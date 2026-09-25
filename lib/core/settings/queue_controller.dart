import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

import '../ffmpeg/ffmpeg_runner.dart';
import '../l10n/app_messages.dart';
import '../ffmpeg/ffprobe_service.dart';
import '../ffmpeg/thumbnail_service.dart';
import '../models/clip_range.dart';
import '../models/conversion_task.dart';
import '../models/queue_progress.dart';
import '../models/app_settings.dart';
import '../models/encode_options.dart';
import '../models/media_format.dart';
import '../models/media_info.dart';
import '../models/subtitle_track.dart';
import '../platform/fs_paths.dart';
import '../service_providers.dart';
import 'settings_controller.dart';
import 'settings_repository.dart';

final queueControllerProvider =
    NotifierProvider<QueueController, QueueState>(QueueController.new);

class QueueState {
  const QueueState({this.tasks = const [], this.busy = false});

  final List<ConversionTask> tasks;
  final bool busy;

  int get pendingCount => tasks
      .where(
        (task) =>
            task.status == TaskStatus.pending ||
            task.status == TaskStatus.queued,
      )
      .length;
  int get runningCount =>
      tasks.where((task) => task.status == TaskStatus.running).length;
  int get failedCount =>
      tasks.where((task) => task.status == TaskStatus.failed).length;
  int get completedCount =>
      tasks.where((task) => task.status == TaskStatus.completed).length;
  QueueProgress get progress => computeQueueProgress(tasks);

  ConversionTask? byId(String id) {
    for (final task in tasks) {
      if (task.id == id) {
        return task;
      }
    }
    return null;
  }

  QueueState copyWith({List<ConversionTask>? tasks, bool? busy}) {
    return QueueState(tasks: tasks ?? this.tasks, busy: busy ?? this.busy);
  }
}

class QueueController extends Notifier<QueueState> {
  static const _uuid = Uuid();

  SettingsRepository get _repository => ref.read(settingsRepositoryProvider);
  FfmpegRunner get _runner => ref.read(ffmpegRunnerProvider);
  FfprobeService get _probe => ref.read(ffprobeServiceProvider);
  ThumbnailService get _thumbnails => ref.read(thumbnailServiceProvider);

  final Map<String, MediaInfo> _mediaInfo = {};
  final Map<String, DateTime> _lastProgressPaint = {};
  final Map<String, FfmpegRunUpdate> _pendingProgress = {};
  final Map<String, Timer> _progressFlush = {};
  bool _pumping = false;

  @override
  QueueState build() {
    ref.onDispose(_clearAllProgressTracking);
    return const QueueState();
  }

  Future<void> initialize() async {
    final tasks = await _repository.loadQueue();
    state = state.copyWith(tasks: tasks);
  }

  ConversionTask? byId(String id) => state.byId(id);

  MediaInfo? infoFor(String path) => _mediaInfo[pathKey(path)];

  Future<MediaInfo> probe(String path, {bool force = false}) async {
    final key = pathKey(path);
    if (!force) {
      final cached = _mediaInfo[key];
      if (cached != null && cached.error == null) {
        return cached;
      }
    }
    await ref.read(settingsControllerProvider.notifier).waitUntilReady();
    final location = ref.read(settingsControllerProvider).location;
    final info = await _probe.probe(location?.ffprobePath ?? '', path);
    if (info.error == null) {
      _mediaInfo[key] = info;
    } else {
      _mediaInfo.remove(key);
    }
    return info;
  }

  Future<List<ConversionTask>> addTasks({
    required List<String> inputPaths,
    required MediaFormat format,
    required String outputDirectory,
    required EncodeOptions encode,
    String? outputFileName,
  }) async {
    if (inputPaths.isEmpty) {
      return const [];
    }
    final created = <ConversionTask>[];
    final reserved = state.tasks.map((task) => pathKey(task.outputPath)).toSet();
    for (final input in inputPaths) {
      final sourceExtension = outputExtensionFor(format, input);
      final preferred = applyOutputNameTemplate(
        outputFileName ?? '',
        input,
        extension: sourceExtension,
      );
      final name = _uniqueQueuedName(
        outputDirectory,
        preferred,
        reserved,
        ref.read(settingsControllerProvider).settings,
      );
      reserved.add(pathKey(joinFsPath(outputDirectory, name)));
      final task = ConversionTask(
        id: _uuid.v4(),
        inputPath: normalizeFsPath(input),
        outputDirectory: normalizeFsPath(outputDirectory),
        outputFileName: name,
        targetFormat: format,
        encode: encode,
        createdAt: DateTime.now(),
      );
      created.add(task);
    }
    state = state.copyWith(tasks: [...state.tasks, ...created]);
    await _persist();
    return created;
  }

  Future<void> updateTask(ConversionTask task) async {
    _replace(task);
    await _persist();
  }

  Future<void> setClip(String taskId, ClipRange? range) async {
    final task = state.byId(taskId);
    if (task == null || !task.canClip) {
      return;
    }
    _replace(
      task.copyWith(clipRange: range, clearClipRange: range == null),
    );
    await _persist();
  }

  Future<void> setSubtitles(String taskId, SubtitleEdit? edit) async {
    final task = state.byId(taskId);
    if (task == null || !task.canEditSubtitles) {
      return;
    }
    _replace(
      task.copyWith(
        subtitleEdit: edit,
        clearSubtitleEdit: edit == null,
      ),
    );
    await _persist();
  }

  Future<void> startAll() async {
    state = state.copyWith(
      tasks: [
        for (final task in state.tasks)
          if (task.status == TaskStatus.pending ||
              task.status == TaskStatus.failed ||
              task.status == TaskStatus.cancelled)
            task.copyWith(
              status: TaskStatus.queued,
              progress: 0,
              clearError: true,
              clearSpeed: true,
              clearEta: true,
              clearLastLog: true,
            )
          else
            task,
      ],
    );
    await _pump();
  }

  Future<void> startOne(String taskId) async {
    final task = state.byId(taskId);
    if (task == null || task.isRunning) {
      return;
    }
    final location = ref.read(settingsControllerProvider).location;
    if (location == null) {
      _replace(
        task.copyWith(
          status: TaskStatus.failed,
          errorMessage: encodeAppMessage(AppMessage.ffmpegNotFound),
        ),
      );
      await _persist();
      return;
    }
    final concurrency = ref.read(settingsControllerProvider).settings.concurrency;
    if (state.runningCount >= concurrency) {
      final others = state.tasks.where((item) => item.id != taskId).toList();
      state = state.copyWith(
        tasks: [
          task.copyWith(
            status: TaskStatus.queued,
            progress: 0,
            clearError: true,
            clearSpeed: true,
            clearEta: true,
            clearLastLog: true,
          ),
          ...others,
        ],
      );
      await _persist();
      return;
    }
    unawaited(_run(task, location.ffmpegPath));
  }

  Future<void> stopOne(String taskId) async {
    await _runner.cancel(taskId);
  }

  Future<void> stopAll() async {
    await _runner.cancelAll();
  }

  Future<void> delete(String taskId) async {
    final task = state.byId(taskId);
    if (task == null) {
      return;
    }
    if (task.isRunning) {
      await _runner.cancel(taskId);
    }
    state = state.copyWith(
      tasks: state.tasks.where((item) => item.id != taskId).toList(),
    );
    _clearProgressTracking(taskId);
    _pruneMediaInfo();
    await _persist();
  }

  Future<void> clearFinished() async {
    state = state.copyWith(
      tasks: state.tasks
          .where(
            (task) =>
                task.status != TaskStatus.completed &&
                task.status != TaskStatus.cancelled,
          )
          .toList(),
    );
    _pruneMediaInfo();
    await _persist();
  }

  Future<void> shutdown() async {
    await _runner.cancelAll();
    final stopped = state.tasks
        .where((task) => task.status != TaskStatus.completed)
        .map((task) {
          if (task.status == TaskStatus.running) {
            return task.copyWith(
              status: TaskStatus.queued,
              progress: 0,
              clearSpeed: true,
              clearEta: true,
              clearLastLog: true,
            );
          }
          return task;
        })
        .toList();
    state = state.copyWith(tasks: stopped);
    _clearAllProgressTracking();
    await _persist();
  }

  Future<void> _pump() async {
    if (_pumping) {
      return;
    }
    _pumping = true;
    try {
      final location = ref.read(settingsControllerProvider).location;
      if (location == null) {
        return;
      }
      while (true) {
        final concurrency = ref
            .read(settingsControllerProvider)
            .settings
            .concurrency;
        final running = state.runningCount;
        if (running >= concurrency) {
          break;
        }
        final next = state.tasks
            .where((task) => task.status == TaskStatus.queued)
            .firstOrNull;
        if (next == null) {
          break;
        }
        unawaited(_run(next, location.ffmpegPath));
        await Future<void>.delayed(const Duration(milliseconds: 30));
      }
    } finally {
      _pumping = false;
    }
  }

  Future<void> _run(ConversionTask task, String ffmpegPath) async {
    if (state.byId(task.id)?.isRunning == true) {
      return;
    }
    _replace(
      task.copyWith(
        status: TaskStatus.running,
        progress: 0,
        startedAt: DateTime.now(),
        clearError: true,
        clearSpeed: true,
        clearEta: true,
        clearLastLog: true,
      ),
    );
    final info = await probe(task.inputPath);
    final settingsNotifier = ref.read(settingsControllerProvider.notifier);
    var running = task;
    if (task.encode.hardwareDecode) {
      await settingsNotifier.ensureHardware();
    }
    final settings = ref.read(settingsControllerProvider);
    if (task.encode.hardwareDecode && !settings.hardware.anyAvailable) {
      running = task.copyWith(
        encode: task.encode.copyWith(hardwareDecode: false),
      );
    }
    final result = await _runner.run(
      ffmpegPath: ffmpegPath,
      task: running,
      totalDuration: info.duration,
      renamePattern: settings.settings.renamePattern,
      hardwareVendor: running.encode.hardwareDecode
          ? settings.hardware.preferredVendor
          : null,
      mediaInfo: info,
      onProgress: (update) => _handleProgress(task.id, update),
    );
    final current = state.byId(task.id);
    if (current == null) {
      await _pump();
      return;
    }
    _clearProgressTracking(task.id);
    if (result.cancelled) {
      _replace(
        current.copyWith(
          status: TaskStatus.cancelled,
          progress: 0,
          clearSpeed: true,
          clearEta: true,
          clearLastLog: true,
          errorMessage: encodeAppMessage(AppMessage.cancelled),
        ),
      );
    } else if (result.success) {
      _replace(
        current.copyWith(
          status: TaskStatus.completed,
          progress: 1,
          outputFileName: p.basename(result.outputPath),
          outputDirectory: directoryOf(result.outputPath),
          clearSpeed: true,
          clearEta: true,
          clearLastLog: true,
          clearError: true,
        ),
      );
    } else {
      _replace(
        current.copyWith(
          status: TaskStatus.failed,
          errorMessage:
              result.error ?? encodeAppMessage(AppMessage.conversionFailed),
          clearSpeed: true,
          clearEta: true,
          clearLastLog: true,
        ),
      );
    }
    await _persist();
    await _pump();
  }

  Future<void> ensureThumbnail(String taskId) async {
    final task = state.byId(taskId);
    if (task == null) {
      return;
    }
    await _ensureThumbnail(task);
  }

  Future<void> _ensureThumbnail(ConversionTask task) async {
    if (task.thumbnailPath != null && File(task.thumbnailPath!).existsSync()) {
      return;
    }
    final location = ref.read(settingsControllerProvider).location;
    if (location == null) {
      return;
    }
    final path = await _thumbnails.capture(
      ffmpegPath: location.ffmpegPath,
      inputPath: task.inputPath,
      taskId: task.id,
    );
    if (path == null) {
      return;
    }
    final current = state.byId(task.id);
    if (current == null) {
      return;
    }
    _replace(current.copyWith(thumbnailPath: path));
    await _persist();
  }

  void _handleProgress(String taskId, FfmpegRunUpdate update) {
    final current = state.byId(taskId);
    if (current == null || !current.isRunning) {
      return;
    }
    _pendingProgress[taskId] = update;
    final now = DateTime.now();
    if (shouldFlushQueueProgress(
      now: now,
      lastPaint: _lastProgressPaint[taskId],
      currentProgress: current.progress,
      nextProgress: update.progress,
    )) {
      _flushProgress(taskId);
      return;
    }
    if (_progressFlush.containsKey(taskId)) {
      return;
    }
    final elapsed = now.difference(_lastProgressPaint[taskId]!);
    final remaining = queueProgressPaintInterval - elapsed;
    final wait = remaining.isNegative ? Duration.zero : remaining;
    _progressFlush[taskId] = Timer(wait, () => _flushProgress(taskId));
  }

  void _flushProgress(String taskId) {
    _progressFlush.remove(taskId)?.cancel();
    final update = _pendingProgress.remove(taskId);
    if (update == null) {
      return;
    }
    final current = state.byId(taskId);
    if (current == null || !current.isRunning) {
      return;
    }
    _lastProgressPaint[taskId] = DateTime.now();
    _replace(
      current.copyWith(
        progress: update.progress,
        speed: update.speed,
        eta: update.eta,
        lastLog: update.lastLog,
      ),
    );
  }

  void _clearProgressTracking(String taskId) {
    _progressFlush.remove(taskId)?.cancel();
    _pendingProgress.remove(taskId);
    _lastProgressPaint.remove(taskId);
  }

  void _clearAllProgressTracking() {
    for (final timer in _progressFlush.values) {
      timer.cancel();
    }
    _progressFlush.clear();
    _pendingProgress.clear();
    _lastProgressPaint.clear();
  }

  void _pruneMediaInfo() {
    final used = state.tasks.map((task) => pathKey(task.inputPath)).toSet();
    _mediaInfo.removeWhere((path, _) => !used.contains(path));
  }

  void _replace(ConversionTask task) {
    state = state.copyWith(
      tasks: [
        for (final item in state.tasks)
          if (item.id == task.id) task else item,
      ],
    );
  }

  Future<void> _persist() {
    return _repository.saveQueue(state.tasks);
  }

  String _uniqueQueuedName(
    String directory,
    String fileName,
    Set<String> reserved,
    AppSettings settings,
  ) {
    final dir = normalizeFsPath(directory);
    final stem = p.basenameWithoutExtension(fileName);
    final ext = p.extension(fileName);
    var candidate = fileName;
    var index = 1;
    while (true) {
      final full = pathKey(joinFsPath(dir, candidate));
      if (!reserved.contains(full) && !File(full).existsSync()) {
        return candidate;
      }
      candidate = settings.renameWithNumber(stem, ext, index);
      index += 1;
    }
  }
}

const queueProgressPaintInterval = Duration(milliseconds: 250);

bool shouldFlushQueueProgress({
  required DateTime now,
  DateTime? lastPaint,
  required double currentProgress,
  required double nextProgress,
}) {
  if (lastPaint == null) {
    return true;
  }
  if (nextProgress >= 1 || nextProgress - currentProgress >= 0.02) {
    return true;
  }
  return now.difference(lastPaint) >= queueProgressPaintInterval;
}

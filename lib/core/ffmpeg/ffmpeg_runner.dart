import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../l10n/app_messages.dart';

import '../models/app_settings.dart';
import '../models/conversion_task.dart';
import '../models/media_info.dart';
import '../platform/fs_paths.dart';
import 'command_builder.dart';
import 'ffmpeg_log.dart';
import 'hardware_probe.dart';
import 'progress_parser.dart';

class FfmpegRunUpdate {
  const FfmpegRunUpdate({
    required this.progress,
    this.speed,
    this.eta,
    this.lastLog,
  });

  final double progress;
  final double? speed;
  final Duration? eta;
  final String? lastLog;
}

class FfmpegRunResult {
  const FfmpegRunResult({
    required this.success,
    required this.outputPath,
    this.error,
    this.cancelled = false,
  });

  final bool success;
  final String outputPath;
  final String? error;
  final bool cancelled;
}

class FfmpegSession {
  FfmpegSession(this._process);

  final Process _process;
  bool _killed = false;

  bool get wasKilled => _killed;

  Future<void> cancel() async {
    _killed = true;
    _process.kill(
      Platform.isWindows ? ProcessSignal.sigkill : ProcessSignal.sigterm,
    );
  }
}

class FfmpegRunner {
  FfmpegRunner({FfmpegCommandBuilder? builder})
    : _builder = builder ?? const FfmpegCommandBuilder();

  final FfmpegCommandBuilder _builder;
  final Map<String, FfmpegSession> _sessions = {};

  bool isRunning(String taskId) => _sessions.containsKey(taskId);

  Future<void> cancel(String taskId) async {
    await _sessions.remove(taskId)?.cancel();
  }

  Future<void> cancelAll() async {
    final sessions = List<FfmpegSession>.from(_sessions.values);
    _sessions.clear();
    for (final session in sessions) {
      await session.cancel();
    }
  }

  Future<FfmpegRunResult> run({
    required String ffmpegPath,
    required ConversionTask task,
    required Duration? totalDuration,
    required void Function(FfmpegRunUpdate update) onProgress,
    String renamePattern = AppSettings.defaultRenamePattern,
    HardwareVendor? hardwareVendor,
    MediaInfo? mediaInfo,
  }) async {
    final outputPath = uniqueOutputPath(
      task.outputDirectory,
      task.outputFileName,
      pattern: renamePattern,
    );
    Directory(task.outputDirectory).createSync(recursive: true);
    final FfmpegCommand command;
    try {
      command = _builder.build(
        ffmpegPath: ffmpegPath,
        task: task,
        outputPath: outputPath,
        hardwareVendor: hardwareVendor,
        mediaInfo: mediaInfo,
      );
    } on FfmpegCommandException catch (error) {
      return FfmpegRunResult(
        success: false,
        outputPath: outputPath,
        error: error.message,
      );
    }
    final effectiveTotal = _effectiveDuration(task, totalDuration);
    final parser = FfmpegProgressParser(total: effectiveTotal);
    final stderrBuffer = StringBuffer();
    var lastLog = '';

    late final Process process;
    try {
      process = await Process.start(
        command.executable,
        command.arguments,
        runInShell: false,
        mode: ProcessStartMode.normal,
        workingDirectory: directoryOf(task.inputPath),
      );
    } catch (error) {
      return FfmpegRunResult(
        success: false,
        outputPath: outputPath,
        error: encodeAppMessage(AppMessage.cannotStartFfmpeg, ['$error']),
      );
    }

    final session = FfmpegSession(process);
    _sessions[task.id] = session;

    void emit(FfmpegProgress snapshot) {
      onProgress(
        FfmpegRunUpdate(
          progress: snapshot.progress,
          speed: snapshot.speed,
          eta: snapshot.eta,
          lastLog: lastLog.isEmpty ? null : lastLog,
        ),
      );
    }

    process.stdout
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen((line) {
          final snapshot = parser.addLine(line);
          if (snapshot != null) {
            emit(snapshot);
          }
        });
    process.stderr
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen((line) {
          stderrBuffer.writeln(line);
          final compact = compactFfmpegLog(line);
          if (compact.isEmpty) {
            return;
          }
          lastLog = compact;
          emit(parser.snapshot());
        });

    final code = await process.exitCode;
    _sessions.remove(task.id);

    if (session.wasKilled) {
      _tryDelete(outputPath);
      return FfmpegRunResult(
        success: false,
        outputPath: outputPath,
        cancelled: true,
        error: encodeAppMessage(AppMessage.cancelled),
      );
    }
    if (code != 0) {
      _tryDelete(outputPath);
      final error = stderrBuffer.toString().trim();
      return FfmpegRunResult(
        success: false,
        outputPath: outputPath,
        error: error.isEmpty
            ? encodeAppMessage(AppMessage.ffmpegExitCode, ['$code'])
            : _lastError(error),
      );
    }
    return FfmpegRunResult(success: true, outputPath: outputPath);
  }

  Duration? _effectiveDuration(ConversionTask task, Duration? total) {
    if (task.clipRange != null) {
      return task.clipRange!.duration;
    }
    return total;
  }

  String _lastError(String error) {
    final lines = const LineSplitter()
        .convert(error)
        .where((line) => line.trim().isNotEmpty)
        .toList();
    if (lines.isEmpty) {
      return error;
    }
    return lines.reversed.take(4).toList().reversed.join('\n');
  }

  void _tryDelete(String path) {
    try {
      final file = File(path);
      if (file.existsSync()) {
        file.deleteSync();
      }
    } catch (_) {}
  }
}

import 'package:ffmpeg_ui/core/ffmpeg/ffmpeg_log.dart';
import 'package:ffmpeg_ui/core/models/conversion_task.dart';
import 'package:ffmpeg_ui/core/models/media_format.dart';
import 'package:ffmpeg_ui/core/settings/queue_controller.dart';
import 'package:ffmpeg_ui/features/queue/queue_stats.dart';
import 'package:ffmpeg_ui/l10n/app_localizations.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final l10n = lookupAppLocalizations(const Locale('zh', 'CN'));

  test('compactFfmpegLog 压缩空白并截断超长日志', () {
    expect(compactFfmpegLog('  Opening   foo.mkv  \n'), "Opening foo.mkv");
    expect(compactFfmpegLog('   '), isEmpty);
    expect(
      compactFfmpegLog('a' * 220, maxLength: 20),
      '${'a' * 19}…',
    );
  });

  test('无剩余时间时时间行跟在已用后面显示最后一条日志', () {
    final startedAt = DateTime(2026, 1, 1, 12);
    final task = _runningTask(
      startedAt: startedAt,
      lastLog: "  Opening   'foo.mkv' for reading  ",
    );
    expect(
      queueTaskStatsLine(l10n, task, now: startedAt.add(const Duration(seconds: 5))),
      "已用 00:05  ·  Opening 'foo.mkv' for reading",
    );
  });

  test('有剩余时间时不显示日志', () {
    final startedAt = DateTime(2026, 1, 1, 12);
    final task = _runningTask(
      startedAt: startedAt,
      eta: const Duration(seconds: 12),
      speed: 1.5,
      lastLog: "Opening 'foo.mkv' for reading",
    );
    expect(
      queueTaskStatsLine(l10n, task, now: startedAt.add(const Duration(seconds: 5))),
      '已用 00:05  ·  剩余 00:12  ·  1.50x',
    );
  });

  test('lastLog 不会写入队列持久化', () {
    final json = _runningTask(
      startedAt: DateTime(2026, 1, 1, 12),
      lastLog: "Opening 'foo.mkv'",
    ).toJson();
    expect(json.containsKey('lastLog'), isFalse);
    expect(ConversionTask.fromJson(json).lastLog, isNull);
  });

  test('进度刷新在首次、进度跳变或超过间隔时立即发生', () {
    final now = DateTime(2026, 1, 1, 12);
    expect(
      shouldFlushQueueProgress(
        now: now,
        currentProgress: 0,
        nextProgress: 0,
      ),
      isTrue,
    );
    expect(
      shouldFlushQueueProgress(
        now: now.add(const Duration(milliseconds: 100)),
        lastPaint: now,
        currentProgress: 0.1,
        nextProgress: 0.11,
      ),
      isFalse,
    );
    expect(
      shouldFlushQueueProgress(
        now: now.add(const Duration(milliseconds: 100)),
        lastPaint: now,
        currentProgress: 0.1,
        nextProgress: 0.13,
      ),
      isTrue,
    );
    expect(
      shouldFlushQueueProgress(
        now: now.add(const Duration(milliseconds: 250)),
        lastPaint: now,
        currentProgress: 0.1,
        nextProgress: 0.11,
      ),
      isTrue,
    );
  });
}

ConversionTask _runningTask({
  required DateTime startedAt,
  String? lastLog,
  Duration? eta,
  double? speed,
}) {
  return ConversionTask(
    id: 'run',
    inputPath: r'C:\in\a.mov',
    outputDirectory: r'C:\out',
    outputFileName: 'a.mp4',
    targetFormat: MediaFormat.mp4,
    status: TaskStatus.running,
    progress: 0,
    startedAt: startedAt,
    lastLog: lastLog,
    eta: eta,
    speed: speed,
    createdAt: DateTime(2026, 1, 1),
  );
}

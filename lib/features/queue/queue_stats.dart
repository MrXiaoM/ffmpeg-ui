import '../../core/ffmpeg/ffmpeg_log.dart';
import '../../core/l10n/app_messages.dart';
import '../../core/models/clip_range.dart';
import '../../core/models/conversion_task.dart';
import '../../l10n/app_localizations.dart';

String queueTaskStatsLine(
  AppLocalizations l10n,
  ConversionTask task, {
  DateTime? now,
}) {
  if (task.status == TaskStatus.failed) {
    final error = localizeMessage(l10n, task.errorMessage);
    return error.isEmpty ? l10n.statusFailed : error;
  }
  if (!task.isRunning) {
    if (task.status == TaskStatus.pending || task.status == TaskStatus.queued) {
      return l10n.taskReady;
    }
    return ' ';
  }
  final bits = <String>[];
  final startedAt = task.startedAt;
  if (startedAt != null) {
    final elapsed = (now ?? DateTime.now()).difference(startedAt);
    bits.add(l10n.elapsed(formatTimecode(elapsed, withMillis: false)));
  }
  if (task.eta != null) {
    bits.add(l10n.remaining(formatTimecode(task.eta!, withMillis: false)));
  } else {
    final log = compactFfmpegLog(task.lastLog ?? '');
    if (log.isNotEmpty) {
      bits.add(log);
    }
  }
  if (task.speed != null) {
    bits.add('${task.speed!.toStringAsFixed(2)}x');
  }
  return bits.isEmpty ? l10n.taskReady : bits.join('  ·  ');
}

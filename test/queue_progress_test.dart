import 'package:ffmpeg_ui/core/models/conversion_task.dart';
import 'package:ffmpeg_ui/core/models/media_format.dart';
import 'package:ffmpeg_ui/core/models/queue_progress.dart';
import 'package:ffmpeg_ui/core/settings/queue_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('empty queue has no progress and is hidden', () {
    const progress = QueueProgress.empty;
    expect(computeQueueProgress(const []), progress);
    expect(progress.value, 0);
    expect(progress.visible, isFalse);
    expect(progress.taskCount, 0);
  });

  test('completed and failed tasks each count as finished', () {
    final progress = computeQueueProgress([
      _task('done', TaskStatus.completed, 1),
      _task('fail', TaskStatus.failed, 0.3),
    ]);
    expect(progress.value, 1);
    expect(progress.visible, isFalse);
    expect(progress.taskCount, 2);
    expect(taskProgressContribution(_task('fail', TaskStatus.failed, 0.3)), 1);
  });

  test('cancelled, pending and queued tasks contribute nothing', () {
    expect(taskProgressContribution(_task('a', TaskStatus.cancelled, 0.8)), 0);
    expect(taskProgressContribution(_task('b', TaskStatus.pending, 0.4)), 0);
    expect(taskProgressContribution(_task('c', TaskStatus.queued, 0.2)), 0);
  });

  test('running tasks contribute their own clamped progress', () {
    expect(taskProgressContribution(_task('run', TaskStatus.running, 0.5)), 0.5);
    expect(taskProgressContribution(_task('low', TaskStatus.running, -1)), 0);
    expect(taskProgressContribution(_task('high', TaskStatus.running, 1.4)), 1);
  });

  test('mixed queue averages contributions and stays visible while active', () {
    final progress = computeQueueProgress([
      _task('done', TaskStatus.completed, 1),
      _task('fail', TaskStatus.failed, 0.1),
      _task('run', TaskStatus.running, 0.5),
      _task('wait', TaskStatus.queued, 0),
    ]);
    expect(progress.value, closeTo(0.625, 0.0001));
    expect(progress.visible, isTrue);
    expect(progress.taskCount, 4);
  });

  test('only pending or cancelled tasks stay hidden', () {
    final pending = computeQueueProgress([
      _task('idle', TaskStatus.pending),
      _task('stop', TaskStatus.cancelled, 0.9),
    ]);
    expect(pending.value, 0);
    expect(pending.visible, isFalse);
  });

  test('queued tasks keep the bar visible even at zero progress', () {
    final progress = computeQueueProgress([
      _task('wait', TaskStatus.queued),
    ]);
    expect(progress.value, 0);
    expect(progress.visible, isTrue);
  });

  test('QueueState exposes computed progress', () {
    final state = QueueState(
      tasks: [
        _task('done', TaskStatus.completed, 1),
        _task('run', TaskStatus.running, 0.5),
      ],
    );
    expect(state.progress.value, closeTo(0.75, 0.0001));
    expect(state.progress.visible, isTrue);
  });
}

ConversionTask _task(String id, TaskStatus status, [double progress = 0]) {
  return ConversionTask(
    id: id,
    inputPath: r'C:\in\a.mov',
    outputDirectory: r'C:\out',
    outputFileName: '$id.mp4',
    targetFormat: MediaFormat.mp4,
    status: status,
    progress: progress,
    createdAt: DateTime(2026, 1, 1),
  );
}

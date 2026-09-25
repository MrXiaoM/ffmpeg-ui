import 'conversion_task.dart';

class QueueProgress {
  const QueueProgress({
    required this.value,
    required this.visible,
    required this.taskCount,
  });

  static const empty = QueueProgress(value: 0, visible: false, taskCount: 0);

  final double value;
  final bool visible;
  final int taskCount;

  @override
  bool operator ==(Object other) {
    return other is QueueProgress &&
        other.value == value &&
        other.visible == visible &&
        other.taskCount == taskCount;
  }

  @override
  int get hashCode => Object.hash(value, visible, taskCount);
}

double taskProgressContribution(ConversionTask task) {
  return switch (task.status) {
    TaskStatus.completed || TaskStatus.failed => 1,
    TaskStatus.running => task.progress.clamp(0.0, 1.0),
    TaskStatus.pending || TaskStatus.queued || TaskStatus.cancelled => 0,
  };
}

QueueProgress computeQueueProgress(Iterable<ConversionTask> tasks) {
  var count = 0;
  var sum = 0.0;
  var visible = false;
  for (final task in tasks) {
    count += 1;
    sum += taskProgressContribution(task);
    if (task.status == TaskStatus.queued || task.status == TaskStatus.running) {
      visible = true;
    }
  }
  if (count == 0) {
    return QueueProgress.empty;
  }
  return QueueProgress(
    value: (sum / count).clamp(0.0, 1.0),
    visible: visible,
    taskCount: count,
  );
}

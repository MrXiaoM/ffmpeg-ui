import 'package:ffmpeg_ui/core/models/queue_progress.dart';
import 'package:ffmpeg_ui/core/platform/window_progress.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('unsupported platforms never call the native progress bar', () async {
    final values = <double>[];
    final bar = SystemWindowProgressBar(
      supported: false,
      setProgressBar: (value) async => values.add(value),
    );

    await bar.apply(
      const QueueProgress(value: 0.4, visible: true, taskCount: 2),
    );

    expect(values, isEmpty);
  });

  test('visible zero still shows a determinate bar', () async {
    final values = <double>[];
    final bar = SystemWindowProgressBar(
      supported: true,
      setProgressBar: (value) async => values.add(value),
    );

    await bar.apply(
      const QueueProgress(value: 0, visible: true, taskCount: 1),
    );

    expect(values, [0]);
  });

  test('visible progress is clamped, rounded and forwarded', () async {
    final values = <double>[];
    final bar = SystemWindowProgressBar(
      supported: true,
      setProgressBar: (value) async => values.add(value),
    );

    await bar.apply(
      const QueueProgress(value: 0.625, visible: true, taskCount: 4),
    );
    await bar.apply(
      const QueueProgress(value: 0.629, visible: true, taskCount: 4),
    );

    expect(values, [0.63]);
  });

  test('hidden progress clears the system icon with -1', () async {
    final values = <double>[];
    final bar = SystemWindowProgressBar(
      supported: true,
      setProgressBar: (value) async => values.add(value),
    );

    await bar.apply(
      const QueueProgress(value: 1, visible: false, taskCount: 2),
    );
    await bar.apply(QueueProgress.empty);

    expect(values, [-1]);
  });
}

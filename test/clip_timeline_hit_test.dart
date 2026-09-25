import 'package:ffmpeg_ui/features/clip_editor/clip_timeline_hit_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const duration = Duration(seconds: 10);
  const fps = 25.0;

  test('handle band prefers in/out handles over playhead', () {
    expect(
      resolveClipTimelineTarget(
        x: 100,
        y: clipTimelineTrackTop,
        width: 400,
        height: clipTimelineHeight,
        startX: 100,
        endX: 300,
        positionX: 100,
      ),
      ClipTimelineTarget.startHandle,
    );
    expect(
      resolveClipTimelineTarget(
        x: 300,
        y: clipTimelineTrackTop + 8,
        width: 400,
        height: clipTimelineHeight,
        startX: 100,
        endX: 300,
        positionX: 300,
      ),
      ClipTimelineTarget.endHandle,
    );
  });

  test('handle band starts at the track, not far below it', () {
    expect(
      resolveClipTimelineTarget(
        x: 100,
        y: clipTimelineTrackTop,
        width: 400,
        height: clipTimelineHeight,
        startX: 100,
        endX: 300,
        positionX: 100,
      ),
      ClipTimelineTarget.startHandle,
    );
  });

  test('upper track hits playhead when not on the handle band', () {
    expect(
      resolveClipTimelineTarget(
        x: 200,
        y: 10,
        width: 400,
        height: clipTimelineHeight,
        startX: 80,
        endX: 320,
        positionX: 200,
      ),
      ClipTimelineTarget.playhead,
    );
  });

  test('overlapping handles pick the nearer one, then the closer half', () {
    expect(
      resolveClipTimelineTarget(
        x: 198,
        y: clipTimelineTrackTop,
        width: 400,
        height: clipTimelineHeight,
        startX: 200,
        endX: 204,
        positionX: 201,
      ),
      ClipTimelineTarget.startHandle,
    );
    expect(
      resolveClipTimelineTarget(
        x: 206,
        y: clipTimelineTrackTop,
        width: 400,
        height: clipTimelineHeight,
        startX: 200,
        endX: 204,
        positionX: 201,
      ),
      ClipTimelineTarget.endHandle,
    );
    expect(
      resolveClipTimelineTarget(
        x: 202,
        y: clipTimelineTrackTop,
        width: 400,
        height: clipTimelineHeight,
        startX: 200,
        endX: 204,
        positionX: 201,
      ),
      ClipTimelineTarget.startHandle,
    );
  });

  test('dragging a handle does not rewrite the other point', () {
    const start = Duration(seconds: 2);
    const end = Duration(seconds: 8);
    expect(
      applyClipTimelineDrag(
        target: ClipTimelineTarget.startHandle,
        time: const Duration(seconds: 4),
        start: start,
        end: end,
        duration: duration,
        fps: fps,
      ),
      const Duration(seconds: 4),
    );
    expect(
      applyClipTimelineDrag(
        target: ClipTimelineTarget.endHandle,
        time: const Duration(seconds: 6),
        start: start,
        end: end,
        duration: duration,
        fps: fps,
      ),
      const Duration(seconds: 6),
    );
    expect(
      applyClipTimelineDrag(
        target: ClipTimelineTarget.playhead,
        time: const Duration(seconds: 5),
        start: start,
        end: end,
        duration: duration,
        fps: fps,
      ),
      const Duration(seconds: 5),
    );
  });

  test('handles keep at least one frame apart and snap to fps', () {
    const start = Duration(seconds: 2);
    const end = Duration(milliseconds: 2080);
    final nextStart = applyClipTimelineDrag(
      target: ClipTimelineTarget.startHandle,
      time: const Duration(seconds: 3),
      start: start,
      end: end,
      duration: duration,
      fps: fps,
    );
    expect(nextStart <= end - const Duration(milliseconds: 40), isTrue);

    final nextEnd = applyClipTimelineDrag(
      target: ClipTimelineTarget.endHandle,
      time: const Duration(seconds: 1),
      start: start,
      end: end,
      duration: duration,
      fps: fps,
    );
    expect(nextEnd >= start + const Duration(milliseconds: 40), isTrue);

    expect(
      snapClipTime(const Duration(milliseconds: 30), fps, duration),
      const Duration(milliseconds: 40),
    );
  });
}

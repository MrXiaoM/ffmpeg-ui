import '../../core/models/clip_range.dart';

enum ClipTimelineTarget { startHandle, endHandle, playhead }

const clipTimelineHeight = 48.0;
const clipTimelinePlayheadTipY = 12.0;
const clipTimelineTrackTop = 22.0;
const clipTimelineTrackHeight = 12.0;
const clipTimelineHandleHitWidth = 24.0;
const clipTimelinePlayheadHitWidth = 16.0;
const clipTimelineHandleBandHeight = 30.0;

double clipTimeToX(Duration time, Duration duration, double width) {
  if (width <= 0) {
    return 0;
  }
  final total = duration.inMicroseconds <= 0 ? 1 : duration.inMicroseconds;
  return width * time.inMicroseconds / total;
}

Duration clipXToTime(double x, Duration duration, double width) {
  final total = duration.inMicroseconds <= 0 ? 1 : duration.inMicroseconds;
  if (width <= 0) {
    return Duration.zero;
  }
  final ratio = (x / width).clamp(0.0, 1.0);
  return Duration(microseconds: (total * ratio).round());
}

Duration clampDuration(Duration value, Duration min, Duration max) {
  if (value < min) {
    return min;
  }
  if (value > max) {
    return max;
  }
  return value;
}

Duration snapClipTime(Duration time, double fps, Duration duration) {
  final safeDuration = duration < Duration.zero ? Duration.zero : duration;
  final range = ClipRange(
    start: Duration.zero,
    end: safeDuration,
    fps: fps,
  );
  final frame = (time.inMicroseconds / 1000000 * range.safeFps).round();
  return clampDuration(range.timeOfFrame(frame), Duration.zero, safeDuration);
}

Duration clampClipStart({
  required Duration value,
  required Duration end,
  required Duration duration,
  required double fps,
}) {
  final minGap = ClipRange(
    start: Duration.zero,
    end: duration,
    fps: fps,
  ).frameStep;
  final maxStart = end > minGap ? end - minGap : Duration.zero;
  return clampDuration(value, Duration.zero, maxStart);
}

Duration clampClipEnd({
  required Duration value,
  required Duration start,
  required Duration duration,
  required double fps,
}) {
  final minGap = ClipRange(
    start: Duration.zero,
    end: duration,
    fps: fps,
  ).frameStep;
  var minEnd = start + minGap;
  if (minEnd > duration) {
    minEnd = duration;
  }
  return clampDuration(value, minEnd, duration);
}

ClipTimelineTarget resolveClipTimelineTarget({
  required double x,
  required double y,
  required double width,
  required double height,
  required double startX,
  required double endX,
  required double positionX,
  double handleHitWidth = clipTimelineHandleHitWidth,
  double playheadHitWidth = clipTimelinePlayheadHitWidth,
  double handleBandHeight = clipTimelineHandleBandHeight,
}) {
  final inHandleBand = height <= 0 || y >= height - handleBandHeight;
  final startDistance = (x - startX).abs();
  final endDistance = (x - endX).abs();
  final playheadDistance = (x - positionX).abs();
  final startHit = startDistance <= handleHitWidth;
  final endHit = endDistance <= handleHitWidth;

  if (inHandleBand && (startHit || endHit)) {
    if (startHit && endHit) {
      if (startDistance < endDistance) {
        return ClipTimelineTarget.startHandle;
      }
      if (endDistance < startDistance) {
        return ClipTimelineTarget.endHandle;
      }
      return x <= (startX + endX) / 2
          ? ClipTimelineTarget.startHandle
          : ClipTimelineTarget.endHandle;
    }
    return startHit
        ? ClipTimelineTarget.startHandle
        : ClipTimelineTarget.endHandle;
  }

  if (!inHandleBand && playheadDistance <= playheadHitWidth) {
    return ClipTimelineTarget.playhead;
  }

  if (startHit || endHit) {
    if (startHit && endHit) {
      if (startDistance < endDistance) {
        return ClipTimelineTarget.startHandle;
      }
      if (endDistance < startDistance) {
        return ClipTimelineTarget.endHandle;
      }
      return x <= (startX + endX) / 2
          ? ClipTimelineTarget.startHandle
          : ClipTimelineTarget.endHandle;
    }
    return startHit
        ? ClipTimelineTarget.startHandle
        : ClipTimelineTarget.endHandle;
  }

  return ClipTimelineTarget.playhead;
}

Duration applyClipTimelineDrag({
  required ClipTimelineTarget target,
  required Duration time,
  required Duration start,
  required Duration end,
  required Duration duration,
  required double fps,
}) {
  final snapped = snapClipTime(time, fps, duration);
  switch (target) {
    case ClipTimelineTarget.startHandle:
      return clampClipStart(
        value: snapped,
        end: end,
        duration: duration,
        fps: fps,
      );
    case ClipTimelineTarget.endHandle:
      return clampClipEnd(
        value: snapped,
        start: start,
        duration: duration,
        fps: fps,
      );
    case ClipTimelineTarget.playhead:
      return clampDuration(snapped, Duration.zero, duration);
  }
}

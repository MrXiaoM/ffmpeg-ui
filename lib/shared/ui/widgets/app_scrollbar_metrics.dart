import 'dart:math' as math;
import 'dart:ui';

const appScrollbarGutter = 14.0;
const appScrollbarMinThumbExtent = 36.0;
const appScrollbarMainAxisMargin = 4.0;
const appScrollbarThickness = 8.0;
const appScrollbarHoverThickness = 10.0;
const appSmoothScrollDuration = Duration(milliseconds: 220);

enum AppScrollbarHit { none, thumb, track }

class AppScrollbarMetrics {
  const AppScrollbarMetrics({
    required this.trackRect,
    required this.thumbRect,
    required this.minScrollExtent,
    required this.maxScrollExtent,
  });

  final Rect trackRect;
  final Rect thumbRect;
  final double minScrollExtent;
  final double maxScrollExtent;

  double get travel => math.max(0.0, trackRect.height - thumbRect.height);

  bool get canScroll => maxScrollExtent > minScrollExtent && travel > 0;

  @override
  bool operator ==(Object other) {
    return other is AppScrollbarMetrics &&
        other.trackRect == trackRect &&
        other.thumbRect == thumbRect &&
        other.minScrollExtent == minScrollExtent &&
        other.maxScrollExtent == maxScrollExtent;
  }

  @override
  int get hashCode => Object.hash(
    trackRect,
    thumbRect,
    minScrollExtent,
    maxScrollExtent,
  );

  AppScrollbarHit hitTest(Offset local) {
    if (!trackRect.contains(local)) {
      return AppScrollbarHit.none;
    }
    if (local.dy >= thumbRect.top && local.dy <= thumbRect.bottom) {
      return AppScrollbarHit.thumb;
    }
    return AppScrollbarHit.track;
  }

  double pixelsForTrackOffset(double localY) {
    if (!canScroll) {
      return minScrollExtent;
    }
    final centerMin = trackRect.top + thumbRect.height / 2;
    final centerMax = trackRect.bottom - thumbRect.height / 2;
    final span = centerMax - centerMin;
    final t = span <= 0 ? 0.0 : ((localY - centerMin) / span).clamp(0.0, 1.0);
    return minScrollExtent + t * (maxScrollExtent - minScrollExtent);
  }

  double pixelsForThumbDelta({
    required double startPixels,
    required double deltaY,
  }) {
    if (!canScroll) {
      return startPixels;
    }
    return (startPixels + deltaY / travel * (maxScrollExtent - minScrollExtent))
        .clamp(minScrollExtent, maxScrollExtent);
  }
}

AppScrollbarMetrics layoutAppScrollbar({
  required Size size,
  required double pixels,
  required double minScrollExtent,
  required double maxScrollExtent,
  required double viewportDimension,
  required double thickness,
}) {
  final track = Rect.fromLTWH(
    0,
    appScrollbarMainAxisMargin,
    size.width,
    math.max(0.0, size.height - 2 * appScrollbarMainAxisMargin),
  );
  final scrollRange = math.max(0.0, maxScrollExtent - minScrollExtent);
  final extent = viewportDimension + scrollRange;
  final double thumbExtent;
  if (scrollRange <= 0 || viewportDimension <= 0 || track.height <= 0) {
    thumbExtent = track.height;
  } else {
    thumbExtent = (track.height * viewportDimension / extent).clamp(
      math.min(appScrollbarMinThumbExtent, track.height),
      track.height,
    );
  }
  final travel = math.max(0.0, track.height - thumbExtent);
  final t = scrollRange <= 0
      ? 0.0
      : ((pixels - minScrollExtent) / scrollRange).clamp(0.0, 1.0);
  final thumbTop = track.top + travel * t;
  final thumbLeft = ((size.width - thickness) / 2).clamp(0.0, size.width);
  return AppScrollbarMetrics(
    trackRect: track,
    thumbRect: Rect.fromLTWH(thumbLeft, thumbTop, thickness, thumbExtent),
    minScrollExtent: minScrollExtent,
    maxScrollExtent: maxScrollExtent,
  );
}

double accumulateSmoothScrollTarget({
  required double pixels,
  required double? pendingTarget,
  required double delta,
  required double minScrollExtent,
  required double maxScrollExtent,
}) {
  final from = pendingTarget ?? pixels;
  return (from + delta).clamp(minScrollExtent, maxScrollExtent);
}

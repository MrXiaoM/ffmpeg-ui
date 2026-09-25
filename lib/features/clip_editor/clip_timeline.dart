import '../../core/models/clip_range.dart';
import '../../shared/ui/ui.dart';
import 'clip_timeline_hit_test.dart';

class ClipTimeline extends StatefulWidget {
  const ClipTimeline({
    super.key,
    required this.duration,
    required this.position,
    required this.start,
    required this.end,
    required this.fps,
    required this.onSeek,
    required this.onStartChanged,
    required this.onEndChanged,
    this.onInteractionEnd,
  });

  final Duration duration;
  final Duration position;
  final Duration start;
  final Duration end;
  final double fps;
  final ValueChanged<Duration> onSeek;
  final ValueChanged<Duration> onStartChanged;
  final ValueChanged<Duration> onEndChanged;
  final VoidCallback? onInteractionEnd;

  @override
  State<ClipTimeline> createState() => _ClipTimelineState();
}

class _ClipTimelineState extends State<ClipTimeline> {
  static const _height = clipTimelineHeight;

  ClipTimelineTarget? _dragTarget;
  Offset? _cursor;
  bool _moved = false;

  Duration _timeOf(double x, double width) {
    return clipXToTime(x, widget.duration, width);
  }

  MouseCursor _cursorFor(ClipTimelineTarget? target) {
    return switch (target) {
      ClipTimelineTarget.startHandle ||
      ClipTimelineTarget.endHandle => SystemMouseCursors.resizeLeftRight,
      ClipTimelineTarget.playhead => SystemMouseCursors.click,
      null => SystemMouseCursors.basic,
    };
  }

  ClipTimelineTarget _targetAt(Offset local, double width) {
    return resolveClipTimelineTarget(
      x: local.dx,
      y: local.dy,
      width: width,
      height: _height,
      startX: clipTimeToX(widget.start, widget.duration, width),
      endX: clipTimeToX(widget.end, widget.duration, width),
      positionX: clipTimeToX(widget.position, widget.duration, width),
    );
  }

  void _apply(ClipTimelineTarget target, Duration time) {
    final next = applyClipTimelineDrag(
      target: target,
      time: time,
      start: widget.start,
      end: widget.end,
      duration: widget.duration,
      fps: widget.fps,
    );
    switch (target) {
      case ClipTimelineTarget.startHandle:
        widget.onStartChanged(next);
      case ClipTimelineTarget.endHandle:
        widget.onEndChanged(next);
      case ClipTimelineTarget.playhead:
        widget.onSeek(next);
    }
  }

  void _followHandle(ClipTimelineTarget target) {
    switch (target) {
      case ClipTimelineTarget.startHandle:
        widget.onSeek(widget.start);
      case ClipTimelineTarget.endHandle:
        widget.onSeek(widget.end);
      case ClipTimelineTarget.playhead:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final timeStyle = appTextStyle(size: 12, color: AppColors.textMuted);
    return Column(
      children: [
        Row(
          children: [
            Text(formatTimecode(Duration.zero), style: timeStyle),
            Expanded(
              child: Text(
                formatTimecode(widget.position),
                textAlign: TextAlign.center,
                style: timeStyle,
              ),
            ),
            Text(formatTimecode(widget.duration), style: timeStyle),
          ],
        ),
        const SizedBox(height: 4),
        SizedBox(
          height: _height,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final startX = clipTimeToX(widget.start, widget.duration, width);
              final endX = clipTimeToX(widget.end, widget.duration, width);
              final positionX = clipTimeToX(
                widget.position,
                widget.duration,
                width,
              );
              final hoverTarget = _dragTarget ??
                  (_cursor == null ? null : _targetAt(_cursor!, width));
              final tooltipTime = switch (_dragTarget) {
                ClipTimelineTarget.startHandle => widget.start,
                ClipTimelineTarget.endHandle => widget.end,
                ClipTimelineTarget.playhead => widget.position,
                null => null,
              };
              final tooltipX = switch (_dragTarget) {
                ClipTimelineTarget.startHandle => startX,
                ClipTimelineTarget.endHandle => endX,
                ClipTimelineTarget.playhead => positionX,
                null => 0.0,
              };

              return MouseRegion(
                cursor: _cursorFor(hoverTarget),
                onHover: (event) => setState(() => _cursor = event.localPosition),
                onExit: (_) {
                  if (_dragTarget == null) {
                    setState(() => _cursor = null);
                  }
                },
                child: Listener(
                  behavior: HitTestBehavior.opaque,
                  onPointerDown: (event) {
                    final local = event.localPosition;
                    final target = _targetAt(local, width);
                    setState(() {
                      _dragTarget = target;
                      _cursor = local;
                      _moved = false;
                    });
                    if (target == ClipTimelineTarget.playhead) {
                      _apply(target, _timeOf(local.dx, width));
                    } else {
                      _followHandle(target);
                    }
                  },
                  onPointerMove: (event) {
                    final target = _dragTarget;
                    if (target == null) {
                      return;
                    }
                    final local = event.localPosition;
                    if (!_moved &&
                        (local.dx - (_cursor?.dx ?? local.dx)).abs() < 1) {
                      setState(() => _cursor = local);
                      return;
                    }
                    _moved = true;
                    setState(() => _cursor = local);
                    _apply(target, _timeOf(local.dx, width));
                  },
                  onPointerUp: (_) => _finishInteraction(),
                  onPointerCancel: (_) => _finishInteraction(),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      CustomPaint(
                        size: Size(width, _height),
                        painter: _TimelinePainter(
                          startX: startX,
                          endX: endX,
                          positionX: positionX,
                          active: _dragTarget,
                        ),
                      ),
                      if (_dragTarget != null && tooltipTime != null)
                        Positioned(
                          left: (tooltipX - 44).clamp(0, width - 88),
                          top: -4,
                          child: IgnorePointer(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: AppColors.surfaceAlt,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: AppColors.borderStrong),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                child: Text(
                                  formatTimecode(tooltipTime),
                                  style: appTextStyle(
                                    size: 12,
                                    weight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _finishInteraction() {
    if (_dragTarget == null) {
      return;
    }
    setState(() {
      _dragTarget = null;
      _moved = false;
    });
    widget.onInteractionEnd?.call();
  }
}

class _TimelinePainter extends CustomPainter {
  _TimelinePainter({
    required this.startX,
    required this.endX,
    required this.positionX,
    required this.active,
  });

  final double startX;
  final double endX;
  final double positionX;
  final ClipTimelineTarget? active;

  @override
  void paint(Canvas canvas, Size size) {
    const trackTop = clipTimelineTrackTop;
    const trackHeight = clipTimelineTrackHeight;
    final track = Paint()..color = const Color(0xFF2A3344);
    final range = Paint()..color = const Color(0x6622D3EE);
    final playhead = Paint()..color = const Color(0xFFF8FAFC);
    final startHandle = Paint()
      ..color = active == ClipTimelineTarget.startHandle
          ? const Color(0xFF67E8F9)
          : const Color(0xFF22D3EE);
    final endHandle = Paint()
      ..color = active == ClipTimelineTarget.endHandle
          ? const Color(0xFF67E8F9)
          : const Color(0xFF22D3EE);

    canvas.drawRRect(
      RRect.fromLTRBR(
        0,
        trackTop,
        size.width,
        trackTop + trackHeight,
        const Radius.circular(8),
      ),
      track,
    );
    canvas.drawRRect(
      RRect.fromLTRBR(
        startX,
        trackTop,
        endX,
        trackTop + trackHeight,
        const Radius.circular(8),
      ),
      range,
    );

    _drawPlayhead(canvas, size, playhead);
    _drawHandle(canvas, startX, startHandle, left: true);
    _drawHandle(canvas, endX, endHandle, left: false);
  }

  void _drawPlayhead(Canvas canvas, Size size, Paint paint) {
    final x = positionX;
    const tipY = clipTimelinePlayheadTipY;
    final path = Path()
      ..moveTo(x - 6, tipY - 10)
      ..lineTo(x + 6, tipY - 10)
      ..lineTo(x, tipY)
      ..close();
    canvas.drawPath(path, paint);
    canvas.drawRect(
      Rect.fromLTWH(x - 1, tipY, 2, size.height - tipY),
      paint,
    );
  }

  void _drawHandle(
    Canvas canvas,
    double x,
    Paint paint, {
    required bool left,
  }) {
    const width = 12.0;
    const radius = Radius.circular(4);
    const top = clipTimelineTrackTop - 4;
    const bottom = clipTimelineTrackTop + clipTimelineTrackHeight + 4;
    final rect = RRect.fromLTRBR(
      x - (left ? 2 : width - 2),
      top,
      x + (left ? width - 2 : 2),
      bottom,
      radius,
    );
    canvas.drawRRect(rect, paint);
    final grip = Paint()..color = const Color(0xFF082028);
    final gripX = left ? x + 3 : x - 7;
    canvas.drawRect(Rect.fromLTWH(gripX, top + 6, 1.5, 12), grip);
    canvas.drawRect(Rect.fromLTWH(gripX + 3.5, top + 6, 1.5, 12), grip);
  }

  @override
  bool shouldRepaint(covariant _TimelinePainter oldDelegate) {
    return startX != oldDelegate.startX ||
        endX != oldDelegate.endX ||
        positionX != oldDelegate.positionX ||
        active != oldDelegate.active;
  }
}

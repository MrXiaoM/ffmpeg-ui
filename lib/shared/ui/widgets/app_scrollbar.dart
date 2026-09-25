import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';

import 'app_scrollbar_metrics.dart';

export 'app_scrollbar_metrics.dart';

class AppScrollbar extends StatefulWidget {
  const AppScrollbar({super.key, required this.child, this.controller});

  final Widget child;
  final ScrollController? controller;

  @override
  State<AppScrollbar> createState() => _AppScrollbarState();
}

class _AppScrollbarState extends State<AppScrollbar> {
  static const _thumbColor = Color(0xFF5B6B82);
  static const _thumbHoverColor = Color(0xFF9AA6B8);
  static const _trackColor = Color(0xFF1A2030);
  static const _trackHoverColor = Color(0xFF252C3A);
  static const _trackBorderColor = Color(0xFF2C3444);

  static PointerScrollEvent? _activeEvent;
  static _AppScrollbarState? _bestState;
  static int _bestDepth = -1;

  bool _hovering = false;
  bool _dragging = false;
  double? _pendingTarget;
  double _dragStartPixels = 0;
  double _dragStartY = 0;
  late final _RenderPointerSignalCatcher _catcher = _RenderPointerSignalCatcher(
    onPointerSignal: _handleCatcherSignal,
    state: this,
  );

  ScrollPosition? get _position {
    final controller = widget.controller;
    if (controller == null || !controller.hasClients) {
      return null;
    }
    return controller.position;
  }

  @override
  void initState() {
    super.initState();
    widget.controller?.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _onScroll());
  }

  @override
  void didUpdateWidget(covariant AppScrollbar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_onScroll);
      widget.controller?.addListener(_onScroll);
      _pendingTarget = null;
    }
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    if (!mounted) {
      return;
    }
    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _onScroll());
      return;
    }
    setState(() {});
  }

  bool _canHandle(PointerScrollEvent event) {
    if (event.kind != PointerDeviceKind.mouse || event.scrollDelta.dy == 0) {
      return false;
    }
    final position = _position;
    if (position == null ||
        !position.hasPixels ||
        !position.physics.shouldAcceptUserOffset(position)) {
      return false;
    }
    final next = accumulateSmoothScrollTarget(
      pixels: position.pixels,
      pendingTarget: _pendingTarget,
      delta: event.scrollDelta.dy,
      minScrollExtent: position.minScrollExtent,
      maxScrollExtent: position.maxScrollExtent,
    );
    return next != (_pendingTarget ?? position.pixels);
  }

  void _handleCatcherSignal(PointerSignalEvent event) {
    if (event is PointerScrollEvent) {
      _offer(event, _catcher.depth);
    }
  }

  void _handleRailSignal(PointerSignalEvent event) {
    if (event is PointerScrollEvent) {
      _offer(event, _catcher.depth + 1);
    }
  }

  void _offer(PointerScrollEvent event, int depth) {
    if (!_canHandle(event)) {
      return;
    }
    if (!identical(_activeEvent, event.original ?? event)) {
      _activeEvent = event.original as PointerScrollEvent? ?? event;
      _bestState = this;
      _bestDepth = depth;
    } else if (depth >= _bestDepth) {
      _bestState = this;
      _bestDepth = depth;
    }
    GestureBinding.instance.pointerSignalResolver.register(event, _deliverBest);
  }

  static void _deliverBest(PointerEvent event) {
    final state = _bestState;
    _activeEvent = null;
    _bestState = null;
    _bestDepth = -1;
    if (state == null || !state.mounted) {
      return;
    }
    final scroll = event as PointerScrollEvent;
    final position = state._position;
    if (position == null || !position.hasPixels) {
      return;
    }
    state._animateTo(
      accumulateSmoothScrollTarget(
        pixels: position.pixels,
        pendingTarget: state._pendingTarget,
        delta: scroll.scrollDelta.dy,
        minScrollExtent: position.minScrollExtent,
        maxScrollExtent: position.maxScrollExtent,
      ),
    );
  }

  void _animateTo(double target) {
    final position = _position;
    if (position == null || !position.hasPixels) {
      return;
    }
    _pendingTarget = target;
    if (target == position.pixels) {
      return;
    }
    position
        .animateTo(
          target,
          duration: appSmoothScrollDuration,
          curve: Curves.easeOutCubic,
        )
        .whenComplete(() {
          if (_pendingTarget == target) {
            _pendingTarget = null;
          }
        });
  }

  void _stopAnimation() {
    _pendingTarget = null;
    final position = _position;
    if (position != null && position.hasPixels) {
      position.jumpTo(position.pixels);
    }
  }

  bool get _showBar {
    final position = _position;
    if (position == null ||
        !position.hasContentDimensions ||
        !position.hasViewportDimension) {
      return false;
    }
    return position.maxScrollExtent > position.minScrollExtent &&
        position.physics.shouldAcceptUserOffset(position);
  }

  AppScrollbarMetrics _metricsFor(Size size) {
    final position = _position;
    return layoutAppScrollbar(
      size: size,
      pixels: position?.hasPixels == true ? position!.pixels : 0,
      minScrollExtent: position?.hasContentDimensions == true
          ? position!.minScrollExtent
          : 0,
      maxScrollExtent: position?.hasContentDimensions == true
          ? position!.maxScrollExtent
          : 0,
      viewportDimension: position?.hasViewportDimension == true
          ? position!.viewportDimension
          : size.height,
      thickness: _hovering ? appScrollbarHoverThickness : appScrollbarThickness,
    );
  }

  void _onRailPointerDown(PointerDownEvent event, AppScrollbarMetrics metrics) {
    final hit = metrics.hitTest(event.localPosition);
    if (hit == AppScrollbarHit.none) {
      return;
    }
    _stopAnimation();
    if (hit == AppScrollbarHit.thumb) {
      final position = _position;
      if (position == null || !position.hasPixels) {
        return;
      }
      setState(() {
        _dragging = true;
        _dragStartPixels = position.pixels;
        _dragStartY = event.localPosition.dy;
      });
      return;
    }
    _animateTo(metrics.pixelsForTrackOffset(event.localPosition.dy));
  }

  void _onRailPointerMove(PointerMoveEvent event, AppScrollbarMetrics metrics) {
    if (!_dragging) {
      return;
    }
    final position = _position;
    if (position == null || !position.hasPixels) {
      return;
    }
    position.jumpTo(
      metrics.pixelsForThumbDelta(
        startPixels: _dragStartPixels,
        deltaY: event.localPosition.dy - _dragStartY,
      ),
    );
  }

  void _onRailPointerUp() {
    if (_dragging) {
      setState(() => _dragging = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final showBar = _showBar;
    return NotificationListener<ScrollMetricsNotification>(
      onNotification: (notification) {
        if (notification.depth == 0) {
          _onScroll();
        }
        return false;
      },
      child: MouseRegion(
        onEnter: showBar ? (_) => setState(() => _hovering = true) : null,
        onExit: showBar ? (_) => setState(() => _hovering = false) : null,
        child: Stack(
          children: [
          Padding(
            padding: showBar
                ? const EdgeInsetsDirectional.only(end: appScrollbarGutter)
                : EdgeInsets.zero,
            child: widget.child,
          ),
          Positioned.fill(
            child: _PointerSignalCatcher(catcher: _catcher),
          ),
          if (showBar)
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              width: appScrollbarGutter,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final metrics = _metricsFor(
                    Size(constraints.maxWidth, constraints.maxHeight),
                  );
                  return _ScrollbarRail(
                    child: Listener(
                      behavior: HitTestBehavior.opaque,
                      onPointerDown: (event) =>
                          _onRailPointerDown(event, metrics),
                      onPointerMove: (event) =>
                          _onRailPointerMove(event, metrics),
                      onPointerUp: (_) => _onRailPointerUp(),
                      onPointerCancel: (_) => _onRailPointerUp(),
                      onPointerSignal: _handleRailSignal,
                      child: CustomPaint(
                        painter: _AppScrollbarPainter(
                          metrics: metrics,
                          hovering: _hovering,
                          thumbColor: _hovering ? _thumbHoverColor : _thumbColor,
                          trackColor: _hovering
                              ? _trackHoverColor
                              : _trackColor,
                          trackBorderColor: _trackBorderColor,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PointerSignalCatcher extends LeafRenderObjectWidget {
  const _PointerSignalCatcher({required this.catcher});

  final _RenderPointerSignalCatcher catcher;

  @override
  RenderObject createRenderObject(BuildContext context) => catcher;

  @override
  void updateRenderObject(
    BuildContext context,
    covariant _RenderPointerSignalCatcher renderObject,
  ) {}
}

class _ScrollbarRail extends SingleChildRenderObjectWidget {
  const _ScrollbarRail({required super.child});

  @override
  RenderObject createRenderObject(BuildContext context) => _RenderScrollbarRail();
}

class _RenderScrollbarRail extends RenderProxyBox {}

class _RenderPointerSignalCatcher extends RenderBox {
  _RenderPointerSignalCatcher({
    required this.onPointerSignal,
    required this.state,
  });

  PointerSignalEventListener onPointerSignal;
  _AppScrollbarState state;

  @override
  bool get sizedByParent => true;

  @override
  Size computeDryLayout(BoxConstraints constraints) => constraints.biggest;

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    if (size.contains(position)) {
      result.add(BoxHitTestEntry(this, position));
    }
    return false;
  }

  @override
  void handleEvent(PointerEvent event, covariant HitTestEntry entry) {
    if (event is PointerSignalEvent) {
      onPointerSignal(event);
    }
  }
}

class _AppScrollbarPainter extends CustomPainter {
  const _AppScrollbarPainter({
    required this.metrics,
    required this.hovering,
    required this.thumbColor,
    required this.trackColor,
    required this.trackBorderColor,
  });

  final AppScrollbarMetrics metrics;
  final bool hovering;
  final Color thumbColor;
  final Color trackColor;
  final Color trackBorderColor;

  @override
  void paint(Canvas canvas, Size size) {
    final track = metrics.trackRect;
    final radius = Radius.circular(hovering ? 8 : 7);
    canvas.drawRRect(
      RRect.fromRectAndRadius(track, radius),
      Paint()..color = trackColor,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(track, radius),
      Paint()
        ..color = trackBorderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(metrics.thumbRect, const Radius.circular(8)),
      Paint()..color = thumbColor,
    );
  }

  @override
  bool shouldRepaint(covariant _AppScrollbarPainter oldDelegate) {
    return metrics != oldDelegate.metrics ||
        hovering != oldDelegate.hovering ||
        thumbColor != oldDelegate.thumbColor ||
        trackColor != oldDelegate.trackColor ||
        trackBorderColor != oldDelegate.trackBorderColor;
  }
}

import 'dart:math' as math;

import '../ui/ui.dart';

class AnchoredTooltip extends StatefulWidget {
  const AnchoredTooltip({super.key, required this.message, required this.child});

  final String message;
  final Widget child;

  @override
  State<AnchoredTooltip> createState() => _AnchoredTooltipState();
}

class _AnchoredTooltipState extends State<AnchoredTooltip> {
  final _key = GlobalKey();
  final _portal = OverlayPortalController();

  void _show() {
    if (widget.message.trim().isEmpty || _portal.isShowing) {
      return;
    }
    _portal.show();
  }

  void _hide() {
    if (!_portal.isShowing) {
      return;
    }
    _portal.hide();
  }

  @override
  Widget build(BuildContext context) {
    return OverlayPortal(
      controller: _portal,
      overlayChildBuilder: (context) {
        return _TooltipOverlay(targetKey: _key, message: widget.message);
      },
      child: MouseRegion(
        key: _key,
        onEnter: (_) => _show(),
        onExit: (_) => _hide(),
        child: widget.child,
      ),
    );
  }
}

class _TooltipOverlay extends StatefulWidget {
  const _TooltipOverlay({required this.targetKey, required this.message});

  final GlobalKey targetKey;
  final String message;

  @override
  State<_TooltipOverlay> createState() => _TooltipOverlayState();
}

class _TooltipOverlayState extends State<_TooltipOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animation;
  Rect? _target;

  @override
  void initState() {
    super.initState();
    _animation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 140),
      reverseDuration: const Duration(milliseconds: 90),
    )..forward();
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncTarget());
  }

  @override
  void didUpdateWidget(covariant _TooltipOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncTarget());
  }

  @override
  void dispose() {
    _animation.dispose();
    super.dispose();
  }

  void _syncTarget() {
    if (!mounted) {
      return;
    }
    final box = widget.targetKey.currentContext?.findRenderObject() as RenderBox?;
    final overlayBox =
        Overlay.maybeOf(context)?.context.findRenderObject() as RenderBox?;
    if (box == null ||
        overlayBox == null ||
        !box.attached ||
        !box.hasSize ||
        !overlayBox.hasSize) {
      return;
    }
    final target =
        overlayBox.globalToLocal(box.localToGlobal(Offset.zero)) & box.size;
    if (_target == target) {
      return;
    }
    setState(() => _target = target);
  }

  @override
  Widget build(BuildContext context) {
    final target = _target;
    if (target == null) {
      return const SizedBox.shrink();
    }
    final curved = CurvedAnimation(
      parent: _animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    return IgnorePointer(
      child: FadeTransition(
        opacity: curved,
        child: CustomMultiChildLayout(
          delegate: _TooltipLayout(target),
          children: [
            LayoutId(
              id: _TooltipSlot.bubble,
              child: _TooltipBubble(message: widget.message),
            ),
            LayoutId(
              id: _TooltipSlot.arrow,
              child: CustomPaint(
                size: const Size(12, 6),
                painter: const _ArrowPainter(Color(0xF0141822)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _TooltipSlot { bubble, arrow }

class _TooltipLayout extends MultiChildLayoutDelegate {
  _TooltipLayout(this.target);

  final Rect target;

  @override
  Size getSize(BoxConstraints constraints) => constraints.biggest;

  @override
  void performLayout(Size size) {
    const margin = 8.0;
    const gap = 6.0;
    final maxWidth = math.min(360.0, math.max(32.0, size.width - margin * 2));
    final bubble = layoutChild(
      _TooltipSlot.bubble,
      BoxConstraints(maxWidth: maxWidth, maxHeight: size.height - margin * 2),
    );
    final arrow = layoutChild(
      _TooltipSlot.arrow,
      const BoxConstraints.tightFor(width: 12, height: 6),
    );
    var left = target.center.dx - bubble.width / 2;
    left = left.clamp(margin, math.max(margin, size.width - margin - bubble.width));
    var top = target.top - gap - arrow.height - bubble.height;
    var above = true;
    if (top < margin) {
      above = false;
      top = target.bottom + gap + arrow.height;
    }
    if (top + bubble.height > size.height - margin) {
      top = math.max(margin, size.height - margin - bubble.height);
    }
    positionChild(_TooltipSlot.bubble, Offset(left, top));
    var arrowLeft = target.center.dx - arrow.width / 2;
    arrowLeft = arrowLeft.clamp(
      left + 8,
      math.max(left + 8, left + bubble.width - arrow.width - 8),
    );
    final arrowTop = above ? top + bubble.height : top - arrow.height;
    positionChild(_TooltipSlot.arrow, Offset(arrowLeft, arrowTop));
  }

  @override
  bool shouldRelayout(covariant _TooltipLayout oldDelegate) {
    return oldDelegate.target != target;
  }
}

class _TooltipBubble extends StatelessWidget {
  const _TooltipBubble({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xF0141822),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(message, style: appTextStyle(size: 13)),
      ),
    );
  }
}

class _ArrowPainter extends CustomPainter {
  const _ArrowPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _ArrowPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

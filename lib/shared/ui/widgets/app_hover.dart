import 'package:flutter/material.dart';

class AppHoverStates {
  const AppHoverStates({required this.isHovered});

  final bool isHovered;
}

class AppHover extends StatefulWidget {
  const AppHover({
    super.key,
    required this.builder,
    this.onPressed,
  });

  final VoidCallback? onPressed;
  final Widget Function(BuildContext context, AppHoverStates states) builder;

  @override
  State<AppHover> createState() => _AppHoverState();
}

class _AppHoverState extends State<AppHover> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    return MouseRegion(
      cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: enabled ? (_) => setState(() => _hovered = true) : null,
      onExit: enabled ? (_) => setState(() => _hovered = false) : null,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onPressed,
        child: widget.builder(
          context,
          AppHoverStates(isHovered: enabled && _hovered),
        ),
      ),
    );
  }
}

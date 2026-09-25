import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../app_icons.dart';
import '../app_theme.dart';
import 'app_hover.dart';

class AppDropdownItem<T> {
  const AppDropdownItem({this.value, required this.child});

  final T? value;
  final Widget child;
}

class AppDropdown<T> extends StatefulWidget {
  const AppDropdown({
    super.key,
    required this.items,
    this.value,
    this.onChanged,
    this.isExpanded = false,
    this.placeholder,
    this.popupColor,
  });

  final List<AppDropdownItem<T>> items;
  final T? value;
  final ValueChanged<T?>? onChanged;
  final bool isExpanded;
  final Widget? placeholder;
  final Color? popupColor;

  @override
  State<AppDropdown<T>> createState() => _AppDropdownState<T>();
}

class _AppDropdownState<T> extends State<AppDropdown<T>> {
  final _key = GlobalKey();
  OverlayEntry? _entry;
  bool _open = false;

  bool get _enabled => widget.onChanged != null && widget.items.isNotEmpty;

  @override
  void dispose() {
    _drop();
    super.dispose();
  }

  void _toggle() {
    if (!_enabled) {
      return;
    }
    if (_open) {
      _hide();
    } else {
      _show();
    }
  }

  void _show() {
    if (_entry != null) {
      return;
    }
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) {
      return;
    }
    _entry = OverlayEntry(
      builder: (context) {
        final box = _key.currentContext?.findRenderObject() as RenderBox?;
        final overlayBox =
            Overlay.of(context).context.findRenderObject() as RenderBox?;
        if (box == null ||
            overlayBox == null ||
            !box.attached ||
            !box.hasSize ||
            !overlayBox.hasSize) {
          return const SizedBox.shrink();
        }
        const gap = 6.0;
        const margin = 8.0;
        final target =
            overlayBox.globalToLocal(box.localToGlobal(Offset.zero)) & box.size;
        final menuWidth = math.max(240.0, target.width);
        final maxHeight = math.min(320.0, overlayBox.size.height - margin * 2);
        var left = target.left;
        left = left.clamp(
          margin,
          math.max(margin, overlayBox.size.width - margin - menuWidth),
        );
        var top = target.bottom + gap;
        if (top + 160 > overlayBox.size.height - margin) {
          top = math.max(margin, target.top - gap - maxHeight);
        }
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: _hide,
              ),
            ),
            Positioned(
              left: left,
              top: top,
              width: menuWidth,
              child: _DropdownMenu<T>(
                items: widget.items,
                value: widget.value,
                maxHeight: maxHeight,
                onSelected: (value) {
                  widget.onChanged?.call(value);
                  _hide();
                },
              ),
            ),
          ],
        );
      },
    );
    overlay.insert(_entry!);
    setState(() => _open = true);
  }

  void _hide() {
    _drop();
    if (mounted && _open) {
      setState(() => _open = false);
    } else {
      _open = false;
    }
  }

  void _drop() {
    _entry?.remove();
    _entry = null;
  }

  @override
  Widget build(BuildContext context) {
    AppDropdownItem<T>? selected;
    for (final item in widget.items) {
      if (item.value == widget.value) {
        selected = item;
        break;
      }
    }
    return AppHover(
      key: _key,
      onPressed: _enabled ? _toggle : null,
      builder: (context, states) {
        final highlighted = _open || states.isHovered;
        return SizedBox(
          width: widget.isExpanded ? double.infinity : null,
          height: appControlHeight,
          child: DecoratedBox(
            decoration: appControlDecoration(
              fill: _enabled ? AppColors.surface : AppColors.surfaceAlt,
              border: highlighted ? AppColors.accent : AppColors.borderStrong,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  Expanded(
                    child: DefaultTextStyle.merge(
                      style: appTextStyle(
                        size: 14,
                        color: selected == null || !_enabled
                            ? AppColors.textMuted
                            : AppColors.text,
                      ).copyWith(height: 1),
                      child: selected?.child ??
                          widget.placeholder ??
                          const SizedBox.shrink(),
                    ),
                  ),
                  Icon(
                    _open ? AppIcons.chevronUp : AppIcons.chevronDown,
                    size: 16,
                    color: AppColors.textMuted,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _DropdownMenu<T> extends StatelessWidget {
  const _DropdownMenu({
    required this.items,
    required this.onSelected,
    required this.maxHeight,
    this.value,
  });

  final List<AppDropdownItem<T>> items;
  final T? value;
  final ValueChanged<T?> onSelected;
  final double maxHeight;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(maxHeight: maxHeight),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.borderStrong),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 6),
            shrinkWrap: true,
            children: [
              for (final item in items)
                AppHover(
                  onPressed: () => onSelected(item.value),
                  builder: (context, states) {
                    final selected = item.value == value;
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      color: selected
                          ? AppColors.accentDim.withValues(alpha: 0.35)
                          : states.isHovered
                          ? AppColors.surfaceAlt
                          : const Color(0x00000000),
                      child: DefaultTextStyle.merge(
                        style: appTextStyle(size: 14),
                        child: item.child,
                      ),
                    );
                  },
                ),
            ],
        ),
      ),
    );
  }
}

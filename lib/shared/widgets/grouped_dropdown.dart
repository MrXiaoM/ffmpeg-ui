import 'dart:math' as math;

import '../ui/ui.dart';

class GroupedDropdownGroup<T> {
  const GroupedDropdownGroup({required this.title, required this.items});

  final String title;
  final List<T> items;
}

class GroupedDropdown<T> extends StatefulWidget {
  const GroupedDropdown({
    super.key,
    required this.groups,
    required this.itemLabel,
    required this.onChanged,
    this.value,
    this.placeholder = '',
    this.itemDescription,
    this.enabled = true,
  });

  final T? value;
  final String placeholder;
  final List<GroupedDropdownGroup<T>> groups;
  final String Function(T value) itemLabel;
  final String Function(T value)? itemDescription;
  final ValueChanged<T> onChanged;
  final bool enabled;

  @override
  State<GroupedDropdown<T>> createState() => _GroupedDropdownState<T>();
}

class _GroupedDropdownState<T> extends State<GroupedDropdown<T>> {
  final _key = GlobalKey();
  OverlayEntry? _entry;
  bool _open = false;

  @override
  void dispose() {
    _dropEntry();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant GroupedDropdown<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    _entry?.markNeedsBuild();
  }

  void _toggle() {
    if (!widget.enabled) {
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
              child: _GroupedDropdownMenu<T>(
                groups: widget.groups,
                value: widget.value,
                itemLabel: widget.itemLabel,
                itemDescription: widget.itemDescription,
                maxHeight: maxHeight,
                onSelected: (value) {
                  widget.onChanged(value);
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
    _dropEntry();
    if (mounted && _open) {
      setState(() => _open = false);
    } else {
      _open = false;
    }
  }

  void _dropEntry() {
    _entry?.remove();
    _entry = null;
  }

  @override
  Widget build(BuildContext context) {
    final selected = widget.value;
    final description = selected == null
        ? null
        : widget.itemDescription?.call(selected);
    return HoverButton(
      key: _key,
      onPressed: widget.enabled ? _toggle : null,
      builder: (context, states) {
        final highlighted = _open || states.isHovered;
        return SizedBox(
          height: appControlHeight,
          width: double.infinity,
          child: DecoratedBox(
            decoration: appControlDecoration(
              fill: widget.enabled ? AppColors.surface : AppColors.surfaceAlt,
              border: highlighted ? AppColors.accent : AppColors.borderStrong,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Expanded(
                    child: _DropdownLabel(
                      label: selected != null
                          ? widget.itemLabel(selected)
                          : widget.placeholder,
                      description: description,
                      muted: selected == null || !widget.enabled,
                    ),
                  ),
                  Icon(
                    _open ? FluentIcons.chevron_up : FluentIcons.chevron_down,
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

class _DropdownLabel extends StatelessWidget {
  const _DropdownLabel({
    required this.label,
    required this.muted,
    this.description,
    this.selected = false,
    this.reserveCheck = false,
  });

  static const _checkSize = 14.0;
  static const _checkGap = 8.0;

  final String label;
  final String? description;
  final bool muted;
  final bool selected;
  final bool reserveCheck;

  @override
  Widget build(BuildContext context) {
    final descriptionText = description?.trim() ?? '';
    return Row(
      children: [
        Flexible(
          flex: 0,
          fit: FlexFit.loose,
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: appTextStyle(
              size: 14,
              weight: FontWeight.w600,
              color: muted ? AppColors.textMuted : AppColors.text,
            ).copyWith(height: 1),
          ),
        ),
        const Expanded(child: SizedBox.shrink()),
        if (descriptionText.isNotEmpty)
          Flexible(
            flex: 0,
            fit: FlexFit.loose,
            child: Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Text(
                descriptionText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
                style: appTextStyle(
                  size: 13,
                  color: AppColors.textMuted,
                ).copyWith(height: 1),
              ),
            ),
          ),
        if (reserveCheck)
          Padding(
            padding: const EdgeInsets.only(left: _checkGap),
            child: SizedBox(
              width: _checkSize,
              height: _checkSize,
              child: selected
                  ? const Icon(
                      FluentIcons.check_mark,
                      size: _checkSize,
                      color: AppColors.accent,
                    )
                  : null,
            ),
          ),
      ],
    );
  }
}

class _GroupedDropdownMenu<T> extends StatelessWidget {
  const _GroupedDropdownMenu({
    required this.groups,
    required this.itemLabel,
    required this.onSelected,
    required this.maxHeight,
    this.itemDescription,
    this.value,
  });

  final List<GroupedDropdownGroup<T>> groups;
  final T? value;
  final String Function(T value) itemLabel;
  final String Function(T value)? itemDescription;
  final ValueChanged<T> onSelected;
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
              for (final group in groups) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                  child: Text(
                    group.title,
                    style: appTextStyle(
                      size: 12,
                      weight: FontWeight.w700,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
                for (final item in group.items)
                  HoverButton(
                    onPressed: () => onSelected(item),
                    builder: (context, states) {
                      final selected = item == value;
                      final hovered = states.isHovered;
                      return SizedBox(
                        height: appControlHeight,
                        width: double.infinity,
                        child: ColoredBox(
                          color: selected
                              ? AppColors.accentDim.withValues(alpha: 0.35)
                              : hovered
                              ? AppColors.surfaceAlt
                              : const Color(0x00000000),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: _DropdownLabel(
                              label: itemLabel(item),
                              description: itemDescription?.call(item),
                              muted: false,
                              selected: selected,
                              reserveCheck: true,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_theme.dart';
import 'app_button.dart';
import 'app_editable_field.dart';

enum SpinButtonPlacementMode { inline, compact, none }

class AppNumberBox<T extends num> extends StatefulWidget {
  const AppNumberBox({
    super.key,
    required this.value,
    this.min,
    this.max,
    this.placeholder,
    this.onChanged,
    this.smallChange,
    this.mode = SpinButtonPlacementMode.inline,
  });

  final T? value;
  final num? min;
  final num? max;
  final String? placeholder;
  final ValueChanged<T?>? onChanged;
  final num? smallChange;
  final SpinButtonPlacementMode mode;

  @override
  State<AppNumberBox<T>> createState() => _AppNumberBoxState<T>();
}

class _AppNumberBoxState<T extends num> extends State<AppNumberBox<T>> {
  late final TextEditingController _controller;

  bool get _decimal => T == double;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _format(widget.value));
  }

  @override
  void didUpdateWidget(covariant AppNumberBox<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final next = _format(widget.value);
    if (_controller.text != next && !_controller.text.endsWith('.')) {
      _controller.value = TextEditingValue(
        text: next,
        selection: TextSelection.collapsed(offset: next.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _format(T? value) {
    if (value == null) {
      return '';
    }
    if (value is double) {
      if (value == value.roundToDouble()) {
        return value.toInt().toString();
      }
      return value.toString();
    }
    return value.toString();
  }

  T? _parse(String raw) {
    final text = raw.trim();
    if (text.isEmpty) {
      return null;
    }
    if (_decimal) {
      final parsed = double.tryParse(text);
      return parsed as T?;
    }
    final parsed = int.tryParse(text);
    return parsed as T?;
  }

  T _clamp(T value) {
    var next = value.toDouble();
    if (widget.min != null && next < widget.min!) {
      next = widget.min!.toDouble();
    }
    if (widget.max != null && next > widget.max!) {
      next = widget.max!.toDouble();
    }
    if (_decimal) {
      return next as T;
    }
    return next.round() as T;
  }

  void _emit(T? value) {
    widget.onChanged?.call(value == null ? null : _clamp(value));
  }

  void _nudge(num delta) {
    final current = widget.value ?? (0 as T);
    final next = current.toDouble() + delta;
    if (_decimal) {
      _emit(next as T);
    } else {
      _emit(next.round() as T);
    }
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onChanged != null;
    final step = widget.smallChange ?? (_decimal ? 0.5 : 1);
    return Row(
      children: [
        Expanded(
          child: AppEditableField(
            controller: _controller,
            enabled: enabled,
            placeholder: widget.placeholder,
            keyboardType: TextInputType.numberWithOptions(
              decimal: _decimal,
              signed: true,
            ),
            inputFormatters: [
              FilteringTextInputFormatter.allow(
                _decimal ? RegExp(r'[-0-9.]') : RegExp(r'[-0-9]'),
              ),
            ],
            onChanged: (raw) => _emit(_parse(raw)),
          ),
        ),
        if (widget.mode == SpinButtonPlacementMode.inline) ...[
          const SizedBox(width: 6),
          AppIconButton(
            icon: const Icon(Icons.remove, size: 14),
            size: appControlHeight,
            onPressed: enabled ? () => _nudge(-step) : null,
          ),
          const SizedBox(width: 4),
          AppIconButton(
            icon: const Icon(Icons.add, size: 14),
            size: appControlHeight,
            onPressed: enabled ? () => _nudge(step) : null,
          ),
        ],
      ],
    );
  }
}

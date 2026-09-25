import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_theme.dart';

class AppEditableField extends StatefulWidget {
  const AppEditableField({
    super.key,
    this.controller,
    this.placeholder,
    this.onChanged,
    this.enabled = true,
    this.keyboardType,
    this.inputFormatters,
  });

  final TextEditingController? controller;
  final String? placeholder;
  final ValueChanged<String>? onChanged;
  final bool enabled;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  @override
  State<AppEditableField> createState() => _AppEditableFieldState();
}

class _AppEditableFieldState extends State<AppEditableField> {
  late final FocusNode _focusNode;
  TextEditingController? _ownedController;

  TextEditingController get _controller =>
      widget.controller ?? (_ownedController ??= TextEditingController());

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _controller.addListener(_onTextChanged);
  }

  @override
  void didUpdateWidget(covariant AppEditableField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller == widget.controller) {
      return;
    }
    oldWidget.controller?.removeListener(_onTextChanged);
    _ownedController?.removeListener(_onTextChanged);
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _ownedController?.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.enabled;
    return SizedBox(
      height: appControlHeight,
      child: Material(
        color: Colors.transparent,
        child: DecoratedBox(
          decoration: appControlDecoration(
            fill: enabled ? AppColors.surface : AppColors.surfaceAlt,
            border: enabled ? AppColors.borderStrong : AppColors.border,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                if (_controller.text.isEmpty && widget.placeholder != null)
                  IgnorePointer(
                    child: Text(
                      widget.placeholder!,
                      style: appTextStyle(
                        size: appFieldTextSize,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                EditableText(
                  controller: _controller,
                  focusNode: _focusNode,
                  readOnly: !enabled,
                  keyboardType: widget.keyboardType,
                  inputFormatters: widget.inputFormatters,
                  onChanged: widget.onChanged,
                  style: appTextStyle(size: appFieldTextSize),
                  strutStyle: appFieldStrutStyle,
                  cursorColor: AppColors.accent,
                  backgroundCursorColor: Colors.transparent,
                  selectionControls: materialTextSelectionControls,
                  maxLines: 1,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_editable_field.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
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
  Widget build(BuildContext context) {
    return AppEditableField(
      controller: controller,
      placeholder: placeholder,
      onChanged: onChanged,
      enabled: enabled,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
    );
  }
}

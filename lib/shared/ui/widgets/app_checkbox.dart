import 'package:flutter/material.dart';

import '../app_icons.dart';
import '../app_theme.dart';

class AppCheckbox extends StatelessWidget {
  const AppCheckbox({
    super.key,
    required this.checked,
    this.onChanged,
    this.content,
  });

  final bool? checked;
  final ValueChanged<bool?>? onChanged;
  final Widget? content;

  @override
  Widget build(BuildContext context) {
    final enabled = onChanged != null;
    final on = checked == true;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: enabled ? () => onChanged!(!on) : null,
      child: Row(
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: on && enabled ? AppColors.accent : AppColors.surface,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: on && enabled ? AppColors.accentDim : AppColors.borderStrong,
              ),
            ),
            child: on
                ? Icon(
                    AppIcons.check,
                    size: 14,
                    color: enabled ? AppColors.accentOnFill : AppColors.textMuted,
                  )
                : null,
          ),
          if (content != null) ...[
            const SizedBox(width: 8),
            Expanded(
              child: DefaultTextStyle.merge(
                style: appTextStyle(
                  size: 14,
                  color: enabled ? AppColors.text : AppColors.textMuted,
                ),
                child: content!,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

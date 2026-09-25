import 'package:flutter/material.dart';

import '../app_theme.dart';

class AppSwitch extends StatelessWidget {
  const AppSwitch({
    super.key,
    required this.checked,
    this.onChanged,
    this.content,
  });

  final bool checked;
  final ValueChanged<bool>? onChanged;
  final Widget? content;

  @override
  Widget build(BuildContext context) {
    final enabled = onChanged != null;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: enabled ? () => onChanged!(!checked) : null,
      child: SizedBox(
        height: appControlHeight,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 140),
              width: 40,
              height: 22,
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: !enabled
                    ? AppColors.border
                    : checked
                    ? AppColors.accent
                    : AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: checked && enabled
                      ? AppColors.accentDim
                      : AppColors.borderStrong,
                ),
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 140),
                alignment: checked ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: enabled ? AppColors.text : AppColors.textMuted,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            if (content != null) ...[
              const SizedBox(width: 8),
              Flexible(
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
      ),
    );
  }
}

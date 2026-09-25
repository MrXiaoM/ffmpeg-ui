import 'package:flutter/material.dart';

import '../app_icons.dart';
import '../app_theme.dart';
import 'app_button.dart';

enum AppInfoSeverity { success, warning, danger, info }

class AppInfoBar extends StatelessWidget {
  const AppInfoBar({
    super.key,
    required this.title,
    this.content,
    this.severity = AppInfoSeverity.info,
    this.onClose,
  });

  final Widget title;
  final Widget? content;
  final AppInfoSeverity severity;
  final VoidCallback? onClose;

  Color get _accent => switch (severity) {
    AppInfoSeverity.success => AppColors.success,
    AppInfoSeverity.warning => AppColors.warning,
    AppInfoSeverity.danger => AppColors.danger,
    AppInfoSeverity.info => AppColors.accent,
  };

  IconData get _icon => switch (severity) {
    AppInfoSeverity.success => AppIcons.completed,
    AppInfoSeverity.warning => AppIcons.warning,
    AppInfoSeverity.danger => AppIcons.warning,
    AppInfoSeverity.info => AppIcons.info,
  };

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(_icon, size: 16, color: _accent),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  DefaultTextStyle.merge(
                    style: appTextStyle(weight: FontWeight.w700),
                    child: title,
                  ),
                  if (content != null) ...[
                    const SizedBox(height: 4),
                    DefaultTextStyle.merge(
                      style: appTextStyle(size: 13, color: AppColors.textMuted),
                      child: content!,
                    ),
                  ],
                ],
              ),
            ),
            if (onClose != null)
              AppIconButton(
                icon: const Icon(AppIcons.close, size: 12),
                onPressed: onClose,
              ),
          ],
        ),
      ),
    );
  }
}

Future<void> showAppInfoBar(
  BuildContext context, {
  required Widget Function(BuildContext context, VoidCallback close) builder,
}) async {
  final overlay = Overlay.of(context, rootOverlay: true);
  late OverlayEntry entry;
  void close() {
    if (entry.mounted) {
      entry.remove();
    }
  }

  entry = OverlayEntry(
    builder: (context) {
      return Positioned(
        left: 24,
        right: 24,
        bottom: 24,
        child: Material(
          color: Colors.transparent,
          child: builder(context, close),
        ),
      );
    },
  );
  overlay.insert(entry);
  await Future<void>.delayed(const Duration(seconds: 4));
  close();
}

Future<void> displayInfoBar(
  BuildContext context, {
  required Widget Function(BuildContext context, VoidCallback close) builder,
}) {
  return showAppInfoBar(context, builder: builder);
}

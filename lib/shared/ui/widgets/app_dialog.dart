import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../../widgets/motion.dart';

class AppDialog extends StatelessWidget {
  const AppDialog({
    super.key,
    this.title,
    this.content,
    this.actions,
    this.constraints = const BoxConstraints(maxWidth: 420),
  });

  final Widget? title;
  final Widget? content;
  final List<Widget>? actions;
  final BoxConstraints constraints;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: constraints,
        child: Material(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderStrong),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (title != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                    child: DefaultTextStyle.merge(
                      style: appTextStyle(size: 16, weight: FontWeight.w700),
                      child: title!,
                    ),
                  ),
                if (content != null)
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
                      child: DefaultTextStyle.merge(
                        style: appTextStyle(),
                        child: content!,
                      ),
                    ),
                  ),
                if (actions != null)
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
                    decoration: const BoxDecoration(
                      border: Border(top: BorderSide(color: AppColors.border)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        for (var i = 0; i < actions!.length; i++) ...[
                          if (i > 0) const SizedBox(width: 8),
                          actions![i],
                        ],
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Future<T?> showAppDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: false,
    barrierLabel: 'dialog',
    barrierColor: const Color(0x8A000000),
    transitionDuration: motionDuration,
    transitionBuilder: dialogMotion,
    pageBuilder: (context, animation, secondaryAnimation) {
      return builder(context);
    },
  );
}

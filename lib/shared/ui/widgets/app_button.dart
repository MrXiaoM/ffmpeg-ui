import 'package:flutter/material.dart';

import '../app_theme.dart';
import 'app_hover.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.child,
    this.onPressed,
    this.filled = false,
    this.fillColor,
    this.padding = appButtonPadding,
  });

  final Widget child;
  final VoidCallback? onPressed;
  final bool filled;
  final Color? fillColor;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return AppHover(
      onPressed: onPressed,
      builder: (context, states) {
        final hovered = states.isHovered;
        return SizedBox(
          height: appControlHeight,
          child: IntrinsicWidth(
            child: DecoratedBox(
              decoration: appControlDecoration(
                fill: appButtonBackground(
                  filled,
                  hovered: hovered,
                  pressed: false,
                  enabled: enabled,
                  fillColor: fillColor,
                ),
                border: appButtonBorder(
                  filled,
                  hovered: hovered,
                  pressed: false,
                  enabled: enabled,
                  fillColor: fillColor,
                ),
              ),
              child: Padding(
                padding: padding,
                child: Center(
                  child: DefaultTextStyle.merge(
                    style: appTextStyle(
                      size: 14,
                      color: appButtonForeground(
                        filled,
                        enabled: enabled,
                        fillColor: fillColor,
                      ),
                    ).copyWith(height: 1),
                    child: IconTheme.merge(
                      data: IconThemeData(
                        size: 14,
                        color: appButtonForeground(
                          filled,
                          enabled: enabled,
                          fillColor: fillColor,
                        ),
                      ),
                      child: child,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class AppFilledButton extends AppButton {
  const AppFilledButton({
    super.key,
    required super.child,
    super.onPressed,
    super.padding,
  }) : super(filled: true);
}

enum IconButtonMode { large, small }

class AppIconButton extends StatelessWidget {
  const AppIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.filled = false,
    this.fillColor,
    this.size = appControlHeight,
    this.style,
    this.iconButtonMode,
  });

  final Widget icon;
  final VoidCallback? onPressed;
  final bool filled;
  final Color? fillColor;
  final double size;
  final Object? style;
  final IconButtonMode? iconButtonMode;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: appControlHeight,
      child: AppButton(
        onPressed: onPressed,
        filled: filled,
        fillColor: fillColor,
        padding: EdgeInsets.zero,
        child: Center(child: icon),
      ),
    );
  }
}

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'widgets/app_scrollbar.dart';

class AppColors {
  static const background = Color(0xFF101218);
  static const surface = Color(0xFF171B24);
  static const surfaceAlt = Color(0xFF1E2430);
  static const border = Color(0xFF2C3444);
  static const borderStrong = Color(0xFF3D4A60);
  static const text = Color(0xFFF4F7FB);
  static const textMuted = Color(0xFF9AA6B8);
  static const accent = Color(0xFF22D3EE);
  static const accentDim = Color(0xFF0E7490);
  static const accentPressed = Color(0xFF155E75);
  static const accentFillHover = Color(0xFF67E8F9);
  static const accentOnFill = Color(0xFF082028);
  static const success = Color(0xFF34D399);
  static const warning = Color(0xFFFBBF24);
  static const danger = Color(0xFFF87171);
  static const menuBar = Color(0xFF141822);
  static const toolbar = Color(0xFF151A24);
  static const statusBar = Color(0xFF0C0F14);
}

class AppScrollBehavior extends MaterialScrollBehavior {
  const AppScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
    PointerDeviceKind.stylus,
  };

  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    if (axisDirectionToAxis(details.direction) == Axis.horizontal) {
      return child;
    }
    return AppScrollbar(
      controller: details.controller,
      child: child,
    );
  }
}

const appFontFamily = 'Microsoft YaHei';

const appFontFamilyFallback = <String>[
  'Microsoft YaHei UI',
  'SimHei',
  'NSimSun',
  'Segoe UI',
];

const appButtonRadius = BorderRadius.all(Radius.circular(6));
const appControlHeight = 36.0;
const appControlBorderWidth = 1.0;
const appButtonPadding = EdgeInsets.symmetric(horizontal: 12);
const appFieldTextSize = 14.0;
const appFieldStrutStyle = StrutStyle(
  fontSize: appFieldTextSize,
  height: 1.3,
  leading: 0,
  forceStrutHeight: true,
  fontFamily: appFontFamily,
);

BoxDecoration appControlDecoration({
  required Color fill,
  required Color border,
}) {
  return BoxDecoration(
    color: fill,
    borderRadius: appButtonRadius,
    border: Border.all(color: border, width: appControlBorderWidth),
  );
}

ThemeData buildAppTheme() {
  const colorScheme = ColorScheme.dark(
    primary: AppColors.accent,
    onPrimary: AppColors.accentOnFill,
    secondary: AppColors.accentDim,
    surface: AppColors.surface,
    onSurface: AppColors.text,
    error: AppColors.danger,
  );
  return ThemeData(
    useMaterial3: false,
    brightness: Brightness.dark,
    colorScheme: colorScheme,
    fontFamily: appFontFamily,
    scaffoldBackgroundColor: AppColors.background,
    canvasColor: AppColors.background,
    cardColor: AppColors.surfaceAlt,
    dividerColor: AppColors.border,
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
    hoverColor: Colors.transparent,
    splashColor: Colors.transparent,
    focusColor: AppColors.accent.withValues(alpha: 0.18),
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: AppColors.accent,
      selectionColor: Color(0x5522D3EE),
      selectionHandleColor: AppColors.accent,
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(
        fontFamily: appFontFamily,
        fontFamilyFallback: appFontFamilyFallback,
        fontSize: 15,
        color: AppColors.text,
        decoration: TextDecoration.none,
      ),
    ),
    iconTheme: const IconThemeData(color: AppColors.text, size: 16),
  );
}

InputDecoration appFieldDecoration({String? placeholder}) {
  return InputDecoration(
    isCollapsed: true,
    isDense: true,
    hintText: placeholder,
    hintStyle: appTextStyle(size: appFieldTextSize, color: AppColors.textMuted),
    border: InputBorder.none,
    enabledBorder: InputBorder.none,
    focusedBorder: InputBorder.none,
    disabledBorder: InputBorder.none,
    contentPadding: EdgeInsets.zero,
  );
}

TextStyle appTextStyle({
  double size = 15,
  FontWeight weight = FontWeight.normal,
  Color color = AppColors.text,
}) {
  return TextStyle(
    fontFamily: appFontFamily,
    fontFamilyFallback: appFontFamilyFallback,
    fontSize: size,
    fontWeight: weight,
    color: color,
    decoration: TextDecoration.none,
  );
}

Color appButtonBorder(
  bool filled, {
  required bool hovered,
  required bool pressed,
  required bool enabled,
  Color? fillColor,
}) {
  if (filled) {
    final fill = fillColor ?? AppColors.accent;
    if (fillColor != null) {
      if (!enabled) {
        return Color.lerp(fill, Colors.black, 0.28)!;
      }
      if (pressed) {
        return Color.lerp(fill, Colors.black, 0.32)!;
      }
      return Color.lerp(fill, Colors.black, 0.16)!;
    }
    if (!enabled) {
      return AppColors.accentDim;
    }
    if (pressed) {
      return AppColors.accentPressed;
    }
    return const Color(0xFF0891B2);
  }
  if (!enabled) {
    return AppColors.border;
  }
  return AppColors.borderStrong;
}

Color appButtonBackground(
  bool filled, {
  required bool hovered,
  required bool pressed,
  required bool enabled,
  Color? fillColor,
}) {
  if (filled) {
    final fill = fillColor ?? AppColors.accent;
    if (fillColor != null) {
      if (!enabled) {
        return fill.withValues(alpha: 0.45);
      }
      if (pressed) {
        return Color.lerp(fill, Colors.black, 0.22)!;
      }
      if (hovered) {
        return Color.lerp(fill, Colors.white, 0.14)!;
      }
      return fill;
    }
    if (!enabled) {
      return AppColors.accentDim.withValues(alpha: 0.45);
    }
    if (pressed) {
      return AppColors.accentDim;
    }
    if (hovered) {
      return AppColors.accentFillHover;
    }
    return AppColors.accent;
  }
  if (!enabled) {
    return AppColors.surface;
  }
  if (pressed) {
    return AppColors.border;
  }
  if (hovered) {
    return AppColors.surfaceAlt;
  }
  return AppColors.surface;
}

Color appButtonForeground(
  bool filled, {
  required bool enabled,
  Color? fillColor,
}) {
  if (!enabled) {
    return AppColors.textMuted;
  }
  if (!filled) {
    return AppColors.text;
  }
  if (fillColor != null) {
    return fillColor.computeLuminance() > 0.42
        ? AppColors.accentOnFill
        : AppColors.text;
  }
  return AppColors.accentOnFill;
}

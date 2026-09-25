// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart' hide Checkbox, FilledButton, IconButton, showDialog, showAboutDialog;

import 'app_icons.dart';
import 'widgets/app_button.dart';
import 'widgets/app_checkbox.dart';
import 'widgets/app_dialog.dart';
import 'widgets/app_dropdown.dart';
import 'widgets/app_hover.dart';
import 'widgets/app_info_bar.dart';
import 'widgets/app_number_field.dart';
import 'widgets/app_switch.dart';
import 'widgets/app_text_field.dart';

export 'package:flutter/material.dart' hide Checkbox, FilledButton, IconButton, showDialog, showAboutDialog;

export 'app_icons.dart';
export 'app_theme.dart';
export 'widgets/app_button.dart';
export 'widgets/app_checkbox.dart';
export 'widgets/app_dialog.dart';
export 'widgets/app_dropdown.dart';
export 'widgets/app_hover.dart';
export 'widgets/app_info_bar.dart';
export 'widgets/app_logo.dart';
export 'widgets/app_number_field.dart';
export 'widgets/app_scrollbar.dart';
export 'widgets/app_switch.dart';
export 'widgets/app_text_field.dart';

typedef Button = AppButton;
typedef FilledButton = AppFilledButton;
typedef IconButton = AppIconButton;
typedef TextBox = AppTextField;
typedef ToggleSwitch = AppSwitch;
typedef ContentDialog = AppDialog;
typedef InfoBar = AppInfoBar;
typedef HoverButton = AppHover;
typedef ComboBox<T> = AppDropdown<T>;
typedef ComboBoxItem<T> = AppDropdownItem<T>;
typedef NumberBox<T extends num> = AppNumberBox<T>;
typedef Checkbox = AppCheckbox;
typedef InfoBarSeverity = AppInfoSeverity;

Future<T?> showDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  RouteTransitionsBuilder? transitionBuilder,
  Duration? transitionDuration,
}) {
  return showAppDialog<T>(context: context, builder: builder);
}

class FluentIcons {
  static const video = AppIcons.video;
  static const music_note = AppIcons.musicNote;
  static const chevron_down = AppIcons.chevronDown;
  static const chevron_right = AppIcons.chevronRight;
  static const chevron_up = AppIcons.chevronUp;
  static const check_mark = AppIcons.check;
  static const delete = AppIcons.delete;
  static const info = AppIcons.info;
  static const red_eye = AppIcons.preview;
  static const open_file = AppIcons.openFile;
  static const folder_open = AppIcons.folderOpen;
  static const stop = AppIcons.stop;
  static const refresh = AppIcons.refresh;
  static const play = AppIcons.play;
  static const pause = AppIcons.pause;
  static const edit = AppIcons.edit;
  static const cut = AppIcons.clip;
  static const locale_language = AppIcons.subtitles;
  static const settings = AppIcons.settings;
  static const chrome_close = AppIcons.close;
  static const completed = AppIcons.completed;
  static const warning = AppIcons.warning;
}

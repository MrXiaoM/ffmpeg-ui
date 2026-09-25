import 'package:flutter/widgets.dart';

enum AppLanguage {
  system,
  zhCn,
  zhHk,
  zhTw,
  en;

  static const supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh', 'CN'),
    Locale('zh', 'HK'),
    Locale('zh', 'TW'),
    Locale('zh'),
  ];

  static AppLanguage fromStorage(String? value) {
    return switch (value) {
      'zh' || 'zhCn' || 'zh_CN' => AppLanguage.zhCn,
      'zhHk' || 'zh_HK' => AppLanguage.zhHk,
      'zhTw' || 'zh_TW' => AppLanguage.zhTw,
      'en' => AppLanguage.en,
      _ => AppLanguage.system,
    };
  }

  String get storageValue => switch (this) {
    AppLanguage.system => 'system',
    AppLanguage.zhCn => 'zh_CN',
    AppLanguage.zhHk => 'zh_HK',
    AppLanguage.zhTw => 'zh_TW',
    AppLanguage.en => 'en',
  };

  bool get followsSystem => this == AppLanguage.system;

  String get nativeName => switch (this) {
    AppLanguage.system => 'System',
    AppLanguage.zhCn => '简体中文（中国大陆）',
    AppLanguage.zhHk => '繁体中文（香港特別行政區）',
    AppLanguage.zhTw => '繁体中文（中國台灣）',
    AppLanguage.en => 'English',
  };
}

Locale localeFromSystem(Locale? systemLocale) {
  final languageCode = systemLocale?.languageCode.trim().toLowerCase() ?? '';
  if (languageCode.isEmpty || languageCode == 'und') {
    return const Locale('en');
  }
  if (languageCode != 'zh') {
    return const Locale('en');
  }

  final script = (systemLocale?.scriptCode ?? '').toLowerCase();
  final country = (systemLocale?.countryCode ?? '').toUpperCase();
  if (script == 'hans' || country == 'CN' || country == 'SG') {
    return const Locale('zh', 'CN');
  }
  if (country == 'HK' || country == 'MO') {
    return const Locale('zh', 'HK');
  }
  if (country == 'TW' || script == 'hant') {
    return const Locale('zh', 'TW');
  }
  return const Locale('zh', 'CN');
}

Locale resolveAppLocale(AppLanguage preference, Locale? systemLocale) {
  return switch (preference) {
    AppLanguage.zhCn => const Locale('zh', 'CN'),
    AppLanguage.zhHk => const Locale('zh', 'HK'),
    AppLanguage.zhTw => const Locale('zh', 'TW'),
    AppLanguage.en => const Locale('en'),
    AppLanguage.system => localeFromSystem(systemLocale),
  };
}

Locale? fluentAppLocale(AppLanguage preference) {
  return preference.followsSystem ? null : resolveAppLocale(preference, null);
}

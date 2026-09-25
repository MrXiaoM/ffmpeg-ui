import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';

import 'app.dart';
import 'app_info.dart';
import 'core/l10n/app_language.dart';
import 'core/platform/window_chrome.dart';
import 'core/service_providers.dart';
import 'core/settings/settings_repository.dart';
import 'l10n/app_localizations.dart';
import 'shared/ui/ui.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  imageCache.maximumSize = 64;
  imageCache.maximumSizeBytes = 24 << 20;
  await SystemChannels.skia.invokeMethod<void>(
    'Skia.setResourceCacheMaxBytes',
    8 << 20,
  );
  await loadAppInfo();
  await windowManager.ensureInitialized();

  final settings = await SettingsRepository().loadSettings();
  final l10n = lookupAppLocalizations(
    resolveAppLocale(
      settings.appLanguage,
      WidgetsBinding.instance.platformDispatcher.locale,
    ),
  );

  final options = WindowOptions(
    size: const Size(1280, 800),
    minimumSize: const Size(1024, 680),
    center: true,
    backgroundColor: AppColors.background,
    skipTaskbar: false,
    title: l10n.appName,
    titleBarStyle: TitleBarStyle.hidden,
    windowButtonVisibility: usesSystemWindowButtons,
  );
  await windowManager.waitUntilReadyToShow(options, () async {
    await windowManager.setTitle(l10n.appName);
    await windowManager.setPreventClose(true);
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(
    ProviderScope(
      overrides: [bootstrapSettingsProvider.overrideWithValue(settings)],
      child: const FfmpegApp(),
    ),
  );
}

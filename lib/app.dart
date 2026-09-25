import 'dart:async';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';

import 'core/l10n/app_language.dart';
import 'core/service_providers.dart';
import 'core/settings/queue_controller.dart';
import 'core/settings/settings_controller.dart';
import 'features/shell/app_shell.dart';
import 'l10n/app_localizations.dart';
import 'shared/ui/ui.dart';

class FfmpegApp extends ConsumerStatefulWidget {
  const FfmpegApp({super.key});

  @override
  ConsumerState<FfmpegApp> createState() => _FfmpegAppState();
}

class _FfmpegAppState extends ConsumerState<FfmpegApp>
    with WidgetsBindingObserver {
  String? _windowTitle;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    ref.listenManual(
      queueControllerProvider.select((state) => state.progress),
      (_, next) {
        unawaited(ref.read(windowProgressBarProvider).apply(next));
      },
      fireImmediately: true,
    );
    Future.microtask(() async {
      await ref.read(settingsControllerProvider.notifier).initialize();
      await ref.read(queueControllerProvider.notifier).initialize();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeLocales(List<Locale>? locales) {
    setState(() {});
  }

  Future<void> _syncWindowTitle(String title) async {
    if (_windowTitle == title) {
      return;
    }
    _windowTitle = title;
    try {
      await windowManager.setTitle(title);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final preference = ref.watch(
      settingsControllerProvider.select((state) => state.settings.appLanguage),
    );
    final resolved = resolveAppLocale(
      preference,
      WidgetsBinding.instance.platformDispatcher.locale,
    );
    final l10n = lookupAppLocalizations(resolved);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncWindowTitle(l10n.appName);
    });
    return MaterialApp(
      title: l10n.appName,
      onGenerateTitle: (context) => AppLocalizations.of(context).appName,
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      scrollBehavior: const AppScrollBehavior(),
      locale: fluentAppLocale(preference),
      supportedLocales: AppLanguage.supportedLocales,
      localeResolutionCallback: (locale, supported) {
        if (!preference.followsSystem) {
          return resolved;
        }
        return localeFromSystem(locale);
      },
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        return DefaultTextStyle(
          style: appTextStyle(),
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: const AppShell(),
    );
  }
}

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/app_language.dart';
import '../models/app_settings.dart';
import '../models/conversion_task.dart';

class SettingsRepository {
  static const _settingsKey = 'app_settings';
  static const _queueKey = 'conversion_queue';

  Future<AppSettings> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_settingsKey);
    if (raw == null || raw.isEmpty) {
      return const AppSettings();
    }
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return AppSettings(
        ffmpegPath: json['ffmpegPath'] as String?,
        concurrency:
            json['concurrency'] as int? ?? AppSettings.defaultConcurrency,
        hardwareAcceleration: json['hardwareAcceleration'] as bool? ?? false,
        leftPanelWidth:
            (json['leftPanelWidth'] as num?)?.toDouble() ?? 340,
        renamePattern:
            json['renamePattern'] as String? ??
            AppSettings.defaultRenamePattern,
        appLanguage: AppLanguage.fromStorage(json['appLanguage'] as String?),
      );
    } catch (_) {
      return const AppSettings();
    }
  }

  Future<void> saveSettings(AppSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _settingsKey,
      jsonEncode({
        'ffmpegPath': settings.ffmpegPath,
        'concurrency': settings.concurrency,
        'hardwareAcceleration': settings.hardwareAcceleration,
        'leftPanelWidth': settings.leftPanelWidth,
        'renamePattern': settings.renamePattern,
        'appLanguage': settings.appLanguage.storageValue,
      }),
    );
  }

  Future<List<ConversionTask>> loadQueue() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_queueKey);
    if (raw == null || raw.isEmpty) {
      return const [];
    }
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .whereType<Map<String, dynamic>>()
          .map(ConversionTask.fromJson)
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<void> saveQueue(List<ConversionTask> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _queueKey,
      jsonEncode(tasks.map((task) => task.toJson()).toList()),
    );
  }
}

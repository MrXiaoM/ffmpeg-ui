import '../l10n/app_language.dart';

class AppSettings {
  const AppSettings({
    this.ffmpegPath,
    this.concurrency = 3,
    this.hardwareAcceleration = false,
    this.leftPanelWidth = 340,
    this.renamePattern = defaultRenamePattern,
    this.appLanguage = AppLanguage.system,
  });

  final String? ffmpegPath;
  final int concurrency;
  final bool hardwareAcceleration;
  final double leftPanelWidth;
  final String renamePattern;
  final AppLanguage appLanguage;

  static const defaultRenamePattern = ' ({n})';
  static const renamePresets = <String>[
    ' ({n})',
    '_{n}',
    '-{n}',
    '.{n}',
    ' ({n:2})',
  ];

  static const minConcurrency = 1;
  static const maxConcurrency = 8;
  static const defaultConcurrency = 3;
  static const minLeftPanelWidth = 260.0;
  static const maxLeftPanelWidth = 560.0;

  AppSettings copyWith({
    String? ffmpegPath,
    bool clearFfmpegPath = false,
    int? concurrency,
    bool? hardwareAcceleration,
    double? leftPanelWidth,
    String? renamePattern,
    AppLanguage? appLanguage,
  }) {
    return AppSettings(
      ffmpegPath: clearFfmpegPath ? null : (ffmpegPath ?? this.ffmpegPath),
      concurrency: (concurrency ?? this.concurrency).clamp(
        minConcurrency,
        maxConcurrency,
      ),
      hardwareAcceleration: hardwareAcceleration ?? this.hardwareAcceleration,
      leftPanelWidth: (leftPanelWidth ?? this.leftPanelWidth).clamp(
        minLeftPanelWidth,
        maxLeftPanelWidth,
      ),
      renamePattern: (renamePattern ?? this.renamePattern).trim().isEmpty
          ? defaultRenamePattern
          : (renamePattern ?? this.renamePattern),
      appLanguage: appLanguage ?? this.appLanguage,
    );
  }

  String renameWithNumber(String stem, String extension, int number) {
    final pattern = renamePattern.contains('{n')
        ? renamePattern
        : '$renamePattern{n}';
    final suffix = pattern.replaceAllMapped(RegExp(r'\{n(?::(\d+))?\}'), (match) {
      final width = int.tryParse(match.group(1) ?? '') ?? 0;
      final text = '$number';
      return width > text.length ? text.padLeft(width, '0') : text;
    });
    return '$stem$suffix$extension';
  }
}

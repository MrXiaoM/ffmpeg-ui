import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'ffmpeg/ffmpeg_locator.dart';
import 'ffmpeg/ffmpeg_runner.dart';
import 'ffmpeg/hardware_probe.dart';
import 'ffmpeg/ffprobe_service.dart';
import 'ffmpeg/thumbnail_service.dart';
import 'models/app_settings.dart';
import 'platform/window_progress.dart';
import 'settings/settings_repository.dart';

final bootstrapSettingsProvider = Provider<AppSettings>((ref) {
  return const AppSettings();
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository();
});

final ffmpegLocatorProvider = Provider<FfmpegLocator>((ref) {
  return FfmpegLocator();
});

final hardwareProbeProvider = Provider<HardwareProbe>((ref) {
  return const HardwareProbe();
});

final ffprobeServiceProvider = Provider<FfprobeService>((ref) {
  return const FfprobeService();
});

final thumbnailServiceProvider = Provider<ThumbnailService>((ref) {
  return ThumbnailService();
});

final ffmpegRunnerProvider = Provider<FfmpegRunner>((ref) {
  return FfmpegRunner();
});

final windowProgressBarProvider = Provider<WindowProgressBar>((ref) {
  return SystemWindowProgressBar();
});

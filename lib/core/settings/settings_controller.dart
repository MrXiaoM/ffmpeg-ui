import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../ffmpeg/ffmpeg_locator.dart';
import '../ffmpeg/hardware_probe.dart';
import '../l10n/app_language.dart';
import '../l10n/app_messages.dart';
import '../models/app_settings.dart';
import '../service_providers.dart';
import 'settings_repository.dart';

final settingsControllerProvider =
    NotifierProvider<SettingsController, SettingsState>(SettingsController.new);

class SettingsState {
  const SettingsState({
    this.settings = const AppSettings(),
    this.location,
    this.hardware = const HardwareCapabilities.unknown(),
    this.busy = false,
    this.message,
  });

  final AppSettings settings;
  final FfmpegLocation? location;
  final HardwareCapabilities hardware;
  final bool busy;
  final String? message;

  bool get ffmpegReady => location?.isReady == true;

  SettingsState copyWith({
    AppSettings? settings,
    FfmpegLocation? location,
    bool clearLocation = false,
    HardwareCapabilities? hardware,
    bool? busy,
    String? message,
    bool clearMessage = false,
  }) {
    return SettingsState(
      settings: settings ?? this.settings,
      location: clearLocation ? null : (location ?? this.location),
      hardware: hardware ?? this.hardware,
      busy: busy ?? this.busy,
      message: clearMessage ? null : (message ?? this.message),
    );
  }
}

class SettingsController extends Notifier<SettingsState> {
  SettingsRepository get _repository => ref.read(settingsRepositoryProvider);
  FfmpegLocator get _locator => ref.read(ffmpegLocatorProvider);
  HardwareProbe get _hardwareProbe => ref.read(hardwareProbeProvider);
  Timer? _panelWidthSave;
  Future<void>? _detectTask;
  Future<void>? _hardwareTask;

  @override
  SettingsState build() {
    return SettingsState(settings: ref.read(bootstrapSettingsProvider));
  }

  Future<void> initialize() async {
    state = state.copyWith(busy: true, clearMessage: true);
    await detect(probeHardware: false);
  }

  Future<void> waitUntilReady() async {
    final task = _detectTask;
    if (task != null) {
      await task;
    }
  }

  Future<void> detect({bool probeHardware = true}) async {
    final task = _detect(probeHardware: probeHardware);
    _detectTask = task;
    try {
      await task;
    } finally {
      if (identical(_detectTask, task)) {
        _detectTask = null;
      }
    }
  }

  Future<void> ensureHardware() async {
    final detectTask = _detectTask;
    if (detectTask != null) {
      await detectTask;
    }
    if (state.hardware.isProbed) {
      return;
    }
    final location = state.location;
    if (location == null) {
      return;
    }
    final existing = _hardwareTask;
    if (existing != null) {
      await existing;
      return;
    }
    final task = _probeHardware(location);
    _hardwareTask = task;
    try {
      await task;
    } finally {
      if (identical(_hardwareTask, task)) {
        _hardwareTask = null;
      }
    }
  }

  Future<void> _detect({required bool probeHardware}) async {
    state = state.copyWith(busy: true, clearMessage: true);
    final location = await _locator.detect(
      preferredPath: state.settings.ffmpegPath,
    );
    if (location == null) {
      state = state.copyWith(
        busy: false,
        clearLocation: true,
        hardware: const HardwareCapabilities.unknown(),
        message: encodeAppMessage(AppMessage.ffmpegNotFoundSpecify),
      );
      return;
    }
    var hardware = const HardwareCapabilities.unknown();
    if (probeHardware) {
      hardware = await _hardwareProbe.detect(location.ffmpegPath);
    }
    state = state.copyWith(
      busy: false,
      location: location,
      hardware: hardware,
      message: encodeAppMessage(AppMessage.ffmpegFoundFrom, [location.source]),
    );
  }

  Future<void> _probeHardware(FfmpegLocation location) async {
    final hardware = await _hardwareProbe.detect(location.ffmpegPath);
    if (state.location?.ffmpegPath != location.ffmpegPath) {
      return;
    }
    state = state.copyWith(hardware: hardware);
  }

  Future<void> setFfmpegPath(String? path) async {
    if (path == null || path.trim().isEmpty) {
      final next = state.settings.copyWith(clearFfmpegPath: true);
      state = state.copyWith(settings: next);
      await _repository.saveSettings(next);
      await detect();
      return;
    }
    state = state.copyWith(busy: true, clearMessage: true);
    final location = await _locator.validate(path.trim());
    if (location == null) {
      state = state.copyWith(
        busy: false,
        message: encodeAppMessage(AppMessage.ffmpegInvalidPath),
      );
      return;
    }
    final next = state.settings.copyWith(ffmpegPath: path.trim());
    state = state.copyWith(
      busy: false,
      settings: next,
      location: location,
      hardware: const HardwareCapabilities.unknown(),
      message: encodeAppMessage(AppMessage.ffmpegUsingSpecified),
    );
    await _repository.saveSettings(next);
    unawaited(ensureHardware());
  }

  Future<void> setRenamePattern(String value) async {
    final next = state.settings.copyWith(renamePattern: value);
    state = state.copyWith(settings: next);
    await _repository.saveSettings(next);
  }

  Future<void> setConcurrency(int value) async {
    final next = state.settings.copyWith(concurrency: value);
    state = state.copyWith(settings: next);
    await _repository.saveSettings(next);
  }

  Future<void> setHardwareAcceleration(bool value) async {
    final next = state.settings.copyWith(hardwareAcceleration: value);
    state = state.copyWith(settings: next);
    await _repository.saveSettings(next);
  }

  Future<void> setAppLanguage(AppLanguage value) async {
    final next = state.settings.copyWith(appLanguage: value);
    state = state.copyWith(settings: next);
    await _repository.saveSettings(next);
  }

  void setLeftPanelWidth(double width) {
    final next = state.settings.copyWith(leftPanelWidth: width);
    state = state.copyWith(settings: next);
    _panelWidthSave?.cancel();
    _panelWidthSave = Timer(const Duration(milliseconds: 250), () {
      _repository.saveSettings(state.settings);
    });
  }
}

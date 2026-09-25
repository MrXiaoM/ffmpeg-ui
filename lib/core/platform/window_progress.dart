import 'dart:io';

import 'package:window_manager/window_manager.dart';

import '../models/queue_progress.dart';

abstract class WindowProgressBar {
  Future<void> apply(QueueProgress progress);
}

class SystemWindowProgressBar implements WindowProgressBar {
  SystemWindowProgressBar({
    Future<void> Function(double progress)? setProgressBar,
    bool? supported,
  }) : _setProgressBar = setProgressBar ?? windowManager.setProgressBar,
       _supported = supported ?? (Platform.isWindows || Platform.isMacOS);

  final Future<void> Function(double progress) _setProgressBar;
  final bool _supported;
  double? _lastValue;

  bool get supported => _supported;

  @override
  Future<void> apply(QueueProgress progress) async {
    if (!_supported) {
      return;
    }
    final value = progress.visible
        ? ((progress.value.clamp(0.0, 1.0) * 100).round() / 100)
        : -1.0;
    if (_lastValue == value) {
      return;
    }
    _lastValue = value;
    try {
      await _setProgressBar(value);
    } catch (_) {}
  }
}

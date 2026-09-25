class FfmpegProgress {
  const FfmpegProgress({
    required this.progress,
    this.outTime,
    this.speed,
    this.eta,
  });

  final double progress;
  final Duration? outTime;
  final double? speed;
  final Duration? eta;
}

class FfmpegProgressParser {
  FfmpegProgressParser({this.total});

  Duration? total;
  final Map<String, String> _buffer = {};
  Duration? _lastOutTime;
  double _lastProgress = 0;

  FfmpegProgress? addLine(String line) {
    final trimmed = line.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    final index = trimmed.indexOf('=');
    if (index <= 0) {
      return null;
    }
    final key = trimmed.substring(0, index).trim();
    final value = trimmed.substring(index + 1).trim();
    _buffer[key] = value;
    if (key != 'progress') {
      return null;
    }
    return snapshot();
  }

  FfmpegProgress snapshot() {
    final parsed = _parseOutTime(_buffer['out_time_us'] ?? _buffer['out_time']);
    if (parsed != null && !parsed.isNegative) {
      _lastOutTime = parsed;
    }
    final outTime = _lastOutTime;
    final speed = _parseSpeed(_buffer['speed']);
    var progress = _lastProgress;
    Duration? eta;
    if (total != null && total!.inMicroseconds > 0 && outTime != null) {
      progress = (outTime.inMicroseconds / total!.inMicroseconds).clamp(0, 1);
      if (speed != null && speed > 0) {
        final remaining = total! - outTime;
        if (!remaining.isNegative) {
          eta = Duration(
            microseconds: (remaining.inMicroseconds / speed).round(),
          );
        }
      }
    }
    if (progress < _lastProgress) {
      progress = _lastProgress;
    }
    if (_buffer['progress'] == 'end') {
      progress = 1;
    }
    _lastProgress = progress;
    return FfmpegProgress(
      progress: progress,
      outTime: outTime,
      speed: speed,
      eta: eta,
    );
  }

  Duration? _parseOutTime(String? raw) {
    if (raw == null || raw.isEmpty || raw == 'N/A') {
      return null;
    }
    final micros = int.tryParse(raw);
    if (micros != null) {
      return Duration(microseconds: micros);
    }
    return parseClock(raw);
  }

  double? _parseSpeed(String? raw) {
    if (raw == null || raw.isEmpty || raw == 'N/A') {
      return null;
    }
    return double.tryParse(raw.replaceAll('x', ''));
  }
}

Duration? parseClock(String value) {
  final parts = value.split(':');
  if (parts.length != 3) {
    return null;
  }
  final hours = int.tryParse(parts[0]);
  final minutes = int.tryParse(parts[1]);
  final seconds = double.tryParse(parts[2]);
  if (hours == null || minutes == null || seconds == null) {
    return null;
  }
  return Duration(
    microseconds:
        ((hours * 3600 + minutes * 60 + seconds) * 1000000).round(),
  );
}

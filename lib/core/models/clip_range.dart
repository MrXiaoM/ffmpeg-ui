class ClipRange {
  const ClipRange({
    required this.start,
    required this.end,
    this.fps = 30,
  });

  final Duration start;
  final Duration end;
  final double fps;

  Duration get duration => end - start;

  double get safeFps => fps > 0 ? fps : 30;

  Duration get frameStep {
    final micros = (1000000 / safeFps).round();
    return Duration(microseconds: micros < 1 ? 1 : micros);
  }

  int get startFrame => _frameAt(start);
  int get endFrame => _frameAt(end);

  int _frameAt(Duration time) {
    return (time.inMicroseconds / 1000000 * safeFps).round();
  }

  Duration timeOfFrame(int frame) {
    final micros = (frame / safeFps * 1000000).round();
    return Duration(microseconds: micros < 0 ? 0 : micros);
  }

  ClipRange copyWith({Duration? start, Duration? end, double? fps}) {
    return ClipRange(
      start: start ?? this.start,
      end: end ?? this.end,
      fps: fps ?? this.fps,
    );
  }

  ClipRange clampTo(Duration mediaDuration) {
    var nextStart = start;
    var nextEnd = end;
    if (nextStart.isNegative) {
      nextStart = Duration.zero;
    }
    if (nextEnd > mediaDuration) {
      nextEnd = mediaDuration;
    }
    if (nextEnd <= nextStart) {
      nextEnd = nextStart + frameStep;
      if (nextEnd > mediaDuration) {
        nextEnd = mediaDuration;
        nextStart = nextEnd - frameStep;
        if (nextStart.isNegative) {
          nextStart = Duration.zero;
        }
      }
    }
    return copyWith(start: nextStart, end: nextEnd);
  }

  Map<String, dynamic> toJson() {
    return {
      'startUs': start.inMicroseconds,
      'endUs': end.inMicroseconds,
      'fps': fps,
    };
  }

  factory ClipRange.fromJson(Map<String, dynamic> json) {
    return ClipRange(
      start: Duration(microseconds: json['startUs'] as int? ?? 0),
      end: Duration(microseconds: json['endUs'] as int? ?? 0),
      fps: (json['fps'] as num?)?.toDouble() ?? 30,
    );
  }
}

Duration stepByFrame(Duration time, double fps, int frames) {
  final safeFps = fps > 0 ? fps : 30;
  final micros = time.inMicroseconds + (frames * 1000000 / safeFps).round();
  return Duration(microseconds: micros < 0 ? 0 : micros);
}

String formatTimecode(Duration time, {bool withMillis = true}) {
  final hours = time.inHours;
  final minutes = time.inMinutes.remainder(60).toString().padLeft(2, '0');
  final seconds = time.inSeconds.remainder(60).toString().padLeft(2, '0');
  if (!withMillis) {
    if (hours > 0) {
      return '$hours:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }
  final millis = time.inMilliseconds.remainder(1000).toString().padLeft(3, '0');
  if (hours > 0) {
    return '$hours:$minutes:$seconds.$millis';
  }
  return '$minutes:$seconds.$millis';
}

String formatFfmpegTime(Duration time) {
  return (time.inMicroseconds / 1000000).toStringAsFixed(3);
}

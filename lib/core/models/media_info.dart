import 'subtitle_track.dart';

class MediaInfo {
  const MediaInfo({
    required this.path,
    this.duration,
    this.width,
    this.height,
    this.fps,
    this.hasVideo = false,
    this.hasAudio = false,
    this.videoCodec,
    this.audioCodec,
    this.channels,
    this.sampleRate,
    this.subtitles = const [],
    this.error,
  });

  final String path;
  final Duration? duration;
  final int? width;
  final int? height;
  final double? fps;
  final bool hasVideo;
  final bool hasAudio;
  final String? videoCodec;
  final String? audioCodec;
  final int? channels;
  final int? sampleRate;
  final List<SubtitleTrack> subtitles;
  final String? error;

  bool get isValid => error == null;

  String get resolutionLabel {
    if (width == null || height == null) {
      return 'Unknown resolution';
    }
    return '${width}x$height';
  }

  String get durationLabel {
    if (duration == null) {
      return 'Unknown duration';
    }
    final minutes = duration!.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration!.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (duration!.inHours > 0) {
      return '${duration!.inHours}:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }
}

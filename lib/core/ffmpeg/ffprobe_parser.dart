import 'dart:convert';

import '../l10n/app_messages.dart';
import '../models/media_info.dart';
import '../models/subtitle_track.dart';

const _textSubtitleCodecs = {
  'subrip',
  'ass',
  'ssa',
  'webvtt',
  'mov_text',
  'text',
};

MediaInfo mediaInfoFromProbeFailure(String path, [String? message]) {
  final trimmed = message?.trim() ?? '';
  return MediaInfo(
    path: path,
    error: trimmed.isEmpty
        ? encodeAppMessage(AppMessage.cannotReadMedia)
        : trimmed,
  );
}

MediaInfo parseFfprobeOutput({
  required String path,
  required Object? stdout,
  Object? stderr,
  int exitCode = 0,
}) {
  final output = decodeProcessOutput(stdout);
  final errors = decodeProcessOutput(stderr).trim();
  final jsonText = extractJsonObject(output);
  if (jsonText == null) {
    if (exitCode != 0 || output.trim().isEmpty) {
      return mediaInfoFromProbeFailure(path, errors);
    }
    return mediaInfoFromProbeFailure(path, output);
  }
  try {
    return parseFfprobeJson(path, jsonText);
  } catch (error) {
    if (errors.isNotEmpty) {
      return mediaInfoFromProbeFailure(path, errors);
    }
    return mediaInfoFromProbeFailure(path, error.toString());
  }
}

String decodeProcessOutput(Object? value) {
  if (value == null) {
    return '';
  }
  if (value is String) {
    return value;
  }
  if (value is List<int>) {
    return utf8.decode(value, allowMalformed: true);
  }
  if (value is List) {
    return utf8.decode(
      value.whereType<int>().toList(growable: false),
      allowMalformed: true,
    );
  }
  return value.toString();
}

String? extractJsonObject(String text) {
  final start = text.indexOf('{');
  final end = text.lastIndexOf('}');
  if (start < 0 || end <= start) {
    return null;
  }
  return text.substring(start, end + 1);
}

MediaInfo parseFfprobeJson(String path, String jsonText) {
  final decoded = jsonDecode(jsonText);
  if (decoded is! Map) {
    return mediaInfoFromProbeFailure(path);
  }
  final json = decoded.cast<String, dynamic>();
  final streams = (json['streams'] as List<dynamic>? ?? const [])
      .whereType<Map>()
      .map((item) => item.cast<String, dynamic>())
      .toList(growable: false);
  final format = json['format'] is Map
      ? (json['format'] as Map).cast<String, dynamic>()
      : const <String, dynamic>{};
  final video = _primaryVideo(streams);
  final audio = streams
      .where((item) => item['codec_type'] == 'audio')
      .firstOrNull;
  final subtitles = [
    for (final stream in streams)
      if (stream['codec_type'] == 'subtitle') _subtitle(stream),
  ];
  final durationSeconds = parseFfprobeDouble(
    format['duration'] ?? video?['duration'] ?? audio?['duration'],
  );
  return MediaInfo(
    path: path,
    duration: durationSeconds == null
        ? null
        : Duration(microseconds: (durationSeconds * 1000000).round()),
    width: parseFfprobeInt(video?['width']),
    height: parseFfprobeInt(video?['height']),
    fps: _parseFps(
      _string(video?['avg_frame_rate']) ?? _string(video?['r_frame_rate']),
    ),
    hasVideo: video != null,
    hasAudio: audio != null,
    videoCodec: _string(video?['codec_name']),
    audioCodec: _string(audio?['codec_name']),
    channels: parseFfprobeInt(audio?['channels']),
    sampleRate: parseFfprobeInt(audio?['sample_rate']),
    subtitles: subtitles,
  );
}

int? parseFfprobeInt(Object? value) {
  if (value == null) {
    return null;
  }
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.round();
  }
  return int.tryParse(value.toString().trim());
}

double? parseFfprobeDouble(Object? value) {
  if (value == null) {
    return null;
  }
  if (value is double) {
    return value;
  }
  if (value is num) {
    return value.toDouble();
  }
  return double.tryParse(value.toString().trim());
}

Map<String, dynamic>? _primaryVideo(List<Map<String, dynamic>> streams) {
  final videos = streams
      .where((item) => item['codec_type'] == 'video')
      .toList(growable: false);
  return videos.where((item) => !_isAttachedPicture(item)).firstOrNull ??
      videos.where(_isAttachedPicture).firstOrNull;
}

bool _isAttachedPicture(Map<String, dynamic> stream) {
  final disposition = stream['disposition'];
  if (disposition is Map && parseFfprobeInt(disposition['attached_pic']) == 1) {
    return true;
  }
  final codec = _string(stream['codec_name'])?.toLowerCase();
  return codec == 'mjpeg' &&
      parseFfprobeInt(stream['nb_frames']) == 1 &&
      _string(stream['codec_type']) == 'video';
}

SubtitleTrack _subtitle(Map<String, dynamic> stream) {
  final tags = stream['tags'] is Map
      ? (stream['tags'] as Map).cast<String, dynamic>()
      : const <String, dynamic>{};
  final disposition = stream['disposition'] is Map
      ? (stream['disposition'] as Map).cast<String, dynamic>()
      : const <String, dynamic>{};
  final codec = _string(stream['codec_name']) ?? 'unknown';
  return SubtitleTrack(
    index: parseFfprobeInt(stream['index']) ?? 0,
    codec: codec,
    language: _string(tags['language']),
    title: _string(tags['title']),
    isDefault: parseFfprobeInt(disposition['default']) == 1,
    isForced: parseFfprobeInt(disposition['forced']) == 1,
    isText: _textSubtitleCodecs.contains(codec),
  );
}

String? _string(Object? value) {
  if (value == null) {
    return null;
  }
  final text = value.toString();
  return text.isEmpty ? null : text;
}

double? _parseFps(String? value) {
  if (value == null || value.isEmpty || value == '0/0') {
    return null;
  }
  final parts = value.split('/');
  if (parts.length == 2) {
    final a = double.tryParse(parts[0]);
    final b = double.tryParse(parts[1]);
    if (a != null && b != null && b != 0) {
      return a / b;
    }
  }
  return double.tryParse(value);
}

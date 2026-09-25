import 'package:flutter/painting.dart';

enum FormatKind { video, audio }

class MediaFormat {
  const MediaFormat({
    required this.id,
    required this.label,
    required this.extension,
    required this.kind,
    required this.description,
    required this.color,
  });

  final String id;
  final String label;
  final String extension;
  final FormatKind kind;
  final String description;
  final Color color;

  bool get isVideo => kind == FormatKind.video;
  bool get isAudio => kind == FormatKind.audio;
  bool get keepsSourceCodec => id == 'copy-video' || id == 'copy-audio';
  bool get supportsEmbeddedSubtitles {
    switch (id) {
      case 'mkv':
      case 'mp4':
      case 'mov':
      case 'webm':
        return true;
      default:
        return false;
    }
  }

  static const copyVideo = MediaFormat(
    id: 'copy-video',
    label: '原编码',
    extension: '',
    kind: FormatKind.video,
    description: '保持原容器，默认源编码，可改参数；未改动时直接复制',
    color: Color(0xFF94A3B8),
  );
  static const copyAudio = MediaFormat(
    id: 'copy-audio',
    label: '原编码',
    extension: '',
    kind: FormatKind.audio,
    description: '保持原容器，默认源编码，可改参数；未改动时直接复制',
    color: Color(0xFF94A3B8),
  );
  static const mp4 = MediaFormat(
    id: 'mp4',
    label: 'MP4',
    extension: '.mp4',
    kind: FormatKind.video,
    description: '通用视频，兼容性最好',
    color: Color(0xFF3B82F6),
  );
  static const mkv = MediaFormat(
    id: 'mkv',
    label: 'MKV',
    extension: '.mkv',
    kind: FormatKind.video,
    description: '开放容器，适合高质量封装',
    color: Color(0xFF8B5CF6),
  );
  static const webm = MediaFormat(
    id: 'webm',
    label: 'WEBM',
    extension: '.webm',
    kind: FormatKind.video,
    description: '网页视频，体积更小',
    color: Color(0xFF22C55E),
  );
  static const mov = MediaFormat(
    id: 'mov',
    label: 'MOV',
    extension: '.mov',
    kind: FormatKind.video,
    description: 'Apple 生态常用视频',
    color: Color(0xFF64748B),
  );
  static const avi = MediaFormat(
    id: 'avi',
    label: 'AVI',
    extension: '.avi',
    kind: FormatKind.video,
    description: '传统视频容器',
    color: Color(0xFFF59E0B),
  );
  static const gif = MediaFormat(
    id: 'gif',
    label: 'GIF',
    extension: '.gif',
    kind: FormatKind.video,
    description: '动画图片，适合短片段',
    color: Color(0xFFEC4899),
  );
  static const wmv = MediaFormat(
    id: 'wmv',
    label: 'WMV',
    extension: '.wmv',
    kind: FormatKind.video,
    description: 'Windows Media 视频',
    color: Color(0xFF2563EB),
  );
  static const flv = MediaFormat(
    id: 'flv',
    label: 'FLV',
    extension: '.flv',
    kind: FormatKind.video,
    description: 'Flash 视频容器',
    color: Color(0xFFEF4444),
  );
  static const mpeg = MediaFormat(
    id: 'mpeg',
    label: 'MPEG',
    extension: '.mpeg',
    kind: FormatKind.video,
    description: 'MPEG 节目流',
    color: Color(0xFFD97706),
  );
  static const ts = MediaFormat(
    id: 'ts',
    label: 'TS',
    extension: '.ts',
    kind: FormatKind.video,
    description: 'MPEG 传输流',
    color: Color(0xFF0F766E),
  );
  static const m2ts = MediaFormat(
    id: 'm2ts',
    label: 'M2TS',
    extension: '.m2ts',
    kind: FormatKind.video,
    description: '蓝光传输流',
    color: Color(0xFF115E59),
  );
  static const threegp = MediaFormat(
    id: '3gp',
    label: '3GP',
    extension: '.3gp',
    kind: FormatKind.video,
    description: '手机常用视频',
    color: Color(0xFF7C3AED),
  );
  static const ogv = MediaFormat(
    id: 'ogv',
    label: 'OGV',
    extension: '.ogv',
    kind: FormatKind.video,
    description: 'Theora 开放视频',
    color: Color(0xFF65A30D),
  );
  static const webp = MediaFormat(
    id: 'webp',
    label: 'WEBP',
    extension: '.webp',
    kind: FormatKind.video,
    description: '动画 WebP 图片',
    color: Color(0xFF059669),
  );
  static const mp3 = MediaFormat(
    id: 'mp3',
    label: 'MP3',
    extension: '.mp3',
    kind: FormatKind.audio,
    description: '通用有损音频',
    color: Color(0xFF06B6D4),
  );
  static const aac = MediaFormat(
    id: 'aac',
    label: 'AAC',
    extension: '.aac',
    kind: FormatKind.audio,
    description: '高效有损音频',
    color: Color(0xFF14B8A6),
  );
  static const m4a = MediaFormat(
    id: 'm4a',
    label: 'M4A',
    extension: '.m4a',
    kind: FormatKind.audio,
    description: 'AAC 音频封装',
    color: Color(0xFF0EA5E9),
  );
  static const wav = MediaFormat(
    id: 'wav',
    label: 'WAV',
    extension: '.wav',
    kind: FormatKind.audio,
    description: '无损 PCM 音频',
    color: Color(0xFF84CC16),
  );
  static const flac = MediaFormat(
    id: 'flac',
    label: 'FLAC',
    extension: '.flac',
    kind: FormatKind.audio,
    description: '无损压缩音频',
    color: Color(0xFFA3E635),
  );
  static const ogg = MediaFormat(
    id: 'ogg',
    label: 'OGG',
    extension: '.ogg',
    kind: FormatKind.audio,
    description: 'Vorbis 开放音频',
    color: Color(0xFFFB923C),
  );
  static const opus = MediaFormat(
    id: 'opus',
    label: 'OPUS',
    extension: '.opus',
    kind: FormatKind.audio,
    description: '低延迟高效音频',
    color: Color(0xFFF472B6),
  );
  static const ac3 = MediaFormat(
    id: 'ac3',
    label: 'AC3',
    extension: '.ac3',
    kind: FormatKind.audio,
    description: '杜比数字环绕声',
    color: Color(0xFF1D4ED8),
  );
  static const wma = MediaFormat(
    id: 'wma',
    label: 'WMA',
    extension: '.wma',
    kind: FormatKind.audio,
    description: 'Windows Media 音频',
    color: Color(0xFF0284C7),
  );
  static const aiff = MediaFormat(
    id: 'aiff',
    label: 'AIFF',
    extension: '.aiff',
    kind: FormatKind.audio,
    description: 'Apple 无损 PCM',
    color: Color(0xFF4D7C0F),
  );
  static const mp2 = MediaFormat(
    id: 'mp2',
    label: 'MP2',
    extension: '.mp2',
    kind: FormatKind.audio,
    description: 'MPEG 音频层 2',
    color: Color(0xFF0891B2),
  );
  static const wv = MediaFormat(
    id: 'wv',
    label: 'WV',
    extension: '.wv',
    kind: FormatKind.audio,
    description: 'WavPack 无损音频',
    color: Color(0xFFCA8A04),
  );
  static const tta = MediaFormat(
    id: 'tta',
    label: 'TTA',
    extension: '.tta',
    kind: FormatKind.audio,
    description: 'True Audio 无损',
    color: Color(0xFFB45309),
  );
  static const spx = MediaFormat(
    id: 'spx',
    label: 'SPX',
    extension: '.spx',
    kind: FormatKind.audio,
    description: 'Speex 语音编码',
    color: Color(0xFFEA580C),
  );
  static const amr = MediaFormat(
    id: 'amr',
    label: 'AMR',
    extension: '.amr',
    kind: FormatKind.audio,
    description: '窄带语音音频',
    color: Color(0xFFDB2777),
  );
  static const alac = MediaFormat(
    id: 'alac',
    label: 'ALAC',
    extension: '.m4a',
    kind: FormatKind.audio,
    description: 'Apple 无损音频',
    color: Color(0xFF9333EA),
  );
  static const caf = MediaFormat(
    id: 'caf',
    label: 'CAF',
    extension: '.caf',
    kind: FormatKind.audio,
    description: 'Apple Core Audio',
    color: Color(0xFF6D28D9),
  );

  static const catalog = <MediaFormat>[
    copyVideo,
    copyAudio,
    mp4,
    mkv,
    webm,
    mov,
    avi,
    gif,
    wmv,
    flv,
    mpeg,
    ts,
    m2ts,
    threegp,
    ogv,
    webp,
    mp3,
    aac,
    m4a,
    wav,
    flac,
    ogg,
    opus,
    ac3,
    wma,
    aiff,
    mp2,
    wv,
    tta,
    spx,
    amr,
    alac,
    caf,
  ];

  static const videoFormats = <MediaFormat>[
    copyVideo,
    mp4,
    mkv,
    webm,
    mov,
    avi,
    gif,
    wmv,
    flv,
    mpeg,
    ts,
    m2ts,
    threegp,
    ogv,
    webp,
  ];
  static const audioFormats = <MediaFormat>[
    copyAudio,
    mp3,
    aac,
    m4a,
    wav,
    flac,
    ogg,
    opus,
    ac3,
    wma,
    aiff,
    mp2,
    wv,
    tta,
    spx,
    amr,
    alac,
    caf,
  ];

  static MediaFormat? byId(String id) {
    for (final format in catalog) {
      if (format.id == id) {
        return format;
      }
    }
    return null;
  }
}

const videoExtensions = <String>{
  'mp4',
  'mkv',
  'webm',
  'mov',
  'avi',
  'gif',
  'wmv',
  'flv',
  'm4v',
  'ts',
  'mts',
  'm2ts',
  '3gp',
  'mpeg',
  'mpg',
  'ogv',
  'webp',
  '3g2',
};

const audioExtensions = <String>{
  'mp3',
  'aac',
  'm4a',
  'wav',
  'flac',
  'ogg',
  'opus',
  'wma',
  'aiff',
  'aif',
  'oga',
  'ac3',
  'mp2',
  'wv',
  'tta',
  'spx',
  'amr',
  'caf',
};

const mediaExtensions = <String>{
  ...videoExtensions,
  ...audioExtensions,
};

String? _extensionKey(String path) {
  final dot = path.lastIndexOf('.');
  if (dot < 0 || dot == path.length - 1) {
    return null;
  }
  return path.substring(dot + 1).toLowerCase();
}

bool isVideoPath(String path) {
  final ext = _extensionKey(path);
  return ext != null && videoExtensions.contains(ext);
}

bool isAudioPath(String path) {
  final ext = _extensionKey(path);
  return ext != null && audioExtensions.contains(ext);
}

bool isMediaPath(String path) {
  return isVideoPath(path) || isAudioPath(path);
}

MediaFormat keepOriginalFormatFor(String path) {
  return isAudioPath(path) ? MediaFormat.copyAudio : MediaFormat.copyVideo;
}

MediaFormat? sourceContainerFormatFor(String path) {
  switch (_extensionKey(path)) {
    case 'mp4':
    case 'm4v':
      return MediaFormat.mp4;
    case 'mkv':
      return MediaFormat.mkv;
    case 'webm':
      return MediaFormat.webm;
    case 'mov':
      return MediaFormat.mov;
    case 'avi':
      return MediaFormat.avi;
    case 'gif':
      return MediaFormat.gif;
    case 'wmv':
      return MediaFormat.wmv;
    case 'flv':
      return MediaFormat.flv;
    case 'mpeg':
    case 'mpg':
      return MediaFormat.mpeg;
    case 'ts':
    case 'mts':
      return MediaFormat.ts;
    case 'm2ts':
      return MediaFormat.m2ts;
    case '3gp':
    case '3g2':
      return MediaFormat.threegp;
    case 'ogv':
      return MediaFormat.ogv;
    case 'webp':
      return MediaFormat.webp;
    case 'mp3':
      return MediaFormat.mp3;
    case 'aac':
      return MediaFormat.aac;
    case 'm4a':
      return MediaFormat.m4a;
    case 'wav':
      return MediaFormat.wav;
    case 'flac':
      return MediaFormat.flac;
    case 'ogg':
    case 'oga':
      return MediaFormat.ogg;
    case 'opus':
      return MediaFormat.opus;
    case 'ac3':
      return MediaFormat.ac3;
    case 'wma':
      return MediaFormat.wma;
    case 'aiff':
    case 'aif':
      return MediaFormat.aiff;
    case 'mp2':
      return MediaFormat.mp2;
    case 'wv':
      return MediaFormat.wv;
    case 'tta':
      return MediaFormat.tta;
    case 'spx':
      return MediaFormat.spx;
    case 'amr':
      return MediaFormat.amr;
    case 'caf':
      return MediaFormat.caf;
    default:
      return null;
  }
}

MediaFormat effectiveEncodeFormat(MediaFormat targetFormat, String inputPath) {
  if (!targetFormat.keepsSourceCodec) {
    return targetFormat;
  }
  return sourceContainerFormatFor(inputPath) ??
      (targetFormat.isAudio ? MediaFormat.mp3 : MediaFormat.mkv);
}

List<String> filterMediaPaths(Iterable<String> paths) {
  return paths.where(isMediaPath).toList(growable: false);
}

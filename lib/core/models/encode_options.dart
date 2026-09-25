import '../ffmpeg/hardware_probe.dart';

enum OutputPreset { original, p1080, p720, p480, custom }

enum QualityPreset { smaller, standard, higher, custom }

enum VideoEncoderChoice {
  auto,
  h264,
  h265,
  h264Nvenc,
  h265Nvenc,
  h264Amf,
  h265Amf,
  h264Qsv,
  h265Qsv,
  h264Vaapi,
  h265Vaapi,
  h264Videotoolbox,
  h265Videotoolbox,
  vp9,
  av1,
}

enum RateControlMode { quality, vbr, cbr }

enum EncoderSpeed { auto, fastest, faster, fast, medium, slow, slower, slowest }

enum VideoTune { auto, film, animation, grain, stillimage, fastdecode, zerolatency }

enum H264ProfileChoice { auto, baseline, main, high }

enum PixelFormatChoice { auto, yuv420p, yuv420p10 }

enum ScaleFlags { auto, bilinear, bicubic, lanczos }

enum DeinterlaceMode { off, yadif, yadifDouble }

enum VideoRotation { none, clockwise, half, counterClockwise }

enum FpsModeChoice { auto, cfr, vfr }

enum KeyframeInterval { auto, oneSecond, twoSeconds, fiveSeconds, tenSeconds }

enum AudioRateMode { quality, bitrate }

enum OpusApplication { audio, voip, lowdelay }

enum OpusVbrMode { on, constrained, off }

class EncodeOptions {
  const EncodeOptions({
    this.outputPreset = OutputPreset.original,
    this.keepAspectRatio = true,
    this.width,
    this.height,
    this.videoBitrateKbps,
    this.audioBitrateKbps,
    this.frameRate,
    this.sampleRate,
    this.channels,
    this.qualityPreset = QualityPreset.standard,
    this.videoEncoder = VideoEncoderChoice.auto,
    this.rateControl = RateControlMode.quality,
    this.crf,
    this.maxRateKbps,
    this.bufSizeKbps,
    this.speed = EncoderSpeed.auto,
    this.tune = VideoTune.auto,
    this.h264Profile = H264ProfileChoice.auto,
    this.pixelFormat = PixelFormatChoice.auto,
    this.scaleFlags = ScaleFlags.auto,
    this.deinterlace = DeinterlaceMode.off,
    this.rotation = VideoRotation.none,
    this.flipHorizontal = false,
    this.flipVertical = false,
    this.fpsMode = FpsModeChoice.auto,
    this.keyframeInterval = KeyframeInterval.auto,
    this.volumeDb = 0,
    this.loudnessNormalize = false,
    this.audioRateMode = AudioRateMode.bitrate,
    this.audioQuality,
    this.flacCompression = 5,
    this.opusApplication = OpusApplication.audio,
    this.opusVbr = OpusVbrMode.on,
    this.hardwareDecode = false,
    this.fastStart = true,
    this.keepMetadata = true,
    this.keepChapters = true,
    this.title = '',
    this.artist = '',
    this.album = '',
    this.year = '',
    this.comment = '',
  });

  final OutputPreset outputPreset;
  final bool keepAspectRatio;
  final int? width;
  final int? height;
  final int? videoBitrateKbps;
  final int? audioBitrateKbps;
  final double? frameRate;
  final int? sampleRate;
  final int? channels;
  final QualityPreset qualityPreset;
  final VideoEncoderChoice videoEncoder;
  final RateControlMode rateControl;
  final int? crf;
  final int? maxRateKbps;
  final int? bufSizeKbps;
  final EncoderSpeed speed;
  final VideoTune tune;
  final H264ProfileChoice h264Profile;
  final PixelFormatChoice pixelFormat;
  final ScaleFlags scaleFlags;
  final DeinterlaceMode deinterlace;
  final VideoRotation rotation;
  final bool flipHorizontal;
  final bool flipVertical;
  final FpsModeChoice fpsMode;
  final KeyframeInterval keyframeInterval;
  final double volumeDb;
  final bool loudnessNormalize;
  final AudioRateMode audioRateMode;
  final int? audioQuality;
  final int flacCompression;
  final OpusApplication opusApplication;
  final OpusVbrMode opusVbr;
  final bool hardwareDecode;
  final bool fastStart;
  final bool keepMetadata;
  final bool keepChapters;
  final String title;
  final String artist;
  final String album;
  final String year;
  final String comment;

  EncodeOptions copyWith({
    OutputPreset? outputPreset,
    bool? keepAspectRatio,
    int? width,
    int? height,
    bool clearWidth = false,
    bool clearHeight = false,
    int? videoBitrateKbps,
    bool clearVideoBitrate = false,
    int? audioBitrateKbps,
    bool clearAudioBitrate = false,
    double? frameRate,
    bool clearFrameRate = false,
    int? sampleRate,
    bool clearSampleRate = false,
    int? channels,
    bool clearChannels = false,
    QualityPreset? qualityPreset,
    VideoEncoderChoice? videoEncoder,
    RateControlMode? rateControl,
    int? crf,
    bool clearCrf = false,
    int? maxRateKbps,
    bool clearMaxRate = false,
    int? bufSizeKbps,
    bool clearBufSize = false,
    EncoderSpeed? speed,
    VideoTune? tune,
    H264ProfileChoice? h264Profile,
    PixelFormatChoice? pixelFormat,
    ScaleFlags? scaleFlags,
    DeinterlaceMode? deinterlace,
    VideoRotation? rotation,
    bool? flipHorizontal,
    bool? flipVertical,
    FpsModeChoice? fpsMode,
    KeyframeInterval? keyframeInterval,
    double? volumeDb,
    bool? loudnessNormalize,
    AudioRateMode? audioRateMode,
    int? audioQuality,
    bool clearAudioQuality = false,
    int? flacCompression,
    OpusApplication? opusApplication,
    OpusVbrMode? opusVbr,
    bool? hardwareDecode,
    bool? fastStart,
    bool? keepMetadata,
    bool? keepChapters,
    String? title,
    String? artist,
    String? album,
    String? year,
    String? comment,
  }) {
    return EncodeOptions(
      outputPreset: outputPreset ?? this.outputPreset,
      keepAspectRatio: keepAspectRatio ?? this.keepAspectRatio,
      width: clearWidth ? null : (width ?? this.width),
      height: clearHeight ? null : (height ?? this.height),
      videoBitrateKbps: clearVideoBitrate
          ? null
          : (videoBitrateKbps ?? this.videoBitrateKbps),
      audioBitrateKbps: clearAudioBitrate
          ? null
          : (audioBitrateKbps ?? this.audioBitrateKbps),
      frameRate: clearFrameRate ? null : (frameRate ?? this.frameRate),
      sampleRate: clearSampleRate ? null : (sampleRate ?? this.sampleRate),
      channels: clearChannels ? null : (channels ?? this.channels),
      qualityPreset: qualityPreset ?? this.qualityPreset,
      videoEncoder: videoEncoder ?? this.videoEncoder,
      rateControl: rateControl ?? this.rateControl,
      crf: clearCrf ? null : (crf ?? this.crf),
      maxRateKbps: clearMaxRate ? null : (maxRateKbps ?? this.maxRateKbps),
      bufSizeKbps: clearBufSize ? null : (bufSizeKbps ?? this.bufSizeKbps),
      speed: speed ?? this.speed,
      tune: tune ?? this.tune,
      h264Profile: h264Profile ?? this.h264Profile,
      pixelFormat: pixelFormat ?? this.pixelFormat,
      scaleFlags: scaleFlags ?? this.scaleFlags,
      deinterlace: deinterlace ?? this.deinterlace,
      rotation: rotation ?? this.rotation,
      flipHorizontal: flipHorizontal ?? this.flipHorizontal,
      flipVertical: flipVertical ?? this.flipVertical,
      fpsMode: fpsMode ?? this.fpsMode,
      keyframeInterval: keyframeInterval ?? this.keyframeInterval,
      volumeDb: volumeDb ?? this.volumeDb,
      loudnessNormalize: loudnessNormalize ?? this.loudnessNormalize,
      audioRateMode: audioRateMode ?? this.audioRateMode,
      audioQuality: clearAudioQuality
          ? null
          : (audioQuality ?? this.audioQuality),
      flacCompression: flacCompression ?? this.flacCompression,
      opusApplication: opusApplication ?? this.opusApplication,
      opusVbr: opusVbr ?? this.opusVbr,
      hardwareDecode: hardwareDecode ?? this.hardwareDecode,
      fastStart: fastStart ?? this.fastStart,
      keepMetadata: keepMetadata ?? this.keepMetadata,
      keepChapters: keepChapters ?? this.keepChapters,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      year: year ?? this.year,
      comment: comment ?? this.comment,
    );
  }

  EncodeOptions applyPreset(OutputPreset preset) {
    switch (preset) {
      case OutputPreset.original:
        return copyWith(
          outputPreset: preset,
          keepAspectRatio: true,
          clearWidth: true,
          clearHeight: true,
        );
      case OutputPreset.p1080:
        return copyWith(
          outputPreset: preset,
          keepAspectRatio: true,
          width: 1920,
          height: 1080,
        );
      case OutputPreset.p720:
        return copyWith(
          outputPreset: preset,
          keepAspectRatio: true,
          width: 1280,
          height: 720,
        );
      case OutputPreset.p480:
        return copyWith(
          outputPreset: preset,
          keepAspectRatio: true,
          width: 854,
          height: 480,
        );
      case OutputPreset.custom:
        return copyWith(outputPreset: preset);
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'outputPreset': outputPreset.name,
      'keepAspectRatio': keepAspectRatio,
      'width': width,
      'height': height,
      'videoBitrateKbps': videoBitrateKbps,
      'audioBitrateKbps': audioBitrateKbps,
      'frameRate': frameRate,
      'sampleRate': sampleRate,
      'channels': channels,
      'qualityPreset': qualityPreset.name,
      'videoEncoder': videoEncoder.name,
      'rateControl': rateControl.name,
      'crf': crf,
      'maxRateKbps': maxRateKbps,
      'bufSizeKbps': bufSizeKbps,
      'speed': speed.name,
      'tune': tune.name,
      'h264Profile': h264Profile.name,
      'pixelFormat': pixelFormat.name,
      'scaleFlags': scaleFlags.name,
      'deinterlace': deinterlace.name,
      'rotation': rotation.name,
      'flipHorizontal': flipHorizontal,
      'flipVertical': flipVertical,
      'fpsMode': fpsMode.name,
      'keyframeInterval': keyframeInterval.name,
      'volumeDb': volumeDb,
      'loudnessNormalize': loudnessNormalize,
      'audioRateMode': audioRateMode.name,
      'audioQuality': audioQuality,
      'flacCompression': flacCompression,
      'opusApplication': opusApplication.name,
      'opusVbr': opusVbr.name,
      'hardwareDecode': hardwareDecode,
      'fastStart': fastStart,
      'keepMetadata': keepMetadata,
      'keepChapters': keepChapters,
      'title': title,
      'artist': artist,
      'album': album,
      'year': year,
      'comment': comment,
    };
  }

  factory EncodeOptions.fromJson(Map<String, dynamic> json) {
    return EncodeOptions(
      outputPreset: _enumFromName(
        OutputPreset.values,
        json['outputPreset'] as String?,
        OutputPreset.original,
      ),
      keepAspectRatio: json['keepAspectRatio'] as bool? ?? true,
      width: json['width'] as int?,
      height: json['height'] as int?,
      videoBitrateKbps: json['videoBitrateKbps'] as int?,
      audioBitrateKbps: json['audioBitrateKbps'] as int?,
      frameRate: (json['frameRate'] as num?)?.toDouble(),
      sampleRate: json['sampleRate'] as int?,
      channels: json['channels'] as int?,
      qualityPreset: _enumFromName(
        QualityPreset.values,
        json['qualityPreset'] as String?,
        QualityPreset.standard,
      ),
      videoEncoder: _enumFromName(
        VideoEncoderChoice.values,
        json['videoEncoder'] as String?,
        VideoEncoderChoice.auto,
      ),
      rateControl: _enumFromName(
        RateControlMode.values,
        json['rateControl'] as String?,
        json['videoBitrateKbps'] == null
            ? RateControlMode.quality
            : RateControlMode.vbr,
      ),
      crf: json['crf'] as int?,
      maxRateKbps: json['maxRateKbps'] as int?,
      bufSizeKbps: json['bufSizeKbps'] as int?,
      speed: _enumFromName(
        EncoderSpeed.values,
        json['speed'] as String?,
        EncoderSpeed.auto,
      ),
      tune: _enumFromName(
        VideoTune.values,
        json['tune'] as String?,
        VideoTune.auto,
      ),
      h264Profile: _enumFromName(
        H264ProfileChoice.values,
        json['h264Profile'] as String?,
        H264ProfileChoice.auto,
      ),
      pixelFormat: _enumFromName(
        PixelFormatChoice.values,
        json['pixelFormat'] as String?,
        PixelFormatChoice.auto,
      ),
      scaleFlags: _enumFromName(
        ScaleFlags.values,
        json['scaleFlags'] as String?,
        ScaleFlags.auto,
      ),
      deinterlace: _enumFromName(
        DeinterlaceMode.values,
        json['deinterlace'] as String?,
        DeinterlaceMode.off,
      ),
      rotation: _enumFromName(
        VideoRotation.values,
        json['rotation'] as String?,
        VideoRotation.none,
      ),
      flipHorizontal: json['flipHorizontal'] as bool? ?? false,
      flipVertical: json['flipVertical'] as bool? ?? false,
      fpsMode: _enumFromName(
        FpsModeChoice.values,
        json['fpsMode'] as String?,
        FpsModeChoice.auto,
      ),
      keyframeInterval: _enumFromName(
        KeyframeInterval.values,
        json['keyframeInterval'] as String?,
        KeyframeInterval.auto,
      ),
      volumeDb: (json['volumeDb'] as num?)?.toDouble() ?? 0,
      loudnessNormalize: json['loudnessNormalize'] as bool? ?? false,
      audioRateMode: _enumFromName(
        AudioRateMode.values,
        json['audioRateMode'] as String?,
        AudioRateMode.bitrate,
      ),
      audioQuality: json['audioQuality'] as int?,
      flacCompression: json['flacCompression'] as int? ?? 5,
      opusApplication: _enumFromName(
        OpusApplication.values,
        json['opusApplication'] as String?,
        OpusApplication.audio,
      ),
      opusVbr: _enumFromName(
        OpusVbrMode.values,
        json['opusVbr'] as String?,
        OpusVbrMode.on,
      ),
      hardwareDecode: json['hardwareDecode'] as bool? ?? false,
      fastStart: json['fastStart'] as bool? ?? true,
      keepMetadata: json['keepMetadata'] as bool? ?? true,
      keepChapters: json['keepChapters'] as bool? ?? true,
      title: json['title'] as String? ?? '',
      artist: json['artist'] as String? ?? '',
      album: json['album'] as String? ?? '',
      year: json['year'] as String? ?? '',
      comment: json['comment'] as String? ?? '',
    );
  }
}

T _enumFromName<T extends Enum>(List<T> values, String? name, T fallback) {
  if (name == null) {
    return fallback;
  }
  for (final value in values) {
    if (value.name == name) {
      return value;
    }
  }
  return fallback;
}

int qualityToCrf(QualityPreset preset) {
  switch (preset) {
    case QualityPreset.smaller:
      return 28;
    case QualityPreset.standard:
    case QualityPreset.custom:
      return 23;
    case QualityPreset.higher:
      return 18;
  }
}

int qualityToAudioBitrate(QualityPreset preset) {
  switch (preset) {
    case QualityPreset.smaller:
      return 96;
    case QualityPreset.standard:
    case QualityPreset.custom:
      return 192;
    case QualityPreset.higher:
      return 320;
  }
}

const advancedVideoFormats = {
  'mp4',
  'mov',
  'mkv',
  'ts',
  'm2ts',
  'flv',
  '3gp',
  'webm',
};

const h26xFormats = {'mp4', 'mov', 'mkv', 'ts', 'm2ts', 'flv', '3gp'};

const tenBitFormats = {'mp4', 'mov', 'mkv', 'webm'};

bool formatSupportsAdvancedVideo(String formatId) {
  return advancedVideoFormats.contains(formatId);
}

List<VideoEncoderChoice> videoEncodersFor(String formatId) {
  if (formatId == 'webm') {
    return const [VideoEncoderChoice.auto, VideoEncoderChoice.vp9, VideoEncoderChoice.av1];
  }
  if (h26xFormats.contains(formatId)) {
    return [
      VideoEncoderChoice.auto,
      VideoEncoderChoice.h264,
      VideoEncoderChoice.h265,
      ...hardwareEncodersForPlatform(),
    ];
  }
  return const [VideoEncoderChoice.auto];
}

List<VideoEncoderChoice> _encodersForResolution(String formatId) {
  if (formatId == 'webm') {
    return const [VideoEncoderChoice.auto, VideoEncoderChoice.vp9, VideoEncoderChoice.av1];
  }
  if (h26xFormats.contains(formatId)) {
    return const [
      VideoEncoderChoice.auto,
      VideoEncoderChoice.h264,
      VideoEncoderChoice.h265,
      VideoEncoderChoice.h264Nvenc,
      VideoEncoderChoice.h265Nvenc,
      VideoEncoderChoice.h264Amf,
      VideoEncoderChoice.h265Amf,
      VideoEncoderChoice.h264Qsv,
      VideoEncoderChoice.h265Qsv,
      VideoEncoderChoice.h264Vaapi,
      VideoEncoderChoice.h265Vaapi,
      VideoEncoderChoice.h264Videotoolbox,
      VideoEncoderChoice.h265Videotoolbox,
    ];
  }
  return const [VideoEncoderChoice.auto];
}

List<VideoEncoderChoice> hardwareEncodersForPlatform() {
  return [
    if (vendorSupportedOnPlatform(HardwareVendor.nvidia)) ...[
      VideoEncoderChoice.h264Nvenc,
      VideoEncoderChoice.h265Nvenc,
    ],
    if (vendorSupportedOnPlatform(HardwareVendor.amd)) ...[
      VideoEncoderChoice.h264Amf,
      VideoEncoderChoice.h265Amf,
    ],
    if (vendorSupportedOnPlatform(HardwareVendor.intel)) ...[
      VideoEncoderChoice.h264Qsv,
      VideoEncoderChoice.h265Qsv,
    ],
    if (vendorSupportedOnPlatform(HardwareVendor.vaapi)) ...[
      VideoEncoderChoice.h264Vaapi,
      VideoEncoderChoice.h265Vaapi,
    ],
    if (vendorSupportedOnPlatform(HardwareVendor.apple)) ...[
      VideoEncoderChoice.h264Videotoolbox,
      VideoEncoderChoice.h265Videotoolbox,
    ],
  ];
}

bool encoderIsHevc(VideoEncoderChoice encoder) {
  switch (encoder) {
    case VideoEncoderChoice.h265:
    case VideoEncoderChoice.h265Nvenc:
    case VideoEncoderChoice.h265Amf:
    case VideoEncoderChoice.h265Qsv:
    case VideoEncoderChoice.h265Vaapi:
    case VideoEncoderChoice.h265Videotoolbox:
      return true;
    default:
      return false;
  }
}

VideoEncoderChoice hardwareEncoderForVendor(
  HardwareVendor? vendor, {
  required bool hevc,
}) {
  return switch (vendor) {
    HardwareVendor.amd =>
      hevc ? VideoEncoderChoice.h265Amf : VideoEncoderChoice.h264Amf,
    HardwareVendor.intel =>
      hevc ? VideoEncoderChoice.h265Qsv : VideoEncoderChoice.h264Qsv,
    HardwareVendor.apple => hevc
        ? VideoEncoderChoice.h265Videotoolbox
        : VideoEncoderChoice.h264Videotoolbox,
    HardwareVendor.vaapi =>
      hevc ? VideoEncoderChoice.h265Vaapi : VideoEncoderChoice.h264Vaapi,
    _ => hevc ? VideoEncoderChoice.h265Nvenc : VideoEncoderChoice.h264Nvenc,
  };
}

VideoEncoderChoice resolveVideoEncoder(
  String formatId,
  VideoEncoderChoice selected, {
  bool hardwareAcceleration = false,
  HardwareVendor? hardwareVendor,
}) {
  final allowed = _encodersForResolution(formatId);
  if (hardwareAcceleration && h26xFormats.contains(formatId)) {
    if (selected == VideoEncoderChoice.vp9 ||
        selected == VideoEncoderChoice.av1) {
      return selected;
    }
    final accelerated = hardwareEncoderForVendor(
      hardwareVendor,
      hevc: encoderIsHevc(selected),
    );
    if (allowed.contains(accelerated)) {
      return accelerated;
    }
  }
  if (selected != VideoEncoderChoice.auto &&
      allowed.contains(selected) &&
      !encoderIsHardware(selected)) {
    return selected;
  }
  if (formatId == 'webm') {
    return VideoEncoderChoice.vp9;
  }
  if (h26xFormats.contains(formatId)) {
    return VideoEncoderChoice.h264;
  }
  return VideoEncoderChoice.auto;
}

HardwareVendor? hardwareVendorForEncoder(VideoEncoderChoice encoder) {
  switch (encoder) {
    case VideoEncoderChoice.h264Nvenc:
    case VideoEncoderChoice.h265Nvenc:
      return HardwareVendor.nvidia;
    case VideoEncoderChoice.h264Amf:
    case VideoEncoderChoice.h265Amf:
      return HardwareVendor.amd;
    case VideoEncoderChoice.h264Qsv:
    case VideoEncoderChoice.h265Qsv:
      return HardwareVendor.intel;
    case VideoEncoderChoice.h264Vaapi:
    case VideoEncoderChoice.h265Vaapi:
      return HardwareVendor.vaapi;
    case VideoEncoderChoice.h264Videotoolbox:
    case VideoEncoderChoice.h265Videotoolbox:
      return HardwareVendor.apple;
    default:
      return null;
  }
}

bool encoderIsHardware(VideoEncoderChoice encoder) {
  switch (encoder) {
    case VideoEncoderChoice.h264Nvenc:
    case VideoEncoderChoice.h265Nvenc:
    case VideoEncoderChoice.h264Amf:
    case VideoEncoderChoice.h265Amf:
    case VideoEncoderChoice.h264Qsv:
    case VideoEncoderChoice.h265Qsv:
    case VideoEncoderChoice.h264Vaapi:
    case VideoEncoderChoice.h265Vaapi:
    case VideoEncoderChoice.h264Videotoolbox:
    case VideoEncoderChoice.h265Videotoolbox:
      return true;
    default:
      return false;
  }
}

bool encoderSupportsTenBit(VideoEncoderChoice encoder) {
  switch (encoder) {
    case VideoEncoderChoice.h265:
    case VideoEncoderChoice.h265Nvenc:
    case VideoEncoderChoice.h265Amf:
    case VideoEncoderChoice.h265Qsv:
    case VideoEncoderChoice.h265Vaapi:
    case VideoEncoderChoice.h265Videotoolbox:
    case VideoEncoderChoice.vp9:
    case VideoEncoderChoice.av1:
      return true;
    default:
      return false;
  }
}

int crfUpperBound(VideoEncoderChoice encoder) {
  switch (encoder) {
    case VideoEncoderChoice.vp9:
    case VideoEncoderChoice.av1:
      return 63;
    default:
      return 51;
  }
}

String? resolvedX26xPreset(EncoderSpeed speed) {
  switch (speed) {
    case EncoderSpeed.auto:
      return null;
    case EncoderSpeed.fastest:
      return 'ultrafast';
    case EncoderSpeed.faster:
      return 'superfast';
    case EncoderSpeed.fast:
      return 'veryfast';
    case EncoderSpeed.medium:
      return 'medium';
    case EncoderSpeed.slow:
      return 'slow';
    case EncoderSpeed.slower:
      return 'slower';
    case EncoderSpeed.slowest:
      return 'veryslow';
  }
}

String? resolvedNvencPreset(EncoderSpeed speed) {
  switch (speed) {
    case EncoderSpeed.auto:
      return null;
    case EncoderSpeed.fastest:
      return 'p1';
    case EncoderSpeed.faster:
      return 'p2';
    case EncoderSpeed.fast:
      return 'p3';
    case EncoderSpeed.medium:
      return 'p4';
    case EncoderSpeed.slow:
      return 'p5';
    case EncoderSpeed.slower:
      return 'p6';
    case EncoderSpeed.slowest:
      return 'p7';
  }
}

String? resolvedQsvPreset(EncoderSpeed speed) {
  switch (speed) {
    case EncoderSpeed.auto:
      return null;
    case EncoderSpeed.fastest:
    case EncoderSpeed.faster:
      return 'veryfast';
    case EncoderSpeed.fast:
      return 'fast';
    case EncoderSpeed.medium:
      return 'medium';
    case EncoderSpeed.slow:
      return 'slow';
    case EncoderSpeed.slower:
      return 'slower';
    case EncoderSpeed.slowest:
      return 'veryslow';
  }
}

String? resolvedAmfPreset(EncoderSpeed speed) {
  switch (speed) {
    case EncoderSpeed.auto:
      return null;
    case EncoderSpeed.fastest:
    case EncoderSpeed.faster:
    case EncoderSpeed.fast:
      return 'speed';
    case EncoderSpeed.medium:
      return 'balanced';
    case EncoderSpeed.slow:
    case EncoderSpeed.slower:
    case EncoderSpeed.slowest:
      return 'quality';
  }
}

String? resolvedVp9Deadline(EncoderSpeed speed) {
  switch (speed) {
    case EncoderSpeed.auto:
      return null;
    case EncoderSpeed.fastest:
    case EncoderSpeed.faster:
    case EncoderSpeed.fast:
      return 'realtime';
    case EncoderSpeed.medium:
    case EncoderSpeed.slow:
      return 'good';
    case EncoderSpeed.slower:
    case EncoderSpeed.slowest:
      return 'best';
  }
}

int? resolvedAv1CpuUsed(EncoderSpeed speed) {
  switch (speed) {
    case EncoderSpeed.auto:
      return null;
    case EncoderSpeed.fastest:
      return 8;
    case EncoderSpeed.faster:
      return 7;
    case EncoderSpeed.fast:
      return 6;
    case EncoderSpeed.medium:
      return 4;
    case EncoderSpeed.slow:
      return 2;
    case EncoderSpeed.slower:
      return 1;
    case EncoderSpeed.slowest:
      return 0;
  }
}

int? resolvedKeyframeFrames(KeyframeInterval interval, double? frameRate) {
  final seconds = switch (interval) {
    KeyframeInterval.auto => null,
    KeyframeInterval.oneSecond => 1,
    KeyframeInterval.twoSeconds => 2,
    KeyframeInterval.fiveSeconds => 5,
    KeyframeInterval.tenSeconds => 10,
  };
  if (seconds == null) {
    return null;
  }
  final fps = frameRate == null || frameRate <= 0 ? 30 : frameRate;
  final frames = (fps * seconds).round();
  return frames < 1 ? 1 : frames;
}

const supportedSampleRates = <int>[8000, 16000, 22050, 32000, 44100, 48000, 96000];

const aacSampleRates = <int>[
  8000,
  11025,
  12000,
  16000,
  22050,
  24000,
  32000,
  44100,
  48000,
  64000,
  88200,
  96000,
];

const mp3SampleRates = <int>[8000, 11025, 12000, 16000, 22050, 24000, 32000, 44100, 48000];

const opusSampleRates = <int>[8000, 12000, 16000, 24000, 48000];

int? nearestSampleRate(int? requested, List<int> allowed) {
  if (requested == null) {
    return null;
  }
  var best = allowed.first;
  var bestDistance = (best - requested).abs();
  for (final rate in allowed.skip(1)) {
    final distance = (rate - requested).abs();
    if (distance < bestDistance) {
      best = rate;
      bestDistance = distance;
    }
  }
  return best;
}

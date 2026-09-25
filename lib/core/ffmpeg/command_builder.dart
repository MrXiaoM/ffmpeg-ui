import '../models/clip_range.dart';
import 'hardware_probe.dart';
import '../models/conversion_task.dart';
import '../models/encode_options.dart';
import '../models/media_format.dart';
import '../models/media_info.dart';
import '../models/source_codec.dart';
import '../models/subtitle_track.dart';

class FfmpegCommandException implements Exception {
  const FfmpegCommandException(this.message);

  final String message;

  @override
  String toString() => message;
}

class FfmpegCommand {
  const FfmpegCommand({required this.executable, required this.arguments});

  final String executable;
  final List<String> arguments;

  String get preview {
    return [executable, ...arguments].join(' ');
  }
}

class FfmpegCommandBuilder {
  const FfmpegCommandBuilder();

  FfmpegCommand build({
    required String ffmpegPath,
    required ConversionTask task,
    required String outputPath,
    HardwareVendor? hardwareVendor,
    MediaInfo? mediaInfo,
  }) {
    final args = <String>[
      '-hide_banner',
      '-y',
      '-progress',
      'pipe:1',
      '-nostats',
    ];
    final clip = task.clipRange;
    if (clip != null) {
      args.addAll([
        '-ss',
        formatFfmpegTime(clip.start),
        '-to',
        formatFfmpegTime(clip.end),
      ]);
    }
    if (!task.targetFormat.keepsSourceCodec ||
        encodeNeedsVideoProcessing(task.encode)) {
      args.addAll(_hardwareDecodeArgs(task, hardwareVendor, mediaInfo));
    }
    args.addAll(['-i', task.inputPath]);
    final subtitleEdit = task.subtitleEdit;
    if (subtitleEdit != null) {
      for (final addition in subtitleEdit.additions) {
        args.addAll(['-i', addition.path]);
      }
    }
    if (task.targetFormat.keepsSourceCodec) {
      args.addAll(_keepSourceArgs(task, hardwareVendor, mediaInfo));
    } else if (task.targetFormat.isVideo) {
      args.addAll(_videoArgs(task, hardwareVendor));
    } else {
      args.addAll(_audioArgs(task));
    }
    if (subtitleEdit != null) {
      if (!task.targetFormat.keepsSourceCodec && task.targetFormat.isVideo) {
        args.addAll(['-map', '0:v', '-map', '0:a?']);
      }
      args.addAll(_subtitleMapArgs(task, subtitleEdit));
    }

    args.add(outputPath);
    return FfmpegCommand(executable: ffmpegPath, arguments: args);
  }

  MediaFormat _effectiveFormat(ConversionTask task) {
    return effectiveEncodeFormat(task.targetFormat, task.inputPath);
  }

  EncodeOptions _videoEncodeOptions(
    ConversionTask task,
    MediaInfo? mediaInfo,
  ) {
    final encode = task.encode;
    if (!task.targetFormat.keepsSourceCodec ||
        encode.videoEncoder != VideoEncoderChoice.auto) {
      return encode;
    }
    final source = videoEncoderForSourceCodec(mediaInfo?.videoCodec);
    if (source == null) {
      return encode;
    }
    return encode.copyWith(videoEncoder: source);
  }

  List<String> _copyArgs(ConversionTask task) {
    final encode = task.encode;
    final format = _effectiveFormat(task);
    if (task.targetFormat.isAudio) {
      return ['-vn', '-c:a', 'copy', ..._streamMetadataArgs(encode)];
    }
    final mapDefaultSubtitles = task.subtitleEdit == null;
    return [
      '-map',
      '0:v',
      '-map',
      '0:a?',
      if (mapDefaultSubtitles) ...['-map', '0:s?'],
      if (mapDefaultSubtitles) ...['-c', 'copy'] else ...['-c:v', 'copy', '-c:a', 'copy'],
      ..._streamMetadataArgs(encode),
      if ((format.id == 'mp4' || format.id == 'mov') && encode.fastStart)
        ...['-movflags', '+faststart'],
    ];
  }

  List<String> _keepSourceArgs(
    ConversionTask task,
    HardwareVendor? hardwareVendor,
    MediaInfo? mediaInfo,
  ) {
    final videoProcess = encodeNeedsVideoProcessing(task.encode);
    final audioProcess = encodeNeedsAudioProcessing(task.encode);
    if (!videoProcess && !audioProcess) {
      return _copyArgs(task);
    }
    if (task.targetFormat.isAudio) {
      return _copyAudioProcessArgs(task, mediaInfo);
    }
    return _copyVideoProcessArgs(
      task,
      hardwareVendor,
      mediaInfo,
      videoProcess: videoProcess,
      audioProcess: audioProcess,
    );
  }

  List<String> _copyAudioProcessArgs(
    ConversionTask task,
    MediaInfo? mediaInfo,
  ) {
    final format =
        audioFormatForSourceCodec(mediaInfo?.audioCodec) ??
        _effectiveFormat(task);
    final encode = task.encode;
    return [
      '-vn',
      ..._audioFilterArgs(encode),
      ..._audioCodecArgs(format, encode),
      ..._streamMetadataArgs(encode),
    ];
  }

  List<String> _copyVideoProcessArgs(
    ConversionTask task,
    HardwareVendor? hardwareVendor,
    MediaInfo? mediaInfo, {
    required bool videoProcess,
    required bool audioProcess,
  }) {
    final encode = task.encode;
    final format = _effectiveFormat(task);
    final mapDefaultSubtitles = task.subtitleEdit == null;
    final args = <String>[
      '-map',
      '0:v',
      '-map',
      '0:a?',
      if (mapDefaultSubtitles) ...['-map', '0:s?'],
      ..._processedVideoArgs(
        task,
        hardwareVendor,
        mediaInfo,
        process: videoProcess,
      ),
      ..._processedAudioArgs(
        task,
        mediaInfo,
        process: audioProcess,
      ),
      if (mapDefaultSubtitles) ...['-c:s', 'copy'],
      ..._streamMetadataArgs(encode),
      if (!videoProcess &&
          (format.id == 'mp4' || format.id == 'mov') &&
          encode.fastStart)
        ...['-movflags', '+faststart'],
    ];
    return args;
  }

  List<String> _processedVideoArgs(
    ConversionTask task,
    HardwareVendor? hardwareVendor,
    MediaInfo? mediaInfo, {
    required bool process,
  }) {
    if (!process) {
      return const ['-c:v', 'copy'];
    }
    final encode = _videoEncodeOptions(task, mediaInfo);
    final format = _effectiveFormat(task);
    final args = <String>[];
    if (format.id == 'gif' || format.id == 'webp') {
      final filters = _cpuVideoFilters(encode);
      filters.add('fps=${encode.frameRate?.toStringAsFixed(0) ?? '15'}');
      if (filters.isNotEmpty) {
        args.addAll(['-vf', filters.join(',')]);
      }
      args.addAll(['-loop', '0']);
      if (format.id == 'webp') {
        args.addAll(['-c:v', 'libwebp_anim']);
      }
      return args;
    }
    final filters = _videoFilters(
      task,
      hardwareVendor,
      format: format,
      encode: encode,
    );
    if (filters.isNotEmpty) {
      args.addAll(['-vf', filters.join(',')]);
    }
    args.addAll(_videoTimingArgs(encode));
    args.addAll(_videoCodecArgs(format, encode, hardwareVendor));
    return args;
  }

  List<String> _processedAudioArgs(
    ConversionTask task,
    MediaInfo? mediaInfo, {
    required bool process,
  }) {
    if (!process) {
      return const ['-c:a', 'copy'];
    }
    final encode = task.encode;
    final format = task.targetFormat.keepsSourceCodec
        ? (audioFormatForSourceCodec(mediaInfo?.audioCodec) ??
            _effectiveFormat(task))
        : task.targetFormat;
    return [
      ..._audioFilterArgs(encode),
      ..._audioCodecArgs(format, encode),
    ];
  }

  List<String> _videoTimingArgs(EncodeOptions encode) {
    final args = <String>[];
    if (encode.frameRate != null) {
      args.addAll(['-r', _trimNumber(encode.frameRate!)]);
    }
    if (encode.fpsMode != FpsModeChoice.auto) {
      args.addAll(['-fps_mode', encode.fpsMode.name]);
    }
    final keyframeFrames = resolvedKeyframeFrames(
      encode.keyframeInterval,
      encode.frameRate,
    );
    if (keyframeFrames != null) {
      args.addAll(['-g', '$keyframeFrames']);
    }
    return args;
  }

  List<String> _subtitleMapArgs(ConversionTask task, SubtitleEdit edit) {
    final args = <String>[];
    for (final index in edit.keepIndexes) {
      args.addAll(['-map', '0:$index']);
    }
    for (var i = 0; i < edit.additions.length; i++) {
      args.addAll(['-map', '${i + 1}:0']);
    }
    args.addAll(['-c:s', _subtitleCodec(task, edit)]);
    final kept = edit.keepIndexes.length;
    for (var i = 0; i < edit.additions.length; i++) {
      final addition = edit.additions[i];
      final stream = 's:${kept + i}';
      if (addition.language.trim().isNotEmpty) {
        args.addAll([
          '-metadata:s:$stream',
          'language=${addition.language.trim()}',
        ]);
      }
      if (addition.title.trim().isNotEmpty) {
        args.addAll([
          '-metadata:s:$stream',
          'title=${addition.title.trim()}',
        ]);
      }
      if (addition.isDefault) {
        args.addAll(['-disposition:$stream', 'default']);
      }
    }
    return args;
  }

  String _subtitleCodec(ConversionTask task, SubtitleEdit edit) {
    switch (_effectiveFormat(task).id) {
      case 'mp4':
      case 'mov':
        return 'mov_text';
      case 'webm':
        return 'webvtt';
      case 'mkv':
        if (edit.additions.isEmpty) {
          return 'copy';
        }
        final hasAss = edit.additions.any((item) {
          final ext = item.extension;
          return ext == '.ass' || ext == '.ssa';
        });
        return hasAss ? 'ass' : 'srt';
      default:
        return 'copy';
    }
  }

  List<String> _hardwareDecodeArgs(
    ConversionTask task,
    HardwareVendor? hardwareVendor,
    MediaInfo? mediaInfo,
  ) {
    if (!task.targetFormat.isVideo || !task.encode.hardwareDecode) {
      return const [];
    }
    final format = _effectiveFormat(task);
    if (!formatSupportsAdvancedVideo(format.id)) {
      return const [];
    }
    final encode = _videoEncodeOptions(task, mediaInfo);
    final encoder = resolveVideoEncoder(
      format.id,
      encode.videoEncoder,
      hardwareAcceleration: true,
      hardwareVendor: hardwareVendor,
    );
    if (!_usesHardwareFrames(encoder, task.encode)) {
      return const [];
    }
    return switch (encoder) {
      VideoEncoderChoice.h264Nvenc || VideoEncoderChoice.h265Nvenc => [
        '-hwaccel',
        'cuda',
        '-hwaccel_output_format',
        'cuda',
      ],
      VideoEncoderChoice.h264Qsv || VideoEncoderChoice.h265Qsv => [
        '-hwaccel',
        'qsv',
        '-hwaccel_output_format',
        'qsv',
      ],
      VideoEncoderChoice.h264Amf || VideoEncoderChoice.h265Amf => [
        '-hwaccel',
        'd3d11va',
        '-hwaccel_output_format',
        'd3d11',
      ],
      VideoEncoderChoice.h264Vaapi || VideoEncoderChoice.h265Vaapi => [
        '-hwaccel',
        'vaapi',
        '-hwaccel_device',
        '/dev/dri/renderD128',
        '-hwaccel_output_format',
        'vaapi',
      ],
      VideoEncoderChoice.h264Videotoolbox ||
      VideoEncoderChoice.h265Videotoolbox => [
        '-hwaccel',
        'videotoolbox',
      ],
      _ => const <String>[],
    };
  }

  bool _usesHardwareFrames(VideoEncoderChoice encoder, EncodeOptions encode) {
    if (!encoderIsHardware(encoder)) {
      return false;
    }
    if (encoder == VideoEncoderChoice.h264Nvenc ||
        encoder == VideoEncoderChoice.h265Nvenc) {
      return encode.rotation == VideoRotation.none &&
          !encode.flipHorizontal &&
          !encode.flipVertical;
    }
    if (encoder == VideoEncoderChoice.h264Amf ||
        encoder == VideoEncoderChoice.h265Amf) {
      return encode.rotation == VideoRotation.none &&
          !encode.flipHorizontal &&
          !encode.flipVertical &&
          encode.deinterlace == DeinterlaceMode.off;
    }
    if (encoder == VideoEncoderChoice.h264Qsv ||
        encoder == VideoEncoderChoice.h265Qsv) {
      final rotates = encode.rotation != VideoRotation.none;
      final bothFlips = encode.flipHorizontal && encode.flipVertical;
      final flipWithRotation =
          rotates && (encode.flipHorizontal || encode.flipVertical);
      return !bothFlips && !flipWithRotation;
    }
    if (encoder == VideoEncoderChoice.h264Vaapi ||
        encoder == VideoEncoderChoice.h265Vaapi) {
      return encode.rotation == VideoRotation.none &&
          !encode.flipHorizontal &&
          !encode.flipVertical;
    }
    if (encoder == VideoEncoderChoice.h264Videotoolbox ||
        encoder == VideoEncoderChoice.h265Videotoolbox) {
      return encode.rotation == VideoRotation.none &&
          !encode.flipHorizontal &&
          !encode.flipVertical &&
          encode.deinterlace == DeinterlaceMode.off &&
          encode.width == null &&
          encode.height == null;
    }
    return false;
  }

  List<String> _videoArgs(ConversionTask task, HardwareVendor? hardwareVendor) {
    final args = <String>[];
    final encode = task.encode;
    final filters = _videoFilters(task, hardwareVendor);
    if (task.targetFormat.id == 'gif' || task.targetFormat.id == 'webp') {
      filters.add('fps=${encode.frameRate?.toStringAsFixed(0) ?? '15'}');
      if (filters.isNotEmpty) {
        args.addAll(['-vf', filters.join(',')]);
      }
      args.addAll(['-loop', '0']);
      if (task.targetFormat.id == 'webp') {
        args.addAll(['-c:v', 'libwebp_anim']);
      }
      return args;
    }
    if (filters.isNotEmpty) {
      args.addAll(['-vf', filters.join(',')]);
    }
    if (encode.frameRate != null) {
      args.addAll(['-r', _trimNumber(encode.frameRate!)]);
    }
    if (encode.fpsMode != FpsModeChoice.auto) {
      args.addAll(['-fps_mode', encode.fpsMode.name]);
    }
    final keyframeFrames = resolvedKeyframeFrames(
      encode.keyframeInterval,
      encode.frameRate,
    );
    if (keyframeFrames != null) {
      args.addAll(['-g', '$keyframeFrames']);
    }
    args.addAll(_videoCodecArgs(task.targetFormat, encode, hardwareVendor));
    args.addAll(_audioFilterArgs(encode));
    args.addAll(_audioCodecArgs(task.targetFormat, encode));
    args.addAll(_streamMetadataArgs(encode));
    return args;
  }

  List<String> _audioArgs(ConversionTask task) {
    final encode = task.encode;
    final args = <String>['-vn', ..._audioFilterArgs(encode)];
    args.addAll(_audioCodecArgs(task.targetFormat, encode));
    args.addAll(_streamMetadataArgs(encode));
    return args;
  }

  List<String> _videoFilters(
    ConversionTask task,
    HardwareVendor? hardwareVendor, {
    MediaFormat? format,
    EncodeOptions? encode,
  }) {
    format ??= _effectiveFormat(task);
    encode ??= task.encode;
    if (format.id == 'gif' ||
        format.id == 'webp' ||
        !formatSupportsAdvancedVideo(format.id)) {
      return _cpuVideoFilters(encode);
    }
    final encoder = resolveVideoEncoder(
      format.id,
      encode.videoEncoder,
      hardwareAcceleration: encode.hardwareDecode,
      hardwareVendor: hardwareVendor,
    );
    if (!_usesHardwareFrames(encoder, encode)) {
      final filters = _cpuVideoFilters(encode);
      if (encoder == VideoEncoderChoice.h264Vaapi ||
          encoder == VideoEncoderChoice.h265Vaapi) {
        return [...filters, 'format=nv12', 'hwupload'];
      }
      return filters;
    }
    if (encoder == VideoEncoderChoice.h264Qsv ||
        encoder == VideoEncoderChoice.h265Qsv) {
      final filter = _qsvVideoFilter(encode);
      return filter == null ? const [] : [filter];
    }
    if (encoder == VideoEncoderChoice.h264Nvenc ||
        encoder == VideoEncoderChoice.h265Nvenc) {
      return _cudaVideoFilters(encode);
    }
    if (encoder == VideoEncoderChoice.h264Vaapi ||
        encoder == VideoEncoderChoice.h265Vaapi) {
      return _vaapiVideoFilters(encode);
    }
    if (encoder == VideoEncoderChoice.h264Videotoolbox ||
        encoder == VideoEncoderChoice.h265Videotoolbox) {
      return const [];
    }
    final amf = _amfScaleFilter(encode);
    return amf == null ? const [] : [amf];
  }

  List<String> _cpuVideoFilters(EncodeOptions encode) {
    final filters = <String>[];
    switch (encode.rotation) {
      case VideoRotation.none:
        break;
      case VideoRotation.clockwise:
        filters.add('transpose=1');
      case VideoRotation.counterClockwise:
        filters.add('transpose=2');
      case VideoRotation.half:
        filters.addAll(['hflip', 'vflip']);
    }
    if (encode.flipHorizontal) {
      filters.add('hflip');
    }
    if (encode.flipVertical) {
      filters.add('vflip');
    }
    final scale = _scaleFilter(encode);
    if (scale != null) {
      filters.add(scale);
    }
    switch (encode.deinterlace) {
      case DeinterlaceMode.off:
        break;
      case DeinterlaceMode.yadif:
        filters.add('yadif');
      case DeinterlaceMode.yadifDouble:
        filters.add('yadif=1');
    }
    return filters;
  }

  String? _qsvVideoFilter(EncodeOptions encode) {
    final options = <String>[];
    final size = _hardwareScale(encode);
    if (size != null) {
      options.add('w=${size.$1}:h=${size.$2}');
    }
    final transpose = switch (encode.rotation) {
      VideoRotation.none => null,
      VideoRotation.clockwise => '1',
      VideoRotation.counterClockwise => '2',
      VideoRotation.half => '4',
    };
    if (transpose != null) {
      options.add('transpose=$transpose');
    } else if (encode.flipHorizontal) {
      options.add('transpose=5');
    } else if (encode.flipVertical) {
      options.add('transpose=6');
    }
    switch (encode.deinterlace) {
      case DeinterlaceMode.off:
        break;
      case DeinterlaceMode.yadif:
        options.add('deinterlace=advanced');
      case DeinterlaceMode.yadifDouble:
        options.add('deinterlace=advanced:rate=field');
    }
    if (options.isEmpty) {
      return null;
    }
    return 'vpp_qsv=${options.join(':')}';
  }

  List<String> _cudaVideoFilters(EncodeOptions encode) {
    final filters = <String>[];
    final scale = _cudaScaleFilter(encode);
    if (scale != null) {
      filters.add(scale);
    }
    switch (encode.deinterlace) {
      case DeinterlaceMode.off:
        break;
      case DeinterlaceMode.yadif:
        filters.add('yadif_cuda=mode=send_frame');
      case DeinterlaceMode.yadifDouble:
        filters.add('yadif_cuda=mode=send_field');
    }
    return filters;
  }

  String? _cudaScaleFilter(EncodeOptions encode) {
    final size = _hardwareScale(encode);
    if (size == null) {
      return null;
    }
    final algorithm = switch (encode.scaleFlags) {
      ScaleFlags.bilinear => ':interp_algo=bilinear',
      ScaleFlags.bicubic => ':interp_algo=bicubic',
      ScaleFlags.lanczos => ':interp_algo=lanczos',
      ScaleFlags.auto => '',
    };
    final ratio = encode.keepAspectRatio && encode.width != null && encode.height != null
        ? ':force_original_aspect_ratio=decrease:force_divisible_by=2'
        : '';
    return 'cudascale=w=${size.$1}:h=${size.$2}$algorithm$ratio';
  }

  List<String> _vaapiVideoFilters(EncodeOptions encode) {
    final filters = <String>[];
    switch (encode.deinterlace) {
      case DeinterlaceMode.off:
        break;
      case DeinterlaceMode.yadif:
        filters.add('deinterlace_vaapi');
      case DeinterlaceMode.yadifDouble:
        filters.add('deinterlace_vaapi=rate=field');
    }
    final scale = _vaapiScaleFilter(encode);
    if (scale != null) {
      filters.add(scale);
    }
    return filters;
  }

  String? _vaapiScaleFilter(EncodeOptions encode) {
    final size = _hardwareScale(encode);
    if (size == null) {
      return null;
    }
    return 'scale_vaapi=w=${size.$1}:h=${size.$2}';
  }

  String? _amfScaleFilter(EncodeOptions encode) {
    final size = _hardwareScale(encode);
    if (size == null) {
      return null;
    }
    final algorithm = encode.scaleFlags == ScaleFlags.bicubic ? 'bicubic' : 'bilinear';
    final ratio = encode.keepAspectRatio && encode.width != null && encode.height != null
        ? ':force_original_aspect_ratio=decrease:force_divisible_by=2'
        : '';
    return 'vpp_amf=w=${size.$1}:h=${size.$2}:scale_type=$algorithm$ratio';
  }

  (String, String)? _hardwareScale(EncodeOptions encode) {
    if (encode.width == null && encode.height == null) {
      return null;
    }
    final width = encode.width;
    final height = encode.height;
    if (width != null && height == null) {
      return ('${_even(width)}', '-2');
    }
    if (width == null && height != null) {
      return ('-2', '${_even(height)}');
    }
    return ('${_even(width!)}', '${_even(height!)}');
  }

  List<String> _audioFilterArgs(EncodeOptions encode) {
    if (encode.loudnessNormalize) {
      return const ['-af', 'loudnorm=I=-16:TP=-1.5:LRA=11'];
    }
    if (encode.volumeDb == 0) {
      return const [];
    }
    return ['-af', 'volume=${_trimNumber(encode.volumeDb)}dB'];
  }

  List<String> _streamMetadataArgs(EncodeOptions encode) {
    final args = <String>[
      '-map_metadata',
      encode.keepMetadata ? '0' : '-1',
      '-map_chapters',
      encode.keepChapters ? '0' : '-1',
    ];
    void addMetadata(String key, String value) {
      final clean = value.replaceAll(RegExp(r'[\r\n]'), ' ').trim();
      if (clean.isEmpty) {
        return;
      }
      args.addAll(['-metadata', '$key=$clean']);
    }

    addMetadata('title', encode.title);
    addMetadata('artist', encode.artist);
    addMetadata('album', encode.album);
    addMetadata('date', encode.year);
    addMetadata('comment', encode.comment);
    return args;
  }

  String? _scaleFilter(EncodeOptions encode) {
    if (encode.width == null && encode.height == null) {
      return null;
    }
    final width = encode.width;
    final height = encode.height;
    final flag = encode.scaleFlags == ScaleFlags.auto
        ? ''
        : ':flags=${encode.scaleFlags.name}';
    if (encode.keepAspectRatio) {
      if (width != null && height != null) {
        return 'scale=${_even(width)}:${_even(height)}:force_original_aspect_ratio=decrease$flag,scale=trunc(iw/2)*2:trunc(ih/2)*2';
      }
      if (width != null) {
        return 'scale=${_even(width)}:-2$flag';
      }
      return 'scale=-2:${_even(height!)}$flag';
    }
    return 'scale=${width != null ? _even(width) : -2}:${height != null ? _even(height) : -2}$flag';
  }

  List<String> _videoCodecArgs(
    MediaFormat format,
    EncodeOptions encode,
    HardwareVendor? hardwareVendor,
  ) {
    if (formatSupportsAdvancedVideo(format.id)) {
      return _advancedVideoArgs(format, encode, hardwareVendor);
    }
    switch (format.id) {
      case 'avi':
        return [
          '-c:v',
          'mpeg4',
          '-q:v',
          encode.qualityPreset == QualityPreset.higher
              ? '3'
              : encode.qualityPreset == QualityPreset.smaller
              ? '8'
              : '5',
          if (encode.videoBitrateKbps != null) ...[
            '-b:v',
            '${encode.videoBitrateKbps}k',
          ],
        ];
      case 'wmv':
        return [
          '-c:v',
          'wmv2',
          '-q:v',
          encode.qualityPreset == QualityPreset.higher
              ? '2'
              : encode.qualityPreset == QualityPreset.smaller
              ? '8'
              : '4',
        ];
      case 'mpeg':
        return [
          '-c:v',
          'mpeg2video',
          '-b:v',
          '${encode.videoBitrateKbps ?? 6000}k',
        ];
      case 'ogv':
        return [
          '-c:v',
          'libtheora',
          '-q:v',
          encode.qualityPreset == QualityPreset.higher
              ? '8'
              : encode.qualityPreset == QualityPreset.smaller
              ? '4'
              : '6',
        ];
      default:
        return const ['-c:v', 'libx264'];
    }
  }

  List<String> _advancedVideoArgs(
    MediaFormat format,
    EncodeOptions encode,
    HardwareVendor? hardwareVendor,
  ) {
    final encoder = resolveVideoEncoder(
      format.id,
      encode.videoEncoder,
      hardwareAcceleration: encode.hardwareDecode,
      hardwareVendor: hardwareVendor,
    );
    final codec = switch (encoder) {
      VideoEncoderChoice.h265 => 'libx265',
      VideoEncoderChoice.h264Nvenc => 'h264_nvenc',
      VideoEncoderChoice.h265Nvenc => 'hevc_nvenc',
      VideoEncoderChoice.h264Amf => 'h264_amf',
      VideoEncoderChoice.h265Amf => 'hevc_amf',
      VideoEncoderChoice.h264Qsv => 'h264_qsv',
      VideoEncoderChoice.h265Qsv => 'hevc_qsv',
      VideoEncoderChoice.h264Vaapi => 'h264_vaapi',
      VideoEncoderChoice.h265Vaapi => 'hevc_vaapi',
      VideoEncoderChoice.h264Videotoolbox => 'h264_videotoolbox',
      VideoEncoderChoice.h265Videotoolbox => 'hevc_videotoolbox',
      VideoEncoderChoice.vp9 => 'libvpx-vp9',
      VideoEncoderChoice.av1 => 'libaom-av1',
      _ => 'libx264',
    };
    final args = <String>['-c:v', codec];
    final legacyPreset = encode.speed == EncoderSpeed.auto &&
            encode.qualityPreset == QualityPreset.smaller
        ? 'fast'
        : null;
    switch (encoder) {
      case VideoEncoderChoice.h264:
      case VideoEncoderChoice.h265:
      case VideoEncoderChoice.auto:
        final preset =
            resolvedX26xPreset(encode.speed) ?? legacyPreset ?? 'medium';
        args.addAll(['-preset', preset]);
        if (encoder != VideoEncoderChoice.h265 &&
            encode.tune != VideoTune.auto &&
            encode.tune != VideoTune.film) {
          args.addAll(['-tune', encode.tune.name]);
        } else if (encoder == VideoEncoderChoice.h265 &&
            encode.tune != VideoTune.auto &&
            encode.tune != VideoTune.stillimage) {
          args.addAll(['-tune', encode.tune.name]);
        }
        if (encoder != VideoEncoderChoice.h265 &&
            (format.id == 'flv' || format.id == '3gp')) {
          args.addAll(['-profile:v', 'baseline', '-level', '3.0']);
        } else if (encoder != VideoEncoderChoice.h265 &&
            encode.h264Profile != H264ProfileChoice.auto) {
          args.addAll(['-profile:v', encode.h264Profile.name]);
        }
      case VideoEncoderChoice.h264Nvenc:
      case VideoEncoderChoice.h265Nvenc:
        final preset = resolvedNvencPreset(encode.speed);
        if (preset != null) {
          args.addAll(['-preset', preset]);
        }
        if (encode.tune == VideoTune.zerolatency) {
          args.addAll(['-tune', 'll']);
        } else if (encode.tune == VideoTune.fastdecode) {
          args.addAll(['-tune', 'ull']);
        }
      case VideoEncoderChoice.h264Qsv:
      case VideoEncoderChoice.h265Qsv:
        final preset = resolvedQsvPreset(encode.speed);
        if (preset != null) {
          args.addAll(['-preset', preset]);
        }
      case VideoEncoderChoice.h264Amf:
      case VideoEncoderChoice.h265Amf:
        final preset = resolvedAmfPreset(encode.speed);
        if (preset != null) {
          args.addAll(['-quality', preset]);
        }
      case VideoEncoderChoice.h264Vaapi:
      case VideoEncoderChoice.h265Vaapi:
        break;
      case VideoEncoderChoice.h264Videotoolbox:
      case VideoEncoderChoice.h265Videotoolbox:
        args.addAll(['-allow_sw', '1']);
        if (encode.tune == VideoTune.zerolatency) {
          args.addAll(['-realtime', '1']);
        }
      case VideoEncoderChoice.vp9:
        final deadline = resolvedVp9Deadline(encode.speed);
        if (deadline != null) {
          args.addAll(['-deadline', deadline]);
        }
      case VideoEncoderChoice.av1:
        final cpu = resolvedAv1CpuUsed(encode.speed);
        if (cpu != null) {
          args.addAll(['-cpu-used', '$cpu']);
        }
    }
    final pixFmt = _pixelFormatArg(format, encoder, encode);
    if (pixFmt != null) {
      args.addAll(['-pix_fmt', pixFmt]);
    }
    args.addAll(_rateControlArgs(encoder, encode));
    if (format.id == 'mp4' || format.id == 'mov') {
      if (encode.fastStart) {
        args.addAll(['-movflags', '+faststart']);
      }
    }
    return args;
  }

  String? _pixelFormatArg(
    MediaFormat format,
    VideoEncoderChoice encoder,
    EncodeOptions encode,
  ) {
    if (encode.pixelFormat == PixelFormatChoice.yuv420p10 &&
        tenBitFormats.contains(format.id) &&
        encoderSupportsTenBit(encoder)) {
      return 'yuv420p10le';
    }
    if (encoder == VideoEncoderChoice.h264 ||
        encoder == VideoEncoderChoice.auto ||
        encode.pixelFormat == PixelFormatChoice.yuv420p) {
      return 'yuv420p';
    }
    return null;
  }

  List<String> _qualityArgs(VideoEncoderChoice encoder, int crf) {
    if (encoder == VideoEncoderChoice.vp9 || encoder == VideoEncoderChoice.av1) {
      return ['-crf', '$crf', '-b:v', '0'];
    }
    if (encoder == VideoEncoderChoice.h264Amf ||
        encoder == VideoEncoderChoice.h265Amf) {
      return ['-rc', 'qvbr', '-qvbr_quality_level', '$crf'];
    }
    if (encoder == VideoEncoderChoice.h264Qsv ||
        encoder == VideoEncoderChoice.h265Qsv) {
      return ['-global_quality', '${crf == 0 ? 1 : crf}'];
    }
    if (encoder == VideoEncoderChoice.h264Nvenc ||
        encoder == VideoEncoderChoice.h265Nvenc) {
      final quality = crf == 0 ? qualityToCrf(QualityPreset.higher) : crf;
      return ['-rc', 'vbr', '-cq', '$quality', '-b:v', '0'];
    }
    if (encoder == VideoEncoderChoice.h264Vaapi ||
        encoder == VideoEncoderChoice.h265Vaapi) {
      return ['-rc_mode', 'CQP', '-qp', '${crf == 0 ? 18 : crf}'];
    }
    if (encoder == VideoEncoderChoice.h264Videotoolbox ||
        encoder == VideoEncoderChoice.h265Videotoolbox) {
      final quality = crf == 0 ? qualityToCrf(QualityPreset.higher) : crf;
      return ['-q:v', '$quality'];
    }
    return ['-crf', '$crf'];
  }

  List<String> _rateControlArgs(VideoEncoderChoice encoder, EncodeOptions encode) {
    final crf = (encode.crf ?? qualityToCrf(encode.qualityPreset)).clamp(
      0,
      crfUpperBound(encoder),
    );
    final target = encode.videoBitrateKbps;
    if (encode.rateControl == RateControlMode.quality || target == null) {
      return _qualityArgs(encoder, crf);
    }
    final args = <String>[];
    if (encoder == VideoEncoderChoice.h264Amf ||
        encoder == VideoEncoderChoice.h265Amf) {
      args.addAll([
        '-rc',
        encode.rateControl == RateControlMode.cbr ? 'cbr' : 'vbr_peak',
      ]);
    }
    args.addAll(['-b:v', '${target}k']);
    if (encode.rateControl == RateControlMode.cbr) {
      final buffer = encode.bufSizeKbps ?? target * 2;
      args.addAll([
        '-minrate',
        '${target}k',
        '-maxrate',
        '${target}k',
        '-bufsize',
        '${buffer}k',
      ]);
    } else {
      if (encode.maxRateKbps != null) {
        args.addAll(['-maxrate', '${encode.maxRateKbps}k']);
      }
      if (encode.bufSizeKbps != null) {
        args.addAll(['-bufsize', '${encode.bufSizeKbps}k']);
      }
    }
    return args;
  }

  List<String> _audioCodecArgs(MediaFormat format, EncodeOptions encode) {
    final bitrate =
        encode.audioBitrateKbps ?? qualityToAudioBitrate(encode.qualityPreset);
    final useQuality = encode.audioRateMode == AudioRateMode.quality;
    switch (format.id) {
      case 'webm':
      case 'ogg':
      case 'ogv':
        return ['-c:a', 'libvorbis', '-b:a', '${bitrate}k'];
      case 'opus':
        return [
          '-c:a',
          'libopus',
          '-b:a',
          '${bitrate}k',
          '-vbr',
          encode.opusVbr.name,
          '-application',
          encode.opusApplication.name,
          ..._audioLayoutArgs(encode, opusSampleRates, allowSurround: true),
        ];
      case 'wav':
        return ['-c:a', 'pcm_s16le', ..._audioLayoutArgs(encode, supportedSampleRates)];
      case 'aiff':
      case 'caf':
        return ['-c:a', 'pcm_s16be', ..._audioLayoutArgs(encode, supportedSampleRates)];
      case 'flac':
        return [
          '-c:a',
          'flac',
          '-compression_level',
          '${encode.flacCompression.clamp(0, 12)}',
          ..._audioLayoutArgs(encode, supportedSampleRates, allowSurround: true),
        ];
      case 'mp3':
        return [
          '-c:a',
          'libmp3lame',
          if (useQuality) ...['-q:a', '${(encode.audioQuality ?? 4).clamp(0, 9)}']
          else ...['-b:a', '${bitrate}k'],
          ..._audioLayoutArgs(encode, mp3SampleRates),
        ];
      case 'mp2':
        return ['-c:a', 'mp2', '-b:a', '${bitrate}k', ..._audioLayoutArgs(encode, mp3SampleRates)];
      case 'ac3':
        return [
          '-c:a',
          'ac3',
          '-b:a',
          '${bitrate}k',
          ..._audioLayoutArgs(encode, supportedSampleRates, allowSurround: true),
        ];
      case 'wma':
      case 'wmv':
        return ['-c:a', 'wmav2', '-b:a', '${bitrate}k', ..._audioLayoutArgs(encode, mp3SampleRates)];
      case 'wv':
        return ['-c:a', 'wavpack', ..._audioLayoutArgs(encode, supportedSampleRates)];
      case 'tta':
        return ['-c:a', 'tta', ..._audioLayoutArgs(encode, supportedSampleRates)];
      case 'spx':
        return ['-c:a', 'libspeex', '-b:a', '${bitrate}k', ..._audioLayoutArgs(encode, mp3SampleRates)];
      case 'amr':
        return [
          '-c:a',
          'libopencore_amrnb',
          '-ar',
          '8000',
          '-ac',
          '1',
          '-b:a',
          '12.2k',
        ];
      case 'alac':
        return ['-c:a', 'alac', ..._audioLayoutArgs(encode, aacSampleRates)];
      case 'mpeg':
      case 'ts':
      case 'm2ts':
        return [
          '-c:a',
          'ac3',
          '-b:a',
          '${bitrate}k',
          ..._audioLayoutArgs(encode, supportedSampleRates, allowSurround: true),
        ];
      case 'flv':
      case '3gp':
        return [
          '-c:a',
          'aac',
          '-b:a',
          '${bitrate}k',
          '-ar',
          '44100',
          '-ac',
          '2',
        ];
      case 'aac':
      case 'm4a':
        return [
          '-c:a',
          'aac',
          if (useQuality) ...['-q:a', '${(encode.audioQuality ?? 2).clamp(1, 5)}']
          else ...['-b:a', '${bitrate}k'],
          ..._audioLayoutArgs(encode, aacSampleRates),
        ];
      default:
        return [
          '-c:a',
          'aac',
          if (useQuality) ...['-q:a', '${(encode.audioQuality ?? 2).clamp(1, 5)}']
          else ...['-b:a', '${bitrate}k'],
          ..._audioLayoutArgs(encode, aacSampleRates),
        ];
    }
  }

  List<String> _audioLayoutArgs(
    EncodeOptions encode,
    List<int> sampleRates, {
    bool allowSurround = false,
  }) {
    final args = <String>[];
    final sampleRate = nearestSampleRate(encode.sampleRate, sampleRates);
    if (sampleRate != null) {
      args.addAll(['-ar', '$sampleRate']);
    }
    if (encode.channels != null) {
      final channels = !allowSurround && encode.channels! > 2 ? 2 : encode.channels!;
      args.addAll(['-ac', '$channels']);
    }
    return args;
  }

  int _even(int value) {
    if (value <= 0) {
      return 2;
    }
    return value.isEven ? value : value - 1;
  }

  String _trimNumber(double value) {
    if (value == value.roundToDouble()) {
      return value.toStringAsFixed(0);
    }
    return value.toString();
  }
}


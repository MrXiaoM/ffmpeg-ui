import 'dart:io';

import 'package:ffmpeg_ui/core/ffmpeg/command_builder.dart';
import 'package:ffmpeg_ui/core/ffmpeg/ffmpeg_locator.dart';
import 'package:ffmpeg_ui/core/ffmpeg/hardware_probe.dart';
import 'package:ffmpeg_ui/core/ffmpeg/progress_parser.dart';
import 'package:ffmpeg_ui/core/ffmpeg/thumbnail_service.dart';
import 'package:ffmpeg_ui/core/models/clip_range.dart';
import 'package:ffmpeg_ui/core/models/conversion_task.dart';
import 'package:ffmpeg_ui/core/models/encode_options.dart';
import 'package:ffmpeg_ui/core/platform/fs_paths.dart';
import 'package:path/path.dart' as p;
import 'package:ffmpeg_ui/core/l10n/app_language.dart';
import 'package:ffmpeg_ui/core/l10n/app_messages.dart';
import 'package:ffmpeg_ui/core/l10n/labels.dart';
import 'package:ffmpeg_ui/core/models/app_settings.dart';
import 'package:ffmpeg_ui/core/models/media_format.dart';
import 'package:ffmpeg_ui/core/models/media_info.dart';
import 'package:ffmpeg_ui/core/models/subtitle_track.dart';
import 'package:ffmpeg_ui/core/settings/settings_repository.dart';
import 'package:ffmpeg_ui/l10n/app_localizations.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('hardware capabilities stay unprobed until detect finishes', () {
    expect(const HardwareCapabilities.unknown().isProbed, isFalse);
    expect(const HardwareCapabilities.unknown().anyAvailable, isFalse);
    expect(
      const HardwareCapabilities(
        nvidia: HardwareEncoderStatus(
          vendor: HardwareVendor.nvidia,
          status: HardwareProbeStatus.unavailable,
        ),
        amd: HardwareEncoderStatus(
          vendor: HardwareVendor.amd,
          status: HardwareProbeStatus.unavailable,
        ),
        intel: HardwareEncoderStatus(
          vendor: HardwareVendor.intel,
          status: HardwareProbeStatus.unavailable,
        ),
        apple: HardwareEncoderStatus(
          vendor: HardwareVendor.apple,
          status: HardwareProbeStatus.unavailable,
        ),
        vaapi: HardwareEncoderStatus(
          vendor: HardwareVendor.vaapi,
          status: HardwareProbeStatus.unavailable,
        ),
      ).isProbed,
      isTrue,
    );
  });

  test('thumbnail capture scales down the still', () {
    expect(
      ThumbnailService.buildArguments(
        inputPath: r'C:\in\a.mov',
        outputPath: r'C:\tmp\a.jpg',
      ),
      containsAllInOrder(['-vf', r'scale=min(320\,iw):-2', '-q:v', '6']),
    );
  });

  test('720p preset keeps aspect ratio and even dimensions', () {
    final options = const EncodeOptions().applyPreset(OutputPreset.p720);
    expect(options.width, 1280);
    expect(options.height, 720);
    expect(options.keepAspectRatio, isTrue);
  });

  test('media path filter accepts common containers', () {
    expect(isMediaPath(r'C:\video\demo.MP4'), isTrue);
    expect(isMediaPath(r'C:\audio\song.flac'), isTrue);
    expect(isMediaPath(r'C:\notes\readme.txt'), isFalse);
  });

  test('embedded subtitle support follows the output container', () {
    ConversionTask task({
      required MediaFormat format,
      required String input,
    }) {
      return ConversionTask(
        id: 'subs',
        inputPath: input,
        outputDirectory: r'C:\out',
        outputFileName: 'a.mp4',
        targetFormat: format,
        createdAt: DateTime(2026, 1, 1),
      );
    }

    expect(
      task(format: MediaFormat.mkv, input: r'C:\in\a.avi').canEditSubtitles,
      isTrue,
    );
    expect(
      task(format: MediaFormat.mp4, input: r'C:\in\a.avi').canEditSubtitles,
      isTrue,
    );
    expect(
      task(format: MediaFormat.copyVideo, input: r'C:\in\a.mkv').canEditSubtitles,
      isTrue,
    );
    expect(
      task(format: MediaFormat.copyVideo, input: r'C:\in\a.mp4').canEditSubtitles,
      isTrue,
    );
    expect(
      task(format: MediaFormat.copyVideo, input: r'C:\in\a.avi').canEditSubtitles,
      isFalse,
    );
    expect(
      task(format: MediaFormat.gif, input: r'C:\in\a.mp4').canEditSubtitles,
      isFalse,
    );
    expect(
      task(format: MediaFormat.mp3, input: r'C:\in\a.mp4').canEditSubtitles,
      isFalse,
    );
    expect(
      task(
        format: MediaFormat.mkv,
        input: r'C:\in\a.mkv',
      ).copyWith(status: TaskStatus.running).canEditSubtitles,
      isFalse,
    );
    expect(task(format: MediaFormat.mkv, input: r'C:\in\a.mkv').hasSubtitleEdit, isFalse);
    expect(
      task(format: MediaFormat.mkv, input: r'C:\in\a.mkv')
          .copyWith(
            subtitleEdit: const SubtitleEdit(keepIndexes: [2]),
          )
          .hasSubtitleEdit,
      isTrue,
    );
  });

  test('keep original format follows the first file container', () {
    expect(keepOriginalFormatFor(r'C:\video\demo.MP4').id, 'copy-video');
    expect(keepOriginalFormatFor(r'C:\audio\song.flac').id, 'copy-audio');
    expect(sourceContainerFormatFor(r'C:\video\demo.MP4')?.id, 'mp4');
    expect(sourceContainerFormatFor(r'C:\audio\song.flac')?.id, 'flac');
    expect(
      effectiveEncodeFormat(MediaFormat.copyVideo, r'C:\video\demo.webm').id,
      'webm',
    );
  });

  test('output name template replaces {name} and fills the extension', () {
    final inputPath = p.join('in', 'demo.mov');
    expect(
      applyOutputNameTemplate(
        '{name}_converted',
        inputPath,
        extension: '.mp4',
      ),
      'demo_converted.mp4',
    );
    expect(
      applyOutputNameTemplate('', inputPath, extension: '.mp4'),
      'demo_converted.mp4',
    );
    expect(
      applyOutputNameTemplate('shared', inputPath, extension: '.mp4'),
      'shared.mp4',
    );
    expect(
      applyOutputNameTemplate(
        'demo_converted.mov',
        inputPath,
        extension: '.mp4',
      ),
      'demo_converted.mp4',
    );
  });

  test('progress parser reads out_time_us', () {
    final parser = FfmpegProgressParser(
      total: const Duration(seconds: 10),
    );
    parser.addLine('out_time_us=5000000');
    final snapshot = parser.addLine('progress=continue');
    expect(snapshot, isNotNull);
    expect(snapshot!.progress, closeTo(0.5, 0.001));
  });

  test('progress does not fall back to zero near completion', () {
    final parser = FfmpegProgressParser(
      total: const Duration(seconds: 10),
    );
    parser.addLine('out_time_us=9000000');
    parser.addLine('progress=continue');
    parser.addLine('out_time_us=N/A');
    final unavailable = parser.addLine('progress=continue');
    expect(unavailable!.progress, closeTo(0.9, 0.001));
    parser.addLine('out_time_us=-1');
    final negative = parser.addLine('progress=continue');
    expect(negative!.progress, closeTo(0.9, 0.001));
    final ended = parser.addLine('progress=end');
    expect(ended!.progress, 1);
  });

  test('command builder includes clip and scale for mp4', () {
    final task = ConversionTask(
      id: '1',
      inputPath: r'C:\in\a.mov',
      outputDirectory: r'C:\out',
      outputFileName: 'a_converted.mp4',
      targetFormat: MediaFormat.mp4,
      encode: const EncodeOptions().applyPreset(OutputPreset.p720),
      clipRange: const ClipRange(
        start: Duration(seconds: 1),
        end: Duration(seconds: 5),
        fps: 30,
      ),
      createdAt: DateTime(2026, 1, 1),
    );
    final command = const FfmpegCommandBuilder().build(
      ffmpegPath: r'C:\ffmpeg\ffmpeg.exe',
      task: task,
      outputPath: r'C:\out\a_converted.mp4',
    );
    expect(
      command.arguments,
      containsAllInOrder(['-ss', '1.000', '-to', '5.000', '-i']),
    );
    expect(command.arguments.any((item) => item.contains('scale=')), isTrue);
    expect(command.arguments, contains('libx264'));
  });

  test('niche formats use encoders available in the local ffmpeg', () {
    final builder = const FfmpegCommandBuilder();
    final cases = <MediaFormat, String>{
      MediaFormat.wmv: 'wmv2',
      MediaFormat.flv: 'libx264',
      MediaFormat.mpeg: 'mpeg2video',
      MediaFormat.ogv: 'libtheora',
      MediaFormat.webp: 'libwebp_anim',
      MediaFormat.ac3: 'ac3',
      MediaFormat.wma: 'wmav2',
      MediaFormat.wv: 'wavpack',
      MediaFormat.amr: 'libopencore_amrnb',
      MediaFormat.alac: 'alac',
    };
    for (final entry in cases.entries) {
      final task = ConversionTask(
        id: entry.key.id,
        inputPath: r'C:\in\a.mp4',
        outputDirectory: r'C:\out',
        outputFileName: 'a${entry.key.extension}',
        targetFormat: entry.key,
        encode: const EncodeOptions(),
        createdAt: DateTime(2026, 1, 1),
      );
      final command = builder.build(
        ffmpegPath: 'ffmpeg',
        task: task,
        outputPath: r'C:\out\a${entry.key.extension}',
      );
      expect(command.arguments, contains(entry.value));
    }
  });

  test('relative ffmpeg paths resolve from the application directory', () {
    final locator = FfmpegLocator();
    final relative = Platform.isWindows
        ? r'ffmpeg\bin\ffmpeg.exe'
        : 'ffmpeg/bin/ffmpeg';
    final resolved = locator.resolveForUse(relative);
    expect(p.isAbsolute(resolved), isTrue);
    expect(
      Platform.isWindows ? resolved.toLowerCase() : resolved,
      endsWith(relative),
    );
    expect(locator.storedPath(relative), relative);
  });

  test('path keys keep unix case and fold windows case', () {
    if (Platform.isWindows) {
      expect(pathKey(r'C:\Out\A.mp4'), pathKey(r'C:\out\a.mp4'));
      expect(joinFsPath(r'C:\out', 'a.mp4').toLowerCase(), r'c:\out\a.mp4');
    } else {
      expect(pathKey('/tmp/A.mp4') == pathKey('/tmp/a.mp4'), isFalse);
      expect(joinFsPath('/tmp/out', 'a.mp4'), '/tmp/out/a.mp4');
    }
  });

  test('rename presets insert the number before the extension', () {
    const settings = AppSettings(renamePattern: '_{n}');
    expect(settings.renameWithNumber('video', '.mp4', 2), 'video_2.mp4');
    expect(
      const AppSettings(renamePattern: ' ({n:2})').renameWithNumber(
        'video',
        '.mkv',
        3,
      ),
      'video (03).mkv',
    );
  });

  test('copy format keeps the source codec', () {
    final task = ConversionTask(
      id: 'copy',
      inputPath: r'C:\in\a.mkv',
      outputDirectory: r'C:\out',
      outputFileName: 'a_converted.mkv',
      targetFormat: MediaFormat.copyVideo,
      encode: const EncodeOptions(),
      createdAt: DateTime(2026, 1, 1),
    );
    final command = const FfmpegCommandBuilder().build(
      ffmpegPath: 'ffmpeg',
      task: task,
      outputPath: r'C:\out\a_converted.mkv',
    );
    expect(command.arguments, containsAllInOrder(['-c', 'copy']));
    expect(command.arguments, isNot(contains('libx264')));
    expect(MediaFormat.videoFormats.first.id, 'copy-video');
    expect(MediaFormat.audioFormats.first.id, 'copy-audio');
  });

  test('copy format scales with the source codec and copies audio', () {
    final task = ConversionTask(
      id: 'copy-scale',
      inputPath: r'C:\in\a.mkv',
      outputDirectory: r'C:\out',
      outputFileName: 'a_converted.mkv',
      targetFormat: MediaFormat.copyVideo,
      encode: const EncodeOptions().applyPreset(OutputPreset.p720),
      createdAt: DateTime(2026, 1, 1),
    );
    final command = const FfmpegCommandBuilder().build(
      ffmpegPath: 'ffmpeg',
      task: task,
      outputPath: r'C:\out\a_converted.mkv',
      mediaInfo: const MediaInfo(
        path: r'C:\in\a.mkv',
        hasVideo: true,
        hasAudio: true,
        videoCodec: 'hevc',
        audioCodec: 'aac',
      ),
    );
    expect(command.arguments.any((item) => item.contains('scale=')), isTrue);
    expect(command.arguments, containsAllInOrder(['-c:v', 'libx265']));
    expect(command.arguments, containsAllInOrder(['-c:a', 'copy']));
    expect(command.arguments, isNot(contains('libx264')));
  });

  test('copy format re-encodes audio only when volume changes', () {
    final task = ConversionTask(
      id: 'copy-audio',
      inputPath: r'C:\in\a.mkv',
      outputDirectory: r'C:\out',
      outputFileName: 'a_converted.mkv',
      targetFormat: MediaFormat.copyVideo,
      encode: const EncodeOptions(volumeDb: -3),
      createdAt: DateTime(2026, 1, 1),
    );
    final command = const FfmpegCommandBuilder().build(
      ffmpegPath: 'ffmpeg',
      task: task,
      outputPath: r'C:\out\a_converted.mkv',
      mediaInfo: const MediaInfo(
        path: r'C:\in\a.mkv',
        hasVideo: true,
        hasAudio: true,
        videoCodec: 'h264',
        audioCodec: 'aac',
      ),
    );
    expect(command.arguments, containsAllInOrder(['-c:v', 'copy']));
    expect(command.arguments, containsAllInOrder(['-c:a', 'aac']));
    expect(command.arguments, containsAllInOrder(['-af', 'volume=-3dB']));
    expect(command.arguments, isNot(containsAllInOrder(['-c', 'copy'])));
  });

  test('copy format uses the container encoder when the source codec is unknown', () {
    final task = ConversionTask(
      id: 'copy-unknown',
      inputPath: r'C:\in\a.mkv',
      outputDirectory: r'C:\out',
      outputFileName: 'a_converted.mkv',
      targetFormat: MediaFormat.copyVideo,
      encode: const EncodeOptions().applyPreset(OutputPreset.p720),
      createdAt: DateTime(2026, 1, 1),
    );
    final command = const FfmpegCommandBuilder().build(
      ffmpegPath: 'ffmpeg',
      task: task,
      outputPath: r'C:\out\a_converted.mkv',
      mediaInfo: const MediaInfo(
        path: r'C:\in\a.mkv',
        hasVideo: true,
        videoCodec: 'prores',
      ),
    );
    expect(command.arguments.any((item) => item.contains('scale=')), isTrue);
    expect(command.arguments, containsAllInOrder(['-c:v', 'libx264']));
    expect(command.arguments, containsAllInOrder(['-c:a', 'copy']));
  });

  test('copy format re-encodes when encoder options change', () {
    final task = ConversionTask(
      id: 'copy-speed',
      inputPath: r'C:\in\a.mkv',
      outputDirectory: r'C:\out',
      outputFileName: 'a_converted.mkv',
      targetFormat: MediaFormat.copyVideo,
      encode: const EncodeOptions(
        speed: EncoderSpeed.fast,
        videoEncoder: VideoEncoderChoice.h264,
      ),
      createdAt: DateTime(2026, 1, 1),
    );
    final command = const FfmpegCommandBuilder().build(
      ffmpegPath: 'ffmpeg',
      task: task,
      outputPath: r'C:\out\a_converted.mkv',
      mediaInfo: const MediaInfo(
        path: r'C:\in\a.mkv',
        hasVideo: true,
        hasAudio: true,
        videoCodec: 'hevc',
        audioCodec: 'aac',
      ),
    );
    expect(command.arguments, containsAllInOrder(['-c:v', 'libx264']));
    expect(command.arguments, containsAllInOrder(['-preset', 'veryfast']));
    expect(command.arguments, containsAllInOrder(['-c:a', 'copy']));
    expect(command.arguments, isNot(containsAllInOrder(['-c', 'copy'])));
  });

  test('subtitle edit maps kept or added tracks onto copy-video', () {
    final task = ConversionTask(
      id: 'subs-copy',
      inputPath: r'C:\in\a.mkv',
      outputDirectory: r'C:\out',
      outputFileName: 'a.mkv',
      targetFormat: MediaFormat.copyVideo,
      subtitleEdit: SubtitleEdit(
        keepIndexes: const [2],
        additions: const [
          SubtitleAddition(path: r'C:\in\zh.srt', language: 'chi'),
        ],
      ),
      createdAt: DateTime(2026, 1, 1),
    );
    final command = const FfmpegCommandBuilder().build(
      ffmpegPath: 'ffmpeg',
      task: task,
      outputPath: r'C:\out\a.mkv',
    );
    expect(command.arguments, containsAllInOrder(['-c:v', 'copy']));
    expect(command.arguments, containsAllInOrder(['-c:a', 'copy']));
    expect(command.arguments, containsAllInOrder(['-map', '0:v']));
    expect(command.arguments, containsAllInOrder(['-map', '0:2']));
    expect(command.arguments, containsAllInOrder(['-map', '1:0']));
    expect(command.arguments, containsAllInOrder(['-c:s', 'srt']));
    expect(command.arguments, contains('language=chi'));
    expect(command.arguments, isNot(contains('0:s?')));
    expect(command.arguments, isNot(contains('libx264')));
  });

  test('subtitle edit keeps video encoding and clip range', () {
    final task = ConversionTask(
      id: 'subs-encode',
      inputPath: r'C:\in\a.mov',
      outputDirectory: r'C:\out',
      outputFileName: 'a.mp4',
      targetFormat: MediaFormat.mp4,
      encode: const EncodeOptions(videoEncoder: VideoEncoderChoice.h264),
      clipRange: const ClipRange(
        start: Duration(seconds: 1),
        end: Duration(seconds: 5),
        fps: 30,
      ),
      subtitleEdit: SubtitleEdit(
        keepIndexes: const [2],
        additions: const [
          SubtitleAddition(path: r'C:\in\zh.srt', language: 'chi'),
        ],
      ),
      createdAt: DateTime(2026, 1, 1),
    );
    final command = const FfmpegCommandBuilder().build(
      ffmpegPath: 'ffmpeg',
      task: task,
      outputPath: r'C:\out\a.mp4',
    );
    expect(
      command.arguments,
      containsAllInOrder(['-ss', '1.000', '-to', '5.000', '-i']),
    );
    expect(command.arguments, contains('libx264'));
    expect(command.arguments, containsAllInOrder(['-map', '0:v']));
    expect(command.arguments, containsAllInOrder(['-map', '0:2']));
    expect(command.arguments, containsAllInOrder(['-map', '1:0']));
    expect(command.arguments, containsAllInOrder(['-c:s', 'mov_text']));
    expect(command.arguments, contains('language=chi'));
  });

  test('advanced options select encoder, rate control, filters and metadata', () {
    final task = ConversionTask(
      id: 'advanced',
      inputPath: r'C:\in\a.mov',
      outputDirectory: r'C:\out',
      outputFileName: 'a.mp4',
      targetFormat: MediaFormat.mp4,
      encode: const EncodeOptions(
        videoEncoder: VideoEncoderChoice.h265,
        speed: EncoderSpeed.slow,
        tune: VideoTune.animation,
        rateControl: RateControlMode.vbr,
        videoBitrateKbps: 5000,
        maxRateKbps: 8000,
        rotation: VideoRotation.clockwise,
        deinterlace: DeinterlaceMode.yadif,
        loudnessNormalize: true,
        title: '示例\n标题',
        keepChapters: false,
      ),
      createdAt: DateTime(2026, 1, 1),
    );
    final command = const FfmpegCommandBuilder().build(
      ffmpegPath: 'ffmpeg',
      task: task,
      outputPath: r'C:\out\a.mp4',
    );
    expect(
      command.arguments,
      containsAllInOrder(['-c:v', 'libx265', '-preset', 'slow', '-tune', 'animation']),
    );
    expect(command.arguments, containsAllInOrder(['-b:v', '5000k', '-maxrate', '8000k']));
    expect(command.arguments.any((item) => item.contains('transpose=1')), isTrue);
    expect(command.arguments.any((item) => item.contains('yadif')), isTrue);
    expect(command.arguments, contains('loudnorm=I=-16:TP=-1.5:LRA=11'));
    expect(command.arguments, contains('title=示例 标题'));
    expect(command.arguments, containsAllInOrder(['-map_chapters', '-1']));
  });

  test('hardware encoders use vendor quality controls and filters', () {
    final builder = const FfmpegCommandBuilder();
    final nvidia = builder.build(
      ffmpegPath: 'ffmpeg',
      task: _videoTask(
        const EncodeOptions(
          hardwareDecode: true,
          crf: 0,
          width: 1280,
          height: 720,
          deinterlace: DeinterlaceMode.yadif,
        ),
      ),
      outputPath: r'C:\out\a.mp4',
      hardwareVendor: HardwareVendor.nvidia,
    );
    expect(
      nvidia.arguments,
      containsAllInOrder(['-hwaccel', 'cuda', '-hwaccel_output_format', 'cuda']),
    );
    expect(nvidia.arguments, containsAllInOrder(['-c:v', 'h264_nvenc']));
    expect(nvidia.arguments, containsAllInOrder(['-cq', '18', '-b:v', '0']));
    expect(
      nvidia.arguments.any((item) => item.startsWith('cudascale=')),
      isTrue,
    );
    expect(
      nvidia.arguments.any((item) => item.contains('yadif_cuda=mode=send_frame')),
      isTrue,
    );

    final intel = builder.build(
      ffmpegPath: 'ffmpeg',
      task: _videoTask(
        const EncodeOptions(
          hardwareDecode: true,
          rotation: VideoRotation.clockwise,
          scaleFlags: ScaleFlags.lanczos,
        ),
      ),
      outputPath: r'C:\out\a.mp4',
      hardwareVendor: HardwareVendor.intel,
    );
    expect(intel.arguments, containsAllInOrder(['-hwaccel', 'qsv']));
    expect(intel.arguments, containsAllInOrder(['-c:v', 'h264_qsv']));
    expect(intel.arguments, containsAllInOrder(['-global_quality', '23']));
    expect(intel.arguments.any((item) => item.contains('vpp_qsv=')), isTrue);

    final amd = builder.build(
      ffmpegPath: 'ffmpeg',
      task: _videoTask(
        const EncodeOptions(
          hardwareDecode: true,
          rotation: VideoRotation.clockwise,
          width: 640,
        ),
      ),
      outputPath: r'C:\out\a.mp4',
      hardwareVendor: HardwareVendor.amd,
    );
    expect(amd.arguments, isNot(contains('d3d11')));
    expect(amd.arguments.any((item) => item.contains('transpose=1')), isTrue);
    expect(amd.arguments.any((item) => item.contains('scale=')), isTrue);
    expect(
      amd.arguments,
      containsAllInOrder(['-rc', 'qvbr', '-qvbr_quality_level', '23']),
    );
  });

  test('linux vaapi uses hardware frames and quality controls', () {
    final command = const FfmpegCommandBuilder().build(
      ffmpegPath: 'ffmpeg',
      task: _videoTask(
        const EncodeOptions(
          hardwareDecode: true,
          videoEncoder: VideoEncoderChoice.h264Vaapi,
          width: 1280,
          height: 720,
          deinterlace: DeinterlaceMode.yadif,
        ),
      ),
      outputPath: '/tmp/a.mp4',
      hardwareVendor: HardwareVendor.vaapi,
    );
    expect(
      command.arguments,
      containsAllInOrder([
        '-hwaccel',
        'vaapi',
        '-hwaccel_device',
        '/dev/dri/renderD128',
        '-hwaccel_output_format',
        'vaapi',
      ]),
    );
    expect(command.arguments, containsAllInOrder(['-c:v', 'h264_vaapi']));
    expect(command.arguments, containsAllInOrder(['-rc_mode', 'CQP', '-qp', '23']));
    expect(
      command.arguments.any((item) => item.contains('deinterlace_vaapi')),
      isTrue,
    );
    expect(
      command.arguments.any((item) => item.contains('scale_vaapi=')),
      isTrue,
    );
  });

  test('macos videotoolbox keeps software filters when scaling', () {
    final scaled = const FfmpegCommandBuilder().build(
      ffmpegPath: 'ffmpeg',
      task: _videoTask(
        const EncodeOptions(
          hardwareDecode: true,
          videoEncoder: VideoEncoderChoice.h264Videotoolbox,
          width: 1280,
          height: 720,
        ),
      ),
      outputPath: '/tmp/a.mp4',
      hardwareVendor: HardwareVendor.apple,
    );
    expect(scaled.arguments, isNot(contains('-hwaccel')));
    expect(scaled.arguments, containsAllInOrder(['-c:v', 'h264_videotoolbox']));
    expect(scaled.arguments.any((item) => item.contains('scale=')), isTrue);
    expect(scaled.arguments, containsAllInOrder(['-q:v', '23']));

    final copy = const FfmpegCommandBuilder().build(
      ffmpegPath: 'ffmpeg',
      task: _videoTask(
        const EncodeOptions(
          hardwareDecode: true,
          videoEncoder: VideoEncoderChoice.h264Videotoolbox,
        ),
      ),
      outputPath: '/tmp/a.mp4',
      hardwareVendor: HardwareVendor.apple,
    );
    expect(copy.arguments, containsAllInOrder(['-hwaccel', 'videotoolbox']));
  });

  test('hardware decode stays off until the task enables it', () {
    final command = const FfmpegCommandBuilder().build(
      ffmpegPath: 'ffmpeg',
      task: _videoTask(
        const EncodeOptions(videoEncoder: VideoEncoderChoice.h264Nvenc),
      ),
      outputPath: r'C:\out\a.mp4',
    );
    expect(command.arguments, isNot(contains('-hwaccel')));
    final saved = EncodeOptions.fromJson(const EncodeOptions().toJson());
    expect(saved.hardwareDecode, isFalse);
  });

  test('legacy bitrate options stay on variable bitrate', () {
    final options = EncodeOptions.fromJson({
      'videoBitrateKbps': 2500,
      'qualityPreset': 'standard',
    });
    expect(options.rateControl, RateControlMode.vbr);
    expect(options.speed, EncoderSpeed.auto);
  });

  test('frame stepping uses fps', () {
    final next = stepByFrame(Duration.zero, 25, 1);
    expect(next.inMicroseconds, 40000);
  });

  test('system language maps Chinese regions and falls back to English', () {
    expect(localeFromSystem(const Locale('zh', 'CN')), const Locale('zh', 'CN'));
    expect(localeFromSystem(const Locale('zh', 'SG')), const Locale('zh', 'CN'));
    expect(localeFromSystem(const Locale('zh', 'HK')), const Locale('zh', 'HK'));
    expect(localeFromSystem(const Locale('zh', 'MO')), const Locale('zh', 'HK'));
    expect(localeFromSystem(const Locale('zh', 'TW')), const Locale('zh', 'TW'));
    expect(localeFromSystem(const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant')), const Locale('zh', 'TW'));
    expect(localeFromSystem(const Locale('zh')), const Locale('zh', 'CN'));
    expect(localeFromSystem(const Locale('ja')), const Locale('en'));
    expect(localeFromSystem(const Locale('und')), const Locale('en'));
    expect(localeFromSystem(null), const Locale('en'));
    expect(
      resolveAppLocale(AppLanguage.system, const Locale('fr')),
      const Locale('en'),
    );
    expect(
      resolveAppLocale(AppLanguage.zhTw, const Locale('en')),
      const Locale('zh', 'TW'),
    );
    expect(fluentAppLocale(AppLanguage.system), isNull);
    expect(fluentAppLocale(AppLanguage.en), const Locale('en'));
    expect(AppLanguage.zhCn.nativeName, '简体中文（中国大陆）');
    expect(AppLanguage.zhHk.nativeName, '繁体中文（香港特別行政區）');
    expect(AppLanguage.zhTw.nativeName, '繁体中文（中國台灣）');
    expect(AppLanguage.en.nativeName, 'English');
  });

  test('settings persist language preference', () async {
    SharedPreferences.setMockInitialValues({});
    final repository = SettingsRepository();
    final saved = const AppSettings(appLanguage: AppLanguage.zhHk);
    await repository.saveSettings(saved);
    final loaded = await repository.loadSettings();
    expect(loaded.appLanguage, AppLanguage.zhHk);
  });

  test('legacy settings without language follow the system', () async {
    SharedPreferences.setMockInitialValues({
      'app_settings': '{"concurrency": 2}',
    });
    final loaded = await SettingsRepository().loadSettings();
    expect(loaded.appLanguage, AppLanguage.system);
    expect(loaded.concurrency, 2);
  });

  test('legacy zh language preference maps to mainland Chinese', () async {
    SharedPreferences.setMockInitialValues({
      'app_settings': '{"appLanguage":"zh"}',
    });
    final loaded = await SettingsRepository().loadSettings();
    expect(loaded.appLanguage, AppLanguage.zhCn);
  });

  test('localized labels switch with locale', () {
    final en = lookupAppLocalizations(const Locale('en'));
    final zhCn = lookupAppLocalizations(const Locale('zh', 'CN'));
    final zhHk = lookupAppLocalizations(const Locale('zh', 'HK'));
    final zhTw = lookupAppLocalizations(const Locale('zh', 'TW'));
    expect(en.detectingGpu, 'Detecting GPU encoders…');
    expect(zhCn.detectingGpu, '正在检测 GPU 编码器…');
    expect(en.appName, 'Media Format Converter');
    expect(zhCn.appName, '媒体格式转换器');
    expect(zhHk.appName, '媒體格式轉換器');
    expect(zhTw.appName, '媒體格式轉換器');
    expect(taskStatusLabel(en, TaskStatus.running), 'Converting');
    expect(taskStatusLabel(zhCn, TaskStatus.running), '转换中');
    expect(taskStatusLabel(zhHk, TaskStatus.running), '轉換中');
    expect(formatLabel(en, MediaFormat.copyVideo), 'Copy');
    expect(formatLabel(zhCn, MediaFormat.copyVideo), '原编码');
    expect(formatLabel(zhTw, MediaFormat.copyVideo), '原編碼');
    expect(en.convertToFormat('MP4'), 'Convert to MP4');
    expect(zhCn.convertToFormat('MP4'), '转换为 MP4');
    expect(zhHk.convertToFormat('原編碼'), '轉換為 原編碼');
    expect(zhTw.convertToFormat('MKV'), '轉換為 MKV');
    expect(
      localizeMessage(en, encodeAppMessage(AppMessage.cancelled)),
      'Cancelled',
    );
    expect(
      localizeMessage(zhCn, encodeAppMessage(AppMessage.cancelled)),
      '已取消',
    );
  });
}

ConversionTask _videoTask(EncodeOptions encode) {
  return ConversionTask(
    id: 'gpu',
    inputPath: r'C:\in\a.mov',
    outputDirectory: r'C:\out',
    outputFileName: 'a.mp4',
    targetFormat: MediaFormat.mp4,
    encode: encode,
    createdAt: DateTime(2026, 1, 1),
  );
}

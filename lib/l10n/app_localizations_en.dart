// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Media Format Converter';

  @override
  String get language => 'Language';

  @override
  String get languageHint => 'The interface updates immediately.';

  @override
  String get languageSystem => 'Follow system';

  @override
  String get about => 'About';

  @override
  String versionLabel(String version) {
    return 'Version $version';
  }

  @override
  String get aboutDescription =>
      'A desktop media converter that wraps local FFmpeg.';

  @override
  String get close => 'Close';

  @override
  String get ffmpegDocs => 'FFmpeg docs';

  @override
  String get settings => 'Settings';

  @override
  String get done => 'Done';

  @override
  String get browse => 'Browse';

  @override
  String get cancel => 'Cancel';

  @override
  String get retry => 'Retry';

  @override
  String get next => 'Next';

  @override
  String get back => 'Back';

  @override
  String get fileMenu => 'File';

  @override
  String get aboutMenu => 'About';

  @override
  String get openFile => 'Open files';

  @override
  String get exit => 'Exit';

  @override
  String get aboutThisApp => 'About this app';

  @override
  String get addConversionTask => 'Add conversion task';

  @override
  String get editConversionTask => 'Edit conversion task';

  @override
  String get subtitles => 'Subtitles';

  @override
  String get startAll => 'Start all';

  @override
  String get stopAll => 'Stop all';

  @override
  String get clearFinished => 'Clear finished';

  @override
  String get ffmpegNotDetected =>
      'ffmpeg was not found. Set its path in Settings first.';

  @override
  String get noMediaFiles => 'No supported media files';

  @override
  String get dropMediaFiles => 'Drop audio or video files.';

  @override
  String ffmpegReadyStatus(String label) {
    return 'ffmpeg ready  ·  $label';
  }

  @override
  String get notReady => 'Not ready';

  @override
  String queueCount(int count) {
    return 'Queue $count';
  }

  @override
  String runningCount(int running, int concurrency) {
    return 'Running $running/$concurrency';
  }

  @override
  String failedCount(int count) {
    return 'Failed $count';
  }

  @override
  String get convertToVideo => 'Convert to video';

  @override
  String get convertToAudio => 'Convert to audio';

  @override
  String convertToFormat(String format) {
    return 'Convert to $format';
  }

  @override
  String get queueEmpty => 'The conversion queue is empty';

  @override
  String get queueEmptyHint =>
      'Open files, drop media, or pick a format on the left to add a task.';

  @override
  String sourcePath(String path) {
    return 'Source: $path';
  }

  @override
  String destinationPath(String path) {
    return 'Destination: $path';
  }

  @override
  String clipRangeLabel(String start, String end) {
    return 'Clip $start → $end';
  }

  @override
  String subtitleKeepAdd(int kept, int added) {
    return 'Subtitles: keep $kept tracks, add $added';
  }

  @override
  String get openInputFolder => 'Open input folder';

  @override
  String get openOutputFolder => 'Open output folder';

  @override
  String get stop => 'Stop';

  @override
  String get restart => 'Restart';

  @override
  String get start => 'Start';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get clip => 'Clip';

  @override
  String elapsed(String time) {
    return 'Elapsed $time';
  }

  @override
  String remaining(String time) {
    return 'ETA $time';
  }

  @override
  String get statusPending => 'Not started';

  @override
  String get statusQueued => 'Queued';

  @override
  String get statusRunning => 'Converting';

  @override
  String get statusCompleted => 'Completed';

  @override
  String get statusFailed => 'Failed';

  @override
  String get statusCancelled => 'Cancelled';

  @override
  String get ffmpegPath => 'ffmpeg path';

  @override
  String get ffmpegPathHintWindows =>
      'Leave empty to search the app folder first, then PATH and Program Files. Relative paths are resolved from the app folder and stored as entered.';

  @override
  String get ffmpegPathHintMacos =>
      'Leave empty to search the app folder first, then PATH, Homebrew, and /usr/local/bin. Relative paths are resolved from the app folder and stored as entered.';

  @override
  String get ffmpegPathHintLinux =>
      'Leave empty to search the app folder first, then PATH, /usr/bin, and ~/.local/bin. Relative paths are resolved from the app folder and stored as entered.';

  @override
  String get useThisPath => 'Use this path';

  @override
  String get redetect => 'Detect again';

  @override
  String get ready => 'Ready';

  @override
  String get taskReady => 'Ready';

  @override
  String get ffmpegNotFoundTitle => 'ffmpeg not found';

  @override
  String get ffmpegMissingHintWindows =>
      'Specify or detect a working ffmpeg.exe before converting.';

  @override
  String get ffmpegMissingHintOther =>
      'Specify or detect a working ffmpeg before converting.';

  @override
  String get hardwareAcceleration => 'Hardware acceleration';

  @override
  String get hardwareAccelerationHint =>
      'When enabled, new conversion tasks use hardware acceleration by default. Existing tasks are unchanged.';

  @override
  String get hardwareDefaultOn => 'On by default for new tasks';

  @override
  String get hardwareAfterGpu => 'Applies to new tasks after a GPU is detected';

  @override
  String get concurrency => 'Task concurrency';

  @override
  String get concurrencyHint =>
      'How many ffmpeg processes can run at once. Higher values convert faster but use more CPU and disk.';

  @override
  String get renameOnConflict => 'Auto-rename on conflict';

  @override
  String renameHint(String token, String padded) {
    return 'Append a number when the output file already exists. $token is the number; $padded becomes 01.';
  }

  @override
  String renamePresetFile(String example) {
    return 'file$example';
  }

  @override
  String get useThisRule => 'Use this rule';

  @override
  String renameExample(String example) {
    return 'Example: video$example';
  }

  @override
  String get pickMediaFiles => 'Select media files';

  @override
  String get pickSubtitleFiles => 'Select external subtitles';

  @override
  String get pickOutputDirectory => 'Select output folder';

  @override
  String get pickFfmpegExe => 'Select ffmpeg.exe';

  @override
  String get pickFfmpeg => 'Select ffmpeg';

  @override
  String clipTitle(String name) {
    return 'Clip  ·  $name';
  }

  @override
  String get play => 'Play';

  @override
  String get pause => 'Pause';

  @override
  String get minusOneFrame => '-1 frame';

  @override
  String get plusOneFrame => '+1 frame';

  @override
  String currentPosition(String time) {
    return 'Position $time';
  }

  @override
  String get loadingPreview => 'Loading preview…';

  @override
  String get clipPreviewUnavailable =>
      'Video preview is temporarily unavailable.';

  @override
  String get inPoint => 'In';

  @override
  String get outPoint => 'Out';

  @override
  String timecodeAndFrame(String time, int frame) {
    return '$time  ·  Frame $frame';
  }

  @override
  String get useCurrentFrame => 'Use current frame';

  @override
  String get clearClip => 'Clear clip';

  @override
  String get applyClip => 'Apply clip';

  @override
  String get clearSubtitles => 'Clear subtitle changes';

  @override
  String get applySubtitles => 'Apply subtitle changes';

  @override
  String get subtitleTaskLocked =>
      'This task cannot be edited while it is running or already finished.';

  @override
  String get subtitleAudioUnsupported =>
      'Audio tasks do not support embedded subtitles.';

  @override
  String get subtitleFormatUnsupported =>
      'This output format does not support embedded subtitles.';

  @override
  String cannotOpenPreview(String error) {
    return 'Cannot open preview: $error';
  }

  @override
  String get selectFormat => 'Target format';

  @override
  String get selectFormatPlaceholder => 'Choose a target format';

  @override
  String get video => 'Video';

  @override
  String get audio => 'Audio';

  @override
  String get inputFiles => 'Input files';

  @override
  String get inputFilePath => 'Input file path';

  @override
  String get addFiles => 'Add files';

  @override
  String get noFilesYet =>
      'No files yet. Click Add, or drop them from the home screen.';

  @override
  String get reading => 'Reading…';

  @override
  String get outputDirectory => 'Output folder';

  @override
  String get outputFileName => 'Output file name';

  @override
  String outputFileNameExample(String token) {
    return 'e.g. ${token}_converted';
  }

  @override
  String outputFileNameHint(String token) {
    return 'Use $token for the original file name. Conflicts still follow the rename setting.';
  }

  @override
  String get outputNamePreviewTitle => 'Converted file names';

  @override
  String get outputNamePreviewEmpty => 'Add files to preview converted names.';

  @override
  String get outputNamePreviewOriginal => 'Original name';

  @override
  String get outputNamePreviewConverted => 'Converted name';

  @override
  String get picture => 'Picture';

  @override
  String get output => 'Output';

  @override
  String get noPictureProcessing =>
      'This target does not reprocess the picture.';

  @override
  String get copyVideoKeepCopy =>
      'Video stays stream-copied until you change picture or encoder options.';

  @override
  String get copyVideoWillReencode =>
      'Changing picture or video options re-encodes the video. Audio stays copied unless you change it.';

  @override
  String get copyVideoEncoderLocked =>
      'Auto follows the source video codec; you can also pick another encoder.';

  @override
  String copyVideoUnknownCodec(String codec) {
    return 'Unknown source codec ($codec). Scaling is unavailable until the codec is recognized.';
  }

  @override
  String get copyAudioKeepCopy =>
      'Audio stays stream-copied until you change audio options.';

  @override
  String get copyAudioWillReencode =>
      'Changing audio options re-encodes audio. Video stays copied unless you change the picture.';

  @override
  String get copyAudioEncoderLocked =>
      'The audio codec stays locked to the source codec.';

  @override
  String copyAudioUnknownCodec(String codec) {
    return 'Unknown source audio codec ($codec). Audio processing is unavailable until the codec is recognized.';
  }

  @override
  String get resolutionPreset => 'Resolution preset';

  @override
  String get keepAspectRatio => 'Keep aspect ratio';

  @override
  String get scaleAlgorithm => 'Scaling algorithm';

  @override
  String get rotation => 'Rotation';

  @override
  String get deinterlace => 'Deinterlace';

  @override
  String get flipHorizontal => 'Flip horizontally';

  @override
  String get flipVertical => 'Flip vertically';

  @override
  String get noVideoReencode => 'This target does not re-encode video.';

  @override
  String get fixedEncoder => 'This format uses a fixed encoder.';

  @override
  String get defaultFps15 => 'Default 15';

  @override
  String get hardwareAccel => 'Hardware acceleration';

  @override
  String get hardwareAccelOnHint =>
      'When on, the GPU is used automatically for decode, filters, and encode.';

  @override
  String get noGpuEncoder => 'No usable GPU encoder was detected.';

  @override
  String get encoder => 'Encoder';

  @override
  String get hardwarePicksEncoder =>
      'The GPU encoder is chosen automatically while hardware acceleration is on.';

  @override
  String get speed => 'Speed';

  @override
  String get contentTune => 'Tune';

  @override
  String get auto => 'Auto';

  @override
  String get pixelFormat => 'Pixel format';

  @override
  String get encoder8bitOnly => 'This encoder uses 8-bit only.';

  @override
  String get rateControl => 'Rate control';

  @override
  String get maxBitrateKbps => 'Max bitrate kbps';

  @override
  String get bufsizeKbps => 'Buffer kbps';

  @override
  String get fpsMode => 'Frame rate mode';

  @override
  String get keyframeInterval => 'Keyframe interval';

  @override
  String get copyAudioNoProcess => 'Copy mode does not reprocess audio.';

  @override
  String get audioControl => 'Audio control';

  @override
  String get audioBitrateKbps => 'Audio bitrate kbps';

  @override
  String get optionalHint => 'Optional';

  @override
  String get amrFixed => 'AMR is fixed at 8000 Hz, mono, 12.2 kbps.';

  @override
  String get mp3Quality => 'MP3 quality 0-9';

  @override
  String get aacQuality => 'AAC quality 1-5';

  @override
  String get flacCompression => 'FLAC compression 0-12';

  @override
  String get opusRateMode => 'Opus rate mode';

  @override
  String get opusApplicationField => 'Opus application';

  @override
  String get sampleRate => 'Sample rate';

  @override
  String get followSource => 'Follow source';

  @override
  String get sampleRateNote =>
      'Unsupported sample rates are adjusted to the nearest value.';

  @override
  String get channels => 'Channels';

  @override
  String get mono => 'Mono';

  @override
  String get stereo => 'Stereo';

  @override
  String get volumeDb => 'Volume (dB)';

  @override
  String get loudnessSkipsVolume =>
      'Volume is not applied while loudness normalization is on.';

  @override
  String get loudnessNormalize => 'Loudness normalization';

  @override
  String get fastStart => 'Optimize for streaming (faststart)';

  @override
  String get keepMetadata => 'Keep metadata';

  @override
  String get keepChapters => 'Keep chapters';

  @override
  String get metadataTitle => 'Title';

  @override
  String get metadataArtist => 'Artist';

  @override
  String get metadataAlbum => 'Album';

  @override
  String get metadataYear => 'Year';

  @override
  String get metadataComment => 'Comment';

  @override
  String get qualityPreset => 'Quality preset';

  @override
  String get custom => 'Custom';

  @override
  String get videoBitrateKbps => 'Video bitrate kbps';

  @override
  String get required => 'Required';

  @override
  String get frameRate => 'Frame rate';

  @override
  String get width => 'Width';

  @override
  String get height => 'Height';

  @override
  String get detectingGpu => 'Detecting GPU encoders…';

  @override
  String get noGpuDetected => 'No usable GPU detected';

  @override
  String usingGpus(String names) {
    return 'Using $names';
  }

  @override
  String get listSeparator => ', ';

  @override
  String get addToQueue => 'Add to queue';

  @override
  String get saveTask => 'Save task';

  @override
  String get wizardStepFormat => '1. Choose format';

  @override
  String get wizardStepParams => '2. Files and options';

  @override
  String get unknownResolution => 'Unknown resolution';

  @override
  String get unknownDuration => 'Unknown duration';

  @override
  String get formatCopyCodec => 'Copy';

  @override
  String get formatDescCopyVideo =>
      'Keep the source container. Defaults to the source codec, with full options; unchanged streams stay copied';

  @override
  String get formatDescCopyAudio =>
      'Keep the source container. Defaults to the source codec, with full options; unchanged streams stay copied';

  @override
  String get formatDescMp4 =>
      'General-purpose video with the widest compatibility';

  @override
  String get formatDescMkv => 'Open container for high-quality muxing';

  @override
  String get formatDescWebm => 'Web video with smaller files';

  @override
  String get formatDescMov => 'Common in the Apple ecosystem';

  @override
  String get formatDescAvi => 'Legacy video container';

  @override
  String get formatDescGif => 'Animated image for short clips';

  @override
  String get formatDescWmv => 'Windows Media video';

  @override
  String get formatDescFlv => 'Flash video container';

  @override
  String get formatDescMpeg => 'MPEG program stream';

  @override
  String get formatDescTs => 'MPEG transport stream';

  @override
  String get formatDescM2ts => 'Blu-ray transport stream';

  @override
  String get formatDesc3gp => 'Common mobile video';

  @override
  String get formatDescOgv => 'Open Theora video';

  @override
  String get formatDescWebp => 'Animated WebP image';

  @override
  String get formatDescMp3 => 'General-purpose lossy audio';

  @override
  String get formatDescAac => 'Efficient lossy audio';

  @override
  String get formatDescM4a => 'AAC audio container';

  @override
  String get formatDescWav => 'Uncompressed PCM audio';

  @override
  String get formatDescFlac => 'Lossless compressed audio';

  @override
  String get formatDescOgg => 'Open Vorbis audio';

  @override
  String get formatDescOpus => 'Low-latency efficient audio';

  @override
  String get formatDescAc3 => 'Dolby Digital surround';

  @override
  String get formatDescWma => 'Windows Media audio';

  @override
  String get formatDescAiff => 'Apple uncompressed PCM';

  @override
  String get formatDescMp2 => 'MPEG Audio Layer 2';

  @override
  String get formatDescWv => 'WavPack lossless audio';

  @override
  String get formatDescTta => 'True Audio lossless';

  @override
  String get formatDescSpx => 'Speex speech codec';

  @override
  String get formatDescAmr => 'Narrowband speech audio';

  @override
  String get formatDescAlac => 'Apple lossless audio';

  @override
  String get formatDescCaf => 'Apple Core Audio';

  @override
  String get presetOriginal => 'Original';

  @override
  String get preset1080p => '1080p';

  @override
  String get preset720p => '720p';

  @override
  String get preset480p => '480p';

  @override
  String get qualitySmaller => 'Smaller file';

  @override
  String get qualityStandard => 'Default';

  @override
  String get qualityHigher => 'Higher quality';

  @override
  String get encoderH264Software => 'H.264 software';

  @override
  String get encoderH265Software => 'H.265 software';

  @override
  String get encoderH264Nvidia => 'H.264 NVIDIA';

  @override
  String get encoderH265Nvidia => 'H.265 NVIDIA';

  @override
  String get encoderH264Amd => 'H.264 AMD';

  @override
  String get encoderH265Amd => 'H.265 AMD';

  @override
  String get encoderH264Intel => 'H.264 Intel';

  @override
  String get encoderH265Intel => 'H.265 Intel';

  @override
  String get encoderH264Vaapi => 'H.264 VAAPI';

  @override
  String get encoderH265Vaapi => 'H.265 VAAPI';

  @override
  String get encoderH264Videotoolbox => 'H.264 VideoToolbox';

  @override
  String get encoderH265Videotoolbox => 'H.265 VideoToolbox';

  @override
  String get encoderVp9 => 'VP9';

  @override
  String get encoderAv1 => 'AV1';

  @override
  String get rateQuality => 'Quality';

  @override
  String get rateVbr => 'Variable bitrate';

  @override
  String get rateCbr => 'Constant bitrate';

  @override
  String get speedFastest => 'Fastest';

  @override
  String get speedFaster => 'Faster';

  @override
  String get speedFast => 'Fast';

  @override
  String get speedMedium => 'Balanced';

  @override
  String get speedSlow => 'Slow';

  @override
  String get speedSlower => 'Slower';

  @override
  String get speedSlowest => 'Slowest';

  @override
  String get tuneFilm => 'Film';

  @override
  String get tuneAnimation => 'Animation';

  @override
  String get tuneGrain => 'Preserve grain';

  @override
  String get tuneStillImage => 'Still image';

  @override
  String get tuneFastDecode => 'Easy to decode';

  @override
  String get tuneZeroLatency => 'Low latency';

  @override
  String get pixelYuv420p => '8-bit 4:2:0';

  @override
  String get pixelYuv420p10 => '10-bit 4:2:0';

  @override
  String get scaleBilinear => 'Bilinear';

  @override
  String get scaleBicubic => 'Bicubic';

  @override
  String get scaleLanczos => 'Lanczos';

  @override
  String get deinterlaceOff => 'Off';

  @override
  String get deinterlaceYadif => 'Deinterlace';

  @override
  String get deinterlaceYadifDouble => 'Deinterlace and double rate';

  @override
  String get rotationNone => 'No rotation';

  @override
  String get rotationClockwise => '90° clockwise';

  @override
  String get rotationHalf => '180°';

  @override
  String get rotationCounterClockwise => '90° counterclockwise';

  @override
  String get fpsCfr => 'Constant frame rate';

  @override
  String get fpsVfr => 'Variable frame rate';

  @override
  String get keyframeOneSecond => '1 second';

  @override
  String get keyframeTwoSeconds => '2 seconds';

  @override
  String get keyframeFiveSeconds => '5 seconds';

  @override
  String get keyframeTenSeconds => '10 seconds';

  @override
  String get audioRateQuality => 'Quality';

  @override
  String get audioRateBitrate => 'Bitrate';

  @override
  String get opusApplicationAudio => 'Music';

  @override
  String get opusApplicationVoip => 'Speech';

  @override
  String get opusApplicationLowdelay => 'Low latency';

  @override
  String get opusVbrOn => 'Variable bitrate';

  @override
  String get opusVbrConstrained => 'Constrained VBR';

  @override
  String get opusVbrOff => 'Constant bitrate';

  @override
  String get subtitleNoVideo =>
      'This file has no video stream, so subtitles cannot be edited.';

  @override
  String get subtitleNeedOutput => 'Enter an output folder and file name.';

  @override
  String get existingSubtitles => 'Existing subtitles';

  @override
  String get readingSubtitleTracks => 'Reading subtitle tracks...';

  @override
  String get noEmbeddedSubtitles => 'No embedded subtitles.';

  @override
  String get externalSubtitles => 'External subtitles to add';

  @override
  String get addExternalSubtitle => 'Add external subtitles';

  @override
  String get subtitleLanguageHint => 'Language, e.g. chi';

  @override
  String get subtitleTitleHint => 'Title';

  @override
  String get subtitleOutputHint =>
      'Uncheck a track to remove it. Subtitles are written into the current task output.';

  @override
  String get container => 'Container';

  @override
  String get webmSubtitleWarning =>
      'WebM keeps WebVTT text subtitles only; styling is lost.';

  @override
  String get mp4AssWarning =>
      'MP4/MOV cannot keep ASS styling. Saving as MKV is recommended.';

  @override
  String get mp4TextWarning =>
      'MP4/MOV converts text subtitles to mov_text, so styling is lost.';

  @override
  String trackIndex(int index) {
    return 'Track $index';
  }

  @override
  String get subtitleDefault => 'Default';

  @override
  String get subtitleForced => 'Forced';

  @override
  String get subtitleDeleteOnly => 'Can only be removed';

  @override
  String get errorFfmpegNotFound => 'ffmpeg was not found';

  @override
  String get errorFfmpegNotFoundSpecify =>
      'ffmpeg was not found. Set its path in Settings.';

  @override
  String errorFfmpegFoundFrom(String source) {
    return 'Found ffmpeg from $source';
  }

  @override
  String get errorFfmpegInvalidPath =>
      'That path is invalid and cannot run ffmpeg';

  @override
  String get errorFfmpegUsingSpecified => 'Using the specified ffmpeg';

  @override
  String get errorCancelled => 'Cancelled';

  @override
  String get errorConversionFailed => 'Conversion failed';

  @override
  String errorCannotStartFfmpeg(String error) {
    return 'Cannot start ffmpeg: $error';
  }

  @override
  String errorFfmpegExitCode(int code) {
    return 'ffmpeg exit code $code';
  }

  @override
  String get errorFfprobeNotFound => 'ffprobe was not found';

  @override
  String get errorCannotReadMedia => 'Cannot read media info';

  @override
  String get errorEncoderInitFailed => 'Encoder initialization failed';

  @override
  String errorEncoderUnsupported(String vendor) {
    return 'This system does not support $vendor encoders';
  }

  @override
  String errorEncoderNotCompiled(String vendor) {
    return 'This ffmpeg build does not include $vendor encoders';
  }

  @override
  String errorEncoderCheckFailed(String vendor, String error) {
    return 'Could not check $vendor encoders: $error';
  }

  @override
  String errorEncoderCanInit(String vendor) {
    return '$vendor encoder can initialize';
  }

  @override
  String errorUnsupportedSourceVideoCodec(String codec) {
    return 'Cannot re-encode with the source video codec ($codec)';
  }

  @override
  String errorUnsupportedSourceAudioCodec(String codec) {
    return 'Cannot re-encode with the source audio codec ($codec)';
  }

  @override
  String get ffmpegSourceSettingsPath => 'the path set in Settings';

  @override
  String get ffmpegSourceManual => 'a manually chosen path';

  @override
  String get ffmpegSourceSystemPath => 'system PATH';

  @override
  String get ffmpegSourceAppDirFfmpeg => 'app folder ffmpeg';

  @override
  String get ffmpegSourceAppDirFfmpegBin => 'app folder ffmpeg/bin';

  @override
  String get ffmpegSourceAppDirBin => 'app folder bin';

  @override
  String get ffmpegSourceAppDir => 'the app folder';

  @override
  String get crfFollowsQuality => 'CRF (empty uses the quality preset)';

  @override
  String get lockedMobileProfile =>
      'FLV and 3GP always use Baseline / Level 3.0.';

  @override
  String channelCount(int count) {
    return '$count channels';
  }
}

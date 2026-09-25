// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appName => '媒体格式转换器';

  @override
  String get language => '语言';

  @override
  String get languageHint => '切换后立即生效。';

  @override
  String get languageSystem => '跟随系统';

  @override
  String get about => '关于';

  @override
  String versionLabel(String version) {
    return '版本 $version';
  }

  @override
  String get aboutDescription => '套壳本地 FFmpeg 的桌面媒体格式转换器。';

  @override
  String get close => '关闭';

  @override
  String get ffmpegDocs => 'FFmpeg 文档';

  @override
  String get settings => '设置';

  @override
  String get done => '完成';

  @override
  String get browse => '浏览';

  @override
  String get cancel => '取消';

  @override
  String get retry => '重试';

  @override
  String get next => '下一步';

  @override
  String get back => '上一步';

  @override
  String get fileMenu => '文件';

  @override
  String get aboutMenu => '关于';

  @override
  String get openFile => '打开文件';

  @override
  String get exit => '退出';

  @override
  String get aboutThisApp => '关于本软件';

  @override
  String get addConversionTask => '添加转换任务';

  @override
  String get editConversionTask => '编辑转换任务';

  @override
  String get subtitles => '字幕';

  @override
  String get startAll => '开始全部';

  @override
  String get stopAll => '停止全部';

  @override
  String get clearFinished => '清空已完成';

  @override
  String get ffmpegNotDetected => '未检测到 ffmpeg，请先到设置中指定路径';

  @override
  String get noMediaFiles => '没有可用的媒体文件';

  @override
  String get dropMediaFiles => '请拖入音视频文件。';

  @override
  String ffmpegReadyStatus(String label) {
    return 'ffmpeg 已就绪  ·  $label';
  }

  @override
  String get notReady => '未就绪';

  @override
  String queueCount(int count) {
    return '队列 $count';
  }

  @override
  String runningCount(int running, int concurrency) {
    return '进行中 $running/$concurrency';
  }

  @override
  String failedCount(int count) {
    return '失败 $count';
  }

  @override
  String get convertToVideo => '转换为视频';

  @override
  String get convertToAudio => '转换为音频';

  @override
  String convertToFormat(String format) {
    return '转换为 $format';
  }

  @override
  String get queueEmpty => '转换队列是空的';

  @override
  String get queueEmptyHint => '打开文件、拖入媒体，或点击左侧格式开始添加任务。';

  @override
  String sourcePath(String path) {
    return '源：$path';
  }

  @override
  String destinationPath(String path) {
    return '目标：$path';
  }

  @override
  String clipRangeLabel(String start, String end) {
    return '剪辑 $start → $end';
  }

  @override
  String subtitleKeepAdd(int kept, int added) {
    return '字幕：保留 $kept 轨，添加 $added 条';
  }

  @override
  String get openInputFolder => '打开输入文件所在目录';

  @override
  String get openOutputFolder => '打开输出目录';

  @override
  String get stop => '停止';

  @override
  String get restart => '重新开始';

  @override
  String get start => '开始';

  @override
  String get delete => '删除';

  @override
  String get edit => '编辑';

  @override
  String get clip => '剪辑';

  @override
  String elapsed(String time) {
    return '已用 $time';
  }

  @override
  String remaining(String time) {
    return '剩余 $time';
  }

  @override
  String get statusPending => '未开始';

  @override
  String get statusQueued => '排队中';

  @override
  String get statusRunning => '转换中';

  @override
  String get statusCompleted => '已完成';

  @override
  String get statusFailed => '失败';

  @override
  String get statusCancelled => '已取消';

  @override
  String get ffmpegPath => 'ffmpeg 路径';

  @override
  String get ffmpegPathHintWindows =>
      '留空则先找程序目录下的 ffmpeg，再找 PATH 和 Program Files。相对路径按程序目录解析，并按输入原样保存。';

  @override
  String get ffmpegPathHintMacos =>
      '留空则先找程序目录下的 ffmpeg，再找 PATH、Homebrew 和 /usr/local/bin。相对路径按程序目录解析，并按输入原样保存。';

  @override
  String get ffmpegPathHintLinux =>
      '留空则先找程序目录下的 ffmpeg，再找 PATH、/usr/bin 和 ~/.local/bin。相对路径按程序目录解析，并按输入原样保存。';

  @override
  String get useThisPath => '使用此路径';

  @override
  String get redetect => '重新探测';

  @override
  String get ready => '已就绪';

  @override
  String get taskReady => '准备就绪';

  @override
  String get ffmpegNotFoundTitle => '未找到 ffmpeg';

  @override
  String get ffmpegMissingHintWindows => '转换前需要先指定或探测到可用的 ffmpeg.exe。';

  @override
  String get ffmpegMissingHintOther => '转换前需要先指定或探测到可用的 ffmpeg。';

  @override
  String get hardwareAcceleration => '硬件加速';

  @override
  String get hardwareAccelerationHint => '打开后，新建转换任务会默认使用硬件加速。已添加的任务不会改变。';

  @override
  String get hardwareDefaultOn => '新建任务默认开启';

  @override
  String get hardwareAfterGpu => '检测到 GPU 后对新任务生效';

  @override
  String get concurrency => '任务并发数';

  @override
  String get concurrencyHint => '同时运行的 ffmpeg 进程数量。数值越大转换越快，也更容易打满 CPU 和磁盘。';

  @override
  String get renameOnConflict => '重名自动重命名';

  @override
  String renameHint(String token, String padded) {
    return '输出文件已存在时追加序号。$token 是序号，$padded 会补成 01。';
  }

  @override
  String renamePresetFile(String example) {
    return '文件$example';
  }

  @override
  String get useThisRule => '使用此规则';

  @override
  String renameExample(String example) {
    return '示例：video$example';
  }

  @override
  String get pickMediaFiles => '选择媒体文件';

  @override
  String get pickSubtitleFiles => '选择外挂字幕';

  @override
  String get pickOutputDirectory => '选择输出目录';

  @override
  String get pickFfmpegExe => '选择 ffmpeg.exe';

  @override
  String get pickFfmpeg => '选择 ffmpeg';

  @override
  String clipTitle(String name) {
    return '剪辑  ·  $name';
  }

  @override
  String get play => '播放';

  @override
  String get pause => '暂停';

  @override
  String get minusOneFrame => '-1 帧';

  @override
  String get plusOneFrame => '+1 帧';

  @override
  String currentPosition(String time) {
    return '当前位置 $time';
  }

  @override
  String get loadingPreview => '正在加载预览…';

  @override
  String get clipPreviewUnavailable => '视频预览暂不可用。';

  @override
  String get inPoint => '入点';

  @override
  String get outPoint => '出点';

  @override
  String timecodeAndFrame(String time, int frame) {
    return '$time  ·  第 $frame 帧';
  }

  @override
  String get useCurrentFrame => '用当前帧';

  @override
  String get clearClip => '清除剪辑';

  @override
  String get applyClip => '应用剪辑';

  @override
  String get clearSubtitles => '清除字幕更改';

  @override
  String get applySubtitles => '应用字幕更改';

  @override
  String get subtitleTaskLocked => '进行中或已完成的任务不能编辑字幕。';

  @override
  String get subtitleAudioUnsupported => '音频任务不支持内嵌字幕。';

  @override
  String get subtitleFormatUnsupported => '当前输出格式不支持内嵌字幕。';

  @override
  String cannotOpenPreview(String error) {
    return '无法打开预览：$error';
  }

  @override
  String get selectFormat => '目标格式';

  @override
  String get selectFormatPlaceholder => '选择要转换到的格式';

  @override
  String get video => '视频';

  @override
  String get audio => '音频';

  @override
  String get inputFiles => '输入文件';

  @override
  String get inputFilePath => '输入文件路径';

  @override
  String get addFiles => '添加文件';

  @override
  String get noFilesYet => '还没有文件。点击添加，或从首页拖入。';

  @override
  String get reading => '读取中…';

  @override
  String get outputDirectory => '输出目录';

  @override
  String get outputFileName => '输出文件名';

  @override
  String outputFileNameExample(String token) {
    return '例如 ${token}_converted';
  }

  @override
  String outputFileNameHint(String token) {
    return '用 $token 表示原文件名。重名仍会按设置追加序号。';
  }

  @override
  String get outputNamePreviewTitle => '转换后的文件名';

  @override
  String get outputNamePreviewEmpty => '先添加文件才能预览转换后的名称。';

  @override
  String get outputNamePreviewOriginal => '原文件名';

  @override
  String get outputNamePreviewConverted => '转换后';

  @override
  String get picture => '画面';

  @override
  String get output => '输出';

  @override
  String get noPictureProcessing => '当前目标不重新处理画面。';

  @override
  String get copyVideoKeepCopy => '未改画面或视频参数时，视频仍直接复制。';

  @override
  String get copyVideoWillReencode => '改了画面或视频参数后会重压视频；音频默认仍复制。';

  @override
  String get copyVideoEncoderLocked => '自动时跟随源视频编码，也可以改成其他编码器。';

  @override
  String copyVideoUnknownCodec(String codec) {
    return '无法识别源视频编码（$codec），缩放前需要能识别的编码。';
  }

  @override
  String get copyAudioKeepCopy => '未改音频参数时，音频仍直接复制。';

  @override
  String get copyAudioWillReencode => '改了音频选项后会重压音频；视频默认仍复制。';

  @override
  String get copyAudioEncoderLocked => '音频编码锁定为源音频编码。';

  @override
  String copyAudioUnknownCodec(String codec) {
    return '无法识别源音频编码（$codec），处理音频前需要能识别的编码。';
  }

  @override
  String get resolutionPreset => '分辨率预设';

  @override
  String get keepAspectRatio => '保持等比缩放';

  @override
  String get scaleAlgorithm => '缩放算法';

  @override
  String get rotation => '旋转';

  @override
  String get deinterlace => '去隔行';

  @override
  String get flipHorizontal => '水平翻转';

  @override
  String get flipVertical => '垂直翻转';

  @override
  String get noVideoReencode => '当前目标不重新编码视频。';

  @override
  String get fixedEncoder => '此格式使用固定编码器。';

  @override
  String get defaultFps15 => '默认 15';

  @override
  String get hardwareAccel => '硬件加速';

  @override
  String get hardwareAccelOnHint => '打开后自动使用本机 GPU 完成解码、画面处理和编码。';

  @override
  String get noGpuEncoder => '没有探测到可用的 GPU 编码器。';

  @override
  String get encoder => '编码器';

  @override
  String get hardwarePicksEncoder => '硬件加速打开时自动选择 GPU 编码器。';

  @override
  String get speed => '速度';

  @override
  String get contentTune => '内容优化';

  @override
  String get auto => '自动';

  @override
  String get pixelFormat => '像素格式';

  @override
  String get encoder8bitOnly => '当前编码器只使用 8-bit。';

  @override
  String get rateControl => '码率控制';

  @override
  String get maxBitrateKbps => '最大码率 kbps';

  @override
  String get bufsizeKbps => '缓冲 kbps';

  @override
  String get fpsMode => '帧率模式';

  @override
  String get keyframeInterval => '关键帧间隔';

  @override
  String get copyAudioNoProcess => '原编码不会重新处理音频。';

  @override
  String get audioControl => '音频控制';

  @override
  String get audioBitrateKbps => '音频码率 kbps';

  @override
  String get optionalHint => '可空';

  @override
  String get amrFixed => 'AMR 固定为 8000 Hz、单声道、12.2 kbps。';

  @override
  String get mp3Quality => 'MP3 质量 0-9';

  @override
  String get aacQuality => 'AAC 质量 1-5';

  @override
  String get flacCompression => 'FLAC 压缩 0-12';

  @override
  String get opusRateMode => 'Opus 码率模式';

  @override
  String get opusApplicationField => 'Opus 用途';

  @override
  String get sampleRate => '采样率';

  @override
  String get followSource => '跟随源';

  @override
  String get sampleRateNote => '不支持的采样率会自动就近调整。';

  @override
  String get channels => '声道';

  @override
  String get mono => '单声道';

  @override
  String get stereo => '立体声';

  @override
  String get volumeDb => '音量（dB）';

  @override
  String get loudnessSkipsVolume => '响度标准化开启时不再叠加音量。';

  @override
  String get loudnessNormalize => '响度标准化';

  @override
  String get fastStart => '优化网络播放（faststart）';

  @override
  String get keepMetadata => '保留元数据';

  @override
  String get keepChapters => '保留章节';

  @override
  String get metadataTitle => '标题';

  @override
  String get metadataArtist => '艺术家';

  @override
  String get metadataAlbum => '专辑';

  @override
  String get metadataYear => '年份';

  @override
  String get metadataComment => '注释';

  @override
  String get qualityPreset => '质量档';

  @override
  String get custom => '自定义';

  @override
  String get videoBitrateKbps => '视频码率 kbps';

  @override
  String get required => '必填';

  @override
  String get frameRate => '帧率';

  @override
  String get width => '宽度';

  @override
  String get height => '高度';

  @override
  String get detectingGpu => '正在检测 GPU 编码器…';

  @override
  String get noGpuDetected => '未检测到可用 GPU';

  @override
  String usingGpus(String names) {
    return '使用 $names';
  }

  @override
  String get listSeparator => '、';

  @override
  String get addToQueue => '添加到队列';

  @override
  String get saveTask => '保存任务';

  @override
  String get wizardStepFormat => '1. 选择格式';

  @override
  String get wizardStepParams => '2. 参数与文件';

  @override
  String get unknownResolution => '未知分辨率';

  @override
  String get unknownDuration => '未知时长';

  @override
  String get formatCopyCodec => '原编码';

  @override
  String get formatDescCopyVideo => '保持原容器，默认源编码，可改参数；未改动时直接复制';

  @override
  String get formatDescCopyAudio => '保持原容器，默认源编码，可改参数；未改动时直接复制';

  @override
  String get formatDescMp4 => '通用视频，兼容性最好';

  @override
  String get formatDescMkv => '开放容器，适合高质量封装';

  @override
  String get formatDescWebm => '网页视频，体积更小';

  @override
  String get formatDescMov => 'Apple 生态常用视频';

  @override
  String get formatDescAvi => '传统视频容器';

  @override
  String get formatDescGif => '动画图片，适合短片段';

  @override
  String get formatDescWmv => 'Windows Media 视频';

  @override
  String get formatDescFlv => 'Flash 视频容器';

  @override
  String get formatDescMpeg => 'MPEG 节目流';

  @override
  String get formatDescTs => 'MPEG 传输流';

  @override
  String get formatDescM2ts => '蓝光传输流';

  @override
  String get formatDesc3gp => '手机常用视频';

  @override
  String get formatDescOgv => 'Theora 开放视频';

  @override
  String get formatDescWebp => '动画 WebP 图片';

  @override
  String get formatDescMp3 => '通用有损音频';

  @override
  String get formatDescAac => '高效有损音频';

  @override
  String get formatDescM4a => 'AAC 音频封装';

  @override
  String get formatDescWav => '无损 PCM 音频';

  @override
  String get formatDescFlac => '无损压缩音频';

  @override
  String get formatDescOgg => 'Vorbis 开放音频';

  @override
  String get formatDescOpus => '低延迟高效音频';

  @override
  String get formatDescAc3 => '杜比数字环绕声';

  @override
  String get formatDescWma => 'Windows Media 音频';

  @override
  String get formatDescAiff => 'Apple 无损 PCM';

  @override
  String get formatDescMp2 => 'MPEG 音频层 2';

  @override
  String get formatDescWv => 'WavPack 无损音频';

  @override
  String get formatDescTta => 'True Audio 无损';

  @override
  String get formatDescSpx => 'Speex 语音编码';

  @override
  String get formatDescAmr => '窄带语音音频';

  @override
  String get formatDescAlac => 'Apple 无损音频';

  @override
  String get formatDescCaf => 'Apple Core Audio';

  @override
  String get presetOriginal => '原画';

  @override
  String get preset1080p => '1080p';

  @override
  String get preset720p => '720p';

  @override
  String get preset480p => '480p';

  @override
  String get qualitySmaller => '更小体积';

  @override
  String get qualityStandard => '默认';

  @override
  String get qualityHigher => '更高画质';

  @override
  String get encoderH264Software => 'H.264 软件';

  @override
  String get encoderH265Software => 'H.265 软件';

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
  String get rateQuality => '质量';

  @override
  String get rateVbr => '动态码率';

  @override
  String get rateCbr => '固定码率';

  @override
  String get speedFastest => '极快';

  @override
  String get speedFaster => '更快';

  @override
  String get speedFast => '快';

  @override
  String get speedMedium => '均衡';

  @override
  String get speedSlow => '慢';

  @override
  String get speedSlower => '更慢';

  @override
  String get speedSlowest => '极慢';

  @override
  String get tuneFilm => '电影';

  @override
  String get tuneAnimation => '动画';

  @override
  String get tuneGrain => '保留颗粒';

  @override
  String get tuneStillImage => '静态画面';

  @override
  String get tuneFastDecode => '便于解码';

  @override
  String get tuneZeroLatency => '低延迟';

  @override
  String get pixelYuv420p => '8-bit 4:2:0';

  @override
  String get pixelYuv420p10 => '10-bit 4:2:0';

  @override
  String get scaleBilinear => '双线性';

  @override
  String get scaleBicubic => '双三次';

  @override
  String get scaleLanczos => 'Lanczos';

  @override
  String get deinterlaceOff => '关闭';

  @override
  String get deinterlaceYadif => '去隔行';

  @override
  String get deinterlaceYadifDouble => '去隔行并补帧';

  @override
  String get rotationNone => '不旋转';

  @override
  String get rotationClockwise => '顺时针 90°';

  @override
  String get rotationHalf => '180°';

  @override
  String get rotationCounterClockwise => '逆时针 90°';

  @override
  String get fpsCfr => '固定帧率';

  @override
  String get fpsVfr => '可变帧率';

  @override
  String get keyframeOneSecond => '1 秒';

  @override
  String get keyframeTwoSeconds => '2 秒';

  @override
  String get keyframeFiveSeconds => '5 秒';

  @override
  String get keyframeTenSeconds => '10 秒';

  @override
  String get audioRateQuality => '质量';

  @override
  String get audioRateBitrate => '码率';

  @override
  String get opusApplicationAudio => '音乐';

  @override
  String get opusApplicationVoip => '语音';

  @override
  String get opusApplicationLowdelay => '低延迟';

  @override
  String get opusVbrOn => '动态码率';

  @override
  String get opusVbrConstrained => '受约束动态码率';

  @override
  String get opusVbrOff => '固定码率';

  @override
  String get subtitleNoVideo => '这个文件没有视频流，不能编辑字幕。';

  @override
  String get subtitleNeedOutput => '请填写输出目录和文件名。';

  @override
  String get existingSubtitles => '已有字幕';

  @override
  String get readingSubtitleTracks => '正在读取字幕轨...';

  @override
  String get noEmbeddedSubtitles => '没有内嵌字幕。';

  @override
  String get externalSubtitles => '要添加的外挂字幕';

  @override
  String get addExternalSubtitle => '添加外挂字幕';

  @override
  String get subtitleLanguageHint => '语言，如 chi';

  @override
  String get subtitleTitleHint => '标题';

  @override
  String get subtitleOutputHint => '取消勾选会删除该字幕轨。字幕会写入当前任务的输出。';

  @override
  String get container => '容器';

  @override
  String get webmSubtitleWarning => 'WebM 只保留 WebVTT 文本字幕，样式会丢失。';

  @override
  String get mp4AssWarning => 'MP4/MOV 不能保留 ASS 样式，建议改存为 MKV。';

  @override
  String get mp4TextWarning => 'MP4/MOV 会把文本字幕转成 mov_text，样式会丢失。';

  @override
  String trackIndex(int index) {
    return '轨道 $index';
  }

  @override
  String get subtitleDefault => '默认';

  @override
  String get subtitleForced => '强制';

  @override
  String get subtitleDeleteOnly => '仅可删除';

  @override
  String get errorFfmpegNotFound => '未找到 ffmpeg';

  @override
  String get errorFfmpegNotFoundSpecify => '未找到 ffmpeg，请在设置中指定路径';

  @override
  String errorFfmpegFoundFrom(String source) {
    return '已从$source找到 ffmpeg';
  }

  @override
  String get errorFfmpegInvalidPath => '指定的路径无效，无法运行 ffmpeg';

  @override
  String get errorFfmpegUsingSpecified => '已使用指定的 ffmpeg';

  @override
  String get errorCancelled => '已取消';

  @override
  String get errorConversionFailed => '转换失败';

  @override
  String errorCannotStartFfmpeg(String error) {
    return '无法启动 ffmpeg：$error';
  }

  @override
  String errorFfmpegExitCode(int code) {
    return 'ffmpeg 退出码 $code';
  }

  @override
  String get errorFfprobeNotFound => '未找到 ffprobe';

  @override
  String get errorCannotReadMedia => '无法读取媒体信息';

  @override
  String get errorEncoderInitFailed => '编码器初始化失败';

  @override
  String errorEncoderUnsupported(String vendor) {
    return '当前系统不支持$vendor编码器';
  }

  @override
  String errorEncoderNotCompiled(String vendor) {
    return '当前 ffmpeg 没有编入$vendor编码器';
  }

  @override
  String errorEncoderCheckFailed(String vendor, String error) {
    return '无法检查$vendor编码器：$error';
  }

  @override
  String errorEncoderCanInit(String vendor) {
    return '$vendor编码器可以初始化';
  }

  @override
  String errorUnsupportedSourceVideoCodec(String codec) {
    return '无法按源视频编码（$codec）重新编码';
  }

  @override
  String errorUnsupportedSourceAudioCodec(String codec) {
    return '无法按源音频编码（$codec）重新编码';
  }

  @override
  String get ffmpegSourceSettingsPath => '设置中指定的路径';

  @override
  String get ffmpegSourceManual => '手动指定';

  @override
  String get ffmpegSourceSystemPath => '系统 PATH';

  @override
  String get ffmpegSourceAppDirFfmpeg => '程序目录 ffmpeg';

  @override
  String get ffmpegSourceAppDirFfmpegBin => '程序目录 ffmpeg/bin';

  @override
  String get ffmpegSourceAppDirBin => '程序目录 bin';

  @override
  String get ffmpegSourceAppDir => '程序目录';

  @override
  String get crfFollowsQuality => 'CRF（空则跟随质量档）';

  @override
  String get lockedMobileProfile => 'FLV 和 3GP 固定使用 Baseline / Level 3.0。';

  @override
  String channelCount(int count) {
    return '$count 声道';
  }
}

/// The translations for Chinese, as used in China (`zh_CN`).
class AppLocalizationsZhCn extends AppLocalizationsZh {
  AppLocalizationsZhCn() : super('zh_CN');

  @override
  String get appName => '媒体格式转换器';

  @override
  String get language => '语言';

  @override
  String get languageHint => '切换后立即生效。';

  @override
  String get languageSystem => '跟随系统';

  @override
  String get about => '关于';

  @override
  String versionLabel(String version) {
    return '版本 $version';
  }

  @override
  String get aboutDescription => '套壳本地 FFmpeg 的桌面媒体格式转换器。';

  @override
  String get close => '关闭';

  @override
  String get ffmpegDocs => 'FFmpeg 文档';

  @override
  String get settings => '设置';

  @override
  String get done => '完成';

  @override
  String get browse => '浏览';

  @override
  String get cancel => '取消';

  @override
  String get retry => '重试';

  @override
  String get next => '下一步';

  @override
  String get back => '上一步';

  @override
  String get fileMenu => '文件';

  @override
  String get aboutMenu => '关于';

  @override
  String get openFile => '打开文件';

  @override
  String get exit => '退出';

  @override
  String get aboutThisApp => '关于本软件';

  @override
  String get addConversionTask => '添加转换任务';

  @override
  String get editConversionTask => '编辑转换任务';

  @override
  String get subtitles => '字幕';

  @override
  String get startAll => '开始全部';

  @override
  String get stopAll => '停止全部';

  @override
  String get clearFinished => '清空已完成';

  @override
  String get ffmpegNotDetected => '未检测到 ffmpeg，请先到设置中指定路径';

  @override
  String get noMediaFiles => '没有可用的媒体文件';

  @override
  String get dropMediaFiles => '请拖入音视频文件。';

  @override
  String ffmpegReadyStatus(String label) {
    return 'ffmpeg 已就绪  ·  $label';
  }

  @override
  String get notReady => '未就绪';

  @override
  String queueCount(int count) {
    return '队列 $count';
  }

  @override
  String runningCount(int running, int concurrency) {
    return '进行中 $running/$concurrency';
  }

  @override
  String failedCount(int count) {
    return '失败 $count';
  }

  @override
  String get convertToVideo => '转换为视频';

  @override
  String get convertToAudio => '转换为音频';

  @override
  String convertToFormat(String format) {
    return '转换为 $format';
  }

  @override
  String get queueEmpty => '转换队列是空的';

  @override
  String get queueEmptyHint => '打开文件、拖入媒体，或点击左侧格式开始添加任务。';

  @override
  String sourcePath(String path) {
    return '源：$path';
  }

  @override
  String destinationPath(String path) {
    return '目标：$path';
  }

  @override
  String clipRangeLabel(String start, String end) {
    return '剪辑 $start → $end';
  }

  @override
  String subtitleKeepAdd(int kept, int added) {
    return '字幕：保留 $kept 轨，添加 $added 条';
  }

  @override
  String get openInputFolder => '打开输入文件所在目录';

  @override
  String get openOutputFolder => '打开输出目录';

  @override
  String get stop => '停止';

  @override
  String get restart => '重新开始';

  @override
  String get start => '开始';

  @override
  String get delete => '删除';

  @override
  String get edit => '编辑';

  @override
  String get clip => '剪辑';

  @override
  String elapsed(String time) {
    return '已用 $time';
  }

  @override
  String remaining(String time) {
    return '剩余 $time';
  }

  @override
  String get statusPending => '未开始';

  @override
  String get statusQueued => '排队中';

  @override
  String get statusRunning => '转换中';

  @override
  String get statusCompleted => '已完成';

  @override
  String get statusFailed => '失败';

  @override
  String get statusCancelled => '已取消';

  @override
  String get ffmpegPath => 'ffmpeg 路径';

  @override
  String get ffmpegPathHintWindows =>
      '留空则先找程序目录下的 ffmpeg，再找 PATH 和 Program Files。相对路径按程序目录解析，并按输入原样保存。';

  @override
  String get ffmpegPathHintMacos =>
      '留空则先找程序目录下的 ffmpeg，再找 PATH、Homebrew 和 /usr/local/bin。相对路径按程序目录解析，并按输入原样保存。';

  @override
  String get ffmpegPathHintLinux =>
      '留空则先找程序目录下的 ffmpeg，再找 PATH、/usr/bin 和 ~/.local/bin。相对路径按程序目录解析，并按输入原样保存。';

  @override
  String get useThisPath => '使用此路径';

  @override
  String get redetect => '重新探测';

  @override
  String get ready => '已就绪';

  @override
  String get taskReady => '准备就绪';

  @override
  String get ffmpegNotFoundTitle => '未找到 ffmpeg';

  @override
  String get ffmpegMissingHintWindows => '转换前需要先指定或探测到可用的 ffmpeg.exe。';

  @override
  String get ffmpegMissingHintOther => '转换前需要先指定或探测到可用的 ffmpeg。';

  @override
  String get hardwareAcceleration => '硬件加速';

  @override
  String get hardwareAccelerationHint => '打开后，新建转换任务会默认使用硬件加速。已添加的任务不会改变。';

  @override
  String get hardwareDefaultOn => '新建任务默认开启';

  @override
  String get hardwareAfterGpu => '检测到 GPU 后对新任务生效';

  @override
  String get concurrency => '任务并发数';

  @override
  String get concurrencyHint => '同时运行的 ffmpeg 进程数量。数值越大转换越快，也更容易打满 CPU 和磁盘。';

  @override
  String get renameOnConflict => '重名自动重命名';

  @override
  String renameHint(String token, String padded) {
    return '输出文件已存在时追加序号。$token 是序号，$padded 会补成 01。';
  }

  @override
  String renamePresetFile(String example) {
    return '文件$example';
  }

  @override
  String get useThisRule => '使用此规则';

  @override
  String renameExample(String example) {
    return '示例：video$example';
  }

  @override
  String get pickMediaFiles => '选择媒体文件';

  @override
  String get pickSubtitleFiles => '选择外挂字幕';

  @override
  String get pickOutputDirectory => '选择输出目录';

  @override
  String get pickFfmpegExe => '选择 ffmpeg.exe';

  @override
  String get pickFfmpeg => '选择 ffmpeg';

  @override
  String clipTitle(String name) {
    return '剪辑  ·  $name';
  }

  @override
  String get play => '播放';

  @override
  String get pause => '暂停';

  @override
  String get minusOneFrame => '-1 帧';

  @override
  String get plusOneFrame => '+1 帧';

  @override
  String currentPosition(String time) {
    return '当前位置 $time';
  }

  @override
  String get loadingPreview => '正在加载预览…';

  @override
  String get clipPreviewUnavailable => '视频预览暂不可用。';

  @override
  String get inPoint => '入点';

  @override
  String get outPoint => '出点';

  @override
  String timecodeAndFrame(String time, int frame) {
    return '$time  ·  第 $frame 帧';
  }

  @override
  String get useCurrentFrame => '用当前帧';

  @override
  String get clearClip => '清除剪辑';

  @override
  String get applyClip => '应用剪辑';

  @override
  String get clearSubtitles => '清除字幕更改';

  @override
  String get applySubtitles => '应用字幕更改';

  @override
  String get subtitleTaskLocked => '进行中或已完成的任务不能编辑字幕。';

  @override
  String get subtitleAudioUnsupported => '音频任务不支持内嵌字幕。';

  @override
  String get subtitleFormatUnsupported => '当前输出格式不支持内嵌字幕。';

  @override
  String cannotOpenPreview(String error) {
    return '无法打开预览：$error';
  }

  @override
  String get selectFormat => '目标格式';

  @override
  String get selectFormatPlaceholder => '选择要转换到的格式';

  @override
  String get video => '视频';

  @override
  String get audio => '音频';

  @override
  String get inputFiles => '输入文件';

  @override
  String get inputFilePath => '输入文件路径';

  @override
  String get addFiles => '添加文件';

  @override
  String get noFilesYet => '还没有文件。点击添加，或从首页拖入。';

  @override
  String get reading => '读取中…';

  @override
  String get outputDirectory => '输出目录';

  @override
  String get outputFileName => '输出文件名';

  @override
  String outputFileNameExample(String token) {
    return '例如 ${token}_converted';
  }

  @override
  String outputFileNameHint(String token) {
    return '用 $token 表示原文件名。重名仍会按设置追加序号。';
  }

  @override
  String get outputNamePreviewTitle => '转换后的文件名';

  @override
  String get outputNamePreviewEmpty => '先添加文件才能预览转换后的名称。';

  @override
  String get outputNamePreviewOriginal => '原文件名';

  @override
  String get outputNamePreviewConverted => '转换后';

  @override
  String get picture => '画面';

  @override
  String get output => '输出';

  @override
  String get noPictureProcessing => '当前目标不重新处理画面。';

  @override
  String get copyVideoKeepCopy => '未改画面或视频参数时，视频仍直接复制。';

  @override
  String get copyVideoWillReencode => '改了画面或视频参数后会重压视频；音频默认仍复制。';

  @override
  String get copyVideoEncoderLocked => '自动时跟随源视频编码，也可以改成其他编码器。';

  @override
  String copyVideoUnknownCodec(String codec) {
    return '无法识别源视频编码（$codec），缩放前需要能识别的编码。';
  }

  @override
  String get copyAudioKeepCopy => '未改音频参数时，音频仍直接复制。';

  @override
  String get copyAudioWillReencode => '改了音频选项后会重压音频；视频默认仍复制。';

  @override
  String get copyAudioEncoderLocked => '音频编码锁定为源音频编码。';

  @override
  String copyAudioUnknownCodec(String codec) {
    return '无法识别源音频编码（$codec），处理音频前需要能识别的编码。';
  }

  @override
  String get resolutionPreset => '分辨率预设';

  @override
  String get keepAspectRatio => '保持等比缩放';

  @override
  String get scaleAlgorithm => '缩放算法';

  @override
  String get rotation => '旋转';

  @override
  String get deinterlace => '去隔行';

  @override
  String get flipHorizontal => '水平翻转';

  @override
  String get flipVertical => '垂直翻转';

  @override
  String get noVideoReencode => '当前目标不重新编码视频。';

  @override
  String get fixedEncoder => '此格式使用固定编码器。';

  @override
  String get defaultFps15 => '默认 15';

  @override
  String get hardwareAccel => '硬件加速';

  @override
  String get hardwareAccelOnHint => '打开后自动使用本机 GPU 完成解码、画面处理和编码。';

  @override
  String get noGpuEncoder => '没有探测到可用的 GPU 编码器。';

  @override
  String get encoder => '编码器';

  @override
  String get hardwarePicksEncoder => '硬件加速打开时自动选择 GPU 编码器。';

  @override
  String get speed => '速度';

  @override
  String get contentTune => '内容优化';

  @override
  String get auto => '自动';

  @override
  String get pixelFormat => '像素格式';

  @override
  String get encoder8bitOnly => '当前编码器只使用 8-bit。';

  @override
  String get rateControl => '码率控制';

  @override
  String get maxBitrateKbps => '最大码率 kbps';

  @override
  String get bufsizeKbps => '缓冲 kbps';

  @override
  String get fpsMode => '帧率模式';

  @override
  String get keyframeInterval => '关键帧间隔';

  @override
  String get copyAudioNoProcess => '原编码不会重新处理音频。';

  @override
  String get audioControl => '音频控制';

  @override
  String get audioBitrateKbps => '音频码率 kbps';

  @override
  String get optionalHint => '可空';

  @override
  String get amrFixed => 'AMR 固定为 8000 Hz、单声道、12.2 kbps。';

  @override
  String get mp3Quality => 'MP3 质量 0-9';

  @override
  String get aacQuality => 'AAC 质量 1-5';

  @override
  String get flacCompression => 'FLAC 压缩 0-12';

  @override
  String get opusRateMode => 'Opus 码率模式';

  @override
  String get opusApplicationField => 'Opus 用途';

  @override
  String get sampleRate => '采样率';

  @override
  String get followSource => '跟随源';

  @override
  String get sampleRateNote => '不支持的采样率会自动就近调整。';

  @override
  String get channels => '声道';

  @override
  String get mono => '单声道';

  @override
  String get stereo => '立体声';

  @override
  String get volumeDb => '音量（dB）';

  @override
  String get loudnessSkipsVolume => '响度标准化开启时不再叠加音量。';

  @override
  String get loudnessNormalize => '响度标准化';

  @override
  String get fastStart => '优化网络播放（faststart）';

  @override
  String get keepMetadata => '保留元数据';

  @override
  String get keepChapters => '保留章节';

  @override
  String get metadataTitle => '标题';

  @override
  String get metadataArtist => '艺术家';

  @override
  String get metadataAlbum => '专辑';

  @override
  String get metadataYear => '年份';

  @override
  String get metadataComment => '注释';

  @override
  String get qualityPreset => '质量档';

  @override
  String get custom => '自定义';

  @override
  String get videoBitrateKbps => '视频码率 kbps';

  @override
  String get required => '必填';

  @override
  String get frameRate => '帧率';

  @override
  String get width => '宽度';

  @override
  String get height => '高度';

  @override
  String get detectingGpu => '正在检测 GPU 编码器…';

  @override
  String get noGpuDetected => '未检测到可用 GPU';

  @override
  String usingGpus(String names) {
    return '使用 $names';
  }

  @override
  String get listSeparator => '、';

  @override
  String get addToQueue => '添加到队列';

  @override
  String get saveTask => '保存任务';

  @override
  String get wizardStepFormat => '1. 选择格式';

  @override
  String get wizardStepParams => '2. 参数与文件';

  @override
  String get unknownResolution => '未知分辨率';

  @override
  String get unknownDuration => '未知时长';

  @override
  String get formatCopyCodec => '原编码';

  @override
  String get formatDescCopyVideo => '保持原容器，默认源编码，可改参数；未改动时直接复制';

  @override
  String get formatDescCopyAudio => '保持原容器，默认源编码，可改参数；未改动时直接复制';

  @override
  String get formatDescMp4 => '通用视频，兼容性最好';

  @override
  String get formatDescMkv => '开放容器，适合高质量封装';

  @override
  String get formatDescWebm => '网页视频，体积更小';

  @override
  String get formatDescMov => 'Apple 生态常用视频';

  @override
  String get formatDescAvi => '传统视频容器';

  @override
  String get formatDescGif => '动画图片，适合短片段';

  @override
  String get formatDescWmv => 'Windows Media 视频';

  @override
  String get formatDescFlv => 'Flash 视频容器';

  @override
  String get formatDescMpeg => 'MPEG 节目流';

  @override
  String get formatDescTs => 'MPEG 传输流';

  @override
  String get formatDescM2ts => '蓝光传输流';

  @override
  String get formatDesc3gp => '手机常用视频';

  @override
  String get formatDescOgv => 'Theora 开放视频';

  @override
  String get formatDescWebp => '动画 WebP 图片';

  @override
  String get formatDescMp3 => '通用有损音频';

  @override
  String get formatDescAac => '高效有损音频';

  @override
  String get formatDescM4a => 'AAC 音频封装';

  @override
  String get formatDescWav => '无损 PCM 音频';

  @override
  String get formatDescFlac => '无损压缩音频';

  @override
  String get formatDescOgg => 'Vorbis 开放音频';

  @override
  String get formatDescOpus => '低延迟高效音频';

  @override
  String get formatDescAc3 => '杜比数字环绕声';

  @override
  String get formatDescWma => 'Windows Media 音频';

  @override
  String get formatDescAiff => 'Apple 无损 PCM';

  @override
  String get formatDescMp2 => 'MPEG 音频层 2';

  @override
  String get formatDescWv => 'WavPack 无损音频';

  @override
  String get formatDescTta => 'True Audio 无损';

  @override
  String get formatDescSpx => 'Speex 语音编码';

  @override
  String get formatDescAmr => '窄带语音音频';

  @override
  String get formatDescAlac => 'Apple 无损音频';

  @override
  String get formatDescCaf => 'Apple Core Audio';

  @override
  String get presetOriginal => '原画';

  @override
  String get preset1080p => '1080p';

  @override
  String get preset720p => '720p';

  @override
  String get preset480p => '480p';

  @override
  String get qualitySmaller => '更小体积';

  @override
  String get qualityStandard => '默认';

  @override
  String get qualityHigher => '更高画质';

  @override
  String get encoderH264Software => 'H.264 软件';

  @override
  String get encoderH265Software => 'H.265 软件';

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
  String get rateQuality => '质量';

  @override
  String get rateVbr => '动态码率';

  @override
  String get rateCbr => '固定码率';

  @override
  String get speedFastest => '极快';

  @override
  String get speedFaster => '更快';

  @override
  String get speedFast => '快';

  @override
  String get speedMedium => '均衡';

  @override
  String get speedSlow => '慢';

  @override
  String get speedSlower => '更慢';

  @override
  String get speedSlowest => '极慢';

  @override
  String get tuneFilm => '电影';

  @override
  String get tuneAnimation => '动画';

  @override
  String get tuneGrain => '保留颗粒';

  @override
  String get tuneStillImage => '静态画面';

  @override
  String get tuneFastDecode => '便于解码';

  @override
  String get tuneZeroLatency => '低延迟';

  @override
  String get pixelYuv420p => '8-bit 4:2:0';

  @override
  String get pixelYuv420p10 => '10-bit 4:2:0';

  @override
  String get scaleBilinear => '双线性';

  @override
  String get scaleBicubic => '双三次';

  @override
  String get scaleLanczos => 'Lanczos';

  @override
  String get deinterlaceOff => '关闭';

  @override
  String get deinterlaceYadif => '去隔行';

  @override
  String get deinterlaceYadifDouble => '去隔行并补帧';

  @override
  String get rotationNone => '不旋转';

  @override
  String get rotationClockwise => '顺时针 90°';

  @override
  String get rotationHalf => '180°';

  @override
  String get rotationCounterClockwise => '逆时针 90°';

  @override
  String get fpsCfr => '固定帧率';

  @override
  String get fpsVfr => '可变帧率';

  @override
  String get keyframeOneSecond => '1 秒';

  @override
  String get keyframeTwoSeconds => '2 秒';

  @override
  String get keyframeFiveSeconds => '5 秒';

  @override
  String get keyframeTenSeconds => '10 秒';

  @override
  String get audioRateQuality => '质量';

  @override
  String get audioRateBitrate => '码率';

  @override
  String get opusApplicationAudio => '音乐';

  @override
  String get opusApplicationVoip => '语音';

  @override
  String get opusApplicationLowdelay => '低延迟';

  @override
  String get opusVbrOn => '动态码率';

  @override
  String get opusVbrConstrained => '受约束动态码率';

  @override
  String get opusVbrOff => '固定码率';

  @override
  String get subtitleNoVideo => '这个文件没有视频流，不能编辑字幕。';

  @override
  String get subtitleNeedOutput => '请填写输出目录和文件名。';

  @override
  String get existingSubtitles => '已有字幕';

  @override
  String get readingSubtitleTracks => '正在读取字幕轨...';

  @override
  String get noEmbeddedSubtitles => '没有内嵌字幕。';

  @override
  String get externalSubtitles => '要添加的外挂字幕';

  @override
  String get addExternalSubtitle => '添加外挂字幕';

  @override
  String get subtitleLanguageHint => '语言，如 chi';

  @override
  String get subtitleTitleHint => '标题';

  @override
  String get subtitleOutputHint => '取消勾选会删除该字幕轨。字幕会写入当前任务的输出。';

  @override
  String get container => '容器';

  @override
  String get webmSubtitleWarning => 'WebM 只保留 WebVTT 文本字幕，样式会丢失。';

  @override
  String get mp4AssWarning => 'MP4/MOV 不能保留 ASS 样式，建议改存为 MKV。';

  @override
  String get mp4TextWarning => 'MP4/MOV 会把文本字幕转成 mov_text，样式会丢失。';

  @override
  String trackIndex(int index) {
    return '轨道 $index';
  }

  @override
  String get subtitleDefault => '默认';

  @override
  String get subtitleForced => '强制';

  @override
  String get subtitleDeleteOnly => '仅可删除';

  @override
  String get errorFfmpegNotFound => '未找到 ffmpeg';

  @override
  String get errorFfmpegNotFoundSpecify => '未找到 ffmpeg，请在设置中指定路径';

  @override
  String errorFfmpegFoundFrom(String source) {
    return '已从$source找到 ffmpeg';
  }

  @override
  String get errorFfmpegInvalidPath => '指定的路径无效，无法运行 ffmpeg';

  @override
  String get errorFfmpegUsingSpecified => '已使用指定的 ffmpeg';

  @override
  String get errorCancelled => '已取消';

  @override
  String get errorConversionFailed => '转换失败';

  @override
  String errorCannotStartFfmpeg(String error) {
    return '无法启动 ffmpeg：$error';
  }

  @override
  String errorFfmpegExitCode(int code) {
    return 'ffmpeg 退出码 $code';
  }

  @override
  String get errorFfprobeNotFound => '未找到 ffprobe';

  @override
  String get errorCannotReadMedia => '无法读取媒体信息';

  @override
  String get errorEncoderInitFailed => '编码器初始化失败';

  @override
  String errorEncoderUnsupported(String vendor) {
    return '当前系统不支持$vendor编码器';
  }

  @override
  String errorEncoderNotCompiled(String vendor) {
    return '当前 ffmpeg 没有编入$vendor编码器';
  }

  @override
  String errorEncoderCheckFailed(String vendor, String error) {
    return '无法检查$vendor编码器：$error';
  }

  @override
  String errorEncoderCanInit(String vendor) {
    return '$vendor编码器可以初始化';
  }

  @override
  String errorUnsupportedSourceVideoCodec(String codec) {
    return '无法按源视频编码（$codec）重新编码';
  }

  @override
  String errorUnsupportedSourceAudioCodec(String codec) {
    return '无法按源音频编码（$codec）重新编码';
  }

  @override
  String get ffmpegSourceSettingsPath => '设置中指定的路径';

  @override
  String get ffmpegSourceManual => '手动指定';

  @override
  String get ffmpegSourceSystemPath => '系统 PATH';

  @override
  String get ffmpegSourceAppDirFfmpeg => '程序目录 ffmpeg';

  @override
  String get ffmpegSourceAppDirFfmpegBin => '程序目录 ffmpeg/bin';

  @override
  String get ffmpegSourceAppDirBin => '程序目录 bin';

  @override
  String get ffmpegSourceAppDir => '程序目录';

  @override
  String get crfFollowsQuality => 'CRF（空则跟随质量档）';

  @override
  String get lockedMobileProfile => 'FLV 和 3GP 固定使用 Baseline / Level 3.0。';

  @override
  String channelCount(int count) {
    return '$count 声道';
  }
}

/// The translations for Chinese, as used in Hong Kong (`zh_HK`).
class AppLocalizationsZhHk extends AppLocalizationsZh {
  AppLocalizationsZhHk() : super('zh_HK');

  @override
  String get appName => '媒體格式轉換器';

  @override
  String get language => '語言';

  @override
  String get languageHint => '切換後即時生效。';

  @override
  String get languageSystem => '跟隨系統';

  @override
  String get about => '關於';

  @override
  String versionLabel(String version) {
    return '版本 $version';
  }

  @override
  String get aboutDescription => '套用本機 FFmpeg 的桌面媒體格式轉換器。';

  @override
  String get close => '關閉';

  @override
  String get ffmpegDocs => 'FFmpeg 文件';

  @override
  String get settings => '設定';

  @override
  String get done => '完成';

  @override
  String get browse => '瀏覽';

  @override
  String get cancel => '取消';

  @override
  String get retry => '重試';

  @override
  String get next => '下一步';

  @override
  String get back => '上一步';

  @override
  String get fileMenu => '檔案';

  @override
  String get aboutMenu => '關於';

  @override
  String get openFile => '開啟檔案';

  @override
  String get exit => '結束';

  @override
  String get aboutThisApp => '關於本軟件';

  @override
  String get addConversionTask => '新增轉換工作';

  @override
  String get editConversionTask => '編輯轉換工作';

  @override
  String get subtitles => '字幕';

  @override
  String get startAll => '全部開始';

  @override
  String get stopAll => '全部停止';

  @override
  String get clearFinished => '清除已完成';

  @override
  String get ffmpegNotDetected => '未偵測到 ffmpeg，請先到設定指定路徑';

  @override
  String get noMediaFiles => '沒有可用的媒體檔案';

  @override
  String get dropMediaFiles => '請拖入音訊或影片檔案。';

  @override
  String ffmpegReadyStatus(String label) {
    return 'ffmpeg 已就緒  ·  $label';
  }

  @override
  String get notReady => '尚未就緒';

  @override
  String queueCount(int count) {
    return '隊列 $count';
  }

  @override
  String runningCount(int running, int concurrency) {
    return '進行中 $running/$concurrency';
  }

  @override
  String failedCount(int count) {
    return '失敗 $count';
  }

  @override
  String get convertToVideo => '轉換為影片';

  @override
  String get convertToAudio => '轉換為音訊';

  @override
  String convertToFormat(String format) {
    return '轉換為 $format';
  }

  @override
  String get queueEmpty => '轉換隊列是空的';

  @override
  String get queueEmptyHint => '開啟檔案、拖入媒體，或點擊左側格式開始新增工作。';

  @override
  String sourcePath(String path) {
    return '來源：$path';
  }

  @override
  String destinationPath(String path) {
    return '目標：$path';
  }

  @override
  String clipRangeLabel(String start, String end) {
    return '剪輯 $start → $end';
  }

  @override
  String subtitleKeepAdd(int kept, int added) {
    return '字幕：保留 $kept 軌，新增 $added 條';
  }

  @override
  String get openInputFolder => '開啟輸入檔案所在資料夾';

  @override
  String get openOutputFolder => '開啟輸出資料夾';

  @override
  String get stop => '停止';

  @override
  String get restart => '重新開始';

  @override
  String get start => '開始';

  @override
  String get delete => '刪除';

  @override
  String get edit => '編輯';

  @override
  String get clip => '剪輯';

  @override
  String elapsed(String time) {
    return '已用 $time';
  }

  @override
  String remaining(String time) {
    return '剩餘 $time';
  }

  @override
  String get statusPending => '未開始';

  @override
  String get statusQueued => '排隊中';

  @override
  String get statusRunning => '轉換中';

  @override
  String get statusCompleted => '已完成';

  @override
  String get statusFailed => '失敗';

  @override
  String get statusCancelled => '已取消';

  @override
  String get ffmpegPath => 'ffmpeg 路徑';

  @override
  String get ffmpegPathHintWindows =>
      '留空則先找程式目錄下的 ffmpeg，再找 PATH 和 Program Files。相對路徑會按程式目錄解析，並按輸入原樣儲存。';

  @override
  String get ffmpegPathHintMacos =>
      '留空則先找程式目錄下的 ffmpeg，再找 PATH、Homebrew 和 /usr/local/bin。相對路徑會按程式目錄解析，並按輸入原樣儲存。';

  @override
  String get ffmpegPathHintLinux =>
      '留空則先找程式目錄下的 ffmpeg，再找 PATH、/usr/bin 和 ~/.local/bin。相對路徑會按程式目錄解析，並按輸入原樣儲存。';

  @override
  String get useThisPath => '使用此路徑';

  @override
  String get redetect => '重新偵測';

  @override
  String get ready => '已就緒';

  @override
  String get taskReady => '準備就緒';

  @override
  String get ffmpegNotFoundTitle => '找不到 ffmpeg';

  @override
  String get ffmpegMissingHintWindows => '轉換前需要先指定或偵測到可用的 ffmpeg.exe。';

  @override
  String get ffmpegMissingHintOther => '轉換前需要先指定或偵測到可用的 ffmpeg。';

  @override
  String get hardwareAcceleration => '硬件加速';

  @override
  String get hardwareAccelerationHint => '開啟後，新建轉換工作會預設使用硬件加速。已新增的工作不會改變。';

  @override
  String get hardwareDefaultOn => '新建工作預設開啟';

  @override
  String get hardwareAfterGpu => '偵測到 GPU 後對新工作生效';

  @override
  String get concurrency => '工作並行數';

  @override
  String get concurrencyHint => '同時執行的 ffmpeg 程序數量。數值越大轉換越快，也更容易打滿 CPU 和磁碟。';

  @override
  String get renameOnConflict => '重名自動重新命名';

  @override
  String renameHint(String token, String padded) {
    return '輸出檔案已存在時會附加序號。$token 是序號，$padded 會補成 01。';
  }

  @override
  String renamePresetFile(String example) {
    return '檔案$example';
  }

  @override
  String get useThisRule => '使用此規則';

  @override
  String renameExample(String example) {
    return '範例：video$example';
  }

  @override
  String get pickMediaFiles => '選擇媒體檔案';

  @override
  String get pickSubtitleFiles => '選擇外掛字幕';

  @override
  String get pickOutputDirectory => '選擇輸出資料夾';

  @override
  String get pickFfmpegExe => '選擇 ffmpeg.exe';

  @override
  String get pickFfmpeg => '選擇 ffmpeg';

  @override
  String clipTitle(String name) {
    return '剪輯  ·  $name';
  }

  @override
  String get play => '播放';

  @override
  String get pause => '暫停';

  @override
  String get minusOneFrame => '-1 格';

  @override
  String get plusOneFrame => '+1 格';

  @override
  String currentPosition(String time) {
    return '目前位置 $time';
  }

  @override
  String get loadingPreview => '正在載入預覽…';

  @override
  String get clipPreviewUnavailable => '影片預覽暫不可用。';

  @override
  String get inPoint => '入點';

  @override
  String get outPoint => '出點';

  @override
  String timecodeAndFrame(String time, int frame) {
    return '$time  ·  第 $frame 格';
  }

  @override
  String get useCurrentFrame => '用目前畫面';

  @override
  String get clearClip => '清除剪輯';

  @override
  String get applyClip => '套用剪輯';

  @override
  String get clearSubtitles => '清除字幕變更';

  @override
  String get applySubtitles => '套用字幕變更';

  @override
  String get subtitleTaskLocked => '進行中或已完成的工作不能編輯字幕。';

  @override
  String get subtitleAudioUnsupported => '音訊工作不支援內嵌字幕。';

  @override
  String get subtitleFormatUnsupported => '目前輸出格式不支援內嵌字幕。';

  @override
  String cannotOpenPreview(String error) {
    return '無法開啟預覽：$error';
  }

  @override
  String get selectFormat => '目標格式';

  @override
  String get selectFormatPlaceholder => '選擇要轉換到的格式';

  @override
  String get video => '影片';

  @override
  String get audio => '音訊';

  @override
  String get inputFiles => '輸入檔案';

  @override
  String get inputFilePath => '輸入檔案路徑';

  @override
  String get addFiles => '新增檔案';

  @override
  String get noFilesYet => '還沒有檔案。點擊新增，或從主頁拖入。';

  @override
  String get reading => '讀取中…';

  @override
  String get outputDirectory => '輸出資料夾';

  @override
  String get outputFileName => '輸出檔名';

  @override
  String outputFileNameExample(String token) {
    return '例如 ${token}_converted';
  }

  @override
  String outputFileNameHint(String token) {
    return '用 $token 表示原檔名。重名仍會按設定附加序號。';
  }

  @override
  String get outputNamePreviewTitle => '轉換後的檔名';

  @override
  String get outputNamePreviewEmpty => '先新增檔案才能預覽轉換後的名稱。';

  @override
  String get outputNamePreviewOriginal => '原檔名';

  @override
  String get outputNamePreviewConverted => '轉換後';

  @override
  String get picture => '畫面';

  @override
  String get output => '輸出';

  @override
  String get noPictureProcessing => '目前目標不會重新處理畫面。';

  @override
  String get copyVideoKeepCopy => '未改畫面或影片參數時，影片仍直接複製。';

  @override
  String get copyVideoWillReencode => '改了畫面或影片參數後會重壓影片；音訊預設仍複製。';

  @override
  String get copyVideoEncoderLocked => '自動時跟隨來源影片編碼，也可以改成其他編碼器。';

  @override
  String copyVideoUnknownCodec(String codec) {
    return '無法識別來源影片編碼（$codec），縮放前需要能識別的編碼。';
  }

  @override
  String get copyAudioKeepCopy => '未改音訊參數時，音訊仍直接複製。';

  @override
  String get copyAudioWillReencode => '改了音訊選項後會重壓音訊；影片預設仍複製。';

  @override
  String get copyAudioEncoderLocked => '音訊編碼鎖定為來源音訊編碼。';

  @override
  String copyAudioUnknownCodec(String codec) {
    return '無法識別來源音訊編碼（$codec），處理音訊前需要能識別的編碼。';
  }

  @override
  String get resolutionPreset => '解像度預設';

  @override
  String get keepAspectRatio => '保持等比縮放';

  @override
  String get scaleAlgorithm => '縮放演算法';

  @override
  String get rotation => '旋轉';

  @override
  String get deinterlace => '去隔行';

  @override
  String get flipHorizontal => '水平翻轉';

  @override
  String get flipVertical => '垂直翻轉';

  @override
  String get noVideoReencode => '目前目標不會重新編碼影片。';

  @override
  String get fixedEncoder => '此格式使用固定編碼器。';

  @override
  String get defaultFps15 => '預設 15';

  @override
  String get hardwareAccel => '硬件加速';

  @override
  String get hardwareAccelOnHint => '開啟後會自動使用本機 GPU 完成解碼、畫面處理和編碼。';

  @override
  String get noGpuEncoder => '沒有偵測到可用的 GPU 編碼器。';

  @override
  String get encoder => '編碼器';

  @override
  String get hardwarePicksEncoder => '硬件加速開啟時會自動選擇 GPU 編碼器。';

  @override
  String get speed => '速度';

  @override
  String get contentTune => '內容最佳化';

  @override
  String get auto => '自動';

  @override
  String get pixelFormat => '像素格式';

  @override
  String get encoder8bitOnly => '目前編碼器只使用 8-bit。';

  @override
  String get rateControl => '位元率控制';

  @override
  String get maxBitrateKbps => '最大位元率 kbps';

  @override
  String get bufsizeKbps => '緩衝 kbps';

  @override
  String get fpsMode => '幀率模式';

  @override
  String get keyframeInterval => '關鍵幀間隔';

  @override
  String get copyAudioNoProcess => '原編碼不會重新處理音訊。';

  @override
  String get audioControl => '音訊控制';

  @override
  String get audioBitrateKbps => '音訊位元率 kbps';

  @override
  String get optionalHint => '可留空';

  @override
  String get amrFixed => 'AMR 固定為 8000 Hz、單聲道、12.2 kbps。';

  @override
  String get mp3Quality => 'MP3 品質 0-9';

  @override
  String get aacQuality => 'AAC 品質 1-5';

  @override
  String get flacCompression => 'FLAC 壓縮 0-12';

  @override
  String get opusRateMode => 'Opus 位元率模式';

  @override
  String get opusApplicationField => 'Opus 用途';

  @override
  String get sampleRate => '取樣率';

  @override
  String get followSource => '跟隨來源';

  @override
  String get sampleRateNote => '不支援的取樣率會自動就近調整。';

  @override
  String get channels => '聲道';

  @override
  String get mono => '單聲道';

  @override
  String get stereo => '立體聲';

  @override
  String get volumeDb => '音量（dB）';

  @override
  String get loudnessSkipsVolume => '響度標準化開啟時不再疊加音量。';

  @override
  String get loudnessNormalize => '響度標準化';

  @override
  String get fastStart => '最佳化網絡播放（faststart）';

  @override
  String get keepMetadata => '保留元資料';

  @override
  String get keepChapters => '保留章節';

  @override
  String get metadataTitle => '標題';

  @override
  String get metadataArtist => '藝術家';

  @override
  String get metadataAlbum => '專輯';

  @override
  String get metadataYear => '年份';

  @override
  String get metadataComment => '註解';

  @override
  String get qualityPreset => '品質檔';

  @override
  String get custom => '自訂';

  @override
  String get videoBitrateKbps => '影片位元率 kbps';

  @override
  String get required => '必填';

  @override
  String get frameRate => '幀率';

  @override
  String get width => '闊度';

  @override
  String get height => '高度';

  @override
  String get detectingGpu => '正在偵測 GPU 編碼器…';

  @override
  String get noGpuDetected => '未偵測到可用 GPU';

  @override
  String usingGpus(String names) {
    return '使用 $names';
  }

  @override
  String get listSeparator => '、';

  @override
  String get addToQueue => '加入隊列';

  @override
  String get saveTask => '儲存工作';

  @override
  String get wizardStepFormat => '1. 選擇格式';

  @override
  String get wizardStepParams => '2. 參數與檔案';

  @override
  String get unknownResolution => '未知解像度';

  @override
  String get unknownDuration => '未知時長';

  @override
  String get formatCopyCodec => '原編碼';

  @override
  String get formatDescCopyVideo => '保持原容器，預設來源編碼，可改參數；未改動時直接複製';

  @override
  String get formatDescCopyAudio => '保持原容器，預設來源編碼，可改參數；未改動時直接複製';

  @override
  String get formatDescMp4 => '通用影片，兼容性最好';

  @override
  String get formatDescMkv => '開放容器，適合高品質封裝';

  @override
  String get formatDescWebm => '網頁影片，體積更小';

  @override
  String get formatDescMov => 'Apple 生態常用影片';

  @override
  String get formatDescAvi => '傳統影片容器';

  @override
  String get formatDescGif => '動畫圖片，適合短片段';

  @override
  String get formatDescWmv => 'Windows Media 影片';

  @override
  String get formatDescFlv => 'Flash 影片容器';

  @override
  String get formatDescMpeg => 'MPEG 節目流';

  @override
  String get formatDescTs => 'MPEG 傳輸流';

  @override
  String get formatDescM2ts => '藍光傳輸流';

  @override
  String get formatDesc3gp => '手機常用影片';

  @override
  String get formatDescOgv => 'Theora 開放影片';

  @override
  String get formatDescWebp => '動畫 WebP 圖片';

  @override
  String get formatDescMp3 => '通用有損音訊';

  @override
  String get formatDescAac => '高效有損音訊';

  @override
  String get formatDescM4a => 'AAC 音訊封裝';

  @override
  String get formatDescWav => '無損 PCM 音訊';

  @override
  String get formatDescFlac => '無損壓縮音訊';

  @override
  String get formatDescOgg => 'Vorbis 開放音訊';

  @override
  String get formatDescOpus => '低延遲高效音訊';

  @override
  String get formatDescAc3 => '杜比數碼環繞聲';

  @override
  String get formatDescWma => 'Windows Media 音訊';

  @override
  String get formatDescAiff => 'Apple 無損 PCM';

  @override
  String get formatDescMp2 => 'MPEG 音訊層 2';

  @override
  String get formatDescWv => 'WavPack 無損音訊';

  @override
  String get formatDescTta => 'True Audio 無損';

  @override
  String get formatDescSpx => 'Speex 語音編碼';

  @override
  String get formatDescAmr => '窄帶語音音訊';

  @override
  String get formatDescAlac => 'Apple 無損音訊';

  @override
  String get formatDescCaf => 'Apple Core Audio';

  @override
  String get presetOriginal => '原畫';

  @override
  String get preset1080p => '1080p';

  @override
  String get preset720p => '720p';

  @override
  String get preset480p => '480p';

  @override
  String get qualitySmaller => '更小體積';

  @override
  String get qualityStandard => '預設';

  @override
  String get qualityHigher => '更高畫質';

  @override
  String get encoderH264Software => 'H.264 軟件';

  @override
  String get encoderH265Software => 'H.265 軟件';

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
  String get rateQuality => '品質';

  @override
  String get rateVbr => '動態位元率';

  @override
  String get rateCbr => '固定位元率';

  @override
  String get speedFastest => '極快';

  @override
  String get speedFaster => '更快';

  @override
  String get speedFast => '快';

  @override
  String get speedMedium => '均衡';

  @override
  String get speedSlow => '慢';

  @override
  String get speedSlower => '更慢';

  @override
  String get speedSlowest => '極慢';

  @override
  String get tuneFilm => '電影';

  @override
  String get tuneAnimation => '動畫';

  @override
  String get tuneGrain => '保留顆粒';

  @override
  String get tuneStillImage => '靜態畫面';

  @override
  String get tuneFastDecode => '便於解碼';

  @override
  String get tuneZeroLatency => '低延遲';

  @override
  String get pixelYuv420p => '8-bit 4:2:0';

  @override
  String get pixelYuv420p10 => '10-bit 4:2:0';

  @override
  String get scaleBilinear => '雙線性';

  @override
  String get scaleBicubic => '雙三次';

  @override
  String get scaleLanczos => 'Lanczos';

  @override
  String get deinterlaceOff => '關閉';

  @override
  String get deinterlaceYadif => '去隔行';

  @override
  String get deinterlaceYadifDouble => '去隔行並補幀';

  @override
  String get rotationNone => '不旋轉';

  @override
  String get rotationClockwise => '順時針 90°';

  @override
  String get rotationHalf => '180°';

  @override
  String get rotationCounterClockwise => '逆時針 90°';

  @override
  String get fpsCfr => '固定幀率';

  @override
  String get fpsVfr => '可變幀率';

  @override
  String get keyframeOneSecond => '1 秒';

  @override
  String get keyframeTwoSeconds => '2 秒';

  @override
  String get keyframeFiveSeconds => '5 秒';

  @override
  String get keyframeTenSeconds => '10 秒';

  @override
  String get audioRateQuality => '品質';

  @override
  String get audioRateBitrate => '位元率';

  @override
  String get opusApplicationAudio => '音樂';

  @override
  String get opusApplicationVoip => '語音';

  @override
  String get opusApplicationLowdelay => '低延遲';

  @override
  String get opusVbrOn => '動態位元率';

  @override
  String get opusVbrConstrained => '受約束動態位元率';

  @override
  String get opusVbrOff => '固定位元率';

  @override
  String get subtitleNoVideo => '這個檔案沒有影片串流，不能編輯字幕。';

  @override
  String get subtitleNeedOutput => '請填寫輸出資料夾和檔名。';

  @override
  String get existingSubtitles => '已有字幕';

  @override
  String get readingSubtitleTracks => '正在讀取字幕軌...';

  @override
  String get noEmbeddedSubtitles => '沒有內嵌字幕。';

  @override
  String get externalSubtitles => '要新增的外掛字幕';

  @override
  String get addExternalSubtitle => '新增外掛字幕';

  @override
  String get subtitleLanguageHint => '語言，如 chi';

  @override
  String get subtitleTitleHint => '標題';

  @override
  String get subtitleOutputHint => '取消剔選會刪除該字幕軌。字幕會寫入目前工作的輸出。';

  @override
  String get container => '容器';

  @override
  String get webmSubtitleWarning => 'WebM 只保留 WebVTT 文字字幕，樣式會遺失。';

  @override
  String get mp4AssWarning => 'MP4/MOV 不能保留 ASS 樣式，建議改存為 MKV。';

  @override
  String get mp4TextWarning => 'MP4/MOV 會把文字字幕轉成 mov_text，樣式會遺失。';

  @override
  String trackIndex(int index) {
    return '軌道 $index';
  }

  @override
  String get subtitleDefault => '預設';

  @override
  String get subtitleForced => '強制';

  @override
  String get subtitleDeleteOnly => '僅可刪除';

  @override
  String get errorFfmpegNotFound => '找不到 ffmpeg';

  @override
  String get errorFfmpegNotFoundSpecify => '找不到 ffmpeg，請在設定中指定路徑';

  @override
  String errorFfmpegFoundFrom(String source) {
    return '已從$source找到 ffmpeg';
  }

  @override
  String get errorFfmpegInvalidPath => '指定的路徑無效，無法執行 ffmpeg';

  @override
  String get errorFfmpegUsingSpecified => '已使用指定的 ffmpeg';

  @override
  String get errorCancelled => '已取消';

  @override
  String get errorConversionFailed => '轉換失敗';

  @override
  String errorCannotStartFfmpeg(String error) {
    return '無法啟動 ffmpeg：$error';
  }

  @override
  String errorFfmpegExitCode(int code) {
    return 'ffmpeg 結束代碼 $code';
  }

  @override
  String get errorFfprobeNotFound => '找不到 ffprobe';

  @override
  String get errorCannotReadMedia => '無法讀取媒體資訊';

  @override
  String get errorEncoderInitFailed => '編碼器初始化失敗';

  @override
  String errorEncoderUnsupported(String vendor) {
    return '目前系統不支援$vendor編碼器';
  }

  @override
  String errorEncoderNotCompiled(String vendor) {
    return '目前 ffmpeg 沒有編入$vendor編碼器';
  }

  @override
  String errorEncoderCheckFailed(String vendor, String error) {
    return '無法檢查$vendor編碼器：$error';
  }

  @override
  String errorEncoderCanInit(String vendor) {
    return '$vendor編碼器可以初始化';
  }

  @override
  String errorUnsupportedSourceVideoCodec(String codec) {
    return '無法按來源影片編碼（$codec）重新編碼';
  }

  @override
  String errorUnsupportedSourceAudioCodec(String codec) {
    return '無法按來源音訊編碼（$codec）重新編碼';
  }

  @override
  String get ffmpegSourceSettingsPath => '設定中指定的路徑';

  @override
  String get ffmpegSourceManual => '手動指定';

  @override
  String get ffmpegSourceSystemPath => '系統 PATH';

  @override
  String get ffmpegSourceAppDirFfmpeg => '程式目錄 ffmpeg';

  @override
  String get ffmpegSourceAppDirFfmpegBin => '程式目錄 ffmpeg/bin';

  @override
  String get ffmpegSourceAppDirBin => '程式目錄 bin';

  @override
  String get ffmpegSourceAppDir => '程式目錄';

  @override
  String get crfFollowsQuality => 'CRF（留空則跟隨品質檔）';

  @override
  String get lockedMobileProfile => 'FLV 和 3GP 固定使用 Baseline / Level 3.0。';

  @override
  String channelCount(int count) {
    return '$count 聲道';
  }
}

/// The translations for Chinese, as used in Taiwan (`zh_TW`).
class AppLocalizationsZhTw extends AppLocalizationsZh {
  AppLocalizationsZhTw() : super('zh_TW');

  @override
  String get appName => '媒體格式轉換器';

  @override
  String get language => '語言';

  @override
  String get languageHint => '切換後立即生效。';

  @override
  String get languageSystem => '跟隨系統';

  @override
  String get about => '關於';

  @override
  String versionLabel(String version) {
    return '版本 $version';
  }

  @override
  String get aboutDescription => '套用本機 FFmpeg 的桌面媒體格式轉換器。';

  @override
  String get close => '關閉';

  @override
  String get ffmpegDocs => 'FFmpeg 文件';

  @override
  String get settings => '設定';

  @override
  String get done => '完成';

  @override
  String get browse => '瀏覽';

  @override
  String get cancel => '取消';

  @override
  String get retry => '重試';

  @override
  String get next => '下一步';

  @override
  String get back => '上一步';

  @override
  String get fileMenu => '檔案';

  @override
  String get aboutMenu => '關於';

  @override
  String get openFile => '開啟檔案';

  @override
  String get exit => '結束';

  @override
  String get aboutThisApp => '關於本軟體';

  @override
  String get addConversionTask => '新增轉換工作';

  @override
  String get editConversionTask => '編輯轉換工作';

  @override
  String get subtitles => '字幕';

  @override
  String get startAll => '全部開始';

  @override
  String get stopAll => '全部停止';

  @override
  String get clearFinished => '清除已完成';

  @override
  String get ffmpegNotDetected => '未偵測到 ffmpeg，請先到設定指定路徑';

  @override
  String get noMediaFiles => '沒有可用的媒體檔案';

  @override
  String get dropMediaFiles => '請拖入音訊或影片檔案。';

  @override
  String ffmpegReadyStatus(String label) {
    return 'ffmpeg 已就緒  ·  $label';
  }

  @override
  String get notReady => '尚未就緒';

  @override
  String queueCount(int count) {
    return '佇列 $count';
  }

  @override
  String runningCount(int running, int concurrency) {
    return '進行中 $running/$concurrency';
  }

  @override
  String failedCount(int count) {
    return '失敗 $count';
  }

  @override
  String get convertToVideo => '轉換為影片';

  @override
  String get convertToAudio => '轉換為音訊';

  @override
  String convertToFormat(String format) {
    return '轉換為 $format';
  }

  @override
  String get queueEmpty => '轉換佇列是空的';

  @override
  String get queueEmptyHint => '開啟檔案、拖入媒體，或點擊左側格式開始新增工作。';

  @override
  String sourcePath(String path) {
    return '來源：$path';
  }

  @override
  String destinationPath(String path) {
    return '目標：$path';
  }

  @override
  String clipRangeLabel(String start, String end) {
    return '剪輯 $start → $end';
  }

  @override
  String subtitleKeepAdd(int kept, int added) {
    return '字幕：保留 $kept 軌，新增 $added 條';
  }

  @override
  String get openInputFolder => '開啟輸入檔案所在資料夾';

  @override
  String get openOutputFolder => '開啟輸出資料夾';

  @override
  String get stop => '停止';

  @override
  String get restart => '重新開始';

  @override
  String get start => '開始';

  @override
  String get delete => '刪除';

  @override
  String get edit => '編輯';

  @override
  String get clip => '剪輯';

  @override
  String elapsed(String time) {
    return '已用 $time';
  }

  @override
  String remaining(String time) {
    return '剩餘 $time';
  }

  @override
  String get statusPending => '未開始';

  @override
  String get statusQueued => '排隊中';

  @override
  String get statusRunning => '轉換中';

  @override
  String get statusCompleted => '已完成';

  @override
  String get statusFailed => '失敗';

  @override
  String get statusCancelled => '已取消';

  @override
  String get ffmpegPath => 'ffmpeg 路徑';

  @override
  String get ffmpegPathHintWindows =>
      '留空則先找程式目錄下的 ffmpeg，再找 PATH 和 Program Files。相對路徑會按程式目錄解析，並按輸入原樣儲存。';

  @override
  String get ffmpegPathHintMacos =>
      '留空則先找程式目錄下的 ffmpeg，再找 PATH、Homebrew 和 /usr/local/bin。相對路徑會按程式目錄解析，並按輸入原樣儲存。';

  @override
  String get ffmpegPathHintLinux =>
      '留空則先找程式目錄下的 ffmpeg，再找 PATH、/usr/bin 和 ~/.local/bin。相對路徑會按程式目錄解析，並按輸入原樣儲存。';

  @override
  String get useThisPath => '使用此路徑';

  @override
  String get redetect => '重新偵測';

  @override
  String get ready => '已就緒';

  @override
  String get taskReady => '準備就緒';

  @override
  String get ffmpegNotFoundTitle => '找不到 ffmpeg';

  @override
  String get ffmpegMissingHintWindows => '轉換前需要先指定或偵測到可用的 ffmpeg.exe。';

  @override
  String get ffmpegMissingHintOther => '轉換前需要先指定或偵測到可用的 ffmpeg。';

  @override
  String get hardwareAcceleration => '硬體加速';

  @override
  String get hardwareAccelerationHint => '開啟後，新建轉換工作會預設使用硬體加速。已新增的工作不會改變。';

  @override
  String get hardwareDefaultOn => '新建工作預設開啟';

  @override
  String get hardwareAfterGpu => '偵測到 GPU 後對新工作生效';

  @override
  String get concurrency => '工作並行數';

  @override
  String get concurrencyHint => '同時執行的 ffmpeg 程序數量。數值越大轉換越快，也更容易打滿 CPU 和磁碟。';

  @override
  String get renameOnConflict => '重名自動重新命名';

  @override
  String renameHint(String token, String padded) {
    return '輸出檔案已存在時會附加序號。$token 是序號，$padded 會補成 01。';
  }

  @override
  String renamePresetFile(String example) {
    return '檔案$example';
  }

  @override
  String get useThisRule => '使用此規則';

  @override
  String renameExample(String example) {
    return '範例：video$example';
  }

  @override
  String get pickMediaFiles => '選擇媒體檔案';

  @override
  String get pickSubtitleFiles => '選擇外掛字幕';

  @override
  String get pickOutputDirectory => '選擇輸出資料夾';

  @override
  String get pickFfmpegExe => '選擇 ffmpeg.exe';

  @override
  String get pickFfmpeg => '選擇 ffmpeg';

  @override
  String clipTitle(String name) {
    return '剪輯  ·  $name';
  }

  @override
  String get play => '播放';

  @override
  String get pause => '暫停';

  @override
  String get minusOneFrame => '-1 格';

  @override
  String get plusOneFrame => '+1 格';

  @override
  String currentPosition(String time) {
    return '目前位置 $time';
  }

  @override
  String get loadingPreview => '正在載入預覽…';

  @override
  String get clipPreviewUnavailable => '影片預覽暫不可用。';

  @override
  String get inPoint => '入點';

  @override
  String get outPoint => '出點';

  @override
  String timecodeAndFrame(String time, int frame) {
    return '$time  ·  第 $frame 格';
  }

  @override
  String get useCurrentFrame => '用目前畫面';

  @override
  String get clearClip => '清除剪輯';

  @override
  String get applyClip => '套用剪輯';

  @override
  String get clearSubtitles => '清除字幕變更';

  @override
  String get applySubtitles => '套用字幕變更';

  @override
  String get subtitleTaskLocked => '進行中或已完成的工作不能編輯字幕。';

  @override
  String get subtitleAudioUnsupported => '音訊工作不支援內嵌字幕。';

  @override
  String get subtitleFormatUnsupported => '目前輸出格式不支援內嵌字幕。';

  @override
  String cannotOpenPreview(String error) {
    return '無法開啟預覽：$error';
  }

  @override
  String get selectFormat => '目標格式';

  @override
  String get selectFormatPlaceholder => '選擇要轉換到的格式';

  @override
  String get video => '影片';

  @override
  String get audio => '音訊';

  @override
  String get inputFiles => '輸入檔案';

  @override
  String get inputFilePath => '輸入檔案路徑';

  @override
  String get addFiles => '新增檔案';

  @override
  String get noFilesYet => '還沒有檔案。點擊新增，或從首頁拖入。';

  @override
  String get reading => '讀取中…';

  @override
  String get outputDirectory => '輸出資料夾';

  @override
  String get outputFileName => '輸出檔名';

  @override
  String outputFileNameExample(String token) {
    return '例如 ${token}_converted';
  }

  @override
  String outputFileNameHint(String token) {
    return '用 $token 表示原檔名。重名仍會按設定附加序號。';
  }

  @override
  String get outputNamePreviewTitle => '轉換後的檔名';

  @override
  String get outputNamePreviewEmpty => '先新增檔案才能預覽轉換後的名稱。';

  @override
  String get outputNamePreviewOriginal => '原檔名';

  @override
  String get outputNamePreviewConverted => '轉換後';

  @override
  String get picture => '畫面';

  @override
  String get output => '輸出';

  @override
  String get noPictureProcessing => '目前目標不會重新處理畫面。';

  @override
  String get copyVideoKeepCopy => '未改畫面或影片參數時，影片仍直接複製。';

  @override
  String get copyVideoWillReencode => '改了畫面或影片參數後會重壓影片；音訊預設仍複製。';

  @override
  String get copyVideoEncoderLocked => '自動時跟隨來源影片編碼，也可以改成其他編碼器。';

  @override
  String copyVideoUnknownCodec(String codec) {
    return '無法識別來源影片編碼（$codec），縮放前需要能識別的編碼。';
  }

  @override
  String get copyAudioKeepCopy => '未改音訊參數時，音訊仍直接複製。';

  @override
  String get copyAudioWillReencode => '改了音訊選項後會重壓音訊；影片預設仍複製。';

  @override
  String get copyAudioEncoderLocked => '音訊編碼鎖定為來源音訊編碼。';

  @override
  String copyAudioUnknownCodec(String codec) {
    return '無法識別來源音訊編碼（$codec），處理音訊前需要能識別的編碼。';
  }

  @override
  String get resolutionPreset => '解析度預設';

  @override
  String get keepAspectRatio => '保持等比縮放';

  @override
  String get scaleAlgorithm => '縮放演算法';

  @override
  String get rotation => '旋轉';

  @override
  String get deinterlace => '去交錯';

  @override
  String get flipHorizontal => '水平翻轉';

  @override
  String get flipVertical => '垂直翻轉';

  @override
  String get noVideoReencode => '目前目標不會重新編碼影片。';

  @override
  String get fixedEncoder => '此格式使用固定編碼器。';

  @override
  String get defaultFps15 => '預設 15';

  @override
  String get hardwareAccel => '硬體加速';

  @override
  String get hardwareAccelOnHint => '開啟後會自動使用本機 GPU 完成解碼、畫面處理和編碼。';

  @override
  String get noGpuEncoder => '沒有偵測到可用的 GPU 編碼器。';

  @override
  String get encoder => '編碼器';

  @override
  String get hardwarePicksEncoder => '硬體加速開啟時會自動選擇 GPU 編碼器。';

  @override
  String get speed => '速度';

  @override
  String get contentTune => '內容最佳化';

  @override
  String get auto => '自動';

  @override
  String get pixelFormat => '像素格式';

  @override
  String get encoder8bitOnly => '目前編碼器只使用 8-bit。';

  @override
  String get rateControl => '位元率控制';

  @override
  String get maxBitrateKbps => '最大位元率 kbps';

  @override
  String get bufsizeKbps => '緩衝 kbps';

  @override
  String get fpsMode => '影格率模式';

  @override
  String get keyframeInterval => '關鍵影格間隔';

  @override
  String get copyAudioNoProcess => '原編碼不會重新處理音訊。';

  @override
  String get audioControl => '音訊控制';

  @override
  String get audioBitrateKbps => '音訊位元率 kbps';

  @override
  String get optionalHint => '可留空';

  @override
  String get amrFixed => 'AMR 固定為 8000 Hz、單聲道、12.2 kbps。';

  @override
  String get mp3Quality => 'MP3 品質 0-9';

  @override
  String get aacQuality => 'AAC 品質 1-5';

  @override
  String get flacCompression => 'FLAC 壓縮 0-12';

  @override
  String get opusRateMode => 'Opus 位元率模式';

  @override
  String get opusApplicationField => 'Opus 用途';

  @override
  String get sampleRate => '取樣率';

  @override
  String get followSource => '跟隨來源';

  @override
  String get sampleRateNote => '不支援的取樣率會自動就近調整。';

  @override
  String get channels => '聲道';

  @override
  String get mono => '單聲道';

  @override
  String get stereo => '立體聲';

  @override
  String get volumeDb => '音量（dB）';

  @override
  String get loudnessSkipsVolume => '響度標準化開啟時不再疊加音量。';

  @override
  String get loudnessNormalize => '響度標準化';

  @override
  String get fastStart => '最佳化網路播放（faststart）';

  @override
  String get keepMetadata => '保留中繼資料';

  @override
  String get keepChapters => '保留章節';

  @override
  String get metadataTitle => '標題';

  @override
  String get metadataArtist => '藝術家';

  @override
  String get metadataAlbum => '專輯';

  @override
  String get metadataYear => '年份';

  @override
  String get metadataComment => '註解';

  @override
  String get qualityPreset => '品質檔';

  @override
  String get custom => '自訂';

  @override
  String get videoBitrateKbps => '影片位元率 kbps';

  @override
  String get required => '必填';

  @override
  String get frameRate => '影格率';

  @override
  String get width => '寬度';

  @override
  String get height => '高度';

  @override
  String get detectingGpu => '正在偵測 GPU 編碼器…';

  @override
  String get noGpuDetected => '未偵測到可用 GPU';

  @override
  String usingGpus(String names) {
    return '使用 $names';
  }

  @override
  String get listSeparator => '、';

  @override
  String get addToQueue => '加入佇列';

  @override
  String get saveTask => '儲存工作';

  @override
  String get wizardStepFormat => '1. 選擇格式';

  @override
  String get wizardStepParams => '2. 參數與檔案';

  @override
  String get unknownResolution => '未知解析度';

  @override
  String get unknownDuration => '未知時長';

  @override
  String get formatCopyCodec => '原編碼';

  @override
  String get formatDescCopyVideo => '保持原容器，預設來源編碼，可改參數；未改動時直接複製';

  @override
  String get formatDescCopyAudio => '保持原容器，預設來源編碼，可改參數；未改動時直接複製';

  @override
  String get formatDescMp4 => '通用影片，相容性最好';

  @override
  String get formatDescMkv => '開放容器，適合高品質封裝';

  @override
  String get formatDescWebm => '網頁影片，體積更小';

  @override
  String get formatDescMov => 'Apple 生態常用影片';

  @override
  String get formatDescAvi => '傳統影片容器';

  @override
  String get formatDescGif => '動畫圖片，適合短片段';

  @override
  String get formatDescWmv => 'Windows Media 影片';

  @override
  String get formatDescFlv => 'Flash 影片容器';

  @override
  String get formatDescMpeg => 'MPEG 節目串流';

  @override
  String get formatDescTs => 'MPEG 傳輸串流';

  @override
  String get formatDescM2ts => '藍光傳輸串流';

  @override
  String get formatDesc3gp => '手機常用影片';

  @override
  String get formatDescOgv => 'Theora 開放影片';

  @override
  String get formatDescWebp => '動畫 WebP 圖片';

  @override
  String get formatDescMp3 => '通用有損音訊';

  @override
  String get formatDescAac => '高效有損音訊';

  @override
  String get formatDescM4a => 'AAC 音訊封裝';

  @override
  String get formatDescWav => '無損 PCM 音訊';

  @override
  String get formatDescFlac => '無損壓縮音訊';

  @override
  String get formatDescOgg => 'Vorbis 開放音訊';

  @override
  String get formatDescOpus => '低延遲高效音訊';

  @override
  String get formatDescAc3 => '杜比數位環繞聲';

  @override
  String get formatDescWma => 'Windows Media 音訊';

  @override
  String get formatDescAiff => 'Apple 無損 PCM';

  @override
  String get formatDescMp2 => 'MPEG 音訊層 2';

  @override
  String get formatDescWv => 'WavPack 無損音訊';

  @override
  String get formatDescTta => 'True Audio 無損';

  @override
  String get formatDescSpx => 'Speex 語音編碼';

  @override
  String get formatDescAmr => '窄頻語音音訊';

  @override
  String get formatDescAlac => 'Apple 無損音訊';

  @override
  String get formatDescCaf => 'Apple Core Audio';

  @override
  String get presetOriginal => '原畫';

  @override
  String get preset1080p => '1080p';

  @override
  String get preset720p => '720p';

  @override
  String get preset480p => '480p';

  @override
  String get qualitySmaller => '更小體積';

  @override
  String get qualityStandard => '預設';

  @override
  String get qualityHigher => '更高畫質';

  @override
  String get encoderH264Software => 'H.264 軟體';

  @override
  String get encoderH265Software => 'H.265 軟體';

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
  String get rateQuality => '品質';

  @override
  String get rateVbr => '動態位元率';

  @override
  String get rateCbr => '固定位元率';

  @override
  String get speedFastest => '極快';

  @override
  String get speedFaster => '更快';

  @override
  String get speedFast => '快';

  @override
  String get speedMedium => '均衡';

  @override
  String get speedSlow => '慢';

  @override
  String get speedSlower => '更慢';

  @override
  String get speedSlowest => '極慢';

  @override
  String get tuneFilm => '電影';

  @override
  String get tuneAnimation => '動畫';

  @override
  String get tuneGrain => '保留顆粒';

  @override
  String get tuneStillImage => '靜態畫面';

  @override
  String get tuneFastDecode => '便於解碼';

  @override
  String get tuneZeroLatency => '低延遲';

  @override
  String get pixelYuv420p => '8-bit 4:2:0';

  @override
  String get pixelYuv420p10 => '10-bit 4:2:0';

  @override
  String get scaleBilinear => '雙線性';

  @override
  String get scaleBicubic => '雙三次';

  @override
  String get scaleLanczos => 'Lanczos';

  @override
  String get deinterlaceOff => '關閉';

  @override
  String get deinterlaceYadif => '去交錯';

  @override
  String get deinterlaceYadifDouble => '去交錯並補幀';

  @override
  String get rotationNone => '不旋轉';

  @override
  String get rotationClockwise => '順時針 90°';

  @override
  String get rotationHalf => '180°';

  @override
  String get rotationCounterClockwise => '逆時針 90°';

  @override
  String get fpsCfr => '固定影格率';

  @override
  String get fpsVfr => '可變影格率';

  @override
  String get keyframeOneSecond => '1 秒';

  @override
  String get keyframeTwoSeconds => '2 秒';

  @override
  String get keyframeFiveSeconds => '5 秒';

  @override
  String get keyframeTenSeconds => '10 秒';

  @override
  String get audioRateQuality => '品質';

  @override
  String get audioRateBitrate => '位元率';

  @override
  String get opusApplicationAudio => '音樂';

  @override
  String get opusApplicationVoip => '語音';

  @override
  String get opusApplicationLowdelay => '低延遲';

  @override
  String get opusVbrOn => '動態位元率';

  @override
  String get opusVbrConstrained => '受約束動態位元率';

  @override
  String get opusVbrOff => '固定位元率';

  @override
  String get subtitleNoVideo => '這個檔案沒有影片串流，不能編輯字幕。';

  @override
  String get subtitleNeedOutput => '請填寫輸出資料夾和檔名。';

  @override
  String get existingSubtitles => '已有字幕';

  @override
  String get readingSubtitleTracks => '正在讀取字幕軌...';

  @override
  String get noEmbeddedSubtitles => '沒有內嵌字幕。';

  @override
  String get externalSubtitles => '要新增的外掛字幕';

  @override
  String get addExternalSubtitle => '新增外掛字幕';

  @override
  String get subtitleLanguageHint => '語言，如 chi';

  @override
  String get subtitleTitleHint => '標題';

  @override
  String get subtitleOutputHint => '取消勾選會刪除該字幕軌。字幕會寫入目前工作的輸出。';

  @override
  String get container => '容器';

  @override
  String get webmSubtitleWarning => 'WebM 只保留 WebVTT 文字字幕，樣式會遺失。';

  @override
  String get mp4AssWarning => 'MP4/MOV 不能保留 ASS 樣式，建議改存為 MKV。';

  @override
  String get mp4TextWarning => 'MP4/MOV 會把文字字幕轉成 mov_text，樣式會遺失。';

  @override
  String trackIndex(int index) {
    return '軌道 $index';
  }

  @override
  String get subtitleDefault => '預設';

  @override
  String get subtitleForced => '強制';

  @override
  String get subtitleDeleteOnly => '僅可刪除';

  @override
  String get errorFfmpegNotFound => '找不到 ffmpeg';

  @override
  String get errorFfmpegNotFoundSpecify => '找不到 ffmpeg，請在設定中指定路徑';

  @override
  String errorFfmpegFoundFrom(String source) {
    return '已從$source找到 ffmpeg';
  }

  @override
  String get errorFfmpegInvalidPath => '指定的路徑無效，無法執行 ffmpeg';

  @override
  String get errorFfmpegUsingSpecified => '已使用指定的 ffmpeg';

  @override
  String get errorCancelled => '已取消';

  @override
  String get errorConversionFailed => '轉換失敗';

  @override
  String errorCannotStartFfmpeg(String error) {
    return '無法啟動 ffmpeg：$error';
  }

  @override
  String errorFfmpegExitCode(int code) {
    return 'ffmpeg 結束代碼 $code';
  }

  @override
  String get errorFfprobeNotFound => '找不到 ffprobe';

  @override
  String get errorCannotReadMedia => '無法讀取媒體資訊';

  @override
  String get errorEncoderInitFailed => '編碼器初始化失敗';

  @override
  String errorEncoderUnsupported(String vendor) {
    return '目前系統不支援$vendor編碼器';
  }

  @override
  String errorEncoderNotCompiled(String vendor) {
    return '目前 ffmpeg 沒有編入$vendor編碼器';
  }

  @override
  String errorEncoderCheckFailed(String vendor, String error) {
    return '無法檢查$vendor編碼器：$error';
  }

  @override
  String errorEncoderCanInit(String vendor) {
    return '$vendor編碼器可以初始化';
  }

  @override
  String errorUnsupportedSourceVideoCodec(String codec) {
    return '無法按來源影片編碼（$codec）重新編碼';
  }

  @override
  String errorUnsupportedSourceAudioCodec(String codec) {
    return '無法按來源音訊編碼（$codec）重新編碼';
  }

  @override
  String get ffmpegSourceSettingsPath => '設定中指定的路徑';

  @override
  String get ffmpegSourceManual => '手動指定';

  @override
  String get ffmpegSourceSystemPath => '系統 PATH';

  @override
  String get ffmpegSourceAppDirFfmpeg => '程式目錄 ffmpeg';

  @override
  String get ffmpegSourceAppDirFfmpegBin => '程式目錄 ffmpeg/bin';

  @override
  String get ffmpegSourceAppDirBin => '程式目錄 bin';

  @override
  String get ffmpegSourceAppDir => '程式目錄';

  @override
  String get crfFollowsQuality => 'CRF（留空則跟隨品質檔）';

  @override
  String get lockedMobileProfile => 'FLV 和 3GP 固定使用 Baseline / Level 3.0。';

  @override
  String channelCount(int count) {
    return '$count 聲道';
  }
}

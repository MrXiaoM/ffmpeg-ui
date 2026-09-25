import '../../l10n/app_localizations.dart';
import '../models/conversion_task.dart';
import '../models/encode_options.dart';
import '../models/media_format.dart';
import '../models/media_info.dart';
import '../models/subtitle_track.dart';
import 'app_language.dart';
import 'app_messages.dart';

String languageOptionLabel(AppLocalizations l10n, AppLanguage language) {
  if (language.followsSystem) {
    return l10n.languageSystem;
  }
  return language.nativeName;
}

String formatLabel(AppLocalizations l10n, MediaFormat format) {
  if (format.id == 'copy-video' || format.id == 'copy-audio') {
    return l10n.formatCopyCodec;
  }
  return format.label;
}

String formatDescription(AppLocalizations l10n, MediaFormat format) {
  return switch (format.id) {
    'copy-video' => l10n.formatDescCopyVideo,
    'copy-audio' => l10n.formatDescCopyAudio,
    'mp4' => l10n.formatDescMp4,
    'mkv' => l10n.formatDescMkv,
    'webm' => l10n.formatDescWebm,
    'mov' => l10n.formatDescMov,
    'avi' => l10n.formatDescAvi,
    'gif' => l10n.formatDescGif,
    'wmv' => l10n.formatDescWmv,
    'flv' => l10n.formatDescFlv,
    'mpeg' => l10n.formatDescMpeg,
    'ts' => l10n.formatDescTs,
    'm2ts' => l10n.formatDescM2ts,
    '3gp' => l10n.formatDesc3gp,
    'ogv' => l10n.formatDescOgv,
    'webp' => l10n.formatDescWebp,
    'mp3' => l10n.formatDescMp3,
    'aac' => l10n.formatDescAac,
    'm4a' => l10n.formatDescM4a,
    'wav' => l10n.formatDescWav,
    'flac' => l10n.formatDescFlac,
    'ogg' => l10n.formatDescOgg,
    'opus' => l10n.formatDescOpus,
    'ac3' => l10n.formatDescAc3,
    'wma' => l10n.formatDescWma,
    'aiff' => l10n.formatDescAiff,
    'mp2' => l10n.formatDescMp2,
    'wv' => l10n.formatDescWv,
    'tta' => l10n.formatDescTta,
    'spx' => l10n.formatDescSpx,
    'amr' => l10n.formatDescAmr,
    'alac' => l10n.formatDescAlac,
    'caf' => l10n.formatDescCaf,
    _ => format.description,
  };
}

String taskStatusLabel(AppLocalizations l10n, TaskStatus status) {
  return switch (status) {
    TaskStatus.pending => l10n.statusPending,
    TaskStatus.queued => l10n.statusQueued,
    TaskStatus.running => l10n.statusRunning,
    TaskStatus.completed => l10n.statusCompleted,
    TaskStatus.failed => l10n.statusFailed,
    TaskStatus.cancelled => l10n.statusCancelled,
  };
}

String mediaResolutionLabel(AppLocalizations l10n, MediaInfo info) {
  if (info.width == null || info.height == null) {
    return l10n.unknownResolution;
  }
  return '${info.width}x${info.height}';
}

String mediaDurationLabel(AppLocalizations l10n, MediaInfo info) {
  if (info.duration == null) {
    return l10n.unknownDuration;
  }
  return info.durationLabel;
}

String subtitleDisabledReason(AppLocalizations l10n, ConversionTask task) {
  if (!task.canEdit) {
    return l10n.subtitleTaskLocked;
  }
  if (!task.targetFormat.isVideo || task.outputContainerFormat.isAudio) {
    return l10n.subtitleAudioUnsupported;
  }
  return l10n.subtitleFormatUnsupported;
}

String subtitleProbeError(AppLocalizations l10n, MediaInfo? info) {
  if (info == null) {
    return '';
  }
  if (info.error != null && info.error!.isNotEmpty) {
    return localizeMessage(l10n, info.error);
  }
  if (!info.hasVideo) {
    return l10n.subtitleNoVideo;
  }
  return '';
}

String subtitleActionMessage(AppLocalizations l10n, ConversionTask task) {
  if (!task.canEditSubtitles) {
    return subtitleDisabledReason(l10n, task);
  }
  final edit = task.subtitleEdit;
  if (edit == null) {
    return l10n.subtitles;
  }
  return l10n.subtitleKeepAdd(edit.keepIndexes.length, edit.additions.length);
}

String subtitleTrackSummary(AppLocalizations l10n, SubtitleTrack track) {
  final bits = <String>[
    l10n.trackIndex(track.index),
    if (track.language != null && track.language!.isNotEmpty) track.language!,
    track.codecLabel,
    if (track.title != null && track.title!.isNotEmpty) track.title!,
    if (track.isDefault) l10n.subtitleDefault,
    if (track.isForced) l10n.subtitleForced,
    if (!track.isText) l10n.subtitleDeleteOnly,
  ];
  return bits.join(' · ');
}

String outputPresetLabel(AppLocalizations l10n, OutputPreset preset) {
  return switch (preset) {
    OutputPreset.original => l10n.presetOriginal,
    OutputPreset.p1080 => l10n.preset1080p,
    OutputPreset.p720 => l10n.preset720p,
    OutputPreset.p480 => l10n.preset480p,
    OutputPreset.custom => l10n.custom,
  };
}

String qualityPresetLabel(AppLocalizations l10n, QualityPreset preset) {
  return switch (preset) {
    QualityPreset.smaller => l10n.qualitySmaller,
    QualityPreset.standard => l10n.qualityStandard,
    QualityPreset.higher => l10n.qualityHigher,
    QualityPreset.custom => l10n.custom,
  };
}

String videoEncoderLabel(AppLocalizations l10n, VideoEncoderChoice value) {
  return switch (value) {
    VideoEncoderChoice.auto => l10n.auto,
    VideoEncoderChoice.h264 => l10n.encoderH264Software,
    VideoEncoderChoice.h265 => l10n.encoderH265Software,
    VideoEncoderChoice.h264Nvenc => l10n.encoderH264Nvidia,
    VideoEncoderChoice.h265Nvenc => l10n.encoderH265Nvidia,
    VideoEncoderChoice.h264Amf => l10n.encoderH264Amd,
    VideoEncoderChoice.h265Amf => l10n.encoderH265Amd,
    VideoEncoderChoice.h264Qsv => l10n.encoderH264Intel,
    VideoEncoderChoice.h265Qsv => l10n.encoderH265Intel,
    VideoEncoderChoice.h264Vaapi => l10n.encoderH264Vaapi,
    VideoEncoderChoice.h265Vaapi => l10n.encoderH265Vaapi,
    VideoEncoderChoice.h264Videotoolbox => l10n.encoderH264Videotoolbox,
    VideoEncoderChoice.h265Videotoolbox => l10n.encoderH265Videotoolbox,
    VideoEncoderChoice.vp9 => l10n.encoderVp9,
    VideoEncoderChoice.av1 => l10n.encoderAv1,
  };
}

String rateControlLabel(AppLocalizations l10n, RateControlMode value) {
  return switch (value) {
    RateControlMode.quality => l10n.rateQuality,
    RateControlMode.vbr => l10n.rateVbr,
    RateControlMode.cbr => l10n.rateCbr,
  };
}

String encoderSpeedLabel(AppLocalizations l10n, EncoderSpeed value) {
  return switch (value) {
    EncoderSpeed.auto => l10n.auto,
    EncoderSpeed.fastest => l10n.speedFastest,
    EncoderSpeed.faster => l10n.speedFaster,
    EncoderSpeed.fast => l10n.speedFast,
    EncoderSpeed.medium => l10n.speedMedium,
    EncoderSpeed.slow => l10n.speedSlow,
    EncoderSpeed.slower => l10n.speedSlower,
    EncoderSpeed.slowest => l10n.speedSlowest,
  };
}

String videoTuneLabel(AppLocalizations l10n, VideoTune value) {
  return switch (value) {
    VideoTune.auto => l10n.auto,
    VideoTune.film => l10n.tuneFilm,
    VideoTune.animation => l10n.tuneAnimation,
    VideoTune.grain => l10n.tuneGrain,
    VideoTune.stillimage => l10n.tuneStillImage,
    VideoTune.fastdecode => l10n.tuneFastDecode,
    VideoTune.zerolatency => l10n.tuneZeroLatency,
  };
}

String pixelFormatLabel(AppLocalizations l10n, PixelFormatChoice value) {
  return switch (value) {
    PixelFormatChoice.auto => l10n.auto,
    PixelFormatChoice.yuv420p => l10n.pixelYuv420p,
    PixelFormatChoice.yuv420p10 => l10n.pixelYuv420p10,
  };
}

String scaleFlagsLabel(AppLocalizations l10n, ScaleFlags value) {
  return switch (value) {
    ScaleFlags.auto => l10n.auto,
    ScaleFlags.bilinear => l10n.scaleBilinear,
    ScaleFlags.bicubic => l10n.scaleBicubic,
    ScaleFlags.lanczos => l10n.scaleLanczos,
  };
}

String deinterlaceLabel(AppLocalizations l10n, DeinterlaceMode value) {
  return switch (value) {
    DeinterlaceMode.off => l10n.deinterlaceOff,
    DeinterlaceMode.yadif => l10n.deinterlaceYadif,
    DeinterlaceMode.yadifDouble => l10n.deinterlaceYadifDouble,
  };
}

String rotationLabel(AppLocalizations l10n, VideoRotation value) {
  return switch (value) {
    VideoRotation.none => l10n.rotationNone,
    VideoRotation.clockwise => l10n.rotationClockwise,
    VideoRotation.half => l10n.rotationHalf,
    VideoRotation.counterClockwise => l10n.rotationCounterClockwise,
  };
}

String fpsModeLabel(AppLocalizations l10n, FpsModeChoice value) {
  return switch (value) {
    FpsModeChoice.auto => l10n.followSource,
    FpsModeChoice.cfr => l10n.fpsCfr,
    FpsModeChoice.vfr => l10n.fpsVfr,
  };
}

String keyframeIntervalLabel(AppLocalizations l10n, KeyframeInterval value) {
  return switch (value) {
    KeyframeInterval.auto => l10n.auto,
    KeyframeInterval.oneSecond => l10n.keyframeOneSecond,
    KeyframeInterval.twoSeconds => l10n.keyframeTwoSeconds,
    KeyframeInterval.fiveSeconds => l10n.keyframeFiveSeconds,
    KeyframeInterval.tenSeconds => l10n.keyframeTenSeconds,
  };
}

String audioRateModeLabel(AppLocalizations l10n, AudioRateMode value) {
  return switch (value) {
    AudioRateMode.quality => l10n.audioRateQuality,
    AudioRateMode.bitrate => l10n.audioRateBitrate,
  };
}

String opusApplicationLabel(AppLocalizations l10n, OpusApplication value) {
  return switch (value) {
    OpusApplication.audio => l10n.opusApplicationAudio,
    OpusApplication.voip => l10n.opusApplicationVoip,
    OpusApplication.lowdelay => l10n.opusApplicationLowdelay,
  };
}

String opusVbrLabel(AppLocalizations l10n, OpusVbrMode value) {
  return switch (value) {
    OpusVbrMode.on => l10n.opusVbrOn,
    OpusVbrMode.constrained => l10n.opusVbrConstrained,
    OpusVbrMode.off => l10n.opusVbrOff,
  };
}

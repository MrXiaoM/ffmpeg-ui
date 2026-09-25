import 'encode_options.dart';
import 'media_format.dart';

bool encodeNeedsVideoProcessing(EncodeOptions encode) {
  return encode.width != null ||
      encode.height != null ||
      encode.rotation != VideoRotation.none ||
      encode.flipHorizontal ||
      encode.flipVertical ||
      encode.deinterlace != DeinterlaceMode.off ||
      encode.frameRate != null ||
      encode.fpsMode != FpsModeChoice.auto ||
      encode.keyframeInterval != KeyframeInterval.auto ||
      encode.videoEncoder != VideoEncoderChoice.auto ||
      encode.qualityPreset != QualityPreset.standard ||
      encode.crf != null ||
      encode.videoBitrateKbps != null ||
      encode.rateControl != RateControlMode.quality ||
      encode.speed != EncoderSpeed.auto ||
      encode.tune != VideoTune.auto ||
      encode.h264Profile != H264ProfileChoice.auto ||
      encode.pixelFormat != PixelFormatChoice.auto ||
      encode.maxRateKbps != null ||
      encode.bufSizeKbps != null;
}

bool encodeNeedsAudioProcessing(EncodeOptions encode) {
  return encode.volumeDb != 0 ||
      encode.loudnessNormalize ||
      encode.sampleRate != null ||
      encode.channels != null ||
      encode.audioBitrateKbps != null ||
      encode.audioQuality != null ||
      encode.audioRateMode != AudioRateMode.bitrate ||
      encode.flacCompression != 5 ||
      encode.opusVbr != OpusVbrMode.on ||
      encode.opusApplication != OpusApplication.audio;
}

String? normalizeCodecName(String? codec) {
  final value = codec?.trim().toLowerCase();
  if (value == null || value.isEmpty) {
    return null;
  }
  return value;
}

VideoEncoderChoice? videoEncoderForSourceCodec(String? codec) {
  switch (normalizeCodecName(codec)) {
    case 'h264':
    case 'avc':
    case 'avc1':
      return VideoEncoderChoice.h264;
    case 'hevc':
    case 'h265':
    case 'hev1':
    case 'hvc1':
      return VideoEncoderChoice.h265;
    case 'vp9':
    case 'vp9.2':
      return VideoEncoderChoice.vp9;
    case 'av1':
    case 'av01':
      return VideoEncoderChoice.av1;
    default:
      return null;
  }
}

MediaFormat? audioFormatForSourceCodec(String? codec) {
  switch (normalizeCodecName(codec)) {
    case 'aac':
      return MediaFormat.aac;
    case 'mp3':
    case 'mp3float':
      return MediaFormat.mp3;
    case 'ac3':
      return MediaFormat.ac3;
    case 'flac':
      return MediaFormat.flac;
    case 'opus':
    case 'libopus':
      return MediaFormat.opus;
    case 'vorbis':
      return MediaFormat.ogg;
    case 'pcm_s16le':
    case 'pcm_s16be':
    case 'pcm_s24le':
    case 'pcm_s24be':
    case 'pcm_s32le':
    case 'pcm_f32le':
    case 'pcm_f64le':
      return MediaFormat.wav;
    case 'alac':
      return MediaFormat.alac;
    case 'wmav1':
    case 'wmav2':
      return MediaFormat.wma;
    case 'mp2':
    case 'mp2float':
      return MediaFormat.mp2;
    case 'wavpack':
      return MediaFormat.wv;
    case 'tta':
      return MediaFormat.tta;
    default:
      return null;
  }
}

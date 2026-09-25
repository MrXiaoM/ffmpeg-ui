import '../../l10n/app_localizations.dart';
import '../ffmpeg/ffmpeg_locator.dart';

class AppMessage {
  static const ffmpegNotFound = 'errorFfmpegNotFound';
  static const ffmpegNotFoundSpecify = 'errorFfmpegNotFoundSpecify';
  static const ffmpegFoundFrom = 'errorFfmpegFoundFrom';
  static const ffmpegInvalidPath = 'errorFfmpegInvalidPath';
  static const ffmpegUsingSpecified = 'errorFfmpegUsingSpecified';
  static const cancelled = 'errorCancelled';
  static const conversionFailed = 'errorConversionFailed';
  static const cannotStartFfmpeg = 'errorCannotStartFfmpeg';
  static const ffmpegExitCode = 'errorFfmpegExitCode';
  static const ffprobeNotFound = 'errorFfprobeNotFound';
  static const cannotReadMedia = 'errorCannotReadMedia';
  static const encoderInitFailed = 'errorEncoderInitFailed';
  static const encoderUnsupported = 'errorEncoderUnsupported';
  static const encoderNotCompiled = 'errorEncoderNotCompiled';
  static const encoderCheckFailed = 'errorEncoderCheckFailed';
  static const encoderCanInit = 'errorEncoderCanInit';
  static const unsupportedSourceVideoCodec = 'errorUnsupportedSourceVideoCodec';
  static const unsupportedSourceAudioCodec = 'errorUnsupportedSourceAudioCodec';

  static const sourceSettingsPath = 'ffmpegSourceSettingsPath';
  static const sourceManual = 'ffmpegSourceManual';
  static const sourceSystemPath = 'ffmpegSourceSystemPath';
  static const sourceAppDirFfmpeg = 'ffmpegSourceAppDirFfmpeg';
  static const sourceAppDirFfmpegBin = 'ffmpegSourceAppDirFfmpegBin';
  static const sourceAppDirBin = 'ffmpegSourceAppDirBin';
  static const sourceAppDir = 'ffmpegSourceAppDir';
}

const _messagePrefix = 'msg:';

String encodeAppMessage(String key, [List<String> args = const []]) {
  if (args.isEmpty) {
    return '$_messagePrefix$key';
  }
  return '$_messagePrefix$key|${args.join('\u001f')}';
}

bool isAppMessage(String? value) {
  return value != null && value.startsWith(_messagePrefix);
}

String localizeMessage(AppLocalizations l10n, String? message) {
  if (message == null || message.isEmpty) {
    return '';
  }
  if (!isAppMessage(message)) {
    return message;
  }
  final payload = message.substring(_messagePrefix.length);
  final parts = payload.split('|');
  final key = parts.first;
  final args = parts.length > 1 ? parts.sublist(1)[0].split('\u001f') : const <String>[];
  return switch (key) {
    AppMessage.ffmpegNotFound => l10n.errorFfmpegNotFound,
    AppMessage.ffmpegNotFoundSpecify => l10n.errorFfmpegNotFoundSpecify,
    AppMessage.ffmpegFoundFrom => l10n.errorFfmpegFoundFrom(
      args.isEmpty ? '' : localizeFfmpegSource(l10n, args.first),
    ),
    AppMessage.ffmpegInvalidPath => l10n.errorFfmpegInvalidPath,
    AppMessage.ffmpegUsingSpecified => l10n.errorFfmpegUsingSpecified,
    AppMessage.cancelled => l10n.errorCancelled,
    AppMessage.conversionFailed => l10n.errorConversionFailed,
    AppMessage.cannotStartFfmpeg => l10n.errorCannotStartFfmpeg(
      args.isEmpty ? '' : args.first,
    ),
    AppMessage.ffmpegExitCode => l10n.errorFfmpegExitCode(
      args.isEmpty ? 0 : int.tryParse(args.first) ?? 0,
    ),
    AppMessage.ffprobeNotFound => l10n.errorFfprobeNotFound,
    AppMessage.cannotReadMedia => l10n.errorCannotReadMedia,
    AppMessage.encoderInitFailed => l10n.errorEncoderInitFailed,
    AppMessage.encoderUnsupported => l10n.errorEncoderUnsupported(
      args.isEmpty ? '' : args.first,
    ),
    AppMessage.encoderNotCompiled => l10n.errorEncoderNotCompiled(
      args.isEmpty ? '' : args.first,
    ),
    AppMessage.encoderCheckFailed => l10n.errorEncoderCheckFailed(
      args.isEmpty ? '' : args.first,
      args.length < 2 ? '' : args[1],
    ),
    AppMessage.encoderCanInit => l10n.errorEncoderCanInit(
      args.isEmpty ? '' : args.first,
    ),
    AppMessage.unsupportedSourceVideoCodec =>
      l10n.errorUnsupportedSourceVideoCodec(
        args.isEmpty ? '' : args.first,
      ),
    AppMessage.unsupportedSourceAudioCodec =>
      l10n.errorUnsupportedSourceAudioCodec(
        args.isEmpty ? '' : args.first,
      ),
    _ => message,
  };
}

String localizeFfmpegSource(AppLocalizations l10n, String source) {
  return switch (source) {
    AppMessage.sourceSettingsPath => l10n.ffmpegSourceSettingsPath,
    AppMessage.sourceManual => l10n.ffmpegSourceManual,
    AppMessage.sourceSystemPath => l10n.ffmpegSourceSystemPath,
    AppMessage.sourceAppDirFfmpeg => l10n.ffmpegSourceAppDirFfmpeg,
    AppMessage.sourceAppDirFfmpegBin => l10n.ffmpegSourceAppDirFfmpegBin,
    AppMessage.sourceAppDirBin => l10n.ffmpegSourceAppDirBin,
    AppMessage.sourceAppDir => l10n.ffmpegSourceAppDir,
    _ => source,
  };
}

String localizedFfmpegSource(AppLocalizations l10n, FfmpegLocation location) {
  return localizeFfmpegSource(l10n, location.source);
}

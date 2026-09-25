import 'dart:io';

import '../l10n/app_messages.dart';
import '../models/media_info.dart';
import 'ffprobe_parser.dart';

class FfprobeService {
  const FfprobeService();

  Future<MediaInfo> probe(String ffprobePath, String inputPath) async {
    if (ffprobePath.isEmpty) {
      return MediaInfo(
        path: inputPath,
        error: encodeAppMessage(AppMessage.ffprobeNotFound),
      );
    }
    try {
      final result = await Process.run(
        ffprobePath,
        [
          '-v',
          'error',
          '-print_format',
          'json',
          '-show_format',
          '-show_streams',
          inputPath,
        ],
        runInShell: false,
        stdoutEncoding: null,
        stderrEncoding: null,
      );
      return parseFfprobeOutput(
        path: inputPath,
        stdout: result.stdout,
        stderr: result.stderr,
        exitCode: result.exitCode,
      );
    } catch (error) {
      return mediaInfoFromProbeFailure(inputPath, error.toString());
    }
  }
}

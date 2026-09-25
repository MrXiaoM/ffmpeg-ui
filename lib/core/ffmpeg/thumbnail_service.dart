import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class ThumbnailService {
  static const maxEdge = 320;
  static const jpegQuality = 6;

  Future<String?> capture({
    required String ffmpegPath,
    required String inputPath,
    required String taskId,
    Duration at = const Duration(seconds: 1),
  }) async {
    if (ffmpegPath.isEmpty) {
      return null;
    }
    try {
      final dir = await getTemporaryDirectory();
      final stamp = at.inMilliseconds;
      final output = p.join(dir.path, 'ffmpeg_ui', '${taskId}_$stamp.jpg');
      await Directory(p.dirname(output)).create(recursive: true);
      final result = await Process.run(
        ffmpegPath,
        buildArguments(
          inputPath: inputPath,
          outputPath: output,
          at: at,
        ),
        runInShell: false,
      );
      if (result.exitCode != 0 || !File(output).existsSync()) {
        return null;
      }
      return output;
    } catch (_) {
      return null;
    }
  }

  static List<String> buildArguments({
    required String inputPath,
    required String outputPath,
    Duration at = const Duration(seconds: 1),
  }) {
    return [
      '-hide_banner',
      '-loglevel',
      'error',
      '-ss',
      (at.inMilliseconds / 1000).toStringAsFixed(3),
      '-i',
      inputPath,
      '-frames:v',
      '1',
      '-vf',
      'scale=min($maxEdge\\,iw):-2',
      '-q:v',
      '$jpegQuality',
      '-y',
      outputPath,
    ];
  }
}

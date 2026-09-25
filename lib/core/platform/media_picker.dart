import 'dart:io';

import 'package:file_picker/file_picker.dart';

import '../models/media_format.dart';
import '../models/subtitle_track.dart';

Future<List<String>> pickMediaFiles({
  String? dialogTitle,
  bool allowMultiple = true,
}) async {
  final result = await FilePicker.pickFiles(
    allowMultiple: allowMultiple,
    type: FileType.custom,
    allowedExtensions: mediaExtensions.toList(),
    dialogTitle: dialogTitle,
    lockParentWindow: true,
  );
  if (result == null) {
    return const [];
  }
  return result.files
      .map((file) => file.path)
      .whereType<String>()
      .where(isMediaPath)
      .toList(growable: false);
}

Future<List<String>> pickSubtitleFiles({String? dialogTitle}) async {
  final result = await FilePicker.pickFiles(
    allowMultiple: true,
    type: FileType.custom,
    allowedExtensions: subtitleExtensions.toList(),
    dialogTitle: dialogTitle,
    lockParentWindow: true,
  );
  if (result == null) {
    return const [];
  }
  return result.files
      .map((file) => file.path)
      .whereType<String>()
      .where(isSubtitlePath)
      .toList(growable: false);
}

Future<String?> pickDirectory({String? initialDirectory, String? dialogTitle}) {
  return FilePicker.getDirectoryPath(
    dialogTitle: dialogTitle,
    initialDirectory: initialDirectory,
    lockParentWindow: true,
  );
}

Future<String?> pickExecutable({String? dialogTitle}) async {
  final result = await FilePicker.pickFiles(
    allowMultiple: false,
    type: Platform.isWindows ? FileType.custom : FileType.any,
    allowedExtensions: Platform.isWindows ? const ['exe'] : null,
    dialogTitle: dialogTitle,
    lockParentWindow: true,
  );
  return result?.files.single.path;
}

String ffmpegPathPlaceholder() {
  if (Platform.isWindows) {
    return r'C:\ffmpeg\bin\ffmpeg.exe';
  }
  if (Platform.isMacOS) {
    return '/opt/homebrew/bin/ffmpeg';
  }
  return '/usr/bin/ffmpeg';
}


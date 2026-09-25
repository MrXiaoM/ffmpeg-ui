import 'dart:io';

import 'package:path/path.dart' as p;

import '../models/app_settings.dart';
import '../models/media_format.dart';

String normalizeFsPath(String path) {
  final trimmed = path.trim();
  if (trimmed.isEmpty) {
    return trimmed;
  }
  return p.normalize(trimmed);
}

String joinFsPath(String first, String second) {
  return normalizeFsPath(p.join(first, second));
}

String fileNameOf(String path) {
  return p.basename(path);
}

String fileStemOf(String path) {
  return p.basenameWithoutExtension(path);
}

String directoryOf(String path) {
  return normalizeFsPath(p.dirname(path));
}

String extensionOf(String path) {
  return p.extension(path).toLowerCase();
}

const defaultOutputNameTemplate = '{name}_converted';

String applyOutputNameTemplate(
  String template,
  String inputPath, {
  required String extension,
}) {
  final trimmed = template.trim();
  final resolved = (trimmed.isEmpty ? defaultOutputNameTemplate : trimmed)
      .replaceAll('{name}', fileStemOf(inputPath));
  return ensureOutputExtension(resolved, extension);
}

String ensureOutputExtension(String fileName, String extension) {
  final name = fileName.trim();
  if (name.isEmpty) {
    return ensureOutputExtension(defaultOutputNameTemplate, extension);
  }
  if (extension.isEmpty) {
    return name;
  }
  final current = extensionOf(name);
  if (current.isEmpty) {
    return '$name$extension';
  }
  if (current == extension.toLowerCase()) {
    return name;
  }
  return '${fileStemOf(name)}$extension';
}

String outputExtensionFor(MediaFormat format, String inputPath) {
  return format.keepsSourceCodec ? extensionOf(inputPath) : format.extension;
}

String pathKey(String path) {
  final normalized = normalizeFsPath(path);
  return Platform.isWindows ? normalized.toLowerCase() : normalized;
}

String uniqueOutputPath(
  String directory,
  String fileName, {
  String pattern = AppSettings.defaultRenamePattern,
}) {
  final dir = normalizeFsPath(directory);
  final settings = AppSettings(renamePattern: pattern);
  final stem = p.basenameWithoutExtension(fileName);
  final ext = p.extension(fileName);
  var candidate = joinFsPath(dir, fileName);
  var index = 1;
  while (File(candidate).existsSync()) {
    candidate = joinFsPath(dir, settings.renameWithNumber(stem, ext, index));
    index += 1;
  }
  return candidate;
}

String uniqueFileName(String directory, String fileName) {
  return p.basename(uniqueOutputPath(directory, fileName));
}

String quoteArg(String value) {
  if (Platform.isWindows) {
    if (value.contains(' ') || value.contains('"')) {
      return '"${value.replaceAll('"', r'\"')}"';
    }
    return value;
  }
  if (value.isEmpty) {
    return "''";
  }
  if (RegExp(r"[^\w@%+=:,./-]").hasMatch(value)) {
    return "'${value.replaceAll("'", r"'\''")}'";
  }
  return value;
}

import 'dart:io';

import 'fs_paths.dart';

Future<void> revealInExplorer(String path) async {
  final normalized = normalizeFsPath(path);
  if (Platform.isMacOS) {
    final entity = FileSystemEntity.typeSync(normalized);
    if (entity == FileSystemEntityType.file) {
      await Process.start('open', ['-R', normalized], runInShell: false);
      return;
    }
    await Process.start('open', [
      entity == FileSystemEntityType.notFound ? directoryOf(normalized) : normalized,
    ], runInShell: false);
    return;
  }
  if (Platform.isLinux) {
    final entity = FileSystemEntity.typeSync(normalized);
    final target = entity == FileSystemEntityType.notFound
        ? directoryOf(normalized)
        : normalized;
    if (entity == FileSystemEntityType.file) {
      final started = await _tryStart('xdg-open', [directoryOf(normalized)]);
      if (started) {
        return;
      }
    }
    await _tryStart('xdg-open', [target]);
    return;
  }

  final entity = FileSystemEntity.typeSync(normalized);
  if (entity == FileSystemEntityType.notFound) {
    await Process.start('explorer.exe', [
      directoryOf(normalized),
    ], runInShell: false);
    return;
  }
  if (entity == FileSystemEntityType.directory) {
    await Process.start('explorer.exe', [normalized], runInShell: false);
    return;
  }
  await Process.start('explorer.exe', [
    '/select,',
    normalized,
  ], runInShell: false);
}

Future<void> openDirectory(String path) async {
  final normalized = normalizeFsPath(path);
  if (Platform.isMacOS) {
    await Process.start('open', [normalized], runInShell: false);
    return;
  }
  if (Platform.isLinux) {
    await _tryStart('xdg-open', [normalized]);
    return;
  }
  await Process.start('explorer.exe', [normalized], runInShell: false);
}

Future<bool> _tryStart(String executable, List<String> arguments) async {
  try {
    await Process.start(executable, arguments, runInShell: false);
    return true;
  } catch (_) {
    return false;
  }
}

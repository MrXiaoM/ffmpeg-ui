import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

import '../l10n/app_messages.dart';

class FfmpegLocation {
  const FfmpegLocation({
    required this.ffmpegPath,
    required this.ffprobePath,
    required this.source,
    this.version,
  });

  final String ffmpegPath;
  final String ffprobePath;
  final String source;
  final String? version;

  bool get isReady => ffmpegPath.isNotEmpty;
}

class FfmpegLocator {
  String get _ffmpegName => Platform.isWindows ? 'ffmpeg.exe' : 'ffmpeg';
  String get _ffprobeName => Platform.isWindows ? 'ffprobe.exe' : 'ffprobe';

  Future<FfmpegLocation?> detect({String? preferredPath}) async {
    final candidates = <_Candidate>[];
    if (preferredPath != null && preferredPath.trim().isNotEmpty) {
      candidates.add(
        _Candidate(preferredPath.trim(), AppMessage.sourceSettingsPath),
      );
    }
    candidates.addAll(_applicationDirectoryCandidates());
    candidates.addAll(await _pathCandidates());
    candidates.addAll(_systemHintCandidates());

    final seen = <String>{};
    for (final candidate in candidates) {
      final resolved = _resolveFfmpeg(candidate.path);
      if (resolved == null) {
        continue;
      }
      final key = Platform.isWindows ? resolved.toLowerCase() : resolved;
      if (!seen.add(key)) {
        continue;
      }
      final version = await _readVersion(resolved);
      if (version == null) {
        continue;
      }
      return FfmpegLocation(
        ffmpegPath: resolved,
        ffprobePath: resolveFfprobe(resolved) ?? '',
        source: candidate.source,
        version: version,
      );
    }
    return null;
  }

  Future<FfmpegLocation?> validate(String path) async {
    final resolved = _resolveFfmpeg(path);
    if (resolved == null) {
      return null;
    }
    final version = await _readVersion(resolved);
    if (version == null) {
      return null;
    }
    return FfmpegLocation(
      ffmpegPath: resolved,
      ffprobePath: resolveFfprobe(resolved) ?? '',
      source: AppMessage.sourceManual,
      version: version,
    );
  }

  String resolveForUse(String raw) {
    var path = _nativeSeparators(raw.trim());
    if (path.isEmpty || _isAbsolute(path)) {
      return path;
    }
    return p.normalize(p.join(_applicationDirectory(), path));
  }

  String storedPath(String raw) {
    return _nativeSeparators(raw.trim());
  }

  String _nativeSeparators(String path) {
    if (Platform.isWindows) {
      return path.replaceAll('/', '\\');
    }
    return path.replaceAll('\\', '/');
  }

  String? _resolveFfmpeg(String raw) {
    final path = resolveForUse(raw);
    if (path.isEmpty) {
      return null;
    }
    final file = File(path);
    if (file.existsSync() && _looksLikeFfmpeg(path)) {
      return file.absolute.path;
    }
    final dir = Directory(path);
    if (dir.existsSync()) {
      final nested = [
        p.join(path, _ffmpegName),
        p.join(path, 'bin', _ffmpegName),
        p.join(path, 'ffmpeg', _ffmpegName),
        p.join(path, 'ffmpeg', 'bin', _ffmpegName),
      ];
      for (final item in nested) {
        if (File(item).existsSync()) {
          return File(item).absolute.path;
        }
      }
    }
    return null;
  }

  String? resolveFfprobe(String ffmpegPath) {
    return resolveFfprobePath(
      ffmpegPath: ffmpegPath,
      ffprobeName: _ffprobeName,
      pathEnv: Platform.environment['PATH'] ?? '',
      pathSeparator: Platform.isWindows ? ';' : ':',
      exists: (path) => File(path).existsSync(),
      absolutePath: (path) => File(path).absolute.path,
    );
  }

  bool _looksLikeFfmpeg(String path) {
    final name = p.basename(path);
    if (Platform.isWindows) {
      return name.toLowerCase() == 'ffmpeg.exe';
    }
    return name == 'ffmpeg';
  }

  Future<List<_Candidate>> _pathCandidates() async {
    final command = Platform.isWindows ? 'where' : 'which';
    try {
      final result = await Process.run(command, [
        _ffmpegName,
      ], runInShell: true);
      if (result.exitCode != 0) {
        return const [];
      }
      return LineSplitter.split(result.stdout.toString())
          .map((line) => line.trim())
          .where((line) => line.isNotEmpty)
          .map((line) => _Candidate(line, AppMessage.sourceSystemPath))
          .toList(growable: false);
    } catch (_) {
      return const [];
    }
  }

  String _applicationDirectory() {
    return File(Platform.resolvedExecutable).parent.path;
  }

  bool _isAbsolute(String path) {
    return p.isAbsolute(path) ||
        (Platform.isWindows && RegExp(r'^[A-Za-z]:[\\/]').hasMatch(path));
  }

  List<_Candidate> _applicationDirectoryCandidates() {
    final exeDir = _applicationDirectory();
    return [
      _Candidate(
        p.join(exeDir, 'ffmpeg', _ffmpegName),
        AppMessage.sourceAppDirFfmpeg,
      ),
      _Candidate(
        p.join(exeDir, 'ffmpeg', 'bin', _ffmpegName),
        AppMessage.sourceAppDirFfmpegBin,
      ),
      _Candidate(
        p.join(exeDir, 'bin', _ffmpegName),
        AppMessage.sourceAppDirBin,
      ),
      _Candidate(p.join(exeDir, _ffmpegName), AppMessage.sourceAppDir),
    ];
  }

  List<_Candidate> _systemHintCandidates() {
    if (Platform.isWindows) {
      return _windowsHintCandidates();
    }
    return _unixHintCandidates();
  }

  List<_Candidate> _unixHintCandidates() {
    final home = Platform.environment['HOME'] ?? '';
    final roots = <String>[
      '/usr/bin',
      '/usr/local/bin',
      '/opt/homebrew/bin',
      '/opt/homebrew/opt/ffmpeg/bin',
      '/opt/local/bin',
      '/snap/bin',
      '/opt/ffmpeg/bin',
      if (home.isNotEmpty) p.join(home, '.local', 'bin'),
      if (home.isNotEmpty) p.join(home, 'bin'),
    ];
    return [
      for (final root in roots)
        _Candidate(p.join(root, _ffmpegName), root),
    ];
  }

  List<_Candidate> _windowsHintCandidates() {
    final roots = <String>[
      Platform.environment['ProgramFiles'] ?? r'C:\Program Files',
      Platform.environment['ProgramFiles(x86)'] ?? r'C:\Program Files (x86)',
      Platform.environment['LocalAppData'] ?? '',
    ].where((item) => item.isNotEmpty).toList(growable: false);

    final relative = <String>[
      'ffmpeg.exe',
      p.join('ffmpeg', 'ffmpeg.exe'),
      p.join('ffmpeg', 'bin', 'ffmpeg.exe'),
      p.join('FFmpeg', 'ffmpeg.exe'),
      p.join('FFmpeg', 'bin', 'ffmpeg.exe'),
      p.join('Gyan', 'FFmpeg', 'bin', 'ffmpeg.exe'),
    ];

    final candidates = <_Candidate>[];
    for (final root in roots) {
      for (final item in relative) {
        candidates.add(_Candidate(p.join(root, item), root));
      }
      final rootDir = Directory(root);
      if (!rootDir.existsSync()) {
        continue;
      }
      try {
        for (final entity in rootDir.listSync(followLinks: false)) {
          if (entity is! Directory) {
            continue;
          }
          final name = p.basename(entity.path).toLowerCase();
          if (!name.contains('ffmpeg')) {
            continue;
          }
          candidates.addAll([
            _Candidate(p.join(entity.path, 'ffmpeg.exe'), entity.path),
            _Candidate(p.join(entity.path, 'bin', 'ffmpeg.exe'), entity.path),
          ]);
        }
      } on FileSystemException {
        // Ignore folders we cannot scan.
      }
    }
    return candidates;
  }

  Future<String?> _readVersion(String ffmpegPath) async {
    try {
      final result = await Process.run(ffmpegPath, [
        '-version',
      ], runInShell: false);
      if (result.exitCode != 0 && result.stdout.toString().isEmpty) {
        return null;
      }
      final firstLine = const LineSplitter()
          .convert(result.stdout.toString())
          .where((line) => line.trim().isNotEmpty)
          .firstOrNull;
      return firstLine?.trim();
    } catch (_) {
      return null;
    }
  }
}

String? resolveFfprobePath({
  required String ffmpegPath,
  required String ffprobeName,
  required String pathEnv,
  required String pathSeparator,
  required bool Function(String path) exists,
  required String Function(String path) absolutePath,
}) {
  final context = pathSeparator == ';' ? p.windows : p.posix;
  final seen = <String>{};
  bool tryAdd(String candidate) {
    final normalized = candidate.trim();
    if (normalized.isEmpty || !seen.add(normalized)) {
      return false;
    }
    if (!exists(normalized)) {
      return false;
    }
    return true;
  }

  final local = context.join(context.dirname(ffmpegPath), ffprobeName);
  if (tryAdd(local)) {
    return absolutePath(local);
  }
  for (final directory in pathEnv.split(pathSeparator)) {
    final trimmed = directory.trim();
    if (trimmed.isEmpty) {
      continue;
    }
    final candidate = context.join(trimmed, ffprobeName);
    if (tryAdd(candidate)) {
      return absolutePath(candidate);
    }
  }
  return null;
}

class _Candidate {
  const _Candidate(this.path, this.source);

  final String path;
  final String source;
}

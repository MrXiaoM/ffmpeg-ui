import '../platform/fs_paths.dart';
import 'clip_range.dart';
import 'encode_options.dart';
import 'media_format.dart';
import 'subtitle_track.dart';

enum TaskStatus { pending, queued, running, completed, failed, cancelled }

class ConversionTask {
  const ConversionTask({
    required this.id,
    required this.inputPath,
    required this.outputDirectory,
    required this.outputFileName,
    required this.targetFormat,
    this.encode = const EncodeOptions(),
    this.clipRange,
    this.subtitleEdit,
    this.status = TaskStatus.pending,
    this.progress = 0,
    this.speed,
    this.eta,
    this.lastLog,
    this.errorMessage,
    this.thumbnailPath,
    this.startedAt,
    required this.createdAt,
  });

  final String id;
  final String inputPath;
  final String outputDirectory;
  final String outputFileName;
  final MediaFormat targetFormat;
  final EncodeOptions encode;
  final ClipRange? clipRange;
  final SubtitleEdit? subtitleEdit;
  final TaskStatus status;
  final double progress;
  final double? speed;
  final Duration? eta;
  final String? lastLog;
  final String? errorMessage;
  final String? thumbnailPath;
  final DateTime? startedAt;
  final DateTime createdAt;

  bool get isRunning => status == TaskStatus.running;
  bool get isPending => status == TaskStatus.pending;
  bool get isQueued => status == TaskStatus.queued;
  bool get canEdit =>
      status == TaskStatus.pending ||
      status == TaskStatus.queued ||
      status == TaskStatus.failed ||
      status == TaskStatus.cancelled;
  bool get canClip => canEdit;
  bool get hasClip => clipRange != null;
  bool get hasSubtitleEdit => subtitleEdit != null;
  MediaFormat get outputContainerFormat {
    if (!targetFormat.keepsSourceCodec) {
      return targetFormat;
    }
    return sourceContainerFormatFor(inputPath) ?? targetFormat;
  }

  bool get supportsEmbeddedSubtitles =>
      outputContainerFormat.supportsEmbeddedSubtitles;
  bool get canEditSubtitles => canEdit && supportsEmbeddedSubtitles;
  bool get canStart => !isRunning;
  bool get canStop => isRunning;
  bool get canDelete => true;

  String get outputPath => joinFsPath(outputDirectory, outputFileName);

  ConversionTask copyWith({
    String? inputPath,
    String? outputDirectory,
    String? outputFileName,
    MediaFormat? targetFormat,
    EncodeOptions? encode,
    ClipRange? clipRange,
    bool clearClipRange = false,
    SubtitleEdit? subtitleEdit,
    bool clearSubtitleEdit = false,
    TaskStatus? status,
    double? progress,
    double? speed,
    bool clearSpeed = false,
    Duration? eta,
    bool clearEta = false,
    String? lastLog,
    bool clearLastLog = false,
    String? errorMessage,
    bool clearError = false,
    String? thumbnailPath,
    DateTime? startedAt,
    bool clearStartedAt = false,
  }) {
    return ConversionTask(
      id: id,
      inputPath: inputPath ?? this.inputPath,
      outputDirectory: outputDirectory ?? this.outputDirectory,
      outputFileName: outputFileName ?? this.outputFileName,
      targetFormat: targetFormat ?? this.targetFormat,
      encode: encode ?? this.encode,
      clipRange: clearClipRange ? null : (clipRange ?? this.clipRange),
      subtitleEdit: clearSubtitleEdit
          ? null
          : (subtitleEdit ?? this.subtitleEdit),
      status: status ?? this.status,
      progress: progress ?? this.progress,
      speed: clearSpeed ? null : (speed ?? this.speed),
      eta: clearEta ? null : (eta ?? this.eta),
      lastLog: clearLastLog ? null : (lastLog ?? this.lastLog),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      startedAt: clearStartedAt ? null : (startedAt ?? this.startedAt),
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'inputPath': inputPath,
      'outputDirectory': outputDirectory,
      'outputFileName': outputFileName,
      'targetFormat': targetFormat.id,
      'encode': encode.toJson(),
      'clipRange': clipRange?.toJson(),
      'subtitleEdit': subtitleEdit?.toJson(),
      'status': status.name,
      'progress': progress,
      'thumbnailPath': thumbnailPath,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ConversionTask.fromJson(Map<String, dynamic> json) {
    final format =
        MediaFormat.byId(json['targetFormat'] as String? ?? 'mp4') ??
        MediaFormat.mp4;
    final statusName = json['status'] as String?;
    var status = TaskStatus.pending;
    for (final value in TaskStatus.values) {
      if (value.name == statusName) {
        status = value;
        break;
      }
    }
    if (status == TaskStatus.running) {
      status = TaskStatus.queued;
    }
    final clipJson = json['clipRange'];
    final subtitleJson = json['subtitleEdit'];
    return ConversionTask(
      id: json['id'] as String,
      inputPath: json['inputPath'] as String,
      outputDirectory: json['outputDirectory'] as String,
      outputFileName: json['outputFileName'] as String,
      targetFormat: format,
      encode: json['encode'] is Map<String, dynamic>
          ? EncodeOptions.fromJson(json['encode'] as Map<String, dynamic>)
          : const EncodeOptions(),
      clipRange: clipJson is Map<String, dynamic>
          ? ClipRange.fromJson(clipJson)
          : null,
      subtitleEdit: subtitleJson is Map<String, dynamic>
          ? SubtitleEdit.fromJson(subtitleJson)
          : null,
      status: status,
      progress: status == TaskStatus.completed
          ? 1
          : ((json['progress'] as num?)?.toDouble() ?? 0),
      thumbnailPath: json['thumbnailPath'] as String?,
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}


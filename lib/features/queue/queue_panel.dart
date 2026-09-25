import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/labels.dart';
import '../../core/models/clip_range.dart';
import '../../core/models/conversion_task.dart';
import '../../core/models/media_format.dart';
import '../../core/platform/fs_paths.dart';
import '../../core/platform/reveal_path.dart';
import '../../core/settings/queue_controller.dart';
import '../../core/settings/settings_controller.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/ui/ui.dart';
import '../../shared/widgets/anchored_tooltip.dart';
import '../../shared/widgets/path_text.dart';
import 'queue_stats.dart';

class QueuePanel extends ConsumerWidget {
  const QueuePanel({
    super.key,
    required this.onEdit,
    required this.onClip,
    required this.onSubtitles,
  });

  final ValueChanged<ConversionTask> onEdit;
  final ValueChanged<ConversionTask> onClip;
  final ValueChanged<ConversionTask> onSubtitles;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final queue = ref.watch(queueControllerProvider);
    if (queue.tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(FluentIcons.video, size: 42, color: AppColors.textMuted),
            const SizedBox(height: 12),
            Text(l10n.queueEmpty, style: appTextStyle(size: 18, weight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text(
              l10n.queueEmptyHint,
              style: appTextStyle(color: AppColors.textMuted),
            ),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(8, 12, 16, 12),
      itemCount: queue.tasks.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final task = queue.tasks[index];
        return QueueTile(
          key: ValueKey(task.id),
          task: task,
          onEdit: () => onEdit(task),
          onClip: () => onClip(task),
          onSubtitles: () => onSubtitles(task),
        );
      },
    );
  }
}

class QueueTile extends ConsumerStatefulWidget {
  const QueueTile({
    super.key,
    required this.task,
    required this.onEdit,
    required this.onClip,
    required this.onSubtitles,
  });

  final ConversionTask task;
  final VoidCallback onEdit;
  final VoidCallback onClip;
  final VoidCallback onSubtitles;

  @override
  ConsumerState<QueueTile> createState() => _QueueTileState();
}

class _QueueTileState extends ConsumerState<QueueTile> {
  Timer? _ticker;
  bool _awaitingThumbnail = false;

  ConversionTask get task => widget.task;

  @override
  void initState() {
    super.initState();
    _syncTicker();
    _requestThumbnail();
  }

  @override
  void didUpdateWidget(QueueTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncTicker();
    if (oldWidget.task.id != task.id ||
        oldWidget.task.thumbnailPath != task.thumbnailPath) {
      _requestThumbnail();
    }
  }

  void _requestThumbnail() {
    final path = task.thumbnailPath;
    if (path != null && File(path).existsSync()) {
      return;
    }
    if (_awaitingThumbnail) {
      return;
    }
    _awaitingThumbnail = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) {
        return;
      }
      try {
        await ref.read(queueControllerProvider.notifier).ensureThumbnail(task.id);
      } finally {
        if (mounted) {
          _awaitingThumbnail = false;
        }
      }
    });
  }

  void _syncTicker() {
    if (task.isRunning && _ticker == null) {
      _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) {
          setState(() {});
        }
      });
    } else if (!task.isRunning) {
      _ticker?.cancel();
      _ticker = null;
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(
      settingsControllerProvider.select((state) => state.ffmpegReady),
      (previous, ready) {
        if (ready) {
          _requestThumbnail();
        }
      },
    );
    final task = ref.watch(
      queueControllerProvider.select((state) {
        return state.byId(widget.task.id) ?? widget.task;
      }),
    );
    final l10n = AppLocalizations.of(context);
    final queue = ref.read(queueControllerProvider.notifier);
    final percent = '${(task.progress * 100).clamp(0, 100).toStringAsFixed(1)}%';
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(11),
        child: Stack(
          children: [
            const Positioned.fill(child: ColoredBox(color: AppColors.surface)),
            Positioned.fill(
              child: _ProgressFill(
                progress: task.progress.clamp(0, 1),
                active: task.isRunning,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: SizedBox(
                height: 102,
                child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Thumb(task: task),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: _FormatPill(format: task.targetFormat),
                            ),
                            const SizedBox(width: 8),
                            _StatusPill(status: task.status),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                fileNameOf(task.inputPath),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        PathText(l10n.sourcePath(task.inputPath)),
                        PathText(l10n.destinationPath(task.outputPath)),
                        const Spacer(),
                        Text(
                          queueTaskStatsLine(l10n, task),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: appTextStyle(
                            size: 13,
                            color: task.status == TaskStatus.failed
                                ? AppColors.danger
                                : AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      SizedBox(
                        width: 58,
                        child: Text(
                          percent,
                          textAlign: TextAlign.right,
                          style: appTextStyle(
                            size: 13,
                            weight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      _actionRow([
                          _TaskAction(
                            message: l10n.openInputFolder,
                            icon: FluentIcons.open_file,
                            onPressed: () => revealInExplorer(task.inputPath),
                          ),
                          _TaskAction(
                            message: l10n.openOutputFolder,
                            icon: FluentIcons.folder_open,
                            onPressed: () => openDirectory(task.outputDirectory),
                          ),
                          if (task.isRunning)
                            _TaskAction(
                              key: ValueKey('stop-${task.id}'),
                              message: l10n.stop,
                              icon: FluentIcons.stop,
                              filled: true,
                              fillColor: AppColors.danger,
                              onPressed: () => queue.stopOne(task.id),
                            )
                          else
                            _TaskAction(
                              key: ValueKey('start-${task.id}'),
                              message: task.status == TaskStatus.completed
                                  ? l10n.restart
                                  : l10n.start,
                              icon: task.status == TaskStatus.completed
                                  ? FluentIcons.refresh
                                  : FluentIcons.play,
                              filled: true,
                              onPressed: task.canStart
                                  ? () => queue.startOne(task.id)
                                  : null,
                            ),
                          _TaskAction(
                            message: l10n.delete,
                            icon: FluentIcons.delete,
                            onPressed: () => queue.delete(task.id),
                          ),
                        ]),
                        const SizedBox(height: 4),
                        _actionRow([
                          _TaskAction(
                            message: l10n.edit,
                            icon: FluentIcons.edit,
                            onPressed: task.canEdit ? widget.onEdit : null,
                          ),
                          _TaskAction(
                            key: ValueKey('clip-${task.id}-${task.hasClip}'),
                            message: task.hasClip
                                ? '${l10n.inPoint} ${formatTimecode(task.clipRange!.start)}  ·  ${l10n.outPoint} ${formatTimecode(task.clipRange!.end)}'
                                : l10n.clip,
                            icon: FluentIcons.cut,
                            filled: task.hasClip,
                            fillColor: task.hasClip ? AppColors.accentDim : null,
                            onPressed: task.canClip ? widget.onClip : null,
                          ),
                          _TaskAction(
                            key: ValueKey(
                              'subtitles-${task.id}-${task.hasSubtitleEdit}',
                            ),
                            message: subtitleActionMessage(l10n, task),
                            icon: FluentIcons.locale_language,
                            filled: task.hasSubtitleEdit,
                            fillColor: task.hasSubtitleEdit
                                ? AppColors.accentDim
                                : null,
                            onPressed: task.canEditSubtitles
                                ? widget.onSubtitles
                                : null,
                          ),
                      ]),
                    ],
                  ),
                ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionRow(List<Widget> children) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          children[i],
        ],
      ],
    );
  }

}

class _ProgressFill extends StatefulWidget {
  const _ProgressFill({required this.progress, required this.active});

  final double progress;
  final bool active;

  @override
  State<_ProgressFill> createState() => _ProgressFillState();
}

class _ProgressFillState extends State<_ProgressFill>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );
  bool _wantsLoop = false;

  @override
  void initState() {
    super.initState();
    _controller.addStatusListener(_onStatus);
    _sync();
  }

  @override
  void didUpdateWidget(_ProgressFill oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync();
  }

  void _sync() {
    _wantsLoop = widget.active;
    if (_wantsLoop && !_controller.isAnimating) {
      _controller.forward(from: _controller.value);
    }
  }

  void _onStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed) {
      return;
    }
    if (_wantsLoop) {
      _controller.forward(from: 0);
    } else {
      _controller.value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return CustomPaint(
            painter: _ProgressWavePainter(
              fill: widget.progress,
              phase: _controller.value,
              showWave: widget.active || _controller.value > 0,
            ),
            child: const SizedBox.expand(),
          );
        },
      ),
    );
  }
}

class _ProgressWavePainter extends CustomPainter {
  const _ProgressWavePainter({
    required this.fill,
    required this.phase,
    required this.showWave,
  });

  final double fill;
  final double phase;
  final bool showWave;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty || fill <= 0) {
      return;
    }
    final filledWidth = size.width * fill.clamp(0, 1);
    canvas.drawRect(
      Rect.fromLTWH(0, 0, filledWidth, size.height),
      Paint()..color = AppColors.accent.withValues(alpha: 0.16),
    );
    if (!showWave) {
      return;
    }
    final band = (size.width * 0.62).clamp(180.0, 420.0);
    final left = -band + (filledWidth + band) * phase;
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 0, filledWidth, size.height));
    final rect = Rect.fromLTWH(left, 0, band, size.height);
    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0x0022D3EE),
          Color(0x8822D3EE),
        ],
      ).createShader(rect);
    canvas.drawRect(rect, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ProgressWavePainter oldDelegate) {
    return oldDelegate.fill != fill ||
        oldDelegate.phase != phase ||
        oldDelegate.showWave != showWave;
  }
}

class _TaskAction extends StatelessWidget {
  const _TaskAction({
    super.key,
    required this.message,
    required this.icon,
    required this.onPressed,
    this.filled = false,
    this.fillColor,
  });

  final String message;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool filled;
  final Color? fillColor;

  @override
  Widget build(BuildContext context) {
    return AnchoredTooltip(
      message: message,
      child: IconButton(
        icon: Icon(icon, size: 16),
        onPressed: onPressed,
        filled: filled,
        fillColor: fillColor,
      ),
    );
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb({required this.task});

  final ConversionTask task;

  @override
  Widget build(BuildContext context) {
    final file = task.thumbnailPath == null ? null : File(task.thumbnailPath!);
    final hasImage = file != null && file.existsSync();
    return Container(
      width: 176,
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
        image: hasImage
            ? DecorationImage(
                image: ResizeImage.resizeIfNeeded(
                  (176 * MediaQuery.devicePixelRatioOf(context)).round(),
                  null,
                  FileImage(file),
                ),
                fit: BoxFit.cover,
              )
            : null,
      ),
      alignment: Alignment.center,
      child: hasImage
          ? null
          : Icon(
              task.targetFormat.isAudio ? FluentIcons.music_note : FluentIcons.video,
              color: AppColors.textMuted,
            ),
    );
  }
}

class _FormatPill extends StatelessWidget {
  const _FormatPill({required this.format});

  final MediaFormat format;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final color = format.color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        l10n.convertToFormat(formatLabel(l10n, format)),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: appTextStyle(size: 13, weight: FontWeight.w700, color: color),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});

  final TaskStatus status;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final color = switch (status) {
      TaskStatus.pending => AppColors.textMuted,
      TaskStatus.queued => AppColors.warning,
      TaskStatus.running => AppColors.accent,
      TaskStatus.completed => AppColors.success,
      TaskStatus.failed => AppColors.danger,
      TaskStatus.cancelled => AppColors.warning,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        taskStatusLabel(l10n, status),
        style: appTextStyle(size: 13, weight: FontWeight.w700, color: color),
      ),
    );
  }
}

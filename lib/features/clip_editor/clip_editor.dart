import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../../core/models/clip_range.dart';
import '../../core/models/conversion_task.dart';
import '../../core/models/media_info.dart';
import '../../core/settings/queue_controller.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/ui/ui.dart';
import '../../shared/widgets/anchored_tooltip.dart';
import 'clip_preview.dart';
import 'clip_timeline.dart';
import 'clip_timeline_hit_test.dart';

class ClipEditor extends ConsumerStatefulWidget {
  const ClipEditor({
    super.key,
    required this.task,
    required this.onCancel,
    required this.onSubmit,
  });

  final ConversionTask task;
  final VoidCallback onCancel;
  final ValueChanged<ClipRange?> onSubmit;

  @override
  ConsumerState<ClipEditor> createState() => _ClipEditorState();
}

class _ClipEditorState extends ConsumerState<ClipEditor> {
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  Duration _start = Duration.zero;
  Duration _end = Duration.zero;
  double _fps = 30;
  MediaInfo? _info;
  Player? _player;
  VideoController? _controller;
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<bool>? _playingSub;
  StreamSubscription<String>? _errorSub;
  bool _loadingPreview = true;
  bool _playing = false;
  bool _suppressPosition = false;
  bool _interacting = false;
  String? _previewError;
  int _seekGeneration = 0;

  @override
  void initState() {
    super.initState();
    _fps = widget.task.clipRange?.fps ?? 30;
    _start = widget.task.clipRange?.start ?? Duration.zero;
    _end = widget.task.clipRange?.end ?? Duration.zero;
    _position = _start;
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final info = await ref
        .read(queueControllerProvider.notifier)
        .probe(widget.task.inputPath);
    if (!mounted) {
      return;
    }
    final duration = info.duration ?? Duration.zero;
    final fps = info.fps ?? widget.task.clipRange?.fps ?? 30;
    final existing = widget.task.clipRange;
    setState(() {
      _info = info;
      _duration = duration;
      _fps = fps;
      _start = existing?.start ?? Duration.zero;
      _end = existing?.end ?? duration;
      _position = _start;
    });
    await _openPreview();
  }

  Future<void> _openPreview() async {
    Player? player;
    try {
      player = createClipPlayer();
      final controller = VideoController(player);
      _player = player;
      _controller = controller;
      _positionSub = player.stream.position.listen((position) {
        if (!mounted || _suppressPosition || _interacting || !_playing) {
          return;
        }
        setState(() {
          _position = clampDuration(position, Duration.zero, _duration);
        });
      });
      _playingSub = player.stream.playing.listen((playing) {
        if (!mounted) {
          return;
        }
        setState(() => _playing = playing);
      });
      _errorSub = player.stream.error.listen((error) {
        if (!mounted || error.trim().isEmpty) {
          return;
        }
        setState(() {
          _previewError = error.trim();
          _loadingPreview = false;
        });
      });
      await player.open(
        clipMediaFromPath(widget.task.inputPath),
        play: false,
      );
      await player.seek(_position);
      if (!mounted) {
        return;
      }
      setState(() => _loadingPreview = false);
    } catch (error) {
      await player?.dispose();
      _player = null;
      _controller = null;
      if (!mounted) {
        return;
      }
      setState(() {
        _previewError = error.toString();
        _loadingPreview = false;
      });
    }
  }

  Future<void> _seek(Duration time, {bool user = true}) async {
    final next = snapClipTime(time, _fps, _duration);
    setState(() => _position = next);
    final player = _player;
    if (player == null) {
      return;
    }
    final generation = ++_seekGeneration;
    if (user) {
      _suppressPosition = true;
    }
    try {
      await player.seek(next);
    } catch (_) {
      // 预览 seek 失败不阻断时间轴。
    }
    if (generation == _seekGeneration && !_interacting) {
      _suppressPosition = false;
    }
  }

  void _beginTimelineInteraction() {
    _interacting = true;
    _suppressPosition = true;
    unawaited(_player?.pause());
  }

  void _endTimelineInteraction() {
    _interacting = false;
    _suppressPosition = false;
  }

  Future<void> _togglePlay() async {
    final player = _player;
    if (player == null || _previewError != null) {
      return;
    }
    if (_playing) {
      await player.pause();
      return;
    }
    if (_position >= _duration && _duration > Duration.zero) {
      await _seek(Duration.zero);
    }
    await player.play();
  }

  Future<void> _nudgePlayhead(int frames) async {
    await _player?.pause();
    await _seek(_position + stepByFrame(Duration.zero, _fps, frames));
  }

  void _nudgePoint(int frames, {required bool inPoint}) {
    if (inPoint) {
      final next = clampClipStart(
        value: snapClipTime(
          _start + stepByFrame(Duration.zero, _fps, frames),
          _fps,
          _duration,
        ),
        end: _end,
        duration: _duration,
        fps: _fps,
      );
      setState(() => _start = next);
      _seek(next);
    } else {
      final next = clampClipEnd(
        value: snapClipTime(
          _end + stepByFrame(Duration.zero, _fps, frames),
          _fps,
          _duration,
        ),
        start: _start,
        duration: _duration,
        fps: _fps,
      );
      setState(() => _end = next);
      _seek(next);
    }
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    _playingSub?.cancel();
    _errorSub?.cancel();
    final player = _player;
    _player = null;
    _controller = null;
    unawaited(player?.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final startFrame = (_start.inMicroseconds / 1000000 * _fps).round();
    final endFrame = (_end.inMicroseconds / 1000000 * _fps).round();
    final hasVideo = _info?.hasVideo ?? true;
    return ColoredBox(
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
        child: Column(
          children: [
            Expanded(
              child: ClipPreview(
                controller: _controller,
                loading: _loadingPreview,
                hasVideo: hasVideo,
                error: _previewError,
              ),
            ),
            const SizedBox(height: 16),
            ClipTimeline(
              duration: _duration,
              position: _position,
              start: _start,
              end: _end,
              fps: _fps,
              onSeek: (value) {
                _beginTimelineInteraction();
                _seek(value);
              },
              onStartChanged: (value) {
                _beginTimelineInteraction();
                setState(() => _start = value);
                _seek(value);
              },
              onEndChanged: (value) {
                _beginTimelineInteraction();
                setState(() => _end = value);
                _seek(value);
              },
              onInteractionEnd: _endTimelineInteraction,
            ),
            const SizedBox(height: 12),
            Stack(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _PointCard(
                      label: l10n.inPoint,
                      time: _start,
                      frame: startFrame,
                      onMinus: () => _nudgePoint(-1, inPoint: true),
                      onPlus: () => _nudgePoint(1, inPoint: true),
                      onUsePlayhead: () {
                        final next = clampClipStart(
                          value: _position,
                          end: _end,
                          duration: _duration,
                          fps: _fps,
                        );
                        setState(() => _start = next);
                        _seek(next);
                      },
                    ),
                    const Spacer(),
                    _PointCard(
                      label: l10n.outPoint,
                      time: _end,
                      frame: endFrame,
                      alignEnd: true,
                      onMinus: () => _nudgePoint(-1, inPoint: false),
                      onPlus: () => _nudgePoint(1, inPoint: false),
                      onUsePlayhead: () {
                        final next = clampClipEnd(
                          value: _position,
                          start: _start,
                          duration: _duration,
                          fps: _fps,
                        );
                        setState(() => _end = next);
                        _seek(next);
                      },
                    ),
                  ],
                ),
                Align(
                  alignment: Alignment.topCenter,
                  child: _TransportControls(
                    playing: _playing,
                    canPlay: _previewError == null,
                    onTogglePlay: _togglePlay,
                    onNudge: _nudgePlayhead,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                const Spacer(),
                Button(onPressed: widget.onCancel, child: Text(l10n.cancel)),
                const SizedBox(width: 8),
                Button(
                  onPressed: () => widget.onSubmit(null),
                  child: Text(l10n.clearClip),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _duration == Duration.zero
                      ? null
                      : () => widget.onSubmit(
                          ClipRange(
                            start: _start,
                            end: _end,
                            fps: _fps,
                          ).clampTo(_duration),
                        ),
                  child: Text(l10n.applyClip),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TransportControls extends StatelessWidget {
  const _TransportControls({
    required this.playing,
    required this.canPlay,
    required this.onTogglePlay,
    required this.onNudge,
  });

  final bool playing;
  final bool canPlay;
  final VoidCallback onTogglePlay;
  final Future<void> Function(int frames) onNudge;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Button(
          onPressed: () => onNudge(-1),
          child: Text(l10n.minusOneFrame),
        ),
        const SizedBox(width: 8),
        AnchoredTooltip(
          message: playing ? l10n.pause : l10n.play,
          child: IconButton(
            icon: Icon(playing ? AppIcons.pause : AppIcons.play),
            onPressed: canPlay ? onTogglePlay : null,
          ),
        ),
        const SizedBox(width: 8),
        Button(
          onPressed: () => onNudge(1),
          child: Text(l10n.plusOneFrame),
        ),
      ],
    );
  }
}

class _PointCard extends StatelessWidget {
  const _PointCard({
    required this.label,
    required this.time,
    required this.frame,
    required this.onMinus,
    required this.onPlus,
    required this.onUsePlayhead,
    this.alignEnd = false,
  });

  final String label;
  final Duration time;
  final int frame;
  final VoidCallback onMinus;
  final VoidCallback onPlus;
  final VoidCallback onUsePlayhead;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment:
              alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(label, style: appTextStyle(weight: FontWeight.w700)),
            const SizedBox(height: 2),
            Text(
              l10n.timecodeAndFrame(formatTimecode(time), frame),
              style: appTextStyle(color: AppColors.textMuted),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              alignment: alignEnd ? WrapAlignment.end : WrapAlignment.start,
              children: [
                Button(onPressed: onMinus, child: Text(l10n.minusOneFrame)),
                Button(onPressed: onPlus, child: Text(l10n.plusOneFrame)),
                Button(
                  onPressed: onUsePlayhead,
                  child: Text(l10n.useCurrentFrame),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

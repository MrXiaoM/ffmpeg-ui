import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/labels.dart';
import '../../core/models/conversion_task.dart';
import '../../core/models/media_info.dart';
import '../../core/models/subtitle_track.dart';
import '../../core/platform/media_picker.dart';
import '../../core/platform/fs_paths.dart';
import '../../core/settings/queue_controller.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/ui/ui.dart';
import '../../shared/widgets/path_text.dart';

class SubtitleEditor extends ConsumerStatefulWidget {
  const SubtitleEditor({
    super.key,
    required this.task,
    required this.onCancel,
    required this.onSubmit,
  });

  final ConversionTask task;
  final VoidCallback onCancel;
  final ValueChanged<SubtitleEdit?> onSubmit;

  @override
  ConsumerState<SubtitleEditor> createState() => _SubtitleEditorState();
}

class _SubtitleEditorState extends ConsumerState<SubtitleEditor> {
  MediaInfo? _info;
  late Set<int> _kept;
  final List<_ExternalSubtitle> _additions = [];
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    final existing = widget.task.subtitleEdit;
    _kept = existing?.keepIndexes.toSet() ?? {};
    for (final addition in existing?.additions ?? const <SubtitleAddition>[]) {
      _additions.add(_ExternalSubtitle(addition));
    }
    _load();
  }

  Future<void> _load({bool force = false}) async {
    if (force && mounted) {
      setState(() {
        _loading = true;
        _info = null;
        _error = null;
      });
    }
    final info = await ref
        .read(queueControllerProvider.notifier)
        .probe(widget.task.inputPath, force: force);
    if (!mounted) {
      return;
    }
    final message = subtitleProbeError(AppLocalizations.of(context), info);
    setState(() {
      _info = info;
      _loading = false;
      if (widget.task.subtitleEdit == null) {
        _kept = info.subtitles.map((track) => track.index).toSet();
      }
      _error = message.isEmpty ? null : message;
    });
  }

  @override
  void dispose() {
    for (final addition in _additions) {
      addition.dispose();
    }
    super.dispose();
  }

  String? _containerWarning(AppLocalizations l10n) {
    switch (widget.task.outputContainerFormat.id) {
      case 'webm':
        return l10n.webmSubtitleWarning;
      case 'mp4':
      case 'mov':
        final hasStyled = _additions.any((item) {
          final ext = item.addition.extension;
          return ext == '.ass' || ext == '.ssa';
        });
        return hasStyled ? l10n.mp4AssWarning : l10n.mp4TextWarning;
      default:
        return null;
    }
  }

  void _submit() {
    final l10n = AppLocalizations.of(context);
    final message = subtitleProbeError(l10n, _info);
    if (message.isNotEmpty) {
      setState(() => _error = message);
      return;
    }
    widget.onSubmit(
      SubtitleEdit(
        keepIndexes: _kept.toList()..sort(),
        additions: [for (final item in _additions) item.value],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final info = _info;
    final warning = _containerWarning(l10n);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PathText(l10n.sourcePath(widget.task.inputPath)),
          const SizedBox(height: 8),
          Text(
            l10n.subtitleOutputHint,
            style: appTextStyle(color: AppColors.textMuted),
          ),
          if (warning != null) ...[
            const SizedBox(height: 8),
            Text(warning, style: appTextStyle(color: AppColors.warning)),
          ],
          const SizedBox(height: 12),
          Expanded(child: _trackPane(info)),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(_error!, style: appTextStyle(color: AppColors.danger)),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              const Spacer(),
              Button(onPressed: widget.onCancel, child: Text(l10n.cancel)),
              const SizedBox(width: 8),
              if (_error != null) ...[
                Button(
                  onPressed: _loading ? null : () => _load(force: true),
                  child: Text(l10n.retry),
                ),
                const SizedBox(width: 8),
              ],
              Button(
                onPressed: () => widget.onSubmit(null),
                child: Text(l10n.clearSubtitles),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: info == null || info.hasVideo != true ? null : _submit,
                child: Text(l10n.applySubtitles),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _trackPane(MediaInfo? info) {
    final l10n = AppLocalizations.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Text(
            l10n.existingSubtitles,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          if (info == null || _loading)
            Text(l10n.readingSubtitleTracks)
          else if (info.subtitles.isEmpty && info.error == null)
            Text(
              l10n.noEmbeddedSubtitles,
              style: appTextStyle(color: AppColors.textMuted),
            )
          else
            for (final track in info.subtitles)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Checkbox(
                  checked: _kept.contains(track.index),
                  onChanged: (checked) {
                    setState(() {
                      if (checked ?? false) {
                        _kept.add(track.index);
                      } else {
                        _kept.remove(track.index);
                      }
                    });
                  },
                  content: Text(subtitleTrackSummary(l10n, track)),
                ),
              ),
          const SizedBox(height: 12),
          Text(
            l10n.externalSubtitles,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          for (var i = 0; i < _additions.length; i++) _additionTile(i),
          const SizedBox(height: 8),
          Button(
            onPressed: () async {
              final paths = await pickSubtitleFiles(
                dialogTitle: l10n.pickSubtitleFiles,
              );
              if (paths.isEmpty) {
                return;
              }
              setState(() {
                _additions.addAll(
                  paths.map(
                    (path) => _ExternalSubtitle(SubtitleAddition(path: path)),
                  ),
                );
              });
            },
            child: Text(l10n.addExternalSubtitle),
          ),
        ],
      ),
    );
  }

  Widget _additionTile(int index) {
    final l10n = AppLocalizations.of(context);
    final item = _additions[index];
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: PathText(fileNameOf(item.addition.path))),
              IconButton(
                icon: const Icon(FluentIcons.delete, size: 14),
                onPressed: () => setState(() {
                  _additions.removeAt(index).dispose();
                }),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: TextBox(
                  controller: item.language,
                  placeholder: l10n.subtitleLanguageHint,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextBox(
                  controller: item.title,
                  placeholder: l10n.subtitleTitleHint,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ExternalSubtitle {
  _ExternalSubtitle(this.addition)
    : language = TextEditingController(text: addition.language),
      title = TextEditingController(text: addition.title);

  final SubtitleAddition addition;
  final TextEditingController language;
  final TextEditingController title;

  SubtitleAddition get value => addition.copyWith(
    language: language.text,
    title: title.text,
  );

  void dispose() {
    language.dispose();
    title.dispose();
  }
}

import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/app_language.dart';
import '../../core/l10n/labels.dart';
import '../../core/models/app_settings.dart';
import '../../core/platform/media_picker.dart';
import '../../core/settings/settings_controller.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/ui/ui.dart';

class SettingsDialog extends ConsumerStatefulWidget {
  const SettingsDialog({super.key, this.onClose});

  final Future<void> Function()? onClose;

  @override
  ConsumerState<SettingsDialog> createState() => _SettingsDialogState();
}

const _twoColumnBreakpoint = 720.0;
const _sectionGap = 12.0;

class _SettingsDialogState extends ConsumerState<SettingsDialog> {
  late final TextEditingController _path;
  late final TextEditingController _rename;

  @override
  void initState() {
    super.initState();
    _path = TextEditingController(
      text: ref.read(settingsControllerProvider).settings.ffmpegPath ?? '',
    );
    _rename = TextEditingController(
      text: ref.read(settingsControllerProvider).settings.renamePattern,
    );
    Future.microtask(
      () => ref.read(settingsControllerProvider.notifier).ensureHardware(),
    );
  }

  @override
  void dispose() {
    _path.dispose();
    _rename.dispose();
    super.dispose();
  }

  String _ffmpegPathHint(AppLocalizations l10n) {
    if (Platform.isWindows) {
      return l10n.ffmpegPathHintWindows;
    }
    if (Platform.isMacOS) {
      return l10n.ffmpegPathHintMacos;
    }
    return l10n.ffmpegPathHintLinux;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(settingsControllerProvider);
    return ColoredBox(
      color: AppColors.surface,
      child: Column(
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final twoColumn =
                    constraints.maxWidth >= _twoColumnBreakpoint;
                final language = _buildLanguageSection(l10n, settings);
                final ffmpeg = _buildFfmpegSection(l10n, settings);
                final hardware = _buildHardwareSection(l10n, settings);
                final concurrency = _buildConcurrencySection(l10n, settings);
                final rename = _buildRenameSection(l10n, settings);
                return ListView(
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
                  children: [
                    if (twoColumn)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _SettingsColumn(
                              children: [language, ffmpeg],
                            ),
                          ),
                          const SizedBox(width: _sectionGap),
                          Expanded(
                            child: _SettingsColumn(
                              children: [hardware, concurrency, rename],
                            ),
                          ),
                        ],
                      )
                    else
                      _SettingsColumn(
                        children: [
                          language,
                          ffmpeg,
                          hardware,
                          concurrency,
                          rename,
                        ],
                      ),
                  ],
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                const Spacer(),
                FilledButton(
                  onPressed: () async {
                    await widget.onClose?.call();
                  },
                  child: Text(l10n.done),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageSection(AppLocalizations l10n, SettingsState settings) {
    return _SettingsSection(
      title: l10n.language,
      hint: l10n.languageHint,
      child: ComboBox<AppLanguage>(
        value: settings.settings.appLanguage,
        isExpanded: true,
        items: [
          for (final language in AppLanguage.values)
            ComboBoxItem(
              value: language,
              child: Text(languageOptionLabel(l10n, language)),
            ),
        ],
        onChanged: settings.busy
            ? null
            : (value) {
                if (value == null) {
                  return;
                }
                ref
                    .read(settingsControllerProvider.notifier)
                    .setAppLanguage(value);
              },
      ),
    );
  }

  Widget _buildFfmpegSection(AppLocalizations l10n, SettingsState settings) {
    return _SettingsSection(
      title: l10n.ffmpegPath,
      hint: _ffmpegPathHint(l10n),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: TextBox(
                  controller: _path,
                  placeholder: ffmpegPathPlaceholder(),
                ),
              ),
              const SizedBox(width: 8),
              Button(
                onPressed: () async {
                  final path = await pickExecutable(
                    dialogTitle: Platform.isWindows
                        ? l10n.pickFfmpegExe
                        : l10n.pickFfmpeg,
                  );
                  if (path != null) {
                    _path.text = path;
                  }
                },
                child: Text(l10n.browse),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Button(
                onPressed: settings.busy
                    ? null
                    : () => ref
                          .read(settingsControllerProvider.notifier)
                          .setFfmpegPath(_path.text.trim()),
                child: Text(l10n.useThisPath),
              ),
              Button(
                onPressed: settings.busy
                    ? null
                    : () async {
                        _path.clear();
                        await ref
                            .read(settingsControllerProvider.notifier)
                            .detect();
                        _path.text =
                            ref
                                .read(settingsControllerProvider)
                                .location
                                ?.ffmpegPath ??
                            '';
                      },
                child: Text(l10n.redetect),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (settings.location != null)
            InfoBar(
              title: Text(l10n.ready),
              content: Text(
                '${settings.location!.ffmpegPath}\n${settings.location!.version ?? ''}',
              ),
              severity: InfoBarSeverity.success,
            )
          else
            InfoBar(
              title: Text(l10n.ffmpegNotFoundTitle),
              content: Text(
                Platform.isWindows
                    ? l10n.ffmpegMissingHintWindows
                    : l10n.ffmpegMissingHintOther,
              ),
              severity: InfoBarSeverity.warning,
            ),
        ],
      ),
    );
  }

  Widget _buildHardwareSection(AppLocalizations l10n, SettingsState settings) {
    return _SettingsSection(
      title: l10n.hardwareAcceleration,
      hint: l10n.hardwareAccelerationHint,
      child: ToggleSwitch(
        checked: settings.settings.hardwareAcceleration,
        content: Text(
          !settings.hardware.isProbed && settings.ffmpegReady
              ? l10n.detectingGpu
              : settings.hardware.anyAvailable
              ? l10n.hardwareDefaultOn
              : l10n.hardwareAfterGpu,
        ),
        onChanged: settings.busy
            ? null
            : (value) => ref
                  .read(settingsControllerProvider.notifier)
                  .setHardwareAcceleration(value),
      ),
    );
  }

  Widget _buildConcurrencySection(
    AppLocalizations l10n,
    SettingsState settings,
  ) {
    return _SettingsSection(
      title: l10n.concurrency,
      hint: l10n.concurrencyHint,
      child: Align(
        alignment: Alignment.centerLeft,
        child: SizedBox(
          width: 180,
          child: NumberBox<int>(
            value: settings.settings.concurrency,
            min: AppSettings.minConcurrency,
            max: AppSettings.maxConcurrency,
            mode: SpinButtonPlacementMode.inline,
            onChanged: (value) {
              if (value == null) {
                return;
              }
              ref
                  .read(settingsControllerProvider.notifier)
                  .setConcurrency(value);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildRenameSection(AppLocalizations l10n, SettingsState settings) {
    return _SettingsSection(
      title: l10n.renameOnConflict,
      hint: l10n.renameHint('{n}', '{n:2}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final preset in AppSettings.renamePresets)
                Button(
                  onPressed: () {
                    _rename.text = preset;
                    ref
                        .read(settingsControllerProvider.notifier)
                        .setRenamePattern(preset);
                  },
                  child: Text(
                    l10n.renamePresetFile(
                      AppSettings(
                        renamePattern: preset,
                      ).renameWithNumber('', '.mp4', 1),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextBox(
                  controller: _rename,
                  placeholder: AppSettings.defaultRenamePattern,
                ),
              ),
              const SizedBox(width: 8),
              Button(
                onPressed: () => ref
                    .read(settingsControllerProvider.notifier)
                    .setRenamePattern(_rename.text),
                child: Text(l10n.useThisRule),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            l10n.renameExample(
              settings.settings.renameWithNumber('', '.mp4', 1),
            ),
            style: appTextStyle(size: 13, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

class _SettingsColumn extends StatelessWidget {
  const _SettingsColumn({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0) const SizedBox(height: _sectionGap),
          children[i],
        ],
      ],
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({
    required this.title,
    required this.hint,
    required this.child,
  });

  final String title;
  final String hint;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title, style: appTextStyle(weight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(
            hint,
            style: appTextStyle(size: 13, color: AppColors.textMuted),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

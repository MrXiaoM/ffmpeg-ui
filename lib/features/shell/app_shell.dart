import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';

import '../../core/l10n/app_messages.dart';
import '../../core/models/clip_range.dart';
import '../../core/models/conversion_task.dart';
import '../../core/models/media_format.dart';
import '../../core/models/subtitle_track.dart';
import '../../core/platform/fs_paths.dart';
import '../../core/platform/media_picker.dart';
import '../../core/platform/window_chrome.dart';
import '../../core/settings/queue_controller.dart';
import '../../core/settings/settings_controller.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/ui/ui.dart';
import '../../shared/widgets/motion.dart';
import '../about/about_dialog.dart';
import '../add_task/add_task_wizard.dart';
import '../clip_editor/clip_editor.dart';
import '../formats/format_panel.dart';
import '../queue/queue_panel.dart';
import '../settings/settings_dialog.dart';
import '../subtitles/subtitle_editor.dart';

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> with WindowListener {
  bool _dropping = false;
  DateTime? _handledByFormatAt;
  _MenuKind? _menu;
  _PageOverlay? _overlay;
  int _overlayGeneration = 0;
  bool _overlayVisible = false;
  MediaFormat? _overlayFormat;
  List<String> _overlayFiles = const [];
  ConversionTask? _overlayEditing;
  ConversionTask? _subtitleTask;
  ConversionTask? _clipTaskItem;

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  void onWindowClose() {
    _shutdownAndClose();
  }

  Future<void> _shutdownAndClose() async {
    final queue = ref.read(queueControllerProvider.notifier);
    FocusManager.instance.primaryFocus?.unfocus();
    await WidgetsBinding.instance.endOfFrame;
    try {
      await queue.shutdown();
    } finally {
      await windowManager.setPreventClose(false);
      await windowManager.close();
    }
  }

  void _closeMenu() {
    if (_menu == null) {
      return;
    }
    setState(() => _menu = null);
  }

  void _toggleMenu(_MenuKind kind) {
    setState(() {
      _menu = _menu == kind ? null : kind;
    });
  }

  void _hoverMenu(_MenuKind kind) {
    if (_menu == null || _menu == kind) {
      return;
    }
    setState(() => _menu = kind);
  }

  void _openOverlay(_PageOverlay overlay) {
    setState(() {
      _overlay = overlay;
      _overlayGeneration += 1;
      _overlayVisible = false;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _overlay == overlay) {
        setState(() => _overlayVisible = true);
      }
    });
  }

  Future<void> _closeOverlay() async {
    if (_overlay == null) {
      return;
    }
    final generation = _overlayGeneration;
    setState(() => _overlayVisible = false);
    await Future<void>.delayed(motionDuration);
    if (!mounted || _overlayVisible || generation != _overlayGeneration) {
      return;
    }
    setState(() {
      _overlay = null;
      _overlayFormat = null;
      _overlayFiles = const [];
      _overlayEditing = null;
      _subtitleTask = null;
      _clipTaskItem = null;
    });
    imageCache.clear();
    imageCache.clearLiveImages();
    await SystemChannels.skia.invokeMethod<void>(
      'Skia.setResourceCacheMaxBytes',
      0,
    );
    await SystemChannels.skia.invokeMethod<void>(
      'Skia.setResourceCacheMaxBytes',
      8 << 20,
    );
  }

  Future<void> _openFiles({
    MediaFormat? format,
    List<String>? files,
  }) async {
    var selected = files ?? const <String>[];
    if (files == null && format == null) {
      selected = await pickMediaFiles(
        dialogTitle: AppLocalizations.of(context).pickMediaFiles,
      );
      if (selected.isEmpty || !mounted) {
        return;
      }
    }
    if (selected.isEmpty && format == null) {
      return;
    }
    setState(() {
      _overlayFormat = format;
      _overlayFiles = selected;
      _overlayEditing = null;
    });
    _openOverlay(_PageOverlay.addTask);
    if (files != null) {
      await windowManager.focus();
    }
  }

  void _editTask(ConversionTask task) {
    setState(() {
      _overlayFormat = task.targetFormat;
      _overlayFiles = [task.inputPath];
      _overlayEditing = task;
    });
    _openOverlay(_PageOverlay.addTask);
  }

  Future<void> _submitAddTask(AddTaskResult result) async {
    final editing = _overlayEditing;
    final queue = ref.read(queueControllerProvider.notifier);
    if (editing == null) {
      await queue.addTasks(
        inputPaths: result.inputPaths,
        format: result.format,
        outputDirectory: result.outputDirectory,
        encode: result.encode,
        outputFileName: result.outputFileName,
      );
    } else {
      await queue.updateTask(
        editing.copyWith(
          inputPath: result.inputPaths.isEmpty
              ? editing.inputPath
              : result.inputPaths.first,
          outputDirectory: result.outputDirectory,
          outputFileName: result.outputFileName ?? editing.outputFileName,
          targetFormat: result.format,
          encode: result.encode,
        ),
      );
    }
    if (mounted) {
      _closeOverlay();
    }
  }

  Future<void> _submitSubtitles(SubtitleEdit? edit) async {
    final source = _subtitleTask;
    if (source == null) {
      return;
    }
    await ref.read(queueControllerProvider.notifier).setSubtitles(
      source.id,
      edit,
    );
    if (mounted) {
      _closeOverlay();
    }
  }

  void _openSubtitles(ConversionTask task) {
    setState(() => _subtitleTask = task);
    _openOverlay(_PageOverlay.subtitles);
  }

  void _openClip(ConversionTask task) {
    setState(() => _clipTaskItem = task);
    _openOverlay(_PageOverlay.clip);
  }

  Future<void> _submitClip(ClipRange? range) async {
    final task = _clipTaskItem;
    if (task == null) {
      return;
    }
    final duration = _clipDurationOf(task);
    final whole = range != null &&
        duration != null &&
        range.start == Duration.zero &&
        range.end >= duration;
    await ref.read(queueControllerProvider.notifier).setClip(
      task.id,
      range == null || whole ? null : range,
    );
    if (mounted) {
      _closeOverlay();
    }
  }

  Duration? _clipDurationOf(ConversionTask task) {
    return ref
        .read(queueControllerProvider.notifier)
        .infoFor(task.inputPath)
        ?.duration;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(settingsControllerProvider);
    final queue = ref.watch(queueControllerProvider);
    return DropTarget(
      enable: _overlay == null,
      onDragEntered: (_) => setState(() => _dropping = true),
      onDragExited: (_) => setState(() => _dropping = false),
      onDragDone: (details) async {
        setState(() => _dropping = false);
        if (_handledByFormatAt != null &&
            DateTime.now().difference(_handledByFormatAt!) <
                const Duration(milliseconds: 400)) {
          return;
        }
        final paths = details.files
            .map((file) => file.path)
            .where(isMediaPath)
            .toList(growable: false);
        if (paths.isEmpty) {
          if (!mounted) {
            return;
          }
          await displayInfoBar(
            context,
            builder: (context, close) => InfoBar(
              title: Text(l10n.noMediaFiles),
              content: Text(l10n.dropMediaFiles),
              severity: InfoBarSeverity.warning,
              onClose: close,
            ),
          );
          return;
        }
        await _openFiles(files: paths);
      },
      child: Stack(
        children: [
          Column(
        children: [
          _TitleBar(
            openMenu: _menu,
            onFile: () => _toggleMenu(_MenuKind.file),
            onAboutMenu: () => _toggleMenu(_MenuKind.about),
            onFileHover: () => _hoverMenu(_MenuKind.file),
            onAboutHover: () => _hoverMenu(_MenuKind.about),
            fileItems: _fileMenuItems(),
            aboutItems: _aboutMenuItems(),
            onDragTitle: _closeMenu,
            onOpen: () => _openFiles(),
            onSettings: () => _openOverlay(_PageOverlay.settings),
            onAbout: () => showAboutDialog(context),
            onExit: _shutdownAndClose,
          ),
          Expanded(
            child: Stack(
              children: [
                Column(
                  children: [
          _Toolbar(
            onOpen: () => _openFiles(),
            onStartAll: () => ref.read(queueControllerProvider.notifier).startAll(),
            onStopAll: () => ref.read(queueControllerProvider.notifier).stopAll(),
            onClear: () => ref.read(queueControllerProvider.notifier).clearFinished(),
            ffmpegReady: settings.ffmpegReady,
          ),
          Expanded(
            child: Row(
              children: [
                FormatPanel(
                  width: settings.settings.leftPanelWidth,
                  dropEnabled: _overlay == null,
                  onResize: (width) {
                    ref
                        .read(settingsControllerProvider.notifier)
                        .setLeftPanelWidth(width);
                  },
                  onFormatTap: (format) => _openFiles(format: format),
                  onFilesDropped: (format, paths) {
                    _handledByFormatAt = DateTime.now();
                    _openFiles(format: format, files: paths);
                  },
                ),
                Expanded(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      border: _dropping
                          ? Border.all(color: AppColors.accent, width: 2)
                          : null,
                    ),
                    child: QueuePanel(
                      onEdit: _editTask,
                      onClip: _openClip,
                      onSubtitles: _openSubtitles,
                    ),
                  ),
                ),
              ],
            ),
          ),
          _StatusBar(
            ffmpegReady: settings.ffmpegReady,
            ffmpegLabel: settings.location?.version ??
                (localizeMessage(l10n, settings.message).isEmpty
                    ? l10n.notReady
                    : localizeMessage(l10n, settings.message)),
            queueCount: queue.tasks.length,
            runningCount: queue.runningCount,
            concurrency: settings.settings.concurrency,
            failedCount: queue.failedCount,
          ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
          if (_overlay != null) _buildOverlay(),
        ],
      ),
    );
  }

  List<Widget> _fileMenuItems() {
    final l10n = AppLocalizations.of(context);
    return [
      _MenuEntry(
        icon: FluentIcons.open_file,
        label: l10n.openFile,
        onPressed: () {
          _closeMenu();
          _openFiles();
        },
      ),
      _MenuEntry(
        icon: FluentIcons.settings,
        label: l10n.settings,
        onPressed: () {
          _closeMenu();
          _openOverlay(_PageOverlay.settings);
        },
      ),
      const Padding(
        padding: EdgeInsets.symmetric(vertical: 4),
        child: Divider(),
      ),
      _MenuEntry(
        label: l10n.exit,
        onPressed: () {
          _closeMenu();
          _shutdownAndClose();
        },
      ),
    ];
  }

  List<Widget> _aboutMenuItems() {
    final l10n = AppLocalizations.of(context);
    return [
      _MenuEntry(
        icon: FluentIcons.info,
        label: l10n.aboutThisApp,
        onPressed: () {
          _closeMenu();
          showAboutDialog(context);
        },
      ),
    ];
  }

  EdgeInsets _overlayPadding() {
    const baseLeft = 28.0;
    const baseTop = 20.0;
    const baseRight = 28.0;
    const baseBottom = 24.0;
    final extra = addTaskFilePaneExtra;
    final width = MediaQuery.sizeOf(context).width;
    final stacked = width < addTaskStackBreakpoint + baseLeft + baseRight;
    var left = baseLeft;
    var right = baseRight;
    if (!stacked && _overlay == _PageOverlay.addTask && _overlayEditing != null) {
      left += extra;
    }
    if (!stacked && _overlay == _PageOverlay.subtitles) {
      left += extra;
      right += extra;
      const minContent = 480.0;
      if (width - left - right < minContent) {
        left = baseLeft;
        right = baseRight;
      }
    }
    return EdgeInsets.fromLTRB(left, baseTop, right, baseBottom);
  }

  Widget _buildOverlay() {
    final l10n = AppLocalizations.of(context);
    final title = switch (_overlay) {
      _PageOverlay.settings => l10n.settings,
      _PageOverlay.subtitles => l10n.subtitles,
      _PageOverlay.clip => l10n.clipTitle(
        fileNameOf(_clipTaskItem?.inputPath ?? ''),
      ),
      _ => _overlayEditing == null
          ? l10n.addConversionTask
          : l10n.editConversionTask,
    };
    final child = switch (_overlay) {
      _PageOverlay.settings => SettingsDialog(
        key: ValueKey('settings-$_overlayGeneration'),
        onClose: () async => _closeOverlay(),
      ),
      _PageOverlay.subtitles => SubtitleEditor(
        key: ValueKey('subtitles-$_overlayGeneration'),
        task: _subtitleTask!,
        onCancel: _closeOverlay,
        onSubmit: _submitSubtitles,
      ),
      _PageOverlay.clip => ClipEditor(
        key: ValueKey('clip-$_overlayGeneration'),
        task: _clipTaskItem!,
        onCancel: _closeOverlay,
        onSubmit: _submitClip,
      ),
      _ => AddTaskWizard(
        key: ValueKey('add-task-$_overlayGeneration'),
        initialFormat: _overlayFormat,
        initialFiles: _overlayFiles,
        editing: _overlayEditing,
        onCancel: _closeOverlay,
        onSubmit: _submitAddTask,
      ),
    };
    return Positioned.fill(
      child: AnimatedOpacity(
        opacity: _overlayVisible ? 1 : 0,
        duration: motionDuration,
        curve: Curves.easeOutCubic,
        child: AnimatedSlide(
          offset: _overlayVisible ? Offset.zero : const Offset(0, 0.025),
          duration: motionDuration,
          curve: Curves.easeOutCubic,
          child: AnimatedScale(
            scale: _overlayVisible ? 1 : 0.975,
            duration: motionDuration,
            curve: Curves.easeOutCubic,
            child: Column(
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onPanStart: (_) => windowManager.startDragging(),
                  child: const ColoredBox(
                    color: Color(0xB3000000),
                    child: SizedBox(height: 40, width: double.infinity),
                  ),
                ),
                Expanded(
                  child: ColoredBox(
                    color: const Color(0x99000000),
                    child: Padding(
                      padding: _overlayPadding(),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        foregroundDecoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.borderStrong),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          children: [
                            SizedBox(
                              height: 36,
                              child: DecoratedBox(
                                decoration: const BoxDecoration(
                                  color: AppColors.menuBar,
                                  border: Border(
                                    bottom: BorderSide(
                                      color: AppColors.borderStrong,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        behavior: HitTestBehavior.opaque,
                                        onPanStart: (_) {
                                          _closeMenu();
                                          windowManager.startDragging();
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                            left: 16,
                                          ),
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              title,
                                              style: appTextStyle(
                                                size: 16,
                                                weight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    _OverlayCloseButton(
                                      onPressed: _closeOverlay,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Expanded(child: child),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MenuButton extends StatefulWidget {
  const _MenuButton({
    required this.label,
    required this.selected,
    required this.menuOpen,
    required this.onPressed,
    required this.onHover,
    required this.items,
  });

  final String label;
  final bool selected;
  final bool menuOpen;
  final VoidCallback onPressed;
  final VoidCallback onHover;
  final List<Widget> items;

  @override
  State<_MenuButton> createState() => _MenuButtonState();
}

class _MenuButtonState extends State<_MenuButton> {
  final _buttonKey = GlobalKey();
  OverlayEntry? _entry;

  @override
  void didUpdateWidget(covariant _MenuButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selected && _entry == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && widget.selected) {
          _insert();
        }
      });
    } else if (!widget.selected && _entry != null) {
      _remove();
    } else {
      _entry?.markNeedsBuild();
    }
  }

  @override
  void dispose() {
    _remove();
    super.dispose();
  }

  void _insert() {
    if (_entry != null) {
      return;
    }
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) {
      return;
    }
    _entry = OverlayEntry(
      builder: (context) {
        final box = _buttonKey.currentContext?.findRenderObject() as RenderBox?;
        if (box == null || !box.attached || !box.hasSize) {
          return const SizedBox.shrink();
        }
        final origin = box.localToGlobal(Offset.zero);
        return Stack(
          children: [
            Positioned(
              left: 0,
              top: 40,
              right: 0,
              bottom: 0,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: widget.onPressed,
              ),
            ),
            Positioned(
              left: origin.dx,
              top: origin.dy + box.size.height,
              width: 220,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: widget.items,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
    overlay.insert(_entry!);
  }

  void _remove() {
    _entry?.remove();
    _entry = null;
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: _buttonKey,
      child: MouseRegion(
        onEnter: (_) {
          if (widget.menuOpen && !widget.selected) {
            widget.onHover();
          }
        },
        child: _MenuCaption(
          label: widget.label,
          selected: widget.selected,
          onPressed: widget.onPressed,
        ),
      ),
    );
  }
}

class _MenuCaption extends StatelessWidget {
  const _MenuCaption({
    required this.label,
    required this.selected,
    required this.onPressed,
  });

  final String label;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return HoverButton(
      onPressed: onPressed,
      builder: (context, states) {
        final hot = selected || states.isHovered;
        return SizedBox(
          height: 40,
          child: ColoredBox(
            color: hot ? AppColors.surfaceAlt : Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Center(child: Text(label)),
            ),
          ),
        );
      },
    );
  }
}

class _MenuEntry extends StatelessWidget {
  const _MenuEntry({this.icon, required this.label, required this.onPressed});

  final IconData? icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return HoverButton(
      onPressed: onPressed,
      builder: (context, states) {
        return ColoredBox(
          color: states.isHovered ? AppColors.surfaceAlt : Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                SizedBox(
                  width: 20,
                  child: icon == null ? null : Icon(icon, size: 14),
                ),
                const SizedBox(width: 8),
                Text(label),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _OverlayCloseButton extends StatelessWidget {
  const _OverlayCloseButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return AppHover(
      onPressed: onPressed,
      builder: (context, states) {
        final hovered = states.isHovered;
        return ColoredBox(
          color: hovered ? const Color(0xB8C42B1C) : const Color(0x00000000),
          child: SizedBox(
            width: 46,
            height: 36,
            child: Center(
              child: Icon(
                FluentIcons.chrome_close,
                size: 14,
                color: hovered ? Colors.white : AppColors.text,
              ),
            ),
          ),
        );
      },
    );
  }
}

enum _PageOverlay { settings, addTask, subtitles, clip }

enum _MenuKind { file, about }

class _TitleBar extends StatelessWidget {
  const _TitleBar({
    required this.openMenu,
    required this.onFile,
    required this.onAboutMenu,
    required this.onFileHover,
    required this.onAboutHover,
    required this.fileItems,
    required this.aboutItems,
    required this.onDragTitle,
    required this.onOpen,
    required this.onSettings,
    required this.onAbout,
    required this.onExit,
  });

  final _MenuKind? openMenu;
  final VoidCallback onFile;
  final VoidCallback onAboutMenu;
  final VoidCallback onFileHover;
  final VoidCallback onAboutHover;
  final List<Widget> fileItems;
  final List<Widget> aboutItems;
  final VoidCallback onDragTitle;
  final VoidCallback onOpen;
  final VoidCallback onSettings;
  final VoidCallback onAbout;
  final VoidCallback onExit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
      height: 40,
      color: AppColors.menuBar,
      child: Row(
        children: [
          SizedBox(width: titleBarLeadingInset),
          const AppLogo(size: 18),
          const SizedBox(width: 8),
          _MenuButton(
            label: l10n.fileMenu,
            selected: openMenu == _MenuKind.file,
            menuOpen: openMenu != null,
            onPressed: onFile,
            onHover: onFileHover,
            items: fileItems,
          ),
          _MenuButton(
            label: l10n.aboutMenu,
            selected: openMenu == _MenuKind.about,
            menuOpen: openMenu != null,
            onPressed: onAboutMenu,
            onHover: onAboutHover,
            items: aboutItems,
          ),
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onPanStart: (_) {
                onDragTitle();
                windowManager.startDragging();
              },
              child: Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Text(
                    l10n.appName,
                    style: appTextStyle(size: 13, color: AppColors.textMuted),
                  ),
                ),
              ),
            ),
          ),
          if (usesCustomCaptionButtons) ...[
            WindowCaptionButton.minimize(
              brightness: Brightness.dark,
              onPressed: windowManager.minimize,
            ),
            WindowCaptionButton.maximize(
              brightness: Brightness.dark,
              onPressed: () async {
                if (await windowManager.isMaximized()) {
                  await windowManager.unmaximize();
                } else {
                  await windowManager.maximize();
                }
              },
            ),
            WindowCaptionButton.close(
              brightness: Brightness.dark,
              onPressed: onExit,
            ),
          ],
        ],
      ),
    ),
      ],
    );
  }
}

class _Toolbar extends StatelessWidget {
  const _Toolbar({
    required this.onOpen,
    required this.onStartAll,
    required this.onStopAll,
    required this.onClear,
    required this.ffmpegReady,
  });

  final VoidCallback onOpen;
  final VoidCallback onStartAll;
  final VoidCallback onStopAll;
  final VoidCallback onClear;
  final bool ffmpegReady;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      height: 52,
      color: AppColors.toolbar,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          FilledButton(
            onPressed: onOpen,
            child: Row(
              children: [
                const Icon(FluentIcons.open_file, size: 14),
                const SizedBox(width: 6),
                Text(l10n.openFile),
              ],
            ),
          ),
          const SizedBox(width: 16),
          const SizedBox(
            height: 22,
            child: VerticalDivider(color: AppColors.border),
          ),
          const SizedBox(width: 16),
          Button(
            onPressed: ffmpegReady ? onStartAll : null,
            child: Row(
              children: [
                const Icon(FluentIcons.play, size: 14),
                const SizedBox(width: 6),
                Text(l10n.startAll),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Button(
            onPressed: onStopAll,
            child: Row(
              children: [
                const Icon(FluentIcons.stop, size: 14),
                const SizedBox(width: 6),
                Text(l10n.stopAll),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Button(
            onPressed: onClear,
            child: Text(l10n.clearFinished),
          ),
          const Spacer(),
          if (!ffmpegReady)
            Text(
              l10n.ffmpegNotDetected,
              style: appTextStyle(size: 13, color: AppColors.warning),
            ),
        ],
      ),
    );
  }
}

class _StatusBar extends StatelessWidget {
  const _StatusBar({
    required this.ffmpegReady,
    required this.ffmpegLabel,
    required this.queueCount,
    required this.runningCount,
    required this.concurrency,
    required this.failedCount,
  });

  final bool ffmpegReady;
  final String ffmpegLabel;
  final int queueCount;
  final int runningCount;
  final int concurrency;
  final int failedCount;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      height: 32,
      color: AppColors.statusBar,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Icon(
            ffmpegReady ? FluentIcons.completed : FluentIcons.warning,
            size: 14,
            color: ffmpegReady ? AppColors.success : AppColors.warning,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              ffmpegReady
                  ? l10n.ffmpegReadyStatus(ffmpegLabel)
                  : ffmpegLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: appTextStyle(size: 13, color: AppColors.textMuted),
            ),
          ),
          Text(
            l10n.queueCount(queueCount),
            style: appTextStyle(size: 13, color: AppColors.textMuted),
          ),
          const SizedBox(width: 12),
          Text(
            l10n.runningCount(runningCount, concurrency),
            style: appTextStyle(size: 13, color: AppColors.textMuted),
          ),
          const SizedBox(width: 12),
          Text(
            l10n.failedCount(failedCount),
            style: appTextStyle(size: 13, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

class VerticalDivider extends StatelessWidget {
  const VerticalDivider({super.key, required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(color: color, child: const SizedBox(width: 1));
  }
}

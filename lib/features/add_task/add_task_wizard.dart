import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/ffmpeg/hardware_probe.dart';
import '../../core/l10n/labels.dart';
import '../../core/models/conversion_task.dart';
import '../../core/models/encode_options.dart';
import '../../core/models/media_format.dart';
import '../../core/models/media_info.dart';
import '../../core/models/source_codec.dart';
import '../../core/platform/fs_paths.dart';
import '../../core/platform/media_picker.dart';
import '../../core/platform/reveal_path.dart';
import '../../core/settings/queue_controller.dart';
import '../../core/settings/settings_controller.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/ui/ui.dart';
import '../../shared/widgets/anchored_tooltip.dart';
import '../../shared/widgets/grouped_dropdown.dart';
import '../../shared/widgets/motion.dart';
import '../../shared/widgets/path_text.dart';

const addTaskFilePaneWidth = 300.0;
const addTaskFilePaneGap = 16.0;
const addTaskFilePaneExtra = addTaskFilePaneWidth + addTaskFilePaneGap;
const addTaskStackBreakpoint = 860.0;

class AddTaskResult {
  const AddTaskResult({
    required this.format,
    required this.inputPaths,
    required this.outputDirectory,
    required this.encode,
    this.outputFileName,
  });

  final MediaFormat format;
  final List<String> inputPaths;
  final String outputDirectory;
  final String? outputFileName;
  final EncodeOptions encode;

  Map<String, dynamic> toJson() {
    return {
      'format': format.id,
      'inputPaths': inputPaths,
      'outputDirectory': outputDirectory,
      'outputFileName': outputFileName,
      'encode': encode.toJson(),
    };
  }

  factory AddTaskResult.fromJson(Map<String, dynamic> json) {
    return AddTaskResult(
      format:
          MediaFormat.byId(json['format'] as String? ?? '') ?? MediaFormat.mp4,
      inputPaths: (json['inputPaths'] as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .toList(),
      outputDirectory: json['outputDirectory'] as String? ?? '',
      outputFileName: json['outputFileName'] as String?,
      encode: json['encode'] is Map<String, dynamic>
          ? EncodeOptions.fromJson(json['encode'] as Map<String, dynamic>)
          : const EncodeOptions(),
    );
  }
}

class AddTaskWizard extends ConsumerStatefulWidget {
  const AddTaskWizard({
    super.key,
    this.initialFormat,
    this.initialFiles = const [],
    this.editing,
    this.onCancel,
    this.onSubmit,
  });

  final MediaFormat? initialFormat;
  final List<String> initialFiles;
  final ConversionTask? editing;
  final VoidCallback? onCancel;
  final FutureOr<void> Function(AddTaskResult result)? onSubmit;

  @override
  ConsumerState<AddTaskWizard> createState() => _AddTaskWizardState();
}

enum _OptionPage { picture, video, audio, output }

class _OptionTab extends StatelessWidget {
  const _OptionTab({
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
        final color = selected
            ? AppColors.accent
            : states.isHovered
                ? AppColors.text
                : AppColors.textMuted;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: selected ? AppColors.accent : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            label,
            style: appTextStyle(weight: FontWeight.w600, color: color),
          ),
        );
      },
    );
  }
}

class _AddTaskWizardState extends ConsumerState<AddTaskWizard> {
  MediaFormat? _format;
  late List<String> _files;
  late EncodeOptions _encode;
  late TextEditingController _inputPath;
  late TextEditingController _outputDir;
  late TextEditingController _outputName;
  late TextEditingController _title;
  late TextEditingController _artist;
  late TextEditingController _album;
  late TextEditingController _year;
  late TextEditingController _comment;
  final Map<String, MediaInfo> _infos = {};
  _OptionPage _page = _OptionPage.picture;

  bool get _editing => widget.editing != null;

  List<String> get _outputPaths {
    if (_editing) {
      final path = _inputPath.text.trim();
      return path.isEmpty ? const [] : [path];
    }
    return _files;
  }

  @override
  void initState() {
    super.initState();
    _files = List<String>.from(widget.initialFiles);
    _format = widget.editing?.targetFormat ??
        widget.initialFormat ??
        (_files.isNotEmpty ? keepOriginalFormatFor(_files.first) : null);
    final settings = ref.read(settingsControllerProvider);
    _encode = widget.editing?.encode ??
        EncodeOptions(
          hardwareDecode: settings.settings.hardwareAcceleration,
        );
    _inputPath = TextEditingController(
      text: widget.editing?.inputPath ??
          (_files.isEmpty ? '' : _files.first),
    );
    _outputDir = TextEditingController(
      text: widget.editing?.outputDirectory ??
          (_files.isEmpty ? '' : directoryOf(_files.first)),
    );
    _outputName = TextEditingController(
      text: widget.editing?.outputFileName ?? defaultOutputNameTemplate,
    );
    _title = TextEditingController(text: _encode.title);
    _artist = TextEditingController(text: _encode.artist);
    _album = TextEditingController(text: _encode.album);
    _year = TextEditingController(text: _encode.year);
    _comment = TextEditingController(text: _encode.comment);
    _loadInfos(_files);
    Future.microtask(_syncHardwareDefault);
  }

  Future<void> _syncHardwareDefault() async {
    await ref.read(settingsControllerProvider.notifier).ensureHardware();
    if (!mounted || widget.editing != null) {
      return;
    }
    final settings = ref.read(settingsControllerProvider);
    final enabled =
        settings.settings.hardwareAcceleration && settings.hardware.anyAvailable;
    if (_encode.hardwareDecode == enabled) {
      return;
    }
    _setEncode(_encode.copyWith(hardwareDecode: enabled));
  }

  @override
  void dispose() {
    _inputPath.dispose();
    _outputDir.dispose();
    _outputName.dispose();
    _title.dispose();
    _artist.dispose();
    _album.dispose();
    _year.dispose();
    _comment.dispose();
    super.dispose();
  }

  void _setEncode(EncodeOptions value) {
    setState(() => _encode = value);
  }

  Future<void> _loadInfos(List<String> paths) async {
    for (final path in paths) {
      if (_infos.containsKey(path)) {
        continue;
      }
      final info = await ref.read(queueControllerProvider.notifier).probe(path);
      if (!mounted) {
        return;
      }
      setState(() => _infos[path] = info);
    }
    if (_outputDir.text.isEmpty && paths.isNotEmpty) {
      _outputDir.text = directoryOf(paths.first);
    }
  }

  void _selectFormat(MediaFormat format) {
    setState(() {
      _format = format;
      if (_outputPaths.length != 1) {
        return;
      }
      final current = _outputName.text.trim();
      if (current.isEmpty || current.contains('{name}')) {
        return;
      }
      _outputName.text = ensureOutputExtension(
        current,
        outputExtensionFor(format, _outputPaths.first),
      );
    });
  }

  List<String> _previewNames() {
    final format = _format;
    if (format == null) {
      return const [];
    }
    return [
      for (final path in _outputPaths)
        applyOutputNameTemplate(
          _outputName.text,
          path,
          extension: outputExtensionFor(format, path),
        ),
    ];
  }

  Future<void> _showNamePreview() async {
    final l10n = AppLocalizations.of(context);
    final names = _previewNames();
    await showDialog<void>(
      context: context,
      transitionBuilder: dialogMotion,
      transitionDuration: motionDuration,
      builder: (context) {
        return ContentDialog(
          title: Text(l10n.outputNamePreviewTitle),
          constraints: const BoxConstraints(maxWidth: 720, maxHeight: 560),
          content: names.isEmpty
              ? Text(
                  l10n.outputNamePreviewEmpty,
                  style: const TextStyle(color: AppColors.textMuted),
                )
              : _NamePreviewTable(
                  originals: [
                    for (final path in _outputPaths) fileNameOf(path),
                  ],
                  converted: names,
                  originalHeader: l10n.outputNamePreviewOriginal,
                  convertedHeader: l10n.outputNamePreviewConverted,
                ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.close),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final canSubmit =
        _format != null &&
        _outputPaths.isNotEmpty &&
        _outputDir.text.trim().isNotEmpty;
    return ColoredBox(
      color: AppColors.surface,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: _buildFormatHeader(),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildBody(),
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
                Button(
                  onPressed: widget.onCancel ?? () => Navigator.of(context).maybePop(),
                  child: Text(l10n.cancel),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: canSubmit ? _submit : null,
                  child: Text(
                    widget.editing == null ? l10n.addToQueue : l10n.saveTask,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormatHeader() {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: GroupedDropdown<MediaFormat>(
          value: _format,
          placeholder: l10n.selectFormatPlaceholder,
          itemLabel: (format) => formatLabel(l10n, format),
          itemDescription: (format) => formatDescription(l10n, format),
          onChanged: _selectFormat,
          groups: [
            GroupedDropdownGroup(
              title: l10n.video,
              items: MediaFormat.videoFormats,
            ),
            GroupedDropdownGroup(
              title: l10n.audio,
              items: MediaFormat.audioFormats,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    final format = _format;
    if (format == null) {
      return Center(
        child: Text(
          AppLocalizations.of(context).selectFormatPlaceholder,
          style: const TextStyle(color: AppColors.textMuted),
        ),
      );
    }
    if (_editing) {
      return _buildOptionsPane(format);
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final stacked = constraints.maxWidth < addTaskStackBreakpoint;
        final files = SizedBox(
          width: stacked ? double.infinity : addTaskFilePaneWidth,
          child: _buildFilePane(),
        );
        final options = Expanded(child: _buildOptionsPane(format));
        if (stacked) {
          return Column(
            children: [
              SizedBox(height: 180, child: files),
              const SizedBox(height: 12),
              options,
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            files,
            const SizedBox(width: addTaskFilePaneGap),
            options,
          ],
        );
      },
    );
  }

  Widget _buildFilePane() {
    final l10n = AppLocalizations.of(context);
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.inputFiles,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              Button(
                onPressed: () async {
                  final picked = await pickMediaFiles(
                    dialogTitle: l10n.pickMediaFiles,
                  );
                  if (picked.isEmpty) {
                    return;
                  }
                  setState(() {
                    for (final path in picked) {
                      if (!_files.contains(path)) {
                        _files.add(path);
                      }
                    }
                  });
                  await _loadInfos(picked);
                },
                child: Text(l10n.addFiles),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _files.isEmpty
                ? Center(
                    child: Text(
                      l10n.noFilesYet,
                      style: const TextStyle(color: AppColors.textMuted),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.only(right: 12),
                    itemCount: _files.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final path = _files[index];
                      final info = _infos[path];
                      return Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceAlt,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              (info?.hasVideo ?? true)
                                  ? FluentIcons.video
                                  : FluentIcons.music_note,
                              color: AppColors.accent,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    fileNameOf(path),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  PathText(path),
                                  Text(
                                    [
                                      info == null
                                          ? l10n.reading
                                          : mediaDurationLabel(l10n, info),
                                      if (info?.hasVideo == true)
                                        mediaResolutionLabel(l10n, info!),
                                      if (info?.hasAudio == true &&
                                          info?.channels != null)
                                        l10n.channelCount(info!.channels!),
                                    ].join('  ·  '),
                                    style: const TextStyle(
                                      color: AppColors.textMuted,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(FluentIcons.delete),
                              onPressed: () =>
                                  setState(() => _files.removeAt(index)),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildOutputPathFields(AppLocalizations l10n) {
    return Column(
      children: [
        _field(
          l10n.outputDirectory,
          Row(
            children: [
              Expanded(
                child: TextBox(
                  controller: _outputDir,
                  placeholder: l10n.pickOutputDirectory,
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 8),
              _pathIconButton(
                icon: FluentIcons.folder_open,
                message: l10n.openOutputFolder,
                onPressed: _outputDir.text.trim().isEmpty
                    ? null
                    : () => openDirectory(_outputDir.text.trim()),
              ),
              const SizedBox(width: 4),
              _pathIconButton(
                icon: FluentIcons.open_file,
                message: l10n.browse,
                onPressed: () async {
                  final dir = await pickDirectory(
                    initialDirectory: _outputDir.text,
                    dialogTitle: l10n.pickOutputDirectory,
                  );
                  if (dir != null) {
                    setState(() => _outputDir.text = dir);
                  }
                },
              ),
            ],
          ),
        ),
        _field(
          l10n.outputFileName,
          Row(
            children: [
              Expanded(
                child: TextBox(
                  controller: _outputName,
                  placeholder: l10n.outputFileNameExample('{name}'),
                ),
              ),
              const SizedBox(width: 8),
              AnchoredTooltip(
                message: l10n.outputNamePreviewTitle,
                child: IconButton(
                  icon: const Icon(FluentIcons.red_eye, size: 16),
                  onPressed: _outputPaths.isEmpty ? null : _showNamePreview,
                ),
              ),
            ],
          ),
          labelTrailing: AnchoredTooltip(
            message: l10n.outputFileNameHint('{name}'),
            child: const Padding(
              padding: EdgeInsets.only(left: 4),
              child: Icon(
                FluentIcons.info,
                size: 14,
                color: AppColors.textMuted,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOptionsPane(MediaFormat format) {
    final l10n = AppLocalizations.of(context);
    final copyOnly = format.keepsSourceCodec;
    final encodeFormat = _encodeFormat(format);
    final audioFormat = _audioEncodeFormat(format);
    final advanced = formatSupportsAdvancedVideo(encodeFormat.id);
    final animation = encodeFormat.id == 'gif' || encodeFormat.id == 'webp';
    final encoder = resolveVideoEncoder(encodeFormat.id, _encode.videoEncoder);
    final tenBit = advanced &&
        tenBitFormats.contains(encodeFormat.id) &&
        encoderSupportsTenBit(encoder);
    final lockedMobile = encodeFormat.id == 'flv' || encodeFormat.id == '3gp';
    final losslessAudio = const {'wav', 'aiff', 'flac', 'alac', 'wv', 'tta', 'caf'}
        .contains(audioFormat.id);
    final amr = audioFormat.id == 'amr';
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_editing)
            _field(
              l10n.inputFilePath,
              Row(
                children: [
                  Expanded(
                    child: TextBox(
                      controller: _inputPath,
                      placeholder: l10n.inputFilePath,
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _pathIconButton(
                    icon: FluentIcons.folder_open,
                    message: l10n.openInputFolder,
                    onPressed: _inputPath.text.trim().isEmpty
                        ? null
                        : () => revealInExplorer(_inputPath.text.trim()),
                  ),
                  const SizedBox(width: 4),
                  _pathIconButton(
                    icon: FluentIcons.open_file,
                    message: l10n.browse,
                    onPressed: () async {
                      final picked = await pickMediaFiles(
                        dialogTitle: l10n.pickMediaFiles,
                        allowMultiple: false,
                      );
                      if (picked.isEmpty) {
                        return;
                      }
                      setState(() => _inputPath.text = picked.first);
                      await _loadInfos(picked);
                    },
                  ),
                ],
              ),
            ),
          _buildOutputPathFields(l10n),
          const SizedBox(height: 12),
          DecoratedBox(
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                for (final page in _OptionPage.values)
                  _OptionTab(
                    label: switch (page) {
                      _OptionPage.picture => l10n.picture,
                      _OptionPage.video => l10n.video,
                      _OptionPage.audio => l10n.audio,
                      _OptionPage.output => l10n.output,
                    },
                    selected: _page == page,
                    onPressed: () => setState(() => _page = page),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView(
                padding: const EdgeInsets.only(right: 12, bottom: 8),
                children: switch (_page) {
                  _OptionPage.picture => _pictureFields(encodeFormat, animation),
                  _OptionPage.video => _videoFields(
                      encodeFormat,
                      copyOnly,
                      advanced,
                      animation,
                      encoder,
                      tenBit,
                      lockedMobile,
                    ),
                  _OptionPage.audio => _audioFields(
                      audioFormat,
                      copyOnly,
                      losslessAudio,
                      amr,
                    ),
                  _OptionPage.output => _outputFields(encodeFormat),
                },
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _pictureFields(MediaFormat format, bool animation) {
    final l10n = AppLocalizations.of(context);
    if (!format.isVideo) {
      return [
        Text(l10n.noPictureProcessing, style: const TextStyle(color: AppColors.textMuted)),
      ];
    }
    return [
      _field(
        l10n.resolutionPreset,
        ComboBox<OutputPreset>(
          value: _encode.outputPreset,
          isExpanded: true,
          items: [
            for (final preset in OutputPreset.values)
              ComboBoxItem(
                value: preset,
                child: Text(outputPresetLabel(l10n, preset)),
              ),
          ],
          onChanged: (value) {
            if (value != null) {
              _setEncode(_encode.applyPreset(value));
            }
          },
        ),
      ),
      _pair(
        _field(l10n.width, _dimensionBox(width: true)),
        _field(l10n.height, _dimensionBox(width: false)),
      ),
      _pair(
        _field(
          l10n.keepAspectRatio,
          ToggleSwitch(
            checked: _encode.keepAspectRatio,
            onChanged: (value) =>
                _setEncode(_encode.copyWith(keepAspectRatio: value)),
          ),
        ),
        _enumField(
          l10n.scaleAlgorithm,
          ScaleFlags.values,
          _encode.scaleFlags,
          (value) => scaleFlagsLabel(l10n, value),
          (value) => _setEncode(_encode.copyWith(scaleFlags: value)),
          enabled: !animation,
        ),
      ),
      _enumField(
        l10n.rotation,
        VideoRotation.values,
        _encode.rotation,
        (value) => rotationLabel(l10n, value),
        (value) => _setEncode(_encode.copyWith(rotation: value)),
      ),
      _enumField(
        l10n.deinterlace,
        DeinterlaceMode.values,
        _encode.deinterlace,
        (value) => deinterlaceLabel(l10n, value),
        (value) => _setEncode(_encode.copyWith(deinterlace: value)),
        enabled: !animation,
      ),
      _pair(
        _field(
          l10n.flipHorizontal,
          ToggleSwitch(
            checked: _encode.flipHorizontal,
            onChanged: (value) =>
                _setEncode(_encode.copyWith(flipHorizontal: value)),
          ),
        ),
        _field(
          l10n.flipVertical,
          ToggleSwitch(
            checked: _encode.flipVertical,
            onChanged: (value) =>
                _setEncode(_encode.copyWith(flipVertical: value)),
          ),
        ),
      ),
    ];
  }

  List<Widget> _videoFields(
    MediaFormat format,
    bool copyOnly,
    bool advanced,
    bool animation,
    VideoEncoderChoice encoder,
    bool tenBit,
    bool lockedMobile,
  ) {
    final l10n = AppLocalizations.of(context);
    if (!format.isVideo) {
      return [
        Text(l10n.noVideoReencode, style: const TextStyle(color: AppColors.textMuted)),
      ];
    }
    final process = encodeNeedsVideoProcessing(_encode);
    final hint = copyOnly
        ? [
            Text(
              process ? l10n.copyVideoWillReencode : l10n.copyVideoKeepCopy,
              style: const TextStyle(color: AppColors.textMuted),
            ),
          ]
        : const <Widget>[];
    if (!advanced && !animation) {
      return [
        ...hint,
        _pair(_qualityField(), _videoBitrateField()),
        _frameRateField(),
        Text(l10n.fixedEncoder, style: const TextStyle(color: AppColors.textMuted)),
      ];
    }
    if (animation) {
      return [...hint, _frameRateField(placeholder: l10n.defaultFps15)];
    }
    final encoders = videoEncodersFor(format.id)
        .where((value) => !encoderIsHardware(value))
        .toList(growable: false);
    final hardware = ref.watch(settingsControllerProvider).hardware;
    final selectedEncoder = encoders.contains(_encode.videoEncoder)
        ? _encode.videoEncoder
        : VideoEncoderChoice.auto;
    return [
      ...hint,
      _field(
        l10n.hardwareAccel,
        ToggleSwitch(
          checked: _encode.hardwareDecode,
          content: Text(_hardwareStatusText(hardware)),
          onChanged: hardware.isProbed && hardware.anyAvailable
              ? (value) => _setEncode(_encode.copyWith(hardwareDecode: value))
              : null,
        ),
        note: !hardware.isProbed
            ? (ref.watch(settingsControllerProvider).ffmpegReady
                ? l10n.detectingGpu
                : l10n.noGpuEncoder)
            : hardware.anyAvailable
            ? l10n.hardwareAccelOnHint
            : l10n.noGpuEncoder,
      ),
      _pair(
        _enumField(
          l10n.encoder,
          encoders,
          selectedEncoder,
          (value) => videoEncoderLabel(l10n, value),
          (value) => _setEncode(_encode.copyWith(videoEncoder: value)),
          enabled: !_encode.hardwareDecode,
          note: _encode.hardwareDecode
              ? l10n.hardwarePicksEncoder
              : (copyOnly ? l10n.copyVideoEncoderLocked : null),
        ),
        _enumField(
          l10n.speed,
          EncoderSpeed.values,
          _encode.speed,
          (value) => encoderSpeedLabel(l10n, value),
          (value) => _setEncode(_encode.copyWith(speed: value)),
        ),
      ),
      _pair(
        _enumField(
          l10n.contentTune,
          VideoTune.values,
          _encode.tune,
          (value) => videoTuneLabel(l10n, value),
          (value) => _setEncode(_encode.copyWith(tune: value)),
        ),
        _enumField(
          'Profile',
          H264ProfileChoice.values,
          _encode.h264Profile,
          (value) => value == H264ProfileChoice.auto ? l10n.auto : value.name,
          (value) => _setEncode(_encode.copyWith(h264Profile: value)),
          enabled: !lockedMobile &&
              encoder != VideoEncoderChoice.h265 &&
              encoder != VideoEncoderChoice.h265Nvenc &&
              encoder != VideoEncoderChoice.h265Amf &&
              encoder != VideoEncoderChoice.h265Qsv &&
              encoder != VideoEncoderChoice.h265Vaapi &&
              encoder != VideoEncoderChoice.h265Videotoolbox &&
              encoder != VideoEncoderChoice.vp9 &&
              encoder != VideoEncoderChoice.av1,
          note: lockedMobile ? l10n.lockedMobileProfile : null,
        ),
      ),
      _pair(
        _enumField(
          l10n.pixelFormat,
          PixelFormatChoice.values,
          _encode.pixelFormat,
          (value) => pixelFormatLabel(l10n, value),
          (value) => _setEncode(_encode.copyWith(pixelFormat: value)),
          enabled: tenBit || _encode.pixelFormat == PixelFormatChoice.yuv420p,
          note: tenBit ? null : l10n.encoder8bitOnly,
        ),
        _enumField(
          l10n.rateControl,
          RateControlMode.values,
          _encode.rateControl,
          (value) => rateControlLabel(l10n, value),
          (value) => _setEncode(_encode.copyWith(rateControl: value)),
        ),
      ),
      if (_encode.rateControl == RateControlMode.quality)
        _pair(
          _qualityField(),
          _field(
            l10n.crfFollowsQuality,
            NumberBox<int>(
              value: _encode.crf,
              min: 0,
              max: crfUpperBound(encoder),
              placeholder: '${qualityToCrf(_encode.qualityPreset)}',
              onChanged: (value) => _setEncode(
                _encode.copyWith(
                  crf: value,
                  clearCrf: value == null,
                  qualityPreset: QualityPreset.custom,
                ),
              ),
            ),
          ),
        )
      else ...[
        if (_encode.rateControl == RateControlMode.vbr)
          _pair(
            _videoBitrateField(),
            _field(
              l10n.maxBitrateKbps,
              NumberBox<int>(
                value: _encode.maxRateKbps,
                min: 100,
                max: 200000,
                placeholder: l10n.optionalHint,
                onChanged: (value) => _setEncode(
                  _encode.copyWith(
                    maxRateKbps: value,
                    clearMaxRate: value == null,
                  ),
                ),
              ),
            ),
          )
        else
          _videoBitrateField(),
        _field(
          l10n.bufsizeKbps,
          NumberBox<int>(
            value: _encode.bufSizeKbps,
            min: 100,
            max: 400000,
            placeholder: l10n.optionalHint,
            onChanged: (value) => _setEncode(
              _encode.copyWith(bufSizeKbps: value, clearBufSize: value == null),
            ),
          ),
        ),
      ],
      _pair(
        _frameRateField(),
        _enumField(
          l10n.fpsMode,
          FpsModeChoice.values,
          _encode.fpsMode,
          (value) => fpsModeLabel(l10n, value),
          (value) => _setEncode(_encode.copyWith(fpsMode: value)),
        ),
      ),
      _enumField(
        l10n.keyframeInterval,
        KeyframeInterval.values,
        _encode.keyframeInterval,
        (value) => keyframeIntervalLabel(l10n, value),
        (value) => _setEncode(_encode.copyWith(keyframeInterval: value)),
      ),
    ];
  }

  List<Widget> _audioFields(
    MediaFormat format,
    bool copyOnly,
    bool losslessAudio,
    bool amr,
  ) {
    final l10n = AppLocalizations.of(context);
    final process = encodeNeedsAudioProcessing(_encode);
    final surround = const {'ac3', 'flac', 'opus', 'mpeg', 'ts', 'm2ts'}.contains(format.id);
    return [
      if (copyOnly)
        Text(
          process ? l10n.copyAudioWillReencode : l10n.copyAudioKeepCopy,
          style: const TextStyle(color: AppColors.textMuted),
        ),
      if (amr)
        Text(l10n.amrFixed, style: const TextStyle(color: AppColors.textMuted))
      else ...[
        if (!losslessAudio && format.id != 'opus')
          _enumField(
            l10n.audioControl,
            AudioRateMode.values,
            _encode.audioRateMode,
            (value) => audioRateModeLabel(l10n, value),
            (value) => _setEncode(_encode.copyWith(audioRateMode: value)),
          ),
        if (!losslessAudio && _encode.audioRateMode == AudioRateMode.bitrate)
          _field(
            l10n.audioBitrateKbps,
            NumberBox<int>(
              value: _encode.audioBitrateKbps,
              min: 32,
              max: 1411,
              placeholder: l10n.optionalHint,
              onChanged: (value) => _setEncode(
                _encode.copyWith(
                  audioBitrateKbps: value,
                  clearAudioBitrate: value == null,
                ),
              ),
            ),
          ),
        if (!losslessAudio &&
            format.id != 'opus' &&
            _encode.audioRateMode == AudioRateMode.quality)
          _field(
            format.id == 'mp3' ? l10n.mp3Quality : l10n.aacQuality,
            NumberBox<int>(
              value: _encode.audioQuality,
              min: format.id == 'mp3' ? 0 : 1,
              max: format.id == 'mp3' ? 9 : 5,
              placeholder: format.id == 'mp3' ? '4' : '2',
              onChanged: (value) => _setEncode(
                _encode.copyWith(audioQuality: value, clearAudioQuality: value == null),
              ),
            ),
          ),
        if (format.id == 'flac')
          _field(
            l10n.flacCompression,
            NumberBox<int>(
              value: _encode.flacCompression,
              min: 0,
              max: 12,
              onChanged: (value) {
                if (value != null) {
                  _setEncode(_encode.copyWith(flacCompression: value));
                }
              },
            ),
          ),
        if (format.id == 'opus')
          _pair(
            _enumField(
              l10n.opusRateMode,
              OpusVbrMode.values,
              _encode.opusVbr,
              (value) => opusVbrLabel(l10n, value),
              (value) => _setEncode(_encode.copyWith(opusVbr: value)),
            ),
            _enumField(
              l10n.opusApplicationField,
              OpusApplication.values,
              _encode.opusApplication,
              (value) => opusApplicationLabel(l10n, value),
              (value) => _setEncode(_encode.copyWith(opusApplication: value)),
            ),
          ),
        _pair(
          _field(
            l10n.sampleRate,
            ComboBox<int?>(
              value: _encode.sampleRate,
              isExpanded: true,
              items: [
                ComboBoxItem(value: null, child: Text(l10n.followSource)),
                const ComboBoxItem(value: 8000, child: Text('8000 Hz')),
                const ComboBoxItem(value: 16000, child: Text('16000 Hz')),
                const ComboBoxItem(value: 22050, child: Text('22050 Hz')),
                const ComboBoxItem(value: 44100, child: Text('44100 Hz')),
                const ComboBoxItem(value: 48000, child: Text('48000 Hz')),
                const ComboBoxItem(value: 96000, child: Text('96000 Hz')),
              ],
              onChanged: (value) => _setEncode(
                _encode.copyWith(
                  sampleRate: value,
                  clearSampleRate: value == null,
                ),
              ),
            ),
            note: l10n.sampleRateNote,
          ),
          _field(
            l10n.channels,
            ComboBox<int?>(
              value: _encode.channels,
              isExpanded: true,
              items: [
                ComboBoxItem(value: null, child: Text(l10n.followSource)),
                ComboBoxItem(value: 1, child: Text(l10n.mono)),
                ComboBoxItem(value: 2, child: Text(l10n.stereo)),
                if (surround) const ComboBoxItem(value: 6, child: Text('5.1')),
              ],
              onChanged: (value) => _setEncode(
                _encode.copyWith(channels: value, clearChannels: value == null),
              ),
            ),
          ),
        ),
      ],
      _pair(
        _field(
          l10n.volumeDb,
          NumberBox<double>(
            value: _encode.volumeDb,
            min: -10,
            max: 10,
            smallChange: 0.5,
            onChanged: _encode.loudnessNormalize
                ? null
                : (value) => _setEncode(_encode.copyWith(volumeDb: value ?? 0)),
          ),
          note: _encode.loudnessNormalize ? l10n.loudnessSkipsVolume : null,
        ),
        _field(
          l10n.loudnessNormalize,
          ToggleSwitch(
            checked: _encode.loudnessNormalize,
            onChanged: (value) =>
                _setEncode(_encode.copyWith(loudnessNormalize: value)),
          ),
        ),
      ),
    ];
  }

  List<Widget> _outputFields(MediaFormat format) {
    final l10n = AppLocalizations.of(context);
    final fastStart = format.id == 'mp4' || format.id == 'mov';
    return [
      if (fastStart)
        _field(
          l10n.fastStart,
          ToggleSwitch(
            checked: _encode.fastStart,
            onChanged: (value) => _setEncode(_encode.copyWith(fastStart: value)),
          ),
        ),
      _pair(
        _field(
          l10n.keepMetadata,
          ToggleSwitch(
            checked: _encode.keepMetadata,
            onChanged: (value) =>
                _setEncode(_encode.copyWith(keepMetadata: value)),
          ),
        ),
        _field(
          l10n.keepChapters,
          ToggleSwitch(
            checked: _encode.keepChapters,
            onChanged: (value) =>
                _setEncode(_encode.copyWith(keepChapters: value)),
          ),
        ),
      ),
      _pair(
        _metadataBox(
          l10n.metadataTitle,
          _title,
          (value) => _encode.copyWith(title: value),
        ),
        _metadataBox(
          l10n.metadataArtist,
          _artist,
          (value) => _encode.copyWith(artist: value),
        ),
      ),
      _pair(
        _metadataBox(
          l10n.metadataAlbum,
          _album,
          (value) => _encode.copyWith(album: value),
        ),
        _metadataBox(
          l10n.metadataYear,
          _year,
          (value) => _encode.copyWith(year: value),
        ),
      ),
      _metadataBox(
        l10n.metadataComment,
        _comment,
        (value) => _encode.copyWith(comment: value),
      ),
    ];
  }

  Widget _qualityField() {
    final l10n = AppLocalizations.of(context);
    return _field(
      l10n.qualityPreset,
      ComboBox<QualityPreset>(
        value: _encode.qualityPreset,
        isExpanded: true,
        items: [
          for (final preset in QualityPreset.values)
            if (preset != QualityPreset.custom)
              ComboBoxItem(
                value: preset,
                child: Text(qualityPresetLabel(l10n, preset)),
              ),
          if (_encode.qualityPreset == QualityPreset.custom)
            ComboBoxItem(value: QualityPreset.custom, child: Text(l10n.custom)),
        ],
        onChanged: (value) {
          if (value != null && value != QualityPreset.custom) {
            _setEncode(_encode.copyWith(qualityPreset: value, clearCrf: true));
          }
        },
      ),
    );
  }

  Widget _videoBitrateField() {
    final l10n = AppLocalizations.of(context);
    return _field(
      l10n.videoBitrateKbps,
      NumberBox<int>(
        value: _encode.videoBitrateKbps,
        min: 100,
        max: 200000,
        placeholder: l10n.required,
        onChanged: (value) => _setEncode(
          _encode.copyWith(videoBitrateKbps: value, clearVideoBitrate: value == null),
        ),
      ),
    );
  }

  Widget _frameRateField({String? placeholder}) {
    final l10n = AppLocalizations.of(context);
    return _field(
      l10n.frameRate,
      ComboBox<double?>(
        value: _encode.frameRate,
        isExpanded: true,
        items: [
          ComboBoxItem(value: null, child: Text(placeholder ?? l10n.followSource)),
          const ComboBoxItem(value: 24, child: Text('24')),
          const ComboBoxItem(value: 30, child: Text('30')),
          const ComboBoxItem(value: 60, child: Text('60')),
        ],
        onChanged: (value) => _setEncode(
          _encode.copyWith(frameRate: value, clearFrameRate: value == null),
        ),
      ),
    );
  }

  Widget _dimensionBox({required bool width}) {
    final l10n = AppLocalizations.of(context);
    return NumberBox<int>(
      value: width ? _encode.width : _encode.height,
      min: 2,
      max: width ? 7680 : 4320,
      placeholder: l10n.optionalHint,
      onChanged: (value) => _setEncode(
        width
            ? _encode.copyWith(
                outputPreset: OutputPreset.custom,
                width: value,
                clearWidth: value == null,
              )
            : _encode.copyWith(
                outputPreset: OutputPreset.custom,
                height: value,
                clearHeight: value == null,
              ),
      ),
    );
  }

  String? get _primaryInputPath {
    if (_editing) {
      final path = _inputPath.text.trim();
      return path.isEmpty ? null : path;
    }
    return _files.isEmpty ? null : _files.first;
  }

  MediaFormat _encodeFormat(MediaFormat format) {
    final path = _primaryInputPath;
    if (path == null) {
      return format;
    }
    return effectiveEncodeFormat(format, path);
  }

  MediaFormat _audioEncodeFormat(MediaFormat format) {
    if (!format.keepsSourceCodec) {
      return format;
    }
    return audioFormatForSourceCodec(_sourceAudioCodec()) ??
        _encodeFormat(format);
  }

  String? _sourceAudioCodec() {
    for (final path in _outputPaths) {
      final codec = _infos[path]?.audioCodec;
      if (codec != null && codec.isNotEmpty) {
        return codec;
      }
    }
    return null;
  }

  String _hardwareStatusText(HardwareCapabilities hardware) {
    final l10n = AppLocalizations.of(context);
    if (!hardware.isProbed) {
      return ref.watch(settingsControllerProvider).ffmpegReady
          ? l10n.detectingGpu
          : l10n.noGpuDetected;
    }
    final available = hardware.all.where((item) => item.isAvailable).toList();
    if (available.isEmpty) {
      return l10n.noGpuDetected;
    }
    return l10n.usingGpus(
      available.map((item) => item.label).join(l10n.listSeparator),
    );
  }

  Widget _enumField<T>(
    String label,
    List<T> values,
    T selected,
    String Function(T value) itemLabel,
    ValueChanged<T> onChanged, {
    bool enabled = true,
    String? note,
  }) {
    return _field(
      label,
      ComboBox<T>(
        value: selected,
        isExpanded: true,
        items: [
          for (final value in values)
            ComboBoxItem(value: value, child: Text(itemLabel(value))),
        ],
        onChanged: enabled
            ? (value) {
                if (value != null) {
                  onChanged(value);
                }
              }
            : null,
      ),
      note: note,
    );
  }

  Widget _metadataBox(
    String label,
    TextEditingController controller,
    EncodeOptions Function(String value) update,
  ) {
    return _field(
      label,
      TextBox(
        controller: controller,
        onChanged: (value) => _setEncode(update(value)),
      ),
    );
  }

  Widget _pathIconButton({
    required IconData icon,
    required String message,
    required VoidCallback? onPressed,
  }) {
    return AnchoredTooltip(
      message: message,
      child: IconButton(
        icon: Icon(icon, size: 16),
        onPressed: onPressed,
      ),
    );
  }

  static const _twoColumnMinWidth = 680.0;

  Widget _pair(Widget left, Widget right) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < _twoColumnMinWidth) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [left, right],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: left),
            const SizedBox(width: 16),
            Expanded(child: right),
          ],
        );
      },
    );
  }

  Widget _field(
    String label,
    Widget child, {
    String? note,
    Widget? labelTrailing,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 148,
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    label,
                    style: appTextStyle(size: 14),
                  ),
                ),
                if (labelTrailing != null) labelTrailing,
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                child,
                if (note != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    note,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    final paths = List<String>.from(_outputPaths);
    final format = _format!;
    final result = AddTaskResult(
      format: format,
      inputPaths: paths,
      outputDirectory: _outputDir.text.trim(),
      outputFileName: paths.length == 1
          ? applyOutputNameTemplate(
              _outputName.text,
              paths.first,
              extension: outputExtensionFor(format, paths.first),
            )
          : _outputName.text.trim(),
      encode: _encode,
    );
    final submit = widget.onSubmit;
    if (submit != null) {
      await submit(result);
      return;
    }
    Navigator.of(context).pop(result);
  }
}

class _NamePreviewTable extends StatelessWidget {
  const _NamePreviewTable({
    required this.originals,
    required this.converted,
    required this.originalHeader,
    required this.convertedHeader,
  });

  final List<String> originals;
  final List<String> converted;
  final String originalHeader;
  final String convertedHeader;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final contentWidth = (constraints.maxWidth - appScrollbarGutter)
              .clamp(0.0, double.infinity);
          return Stack(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsetsDirectional.only(
                      end: appScrollbarGutter,
                    ),
                    child: _NamePreviewRow(
                      left: originalHeader,
                      right: convertedHeader,
                      header: true,
                    ),
                  ),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 360),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(7),
                      ),
                      child: ListView.builder(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          itemCount: originals.length,
                          itemBuilder: (context, index) {
                            return _NamePreviewRow(
                              left: originals[index],
                              right: converted[index],
                              striped: index.isOdd,
                            );
                          },
                      ),
                    ),
                  ),
                ],
              ),
              Positioned(
                left: contentWidth / 2,
                top: 0,
                bottom: 0,
                child: const ColoredBox(
                  color: AppColors.border,
                  child: SizedBox(width: 1),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _NamePreviewRow extends StatelessWidget {
  const _NamePreviewRow({
    required this.left,
    required this.right,
    this.header = false,
    this.striped = false,
  });

  final String left;
  final String right;
  final bool header;
  final bool striped;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: header
            ? AppColors.surface
            : striped
            ? AppColors.surface.withValues(alpha: 0.4)
            : const Color(0x00000000),
        border: const Border(
          bottom: BorderSide(color: AppColors.border),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _NamePreviewCell(text: left, header: header),
          ),
          Expanded(
            child: _NamePreviewCell(text: right, header: header),
          ),
        ],
      ),
    );
  }
}

class _NamePreviewCell extends StatelessWidget {
  const _NamePreviewCell({required this.text, required this.header});

  final String text;
  final bool header;

  @override
  Widget build(BuildContext context) {
    final style = appTextStyle(
      size: header ? 12 : 13,
      weight: header ? FontWeight.w700 : FontWeight.w500,
      color: header ? AppColors.textMuted : AppColors.text,
    );
    final display = header ? text : _breakableFileName(text);
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 12,
        vertical: header ? 8 : 10,
      ),
      child: header
          ? Text(display, style: style)
          : SelectableText(display, style: style),
    );
  }
}

String _breakableFileName(String value) {
  return value.replaceAllMapped(
    RegExp(r'[._\-]'),
    (match) => '${match[0]}\u200B',
  );
}

import '../../core/models/app_settings.dart';
import '../../core/models/media_format.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/ui/ui.dart';
import '../../shared/widgets/format_card.dart';

class FormatPanel extends StatefulWidget {
  const FormatPanel({
    super.key,
    required this.width,
    required this.onResize,
    required this.onFormatTap,
    required this.onFilesDropped,
    this.dropEnabled = true,
  });

  final double width;
  final ValueChanged<double> onResize;
  final ValueChanged<MediaFormat> onFormatTap;
  final void Function(MediaFormat format, List<String> paths) onFilesDropped;
  final bool dropEnabled;

  @override
  State<FormatPanel> createState() => _FormatPanelState();
}

class _FormatPanelState extends State<FormatPanel> {
  double? _dragStartWidth;
  double? _pointerStartX;
  bool _videoExpanded = true;
  bool _audioExpanded = true;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final width = widget.width;
    return ColoredBox(
      color: AppColors.surface,
      child: SizedBox(
        width: width,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                child: ListView(
                  children: [
                    _FormatSection(
                      title: l10n.convertToVideo,
                      expanded: _videoExpanded,
                      onToggle: () =>
                          setState(() => _videoExpanded = !_videoExpanded),
                      child: _FormatGrid(
                        formats: MediaFormat.videoFormats,
                        panelWidth: width - 40,
                        dropEnabled: widget.dropEnabled,
                        onTap: widget.onFormatTap,
                        onFilesDropped: widget.onFilesDropped,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _FormatSection(
                      title: l10n.convertToAudio,
                      expanded: _audioExpanded,
                      onToggle: () =>
                          setState(() => _audioExpanded = !_audioExpanded),
                      child: _FormatGrid(
                        formats: MediaFormat.audioFormats,
                        panelWidth: width - 40,
                        dropEnabled: widget.dropEnabled,
                        onTap: widget.onFormatTap,
                        onFilesDropped: widget.onFilesDropped,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            MouseRegion(
              cursor: SystemMouseCursors.resizeColumn,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onHorizontalDragStart: (details) {
                  _dragStartWidth = widget.width;
                  _pointerStartX = details.globalPosition.dx;
                },
                onHorizontalDragUpdate: (details) {
                  final startWidth = _dragStartWidth;
                  final startX = _pointerStartX;
                  if (startWidth == null || startX == null) {
                    return;
                  }
                  widget.onResize(
                    (startWidth + details.globalPosition.dx - startX).clamp(
                      AppSettings.minLeftPanelWidth,
                      AppSettings.maxLeftPanelWidth,
                    ),
                  );
                },
                onHorizontalDragEnd: (_) {
                  _dragStartWidth = null;
                  _pointerStartX = null;
                },
                onHorizontalDragCancel: () {
                  _dragStartWidth = null;
                  _pointerStartX = null;
                },
                child: const SizedBox(width: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FormatSection extends StatelessWidget {
  const _FormatSection({
    required this.title,
    required this.expanded,
    required this.onToggle,
    required this.child,
  });

  final String title;
  final bool expanded;
  final VoidCallback onToggle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        HoverButton(
          onPressed: onToggle,
          builder: (context, states) {
            final hovered = states.isHovered;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Icon(
                    expanded
                        ? FluentIcons.chevron_down
                        : FluentIcons.chevron_right,
                    size: 12,
                    color: hovered ? AppColors.text : AppColors.textMuted,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            );
          },
        ),
        if (expanded) ...[
          const SizedBox(height: 4),
          child,
        ],
      ],
    );
  }
}

class _FormatGrid extends StatelessWidget {
  const _FormatGrid({
    required this.formats,
    required this.panelWidth,
    required this.onTap,
    required this.onFilesDropped,
    required this.dropEnabled,
  });

  final List<MediaFormat> formats;
  final double panelWidth;
  final ValueChanged<MediaFormat> onTap;
  final void Function(MediaFormat format, List<String> paths) onFilesDropped;
  final bool dropEnabled;

  @override
  Widget build(BuildContext context) {
    const spacing = 8.0;
    const minCard = 96.0;
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = (constraints.maxWidth / (minCard + spacing))
            .floor()
            .clamp(2, 4);
        final itemWidth =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;
        final itemHeight = itemWidth / 0.86;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final format in formats)
              SizedBox(
                width: itemWidth,
                height: itemHeight,
                child: FormatCard(
                  format: format,
                  onTap: () => onTap(format),
                  onFilesDropped: dropEnabled
                      ? (paths) => onFilesDropped(format, paths)
                      : null,
                ),
              ),
          ],
        );
      },
    );
  }
}

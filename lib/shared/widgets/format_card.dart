import 'package:desktop_drop/desktop_drop.dart';

import '../../core/l10n/labels.dart';
import '../../core/models/media_format.dart';
import '../../l10n/app_localizations.dart';
import '../ui/ui.dart';
import 'anchored_tooltip.dart';

class FormatCard extends StatefulWidget {
  const FormatCard({
    super.key,
    required this.format,
    this.selected = false,
    this.compact = false,
    this.onTap,
    this.onFilesDropped,
  });

  final MediaFormat format;
  final bool selected;
  final bool compact;
  final VoidCallback? onTap;
  final ValueChanged<List<String>>? onFilesDropped;

  @override
  State<FormatCard> createState() => _FormatCardState();
}

class _FormatCardState extends State<FormatCard> {
  bool _hovering = false;
  bool _dropping = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final label = formatLabel(l10n, widget.format);
    final highlighted = widget.selected || _hovering || _dropping;
    final child = MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          decoration: BoxDecoration(
            color: highlighted ? AppColors.surfaceAlt : AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _dropping
                  ? AppColors.accent
                  : widget.selected
                  ? AppColors.accentDim
                  : AppColors.border,
              width: _dropping ? 2 : 1,
            ),
          ),
          padding: EdgeInsets.all(widget.compact ? 8 : 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: _FormatThumb(
                  format: widget.format,
                  compact: widget.compact,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: appTextStyle(
                  size: widget.compact ? 13 : 15,
                  weight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    final tooltip = AnchoredTooltip(
      message: '$label  ·  ${formatDescription(l10n, widget.format)}',
      child: child,
    );

    if (widget.onFilesDropped == null) {
      return tooltip;
    }
    return DropTarget(
      onDragEntered: (_) => setState(() => _dropping = true),
      onDragExited: (_) => setState(() => _dropping = false),
      onDragDone: (details) {
        setState(() => _dropping = false);
        final paths = details.files
            .map((file) => file.path)
            .where(isMediaPath)
            .toList(growable: false);
        if (paths.isEmpty) {
          return;
        }
        widget.onFilesDropped!(paths);
      },
      child: tooltip,
    );
  }
}

class _FormatThumb extends StatelessWidget {
  const _FormatThumb({required this.format, required this.compact});

  final MediaFormat format;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            format.color.withValues(alpha: 0.92),
            format.color.withValues(alpha: 0.55),
            const Color(0xFF0B1220),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -8,
            bottom: -10,
            child: Icon(
              format.isVideo ? FluentIcons.video : FluentIcons.music_note,
              size: compact ? 36 : 44,
              color: Colors.white.withValues(alpha: 0.18),
            ),
          ),
          Center(
            child: Text(
              format.extension.replaceFirst('.', '').toUpperCase(),
              style: TextStyle(
                fontSize: compact ? 16 : 18,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 0.8,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

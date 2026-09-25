import '../ui/ui.dart';
import 'anchored_tooltip.dart';

class PathText extends StatelessWidget {
  const PathText(this.text, {super.key, this.maxLines = 1});

  final String text;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return AnchoredTooltip(
      message: text,
      child: Text(
        text,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        style: appTextStyle(size: 13, color: AppColors.textMuted),
      ),
    );
  }
}

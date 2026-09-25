import 'package:flutter/widgets.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 16});

  static const assetPath = 'assets/icons/app_icon.png';

  final double size;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      assetPath,
      width: size,
      height: size,
      filterQuality: FilterQuality.medium,
      gaplessPlayback: true,
    );
  }
}

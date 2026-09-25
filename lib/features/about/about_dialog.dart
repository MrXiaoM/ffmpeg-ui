import 'package:url_launcher/url_launcher.dart';

import '../../app_info.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/ui/ui.dart';
import '../../shared/widgets/motion.dart';

Future<void> showAboutDialog(BuildContext context) {
  return showDialog(
    context: context,
    transitionBuilder: dialogMotion,
    transitionDuration: motionDuration,
    builder: (_) => const AboutAppDialog(),
  );
}

class AboutAppDialog extends StatelessWidget {
  const AboutAppDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ContentDialog(
      title: Text(l10n.about),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const AppLogo(size: 48),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.appName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.versionLabel(appVersion),
                      style: const TextStyle(color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(l10n.aboutDescription),
          const SizedBox(height: 8),
          const Text(appCopyright, style: TextStyle(color: AppColors.textMuted)),
        ],
      ),
      actions: [
        Button(
          onPressed: () {
            launchUrl(Uri.parse('https://ffmpeg.org/documentation.html'));
          },
          child: Text(l10n.ffmpegDocs),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.close),
        ),
      ],
    );
  }
}

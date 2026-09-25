import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../../l10n/app_localizations.dart';
import '../../shared/ui/ui.dart';

class ClipPreview extends StatelessWidget {
  const ClipPreview({
    super.key,
    required this.controller,
    required this.loading,
    required this.hasVideo,
    this.error,
  });

  final VideoController? controller;
  final bool loading;
  final bool hasVideo;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (controller != null && error == null && hasVideo)
              Video(
                controller: controller!,
                controls: NoVideoControls,
                fill: Colors.black,
              ),
            if (loading)
              _PreviewMessage(l10n.loadingPreview)
            else if (error != null)
              _PreviewMessage(l10n.cannotOpenPreview(error!))
            else if (!hasVideo)
              _PreviewMessage(l10n.clipPreviewUnavailable),
          ],
        ),
      ),
    );
  }
}

class _PreviewMessage extends StatelessWidget {
  const _PreviewMessage(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0x99000000),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: appTextStyle(color: AppColors.textMuted),
          ),
        ),
      ),
    );
  }
}

Player createClipPlayer() {
  MediaKit.ensureInitialized();
  return Player(
    configuration: const PlayerConfiguration(
      title: 'ffmpeg-ui',
      muted: false,
    ),
  );
}

Media clipMediaFromPath(String path) {
  return Media(path);
}

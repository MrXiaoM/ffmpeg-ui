import 'dart:convert';

import 'package:ffmpeg_ui/core/ffmpeg/ffmpeg_locator.dart';
import 'package:ffmpeg_ui/core/ffmpeg/ffprobe_parser.dart';
import 'package:ffmpeg_ui/core/l10n/app_messages.dart';
import 'package:ffmpeg_ui/core/l10n/labels.dart';
import 'package:ffmpeg_ui/core/models/media_info.dart';
import 'package:ffmpeg_ui/l10n/app_localizations.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses utf8 ffprobe json with chinese subtitle titles', () {
    final json = utf8.encode('''
{
  "streams": [
    {"index": 0, "codec_type": "video", "codec_name": "h264", "width": "1920", "height": "1080", "avg_frame_rate": "24000/1001"},
    {"index": 1, "codec_type": "audio", "codec_name": "aac", "channels": "2", "sample_rate": "48000"},
    {"index": 2, "codec_type": "subtitle", "codec_name": "subrip", "tags": {"language": "chi", "title": "繁體中文"}, "disposition": {"default": 1}}
  ],
  "format": {"duration": "1420.032000"}
}
''');
    final info = parseFfprobeOutput(
      path: r'H:\影片资源\spy.mkv',
      stdout: json,
    );
    expect(info.error, isNull);
    expect(info.hasVideo, isTrue);
    expect(info.hasAudio, isTrue);
    expect(info.videoCodec, 'h264');
    expect(info.width, 1920);
    expect(info.height, 1080);
    expect(info.channels, 2);
    expect(info.sampleRate, 48000);
    expect(info.subtitles, hasLength(1));
    expect(info.subtitles.single.title, '繁體中文');
    expect(info.subtitles.single.isText, isTrue);
  });

  test('keeps json even when ffprobe exits with a stream warning', () {
    final info = parseFfprobeOutput(
      path: r'C:\in\a.mkv',
      exitCode: 1,
      stderr: 'Could not find codec parameters for stream 2',
      stdout: '''
{
  "streams": [
    {"index": 0, "codec_type": "video", "codec_name": "h264", "width": 1280, "height": 720}
  ],
  "format": {"duration": "10"}
}
''',
    );
    expect(info.error, isNull);
    expect(info.hasVideo, isTrue);
    expect(info.width, 1280);
  });

  test('prefers a real video stream over an attached cover', () {
    final info = parseFfprobeJson(r'C:\in\a.mkv', '''
{
  "streams": [
    {"index": 0, "codec_type": "video", "codec_name": "mjpeg", "width": 600, "height": 600, "disposition": {"attached_pic": 1}},
    {"index": 1, "codec_type": "video", "codec_name": "h264", "width": 1920, "height": 1080}
  ]
}
''');
    expect(info.hasVideo, isTrue);
    expect(info.videoCodec, 'h264');
    expect(info.width, 1920);
  });

  test('subtitle probe error keeps the real probe failure', () {
    final l10n = lookupAppLocalizations(const Locale('zh', 'CN'));
    expect(
      subtitleProbeError(
        l10n,
        MediaInfo(
          path: r'C:\in\a.mkv',
          error: encodeAppMessage(AppMessage.ffprobeNotFound),
        ),
      ),
      l10n.errorFfprobeNotFound,
    );
    expect(
      subtitleProbeError(
        l10n,
        const MediaInfo(path: r'C:\in\a.mkv', hasAudio: true),
      ),
      l10n.subtitleNoVideo,
    );
    expect(
      subtitleProbeError(
        l10n,
        const MediaInfo(path: r'C:\in\a.mkv', hasVideo: true),
      ),
      '',
    );
  });

  test('ffprobe lookup falls back to PATH when it is not next to ffmpeg', () {
    final resolved = resolveFfprobePath(
      ffmpegPath: r'C:\tools\ffmpeg.exe',
      ffprobeName: 'ffprobe.exe',
      pathEnv: r'C:\windows;C:\ffmpeg\bin',
      pathSeparator: ';',
      exists: (path) => path == r'C:\ffmpeg\bin\ffprobe.exe',
      absolutePath: (path) => path,
    );
    expect(resolved, r'C:\ffmpeg\bin\ffprobe.exe');
  });
}

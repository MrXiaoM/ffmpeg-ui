import 'dart:convert';
import 'dart:io';

import '../l10n/app_messages.dart';

enum HardwareVendor { nvidia, amd, intel, apple, vaapi }

enum HardwareProbeStatus { unknown, available, unavailable }

class HardwareEncoderStatus {
  const HardwareEncoderStatus({
    required this.vendor,
    required this.status,
    this.detail = '',
  });

  final HardwareVendor vendor;
  final HardwareProbeStatus status;
  final String detail;

  bool get isAvailable => status == HardwareProbeStatus.available;

  String get label => switch (vendor) {
    HardwareVendor.nvidia => 'NVIDIA',
    HardwareVendor.amd => 'AMD',
    HardwareVendor.intel => 'Intel',
    HardwareVendor.apple => 'Apple',
    HardwareVendor.vaapi => 'VAAPI',
  };
}

class HardwareCapabilities {
  const HardwareCapabilities({
    required this.nvidia,
    required this.amd,
    required this.intel,
    required this.apple,
    required this.vaapi,
  });

  const HardwareCapabilities.unknown()
    : nvidia = const HardwareEncoderStatus(
        vendor: HardwareVendor.nvidia,
        status: HardwareProbeStatus.unknown,
      ),
      amd = const HardwareEncoderStatus(
        vendor: HardwareVendor.amd,
        status: HardwareProbeStatus.unknown,
      ),
      intel = const HardwareEncoderStatus(
        vendor: HardwareVendor.intel,
        status: HardwareProbeStatus.unknown,
      ),
      apple = const HardwareEncoderStatus(
        vendor: HardwareVendor.apple,
        status: HardwareProbeStatus.unknown,
      ),
      vaapi = const HardwareEncoderStatus(
        vendor: HardwareVendor.vaapi,
        status: HardwareProbeStatus.unknown,
      );

  final HardwareEncoderStatus nvidia;
  final HardwareEncoderStatus amd;
  final HardwareEncoderStatus intel;
  final HardwareEncoderStatus apple;
  final HardwareEncoderStatus vaapi;

  bool get anyAvailable => all.any((item) => item.isAvailable);

  bool get isProbed =>
      all.every((item) => item.status != HardwareProbeStatus.unknown);

  HardwareVendor? get preferredVendor {
    for (final item in all) {
      if (item.isAvailable) {
        return item.vendor;
      }
    }
    return null;
  }

  List<HardwareEncoderStatus> get all => [nvidia, apple, vaapi, intel, amd];

  HardwareEncoderStatus forVendor(HardwareVendor vendor) {
    return switch (vendor) {
      HardwareVendor.nvidia => nvidia,
      HardwareVendor.amd => amd,
      HardwareVendor.intel => intel,
      HardwareVendor.apple => apple,
      HardwareVendor.vaapi => vaapi,
    };
  }
}

class HardwareProbe {
  const HardwareProbe();

  Future<HardwareCapabilities> detect(String ffmpegPath) async {
    if (ffmpegPath.trim().isEmpty) {
      return const HardwareCapabilities.unknown();
    }
    final compiled = await _compiledEncoders(ffmpegPath);
    final results = await Future.wait([
      _probeVendor(
        ffmpegPath,
        HardwareVendor.nvidia,
        compiled.contains('h264_nvenc'),
        const [
          '-f',
          'lavfi',
          '-i',
          'color=c=black:s=256x256:d=0.1:r=30',
          '-frames:v',
          '1',
          '-an',
          '-c:v',
          'h264_nvenc',
          '-f',
          'null',
          '-',
        ],
      ),
      _probeVendor(
        ffmpegPath,
        HardwareVendor.amd,
        compiled.contains('h264_amf'),
        const [
          '-f',
          'lavfi',
          '-i',
          'color=c=black:s=256x256:d=0.1:r=30',
          '-frames:v',
          '1',
          '-an',
          '-c:v',
          'h264_amf',
          '-f',
          'null',
          '-',
        ],
      ),
      _probeVendor(
        ffmpegPath,
        HardwareVendor.intel,
        compiled.contains('h264_qsv'),
        const [
          '-f',
          'lavfi',
          '-i',
          'color=c=black:s=256x256:d=0.1:r=30',
          '-frames:v',
          '1',
          '-an',
          '-c:v',
          'h264_qsv',
          '-f',
          'null',
          '-',
        ],
      ),
      _probeVendor(
        ffmpegPath,
        HardwareVendor.apple,
        compiled.contains('h264_videotoolbox'),
        const [
          '-f',
          'lavfi',
          '-i',
          'color=c=black:s=256x256:d=0.1:r=30',
          '-frames:v',
          '1',
          '-an',
          '-c:v',
          'h264_videotoolbox',
          '-f',
          'null',
          '-',
        ],
      ),
      _probeVendor(
        ffmpegPath,
        HardwareVendor.vaapi,
        compiled.contains('h264_vaapi'),
        const [
          '-init_hw_device',
          'vaapi=va:/dev/dri/renderD128',
          '-filter_hw_device',
          'va',
          '-f',
          'lavfi',
          '-i',
          'color=c=black:s=256x256:d=0.1:r=30',
          '-frames:v',
          '1',
          '-an',
          '-vf',
          'format=nv12,hwupload',
          '-c:v',
          'h264_vaapi',
          '-f',
          'null',
          '-',
        ],
      ),
    ]);
    return HardwareCapabilities(
      nvidia: results[0],
      amd: results[1],
      intel: results[2],
      apple: results[3],
      vaapi: results[4],
    );
  }

  Future<Set<String>> _compiledEncoders(String ffmpegPath) async {
    try {
      final result = await Process.run(ffmpegPath, const [
        '-hide_banner',
        '-encoders',
      ], runInShell: false);
      final output = '${result.stdout}\n${result.stderr}';
      return LineSplitter.split(output)
          .map((line) => line.trim())
          .where((line) => line.isNotEmpty)
          .map((line) => line.split(RegExp(r'\s+')).elementAtOrNull(1) ?? '')
          .where((name) => name.isNotEmpty)
          .toSet();
    } catch (_) {
      return const {};
    }
  }

  Future<HardwareEncoderStatus> _probeVendor(
    String ffmpegPath,
    HardwareVendor vendor,
    bool compiled,
    List<String> arguments,
  ) async {
    if (!vendorSupportedOnPlatform(vendor)) {
      return HardwareEncoderStatus(
        vendor: vendor,
        status: HardwareProbeStatus.unavailable,
        detail: encodeAppMessage(AppMessage.encoderUnsupported, [
          _vendorLabel(vendor),
        ]),
      );
    }
    if (!compiled) {
      return HardwareEncoderStatus(
        vendor: vendor,
        status: HardwareProbeStatus.unavailable,
        detail: encodeAppMessage(AppMessage.encoderNotCompiled, [
          _vendorLabel(vendor),
        ]),
      );
    }
    try {
      final result = await Process.run(ffmpegPath, [
        '-hide_banner',
        '-nostats',
        ...arguments,
      ], runInShell: false);
      if (result.exitCode == 0) {
        return HardwareEncoderStatus(
          vendor: vendor,
          status: HardwareProbeStatus.available,
          detail: encodeAppMessage(AppMessage.encoderCanInit, [
            _vendorLabel(vendor),
          ]),
        );
      }
      return HardwareEncoderStatus(
        vendor: vendor,
        status: HardwareProbeStatus.unavailable,
        detail: _compactError('${result.stderr}\n${result.stdout}'),
      );
    } catch (error) {
      return HardwareEncoderStatus(
        vendor: vendor,
        status: HardwareProbeStatus.unavailable,
        detail: encodeAppMessage(AppMessage.encoderCheckFailed, [
          _vendorLabel(vendor),
          '$error',
        ]),
      );
    }
  }

  String _vendorLabel(HardwareVendor vendor) {
    return switch (vendor) {
      HardwareVendor.nvidia => 'NVIDIA',
      HardwareVendor.amd => 'AMD',
      HardwareVendor.intel => 'Intel',
      HardwareVendor.apple => 'Apple',
      HardwareVendor.vaapi => 'VAAPI',
    };
  }

  String _compactError(String raw) {
    final lines = LineSplitter.split(raw)
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .where((line) => !line.startsWith('Input #'))
        .where((line) => !line.startsWith('Duration:'))
        .where((line) => !line.startsWith('Stream #'))
        .toList(growable: false);
    if (lines.isEmpty) {
      return encodeAppMessage(AppMessage.encoderInitFailed);
    }
    final message = lines.last;
    return message.length > 180 ? '${message.substring(0, 180)}…' : message;
  }
}

bool vendorSupportedOnPlatform(HardwareVendor vendor) {
  switch (vendor) {
    case HardwareVendor.nvidia:
      return Platform.isWindows || Platform.isLinux;
    case HardwareVendor.amd:
      return Platform.isWindows;
    case HardwareVendor.intel:
      return Platform.isWindows || Platform.isLinux;
    case HardwareVendor.apple:
      return Platform.isMacOS;
    case HardwareVendor.vaapi:
      return Platform.isLinux;
  }
}

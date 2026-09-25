import 'package:package_info_plus/package_info_plus.dart';

const appCopyright = '© 2026 MrXiaoM';

String appVersion = '0.0.0';

Future<void> loadAppInfo() async {
  final info = await PackageInfo.fromPlatform();
  appVersion = info.version;
}

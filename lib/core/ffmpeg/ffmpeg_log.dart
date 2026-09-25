String compactFfmpegLog(String line, {int maxLength = 200}) {
  final compact = line.replaceAll(RegExp(r'\s+'), ' ').trim();
  if (compact.length <= maxLength) {
    return compact;
  }
  final limit = maxLength < 1 ? 0 : maxLength - 1;
  return '${compact.substring(0, limit)}…';
}

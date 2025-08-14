// lib/utils/image_helper.dart
class ImageHelper {
  // Android emulator: http://10.0.2.2:3000
  // iOS simulator:    http://127.0.0.1:3000
  static const String _apiBase = "http://192.168.1.6:3000";

  static bool _isHttp(String s) =>
      s.startsWith('http://') || s.startsWith('https://');

  static bool _looksValidAbsolute(String s) {
    final u = Uri.tryParse(s);
    return u != null && u.hasScheme && u.host.isNotEmpty;
  }

  static String getFullUrl(String? path) {
    final raw = (path ?? '').trim();
    // reject junk that often sneaks in
    if (raw.isEmpty ||
        raw == '#' ||
        raw.toLowerCase() == 'null' ||
        raw.toLowerCase() == 'undefined' ||
        raw.startsWith('file://') ||
        raw.startsWith('about:') ||
        raw.startsWith('data:')) {
      return '';
    }

    if (_isHttp(raw)) return _looksValidAbsolute(raw) ? raw : '';

    final joined = '$_apiBase/${raw.replaceFirst(RegExp(r'^/'), '')}';
    return _looksValidAbsolute(joined) ? joined : '';
  }
}

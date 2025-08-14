// lib/model/ground_model.dart
class Ground {
  final String id;
  final String title;        // backend: name
  final String subtitle;     // backend: city
  final int price;           // backend me optional; default 0
  final double rating;       // backend: rating
  final List<String> images; // resolved absolute URLs
  final bool recommended;    // backend: recommended
  final double? lat;         // backend: coordinates.lat
  final double? lng;         // backend: coordinates.lng
  final String? description; // backend: description

  Ground(
      this.title,
      this.subtitle,
      this.price,
      this.rating,
      this.images, {
        this.recommended = false,
        required this.lat,
        required this.lng,
        this.description,
        this.id = '',
      });

  /// Helper: pick first image as cover (nullable)
  String? get coverUrl => images.isNotEmpty ? images.first : null;

  /// Normalize to absolute URL (prefix baseUrl if relative)
  static String _resolveUrl(String raw, String? baseUrl) {
    if (raw.isEmpty) return raw;
    final lower = raw.toLowerCase().trim();
    final isAbs = lower.startsWith('http://') || lower.startsWith('https://');
    if (isAbs) return raw;
    if (baseUrl == null || baseUrl.isEmpty) return raw;
    // ensure single slash join
    final left = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    final right = raw.startsWith('/') ? raw.substring(1) : raw;
    return '$left/$right';
  }

  /// Collect images from multiple possible keys
  static List<String> _extractImages(Map<String, dynamic> json, String? baseUrl) {
    final List<String> out = [];

    // common keys
    void addIfString(dynamic v) {
      if (v is String && v.trim().isNotEmpty) {
        out.add(_resolveUrl(v, baseUrl));
      }
    }

    void addList(dynamic v) {
      if (v is List) {
        for (final e in v) {
          if (e is String && e.trim().isNotEmpty) {
            out.add(_resolveUrl(e, baseUrl));
          } else if (e is Map && e['url'] is String) {
            out.add(_resolveUrl(e['url'], baseUrl));
          }
        }
      }
    }

    // try arrays first
    addList(json['images']);
    addList(json['photos']);
    addList(json['gallery']);

    // try single string fields
    addIfString(json['image']);
    addIfString(json['cover']);
    addIfString(json['coverImage']);
    addIfString(json['thumbnail']);

    // remove duplicates
    final seen = <String>{};
    return out.where((u) => seen.add(u)).toList();
  }

  static double? _toD(dynamic v) => (v is int) ? v.toDouble() : (v as num?)?.toDouble();

  factory Ground.fromJson(Map<String, dynamic> json, {String? baseUrl}) {
    final coords = (json['coordinates'] as Map<String, dynamic>?) ?? {};
    final images = _extractImages(json, baseUrl);

    return Ground(
      (json['name'] ?? '').toString(),     // title
      (json['city'] ?? '').toString(),     // subtitle
      (json['price'] is num) ? (json['price'] as num).toInt() : 0,
      _toD(json['rating']) ?? 0.0,
      images,
      recommended: json['recommended'] == true,
      lat: _toD(coords['lat']),
      lng: _toD(coords['lng']),
      description: (json['description'] as String?)?.toString(),
    ).copyWithId((json['_id'] ?? json['id'] ?? '').toString());
  }

  Ground copyWithId(String id) => Ground(
    title,
    subtitle,
    price,
    rating,
    images,
    recommended: recommended,
    lat: lat,
    lng: lng,
    description: description,
    id: id,
  );
}

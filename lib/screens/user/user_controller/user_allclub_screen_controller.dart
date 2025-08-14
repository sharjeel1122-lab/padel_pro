import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:padel_pro/services/current%20location/permission_get_location.dart';
import 'package:padel_pro/services/user%20role%20api%20service/user_fetch_allclubs_api.dart';

class UserClubScreenController extends GetxController {
  final searchController = TextEditingController();

  // ---- CONFIG: set these to your API/CDN base ----
  // Example:
  // const String BASE_URL = 'https://api.padelpro.pk'; // <-- CHANGE THIS
  // If your API returns "/uploads/xyz.jpg", final URL becomes "https://api.padelpro.pk/uploads/xyz.jpg"
  static const String BASE_URL = 'https://your-backend.example.com'; // TODO set correctly

  // Optional: if backend gives just an id and you need to hit /files/:id
  // static const String FILE_ENDPOINT_PREFIX = '$BASE_URL/files/';

  // Optional: if images need auth headers (Bearer token), put it here.
  Map<String, String> get imageHeaders => const {
    // 'Authorization': 'Bearer YOUR_TOKEN',
  };

  // Filters state
  final priceRange = const RangeValues(10, 30).obs;
  final selectedTypes = <String>[].obs;
  final selectedFacilities = <String>[].obs;

  // Location filter (chips)
  final RxString locationFilter = 'All'.obs;
  final List<String> knownLocations = const ['All', 'DHA', 'Model Town', 'Bahria Town'];

  // Reactive search query (used by Obx in search bar)
  final RxString searchQuery = ''.obs;

  // UI + data
  final selectedCategory = 0.obs; // kept for compatibility
  final isLoading = false.obs;
  final playgrounds = <Map<String, dynamic>>[].obs;         // raw from API
  final filteredPlaygrounds = <Map<String, dynamic>>[].obs; // result after filters

  var clubs = <Map<String, dynamic>>[].obs;

  final UserFetchAllClubsApi api = UserFetchAllClubsApi();
  final GetLocationPermission permission = GetLocationPermission();

  @override
  void onInit() {
    super.onInit();
    fetchPlaygrounds();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  Future<void> fetchPlaygrounds() async {
    try {
      isLoading.value = true;

      final rawData = await api.fetchAllPlaygrounds();
      playgrounds.value = List<Map<String, dynamic>>.from(rawData);
      clubs.value = playgrounds;

      _applyAllFilters(); // seed filtered list
    } catch (e) {
      // ignore: avoid_print
      print('User fetch error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  String getPlaygroundPrice(Map<String, dynamic> playground) {
    final courts = playground['courts'] as List<dynamic>?;

    if (courts == null || courts.isEmpty) return '2000'; // Default fallback

    double totalPrice = 0;

    for (var court in courts) {
      final pricing = court['pricing'] as List<dynamic>?;

      if (pricing != null && pricing.isNotEmpty) {
        pricing.sort((a, b) => (a['duration'] as int).compareTo(b['duration'] as int));
        final minPrice = pricing.first['price'];
        totalPrice += (minPrice is num) ? minPrice.toDouble() : 0;
      }
    }

    return totalPrice.toStringAsFixed(0);
  }

  // With distance
  Future<void> fetchPlaygroundsWithDistance() async {
    try {
      isLoading.value = true;

      final userPosition = await permission.getCurrentPosition();
      final rawData = await api.fetchAllPlaygrounds();

      List<Map<String, dynamic>> updatedPlaygrounds = [];

      for (var pg in rawData) {
        final lat = (pg['latitude'] ?? 0.0).toDouble();
        final lon = (pg['longitude'] ?? 0.0).toDouble();

        final meters = Geolocator.distanceBetween(
          userPosition.latitude,
          userPosition.longitude,
          lat,
          lon,
        );
        pg['distance'] = '${(meters / 1000).toStringAsFixed(1)} km';

        updatedPlaygrounds.add(Map<String, dynamic>.from(pg));
      }

      playgrounds.value = updatedPlaygrounds;
      clubs.value = updatedPlaygrounds;
      _applyAllFilters();
    } catch (e) {
      // ignore: avoid_print
      print('Distance error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ---------- Filters & Search ----------

  void searchPlaygrounds(String query) {
    searchQuery.value = query; // reactive value drives the Obx in search bar
    _applyAllFilters();
  }

  void setLocationFilter(String value) {
    locationFilter.value = value;
    _applyAllFilters();
  }

  void applyFilters() {
    _applyAllFilters();
  }

  void resetFilters() {
    priceRange.value = const RangeValues(10, 30);
    selectedTypes.clear();
    selectedFacilities.clear();
    selectedCategory.value = 0;
    searchController.clear();
    searchQuery.value = '';
    locationFilter.value = 'All';
    _applyAllFilters();
  }

  // Combine location + search + price
  void _applyAllFilters() {
    final q = searchQuery.value.trim().toLowerCase();
    final loc = locationFilter.value.toLowerCase();

    List<Map<String, dynamic>> list = List<Map<String, dynamic>>.from(playgrounds);

    // Location filter
    if (loc != 'all') {
      list = list.where((p) {
        final l = (p['location'] ?? '').toString().toLowerCase();
        return l.contains(loc);
      }).toList();
    }

    // Search filter
    if (q.isNotEmpty) {
      list = list.where((p) {
        final name = (p['name'] ?? '').toString().toLowerCase();
        final locVal = (p['location'] ?? '').toString().toLowerCase();
        return name.contains(q) || locVal.contains(q);
      }).toList();
    }

    // Price filter (using minPrice when available)
    list = list.where((p) {
      final dynamic raw = p['minPrice'];
      final price = raw is num ? raw.toDouble() : null;
      if (price == null) return true; // don't exclude if missing
      return price >= priceRange.value.start && price <= priceRange.value.end;
    }).toList();

    filteredPlaygrounds.assignAll(list);
  }

  // ---------- IMAGE HELPERS ----------

  /// Public: safely resolve the best image URL for a playground
  String? imageUrlFor(Map<String, dynamic> pg) {
    final raw = _extractFirstImage(pg);
    if (raw == null || raw.trim().isEmpty) return null;
    return _normalizeToAbsoluteUrl(raw.trim());
  }

  /// Find plausible image from multiple shapes: string / list / nested maps
  String? _extractFirstImage(Map<String, dynamic> pg) {
    // Common direct keys
    final candidateKeys = [
      'image', 'imageUrl', 'photo', 'thumbnail', 'cover', 'logo',
    ];

    for (final k in candidateKeys) {
      final v = pg[k];
      if (v is String && v.trim().isNotEmpty) return v;
      if (v is Map && (v['url'] is String)) return v['url'];
    }

    // Arrays
    final listKeys = ['photos', 'images', 'gallery'];
    for (final k in listKeys) {
      final v = pg[k];
      if (v is List && v.isNotEmpty) {
        // string list
        final s = v.firstWhere(
              (e) => e is String && e.toString().trim().isNotEmpty,
          orElse: () => null,
        );
        if (s is String) return s;
        // map list with url
        final m = v.firstWhere(
              (e) => e is Map && (e['url'] is String && (e['url'] as String).trim().isNotEmpty),
          orElse: () => null,
        );
        if (m is Map) return m['url'];
      }
    }

    // inside first court
    final courts = pg['courts'];
    if (courts is List && courts.isNotEmpty) {
      final c0 = courts.first;
      if (c0 is Map) {
        // direct keys inside court
        for (final k in candidateKeys) {
          final v = c0[k];
          if (v is String && v.trim().isNotEmpty) return v;
          if (v is Map && (v['url'] is String)) return v['url'];
        }
        // arrays inside court
        for (final k in listKeys) {
          final v = c0[k];
          if (v is List && v.isNotEmpty) {
            final s = v.firstWhere(
                  (e) => e is String && e.toString().trim().isNotEmpty,
              orElse: () => null,
            );
            if (s is String) return s;
            final m = v.firstWhere(
                  (e) => e is Map && (e['url'] is String && (e['url'] as String).trim().isNotEmpty),
              orElse: () => null,
            );
            if (m is Map) return m['url'];
          }
        }
      }
    }

    // nothing found
    return null;
  }

  /// Normalize relative / protocol-relative / backslash paths to absolute URL
  String _normalizeToAbsoluteUrl(String raw) {
    String u = raw.replaceAll('\\', '/'); // windows path => URL-ish

    // data URL or already absolute
    final parsed = Uri.tryParse(u);
    if (u.startsWith('data:image')) return u;
    if (parsed != null && parsed.hasScheme) return u;

    // protocol-relative: //host/path
    if (u.startsWith('//')) return 'https:$u';

    // relative: /path or path
    if (u.startsWith('/')) return _joinUrl(BASE_URL, u);
    return _joinUrl(BASE_URL, '/$u');
  }

  String _joinUrl(String base, String path) {
    final b = base.endsWith('/') ? base.substring(0, base.length - 1) : base;
    final p = path.startsWith('/') ? path.substring(1) : path;
    return '$b/$p';
  }

  // ---------- Favorites ----------

  void toggleFavorite(String id) {
    int index = playgrounds.indexWhere(
          (p) => (p['_id']?.toString() ?? p['id']?.toString()) == id,
    );
    if (index != -1) {
      final current = playgrounds[index]['isFavorite'] ?? false;
      playgrounds[index]['isFavorite'] = !current;
      playgrounds.refresh();

      final fIndex = filteredPlaygrounds.indexWhere(
            (p) => (p['_id']?.toString() ?? p['id']?.toString()) == id,
      );
      if (fIndex != -1) {
        filteredPlaygrounds[fIndex]['isFavorite'] = !current;
        filteredPlaygrounds.refresh();
      }
    }
  }
}

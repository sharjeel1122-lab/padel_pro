import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:padel_pro/services/current%20location/permission_get_location.dart';
import 'package:padel_pro/services/user%20role%20api%20service/user_fetch_allclubs_api.dart';


class UserClubScreenController extends GetxController {
  final searchController = TextEditingController();
  final priceRange = RangeValues(10, 30).obs;
  final selectedTypes = <String>[].obs;
  final selectedFacilities = <String>[].obs;
  final selectedCategory = 0.obs;
  final isLoading = false.obs;
  final playgrounds = <Map<String, dynamic>>[].obs;
  final filteredPlaygrounds = <Map<String, dynamic>>[].obs;


  var clubs = <Map<String, dynamic>>[].obs;

  final UserFetchAllClubsApi api = UserFetchAllClubsApi();
  final GetLocationPermission permission = GetLocationPermission();

  @override
  void onInit() {
    super.onInit();
    fetchPlaygrounds();
  }

  void fetchPlaygrounds() async {
    try {
      isLoading.value = true;

      // ⛳ use correct user API service
      final rawData = await api.fetchAllPlaygrounds();

      // ✅ Already returning `data` list, so no need to access rawData['data'] again
      playgrounds.value = List<Map<String, dynamic>>.from(rawData);
      clubs.value = playgrounds;

    } catch (e) {
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
        totalPrice += (minPrice is int || minPrice is double) ? minPrice.toDouble() : 0;
      }
    }

    return totalPrice.toStringAsFixed(0);
  }

  // distance calculate

  Future<void> fetchPlaygroundsWithDistance() async {
    try {
      isLoading.value = true;

      final userPosition = await permission.getCurrentPosition();
      final rawData = await api.fetchAllPlaygrounds();

      List<Map<String, dynamic>> updatedPlaygrounds = [];

      for (var pg in rawData) {
        double lat = pg['latitude'] ?? 0.0;
        double lon = pg['longitude'] ?? 0.0;

        double distanceInMeters = Geolocator.distanceBetween(
          userPosition.latitude,
          userPosition.longitude,
          lat,
          lon,
        );

        double distanceInKm = distanceInMeters / 1000;
        pg['distance'] = '${distanceInKm.toStringAsFixed(1)} km';

        updatedPlaygrounds.add(Map<String, dynamic>.from(pg));
      }

      playgrounds.value = updatedPlaygrounds;
      clubs.value = updatedPlaygrounds;
      // filteredClubs.assignAll(updatedPlaygrounds);
    } catch (e) {
      print('Distance error: $e');
    } finally {
      isLoading.value = false;
    }
  }








  void searchPlaygrounds(String query) {
    if (query.isEmpty) {
      filteredPlaygrounds.assignAll(playgrounds);
      return;
    }

    final lowerQuery = query.toLowerCase();
    filteredPlaygrounds.assignAll(playgrounds.where((p) {
      return (p['name'] ?? '').toLowerCase().contains(lowerQuery) ||
          (p['location'] ?? '').toLowerCase().contains(lowerQuery);
    }).toList());
  }

  void filterByCategory(String category) {
    if (category == 'All') {
      filteredPlaygrounds.assignAll(playgrounds);
      return;
    }

    filteredPlaygrounds.assignAll(playgrounds.where((p) {
      return (p['name'] ?? '').toLowerCase().contains(category.toLowerCase());
    }).toList());
  }

  void toggleFavorite(String id) {
    final index = playgrounds.indexWhere((p) => p['_id'] == id); // Use '_id' from MongoDB
    if (index != -1) {
      playgrounds[index]['isFavorite'] = !(playgrounds[index]['isFavorite'] ?? false);
      playgrounds.refresh();

      final filteredIndex = filteredPlaygrounds.indexWhere((p) => p['_id'] == id);
      if (filteredIndex != -1) {
        filteredPlaygrounds[filteredIndex]['isFavorite'] = playgrounds[index]['isFavorite'];
        filteredPlaygrounds.refresh();
      }
    }
  }

  void applyFilters() {
    filteredPlaygrounds.assignAll(playgrounds.where((p) {
      final price = (p['minPrice'] ?? 0).toDouble();
      return price >= priceRange.value.start && price <= priceRange.value.end;
    }).toList());
  }

  void resetFilters() {
    priceRange.value = const RangeValues(10, 30);
    selectedTypes.clear();
    selectedFacilities.clear();
    selectedCategory.value = 0;
    filteredPlaygrounds.assignAll(playgrounds);
  }
}

// ignore_for_file: deprecated_member_use

import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import '../model/ground_model.dart';

class GroundController extends GetxController {
  final popularGrounds = <Ground>[].obs;
  final searchText = ''.obs;
  final userPosition = Rxn<Position>();

  // Computed: Filtered + Sorted list
  List<Ground> get filteredGrounds {
    final search = searchText.value.toLowerCase();

    // Filter by search text
    var list = popularGrounds.where((g) {
      return g.title.toLowerCase().contains(search) || g.subtitle.toLowerCase().contains(search);
    }).toList();

    double calculateDistance(double lat, double lng) {
      return Geolocator.distanceBetween(
        userPosition.value!.latitude,
        userPosition.value!.longitude,
        lat,
        lng,
      );
    }


    // Sort by distance if location is available
    if (userPosition.value != null) {
      list.sort((a, b) {
        final distA = calculateDistance(a.lat, a.lng);
        final distB = calculateDistance(b.lat, b.lng);
        return distA.compareTo(distB);
      });
    }

    return list;
  }

  @override
  void onInit() {
    fetchGrounds();
    _getUserLocation();
    super.onInit();
  }

  void fetchGrounds() {
    popularGrounds.assignAll([
      Ground('City Stadium', 'Lahore', 3000, 4.5, ['assets/court1.jpg','assets/court3.jpg', 'assets/court2.jpg'],
          recommended: true, lat: 24.8607, lng: 67.0011),
      Ground('Green Field', 'Karachi', 2500, 4.2, ['assets/court1.jpg','assets/court3.jpg', 'assets/court2.jpg'],
          recommended: false, lat: 24.8700, lng: 67.0300),
      Ground('Pro Arena', 'Multan', 3500, 4.8, ['assets/court1.jpg','assets/court3.jpg', 'assets/court2.jpg'],
          recommended: true, lat: 24.8500, lng: 66.9900),
      Ground('Old Town Field', 'Faiz Road', 2000, 3.9, ['assets/court1.jpg','assets/court3.jpg', 'assets/court2.jpg'],
          recommended: false, lat: 24.8450, lng: 66.9850),
      Ground('City Stadium', 'Model Town', 3000, 4.5, ['assets/court1.jpg','assets/court3.jpg', 'assets/court2.jpg'],
          recommended: true, lat: 24.8650, lng: 67.0050),
    ]);
  }

  Future<void> _getUserLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) return;

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }
    }

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    userPosition.value = position;
  }

  void updateSearch(String value) {
    searchText.value = value;
  }
}

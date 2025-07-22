import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart'; // ✅ Add this

class UserController extends GetxController {
  var username = 'Asad Ali'.obs;
  var location = 'Fetching location...'.obs;
  var isSearching = false.obs;
  var searchText = ''.obs;

  @override
  void onInit() {
    getLocation();
    super.onInit();
  }

  void toggleSearch() {
    isSearching.value = !isSearching.value;
  }

  void updateSearchText(String text) {
    searchText.value = text;
  }

  Future<void> getLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        location.value = "Location services are disabled";
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          location.value = "Location permission denied";
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        location.value = "Location permission permanently denied";
        return;
      }

      // ✅ Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // ✅ Reverse geocode
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        location.value =
        "${place.locality ?? ''}, ${place.administrativeArea ?? ''}, ${place.country ?? ''}";
      } else {
        location.value = "Address not found";
      }
    } catch (e) {
      location.value = "Location unavailable";
      print("Location error: $e");
    }
  }

}

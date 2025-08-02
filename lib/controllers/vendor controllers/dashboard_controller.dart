import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:padel_pro/screens/vendor/views/create_playground_view.dart';
import 'package:padel_pro/services/vendors%20api/fetch_club_courts_api.dart';

class VendorDashboardController extends GetxController {
  final FetchVendorApi _fetchVendorApi = FetchVendorApi();
  final RxList<Map<String, dynamic>> playgrounds = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;
  var filteredClubs = <Map<String, dynamic>>[].obs;
  final TextEditingController searchController = TextEditingController();


  var clubs = <Map<String, dynamic>>[].obs;


  @override
  void onInit() {
    super.onInit();
    fetchPlaygrounds();
    searchController.addListener(onSearchChanged);

  }

  void fetchPlaygrounds() async {
    try {
      isLoading.value = true;
      final data = await _fetchVendorApi.getVendorPlaygrounds();
      playgrounds.value = List<Map<String, dynamic>>.from(data);
      clubs.value = playgrounds;
      filteredClubs.assignAll(clubs);
    } catch (e) {
      print('Error: $e');
    } finally {
      isLoading.value = false;
    }
  }


  void onSearchChanged() {
    final query = searchController.text.toLowerCase();

    if (query.isEmpty) {
      filteredClubs.assignAll(clubs);
    } else {
      filteredClubs.assignAll(
        clubs.where((club) {
          final name = (club['name'] ?? '').toString().toLowerCase();
          final location = (club['location'] ?? '').toString().toLowerCase();
          return name.contains(query) || location.contains(query);
        }).toList(),
      );
    }
  }




  // void fetchClubs() async {
  //   try {
  //     isLoading.value = true;
  //
  //     final data = await _fetchVendorApi.getVendorPlaygrounds();
  //
  //     clubs.value = data.map<Map<String, dynamic>>((club) {
  //       return {
  //         'id': club['_id']?['\$oid'] ?? '',
  //         'name': club['name'] ?? 'Unnamed',
  //         'location': club['location'] ?? 'Unknown',
  //         'city': club['city'] ?? 'Unknown City',
  //         'courtsCount': (club['courts'] as List<dynamic>?)?.length ?? 0,
  //         'photos': (club['photos'] as List<dynamic>?)?.cast<String>() ?? [],
  //         'phoneNumber': club['phoneNumber'] ?? '',
  //         'website': club['website'] ?? '',
  //         'description': club['description'] ?? '',
  //       };
  //     }).toList();
  //
  //     // Print fetched clubs list
  //     print('Fetched Clubs:');
  //     for (var club in clubs) {
  //       print(club);
  //     }
  //
  //   } catch (e) {
  //     print("Error fetching clubs: $e");
  //   } finally {
  //     isLoading.value = false;
  //   }
  // }



  // void fetchClubs() async {
  //   try {
  //     isLoading.value = true;
  //     final data = await _fetchVendorApi.getVendorPlaygrounds();
  //
  //     // Only pick required fields: name, location, courts
  //     clubs.value = data.map<Map<String, dynamic>>((club) {
  //       return {
  //         'name': club['name'] ?? 'Unnamed',
  //         'location': club['location'] ?? 'Unknown',
  //         'courts': (club['courts'] as List?)?.length ?? 0,
  //       };
  //     }).toList();
  //   } catch (e) {
  //     print("Error fetching clubs: $e");
  //   } finally {
  //     isLoading.value = false;
  //   }
  // }

  // void loadClubs() {
  //   clubs.value = [
  //     {
  //       'name': 'Main Gulberg Club',
  //       'location': 'Lahore',
  //       'courts': 3,
  //     },
  //     {
  //       'name': 'DHA Sports Arena',
  //       'location': 'Lahore',
  //       'courts': 1,
  //     },
  //     {
  //       'name': 'DHA Sports Arena',
  //       'location': 'Lahore',
  //       'courts': 5,
  //     },
  //
  //   ];
  // }

  void addClub() {
    Get.to(CreatePlaygroundView());
  }

  void editClub(int index) {
    // Logic to edit
  }

  void deleteClub(int index) {
   // Logic to delete
  }

  void viewCourts(int index) {
    // Navigate to courts screen
  }
}

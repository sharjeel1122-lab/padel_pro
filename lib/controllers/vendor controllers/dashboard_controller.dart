import 'package:get/get.dart';

class VendorDashboardController extends GetxController {
  var clubs = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadClubs();
  }

  void loadClubs() {
    clubs.value = [
      {
        'name': 'Main Gulberg Club',
        'location': 'Lahore',
        'courts': 3,
      },
      {
        'name': 'DHA Sports Arena',
        'location': 'Lahore',
        'courts': 1,
      },
      {
        'name': 'DHA Sports Arena',
        'location': 'Lahore',
        'courts': 5,
      },
      
    ];
  }

  void addClub() {
    // Logic to add club
  }

  void editClub(int index) {
    // Logic to edit
  }

  void deleteClub(int index) {
    clubs.removeAt(index);
  }

  void viewCourts(int index) {
    // Navigate to courts screen
  }
}

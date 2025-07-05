import 'package:get/get.dart';

import '../model/ground_model.dart';

class GroundController extends GetxController {
  final popularGrounds = <Ground>[].obs;

  @override
  void onInit() {
    fetchGrounds();
    super.onInit();
  }

  void fetchGrounds() {
    popularGrounds.assignAll([
      Ground('City Stadium', 'Downtown', 3000, 4.5, 'assets/court1.jpg', recommended: true),
      Ground('Green Field', 'East Side', 2500, 4.2, 'assets/green.png'),
      Ground('Pro Arena', 'North Block', 3500, 4.8, 'assets/court2.jpg', recommended: true),
      Ground('Old Town Field', 'West End', 2000, 3.9, 'assets/oldtown.png', recommended: false),
      Ground('City Stadium', 'Downtown', 3000, 4.5, 'assets/court1.jpg', recommended: true),

    ]);
  }
}

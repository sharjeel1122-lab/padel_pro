// lib/screens/admin/vendors controllers/dashboard_controller.dart
import 'package:get/get.dart';

class DashboardController extends GetxController {
  var totalCourts = 1.obs;
  var vendors = 1.obs;
  var products = 10.obs;
  var requests = 1.obs;

  final courts = <CourtModel>[
    CourtModel(name: "Green Arena", date: "2024-07-10", type: "Indoor"),
  ].obs;

  void addVendor() {
    vendors.value++;
    update();
  }

  void addCourt({required String name, required String type}) {
    totalCourts.value++;
    requests.value++;
    courts.insert(
      0,
      CourtModel(name: name, date: DateTime.now().toString().split(' ')[0], type: type),
    );
    update();
  }
}

class CourtModel {
  final String name;
  final String date;
  final String type;

  CourtModel({required this.name, required this.date, required this.type});
}

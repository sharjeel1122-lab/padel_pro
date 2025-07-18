import 'package:get/get.dart';
import '../admin_models/court_model.dart';


class DashboardController extends GetxController {
  var courts = <CourtModel>[].obs;

  var totalCourts = 24.obs;
  var vendors = 10.obs;
  var products = 42.obs;
  var requests = 5.obs;

  @override
  void onInit() {
    super.onInit();
    loadStaticCourts();
  }

  void loadStaticCourts() {
    courts.value = [
      CourtModel(name: "Court A", date: "03-02-2025", type: "Clay"),
      CourtModel(name: "Court B", date: "27-02-2025", type: "Grass"),
      CourtModel(name: "Court C", date: "23-02-2025", type: "Hard"),
      CourtModel(name: "Court D", date: "23-02-2025", type: "Clay"),
      CourtModel(name: "Court E", date: "22-02-2025", type: "Synthetic"),
    ];
  }
}

import 'package:get/get.dart';

class SportController extends GetxController {
  final selectedSport = 0.obs;

  void selectSport(int index) {
    selectedSport.value = index;
  }
}

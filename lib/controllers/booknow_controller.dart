import 'package:get/get.dart';

class BookingController extends GetxController {
  final RxMap<String, List<String>> bookedData = <String, List<String>>{}.obs;

  void book(String dateKey, String slot) {
    if (!bookedData.containsKey(dateKey)) {
      bookedData[dateKey] = [];
    }
    bookedData[dateKey]!.add(slot);
    bookedData.refresh(); // 🛑 force UI update
  }

  bool isSlotBooked(String dateKey, String slot) {
    return bookedData[dateKey]?.contains(slot) ?? false;
  }
}

import 'package:get/get.dart';

class ClubPadelController extends GetxController {
  final selectedDate = DateTime.now().obs;
  final selectedCourt = 'Court 1'.obs;
  final selectedDuration = '60 Minutes'.obs;
  final rating = 4.3.obs;

  void changeDate(DateTime newDate) => selectedDate.value = newDate;
  void changeCourt(String court) => selectedCourt.value = court;
  void changeDuration(String duration) => selectedDuration.value = duration;
}
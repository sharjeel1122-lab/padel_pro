// import 'package:get/get.dart';
// import 'package:padel_pro/model/booking_model.dart';
//
// class BookingController extends GetxController {
//   RxList<BookingModel> bookings = <BookingModel>[].obs;
//   RxBool isLoading = false.obs;
//
//   @override
//   void onInit() {
//     fetchBookings();
//     super.onInit();
//   }
//
//   Future<void> fetchBookings() async {
//     isLoading.value = true;
//     try {
//       final result = await ApiService.getBookings(); // Your HTTP call to backend
//       bookings.value =
//           result.map<BookingModel>((e) => BookingModel.fromJson(e)).toList();
//     } catch (e) {
//       Get.snackbar("Error", "Failed to fetch bookings: $e");
//     } finally {
//       isLoading.value = false;
//     }
//   }
// }

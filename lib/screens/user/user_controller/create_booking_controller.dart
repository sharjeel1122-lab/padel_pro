// import 'package:get/get.dart';
// import 'package:padel_pro/services/user%20role%20api%20service/create_booking_user.dart';
//
//
// class BookingController extends GetxController {
//   final BookingApi _api = BookingApi();
//
//   var isLoading = false.obs;
//   var errorMessage = ''.obs;
//
//   Future<bool> bookCourt({
//     required String playgroundId,
//     required String courtNumber,
//     required String date,
//     required String startTime,
//     required int duration,
//   }) async {
//     isLoading.value = true;
//     errorMessage.value = '';
//
//     final result = await _api.createBooking(
//       playgroundId: playgroundId,
//       courtNumber: courtNumber,
//       date: date,
//       startTime: startTime,
//       duration: duration,
//     );
//
//     isLoading.value = false;
//
//     if (result['success']) {
//       return true;
//     } else {
//       errorMessage.value = result['message'];
//       return false;
//     }
//   }
// }

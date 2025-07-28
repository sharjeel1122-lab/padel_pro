// import 'package:get/get.dart';
//
// import '../data models/vendor_data_model.dart';
// import '../mock data/vendor_mock_data.dart';
//
// class AuthController extends GetxController {
//   var currentVendor = Rxn<Vendor>(); // Rxn ka matlab hai ke yeh null ho sakta hai.
//   var error = ''.obs; // .obs isko reactive banata hai.
//
//   void login(String vendorId, String password) {
//     try {
//       final vendor = mockVendors.firstWhere(
//             (v) => v.id == vendorId && v.password == password,
//       );
//       currentVendor.value = vendor;
//       error.value = '';
//     } catch (e) {
//       error.value = 'Vendor ID ya Password ghalat hai.';
//     }
//   }
//
//   void logout() {
//     currentVendor.value = null;
//   }
// }
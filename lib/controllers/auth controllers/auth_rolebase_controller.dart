import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:padel_pro/services/user_login_api.dart';

import '../../services/profile api/user_profile_api.dart';


//
//
// class AuthController extends GetxController {
//   final saveVendorId = GetStorage();
//   final profileApi = ProfileApi();
//   final storage = const FlutterSecureStorage();
//
//   final obscureText = true.obs;
//   final rememberMe = false.obs;
//   final isLoading = false.obs;
//
//   void toggleVisibility() => obscureText.toggle();
//   void toggleRememberMe() => rememberMe.toggle();
//
//   // Email/Password Login
//   Future<void> login(String email, String password) async {
//     try {
//       isLoading(true);
//       Get.closeAllSnackbars();
//
//       final response = await UserLoginApi.login(email, password);
//       final token = response['token'];
//       final user = response['user'];
//       final role = user['role'];
//       final id = user['id'];
//
//       await storage.write(key: 'token', value: token);
//       await storage.write(key: 'role', value: role);
//       await storage.write(key: 'email', value: email);
//
//       if (role.toLowerCase() == 'vendor') {
//         await storage.write(key: 'vendorId', value: id);
//       }
//
//       profileApi.getProfile();
//
//       Get.snackbar('Login Successful', 'Welcome ${role.toUpperCase()}',
//           snackPosition: SnackPosition.BOTTOM,
//           backgroundColor: Colors.green,
//           colorText: Colors.white);
//
//       await Future.delayed(const Duration(seconds: 1));
//
//       final hasMPIN = await storage.read(key: 'mpin');
//       if (hasMPIN == null) {
//         Get.offAllNamed('/setup-mpin'); // <-- route to create MPIN
//       } else {
//         _navigateToDashboard(role);
//       }
//     } catch (e) {
//       Get.snackbar('Login Failed', e.toString().replaceAll('Exception: ', ''),
//           snackPosition: SnackPosition.BOTTOM,
//           backgroundColor: Colors.red,
//           colorText: Colors.white);
//     } finally {
//       isLoading(false);
//     }
//   }
//
//   // MPIN Login
//   Future<void> loginWithMPIN(String mpin) async {
//     try {
//       isLoading(true);
//       final response = await UserMPINLoginApi.loginWithMPIN(mpin);
//
//       final token = response['token'];
//       final user = response['user'];
//       final role = user['role'] ?? 'user';
//       final id = user['id'];
//
//       await storage.write(key: 'token', value: token);
//       await storage.write(key: 'role', value: role);
//       await storage.write(key: 'email', value: user['email']);
//       await storage.write(key: 'mpin', value: mpin);
//
//       if (role.toLowerCase() == 'vendor') {
//         await storage.write(key: 'vendorId', value: id);
//       }
//
//       profileApi.getProfile();
//
//       Get.snackbar('Login Successful', 'Welcome back $role',
//           snackPosition: SnackPosition.BOTTOM,
//           backgroundColor: Colors.green,
//           colorText: Colors.white);
//
//       await Future.delayed(Duration(seconds: 1));
//       _navigateToDashboard(role);
//     } catch (e) {
//       Get.snackbar('MPIN Login Failed', e.toString().replaceAll('Exception: ', ''),
//           snackPosition: SnackPosition.BOTTOM,
//           backgroundColor: Colors.red,
//           colorText: Colors.white);
//     } finally {
//       isLoading(false);
//     }
//   }
//
//   // Save MPIN
//   Future<void> saveMPIN(String mpin) async {
//     await storage.write(key: 'mpin', value: mpin);
//   }
//
//   // Check if MPIN exists
//   Future<bool> hasMPIN() async {
//     final mpin = await storage.read(key: 'mpin');
//     return mpin != null;
//   }
//
//   // Logout
//   Future<void> logout() async {
//     try {
//       await storage.deleteAll();
//       saveVendorId.remove('vendorId');
//
//       Get.snackbar('Logged Out', 'You have been successfully logged out',
//           snackPosition: SnackPosition.BOTTOM,
//           backgroundColor: Colors.blue,
//           colorText: Colors.white);
//
//       Get.offAllNamed('/login');
//     } catch (e) {
//       Get.snackbar('Logout Error', 'Failed to clear session data',
//           snackPosition: SnackPosition.BOTTOM,
//           backgroundColor: Colors.red);
//     }
//   }
//
//   //  Dashboard Navigator
//   void _navigateToDashboard(String role) {
//     switch (role.toLowerCase()) {
//       case 'admin':
//         Get.offAllNamed('/admin-dashboard');
//         break;
//       case 'vendor':
//         Get.offAllNamed('/vendor-dashboard');
//         break;
//       default:
//         Get.offAllNamed('/userHome');
//     }
//   }
// }

// Working
class AuthController extends GetxController {
  final saveVendorId = GetStorage();
  final profileApi = ProfileApi();



  final storage = const FlutterSecureStorage();
  final obscureText = true.obs; // Observable for password visibility
  final rememberMe = false.obs; // Observable for remember me
  final isLoading = false.obs;  // Observable for loading state

  void toggleVisibility() {
    obscureText.toggle();
    update();
  }

  void toggleRememberMe() {
    rememberMe.toggle();
    update();
  }

  Future<void> login(String email, String password) async {
    try {
      isLoading(true);
      Get.closeAllSnackbars();

      final response = await UserLoginApi.login(email, password);
      final token = response['token'];
      final user = response['user'];
      final role = user['role'];
      final id = user['id'];

      await storage.write(key: 'token', value: token);
      await storage.write(key: 'role', value: role);
      await storage.write(key: 'email', value: email);
      final savedToken = await storage.read(key: 'token');
      print('📦 Token stored in secure storage: $savedToken');

      if (role.toLowerCase() == 'vendor') {
        await storage.write(key: 'vendorId', value: id);
      }



      profileApi.getProfile();

      Get.snackbar(
        'Login Successful',
        'Welcome ${role.toUpperCase()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      await Future.delayed(const Duration(seconds: 1));


      await storage.write(key: 'isLoggedIn', value: 'true');

      final savedToken2 = await storage.read(key: 'isLoggedIn');

      print("Check Save Token 2: ${savedToken2}");



      switch (role.toLowerCase()) {
        case 'admin':
          Get.offAllNamed('/admin-dashboard');
          break;
        case 'vendor':
          Get.offAllNamed('/vendor-dashboard');
          break;
        default:
          Get.offAllNamed('/userHome');
      }
    } catch (e) {
      Get.snackbar(
        'Login Failed',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading(false);
    }
  }

  Future<void> logout() async {
    try {
      await storage.delete(key: 'token');
      await storage.delete(key: 'role');

      saveVendorId.remove('vendorId'); //

      Get.snackbar(
        'Logged Out',
        'You have been successfully logged out',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blue,
        colorText: Colors.white,
      );
      await storage.write(key: 'isLoggedIn', value: 'true');
      final savedToken2 = await storage.read(key: 'isLoggedIn');

      print("Check Save Token Read: ${savedToken2}");

      Get.offAllNamed('/splash');

    } catch (e) {
      Get.snackbar(
        'Logout Error',
        'Failed to clear session data',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
      );
    }
  }
}
// Working



// import 'package:flutter/material.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:get/get.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:padel_pro/services/user_login_api.dart';
// import '../../services/profile api/user_profile_api.dart';
//
// class AuthController extends GetxController {
//   final profileApi = ProfileApi();
//   final storage = const FlutterSecureStorage();
//   final obscureText = true.obs;
//   final rememberMe = false.obs;
//   final isLoading = false.obs;
//
//   late SharedPreferences _prefs;
//
//   @override
//   void onInit() {
//     super.onInit();
//     _initSharedPreferences();
//   }
//
//   Future<void> _initSharedPreferences() async {
//     _prefs = await SharedPreferences.getInstance();
//     // Check if user was previously logged in
//     if (_prefs.getBool('isLoggedIn') == true) {
//       _autoLogin();
//     }
//   }
//
//   Future<void> _autoLogin() async {
//     try {
//       isLoading(true);
//       final email = _prefs.getString('email');
//       final role = _prefs.getString('role');
//
//       if (email != null && role != null) {
//         // Get token from secure storage
//         final token = await storage.read(key: 'token');
//         if (token != null) {
//           // Navigate to appropriate dashboard
//           switch (role.toLowerCase()) {
//             case 'admin':
//               Get.offAllNamed('/admin-dashboard');
//               break;
//             case 'vendor':
//               Get.offAllNamed('/vendor-dashboard');
//               break;
//             default:
//               Get.offAllNamed('/userHome');
//           }
//         }
//       }
//     } catch (e) {
//       await _clearSessionData();
//     } finally {
//       isLoading(false);
//     }
//   }
//
//   Future<void> login(String email, String password) async {
//     try {
//       isLoading(true);
//       Get.closeAllSnackbars();
//
//       final response = await UserLoginApi.login(email, password);
//       final token = response['token'];
//       final user = response['user'];
//       final role = user['role'];
//       final id = user['_id'];
//
//       // Store sensitive data in secure storage
//       await storage.write(key: 'token', value: token);
//       await storage.write(key: 'role', value: role);
//       if (role.toLowerCase() == 'vendor') {
//         await storage.write(key: 'vendorId', value: id);
//       }
//
//       // Store non-sensitive data in SharedPreferences
//       await _prefs.setBool('isLoggedIn', true);
//       await _prefs.setString('email', email);
//       await _prefs.setString('role', role);
//
//       profileApi.getProfile();
//
//       Get.snackbar(
//         'Login Successful',
//         'Welcome ${role.toUpperCase()}',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.green,
//         colorText: Colors.white,
//       );
//
//       await Future.delayed(const Duration(seconds: 1));
//
//       switch (role.toLowerCase()) {
//         case 'admin':
//           Get.offAllNamed('/admin-dashboard');
//           break;
//         case 'vendor':
//           Get.offAllNamed('/vendor-dashboard');
//           break;
//         default:
//           Get.offAllNamed('/userHome');
//       }
//     } catch (e) {
//       Get.snackbar(
//         'Login Failed',
//         e.toString().replaceAll('Exception: ', ''),
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//     } finally {
//       isLoading(false);
//     }
//   }
//
//   Future<void> _clearSessionData() async {
//     await storage.delete(key: 'token');
//     await storage.delete(key: 'role');
//     await storage.delete(key: 'vendorId');
//     await _prefs.remove('isLoggedIn');
//     await _prefs.remove('email');
//     await _prefs.remove('role');
//   }
//
//   Future<void> logout() async {
//     try {
//       await _clearSessionData();
//
//       Get.snackbar(
//         'Logged Out',
//         'You have been successfully logged out',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.blue,
//         colorText: Colors.white,
//       );
//       Get.offAllNamed('/login');
//     } catch (e) {
//       Get.snackbar(
//         'Logout Error',
//         'Failed to clear session data',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.red,
//       );
//     }
//   }
//
//   void toggleVisibility() {
//     obscureText.toggle();
//     update();
//   }
//
//   void toggleRememberMe() {
//     rememberMe.toggle();
//     update();
//   }
// }

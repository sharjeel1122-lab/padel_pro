// import 'dart:async';
// import 'package:get/get.dart';
// import 'package:padel_pro/model/users model/user_model.dart';
// import 'package:padel_pro/services/admin api/fetch_all_users_api.dart';
// import 'package:padel_pro/services/admin api/delete_user_api.dart';
//
// class TotalUsersController extends GetxController {
//   final FetchAllUsersApi service = FetchAllUsersApi();
//   final DeleteUserApi deleteService = DeleteUserApi();
//
//   // state
//   final users = <UserModel>[].obs;
//   final searchQuery = ''.obs;
//   final isLoading = true.obs;
//
//   // computed
//   List<UserModel> get filteredUsers {
//     if (searchQuery.isEmpty) return users;
//     final q = searchQuery.value.toLowerCase();
//     return users.where((u) {
//       final fullName = "${u.firstName} ${u.lastName}".toLowerCase();
//       final email = u.email.toLowerCase();
//       final phone = u.phone?.toLowerCase() ?? '';
//       return fullName.contains(q) || email.contains(q) || phone.contains(q);
//     }).toList()
//       ..sort((a, b) => a.firstName.compareTo(b.firstName));
//   }
//
//   @override
//   void onInit() {
//     super.onInit();
//     _loadWithMinimumDelay();
//   }
//
//   void search(String query) => searchQuery.value = query;
//
//   /// Ensures the loader stays for at least 5 seconds.
//   Future<void> _loadWithMinimumDelay() async {
//     isLoading.value = true;
//     final start = DateTime.now();
//
//     await fetchUsers(); // fetch data (handles its own errors)
//
//     final elapsed = DateTime.now().difference(start);
//     final minDuration = const Duration(seconds: 5);
//     final remaining = minDuration - elapsed;
//
//     if (remaining > Duration.zero) {
//       await Future.delayed(remaining);
//     }
//     isLoading.value = false;
//   }
//
//   Future<void> fetchUsers() async {
//     try {
//       final result = await service.fetchUsers();
//       users.assignAll(result.where((u) => u.role == 'user'));
//     } catch (e) {
//       // error UI optional
//       Get.snackbar("Error", e.toString());
//     }
//   }
//
//   Future<bool> deleteUserById(String userId) async {
//     try {
//       return await deleteService.deleteUserById(userId);
//     } catch (e) {
//       Get.snackbar("Error", e.toString());
//       return false;
//     }
//   }
// }

import 'dart:async';
import 'package:get/get.dart';
import 'package:padel_pro/model/users model/user_model.dart';
import 'package:padel_pro/services/admin api/fetch_all_users_api.dart';
import 'package:padel_pro/services/admin api/delete_user_api.dart';

class TotalUsersController extends GetxController {
  final FetchAllUsersApi service = FetchAllUsersApi();
  final DeleteUserApi deleteService = DeleteUserApi();

  // state
  final users = <UserModel>[].obs;
  final searchQuery = ''.obs;
  final isLoading = true.obs;
  final isDeleting = false.obs; // ✅ added

  // computed
  List<UserModel> get filteredUsers {
    if (searchQuery.isEmpty) return users;
    final q = searchQuery.value.toLowerCase();
    return users.where((u) {
      final fullName = "${u.firstName} ${u.lastName}".toLowerCase();
      final email = u.email.toLowerCase();
      final phone = u.phone?.toLowerCase() ?? '';
      return fullName.contains(q) || email.contains(q) || phone.contains(q);
    }).toList()
      ..sort((a, b) => a.firstName.compareTo(b.firstName));
  }

  @override
  void onInit() {
    super.onInit();
    _loadWithMinimumDelay();
  }

  void search(String query) => searchQuery.value = query;

  /// Ensures the loader stays for at least 5 seconds.
  Future<void> _loadWithMinimumDelay() async {
    isLoading.value = true;
    final start = DateTime.now();

    await fetchUsers();

    final elapsed = DateTime.now().difference(start);
    final minDuration = const Duration(seconds: 5);
    final remaining = minDuration - elapsed;

    if (remaining > Duration.zero) {
      await Future.delayed(remaining);
    }
    isLoading.value = false;
  }

  Future<void> fetchUsers() async {
    try {
      final result = await service.fetchUsers();
      users.assignAll(result.where((u) => u.role == 'user'));
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  Future<void> refresh() async { // ✅ added for pull-to-refresh
    await fetchUsers();
  }

  Future<bool> deleteUserById(String userId) async {
    try {
      return await deleteService.deleteUserById(userId);
    } catch (e) {
      Get.snackbar("Error", e.toString());
      return false;
    }
  }
}

import 'package:get/get.dart';

class ProfileController extends GetxController {
  var firstName = ''.obs;
  var lastName = ''.obs;
  var email = ''.obs;
  var phone = ''.obs;
  var city = ''.obs;
  var gender = ''.obs;

  void loadUserData(Map<String, dynamic> user) {
    firstName.value = user['firstName'] ?? '';
    lastName.value = user['lastName'] ?? '';
    email.value = user['email'] ?? '';
    phone.value = user['phone'] ?? '';
    city.value = user['city'] ?? '';
    gender.value = user['gender'] ?? '';
  }

  void updateProfile({
    required String firstName,
    required String lastName,
    required String phone,
    required String city,
    required String gender,
  }) {
    this.firstName.value = firstName;
    this.lastName.value = lastName;
    this.phone.value = phone;
    this.city.value = city;
    this.gender.value = gender;


  }
}

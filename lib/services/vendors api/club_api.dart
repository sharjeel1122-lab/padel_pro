// import 'package:get/get.dart';
//
//
// class ClubApi {
//   final ApiProvider _api = Get.find<ApiProvider>();
//
//   Future<List<Club>> getVendorClubs() async {
//     final response = await _api.get('/vendor/clubs');
//     return List<Club>.from(response.data.map((x) => Club.fromJson(x)));
//   }
//
//   Future<void> createClub(Club club) async {
//     await _api.post('/clubs', club.toJson());
//   }
//
//   Future<void> updateClub(String clubId, Club club) async {
//     await _api.put('/clubs/$clubId', club.toJson());
//   }
//
//   Future<void> deleteClub(String clubId) async {
//     await _api.delete('/clubs/$clubId');
//   }
// }
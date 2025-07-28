// import 'package:get/get.dart';
//
// import '../../../model/court_model.dart';
//
//
// class TotalVenuesController extends GetxController {
//   RxList<VenueModel> allVenues = <VenueModel>[].obs;
//   RxList<VenueModel> filteredVenues = <VenueModel>[].obs;
//
//   var searchText = ''.obs;
//
//   @override
//   void onInit() {
//     super.onInit();
//     fetchVenues();
//   }
//
//   void fetchVenues() {
//     // Static for now – backend later
//     allVenues.value = [
//       VenueModel(
//         name: 'Elite Ground',
//         location: 'Lahore',
//         price: 3000,
//         startTime: '5:00 PM',
//         endTime: '10:00 PM',
//         imageUrl: '',
//       ),
//       VenueModel(
//         name: 'Star Court',
//         location: 'Karachi',
//         price: 2500,
//         startTime: '6:00 AM',
//         endTime: '11:00 AM',
//         imageUrl: '',
//       ),
//     ];
//     filteredVenues.value = allVenues;
//   }
//
//   void search(String value) {
//     searchText.value = value.toLowerCase();
//     filteredVenues.value = allVenues.where((venue) {
//       return venue.name.toLowerCase().contains(searchText.value) ||
//           venue.location.toLowerCase().contains(searchText.value) ||
//           venue.price.toString().contains(searchText.value);
//     }).toList();
//   }
//
//   void deleteVenue(int index) {
//     allVenues.removeAt(index);
//     search(searchText.value);
//   }
//
//   void editVenue(int index) {
//     // Navigate to edit screen later
//     print("Editing venue: ${allVenues[index].name}");
//   }
// }

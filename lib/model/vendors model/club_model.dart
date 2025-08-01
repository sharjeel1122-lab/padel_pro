// import 'package:padel_pro/model/vendors%20model/court_model.dart';
//
// class Playground {
//   final String name;
//   final String size;
//   final String openingTime;
//   final String closingTime;
//   final String description;
//   final List<String> photos;
//   final String website;
//   final String phoneNumber;
//   final String location;
//   final String city;
//   final List<String> facilities;
//   final bool recommended;
//   final List<dynamic> wishlist;
//   final String vendorId;
//   final List<CourtModel> courts;
//
//   Playground({
//     required this.name,
//     required this.size,
//     required this.openingTime,
//     required this.closingTime,
//     required this.description,
//     required this.photos,
//     required this.website,
//     required this.phoneNumber,
//     required this.location,
//     required this.city,
//     required this.facilities,
//     required this.recommended,
//     required this.wishlist,
//     required this.vendorId,
//     required this.courts,
//   });
//
//   factory Playground.fromJson(Map<String, dynamic> json) {
//     return Playground(
//       name: json['name'],
//       size: json['size'],
//       openingTime: json['openingTime'],
//       closingTime: json['closingTime'],
//       description: json['description'],
//       photos: List<String>.from(json['photos']),
//       website: json['website'],
//       phoneNumber: json['phoneNumber'],
//       location: json['location'],
//       city: json['city'],
//       facilities: List<String>.from(json['facilities']),
//       recommended: json['recommended'],
//       wishlist: List<dynamic>.from(json['wishlist']),
//       vendorId: json['vendorId']['\$oid'],
//       courts: (json['courts'] as List).map((e) => CourtModel.fromJson(e)).toList(),
//     );
//   }
// }

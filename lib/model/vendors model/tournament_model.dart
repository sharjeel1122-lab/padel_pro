// class Tournament {
//   final String id;
//   final String name;
//   final String description;
//   final DateTime startDate;
//   final String location;
//   final String status; // upcoming, ongoing, completed
//   final int participants;
//   final String type; // Men's, Women's, Mixed
//
//   Tournament({
//     required this.id,
//     required this.name,
//     required this.description,
//     required this.startDate,
//     required this.location,
//     required this.status,
//     required this.participants,
//     required this.type,
//   });
// }

class Tournament {
  final String id;
  final String name;
  final String description;
  final String? photo;
  final String vendorId;
  final DateTime createdAt;

  Tournament({
    required this.id,
    required this.name,
    required this.description,
    this.photo,
    required this.vendorId,
    required this.createdAt,
  });

  factory Tournament.fromJson(Map<String, dynamic> json) {
    return Tournament(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      photo: json['photo'],
      vendorId: json['vendorId'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

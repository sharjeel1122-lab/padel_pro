class Tournament {
  final String id;
  final String name;
  final String registrationLink;
  final String tournamentType;
  final String location;
  final String startDate;
  final String startTime;
  final String description;
  final String? photo;
  final String vendorId;
  final DateTime createdAt;

  Tournament({
    required this.id,
    required this.name,
    required this.registrationLink,
    required this.tournamentType,
    required this.location,
    required this.startDate,
    required this.startTime,
    required this.description,
    required this.vendorId,
    required this.createdAt,
    this.photo,
  });

  factory Tournament.fromJson(Map<String, dynamic> json) {
    return Tournament(
      id: json['_id'],
      name: json['name'],
      registrationLink: json['registrationLink'],
      tournamentType: json['tournamentType'],
      location: json['location'],
      startDate: json['startDate'],
      startTime: json['startTime'],
      description: json['description'],
      photo: json['photo'],
      vendorId: json['vendorId'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  String get type => type;

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'registrationLink': registrationLink,
      'tournamentType': tournamentType,
      'location': location,
      'startDate': startDate,
      'startTime': startTime,
      'description': description,
      'photo': photo,
      'vendorId': vendorId,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

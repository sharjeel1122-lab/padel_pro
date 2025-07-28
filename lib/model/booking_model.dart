class BookingModel {
  final String id;
  final String userName;
  final String userEmail;
  final String clubName;
  final String courtName;
  final DateTime bookingDate;

  BookingModel({
    required this.id,
    required this.userName,
    required this.userEmail,
    required this.clubName,
    required this.courtName,
    required this.bookingDate,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['_id'],
      userName: json['userName'],
      userEmail: json['userEmail'],
      clubName: json['clubName'],
      courtName: json['courtName'],
      bookingDate: DateTime.parse(json['bookingDate']),
    );
  }
}

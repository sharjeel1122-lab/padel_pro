class PeakHour {
  final String startTime;
  final String endTime;
  final int price;

  PeakHour({
    required this.startTime,
    required this.endTime,
    required this.price,
  });

  factory PeakHour.fromJson(Map<String, dynamic> json) {
    return PeakHour(
      startTime: json['startTime'],
      endTime: json['endTime'],
      price: json['price'],
    );
  }
}

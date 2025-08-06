// class Pricing {
//   final int duration;
//   final int price;
//
//   Pricing({required this.duration, required this.price});
//
//   factory Pricing.fromJson(Map<String, dynamic> json) {
//     return Pricing(
//       duration: json['duration'],
//       price: json['price'],
//     );
//   }
// }
class Pricing {
  int duration;
  double price;

  Pricing({required this.duration, required this.price});

  Map<String, dynamic> toJson() {
    return {
      'duration': duration,
      'price': price,
    };
  }

  factory Pricing.fromJson(Map<String, dynamic> json) {
    return Pricing(
      duration: json['duration'],
      price: (json['price'] as num).toDouble(),
    );
  }
}

class PeakHours {
  String startTime;
  String endTime;
  double price;

  PeakHours({
    required this.startTime,
    required this.endTime,
    required this.price,
  });

  Map<String, dynamic> toJson() {
    return {
      'startTime': startTime,
      'endTime': endTime,
      'price': price,
    };
  }

  factory PeakHours.fromJson(Map<String, dynamic> json) {
    return PeakHours(
      startTime: json['startTime'],
      endTime: json['endTime'],
      price: (json['price'] as num).toDouble(),
    );
  }
}

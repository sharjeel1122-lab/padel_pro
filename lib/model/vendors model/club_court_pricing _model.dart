class Pricing {
  final int duration;
  final int price;

  Pricing({required this.duration, required this.price});

  factory Pricing.fromJson(Map<String, dynamic> json) {
    return Pricing(
      duration: json['duration'],
      price: json['price'],
    );
  }
}

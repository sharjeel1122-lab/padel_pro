import 'dart:ui';

class Shop {
  final String name;
  final String location;
  final String image;
  final double rating;
  final bool recommended;

  Shop({
    required this.name,
    required this.location,
    required this.image,
    required this.rating,
    this.recommended = false,
  });
}

class Product {
  final String brand;
  final String name;
  final String image;
  final double price;
  final double rating;
  final String category;
  final String description;
  final List<String> sizes;
  final List<Color> colors;

  Product({
    required this.brand,
    required this.name,
    required this.image,
    required this.price,
    required this.rating,
    required this.category,
    required this.description,
    required this.sizes,
    required this.colors,
  });
}
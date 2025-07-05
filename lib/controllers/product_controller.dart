import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../model/shop_model.dart';

class ProductController extends GetxController {
  var products = <Product>[].obs;
  var selectedProduct = Rxn<Product>();

  @override
  void onInit() {
    super.onInit();
    products.addAll([
      Product(
        brand: 'Adidas',
        name: 'Nave Jeasos',
        image: 'assets/image.png',
        price: 1200,
        rating: 5.0,
        category: 'Sports Shoes',
        description: 'Comfortable running shoe with breathable material.',
        sizes: ['S', 'M', 'L', 'XL', 'XXL'],
        colors: [Colors.black, Colors.brown, Colors.blue, Colors.teal, Colors.white],
      ),
    ]);
  }

  void selectProduct(Product product) {
    selectedProduct.value = product;
  }
}
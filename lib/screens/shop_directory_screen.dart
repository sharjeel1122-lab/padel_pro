import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/product_controller.dart';
import '../controllers/shop_controller.dart';
import '../custom_widgets/search_bar_widget.dart';
import '../custom_widgets/shop_list_card_two.dart';
import 'product_detail_screen.dart';

class ShopDirectoryScreen extends StatelessWidget {
  final shopController = Get.find<ShopController>();
  final productController = Get.find<ProductController>();

   ShopDirectoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SearchBarWidget(),
              const SizedBox(height: 16),
              Obx(() => Text(shopController.shops[0].name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20))),
              Row(
                children: [
                  Icon(Icons.location_on, color: Colors.redAccent),
                  Text(shopController.shops[0].location),
                  Spacer(),
                  Icon(Icons.star, color: Colors.orange),
                  Text(shopController.shops[0].rating.toString()),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Obx(() => GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.75),
                  itemCount: productController.products.length,
                  itemBuilder: (context, index) {
                    final product = productController.products[index];
                    return GestureDetector(
                      onTap: () {
                        productController.selectProduct(product);
                        Get.to(() => ProductDetailScreen());
                      },
                      child: ShopListCardTwo(product: product),
                    );
                  },
                )),
              )
            ],
          ),
        ),
      ),
    );
  }
}
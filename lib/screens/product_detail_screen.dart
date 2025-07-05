import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/product_controller.dart';

class ProductDetailScreen extends StatelessWidget {
  final controller = Get.find<ProductController>();

   ProductDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final product = controller.selectedProduct.value;
    if (product == null) return SizedBox();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: BackButton(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.asset(product.image, height: 200),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (i) => Padding(
                padding: EdgeInsets.all(4),
                child: Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    border: Border.all(color: Color(0xFF91E208), width: i == 0 ? 2 : 1),
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(image: AssetImage(product.image), fit: BoxFit.cover),
                  ),
                ),
              )),
            ),
            const SizedBox(height: 12),
            Text(product.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
            Text('${product.price} PKR', style: TextStyle(color: Colors.grey[700], fontSize: 18)),
            const SizedBox(height: 10),
            Row(
              children: [
                CircleAvatar(radius: 10, backgroundImage: AssetImage('assets/shop.jpg')),
                const SizedBox(width: 8),
                Text('Speed Sports'),
                Spacer(),
                Icon(Icons.star, color: Colors.orange),
                Text(product.rating.toString()),
              ],
            ),
            const SizedBox(height: 16),
            Text('Size', style: TextStyle(fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 8,
              children: product.sizes
                  .map((s) => ChoiceChip(label: Text(s), selected: false))
                  .toList(),
            ),
            const SizedBox(height: 16),
            Text('Color', style: TextStyle(fontWeight: FontWeight.bold)),
            Row(
              children: product.colors.map((c) => Container(
                margin: EdgeInsets.symmetric(horizontal: 4),
                width: 24,
                height: 24,
                decoration: BoxDecoration(color: c, shape: BoxShape.circle, border: Border.all(color: Colors.black12)),
              )).toList(),
            ),
            const SizedBox(height: 16),
            Text('Description', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(product.description, style: TextStyle(color: Colors.grey[700])),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green, shape: StadiumBorder()),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text('Add to Cart'),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
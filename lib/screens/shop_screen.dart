import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:padel_pro/controllers/shop_controller.dart';

import '../custom_widgets/recommended_shop_card.dart';
import '../custom_widgets/search_bar_widget.dart';
import '../custom_widgets/shop_list_card.dart';

class ShopScreen extends StatelessWidget {
  final ShopController controller = Get.find();

   ShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10,),
                SearchBarWidget(),
                const SizedBox(height: 20),
                _buildSectionHeader('Recommended Products', onTap: () {}),
                const SizedBox(height: 10),
                Obx(() {
                  final recommended = controller.shops.where((s) => s.recommended).toList();
                  return SizedBox(
                    height: 130,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: recommended.length,
                      separatorBuilder: (_, __) => SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        return RecommendedShopCard(shop: recommended[index]);
                      },
                    ),
                  );
                }),
                const SizedBox(height: 24),
                Text('Products', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Obx(() => Column(
                  children: controller.shops
                      .where((s) => !s.recommended)
                      .map((shop) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: ShopListCard(shop: shop),
                  ))
                      .toList(),
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, {required VoidCallback onTap}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        GestureDetector(
          onTap: onTap,
          child: Text('See All', style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}
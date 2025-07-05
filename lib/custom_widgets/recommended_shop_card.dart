import 'package:flutter/material.dart';

import '../model/shop_model.dart';

class RecommendedShopCard extends StatelessWidget {
  final Shop shop;

  const RecommendedShopCard({super.key, required this.shop});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(
          image: AssetImage(shop.image),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [Colors.black.withOpacity(0.6), Colors.transparent],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Spacer(),
            Text(shop.name, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            Text(shop.location, style: TextStyle(color: Colors.white70, fontSize: 12)),
            Row(
              children: [
                Icon(Icons.star, color: Colors.orangeAccent, size: 14),
                SizedBox(width: 4),
                Text(shop.rating.toString(), style: TextStyle(color: Colors.white, fontSize: 12)),
              ],
            )
          ],
        ),
      ),
    );
  }
}
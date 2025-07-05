import 'package:get/get.dart';

import '../model/shop_model.dart';

class ShopController extends GetxController {
  var shops = <Shop>[
    Shop(name: 'Sports Plus', location: 'DHA, Lahore', image: 'assets/image.png', rating: 4.5, recommended: true),
    Shop(name: 'Speed Sports', location: 'Giga Mall, Lhr', image: 'assets/image (1).png', rating: 4.6, recommended: true),
    Shop(name: 'Capital Sports', location: 'DHA, Lhr', image: 'assets/image (2).png', rating: 4.5, recommended: true),
    Shop(name: 'Speed Sports', location: 'DHA, Lahore', image: 'assets/image (3).png', rating: 4.9),
    Shop(name: 'Sports Plus', location: 'Askari X, Lahore', image: 'assets/image (4).png', rating: 4.8),
    Shop(name: 'Sports Plus', location: 'Askari X, Lahore', image: 'assets/image (5).png', rating: 4.8),
  ].obs;
}
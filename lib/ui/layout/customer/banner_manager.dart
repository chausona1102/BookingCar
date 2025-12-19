import '../../../models/banner.dart';
import 'package:go_router/go_router.dart';

final List<BannerItem> banners = [
  BannerItem(
    image: 'assets/images/banner1.png',
    onTap: (context) {
      context.go('/booking');
      print("banner hội viên");
    },
  ),
  BannerItem(
    image: 'assets/images/banner2.png',
    onTap: (context) {
      context.go('/booking');
      print("banner khuyến mãi");
    },
  ),
  BannerItem(
    image: 'assets/images/banner3.jpg',
    onTap: (context) {
      print("banner khuyến mãi");
    },
  ),
];

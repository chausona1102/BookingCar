import '../../../models/banner.dart';
import 'package:go_router/go_router.dart';

final List<BannerItem> banners = [
  BannerItem(
    image: 'assets/images/banner1.png',
    onTap: (context, membership, user) {
      context.push(
        '/booking',
        extra: {'type': 'car', 'memberInfo': membership, 'user': user},
      );
    },
  ),
  BannerItem(
    image: 'assets/images/banner2.png',
    onTap: (context, membership, user) {
      context.push(
        '/booking',
        extra: {'type': 'car', 'memberInfo': membership, 'user': user},
      );
    },
  ),
  BannerItem(
    image: 'assets/images/banner3.jpg',
    onTap: (context, membership, user) {
      context.push('/become-vip-page');
    },
  ),
];

import 'package:booking_app/ui/auth/auth_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../shared/navigation_bar.dart';
import 'banner_manager.dart';

class Customer extends StatefulWidget {
  const Customer({super.key});

  @override
  State<Customer> createState() => _CustomerState();
}

class _CustomerState extends State<Customer> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 3), _autoSlide);
  }

  void _autoSlide() {
    if (!mounted) return;

    _currentPage = (_currentPage + 1) % banners.length;

    _pageController.animateToPage(
      _currentPage,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );

    Future.delayed(const Duration(seconds: 3), _autoSlide);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthManager>().user;
    return Scaffold(
      backgroundColor: Colors.green.shade50,
      body: SingleChildScrollView(
        // padding: EdgeInsetsGeometry.all(1),
        child: Column(
          children: [
            const SizedBox(height: 60),
            Padding(
              padding: EdgeInsets.only(top: 20, left: 20, right: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Xin chào, ${user!.fullName}',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.only(left: 20, right: 20),
              child: GestureDetector(
                onTap: () => {print("Dat xe")},
                child: Container(
                  padding: EdgeInsets.only(
                    top: 8,
                    left: 10,
                    right: 10,
                    bottom: 8,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.green, width: 1),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.amberAccent),
                      const SizedBox(width: 10),
                      Text(
                        'Bạn muốn đi đâu nạ?',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              // spacing: 2,
              children: [
                IconButton(
                  onPressed: () {
                    print('Dat oto');
                  },
                  icon: _iconButton(
                    imagePath: 'assets/images/car.png',
                    text: 'Ô tô',
                  ),
                ),
                IconButton(
                  onPressed: () {
                    print('Dat xe máy');
                  },
                  icon: _iconButton(
                    imagePath: 'assets/images/motobike.png',
                    text: 'Xe máy',
                  ),
                ),
                IconButton(
                  onPressed: () => {print('Theo doi dat xe')},
                  icon: _iconButton(
                    imagePath: 'assets/images/car_driving_removebg.png',
                    text: 'Theo dõi',
                  ),
                ),
                IconButton(
                  onPressed: () => {print('Dang ky hoi vien')},
                  icon: _iconButton(
                    imagePath: 'assets/images/VIP_rmbg.png',
                    text: 'Hội viên',
                  ),
                ),
                IconButton(
                  onPressed: () => {print('Booking tai xe')},
                  icon: _iconButton(
                    imagePath: 'assets/images/driver.png',
                    text: 'Tài xế',
                  ),
                ),
              ],
            ),
            // const Divider(color: Colors.green),
            SizedBox(
              height: 200,
              child: PageView.builder(
                controller: _pageController,
                itemCount: banners.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  final banner = banners[index];
                  return GestureDetector(
                    onTap: () => banner.onTap(context),
                    child: Image.asset(banner.image, fit: BoxFit.cover),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(banners.length, (index) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 25 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? Colors.green
                        : Colors.green.shade200,
                    borderRadius: BorderRadius.circular(10),
                  ),
                );
              }),
            ),
            // const Divider(color: Colors.green),
            Padding(
              padding: EdgeInsetsGeometry.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Gói hội viên',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () => {print('Hoi vien')},
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                  child: ClipRRect(
                    borderRadius: BorderRadiusGeometry.circular(15),
                    child: Image.asset(
                      'assets/images/signupmember.png',
                      height: 150,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Padding(
            //   padding: EdgeInsetsGeometry.symmetric(
            //     horizontal: 20,
            //     vertical: 10,
            //   ),
            //   child: Align(
            //     alignment: Alignment.centerLeft,
            //     child: Text(
            //       'Gói hội viên',
            //       style: TextStyle(
            //         color: Colors.black,
            //         fontWeight: FontWeight.bold,
            //         fontSize: 18,
            //       ),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
      bottomNavigationBar: const NavBar(),
    );
  }

  Widget _iconButton({required String imagePath, required String text}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(imagePath, width: 80, height: 80, fit: BoxFit.contain),
        Text(
          text,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}

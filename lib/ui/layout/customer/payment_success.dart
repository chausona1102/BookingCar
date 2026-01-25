import 'package:go_router/go_router.dart';
import 'package:booking_app/ui/shared/button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class PaymentSuccessPage extends StatefulWidget {
  const PaymentSuccessPage({super.key});
  @override
  State<StatefulWidget> createState() => _PaymentSuccessState();
}

class _PaymentSuccessState extends State<PaymentSuccessPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: myAppBar(context, 'Thanh toán'),
      backgroundColor: Colors.white,
      body: Container(
        color: Colors.green,
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/gifs/dancing.gif', width: 120),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Thanh toán thành công',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: EdgeInsets.all(2),
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: SvgPicture.asset(
                    'assets/icons/check.svg',
                    color: Colors.green,
                    width: 24,
                    height: 24,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            button('Quay lại trang chủ', 'light', () {
              context.go('/');
            }),
          ],
        ),
      ),
    );
  }
}

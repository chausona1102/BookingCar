import 'package:booking_app/models/booking.dart';
import 'package:booking_app/ui/layout/customer/payment_manager.dart';
import 'package:booking_app/ui/shared/snackBarLogger.dart';
import 'package:booking_app/utils/myFunction.dart';
import '../../auth/auth_manager.dart';
import 'package:booking_app/ui/shared/svgButton.dart';
import 'package:flutter/services.dart';
import 'package:booking_app/ui/shared/myAppBar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../customer/bank_manager.dart';
import 'package:booking_app/ui/shared/button.dart';
import 'package:go_router/go_router.dart';

class PaymentTripPage extends StatefulWidget {
  final BookingModel data;
  const PaymentTripPage({super.key, required this.data});
  @override
  State<StatefulWidget> createState() => _PaymentState();
}

class _PaymentState extends State<PaymentTripPage> {
  var bankname = 'Agribank';
  var bankcode = '10890013';
  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      // tạo payment
      context.read<PaymentManager>().createPaymentBooking(
        widget.data,
        bankname,
        bankcode,
      );

      // check membership
    });
  }

  String toCapitalCase(String title) {
    if (title.isEmpty) return title;
    return title[0].toUpperCase() + title.substring(1).toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    final payment = context.watch<PaymentManager>();
    final myFunctions = context.watch<MyFunctions>();
    if (!payment.isReady) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: myAppBar(context, 'Thanh toán'),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          // mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Chọn ngân hàng',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 60,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: banks.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final bank = banks[index];
                  final bool isSelected = bank['name'] == bankname;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        bankname = bank['name']!;
                        bankcode = bank['code']!;
                      });

                      context.read<PaymentManager>().updateBank(
                        bankname,
                        bankcode,
                      );
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.brown.shade50 : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected
                              ? Colors.green
                              : Colors.grey.shade300,
                          width: 2,
                        ),
                      ),
                      child: Image.asset(
                        bank['assets']!,
                        width: 150,
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 40),
            Center(
              child: Column(
                children: [
                  const Text(
                    'Thông tin thanh toán',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    bankname,
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w700,
                      fontSize: 30,
                    ),
                  ),
                  Text(
                    bankcode,
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                    ),
                  ),
                  Text(
                    'Số tiền: ' +
                        myFunctions.convertToVND(payment.amount.toString()) +
                        'VND',
                    // plan + " - " + amount.toString(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.black45,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        payment.note,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.black45,
                        ),
                      ),
                      svgButton('assets/icons/copy.svg', '', 'black', () {
                        Clipboard.setData(
                          ClipboardData(
                            text:
                                payment.bankName +
                                " | " +
                                payment.bankAccount +
                                " | " +
                                payment.amount.toString() +
                                " | " +
                                payment.note,
                          ),
                        );

                        snackBarLogger(
                          context,
                          'Đã sao chép nội dung thanh toán',
                          'success',
                        );
                      }),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.green, width: 2),
                    ),
                    child: QrImageView(
                      data: payment.qrData,
                      size: 220,
                      backgroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                button('Đến trang chủ', 'normal', () {
                  context.push('/driver-page');
                  snackBarLogger(context, 'Đã sao chép mã!', 'success');
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

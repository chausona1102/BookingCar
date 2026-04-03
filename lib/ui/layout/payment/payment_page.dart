import 'package:booking_app/services/paypal_service.dart';
import 'package:booking_app/ui/layout/payment/paypal_webview_page.dart';
import 'package:booking_app/ui/shared/snackBarLogger.dart';
import 'package:booking_app/utils/myFunction.dart';
import '../../auth/auth_manager.dart';
import 'package:booking_app/ui/shared/svgButton.dart';
import 'package:flutter/services.dart';
import 'package:booking_app/models/vipdata.dart';
import 'package:booking_app/ui/shared/myAppBar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'payment_manager.dart';
import '../customer/bank_manager.dart';
import 'package:booking_app/ui/shared/button.dart';
import 'package:go_router/go_router.dart';
import 'package:booking_app/ui/auth/customer_manager.dart';
import 'package:booking_app/models/membership.dart';

class PaymentPage extends StatefulWidget {
  final Vipdata data;
  const PaymentPage({super.key, required this.data});
  @override
  State<StatefulWidget> createState() => _PaymentState();
}

class _PaymentState extends State<PaymentPage> {
  var bankname = 'Agribank';
  var bankcode = '10890013';
  Membership? membership;
  bool _isMemberShips = false;
  String? plan;
  String? discountPercent;
  @override
  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      // tạo payment
      context.read<PaymentManager>().createPayment(
        widget.data,
        bankname,
        bankcode,
      );

      // check membership
      final authManager = context.read<AuthManager>();
      final customerManager = context.read<CustomerManager>();
      final userId = authManager.currentUserId;

      if (userId != null) {
        try {
          final record = await customerManager.getMembership(user: userId);
          if (!mounted) return;
          setState(() {
            membership = record;
            _isMemberShips = true;
          });
          // print(records); // có record
        } catch (e) {
          print('Exception: $e');
        }
      } else {
        print('Invalid userId value');
      }
    });
  }

  Future<void> _handlePaypal() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final result = await PaypalService.createOrder(
      amount: (widget.data.amount / 25000).toDouble(),
      description: 'Membership - ${widget.data.plan}',
    );

    if (!mounted) return;
    Navigator.pop(context);
    if (result == null) {
      snackBarLogger(context, 'Không thể kết nối PayPal', 'error');
      return;
    }

    // Mở WebView PayPal
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaypalWebviewPage(
          approvalUrl: result['approvalUrl'],
          orderId: result['orderId'],
          onSuccess: (data) async {
            Navigator.pop(context);

            // Lưu membership
            final authManager = context.read<AuthManager>();
            final success = await context
                .read<PaymentManager>()
                .addMemeberShips(
                  user: authManager.currentUserId!,
                  plan: widget.data.plan,
                  discountpercent: widget.data.discountPercent,
                );

            if (!mounted) return;
            if (success) {
              context.go('/payment-success');
            } else {
              snackBarLogger(context, 'Lưu thông tin thất bại', 'error');
            }
          },
          onCancel: () {
            Navigator.pop(context);
            snackBarLogger(context, 'Đã hủy thanh toán PayPal', 'warning');
          },
        ),
      ),
    );
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
    if (_isMemberShips) {
      return Scaffold(
        appBar: myAppBar(context, 'Thành viên'),
        body: Container(
          color: Colors.green.shade100,
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/images/app_icon.png', width: 200),
                  Text(
                    'Bạn đã là thanh viên của rùa nhỏ',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  button('Quay lại trang chủ', 'success', () {
                    context.go('/');
                  }),
                  const SizedBox(width: 10),
                  button('Nâng cấp độ thành viên', 'normal', () {
                    snackBarLogger(
                      context,
                      'Tính năng chưa được cập nhật',
                      'warning',
                    );
                  }),
                ],
              ),
            ],
          ),
        ),
      );
    } else {
      return Scaffold(
        appBar: myAppBar(context, 'Thanh toán'),
        body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          // width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            // mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Thoanh toán quốc tế',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ElevatedButton.icon(
                    onPressed: _handlePaypal,
                    icon: Image.asset('assets/images/paypal.png', width: 20),
                    label: Text(
                      'PayPal',
                      style: TextStyle(
                        fontSize: 18,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF003087),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'Thanh toán nội địa',
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
                          color: isSelected
                              ? Colors.brown.shade50
                              : Colors.white,
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
              const SizedBox(height: 30),
              Center(
                child: Column(
                  children: [
                    const Text(
                      'Thông tin thanh toán',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
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
                  button('Sao chép mã', 'normal', () {
                    Clipboard.setData(ClipboardData(text: payment.qrData));

                    snackBarLogger(context, 'Đã sao chép mã!', 'success');
                  }),
                  const SizedBox(width: 20),
                  button('Thanh toán', 'success', () async {
                    final authManager = context.read<AuthManager>();
                    final payment = context.read<PaymentManager>();
                    final userId = authManager.currentUserId;
                    final success = await payment.addMemeberShips(
                      user: userId!,
                      plan: widget.data.plan,
                      discountpercent: widget.data.discountPercent,
                    );

                    if (!mounted) return;

                    if (success) {
                      context.go('/payment-success');
                    } else {
                      snackBarLogger(context, 'Thanh toán thất bại', 'error');
                    }
                  }),
                ],
              ),
            ],
          ),
        ),
      );
    }
  }
}

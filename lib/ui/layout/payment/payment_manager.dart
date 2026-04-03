import 'package:booking_app/models/booking.dart';
import 'package:flutter/material.dart';
import 'package:booking_app/models/vipdata.dart';
import 'package:booking_app/services/customer_service.dart';

class PaymentManager extends ChangeNotifier {
  final CustomerService _customerService = CustomerService();
  bool _initialized = false;

  String transactionId = '';
  String bankName = '';
  String bankAccount = '';
  int amount = 0;
  String note = '';

  void createPayment(Vipdata data, bankname, bankcode) {
    transactionId = _generateTransactionId();
    bankName = bankname.toString();
    bankAccount = bankcode.toString();
    amount = data.amount;
    note = 'VIP_${data.plan.toUpperCase()}_$transactionId';

    _initialized = true;
    notifyListeners();
  }

  void createPaymentBooking(BookingModel booking, bankname, bankcode) {
    transactionId = _generateTransactionId();
    bankName = bankname.toString();
    bankAccount = bankcode.toString();
    amount = booking.price.toInt();
    note = 'trip_${booking.id.toString()}_$transactionId';

    _initialized = true;
    notifyListeners();
  }

  void updateBank(bankname, bankcode) {
    bankName = bankname;
    bankAccount = bankcode;
    notifyListeners();
  }

  bool get isReady => _initialized;

  String get paymentText {
    if (!_initialized) return '';
    return '''
Mã giao dịch: $transactionId
Ngân hàng: $bankName
Số tài khoản: $bankAccount
Số tiền: $amount VNĐ
Nội dung: $note
''';
  }

  String get qrData {
    if (!_initialized) return '';
    return '$bankName|$bankAccount|$amount|$note';
  }

  String _generateTransactionId() {
    return 'TX${DateTime.now().millisecondsSinceEpoch}';
  }

  Future<bool> addMemeberShips({
    required String user,
    required String plan,
    required int discountpercent,
  }) async {
    return await _customerService.addMemberShip(
      user: user,
      plan: plan,
      discountpercent: discountpercent,
    );
  }
}

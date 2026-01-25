import 'package:booking_app/models/vipdata.dart';
import 'package:booking_app/ui/shared/button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:booking_app/ui/shared/myappbar.dart';

class BecomeVipMemberPage extends StatefulWidget {
  const BecomeVipMemberPage({super.key});

  @override
  State<BecomeVipMemberPage> createState() => _BecomeVipMemberPageState();
}

class _BecomeVipMemberPageState extends State<BecomeVipMemberPage> {
  var _levelMember = 'silver';
  var _discountPercent = 30;
  var _amount = 100000;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: myAppBar(context, 'Đăng ký hội viên'),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Chọn cấp bậc",
              style: TextStyle(
                color: Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Row(
              children: [
                Radio<String>(
                  value: 'silver',
                  groupValue: _levelMember,
                  focusColor: Colors.green,
                  onChanged: (String? value) {
                    setState(() {
                      _discountPercent = 30;
                      _amount = 100000;
                      _levelMember = value.toString();
                    });
                  },
                ),
                Text('Bạc', style: TextStyle(color: Colors.black)),
                const SizedBox(width: 10),
                Radio<String>(
                  value: 'gold',
                  groupValue: _levelMember,
                  focusColor: Colors.green,
                  onChanged: (String? value) {
                    setState(() {
                      _discountPercent = 40;
                      _amount = 150000;
                      _levelMember = value.toString();
                    });
                  },
                ),
                Text('Vàng', style: TextStyle(color: Colors.black)),
                const SizedBox(width: 10),
                Radio<String>(
                  value: 'platinum',
                  groupValue: _levelMember,
                  focusColor: Colors.green,
                  onChanged: (String? value) {
                    setState(() {
                      _amount = 200000;
                      _discountPercent = 50;
                      _levelMember = value.toString();
                    });
                  },
                ),
                Text('Bạch kim', style: TextStyle(color: Colors.black)),
                const SizedBox(width: 10),
              ],
            ),
            // End choose plan
            const SizedBox(height: 10),
            Row(
              children: [
                Text(
                  'Mức ưu đãi: ',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                ),
                Text(
                  _discountPercent.toString() + '%',
                  style: TextStyle(
                    color: const Color.fromARGB(255, 0, 167, 6),
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Điều khoản khuyến mãi
            // Code </>
            // Thay thế phần comment "// Điều khoản khuyến mãi" bằng code sau:
            Container(
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Điều khoản ưu đãi',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildTermItem(
                    'Thời hạn sử dụng: 3 tháng kể từ ngày đăng ký',
                  ),
                  _buildTermItem('Được tích điểm với mỗi lần đặt'),
                  _buildTermItem(
                    'Ưu đãi áp dụng cho tất cả dịch vụ trong hệ thống',
                  ),
                  _buildTermItem(
                    'Không áp dụng đồng thời với các chương trình khuyến mãi khác',
                  ),
                  _buildTermItem(
                    'Thẻ hội viên không được chuyển nhượng cho người khác',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        child: Row(
          children: [
            Text(
              'Tổng số tiền:',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
            ),
            const SizedBox(width: 10),
            Text(
              _amount.toString() + ' đồng',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 20,
                color: Colors.redAccent.shade400,
              ),
            ),
            const Spacer(),
            button(
              'Thanh toán',
              'success',
              () => context.push(
                '/payment-page',
                extra: Vipdata(
                  plan: _levelMember,
                  discountPercent: _discountPercent,
                  amount: _amount,
                ),
              ),
            ),
          ],
        ),
      ),
      // floatingActionButton: const FloatingActionButton(onPressed: null),
    );
  }
}

Widget _buildTermItem(String text) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8.0),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.check_circle, size: 16, color: Colors.green),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 14, color: Colors.black87, height: 1.4),
          ),
        ),
      ],
    ),
  );
}

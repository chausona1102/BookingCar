import 'package:booking_app/ui/shared/myAppBar.dart';
import 'package:flutter/material.dart';

class DriverRequestManagerPage extends StatefulWidget {
  const DriverRequestManagerPage({super.key});

  @override
  State<DriverRequestManagerPage> createState() =>
      _DriverRequestManagerPageState();
}

class _DriverRequestManagerPageState extends State<DriverRequestManagerPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: myAppBar(context, 'Đơn đăng ký làm tài xế'),
      body: Center(child: Text('DriverRequestManagerPage')),
    );
  }
}

import 'package:booking_app/ui/shared/myAppBar.dart';
import 'package:flutter/material.dart';

class BookingsManagerPage extends StatefulWidget {
  const BookingsManagerPage({super.key});

  @override
  State<BookingsManagerPage> createState() => _BookingsManagerPageState();
}

class _BookingsManagerPageState extends State<BookingsManagerPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: myAppBar(context, "Quản lý đơn hàng"),
      body: Center(child: Text('BookingsManagerPage')),
    );
  }
}

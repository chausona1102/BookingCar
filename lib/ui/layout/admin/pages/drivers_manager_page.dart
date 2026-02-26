import 'package:booking_app/ui/shared/myAppBar.dart';
import 'package:flutter/material.dart';

class DriversManagerPage extends StatefulWidget {
  const DriversManagerPage({super.key});

  @override
  State<DriversManagerPage> createState() => _DriversManagerPageState();
}

class _DriversManagerPageState extends State<DriversManagerPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: myAppBar(context, 'Quản lý tài xế') ,body: Center(child: Text('DriversManagerPage')));
  }
}

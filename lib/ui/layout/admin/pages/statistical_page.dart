import 'package:booking_app/ui/shared/myAppBar.dart';
import 'package:flutter/material.dart';

class StatisticalPage extends StatefulWidget {
  const StatisticalPage({super.key});

  @override
  State<StatisticalPage> createState() => _StatisticalPageState();
}

class _StatisticalPageState extends State<StatisticalPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: myAppBar(context, 'Thống kê'),
      body: Center(child: Text('StatisticalPage')),
    );
  }
}

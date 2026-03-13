import 'package:booking_app/models/driverrequest.dart';
import 'package:booking_app/ui/shared/avatarCircle.dart';
import 'package:booking_app/ui/shared/buildRowInfo.dart';
import 'package:booking_app/ui/shared/buttonPro.dart';
import 'package:booking_app/ui/shared/myAppBar.dart';
import 'package:booking_app/ui/shared/snackBarLogger.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'dart:io';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../auth/auth_manager.dart';
import '../../auth/customer_manager.dart';

enum TypeCar { car, motorbike }

class BecomeDriverPage extends StatefulWidget {
  const BecomeDriverPage({super.key});

  @override
  State<BecomeDriverPage> createState() => _BecomeDriverPage();
}

class _BecomeDriverPage extends State<BecomeDriverPage> {
  final _licensenumber = TextEditingController();
  final _carnumber = TextEditingController();
  late final CustomerManager manager;
  late final AuthManager authManager;
  DriverRequest? myRequest;
  TypeCar? _selectedTypeCar;

  File? _carimage;
  bool _isLoadingPage = true;
  bool _isLoadingButton = false;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _carimage = File(image.path);
      });
    }
  }

  Future<void> _register() async {
    final userId = authManager.currentUserId;

    if (userId == null) {
      snackBarLogger(context, 'Chưa đăng nhập!', 'warning');
      context.go('/login');
      return;
    }

    if (_selectedTypeCar == null) {
      snackBarLogger(context, 'Vui lòng chọn loại phương tiện', 'warning');
      return;
    }

    setState(() => _isLoadingButton = true);

    try {
      final success = await manager.addDriverRequest(
        licensenumber: _licensenumber.text.trim(),
        typecar: _selectedTypeCar!.name,
        user: userId,
        carimage: _carimage,
        carnumber: _carnumber.text.trim(),
      );

      if (!mounted) return;

      if (success) {
        snackBarLogger(context, 'Rùa nhỏ chào mừng rùa newbie!', 'success');
        context.go('/profile');
      } else {
        snackBarLogger(context, 'Đăng ký thất bại!', 'warning');
      }
    } finally {
      if (mounted) setState(() => _isLoadingButton = false);
    }
  }

  @override
  void initState() {
    super.initState();
    manager = context.read<CustomerManager>();
    authManager = context.read<AuthManager>();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final request = await manager.fetchRequestByUserID(
        authManager.currentUserId!,
      );
      if (mounted) {
        setState(() {
          myRequest = request;
          _isLoadingPage = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingPage) {
      return const Scaffold(
        body: Center(child: SpinKitCircle(color: Colors.green)),
      );
    }

    if (myRequest != null) {
      return Scaffold(
        appBar: myAppBar(context, 'Đăng ký làm tài xế'),
        backgroundColor: Colors.green.shade50,
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
          child: Column(
            children: [
              Center(child: avatarCircle(myRequest!.user, 90)),
              const SizedBox(height: 20),
              buildRowInfo('Họ và tên: ', myRequest!.user.fullName),
              const SizedBox(height: 10),
              buildRowInfo('Email: ', myRequest!.user.emailText),
              const SizedBox(height: 10),
              buildRowInfo('SĐT: ', myRequest!.user.phoneNumber),
              const SizedBox(height: 10),
              buildRowInfo('SH bằng lái: ', myRequest!.licensenumber),
              const SizedBox(height: 10),
              buildRowInfo('Biển số xe: ', myRequest!.carnumber),
              const SizedBox(height: 10),
              buildRowInfo('Trạng thái: ', myRequest!.getStatus),
              const SizedBox(height: 10),
              if (myRequest!.createat != null)
                buildRowInfo('Ngày gửi đơn: ', myRequest!.createTimeFormatted),
              const SizedBox(height: 10),
              if (myRequest!.updated != null)
                buildRowInfo(
                  'Cập nhật lần cuối: ',
                  myRequest!.updateTimeFormatted,
                ),

              if (myRequest!.status == 'cancelled') ...[
                const SizedBox(height: 20),
                buttonPro('Gửi lại yêu cầu', 'success', () async {
                  final success = await manager.retryDriverRequest(
                    myRequest!.id,
                  );
                  if (!success) {
                    snackBarLogger(context, 'Thất bại', 'error');
                  }
                  snackBarLogger(context, 'Đã gửi lại yêu cầu', 'success');
                  setState(() => _isLoadingPage = true);
                  final request = await manager.fetchRequestByUserID(
                    authManager.currentUserId!,
                  );
                  if (mounted) {
                    setState(() {
                      myRequest = request;
                      _isLoadingPage = false;
                    });
                  }
                }),
              ],
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: myAppBar(context, 'Đăng ký làm tài xế'),
      backgroundColor: Colors.green.shade50,
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 60),
                const Text(
                  'Đăng ký làm tài xế',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: _licensenumber,
                  decoration: const InputDecoration(
                    labelText: 'Số hiệu bằng lái',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(
                      Icons.card_membership,
                      color: Colors.green,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<TypeCar>(
                  value: _selectedTypeCar,
                  decoration: const InputDecoration(
                    labelText: 'Loại phương tiện',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.directions_car, color: Colors.green),
                  ),
                  items: const [
                    DropdownMenuItem(value: TypeCar.car, child: Text('Ô tô')),
                    DropdownMenuItem(
                      value: TypeCar.motorbike,
                      child: Text('Xe máy'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedTypeCar = value);
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _carnumber,
                  decoration: const InputDecoration(
                    labelText: 'Biển số xe (67-F1 58113)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.numbers, color: Colors.green),
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 45,
                    backgroundColor: Colors.green.shade200,
                    backgroundImage: _carimage != null
                        ? FileImage(_carimage!)
                        : null,
                    child: _carimage == null
                        ? const Icon(
                            Icons.camera_alt,
                            size: 30,
                            color: Colors.white,
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: _isLoadingButton
                      ? const SpinKitFadingCircle(color: Colors.green, size: 30)
                      : ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade300,
                            foregroundColor: Colors.white,
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: _register,
                          child: const Text('Đăng ký'),
                        ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => context.go('/profile'),
                    child: const Text('Hủy bỏ'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'dart:io';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../auth/auth_manager.dart';
import '../../auth/customer_manager.dart';
// import 'package:image_picker/image_picker.dart';

enum TypeCar { car, motorbike }

class BecomeDriverPage extends StatefulWidget {
  const BecomeDriverPage({super.key});

  @override
  State<BecomeDriverPage> createState() => _BecomeDriverPage();
}

class _BecomeDriverPage extends State<BecomeDriverPage> {
  final _licensenumber = TextEditingController();

  TypeCar? _selectedTypeCar;

  File? _carimage;
  bool _isLoading = false;
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
    final authManager = context.read<AuthManager>();
    final userId = authManager.currentUserId;

    if (userId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Chưa đăng nhập')));
      context.go('/login');
      return;
    }

    if (_selectedTypeCar == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn loại phương tiện')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final success = await context.read<CustomerManager>().addDriver(
        licensenumber: _licensenumber.text.trim(),
        typecar: _selectedTypeCar!.name,
        user: userId,
        carimage: _carimage,
      );
      print(_licensenumber.text.trim());
      print(_selectedTypeCar!.name);
      print(userId);
      print(_carimage);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Đăng ký thành công' : 'Đăng ký thất bại'),
        ),
      );

      if (success) context.go('/profile');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade50,
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 60),
                Text(
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
                    prefixIcon: Icon(Icons.email, color: Colors.green),
                  ),
                ),
                const SizedBox(height: 16),
                // tài khoản
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
                    setState(() {
                      _selectedTypeCar = value;
                    });
                  },
                ),
                // Them enum car ở đây!
                const SizedBox(height: 16),
                // mật khẩu
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
                // nút đăng nhập
                SizedBox(
                  width: double.infinity,
                  child: _isLoading
                      ? SpinKitFadingCircle(color: Colors.green, size: 30)
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
                    onPressed: () {
                      context.go('/profile');
                    },
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

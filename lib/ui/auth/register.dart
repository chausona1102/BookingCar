import 'auth_manager.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  // final AuthService _authService = AuthService();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _firstnameController = TextEditingController();
  final _lastnameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? _avatar;
  bool _isLoading = false;

  Future<void> _pickAvatar() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _avatar = File(image.path);
      });
    }
  }

  // Future<void> _register() async {
  //   setState(() => _isLoading = true);
  //   final email = _emailController.text.trim();
  //   final username = _usernameController.text.trim();
  //   final phone = _phoneController.text.trim();
  //   final firstname = _firstnameController.text.trim();
  //   final lastname = _lastnameController.text.trim();
  //   final password = _passwordController.text.trim();
  //   final passwordConfirm = _passwordConfirmController.text.trim();
  //   if (password != passwordConfirm) {
  //     setState(() {
  //       _isLoading = false;
  //     });
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text("Mật khẩu xác nhận không khớp!")),
  //     );
  //     return;
  //   }
  //   final success = await _authService.register(
  //     email: email,
  //     username: username,
  //     firstname: firstname,
  //     lastname: lastname,
  //     phone: phone,
  //     password: password,
  //     avatar: _avatar,
  //   );
  //   setState(() {
  //     _isLoading = false;
  //   });
  //   if (!mounted) return;
  //   if (success) {
  //     ScaffoldMessenger.of(
  //       context,
  //     ).showSnackBar(const SnackBar(content: Text("Đăng ký thành công!")));
  //     context.go('/login');
  //   } else {
  //     ScaffoldMessenger.of(
  //       context,
  //     ).showSnackBar(const SnackBar(content: Text("Đăng ký thất bại!")));
  //   }
  // }

  Future<void> _register() async {
    setState(() => _isLoading = true);

    final email = _emailController.text.trim();
    final username = _usernameController.text.trim();
    final phone = _phoneController.text.trim();
    final firstname = _firstnameController.text.trim();
    final lastname = _lastnameController.text.trim();
    final password = _passwordController.text.trim();
    final passwordConfirm = _passwordConfirmController.text.trim();

    try {
      final authManager = context.read<AuthManager>();

      final success = await authManager.register(
        email: email,
        username: username,
        firstname: firstname,
        lastname: lastname,
        phone: phone,
        password: password,
        passwordConfirm: passwordConfirm,
        avatar: _avatar,
      );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Đăng ký thành công!")));
        context.go('/login');
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Đăng ký thất bại!")));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
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
                  'Booking Car',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 3,
                  ),
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email, color: Colors.green),
                  ),
                ),
                const SizedBox(height: 16),
                // tài khoản
                TextField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Tài khoản',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person, color: Colors.green),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Số điện thoại',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phone, color: Colors.green),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: _firstnameController,
                        decoration: const InputDecoration(
                          labelText: 'Họ và tên đệm',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person, color: Colors.green),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 1,
                      child: TextField(
                        controller: _lastnameController,
                        decoration: const InputDecoration(
                          labelText: 'Tên',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // mật khẩu
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Mật khẩu',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock, color: Colors.green),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordConfirmController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Nhập lại mật khẩu',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock, color: Colors.green),
                  ),
                ),
                const SizedBox(height: 24),

                GestureDetector(
                  onTap: _pickAvatar,
                  child: CircleAvatar(
                    radius: 45,
                    backgroundColor: Colors.green.shade200,
                    backgroundImage: _avatar != null
                        ? FileImage(_avatar!)
                        : null,
                    child: _avatar == null
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
                      context.go('/login');
                    },
                    child: const Text('Quay lại đăng nhập'),
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

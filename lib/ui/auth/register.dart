import 'package:booking_app/ui/shared/snackBarLogger.dart';
import 'package:booking_app/ui/shared/textFieldForm.dart';
import 'package:booking_app/validator/validator.dart';

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
  bool obscureTextPass = true;
  bool obscureTextConfirmPass = true;

  Future<void> _pickAvatar() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _avatar = File(image.path);
      });
    }
  }

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
        context: context,
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
        snackBarLogger(context, 'Đăng ký thành công', 'success');
        context.go('/login');
      } else {
        snackBarLogger(context, 'Đăng ký thất bại', 'warning');
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

  void showPass(String field) {
    switch (field) {
      case 'pass':
        obscureTextPass = !obscureTextPass;
        break;
      case 'confirmpass':
        obscureTextConfirmPass = !obscureTextConfirmPass;
        break;
      default:
        obscureTextPass = !obscureTextPass;
    }
  }

  bool validator() {
    return context.read<Validator>().validator(
      context,
      _emailController,
      _usernameController,
      _phoneController,
      _firstnameController,
      _lastnameController,
      _passwordController,
      _avatar,
    );
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
                textFieldForm(_emailController, 'Email', Icons.email, false),
                const SizedBox(height: 16),
                textFieldForm(
                  _usernameController,
                  'Tài khoản',
                  Icons.person,
                  false,
                ),
                const SizedBox(height: 16),
                textFieldForm(
                  _phoneController,
                  'Số điện thoại',
                  Icons.phone,
                  false,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: textFieldForm(
                        _firstnameController,
                        'Họ và tên đệm',
                        Icons.person,
                        false,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      flex: 1,
                      child: textFieldForm(
                        _lastnameController,
                        'Tên',
                        Icons.person,
                        false,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Stack(
                  children: [
                    TextField(
                      controller: _passwordController,
                      obscureText: obscureTextPass,
                      cursorColor: Colors.green,
                      decoration: const InputDecoration(
                        labelText: 'Mật khẩu',
                        labelStyle: TextStyle(color: Colors.black38),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.green, width: 1),
                        ),
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.lock, color: Colors.green),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      bottom: 0,
                      right: 10,
                      child: IconButton(
                        onPressed: () {
                          setState(() {
                            showPass('pass');
                          });
                        },
                        icon: obscureTextPass
                            ? Icon(Icons.visibility_off, color: Colors.black26)
                            : Icon(Icons.remove_red_eye, color: Colors.black26),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                Stack(
                  children: [
                    TextField(
                      controller: _passwordConfirmController,
                      obscureText: obscureTextConfirmPass,
                      cursorColor: Colors.green,
                      decoration: const InputDecoration(
                        labelText: 'Nhập lại mật khẩu',
                        labelStyle: TextStyle(color: Colors.black38),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.green, width: 1),
                        ),
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.lock, color: Colors.green),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      bottom: 0,
                      right: 10,
                      child: IconButton(
                        onPressed: () {
                          setState(() {
                            showPass('confirmpass');
                          });
                        },
                        icon: obscureTextConfirmPass
                            ? Icon(Icons.visibility_off, color: Colors.black26)
                            : Icon(Icons.remove_red_eye, color: Colors.black26),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
                Center(
                  child: const Text(
                    'Ảnh đại diện',
                    style: TextStyle(
                      color: Colors.black54,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
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
                SizedBox(
                  width: double.infinity,
                  child: _isLoading
                      ? SpinKitFadingCircle(color: Colors.green, size: 30)
                      : ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade300,
                            foregroundColor: Colors.white,
                            elevation: 6,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: () {
                            if (validator()) {
                              _register();
                            } else {
                              return;
                            }
                          },
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
                    style: ElevatedButton.styleFrom(elevation: 6),
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

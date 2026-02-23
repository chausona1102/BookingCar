import 'package:booking_app/ui/shared/snackBarLogger.dart';
import 'package:booking_app/ui/shared/textFieldForm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'auth_manager.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool obscureText = true;
  bool _isLoading = false;

  final logger = Logger();

  Future<void> _login() async {
    setState(() => _isLoading = true);

    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    final authManager = context.read<AuthManager>();
    final success = await authManager.login(username, password);

    setState(() => _isLoading = false);

    if (success) {
      final role = authManager.role;

      snackBarLogger(context, 'Đăng nhập thành công!', 'success');

      if (role == 'driver') {
        context.go('/driver-page');
      } else if (role == 'customer') {
        context.go('/');
      } else if (role == 'admin') {
        context.go('/admin');
      } else {
        context.go('/NotFound');
      }
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Sai email hoặc mật khẩu')));
    }
  }

  void toggleShowPass() {
    obscureText = !obscureText;
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      backgroundColor: Colors.green.shade50,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Container(
                    width: isLandscape ? 400 : double.infinity,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Booking Car',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 3,
                          ),
                        ),
                        const SizedBox(height: 32),
                        textFieldForm(
                          _usernameController,
                          'Tài khoản',
                          Icons.person,
                          false,
                        ),
                        const SizedBox(height: 16),
                        Stack(
                          children: [
                            TextField(
                              controller: _passwordController,
                              obscureText: obscureText,
                              cursorColor: Colors.green,
                              decoration: const InputDecoration(
                                labelText: 'Mật khẩu',
                                labelStyle: TextStyle(color: Colors.black38),
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(
                                  Icons.lock,
                                  color: Colors.green,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.green,
                                    width: 1,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 0,
                              bottom: 0,
                              right: 10,
                              child: IconButton(
                                onPressed: () {
                                  setState(() {
                                    toggleShowPass();
                                  });
                                },
                                icon: obscureText
                                    ? Icon(
                                        Icons.visibility_off,
                                        color: Colors.black26,
                                      )
                                    : Icon(
                                        Icons.remove_red_eye,
                                        color: Colors.black26,
                                      ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        SizedBox(
                          width: double.infinity,
                          child: _isLoading
                              ? const SpinKitFadingCircle(
                                  color: Colors.green,
                                  size: 30,
                                )
                              : ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green.shade300,
                                    foregroundColor: Colors.white,
                                    elevation: 6,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    textStyle: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  onPressed: _login,
                                  child: const Text('Đăng nhập'),
                                ),
                        ),

                        const SizedBox(height: 10),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              context.go('/register');
                            },
                            style: ElevatedButton.styleFrom(elevation: 6),
                            child: const Text(
                              'Chưa có tài khoản? Đăng ký ngay!',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

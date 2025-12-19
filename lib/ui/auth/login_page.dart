import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
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

  bool _isLoading = false;

  Future<void> _login() async {
    setState(() => _isLoading = true);

    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    final authManager = context.read<AuthManager>();
    final success = await authManager.login(username, password);

    setState(() => _isLoading = false);

    if (success) {
      context.go('/');
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Sai email hoặc mật khẩu')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade50,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // const Icon(Icons.directions_car, size: 80, color: Colors.blue),
              // const SizedBox(height: 16),
              Text(
                'Booking Car',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: 32),

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
              const SizedBox(height: 24),

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
                        onPressed: _login,
                        child: const Text('Đăng nhập'),
                      ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    print('Go register');
                    context.go('/register');
                  },
                  child: const Text('Chưa có tài khoản? Đăng ký ngay!'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:booking_app/models/user.dart';
import 'package:booking_app/ui/auth/auth_manager.dart';
import 'package:booking_app/ui/notifications/notification_manager.dart';
import 'package:booking_app/ui/shared/snackBarMessage.dart';
import 'package:flutter/material.dart';
import 'package:logger/web.dart';
import 'package:provider/provider.dart';

class ChangePasswordOverlay extends StatefulWidget {
  const ChangePasswordOverlay({super.key});

  static Future<void> show(BuildContext context) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Đóng',
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (_, __, ___) => const ChangePasswordOverlay(),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        );
      },
    );
  }

  @override
  State<ChangePasswordOverlay> createState() => _ChangePasswordOverlayState();
}

class _ChangePasswordOverlayState extends State<ChangePasswordOverlay> {
  final _formKey = GlobalKey<FormState>();
  final _oldPassCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();

  final logger = Logger();

  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  late User user;
  @override
  void initState() {
    super.initState();
    user = context.read<AuthManager>().currentUser!;
  }

  @override
  void dispose() {
    _oldPassCtrl.dispose();
    _newPassCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final currentPass = _oldPassCtrl.text.trim();
    final newPass = _newPassCtrl.text.trim();

    final isCorrect = await context.read<AuthManager>().verify(
      user.userName,
      currentPass,
    );
    if (!mounted) return;

    if (!isCorrect) {
      setState(() => _isLoading = false);
      snackBarMessage(context, 'Mật khẩu hiện tại không đúng!', 'error');
      return;
    }

    final success = await context.read<AuthManager>().updatePassword(
      oldPassword: currentPass,
      newPassword: newPass,
    );
    if (!mounted) return;

    setState(() => _isLoading = false);

    if (!success) {
      snackBarMessage(context, 'Đổi mật khẩu thất bại, thử lại!', 'error');
      return;
    }

    context.read<NotificationManager>().addNotification(
      "Thông báo từ hệ thống",
      'success',
      "Đã đổi mật khẩu",
      user.id,
    );
    Navigator.of(context).pop();
    snackBarMessage(context, 'Đổi mật khẩu thành công!', 'success');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F5),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              color: const Color(0xFFF4F7F5),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    color: const Color(0xFF0F1923),
                  ),
                  const Expanded(
                    child: Text(
                      'Đổi mật khẩu',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F1923),
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),

                      Center(
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: const Color(0xFF00C853).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: const Icon(
                            Icons.lock_reset_rounded,
                            size: 40,
                            color: Color(0xFF00C853),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Center(
                        child: Text(
                          'Nhập thông tin bên dưới\nđể cập nhật mật khẩu',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                            height: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      _buildLabel('Mật khẩu hiện tại'),
                      const SizedBox(height: 8),
                      _buildPasswordField(
                        controller: _oldPassCtrl,
                        hint: 'Nhập mật khẩu hiện tại',
                        obscure: _obscureOld,
                        onToggle: () =>
                            setState(() => _obscureOld = !_obscureOld),
                        validator: (v) => (v == null || v.isEmpty)
                            ? 'Vui lòng nhập mật khẩu hiện tại'
                            : null,
                      ),
                      const SizedBox(height: 20),

                      _buildLabel('Mật khẩu mới'),
                      const SizedBox(height: 8),
                      _buildPasswordField(
                        controller: _newPassCtrl,
                        hint: 'Tối thiểu 8 ký tự',
                        obscure: _obscureNew,
                        onToggle: () =>
                            setState(() => _obscureNew = !_obscureNew),
                        validator: (v) {
                          if (v == null || v.isEmpty)
                            return 'Vui lòng nhập mật khẩu mới';
                          if (v.length < 8)
                            return 'Mật khẩu phải có ít nhất 8 ký tự';
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      _buildLabel('Xác nhận mật khẩu mới'),
                      const SizedBox(height: 8),
                      _buildPasswordField(
                        controller: _confirmPassCtrl,
                        hint: 'Nhập lại mật khẩu mới',
                        obscure: _obscureConfirm,
                        onToggle: () =>
                            setState(() => _obscureConfirm = !_obscureConfirm),
                        validator: (v) {
                          if (v == null || v.isEmpty)
                            return 'Vui lòng xác nhận mật khẩu';
                          if (v != _newPassCtrl.text)
                            return 'Mật khẩu không khớp';
                          return null;
                        },
                      ),
                      const SizedBox(height: 40),

                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleSubmit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00C853),
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: const Color(
                              0xFF00C853,
                            ).withOpacity(0.5),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : const Text(
                                  'Xác nhận đổi mật khẩu',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: Color(0xFF0F1923),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hint,
    required bool obscure,
    required VoidCallback onToggle,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator,
      style: const TextStyle(fontSize: 14, color: Color(0xFF0F1923)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF00C853), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.red.shade300),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.red.shade400, width: 1.5),
        ),
        suffixIcon: IconButton(
          onPressed: onToggle,
          icon: Icon(
            obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: Colors.grey.shade400,
            size: 20,
          ),
        ),
      ),
    );
  }
}

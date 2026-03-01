import 'dart:io';

import 'package:booking_app/models/driver.dart';
import 'package:booking_app/ui/layout/admin/manager/driver_admin_manager.dart';
import 'package:booking_app/ui/shared/snackBarLogger.dart';
import 'package:booking_app/ui/shared/snackBarMessage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/web.dart';
import 'package:provider/provider.dart';

class ChangeInfoDriverOverley extends StatefulWidget {
  final Driver driver;
  const ChangeInfoDriverOverley({super.key, required this.driver});
  static Future<Driver?> show(BuildContext context, Driver driver) {
    return showGeneralDialog<Driver>(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (_, __, ___) => ChangeInfoDriverOverley(driver: driver),
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
  State<ChangeInfoDriverOverley> createState() =>
      _ChangeInfoDriverOverleyState();
}

class _ChangeInfoDriverOverleyState extends State<ChangeInfoDriverOverley> {
  final _formKey = GlobalKey<FormState>();

  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _licenseCtrl = TextEditingController();
  final _numberCarCtrl = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  File? _carImage;

  final logger = Logger();

  bool _isLoading = false;

  late Driver driver;
  @override
  void initState() {
    super.initState();
    driver = widget.driver;

    _firstNameCtrl.text = driver.user.firstName ?? "";
    _lastNameCtrl.text = driver.user.lastName ?? "";
    _usernameCtrl.text = driver.user.userName;
    _emailCtrl.text = driver.user.email ?? "";
    _phoneCtrl.text = driver.user.phone ?? "";
    _licenseCtrl.text = driver.licensenumber;
    _numberCarCtrl.text = driver.carnumber;
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _pickCarImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _carImage = File(image.path);
      });
    } else {
      snackBarLogger(context, 'Ảnh không tồn tại', 'warning');
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    print('Handle Submit');
    final success = await context.read<DriverAdminManager>().update(
      id: driver.id,
      licenseNumber: _licenseCtrl.text.trim(),
      carNumber: _numberCarCtrl.text.trim(),
      carImage: _carImage,
    );
    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });
    if (!success) {
      snackBarMessage(context, "Cập nhật thất bại!", "error");
      return;
    }
    snackBarMessage(context, "Cập nhật thành công!", "success");
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    logger.i(driver.carImageURL);
    logger.i(driver.carimage);
    return Scaffold(
      // backgroundColor: const Color(0xFFF4F7F5),
      backgroundColor: Colors.green.shade50,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      _buildCarImageSection(),
                      const SizedBox(height: 30),
                      _buildInputCard(driver),
                      const SizedBox(height: 30),
                      _buildSaveButton(),
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

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
          ),
          const Expanded(
            child: Text(
              "Chỉnh sửa hồ sơ",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildInputCard(Driver driver) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildTextField("Username", _usernameCtrl, enable: false),
          const SizedBox(height: 16),
          _buildTextField("Email", _emailCtrl, enable: false),
          const SizedBox(height: 16),
          _buildTextField("Số điện thoại", _phoneCtrl, enable: false),
          const SizedBox(height: 16),
          _buildTextField("License Num:", _licenseCtrl, enable: true),
          const SizedBox(height: 16),
          _buildTextField("Car Num:", _numberCarCtrl, enable: true),
        ],
      ),
    );
  }

  Widget _buildCarImageSection() {
    return Column(
      children: [
        Stack(
          children: [
            GestureDetector(
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Colors.green.shade200,
                backgroundImage: _carImage != null
                    ? FileImage(_carImage!)
                    // ignore: unnecessary_null_comparison
                    : (driver.carimage != null && driver.carimage.isNotEmpty
                              ? NetworkImage(driver.carImageURL!)
                              : null)
                          as ImageProvider?,
                child:
                    (_carImage == null &&
                        // ignore: unnecessary_null_comparison
                        (driver.carimage == null || driver.carimage.isEmpty))
                    ? const Icon(
                        Icons.camera_alt,
                        size: 30,
                        color: Colors.white,
                      )
                    : null,
              ),
            ),
            Positioned(
              left: 0,
              bottom: 0,
              top: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black38,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: () {
                    _pickCarImage();
                  },
                  icon: Icon(Icons.edit_square, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          driver.user.fullName,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    required bool enable,
  }) {
    return TextFormField(
      controller: controller,
      validator: (v) {
        if (v == null || v.trim().isEmpty) {
          return "Không được để trống";
        }
        return null;
      },
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        enabled: enable,
        filled: true,
        fillColor: const Color(0xFFF4F7F5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00C853),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                "Lưu thay đổi",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }
}

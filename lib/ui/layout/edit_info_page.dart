import 'dart:async';
import 'dart:io';

import 'package:booking_app/models/user.dart';
import 'package:booking_app/ui/auth/auth_manager.dart';
import 'package:booking_app/ui/shared/myAppBar.dart';
import 'package:booking_app/ui/shared/snackBarLogger.dart';
import 'package:booking_app/ui/shared/textFieldForm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

class EditInfoPage extends StatefulWidget {
  const EditInfoPage({super.key});

  @override
  createState() => _EditInfoState();
}

class _EditInfoState extends State<EditInfoPage> {
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _firstnameController = TextEditingController();
  final _lastnameController = TextEditingController();
  final _phoneController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? _avatar;
  bool _isLoading = false;

  final logger = Logger();
  User? user;
  late AuthManager authManager;
  @override
  void initState() {
    super.initState();
    authManager = context.read<AuthManager>();
    user = authManager.currentUser;
    _usernameController.text = user?.userName ?? '';
    _firstnameController.text = user?.firstName ?? '';
    _lastnameController.text = user?.lastName ?? '';
    _phoneController.text = user?.phone ?? '';
    _emailController.text = user?.email ?? '';
  }

  Future<void> _pickAvatar() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _avatar = File(image.path);
      });
    } else {
      snackBarLogger(context, 'Ảnh không tồn tại', 'warning');
    }
  }

  Future<bool> _editedRequest(String id) async {
    setState(() => _isLoading = true);
    final phone = _phoneController.text.trim();
    final firstname = _firstnameController.text.trim();
    final lastname = _lastnameController.text.trim();
    logger.i('Request Editing');
    try {
      final success = await authManager.update(
        id: id,
        firstname: firstname,
        lastname: lastname,
        phone: phone,
        avatar: _avatar,
      );

      if (!mounted) return false;

      if (success) {
        snackBarLogger(context, 'Cập nhật thành công', 'success');
        context.go('/profile');
      } else {
        snackBarLogger(context, 'Cập nhật thất bại', 'warning');
      }
      return success;
    } catch (e) {
      logger.i('Error in State<EditInfoPage>_editedRequest', error: e);
      return false;
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
    @override
  void dispose() {
    _emailController.dispose();
    _firstnameController.dispose();
    _lastnameController.dispose();
    _usernameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    if (user == null) {
      return Scaffold(
        backgroundColor: Colors.green.shade50,
        appBar: myAppBar(context, 'Chỉnh sửa thông tin cá nhân'),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Spacer(),
              SpinKitCircle(color: Colors.green, size: 50.0),
              const SizedBox(height: 10),
              const Text('Đang tải...'),
              Spacer(),
            ],
          ),
        ),
      );
    } else {
      return Scaffold(
        backgroundColor: Colors.green.shade50,
        appBar: isLandscape ? null : myAppBar(context, 'Sửa thông tin cá nhân'),
        body: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (isLandscape) ...[
                      Container(
                        margin: const EdgeInsets.only(top: 10),
                        alignment: Alignment.topLeft,
                        child: FloatingActionButton(
                          backgroundColor: Colors.white,
                          elevation: 6,
                          onPressed: () {},
                          child: Icon(Icons.arrow_back, color: Colors.black45),
                        ),
                      ),
                    ],
                    Text(
                      'Ảnh đại diện',
                      style: TextStyle(
                        color: Colors.black54,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Stack(
                      children: [
                        GestureDetector(
                          child: CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.green.shade200,
                            backgroundImage: _avatar != null
                                ? FileImage(_avatar!)
                                : (user?.avatar != null &&
                                              user!.avatar!.isNotEmpty
                                          ? NetworkImage(user!.avatarUrl!)
                                          : null)
                                      as ImageProvider?,
                            child:
                                (_avatar == null &&
                                    (user?.avatar == null ||
                                        user!.avatar!.isEmpty))
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
                                _pickAvatar();
                              },
                              icon: Icon(
                                Icons.edit_square,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    textFieldForm(
                      _usernameController,
                      user!.userName,
                      Icons.person,
                      true,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          flex: 6,
                          child: textFieldForm(
                            _firstnameController,
                            user!.firstName!,
                            Icons.person,
                            false,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 4,
                          child: textFieldForm(
                            _lastnameController,
                            user!.lastName!,
                            Icons.person,
                            false,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    textFieldForm(
                      _phoneController,
                      user!.phone!,
                      Icons.phone,
                      false,
                    ),
                    const SizedBox(height: 10),
                    textFieldForm(
                      _emailController,
                      user!.email!,
                      Icons.mail,
                      true,
                    ),
                    const SizedBox(height: 20),
                    if (_isLoading) ...[
                      SpinKitCircle(color: Colors.green, size: 30),
                    ] else ...[
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 16,
                          ),
                          label: const Text(
                            'Hoàn tất',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                          onPressed: () {
                            _editedRequest(user!.id);
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(
                          Icons.cancel,
                          color: Colors.black,
                          size: 16,
                        ),
                        label: const Text(
                          'Hủy',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(elevation: 6),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }
  }
}

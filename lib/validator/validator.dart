import 'dart:io';
import 'package:booking_app/ui/shared/snackBarLogger.dart';
import 'package:flutter/material.dart';

class Validator extends ChangeNotifier {
  bool startsWithNumber(String text) {
    return RegExp(r'^\d').hasMatch(text);
  }

  bool containerUpercase(String text) {
    return RegExp(r'[A-Z]').hasMatch(text);
  }

  bool containerLowercase(String text) {
    return RegExp(r'[a-z]').hasMatch(text);
  }

  bool containerSpace(String text) {
    return RegExp(r'\s').hasMatch(text);
  }

  bool containeNumber(String text) {
    return RegExp(r'\d').hasMatch(text);
  }

  bool containsSpecialChar(String text) {
    return RegExp(r'[^a-zA-Z0-9]').hasMatch(text);
  }

  bool isNumber(String text) {
    return RegExp(r'^\d+$').hasMatch(text);
  }

  bool checkName(String text) {
    return RegExp(r'[!@#$%^&*(),.?":{}|<>_\-+=\[\]\\;/`~]').hasMatch(text);
  }

  bool validator(
    BuildContext context,
    TextEditingController emailController,
    TextEditingController usernameController,
    TextEditingController phoneController,
    TextEditingController firstnameController,
    TextEditingController lastnameController,
    TextEditingController passController,
    File? avatar,
  ) {
    final email = emailController.text.trim();
    final username = usernameController.text.trim();
    final phone = phoneController.text.trim();
    final firstname = firstnameController.text.trim();
    final lastname = lastnameController.text.trim();
    final password = passController.text.trim();

    if (email.isEmpty ||
        username.isEmpty ||
        firstname.isEmpty ||
        lastname.isEmpty ||
        phone.isEmpty ||
        password.isEmpty) {
      snackBarLogger(context, 'Không được bỏ trống', 'warning');
      return false;
    }

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,}$').hasMatch(email)) {
      snackBarLogger(context, 'Email không hợp lệ', 'warning');
      return false;
    }
    if (startsWithNumber(username)) {
      snackBarLogger(
        context,
        'Tên đăng nhập phải bắt đầu bằng chữ cái',
        'warning',
      );
      return false;
    }
    ;
    if (username.length < 4) {
      snackBarLogger(
        context,
        'Tên đăng nhập quá ngắn (ít nhất 4 ký tự)',
        'warning',
      );
      return false;
    } else if (containsSpecialChar(username)) {
      snackBarLogger(
        context,
        'Tên đăng nhập không chứa ký tự đặc biệt',
        'warning',
      );
      return false;
    }
    if (password.length < 8 || password.length > 255) {
      snackBarLogger(context, 'Mật khẩu quá ngắn (ít nhất 8 ký tự)', 'warning');
      return false;
    }
    if (!isNumber(phone)) {
      snackBarLogger(context, 'Số điện thoại chỉ được là số', 'warning');
      return false;
    }
    if (phone.length != 10) {
      snackBarLogger(context, 'Số điện thoại không hợp lệ', 'warning');
      return false;
    }
    if (!phone.startsWith('0')) {
      snackBarLogger(context, 'Số điện thoại phải bắt đầu bằng 0', 'warning');
      return false;
    }
    if (firstname.length < 2 || firstname.length > 255) {
      snackBarLogger(context, 'Họ và tên đệm không hợp lệ', 'warning');
      return false;
    }
    if (lastname.length > 255) {
      snackBarLogger(context, 'Tên không hợp lệ', 'warning');
      return false;
    }
    if (containeNumber(firstname) ||
        containeNumber(lastname) ||
        checkName(firstname) ||
        checkName(lastname)) {
      snackBarLogger(context, 'Họ và tên không hợp lệ', 'warning');
      return false;
    }
    if (!containeNumber(password) ||
        !containerLowercase(password) ||
        !containerUpercase(password)) {
      snackBarLogger(
        context,
        'Mật khẩu phải chứa số, chữ cái hoa, chữ cái thường',
        'warning',
      );
      return false;
    }
    if (avatar == null) {
      snackBarLogger(context, 'Chưa chọn ảnh', 'warning');
      return false;
    }
    return true;
  }
}

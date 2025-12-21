import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'pb_client.dart';

class CustomerService extends ChangeNotifier {
  PocketBase get pb => pocketBase;
  Future<bool> addDriver({
    required String licensenumber,
    required String typecar,
    required String user,
    File? carimage,
  }) async {
    // print(pb.authStore.isValid);
    // print(pb.authStore.model?.id);
    try {
      final body = {
        'licensenumber': licensenumber,
        'typecar': typecar,
        'user': user,
      };
      final files = <http.MultipartFile>[];
      if (carimage != null) {
        files.add(await http.MultipartFile.fromPath('carimage', carimage.path));
      }
      await pb.collection('drivers').create(body: body, files: files);
      return true;
    } catch (e) {
      print("Lỗi thêm tài xế: $e");
      return false;
    }
  }
}

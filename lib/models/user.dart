import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pocketbase/pocketbase.dart';

class User {
  final String id;
  final String username;
  final String? firstName;
  final String? lastName;
  final String role;
  final String? email;
  final String? phone;
  final String? avatar;
  final bool isActive;
  final DateTime createdAt;

  User({
    required this.id,
    required this.username,
    this.firstName,
    this.lastName,
    required this.role,
    this.email,
    this.phone,
    this.avatar,
    required this.isActive,
    required this.createdAt,
  });

  factory User.fromJson(dynamic source) {
    final json = source is RecordModel
        ? source.toJson()
        : source as Map<String, dynamic>;
    final id = source is RecordModel ? source.id : json['id'];

    return User(
      id: id ?? '',
      username: json['username'] ?? '',
      firstName: json['firstname'],
      lastName: json['lastname'],
      role: json['role'] ?? 'customer',
      email: json['email'],
      phone: json['phone'],
      avatar: json['avatar'],
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.tryParse(json['created'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'firstname': firstName,
      'lastname': lastName,
      'email': email,
      'role': role,
      'phone': phone,
      'avatar': avatar,
      'is_active': isActive,
    };
  }

  String? get avatarUrl {
    if (avatar == null || avatar!.isEmpty) return null;

    final baseUrl = dotenv.env['POCKETBASE_URL'];
    final collection = dotenv.env['POCKETBASE_COLLECTION'] ?? 'users';

    if (baseUrl == null || baseUrl.isEmpty) return null;

    return '$baseUrl/api/files/$collection/$id/$avatar';
  }

  String get fullName => '${firstName ?? ''} ${lastName ?? ''}'.trim();
  String get phoneNumber => phone?.trim() ?? "";
  String get emailText => email?.trim() ?? "";
  String get userId => id.trim();
  String get userName => username.trim();
  String get getRole {
    switch (role) {
      case 'customer':
        return 'khách hàng';
      case 'driver':
        return 'tài xế';
      case 'admin':
        return 'quản trị viên';
      default:
        return 'không xác định';
    }
  }

  User copyWith({
    String? id,
    String? username,
    String? firstName,
    String? lastName,
    String? role,
    String? email,
    String? phone,
    String? avatar,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      role: role ?? this.role,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatar: avatar ?? this.avatar,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

import 'package:booking_app/models/user.dart';
import 'package:booking_app/ui/layout/admin/manager/user_admin_manager.dart';
import 'package:booking_app/ui/layout/admin/pages/changeinfouseroverley.dart';
import 'package:booking_app/ui/shared/button.dart';
import 'package:booking_app/ui/shared/myAppBar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:logger/logger.dart';

class UsersManagerPage extends StatefulWidget {
  const UsersManagerPage({super.key});

  @override
  State<UsersManagerPage> createState() => _UsersManagerPageState();
}

class _UsersManagerPageState extends State<UsersManagerPage> {
  final logger = Logger();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<UserAdminManager>().fetchUserLimit();
      setState(() => _isLoading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final users = context.watch<UserAdminManager>().users;
    return Scaffold(
      appBar: myAppBar(context, 'Quản lý người dùng'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : users.isEmpty
          ? const Center(child: Text('Không có người dùng'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: users.length,
              itemBuilder: (context, index) => _buildRow(users[index]),
            ),
    );
  }

  Widget _buildRow(User user) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        onTap: () => _showAction(user),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: user.avatarUrl != null
              ? Image.network(
                  user.avatarUrl!,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _defaultAvatar(),
                )
              : _defaultAvatar(),
        ),
        title: Text(
          user.fullName.isNotEmpty ? user.fullName : user.userName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (user.emailText.isNotEmpty)
              Text(
                user.emailText,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            if (user.phoneNumber.isNotEmpty) Text(user.phoneNumber),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: user.role == 'driver'
                ? Colors.blue.shade100
                : Colors.green.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            user.getRole,
            style: TextStyle(
              color: user.role == 'driver' ? Colors.blue : Colors.green,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _defaultAvatar() {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.person, color: Colors.grey),
    );
  }

  void _showAction(User user) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              user.fullName.isNotEmpty ? user.fullName : user.userName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                button('Chỉnh sửa', 'warning', () {
                  Navigator.pop(context);
                  ChangeInfoUserOverley.show(context, user);
                }),
                const SizedBox(width: 8),
                button('Khóa tài khoản', 'error', () => print(user.id)),
                const SizedBox(width: 8),
                button('Xóa', 'error', () => print(user.id)),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

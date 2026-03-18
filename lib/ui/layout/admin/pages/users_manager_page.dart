import 'package:booking_app/models/user.dart';
import 'package:booking_app/ui/layout/admin/manager/user_admin_manager.dart';
import 'package:booking_app/ui/layout/admin/pages/changeinfouseroverley.dart';
import 'package:booking_app/ui/shared/buildRowInfo.dart';
import 'package:booking_app/ui/shared/buttonPro.dart';
import 'package:booking_app/ui/shared/myAppBar.dart';
import 'package:booking_app/ui/shared/snackBarLogger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
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
  late final UserAdminManager userManager;

  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  // Filter
  bool showFilter = false;
  bool sortName = false;
  bool sortDate = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      userManager = context.read<UserAdminManager>();
      await userManager.fetchUserLimit();
      setState(() => _isLoading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final users = context.watch<UserAdminManager>().users;
    return Scaffold(
      appBar: myAppBar(context, 'Quản lý người dùng'),
      backgroundColor: Colors.green.shade50,
      body: _isLoading
          ? const Center(child: SpinKitCircle(color: Colors.green))
          : Column(
              children: [
                _buildSearch(),
                if (_isSearching)
                  const Padding(
                    padding: EdgeInsets.all(8),
                    child: LinearProgressIndicator(),
                  ),
                const SizedBox(height: 10),
                _buildFilter(),
                const SizedBox(height: 5),
                _buildLength(users.length, userManager.isMaxLength),
                const SizedBox(height: 10),
                Expanded(
                  child: users.isEmpty
                      ? const Center(child: Text('Không có người dùng'))
                      : ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: users.length,
                          itemBuilder: (context, index) =>
                              _buildRow(users[index]),
                        ),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    userManager.fetchMoreUser();
                  },
                  child: Text(
                    'Xem thêm',
                    style: TextStyle(color: Colors.green),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
    );
  }

  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _searchController.text.isNotEmpty
                ? Colors.green.shade400
                : Colors.grey.shade200,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: _searchController.text.isNotEmpty
                  ? Colors.green.withOpacity(0.08)
                  : Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1A1A2E),
          ),
          onChanged: (value) async {
            setState(() {
              showFilter = false;
            });
            if (value.trim().isEmpty) {
              await userManager.fetchUserLimit();
              return;
            }
            setState(() => _isSearching = true);
            await userManager.search(value.trim());
            setState(() => _isSearching = false);
          },
          decoration: InputDecoration(
            hintText: 'Tìm theo tên, username, email...',
            hintStyle: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade400,
              fontWeight: FontWeight.w400,
            ),
            prefixIcon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                _searchController.text.isNotEmpty
                    ? Icons.manage_search_rounded
                    : Icons.search_rounded,
                key: ValueKey(_searchController.text.isNotEmpty),
                color: _searchController.text.isNotEmpty
                    ? Colors.green.shade500
                    : Colors.grey.shade400,
                size: 22,
              ),
            ),
            suffixIcon: _searchController.text.isNotEmpty
                ? GestureDetector(
                    onTap: () async {
                      _searchController.clear();
                      await userManager.fetchUserLimit();
                      setState(() {});
                    },
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        color: Colors.grey.shade500,
                        size: 16,
                      ),
                    ),
                  )
                : null,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 14,
              horizontal: 4,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLength(int length, bool isMax) {
    return Row(
      children: [
        const Spacer(),
        if (isMax) ...[
          Text('Số dòng $length/${userManager.getMaxLength} (max)'),
        ] else ...[
          Text('Số dòng $length'),
        ],
        const SizedBox(width: 20),
      ],
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
              ? _avatar(user.avatarUrl!, user.isActive)
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

  Widget _avatar(avatar, bool isActive) {
    // logger.i(isActive);
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            avatar,
            width: 50,
            height: 50,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 2,
          // left: 2,
          right: 2,
          child: Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: isActive ? Colors.green : Colors.grey,
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color.fromARGB(255, 255, 255, 255),
                width: 1,
              ),
            ),
          ),
        ),
      ],
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
            Row(
              children: [
                Spacer(),
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(
                    Icons.cancel,
                    color: Color.fromARGB(255, 243, 112, 103),
                  ),
                ),
              ],
            ),
            Center(
              child: Text(
                user.fullName.isNotEmpty ? user.fullName : user.userName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(height: 16),
            buildRowInfo('ID:', user.id),
            const SizedBox(height: 10),
            buildRowInfo('Tài khoản:', user.username),
            const SizedBox(height: 10),
            buildRowInfo('Email:', user.emailText),
            const SizedBox(height: 10),
            buildRowInfo('SĐT:', user.phoneNumber),
            const SizedBox(height: 10),
            buildRowInfo('Vai trò:', user.getRole.toUpperCase()),
            const SizedBox(height: 10),
            buildRowInfo('Trạng thái:', user.getStatus),
            const SizedBox(height: 20),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  buttonPro('✒️ Chỉnh sửa', 'success', () {
                    Navigator.pop(context);
                    ChangeInfoUserOverley.show(context, user);
                  }, filled: true),
                  const SizedBox(width: 8),
                  buttonPro('🔐 Khóa tài khoản', 'warning', () async {
                    final success = await userManager.toggleIsActive(user.id);
                    if (!success) {
                      snackBarLogger(context, "Thao tác thất bại", 'error');
                    }
                    Navigator.pop(context);
                    snackBarLogger(
                      context,
                      'Thao tác thành công với ${user.id}',
                      'success',
                    );
                  }, filled: true),
                  const SizedBox(width: 8),
                  buttonPro('🗑️ Xóa', 'error', () async {
                    final success = await userManager.deleteUserById(
                      context,
                      user.id,
                    );
                    if (!success) {
                      // snackBarLogger(context, "Xoá không thành công", 'error');
                      return;
                    }
                    snackBarLogger(
                      context,
                      'Đã xóa tài khoản ${user.id}',
                      'success',
                    );
                    Navigator.pop(context);
                    setState(() {
                      userManager.users.removeWhere((r) => r.id == user.id);
                    });
                  }, filled: true),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildFilter() {
    return Row(
      children: [
        const Spacer(),
        if (showFilter) ...[
          TextButton(
            onPressed: () {
              if (sortName) {
                userManager.sortUserByName('asc');
              } else {
                userManager.sortUserByName('desc');
              }
              setState(() {
                sortName = !sortName;
              });
            },
            child: Row(
              children: [
                Text('Name'),
                Icon(sortName ? Icons.expand_less : Icons.expand_more),
              ],
            ),
          ),
          const SizedBox(width: 10),
          TextButton(
            onPressed: () {
              if (sortDate) {
                userManager.sortUserByDate('asc');
              } else {
                userManager.sortUserByDate('desc');
              }
              setState(() {
                sortDate = !sortDate;
              });
            },
            child: Row(
              children: [
                Text('Date'),
                Icon(sortDate ? Icons.expand_less : Icons.expand_more),
              ],
            ),
          ),
          const SizedBox(width: 10),
        ],
        IconButton(
          onPressed: () {
            setState(() {
              showFilter = !showFilter;
            });
          },
          icon: Icon(Icons.filter_alt_outlined),
          style: IconButton.styleFrom(
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            side: BorderSide(color: Colors.black),
          ),
        ),
        const SizedBox(width: 10),
      ],
    );
  }
}

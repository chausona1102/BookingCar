import 'package:booking_app/models/driverrequest.dart';
import 'package:booking_app/ui/layout/admin/manager/driver_request_admin_manager.dart';
import 'package:booking_app/ui/layout/admin/manager/user_admin_manager.dart';
import 'package:booking_app/ui/shared/buttonPro.dart';
import 'package:booking_app/ui/shared/myAppBar.dart';
import 'package:booking_app/ui/shared/snackBarLogger.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

class DriverRequestManagerPage extends StatefulWidget {
  const DriverRequestManagerPage({super.key});

  @override
  State<DriverRequestManagerPage> createState() =>
      _DriverRequestManagerPageState();
}

class _DriverRequestManagerPageState extends State<DriverRequestManagerPage> {
  final logger = Logger();
  late final DriverRequestAdminManager requestManager;
  late final UserAdminManager userManager;
  bool _isLoading = true;

  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      requestManager = context.read<DriverRequestAdminManager>();
      userManager = context.read<UserAdminManager>();
      await requestManager.fetchRequestLimit();
      setState(() => _isLoading = false);
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final requests = context.watch<DriverRequestAdminManager>().requests;
    return Scaffold(
      appBar: myAppBar(context, 'Đơn đăng ký làm tài xế'),
      backgroundColor: Colors.green.shade50,
      body: _isLoading
          ? const CircularProgressIndicator(color: Colors.green)
          : Column(
              children: [
                _buildSearch(),
                if (_isSearching)
                  const Padding(
                    padding: EdgeInsets.all(8),
                    child: LinearProgressIndicator(),
                  ),
                Expanded(
                  child: requests.isEmpty
                      ? const Center(child: Text('Không có người dùng'))
                      : ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: requests.length,
                          itemBuilder: (context, index) =>
                              _buildRow(requests[index]),
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: TextField(
        controller: _searchController,
        onChanged: (value) async {
          if (value.trim().isEmpty) {
            await requestManager.fetchRequestLimit();
            return;
          }
          setState(() => _isSearching = true);
          await requestManager.search(value.trim());
          setState(() => _isSearching = false);
        },
        decoration: InputDecoration(
          hintText: 'Tìm theo tên, username, email...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () async {
                    _searchController.clear();
                    await requestManager.fetchRequestLimit();
                    setState(() {});
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey.shade100,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 0,
            horizontal: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildRow(DriverRequest request) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        onTap: () => {_showAction(request)},
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: request.user.avatarUrl != null
              ? _avatar(request.user.avatarUrl!, request.user.isActive)
              : _defaultAvatar(),
        ),
        title: Text(
          request.user.fullName.isNotEmpty
              ? request.user.fullName
              : request.user.userName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (request.user.emailText.isNotEmpty)
              Text(
                request.user.emailText,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            if (request.user.phoneNumber.isNotEmpty)
              Text(request.user.phoneNumber),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: request.status == 'accepted'
                ? Colors.green.shade100
                : request.status == 'cancelled'
                ? Colors.red.shade100
                : Colors.blue.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            request.getStatus,
            style: TextStyle(
              color: request.status == 'accepted'
                  ? Colors.green
                  : request.status == 'cancelled'
                  ? Colors.red
                  : Colors.blue,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _avatar(avatar, bool isActive) {
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

  void _showAction(DriverRequest request) {
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
            const SizedBox(height: 10),

            Center(
              child: Text(
                request.user.fullName.isNotEmpty
                    ? request.user.fullName
                    : request.user.userName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildRowInfo('Username:', request.user.username),
            const SizedBox(height: 10),
            _buildRowInfo('Email:', request.user.emailText),
            const SizedBox(height: 10),
            _buildRowInfo('Phone:', request.user.phoneNumber),
            const SizedBox(height: 10),
            _buildRowInfo('Status:', request.user.getStatus),
            const SizedBox(height: 10),
            _buildRowInfo('Bằng lái:', request.licensenumber),
            const SizedBox(height: 10),
            _buildRowInfo('Biển số:', request.carnumber),
            const SizedBox(height: 10),
            _buildRowInfo('Loại xe:', request.typeCar),
            const SizedBox(height: 10),
            Center(
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Colors.green.shade200,
                backgroundImage: NetworkImage(request.carImageURL!),
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: Text(
                'Ảnh xe',
                style: TextStyle(
                  color: Colors.black38,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 15),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (request.status == 'requested') ...[
                  Row(
                    children: [
                      buttonPro('✔️ Duyệt', 'success', () async {
                        final success = await requestManager
                            .updateStatusAccepted(
                              id: request.id,
                              status: 'accepted',
                              user: request.user.id,
                              licensenumber: request.licensenumber,
                              typecar: request.typecar,
                              carnumber: request.carnumber,
                              carImageURL: request.carImageURL,
                            );
                        if (!success) {
                          snackBarLogger(context, 'Cập nhật thất bại', 'error');
                          return;
                        }
                        snackBarLogger(
                          context,
                          'Cập nhật thành công',
                          'success',
                        );
                        Navigator.pop(context);
                        await requestManager.fetchRequestLimit();
                      }, filled: true),
                    ],
                  ),
                  const SizedBox(width: 8),
                  buttonPro('❌ Từ chối', 'warning', () async {
                    final success = await requestManager.updateStatusCancelled(
                      request.id,
                    );
                    if (!success) {
                      snackBarLogger(context, 'Cập nhật thất bại', 'error');
                      return;
                    }
                    snackBarLogger(context, 'Cập nhật thành công', 'success');
                    Navigator.pop(context);
                    await requestManager.fetchRequestLimit();
                  }, filled: true),
                ],
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildRowInfo(String title, String info) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          flex: 4,
          child: Text(
            title,
            style: TextStyle(
              color: Colors.black38,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
        Expanded(
          flex: 6,
          child: Text(
            info,
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:booking_app/models/driverrequest.dart';
import 'package:booking_app/ui/layout/admin/manager/driver_request_admin_manager.dart';
import 'package:booking_app/ui/shared/buildRowInfo.dart';
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
  bool _isLoading = true;

  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  // Filter
  bool showFilter = false;
  bool sortName = false;
  bool sortDate = false;
  var _status = "All";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      requestManager = context.read<DriverRequestAdminManager>();
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
                const SizedBox(height: 10),
                _buildFilter(),
                const SizedBox(height: 5),
                _buildLength(requests.length, requestManager.isMaxLength),
                const SizedBox(height: 10),
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
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    requestManager.fetchMoreRequest();
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
              await requestManager.fetchRequestLimit();
              return;
            }
            setState(() => _isSearching = true);
            await requestManager.search(value.trim());
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
                      await requestManager.fetchRequestLimit();
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
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
          child: SingleChildScrollView(
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
                buildRowInfo('Username:', request.user.username),
                const SizedBox(height: 10),
                buildRowInfo('Email:', request.user.emailText),
                const SizedBox(height: 10),
                buildRowInfo('Phone:', request.user.phoneNumber),
                const SizedBox(height: 10),
                buildRowInfo('Status:', request.user.getStatus),
                const SizedBox(height: 10),
                buildRowInfo('Bằng lái:', request.licensenumber),
                const SizedBox(height: 10),
                buildRowInfo('Biển số:', request.carnumber),
                const SizedBox(height: 10),
                buildRowInfo('Loại xe:', request.typeCar),
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
                              snackBarLogger(
                                context,
                                'Cập nhật thất bại',
                                'error',
                              );
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
                        final success = await requestManager
                            .updateStatusCancelled(request.id);
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
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilter() {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    return Row(
      children: [
        const Spacer(),
        if (showFilter) ...[
          TextButton(
            onPressed: () {
              if (sortName) {
                // driverManager.sortDriverByName('asc');
                requestManager.sortRequestByName('asc');
              } else {
                requestManager.sortRequestByName('desc');
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
                requestManager.sortRequestByDate('asc');
              } else {
                requestManager.sortRequestByDate('desc');
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
          SizedBox(
            width: isLandscape ? 200 : MediaQuery.of(context).size.width * 0.3,
            height: 40,
            child: DropdownMenu<String>(
              initialSelection: _status,
              menuHeight: 150,
              inputDecorationTheme: InputDecorationTheme(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 0,
                ),
                constraints: BoxConstraints(maxHeight: 40),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onSelected: (value) {
                setState(() => _status = value!);
                requestManager.filterByStatus(_status);
                // driverManager.filterByStatus(_status);
              },
              dropdownMenuEntries: [
                'All',
                'Chờ duyệt',
                'Từ chối',
                'Đã duyệt',
              ].map((e) => DropdownMenuEntry(value: e, label: e)).toList(),
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

  Widget _buildLength(int length, bool isMax) {
    return Row(
      children: [
        const Spacer(),
        if (isMax) ...[
          Text('Số dòng $length/${requestManager.getMaxLength} (max)'),
        ] else ...[
          Text('Số dòng $length'),
        ],
        const SizedBox(width: 20),
      ],
    );
  }
}

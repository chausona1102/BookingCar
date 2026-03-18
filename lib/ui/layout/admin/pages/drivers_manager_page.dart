import 'package:booking_app/models/driver.dart';
import 'package:booking_app/ui/layout/admin/manager/driver_admin_manager.dart';
import 'package:booking_app/ui/layout/admin/pages/changeinfodriveroverley.dart';
import 'package:booking_app/ui/shared/buildRowInfo.dart';
import 'package:booking_app/ui/shared/buttonPro.dart';
import 'package:booking_app/ui/shared/myAppBar.dart';
import 'package:booking_app/ui/shared/snackBarLogger.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:logger/logger.dart';

class DriversManagerPage extends StatefulWidget {
  const DriversManagerPage({super.key});

  @override
  State<DriversManagerPage> createState() => _DriversManagerPageState();
}

class _DriversManagerPageState extends State<DriversManagerPage> {
  final logger = Logger();
  bool _isLoading = true;
  late final DriverAdminManager driverManager;

  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  // Filter
  bool showFilter = false;
  bool sortName = false;
  bool sortDate = false;
  var _type = "All";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      driverManager = context.read<DriverAdminManager>();
      await driverManager.fetchDriverLimit();
      setState(() => _isLoading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    logger.i('Re-render');
    final drivers = context.watch<DriverAdminManager>().drivers;
    return Scaffold(
      appBar: myAppBar(context, 'Quản lý tài xế'),
      backgroundColor: Colors.green.shade50,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
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
                _buildLength(drivers.length, driverManager.isMaxLength),
                const SizedBox(height: 10),
                Expanded(
                  child: drivers.isEmpty
                      ? const Center(child: Text('Không có người dùng'))
                      : ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: drivers.length,
                          itemBuilder: (context, index) =>
                              _buildRow(drivers[index]),
                        ),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    driverManager.fetchMoreDriver();
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
              await driverManager.fetchDriverLimit();
              return;
            }
            setState(() => _isSearching = true);
            await driverManager.search(value.trim());
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
                      await driverManager.fetchDriverLimit();
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
                driverManager.sortDriverByName('asc');
              } else {
                driverManager.sortDriverByName('desc');
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
                driverManager.sortDriverByDate('asc');
              } else {
                driverManager.sortDriverByDate('desc');
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
              initialSelection: _type,
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
                setState(() => _type = value!);
                driverManager.filterByTypeCar(_type);
              },
              dropdownMenuEntries: [
                'All',
                'car',
                'motobike',
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
          Text('Số dòng $length/${driverManager.getMaxLength} (max)'),
        ] else ...[
          Text('Số dòng $length'),
        ],
        const SizedBox(width: 20),
      ],
    );
  }

  Widget _buildRow(Driver driver) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        onTap: () => _showAction(driver),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: driver.user.avatarUrl != null
              ? _avatar(driver.user.avatarUrl!, driver.user.isActive)
              : _defaultAvatar(),
        ),
        title: Text(
          driver.user.fullName.isNotEmpty
              ? driver.user.fullName
              : driver.user.userName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (driver.user.emailText.isNotEmpty)
              Text(
                driver.user.emailText,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            if (driver.user.phoneNumber.isNotEmpty)
              Text(driver.user.phoneNumber),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: driver.user.role == 'driver'
                ? Colors.blue.shade100
                : Colors.green.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            driver.user.getRole,
            style: TextStyle(
              color: driver.user.role == 'driver' ? Colors.blue : Colors.green,
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

  void _showAction(Driver driver) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.green.shade50,
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
                driver.user.fullName.isNotEmpty
                    ? driver.user.fullName
                    : driver.user.userName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(height: 16),
            buildRowInfo('Username:', driver.user.username),
            const SizedBox(height: 10),
            buildRowInfo('Email:', driver.user.emailText),
            const SizedBox(height: 10),
            buildRowInfo('Phone:', driver.user.phoneNumber),
            const SizedBox(height: 10),
            buildRowInfo('Status:', driver.user.getStatus),
            const SizedBox(height: 10),
            buildRowInfo('Bằng lái:', driver.licensenumber),
            const SizedBox(height: 10),
            buildRowInfo('Biển số:', driver.carnumber),
            const SizedBox(height: 10),
            buildRowInfo('Loại xe:', driver.typeCar),
            const SizedBox(height: 15),

            Row(
              children: [
                buttonPro('✒️ Chỉnh sửa', 'success', () {
                  Navigator.pop(context);
                  ChangeInfoDriverOverley.show(context, driver);
                }, filled: true),
                const SizedBox(width: 10),
                buttonPro('🗑️ Xóa', 'error', () async {
                  final success = await driverManager.deleteDriverById(
                    driver.id,
                  );
                  if (!success) {
                    // snackBarLogger(context, "Xoá không thành công", 'error');
                    return;
                  }
                  snackBarLogger(
                    context,
                    'Đã xóa tài khoản ${driver.id}',
                    'success',
                  );
                  setState(() {
                    driverManager.drivers.removeWhere((r) => r.id == driver.id);
                  });
                }, filled: true),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './notification_manager.dart';
import 'package:booking_app/ui/auth/auth_manager.dart';
import '../shared/myAppBar.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<StatefulWidget> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final authManager = context.read<AuthManager>();
      final userId = authManager.currentUserId;
      if (userId == null) return;
      final manager = context.read<NotificationManager>();
      await manager.loadNotifications(userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final authManager = context.read<AuthManager>();
    final currentUserId = authManager.currentUserId;
    final notificationManager = context.watch<NotificationManager>();

    final myNotifications = notificationManager.notificationsOfUser(
      currentUserId!,
    );
    print(myNotifications);
    return Scaffold(
      appBar: myAppBar(context, 'Thông báo'),
      backgroundColor: Colors.green.shade50,
      body: myNotifications.isEmpty
          ? const Center(child: Text('Trống'))
          : Padding(
              padding: EdgeInsetsGeometry.symmetric(horizontal: 5, vertical: 5),
              child: ListView.builder(
                itemCount: myNotifications.length,
                itemBuilder: (context, index) {
                  final n = myNotifications[index];
                  final title = n.title;
                  final message = n.message;
                  final type = n.type;
                  final id = n.id;
                  final date = n.timeDate;
                  final hour = n.timeHour;
                  var fileName;
                  switch (type) {
                    case 'success':
                      fileName = 'turtle_success.png';
                      break;
                    case 'warning':
                      fileName = 'turtle_warning.png';
                      break;
                    case 'error':
                      fileName = 'turtle_error.png';
                      break;
                    default:
                      fileName = 'turtle_success.png';
                  }
                  return Dismissible(
                    key: ValueKey(id),
                    background: Container(
                      color: Theme.of(context).colorScheme.error,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      margin: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 5,
                      ),
                      child: const Icon(
                        Icons.delete_forever,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                    direction: DismissDirection.endToStart,
                    confirmDismiss: (direction) async {
                      return await showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Xóa thông báo'),
                          content: const Text(
                            'Bạn có chắc chắn xóa thông báo này không?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(false),
                              child: const Text('Không'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(true),
                              child: const Text('Có'),
                            ),
                          ],
                        ),
                      );
                    },
                    onDismissed: (direction) {
                      notificationManager.removeNotificationById(
                        id!,
                        currentUserId,
                      );
                    },
                    child: Padding(
                      padding: EdgeInsetsGeometry.only(top: 3, bottom: 3),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          color: Colors.white,
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.asset(
                                  'assets/images/$fileName',
                                  width: 70,
                                  fit: BoxFit.cover,
                                ),
                              ),

                              const SizedBox(width: 12),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      message,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.black45,
                                      ),
                                    ),
                                    Text(
                                      date.toString() + ' - ' + hour,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.black45,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}

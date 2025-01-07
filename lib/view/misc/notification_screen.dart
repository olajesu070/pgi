import 'package:flutter/material.dart';
import 'package:pgi/services/api/xenforo_notification_service.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final NotificationService _notificationService = NotificationService();
  bool isLoading = true;
List<dynamic> notifications = [];

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    setState(() => isLoading = true);
    try {
      final fetchedNotifications = await _notificationService.getAlerts();
      setState(() {
        notifications = fetchedNotifications['alerts'] ?? [];
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load notifications: $e')),
      );
    }
  }

  void markAllAsRead() {
    setState(() {
      notifications = notifications.map((notification) {
        return {...notification, 'isRead': true};
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: markAllAsRead,
            child: const Text(
              'Mark all as read',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : notifications.isEmpty
              ? const Center(
                  child: Text(
                    'No notifications available',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: ListView.builder(
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final notification = notifications[index];
                      return Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: notification['isRead']
                                ? Colors.green
                                : Colors.red,
                            child: Icon(
                              notification['isRead']
                                  ? Icons.notifications_active
                                  : Icons.notifications,
                              color: Colors.white,
                            ),
                          ),
                          title: Text(
                            notification['title'] ?? 'Untitled Notification',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: notification['isRead']
                                  ? Colors.grey
                                  : Colors.black,
                            ),
                          ),
                          subtitle: Text(
                            notification['message'] ?? '',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Icon(
                            notification['isRead']
                                ? Icons.check_circle
                                : Icons.circle,
                            color: notification['isRead']
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}

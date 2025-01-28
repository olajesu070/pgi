import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pgi/core/utils/status_bar_util.dart';
import 'package:pgi/services/api/xenforo_notification_service.dart';
import 'package:pgi/view/widgets/custom_app_bar.dart';

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
   StatusBarUtil.setLightStatusBar();
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
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBarBody(
            title: 'Notifications',
            actions: [
                GestureDetector(
                onTap: markAllAsRead,
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                  'Mark All as Read',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                ),
            ],
          ),
          Expanded(
           child: isLoading
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
                      final user = notification['User'];
                       // Get the event date and format it
                      final eventDate = notification['event_date'] != null
                          ? DateTime.fromMillisecondsSinceEpoch(
                                  notification['event_date'] * 1000)
                              .toLocal()
                          : null;
                        return Dismissible(
                        key: Key(notification['alert_id'].toString()),
                        onDismissed: (direction) {
                          setState(() {
                          notifications.removeAt(index);
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Notification dismissed')),
                          );
                        },
                        background: Container(color: Colors.red),
                        child: Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                          ),
                          child: ListTile(
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(user['avatar_urls']['s'] ?? ''),
                          ),
                          title: Text(
                            notification['alert_text'] ?? 'Untitled Notification',
                            style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: notification['auto_read'] ? Colors.grey : Colors.black,
                            ),
                          ),
                          subtitle: Text(eventDate != null ? '${DateFormat('hh:mm a').format(eventDate)} on ${DateFormat('d MMM, yyyy').format(eventDate)}' : 'Unknown date'),
                          trailing: Icon(
                            notification['auto_read'] ? Icons.check_circle : Icons.circle,
                            color: notification['auto_read'] ? Colors.green : Colors.red,
                          ),
                          ),
                        ),
                        );
                    },
                  ),
                ),
          ),
          ],
        )
       
                
      )
    );
  }
}

class NotificationDetailScreen extends StatelessWidget {
  final String url;

  const NotificationDetailScreen({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Detail'),
      ),
      body: Center(
        child: Column(
          children: [
            const Text('Details for notification:'),
            Text(url),
            // You can load the URL content here or show more info as needed
          ],
        ),
      ),
    );
  }
}

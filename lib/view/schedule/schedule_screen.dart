import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:pgi/services/api/xenforo_event_service.dart';
import 'package:intl/intl.dart';
import 'package:pgi/view/explore/event_detail_screen.dart';
import 'package:pgi/view/widgets/custom_app_bar.dart'; // For date formatting

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  _ScheduleScreenState createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  bool isUpcomingSelected = true; // Tracks which tab is selected
  List<dynamic> events = [];
  final XenforoEventService eventService = XenforoEventService();
   int _currentPage = 1;
  int _totalPages = 1;
   bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    if (_isLoading || _currentPage > _totalPages) return; // Prevent extra calls
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await eventService.fetchEvents(page: _currentPage);
      final fetchedEvents = response['events'] as List<dynamic>;
      final pagination = response['pagination'];
      
      setState(() {
        events.addAll(fetchedEvents);
        _currentPage = pagination['current_page'] + 1;
        _totalPages = pagination['last_page'];
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching events: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

 @override
Widget build(BuildContext context) {
  return Scaffold(
    body: Column(
      children: [
         const CustomAppBarBody(
            title: 'Events',
          ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: events.length + 1,
            itemBuilder: (context, index) {
              if (index == events.length) {
                if (_isLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (_currentPage <= _totalPages) {
                  SchedulerBinding.instance.addPostFrameCallback((_) {
                    _fetchEvents();  // This will be triggered after the current frame completes
                  });
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Loading more events...'),
                    ),
                  );
                }
                return const SizedBox.shrink(); // End of list
              }
              final event = events[index];
              return _buildEventCard(event);
            },
          ),
        ),
      ],
    ),
  );
}

  Widget _buildEventCard(Map<String, dynamic> event) {
    final eventTitle = event['title'] ?? 'No Title';
    final eventOrganizer = event['username'] ?? 'Unknown';
    final eventStartDate = DateTime.fromMillisecondsSinceEpoch(event['event_start_date'] * 1000);
    final eventEndDate = DateTime.fromMillisecondsSinceEpoch(event['event_end_date'] * 1000);
    final formattedDate = DateFormat.yMMMMd().format(eventStartDate);
    final formattedEndDate = DateFormat.yMMMMd().format(eventEndDate);
    final location = event['event_timezone'] ?? 'Location not specified';
    final  categoryTitle = event['Category']?['title'] ?? 'General';
    final userId = event['user_id'];
    final  username = event['username'] ?? 'Unknown';
    final message = event['message'] ?? 'No description provided.';
    final isRsvp = event['is_rsvp_enabled'] ?? false;
    final dateRange = DateFormat('d MMM, yyyy').format(eventStartDate) +
        (eventStartDate == eventEndDate ? '' : ' - ${DateFormat('d MMM, yyyy').format(eventEndDate)}');

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15.0),
      ),
      elevation: 5,
      child: InkWell(
      borderRadius: BorderRadius.circular(15.0),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventDetailPage(
              title: eventTitle,
              date: dateRange,
              time: DateFormat('hh:mm a').format(eventStartDate),
              endTime:DateFormat('hh:mm a').format(eventEndDate),
              centerName: categoryTitle,
              address: location,
              organizerName: username,
              eventDetails: message,
              userId: userId,
              isRsvp: isRsvp,
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
          eventTitle,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
          ),
          const SizedBox(height: 8),
          Row(
          children: [
            const Icon(Icons.person, size: 16),
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
              'Organizer: $eventOrganizer',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black87,
              ),
              ),
            ),
          ],
          ),
          const SizedBox(height: 8),
          Row(
          children: [
            const Icon(Icons.calendar_today, size: 16),
            const SizedBox(width: 4),
            Text('Date: ${formattedDate == formattedEndDate ? formattedDate : '$formattedDate - $formattedEndDate'}'),
          ],
          ),
          const SizedBox(height: 8),
          Row(
          children: [
            const Icon(Icons.location_on, size: 16),
            const SizedBox(width: 4),
            Text('Location: $location'),
          ],
          ),
        ],
        ),
      ),
      ),
    );
  }
}

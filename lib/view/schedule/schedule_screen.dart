import 'package:flutter/material.dart';
import 'package:pgi/view/misc/create_event_screen.dart';
import 'package:pgi/view/widgets/custom_button.dart';
import 'package:pgi/view/widgets/schedule_card.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  _ScheduleScreenState createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  bool isUpcomingSelected = true; // Tracks which tab is selected

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Schedule'),
      ),
      body: Column(
        children: [
          // Toggle Buttons for "UPCOMING" and "MY SCHEDULE"
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildToggleButton('UPCOMING', isUpcomingSelected),
                const SizedBox(width: 16),
                _buildToggleButton('MY SCHEDULE', !isUpcomingSelected),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                _buildEventCards(isUpcomingSelected ? upcomingEvents : myScheduleEvents),
                _buildAddEventButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Method to build the toggle button
  Widget _buildToggleButton(String title, bool isSelected) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            isUpcomingSelected = title == 'UPCOMING';
          });
        },
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFFFFFFF) : Colors.transparent,
            borderRadius: BorderRadius.circular(100),
          ),
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? const Color(0xFF0A5338) : const Color(0xFF767676),
              fontWeight: FontWeight.bold,
              fontSize: 15
            ),
          ),
        ),
      ),
    );
  }

  // Method to display event cards
  Widget _buildEventCards(List<Map<String, String>> events) {
    return Column(
      children: events.map((event) => ScheduleCard(event)).toList(),
    );
  }

  // "Add Event" Button
  Widget _buildAddEventButton() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: CustomButton(
        label: 'Add Event',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateEventScreen()), // Make sure you import the PostThreadScreen
          );
        },
        // color: Colors.blue,
        textColor: Colors.white,
        ),
    );
  }
}




// Sample data for Upcoming and My Schedule events
final List<Map<String, String>> upcomingEvents = [
  {
    'imageUrl': 'https://picsum.photos/80/80?random=1',
    'date': 'Dec 12',
    'time': '10:00 AM',
    'title': 'Tech Conference',
    'location': 'New York, NY',
  },
  {
    'imageUrl': 'https://picsum.photos/80/80?random=2',
    'date': 'Dec 15',
    'time': '3:00 PM',
    'title': 'Music Festival',
    'location': 'Los Angeles, CA',
  },
];

final List<Map<String, String>> myScheduleEvents = [
  {
    'imageUrl': 'https://picsum.photos/80/80?random=3',
    'date': 'Jan 5',
    'time': '9:00 AM',
    'title': 'Yoga Workshop',
    'location': 'Chicago, IL',
  },
  {
    'imageUrl': 'https://picsum.photos/80/80?random=4',
    'date': 'Jan 20',
    'time': '1:00 PM',
    'title': 'Business Seminar',
    'location': 'San Francisco, CA',
  },
];

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pgi/core/utils/status_bar_util.dart';
import 'package:pgi/view/explore/oroganiser_detail_screen.dart';
import 'package:pgi/view/widgets/custom_app_bar.dart';
import 'package:pgi/view/widgets/custom_button.dart';

class EventDetailPage extends StatefulWidget {
  final String title;
  final String date;
  final String time;
  final String centerName;
  final String address;
  final String organizerName;
  final String eventDetails;
  final int userId;
  final String endTime;
  final bool isRsvp;

  const EventDetailPage({super.key, 
    required this.title,
    required this.date,
    required this.time,
    required this.centerName,
    required this.address,
    required this.organizerName,
    required this.eventDetails,
    required this.userId,
    required this.endTime,
    required this.isRsvp
  });

  @override
  State<EventDetailPage> createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
   @override
  void initState() {
    super.initState();
    StatusBarUtil.setLightStatusBar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: 
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CustomAppBarBody(
            title: 'Event Detail',
            
          ),
          // Cover Image with overlay
          Stack(
            children: [
              Image.network(
                'https://images.unsplash.com/photo-1500212802521-de7d7426f496?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8M3x8bmV3JTIweWVhcnxlbnwwfHwwfHx8MA%3D%3D',
                 width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
            ],
          ),
          // Event Title
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              widget.title,
              style: const TextStyle(
                fontSize: 35,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Date and Time
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                _iconContainer(Icons.calendar_today),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.date,
                      style: const TextStyle(fontSize: 16),
                    ),
                    Text(
                      'Start Time: ${widget.time}',
                      style: const TextStyle(color: Color(0xFF747688), fontSize: 12),
                    ),
                    Text(
                      'End Time: ${widget.endTime}',
                      style: const TextStyle(color: Color(0xFF747688), fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Location
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                _iconContainer(Icons.location_on),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.centerName,
                      style: const TextStyle(fontSize: 16),
                    ),
                    Text(
                      widget.address,
                      style: const TextStyle(color: Color(0xFF747688), fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Organizer Info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OrganizerDetailsScreen(
                          userId: widget.userId,
                        ),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                        const Icon(
                        Icons.person,
                        size: 40,
                        color: Colors.grey,
                        ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.organizerName,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize:15 ),
                          ),
                          const Text(
                            'Organizer',
                            style: TextStyle(color: Color(0xFF747688), fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    // Follow action
                  },
                  child: const Text(
                    'Follow',
                    style: TextStyle(color: Color(0xFF0A5338)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // About Event
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'About Event',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              widget.eventDetails,
              style: TextStyle(fontSize: 12, color: Colors.grey[800]),
            ),
          ),
          const Spacer(),
          // RSVP Button

          if (widget.isRsvp)
          Padding(
            padding: const EdgeInsets.all(16.0),

            child: CustomButton(
                  label: 'RSVP For Event',
                  onPressed: () {
                    // Handle Sign In action
                     Navigator.pushReplacementNamed(context, '/home');
                  },
                  // color: Colors.blue,
                  textColor: Colors.white,
                ),
          ),

          
        ],
      ),
      ),
    );
  }

  // Helper for icon containers
  Widget _iconContainer(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0x6A0A5338),
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        icon,
        color: const Color(0xFF0A5338),
        size: 20,
      ),
    );
  }
}
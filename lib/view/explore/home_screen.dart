import 'package:flutter/material.dart';
import 'package:pgi/core/constants/app_colors.dart';
import 'package:pgi/view/explore/detail_screen.dart';
import 'package:pgi/view/widgets/custom_drawer.dart';
import 'package:pgi/view/widgets/edge_button.dart';
import 'package:pgi/view/widgets/event_cards.dart';
import 'package:pgi/view/widgets/post_cards.dart';
import 'package:pgi/view/widgets/section_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CustomDrawer(membershipType: "Premium"),
      body: Stack(
        children: [
          Container(
            color: const Color(0xFFFFFFFF),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(33),
                  bottomRight: Radius.circular(33),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFFFFFFFF),
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Top Row with Hamburger, Location, and Notification Icons
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Use Builder to get the correct context
                      Builder(
                        builder: (BuildContext context) {
                          return IconButton(color: const Color(0xFFFFFFFF),
                            icon: const Icon(Icons.menu),
                            onPressed: () {
                              Scaffold.of(context).openDrawer();
                            },
                          );
                        },
                      ),
                      GestureDetector(
                        onTap: () {
                          // Navigate to map page
                          // Navigator.pushNamed(context, '/map');
                        },
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [

                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Current Location',
                                  style: TextStyle(fontSize: 12,color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                                Icon(Icons.arrow_drop_down, size: 20,color: Colors.white),
                              ],
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Florida, USA',
                              style: TextStyle(fontSize: 14, color: Colors.white),
                            ),

                          ],
                        ),
                      ),
                      const CircleAvatar(
                        backgroundColor: Color(0x49FFFFFF),
                        child: Icon(Icons.notifications_none,color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Second Row with Search and Filter Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Search...',
                            hintStyle: const TextStyle(color: Colors.white),
                            prefixIcon: const Icon(Icons.search, color: Colors.white),
                            filled: true,
                            fillColor: Colors.transparent,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none, // Makes it borderless
                            ),
                            contentPadding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          style: const TextStyle(color: Colors.white), // Set input text color to white
                        ),
                      ),
                      const SizedBox(width: 10),
                       ElevatedButton(
                        onPressed: () {
                          // Filter action
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          backgroundColor: const Color(0xFF0A5338),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                           Container(
                                decoration: const BoxDecoration(
                                  color: Colors.white, // White background for icon
                                  shape: BoxShape.circle,
                                ),
                                padding: const EdgeInsets.all(5),
                                child: const Icon(
                                  Icons.filter_list,
                                  color: Color(0xFF0A5338), // Icon color
                                  size: 20,
                                ),
                              ),
                            const SizedBox(width: 5),
                            const Text(
                              'Filter',
                              style: TextStyle(color: Colors.white), // Text color
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
          // Edge Buttons partially overlaying the header
          const Positioned(
            top: 180, // Adjust this value to control how much is overlayed
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                EdgeButton(color: Color(0xFFF44336), text: 'The Guild'),
                EdgeButton(color: Color(0xFFF59762), text:'PGI Training'),
                EdgeButton(color: Color(0xFF29D697), text:'Memberships'),
              ],
            ),
          ),
          // Main Body Content
        Padding(
            padding: const EdgeInsets.only(top: 240), // Adjust based on overlay height
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SectionWidget(title: 'Upcoming Events', actionText: 'See All', content: _buildEventCards()),
                  SectionWidget(title: 'Latest Posts', actionText: 'See All', content: _buildPostCards(context)),
                ],
              ),
            ),
          ), 
        ],
      ),
    );
  }

  Widget _buildEventCards() {
    return SizedBox(
      height: 280, // Set height to fit the card designs
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];
          return EventCard(
            imageUrl: event['imageUrl'],
            date: event['date'],
            title: event['title'],
            attendeeAvatars: event['attendeeAvatars'],
            location: event['location'],
            goingCount: event['goingCount'],
          );
        },
      ),
    );
  }



 Widget _buildPostCards(BuildContext context) {
    return Column(
      children: posts.map((post) {
        return LatestPostCard(
          imageUrl: post['imageUrl']!,
          date: post['date']!,
          time: post['time']!,
          title: post['title']!,
          writerName: post['writerName']!,
          onTap: () {
            // Navigate to PostDetailScreen with the current post data
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PostDetailScreen(post: post),
              ),
            );
          },
        );
      }).toList(),
    );
  }
}

    // Sample list of events to be displayed
 


 

   final List<Map<String, dynamic>> events = [
  {
    'imageUrl': 'https://picsum.photos/201/300',
    'date': 'Dec 25',
    'title': 'New Year Party 2024 Celebration',
    'location': 'New York City, NY',
    'goingCount': 20,
    'attendeeAvatars': [
      'https://picsum.photos/seed/1/50/50',
      'https://picsum.photos/seed/2/50/50',
      'https://picsum.photos/seed/3/50/50',
    ],
  },
  {
    'imageUrl': 'https://picsum.photos/200/300',
    'date': 'Jan 10',
    'title': 'Winter Music Fest',
    'location': 'Los Angeles, CA',
    'goingCount': 35,
    'attendeeAvatars': [
      'https://picsum.photos/seed/4/50/50',
      'https://picsum.photos/seed/5/50/50',
      'https://picsum.photos/seed/6/50/50',
    ],
  },
  {
    'imageUrl': 'https://picsum.photos/202/300',
    'date': 'Feb 14',
    'title': 'Valentine’s Gala',
    'location': 'Chicago, IL',
    'goingCount': 45,
    'attendeeAvatars': [
      'https://picsum.photos/seed/7/50/50',
      'https://picsum.photos/seed/8/50/50',
      'https://picsum.photos/seed/9/50/50',
    ],
  },
  // Add more event entries as needed
];



  final List<Map<String, String>> posts = [
    {
      'imageUrl': 'https://picsum.photos/200',
      'date': 'Nov 3',
      'time': '10:00 AM',
      'title': 'Exploring Flutter’s New Features',
      'writerName': 'Alice Johnson',
    },
    {
      'imageUrl': 'https://picsum.photos/201',
      'date': 'Nov 2',
      'time': '2:30 PM',
      'title': 'React vs Flutter: A Developer’s Guide',
      'writerName': 'Bob Smith',
    },
    {
      'imageUrl': 'https://picsum.photos/202',
      'date': 'Nov 1',
      'time': '6:45 PM',
      'title': 'Understanding State Management in Flutter',
      'writerName': 'John Doe',
    },
    // Add more post entries as needed
  ];

 

import 'package:flutter/material.dart';
import 'package:pgi/view/message/chatscreen.dart';
import 'package:pgi/view/widgets/custom_button.dart';

class OrganizerDetailsScreen extends StatelessWidget {
  final String organizerName;

  const OrganizerDetailsScreen({super.key, required this.organizerName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        // title: Text(organizerName),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // User Avatar Section
            const Padding(
              padding: EdgeInsets.only(top: 16.0),
              child: CircleAvatar(
                radius: 96, // Avatar size
                backgroundImage: NetworkImage(
                    'https://picsum.photos/202'), // Placeholder image
              ),
            ),
            const SizedBox(height: 8),
            // User Name Section
            Text(
              organizerName,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // Numbered Sections (Media, Reactions, Points)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
               children: [
              _buildColumn('Media', '10'),
              const Divider(
                height: 20.0,
                color: Colors.grey,
                indent: 10.0,
                endIndent: 10.0,
              ),
              _buildColumn('Reactions', '200'),
              const Divider(
                height: 20.0,
                color: Colors.grey,
                indent: 10.0,
                endIndent: 10.0,
              ),
              _buildColumn('Points', '500'),
            ],

              ),
            ),
            const SizedBox(height: 16),
            // Follow and Message Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                 CustomButton(
                  label: 'Follow',
                  width: 154,
                  onPressed: () {
                    // Handle follow action
                  },
                  // color: Colors.blue,
                  textColor: Colors.white,
                ),
                  const SizedBox(width: 16),
                  CustomButton(
                  label: 'Message',
                  width: 154,
                  isOutlined: true,
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatPage(title: 'Chat with $organizerName'),
                        ),
                      );
                  },
                ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Tab Bar Section
            const DefaultTabController(
              length: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tabs
                  TabBar(
                    tabs: [
                      Tab(text: 'ABOUT'),
                      Tab(text: 'EVENTS'),
                      Tab(text: 'REVIEWS'),
                    ],
                  ),
                  SizedBox(
                    height: 400, // Adjust based on content
                    child: TabBarView(
                      children: [
                        // About Tab Content
                        Center(child: Text('About Content')),
                        // Events Tab Content
                        Center(child: Text('Events Content')),
                        // Reviews Tab Content
                        Center(child: Text('Reviews Content')),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build each column (Media, Reactions, Points)
  Widget _buildColumn(String title, String count) {
    return Column(
      children: [
        Text(
          count,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

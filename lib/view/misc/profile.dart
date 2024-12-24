import 'package:flutter/material.dart';
import 'package:pgi/view/misc/edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  final String userName;

  const ProfileScreen({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Navigate back
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // User Avatar
              const CircleAvatar(
                radius: 60, // Size of the avatar
                backgroundImage: NetworkImage('https://picsum.photos/212'), // Replace with user avatar URL
              ),
              const SizedBox(height: 16),

              // User Name
              Text(
                userName,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Statistics Row (Messages, Media, Reactions, Points)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildStatColumn('Messages', '100'),
                  const SizedBox(width: 16),  // Space between the columns
                  const Divider(
                    color: Colors.grey,  // Divider color
                    height: 40,  // Space the divider will occupy
                    thickness: 1,  // Divider thickness
                  ),
                  const SizedBox(width: 16),  // Space between the columns
                  _buildStatColumn('Media', '200'),
                  const SizedBox(width: 16),  // Space between the columns
                  const Divider(
                    color: Colors.grey,
                    height: 40,
                    thickness: 1,
                  ),
                  const SizedBox(width: 16),
                  _buildStatColumn('Reactions', '300'),
                  const SizedBox(width: 16),  // Space between the columns
                  const Divider(
                    color: Colors.grey,
                    height: 40,
                    thickness: 1,
                  ),
                  const SizedBox(width: 16),
                  _buildStatColumn('Points', '400'),
                ],
              ),
              const SizedBox(height: 16),

              // Edit Profile Button
             OutlinedButton.icon(
                onPressed: () {
                  // Navigate to Edit Profile page
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const EditProfileScreen()), // Replace with your EditProfileScreen widget
                  );
                },
                icon: const Icon(Icons.edit),
                label: const Text('Edit Profile'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),

              const SizedBox(height: 24),

              // About Me Section
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'About Me',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Quisque ut purus et nisi gravida ullamcorper. Morbi ut risus nec sapien ullamcorper varius.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),

              // My Recent Events Title
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'My Recent Events',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),

              // Schedule Card List
              _buildRecentEventsList(),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build a statistic column
  Widget _buildStatColumn(String label, String count) {
    return Column(
      children: [
        Text(
          count,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ],
    );
  }

  // Helper method to create a recent event schedule card
  Widget _buildRecentEventsList() {
    return ListView.builder(
      shrinkWrap: true, // To avoid unbounded height in ListView
      physics: const NeverScrollableScrollPhysics(), // Prevent scrolling in ListView
      itemCount: 5, // Replace with actual data count
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            title: Text('Event Title $index'),
            subtitle: const Text('Event Description'),
            onTap: () {
              // Navigate to event detail page
            },
          ),
        );
      },
    );
  }
}

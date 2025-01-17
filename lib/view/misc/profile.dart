import 'package:flutter/material.dart';
import 'package:pgi/data/models/user_state.dart';
import 'package:pgi/view/misc/edit_profile_screen.dart';
import 'package:pgi/view/widgets/custom_app_bar.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget {

  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
     final userState = Provider.of<UserState>(context);
    final userDetails = userState.userDetails;
    final String firstName = userDetails?['me']['custom_fields']['firstname'] ?? '';
    final String lastName = userDetails?['me']['custom_fields']['lastname'] ?? '';
    final String email = userDetails?['me']['email'] ?? '';
    final String about = (userDetails?['me']['about'] ?? '').isEmpty 
    ? 'Please update your about section.' 
    : userDetails?['me']['about']!;
    final String userName = '$firstName $lastName';
    final String avatarUrl = userDetails?['me']['avatar_urls']['o'] ?? 'https://picsum.photos/200/300';
    final bool isActiveMember = userDetails?['me']['activity_visible'] ?? false;
    final int messages = userDetails?['me']['message_count'] ?? 0;
    final int reactionScore = userDetails?['me']['reaction_score'] ?? 0;
    final int points = userDetails?['me']['trophy_points'] ?? 0;
    
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
             const CustomAppBarBody(
                title: 'Profile',
              ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xE0BDEC66),
                borderRadius: BorderRadius.circular(0),
              ),
              child: Text(
                isActiveMember ? 'Active PGI Member' : 'Guest',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // User Avatar
            CircleAvatar(
                radius: 60, // Size of the avatar
                backgroundImage: NetworkImage(avatarUrl), // Replace with user avatar URL
              ),
              const SizedBox(height: 16),

              // User Name
              Text(
                userName,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
               Text(
                email,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),

              // Statistics Row (Messages, Media, Reactions, Points)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildStatColumn('Messages', messages.toString()),
                  const SizedBox(width: 16),  // Space between the columns
                  const Divider(
                    color: Colors.grey,  // Divider color
                    height: 40,  // Space the divider will occupy
                    thickness: 1,  // Divider thickness
                  ),
                  const SizedBox(width: 16),  // Space between the columns
                
                  _buildStatColumn('Reactions', reactionScore.toString()),
                  const SizedBox(width: 16),  // Space between the columns
                  const Divider(
                    color: Colors.grey,
                    height: 40,
                    thickness: 1,
                  ),
                  const SizedBox(width: 16),
                  _buildStatColumn('Points', points.toString()),
                ],
              ),
              const SizedBox(height: 20),

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
               Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  about,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              )

              // My Recent Events Title
              // const Align(
              //   alignment: Alignment.centerLeft,
              //   child: Text(
              //     'My Recent Events',
              //     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              //   ),
              // ),
              // const SizedBox(height: 8),

              // Schedule Card List
              // _buildRecentEventsList(),
            ],
            ),
          ),
        ],
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

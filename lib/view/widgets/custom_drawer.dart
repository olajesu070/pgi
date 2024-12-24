import 'package:flutter/material.dart';

class CustomDrawer extends StatelessWidget {
  final String membershipType; // Type of membership (e.g., "Guest", "Premium")

  const CustomDrawer({
    super.key,
    this.membershipType = "Guest", // Default to "Guest" if not specified
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFFFFFFFF),
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Color(0xFFFFFFFF),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: NetworkImage('https://picsum.photos/200/300'),
                ),
                SizedBox(height: 10),
                Text(
                  'Logan Moore',
                  style: TextStyle(color: Color(0xFF000000), fontSize: 20),
                ),
              ],
            ),
          ),
          // My Profile tile with padding and background color
          Container(
            color: Colors.white,
            child: ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('My Profile'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/profile');
              },
            ),
          ),
          const SizedBox(height: 10), // Space between tiles

          // Messages tile with padding and background color
          Container(
            color: Colors.white,
            child: ListTile(
              leading: const Icon(Icons.chat_bubble_outline),
              title: const Text('Messages'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/messages');
              },
            ),
          ),
          const SizedBox(height: 10), // Space between tiles

          // Contact Us tile
          Container(
            color: Colors.white,
            child: ListTile(
              leading: const Icon(Icons.mail_outline),
              title: const Text('Contact Us'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/contact');
              },
            ),
          ),
          const SizedBox(height: 10), // Space between tiles

          // Settings tile
          Container(
            color: Colors.white,
            child: ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/settings');
              },
            ),
          ),
          const SizedBox(height: 10), // Space between tiles

          // Sign Out tile
          Container(
            color: Colors.white,
            child: ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Sign Out'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/signIn');
              },
            ),
          ),
          const SizedBox(height: 20), // Space before membership label

          // Membership label at the bottom of the drawer
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                membershipType,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

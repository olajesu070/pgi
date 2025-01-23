import 'package:flutter/material.dart';
import 'package:pgi/services/api/oauth2_service.dart';

class CustomDrawer extends StatelessWidget {
  final Map<String, dynamic> userDetails;
  final OAuth2Service oauth2Service = OAuth2Service(onTokensUpdated: () {
    // Handle token update if needed
  });

  CustomDrawer({
    super.key,
    required this.userDetails,
  });

  @override
  Widget build(BuildContext context) {
    final String firstName = userDetails['me']['custom_fields']['firstname'] ?? '';
    final String lastName = userDetails['me']['custom_fields']['lastname'] ?? '';
    final String email = userDetails['me']['email'] ?? '';
    final String userName = '$firstName $lastName';
    final String avatarUrl = userDetails['me']['avatar_urls']['o'] ?? 'https://picsum.photos/200/300';
    final String membershipType = userDetails['membershipType'] ?? 'Guest';
    final bool isActiveMember = userDetails['me']['activity_visible'] ?? false;

    return Drawer(
      backgroundColor: const Color(0xFFFFFFFF),
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Color(0xFFFFFFFF),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: NetworkImage(avatarUrl),
                ),
                const SizedBox(height: 10),
                Text(
                  userName,
                  style: const TextStyle(
                    color: Color(0xFF000000),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('My Profile'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/profile');
            },
          ),
          ListTile(
            leading: const Icon(Icons.chat_bubble_outline),
            title: const Text('Messages'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/messages');
            },
          ),
          ListTile(
            leading: const Icon(Icons.mail_outline),
            title: const Text('Contact Us'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/contact');
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/settings');
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Sign Out'),
            onTap: () async {
              // Navigator.pop(context);
              await oauth2Service.logout(context);
            },
          ),
          const Spacer(),
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
        ],
      ),
    );
  }
}

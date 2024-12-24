import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Go back to the previous page
          },
        ),
      ),
      body: ListView(
        children: [
          // Account Section
          _buildSection('Account', [
            _buildListTile(
              icon: Icons.person,
              title: 'Edit Profile',
              onTap: () {
                // Navigate to edit profile page
              },
            ),
            _buildListTile(
              icon: Icons.security,
              title: 'Security',
              onTap: () {
                // Navigate to security settings page
              },
            ),
            _buildListTile(
              icon: Icons.notifications,
              title: 'Notifications',
              onTap: () {
                // Navigate to notifications settings page
              },
            ),
            _buildListTile(
              icon: Icons.lock,
              title: 'Privacy',
              onTap: () {
                // Navigate to privacy settings page
              },
            ),
          ]),

          // Support & About Section
          _buildSection('Support & About', [
            _buildListTile(
              icon: Icons.help,
              title: 'Help & Support',
              onTap: () {
                // Navigate to help & support page
              },
            ),
            _buildListTile(
              icon: Icons.description,
              title: 'Terms and Policies',
              onTap: () {
                // Navigate to terms and policies page
              },
            ),
          ]),

          // Actions Section
          _buildSection('Actions', [
            _buildListTile(
              icon: Icons.report_problem,
              title: 'Report a problem',
              onTap: () {
                // Navigate to report a problem page
              },
            ),
            _buildListTile(
              icon: Icons.exit_to_app,
              title: 'Log out',
              onTap: () {
                // Log out action
              },
            ),
          ]),
        ],
      ),
    );
  }

  // Helper to create section titles
  Widget _buildSection(String title, List<Widget> listItems) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Divider(), // Divider line between sections
          ...listItems,
        ],
      ),
    );
  }

  // Helper to create each list item with an icon
  Widget _buildListTile({
    required IconData icon,
    required String title,
    required Function onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () => onTap(),
    );
  }
}

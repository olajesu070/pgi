import 'package:flutter/material.dart';
import 'package:pgi/view/misc/contact_screen.dart';
import 'package:pgi/view/misc/edit_profile_screen.dart';
import 'package:pgi/view/misc/policy.dart';
import 'package:pgi/view/misc/terms_policy.dart';
import 'package:pgi/view/misc/notification_screen.dart';
import 'package:pgi/view/widgets/custom_app_bar.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: SafeArea(
        child: Column(
          children: [
             const CustomAppBarBody(
              title: 'Settings',
            ),
            Expanded(
              child: ListView(
              children: [
                // Account Section
                _buildSection('Account', [
                  _buildListTile(
                    icon: Icons.person,
                    title: 'Edit Profile',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const EditProfileScreen()),
                      );
                    },
                  ),
                  _buildListTile(
                    icon: Icons.notifications,
                    title: 'Notifications',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) =>  const NotificationScreen()),
                      );
                    },
                  ),
                  _buildListTile(
                    icon: Icons.lock,
                    title: 'Privacy',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const PrivacyPolicyScreen()),
                      );
                    },
                  ),
                ]),

                // Support & About Section
                _buildSection('Support & About', [
                  _buildListTile(
                    icon: Icons.help,
                    title: 'Help & Support',
                    onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) =>  const ContactUsScreen()),
                      );
                    },
                  ),
                  _buildListTile(
                    icon: Icons.description,
                    title: 'Terms and Policies',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const TermsAndConditionsScreen()),
                      );
                    },
                  ),
                ]),

                // Actions Section
                _buildSection('Actions', [
                  _buildListTile(
                    icon: Icons.report_problem,
                    title: 'Report a problem',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) =>  const ContactUsScreen()),
                      );
                    },
                  ),
                ]),
              ],
            ),
            )
          ]
        )
      )
      
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

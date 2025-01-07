import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Privacy Policy',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'We are Pyrotechnics Guild International ("we", "our", "us"). We’re committed to protecting and respecting your privacy. If you have questions about your personal information please contact us.',
            ),
            SizedBox(height: 24),
            Text(
              'What Information We Hold About You',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'The type of data that we collect and process includes:',
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('- Your username.'),
                  Text('- Your first name.'),
                  Text('- Your last name.'),
                  Text('- Your email address.'),
                  Text('- Your phone number.'),
                  Text('- Your mailing address.'),
                  Text('- Your IP address.'),
                  Text('- Further data you may choose to share.'),
                ],
              ),
            ),
            SizedBox(height: 24),
            Text(
              'We collect some or all of this information in the following cases:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('- You register as a member on this site.'),
                  Text('- You fill out our contact form.'),
                  Text('- You browse this site. See "Cookie policy" below.'),
                  Text('- You fill out fields on your profile.'),
                ],
              ),
            ),
            SizedBox(height: 24),
            Text(
              'How Your Personal Information is Used',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'We may use your personal information in the following ways:',
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      '- To make you a registered member, enabling content contribution.'),
                  Text('- To send you emails about site activity.'),
                  Text('- To record your IP address for certain actions.'),
                  Text(
                      '- To send physical membership materials using your mailing address.'),
                  Text(
                      '- To contact you via phone for registration or event issues.'),
                  Text('- To share newsletters and announcements.'),
                ],
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Keeping Your Data Secure',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'We are committed to safeguarding your data. We have measures in place to secure the information we collect.',
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Location of Data Processing',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text('All data processing is done in the United States.'),
            ),
            SizedBox(height: 24),
            Text(
              'Third-party Websites',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'Our site may link to external websites. We are not responsible for their content or practices. Please review their privacy policies.',
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Cookie Policy',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'We use cookies to enhance functionality, such as login and preference tracking.',
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Your Rights',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'You have rights to access, correct, or delete your personal data. Contact us to exercise these rights.',
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Acceptance of This Policy',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'By using our site, you accept this policy. If you do not agree, please do not use our site.',
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Changes to This Policy',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'We may update this policy. You may need to review and re-accept changes.',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

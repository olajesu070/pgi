import 'package:flutter/material.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms and Conditions'),
        centerTitle: true,
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
           Text(
              'Terms and Conditions',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
             SizedBox(height: 16),
             Text(
              'The Providers ("we", "us", "our") of the service provided by this web site ("Service") are not responsible for any user-generated content and accounts. Content submitted express the views of their author only.',
              style: TextStyle(fontSize: 16),
            ),
             SizedBox(height: 16),
          Text(
              'This Service is only available to users who are at least 13 years old. If you are younger than this, please do not register for this Service. If you register for this Service, you represent that you are this age or older.',
              style: TextStyle(fontSize: 16),
            ),
             SizedBox(height: 16),
            Text(
              'All content you submit, upload, or otherwise make available to the Service ("Content") may be reviewed by staff members. All Content you submit or upload may be sent to third-party verification services (including, but not limited to, spam prevention services). Do not submit any Content that you consider to be private or confidential.',
              style: TextStyle(fontSize: 16),
            ),
             SizedBox(height: 16),
            Text(
              'You agree to not use the Service to submit or link to any Content which is defamatory, abusive, hateful, threatening, spam or spam-like, likely to offend, contains adult or objectionable content, contains personal information of others, risks copyright infringement, encourages unlawful activity, or otherwise violates any laws. You are entirely responsible for the content of, and any harm resulting from, that Content or your conduct.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
           Text(
              'We may remove or modify any Content submitted at any time, with or without cause, with or without notice. Requests for Content to be removed or modified will be undertaken only at our discretion. We may terminate your access to all or any part of the Service at any time, with or without cause, with or without notice.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'You are granting us with a non-exclusive, permanent, irrevocable, unlimited license to use, publish, or re-publish your Content in connection with the Service. You retain copyright over the Content.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
             Text(
              'The manufacture, assembly, and discharge of pyrotechnic devices is beyond the control of this Service. Such activities should be undertaken only after proper study and training. The articles and materials contained in this Service are for the general knowledge of its readers. The Pyrotechnics Guild International, Inc., its officers, agents, directors, employees, and members assume no liability for the accuracy of any information contained herein, and each of them disclaims any responsibility for any loss or injury occasioned by any use of, or attempt to duplicate, any device, assembly, or formula that may be described.',
              style: TextStyle(fontSize: 16),
            ),
           SizedBox(height: 16),
            Text(
              'These terms may be changed at any time without notice.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
           Text(
              'If you do not agree with these terms, please do not register or use the Service. Use of the Service constitutes acceptance of these terms. If you wish to close your account, please contact us.',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:pgi/view/discussion/thread_detail_screen.dart';

class ContactUsScreen extends StatelessWidget {
  ContactUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Navigate back
          },
        ),
        title: const Text('Contact Us'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Information message
            Text(
              'For any inquiries, please click the button below to contact us, We are here to assist you with any questions or concerns you may have. Our team is dedicated to providing you with the best support possible.',
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Contact Us Button
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ThreadDetailScreen(param: 'https://pgi.org/misc/contact',)),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Contact Us'),
            ),
          ],
        ),
      ),
    );
  }
}


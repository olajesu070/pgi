import 'package:flutter/material.dart';

class PostThreadScreen extends StatefulWidget {
  const PostThreadScreen({super.key});

  @override
  _PostThreadScreenState createState() => _PostThreadScreenState();
}

class _PostThreadScreenState extends State<PostThreadScreen> {
  bool watchThread = false;
  bool emailNotifications = false;
  String threadType = 'Discussion'; // Default thread type

  // Controllers for text inputs
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Thread'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Navigate back
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Thread Title
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Thread Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Thread Type (Discussion, Poll, Question)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildThreadTypeOption('Discussion'),
                _buildThreadTypeOption('Poll'),
                _buildThreadTypeOption('Question'),
              ],
            ),
            const SizedBox(height: 16),

            // Big Content Input Box
            TextField(
              controller: contentController,
              maxLines: 6,
              decoration: const InputDecoration(
                labelText: 'Write your post...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Add Attachment Button
            InkWell(
              onTap: () {
                // Implement the action to add an attachment (e.g., pick a file)
              },
              child: Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey),
                ),
                child: const Center(
                  child: Icon(Icons.attach_file, size: 24),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Options (Watch Thread, Email Notifications)
            Row(
              children: [
                Checkbox(
                  value: watchThread,
                  onChanged: (bool? value) {
                    setState(() {
                      watchThread = value ?? false;
                    });
                  },
                ),
                const Text('Watch this thread'),
              ],
            ),
            Row(
              children: [
                Checkbox(
                  value: emailNotifications,
                  onChanged: (bool? value) {
                    setState(() {
                      emailNotifications = value ?? false;
                    });
                  },
                ),
                const Text('Receive email notifications'),
              ],
            ),
            const SizedBox(height: 16),

            // Post Thread Button
            ElevatedButton(
              onPressed: () {
                // Implement the action to post the thread
                String title = titleController.text;
                String content = contentController.text;

                // You can use the data like title, content, and threadType for submitting the post
                // For now, we will show a simple success message
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Thread posted successfully!')),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Post Thread'),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build thread type selection
  Widget _buildThreadTypeOption(String type) {
    return GestureDetector(
      onTap: () {
        setState(() {
          threadType = type;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: threadType == type ? Colors.blueAccent : Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(
              type == 'Discussion'
                  ? Icons.chat_bubble_outline
                  : type == 'Poll'
                      ? Icons.poll
                      : Icons.question_answer,
              color: threadType == type ? Colors.white : Colors.black,
            ),
            const SizedBox(height: 4),
            Text(
              type,
              style: TextStyle(
                color: threadType == type ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

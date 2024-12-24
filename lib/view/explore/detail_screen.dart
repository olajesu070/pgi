import 'package:flutter/material.dart';

class PostDetailScreen extends StatelessWidget {
  final Map<String, String> post;

  const PostDetailScreen({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Post Details"),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover image at the top
            Image.network(
              post['imageUrl']!,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Post title
                  Text(
                    post['title']!,
                    style: const TextStyle(
                      fontSize: 35,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Post writer and date/time info in a row
                  Row(
                    children: [
                      const Icon(Icons.person, size: 14, color: Color(0xFF0A5338),),
                      const SizedBox(width: 8),
                      Text(
                        "By ${post['writerName']}",
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(width: 16),
                      const Icon(Icons.calendar_today, size: 14, color: Color(0xFF0A5338),),
                      const SizedBox(width: 8),
                      Text(
                        "${post['date']} at ${post['time']}",
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Section header for the post content
                  const Text(
                    'Post Content',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Main post content
                  Text(
                    post['content'] ?? "Here are the detailed contents of the post...",
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

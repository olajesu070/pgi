import 'package:flutter/material.dart';

class DiscussionCard extends StatelessWidget {
  final String title;
  final List<String> avatars;
  final int remainingCount;

  const DiscussionCard({
    super.key,
    required this.title,
    required this.avatars,
    required this.remainingCount,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Discussion Title
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xCC0A5338),
              ),
            ),
            const SizedBox(height: 12),
            // Avatars and remaining member count
            Row(
              children: [
                // Display up to 5 avatars
                ...avatars.take(5).map((avatarUrl) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 4.0),
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(avatarUrl),
                      radius: 15,
                    ),
                  );
                }),
                // Display "+remainingCount others" if there are more than 5 avatars
                if (remainingCount > 0)
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      '+$remainingCount others',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

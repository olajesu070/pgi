import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pgi/view/discussion/discussion.dart';
import 'package:pgi/view/discussion/thread_detail_screen.dart'; // For date formatting

class DiscussionCard extends StatelessWidget {
  final String title;
  final String forumTitle;
  final String postDate;
  final String username;
  final int reactionCount;
  final int replyCount;
  final List<String> avatars;
  final int remainingCount;
  final String viewUrl; // URL to navigate to the thread
  final int threadId;



  const DiscussionCard({
    super.key,
    required this.title,
    required this.forumTitle,
    required this.postDate,
    required this.username,
    required this.reactionCount,
    required this.replyCount,
    required this.avatars,
    required this.remainingCount,
    required this.viewUrl,
    required this.threadId,
  });

  @override
  Widget build(BuildContext context) {
    // Format the post date
    // final formattedDate = DateFormat('MMM dd, yyyy').format(DateTime.fromMillisecondsSinceEpoch(int.parse(postDate) * 1000));

    return GestureDetector(
      onTap: () {
        // Navigate to the thread detail view
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DiscussionDetailScreen(threadId: threadId,), // Replace with your actual detail screen
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Forum Title (tag style)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xCC0A5338),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  forumTitle,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Discussion Title
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xCC0A5338),
                ),
              ),
              const SizedBox(height: 8),
              // Post Date and Username
              Row(
                children: [
                  Text(
                    'Posted on $postDate by $username',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
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
              const SizedBox(height: 12),
              // Reaction count and Reply count with icons
              Row(
                children: [
                  // Reaction count
                  Row(
                    children: [
                      const Icon(Icons.thumb_up, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        '$reactionCount reactions',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  // Reply count
                  Row(
                    children: [
                      const Icon(Icons.message, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        '$replyCount replies',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

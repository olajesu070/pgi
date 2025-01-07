import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pgi/services/api/xenforo_api_service.dart';
import 'package:pgi/view/misc/post_thread_screen.dart';
import 'package:pgi/view/widgets/discussion_card.dart';

class DiscussionsScreen extends StatefulWidget {
  const DiscussionsScreen({super.key});

  @override
  _DiscussionsScreenState createState() => _DiscussionsScreenState();
}

class _DiscussionsScreenState extends State<DiscussionsScreen> {
  final XenForoApiService apiService = XenForoApiService();

  List<Map<String, dynamic>> discussions = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchDiscussions();
  }

 Future<void> _fetchDiscussions() async {
  setState(() {
    isLoading = true;
    errorMessage = ''; // Clear any previous error message
  });

  try {
    final data = await apiService.getForumThreads();

    setState(() {
      if (data['threads'] == null || data['threads'].isEmpty) {
        discussions = [];  // Handle case for empty threads (204 No Content)
        errorMessage = 'No discussions available at the moment.';
      } else {
        discussions = List<Map<String, dynamic>>.from(data['threads']); // Extract the threads array
      }
      isLoading = false;
    });
  } catch (e) {
    setState(() {
      errorMessage = '$e Failed to load discussions. Please try again later.';
      isLoading = false;
    });
  }
}


  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      automaticallyImplyLeading: false,
      title: const Text('Discussions'),
      // actions: [
      //   IconButton(
      //     icon: const Icon(Icons.search),
      //     onPressed: () {
      //       // Handle search action
      //     },
      //   ),
      //   IconButton(
      //     icon: const Icon(Icons.more_vert),
      //     onPressed: () {
      //       // Handle more options action
      //     },
      //   ),
      // ],
    ),
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: isLoading
          ? const Center(child: CircularProgressIndicator()) // Loading state
          : discussions.isEmpty
              ? Center(child: Text(errorMessage.isNotEmpty ? errorMessage : 'No discussions available.')) // Empty or error message
              : ListView.builder(
                  itemCount: discussions.length,
                  itemBuilder: (context, index) {
                    final discussion = discussions[index];
                    final user = discussion['User'];
                    final formattedDate = DateFormat('MMM dd, yyyy').format(DateTime.fromMillisecondsSinceEpoch(discussion['post_date'] * 1000));
                    
                    return DiscussionCard(
                      title: discussion['title'] ?? 'Untitled',
                      avatars: user != null ? [user['avatar_urls']['s'] ?? ''] : [],
                      remainingCount: discussion['reply_count'] ?? 0,
                      forumTitle: discussion['Forum']['title'] ?? 'General',
                      postDate: formattedDate,
                      reactionCount: user['reaction_score'] ?? 0,
                      replyCount: discussion['reply_count'] ?? 0,
                      username: user['username'] ?? 'Anonymous',
                      viewUrl: discussion['view_url'] ?? '',
                      threadId: discussion['thread_id'] ?? '',
                    );
                  },
                ),
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PostThreadScreen()),
        );
      },
      tooltip: 'Post a Thread',
      backgroundColor: const Color(0xE40A5338),
      child: const Icon(Icons.add, color: Colors.white),
    ),
  );
}

}

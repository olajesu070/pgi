import 'package:flutter/material.dart';
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
      if (data.isEmpty) {
        discussions = [];  // Handle case for empty threads (204 No Content)
        errorMessage = 'No discussions available at the moment.';
      } else {
        discussions = data as List<Map<String, dynamic>>; // Handle normal data
      }
      isLoading = false;
    });
  } catch (e) {
    setState(() {
      errorMessage = 'Failed to load discussions. Please try again later.';
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
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Handle search action
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // Handle more options action
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())  // Loading state
            : discussions.isEmpty
                ? Center(child: Text(errorMessage.isNotEmpty ? errorMessage : 'No discussions available.'))  // Empty or error message
                : ListView.builder(
                    itemCount: discussions.length,
                    itemBuilder: (context, index) {
                      final discussion = discussions[index];
                      return DiscussionCard(
                        title: discussion['title'],
                        avatars: discussion['avatars'] ?? [],
                        remainingCount: discussion['remainingCount'] ?? 0,
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

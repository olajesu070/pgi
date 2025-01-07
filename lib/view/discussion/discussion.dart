import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pgi/core/utils/bbcode_parser.dart';
import 'package:pgi/services/api/xenforo_thread_api.dart';
import 'package:pgi/view/explore/oroganiser_detail_screen.dart';

class DiscussionDetailScreen extends StatefulWidget {
  final int threadId;

  const DiscussionDetailScreen({super.key, required this.threadId});

  @override
  State<DiscussionDetailScreen> createState() => _DiscussionDetailScreenState();
}

class _DiscussionDetailScreenState extends State<DiscussionDetailScreen> {
  bool _isLoading = true;
  bool _hasError = false;
  Map<String, dynamic>? _threadData;
  final TextEditingController _messageController = TextEditingController();
  String? _replyToMessageId;

  @override
  void initState() {
    super.initState();
    _fetchThreadDetails();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _handleLike(Map<String, dynamic> reply) {
    debugPrint('Liked reply by ${reply['username']}');
  }

  void _handleReply(Map<String, dynamic> reply) {
    setState(() {
      _replyToMessageId = reply['post_id'].toString(); // Capture the ID of the post being replied to
    });
    final quotedText = '[QUOTE="${reply['user_id']}"]${reply['message']}[/QUOTE]\n';
    _messageController.text = quotedText;
  }

  Future<void> _fetchThreadDetails() async {
    try {
      final threadService = ThreadService();
      final threadDetails = await threadService.getThreadDetails(
        threadId: widget.threadId,
        withPosts: true,
        withFirstPost: true,
        order: 'desc',
      );
      setState(() {
        _threadData = threadDetails;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  Future<void> _sendMessage(int threadId) async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    try {
      final threadService = ThreadService();
      await threadService.addReply(threadId: threadId, message: message);
      _messageController.clear();
      _replyToMessageId = null;
      _fetchThreadDetails(); // Refresh the thread to show the new post
    } catch (e) {
      print('Error sending message: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to send message. Please try again.')),
      );
    }
  }

 @override
Widget build(BuildContext context) {
  final threadId = _threadData?['thread']['thread_id'] ?? 0;

  return Scaffold(
    appBar: AppBar(
      title: Text(
        _threadData?['thread']['title'] ?? 'loading...',
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
    ),
    body: SafeArea(
      child: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _hasError
                    ? const Center(child: Text('An error occurred while fetching data.'))
                    : SingleChildScrollView(
                        child: _buildThreadDetails(),
                      ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: _buildMessageInput(threadId),
          ),
        ],
      ),
    ),
  );
}


  Widget _buildThreadDetails() {
    final replies = _threadData?['posts'] as List<dynamic>? ?? [];

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            replies.isEmpty
                ? const Text('No post available.')
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: replies.length,
                    itemBuilder: (context, index) {
                      final reply = replies[index];
                      return _buildReplyCard(reply);
                    },
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildReplyCard(Map<String, dynamic> reply) {
    final String message = reply['message'] ?? 'No content available';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(
                    reply['User']?['avatar_urls']['o'] ?? 'https://via.placeholder.com/150',
                  ),
                  radius: 20,
                ),
                const SizedBox(width: 10),
                
               Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OrganizerDetailsScreen(userId: reply['user_id']),
                        ),
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          reply['username'] ?? 'Anonymous',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Posted on ${DateFormat('yyyy-MM-dd – kk:mm').format(DateTime.fromMillisecondsSinceEpoch(reply['post_date'] * 1000))}',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),

              ],
            ),
            const SizedBox(height: 10),
            Text.rich(
              TextSpan(
                children: BBCodeParser.parseBBCode(message),
              ),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () {
                  _handleReply(reply);
                },
                icon: const Icon(Icons.reply, size: 16),
                label: const Text('Reply'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput(int threadId) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Enter your message...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () => _sendMessage(threadId),
          ),
        ],
      ),
    );
  }
}

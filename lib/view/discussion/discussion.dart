import 'package:flutter/material.dart';
import 'package:pgi/services/api/xenforo_thread_api.dart';

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

  @override
  void initState() {
    super.initState();
    _fetchThreadDetails();
  }

String? _extractQuotedMessage(String message) {
  final quoteRegExp = RegExp(r'\[QUOTE=\"(.+?)\".*?\](.+?)\[\/QUOTE\]');
  final match = quoteRegExp.firstMatch(message);
 

  if (match != null) {
    final userId = match.group(1);
    final quotedMessage = match.group(2);
    return 'Quoted by User $userId: $quotedMessage';
  }
  return null;
}

String _removeQuoteFromMessage(String message) {
  final quoteRegExp = RegExp(r'\[QUOTE=\s?(.+?)\s?(.+?)\]');
  return message.replaceAll(quoteRegExp, '').trim();
}

void _handleLike(Map<String, dynamic> reply) {
  // Logic to handle like functionality
  debugPrint('Liked reply by ${reply['username']}');
}

void _handleReply(Map<String, dynamic> reply) {
  // Logic to open reply input and pre-fill with quoted text
  final quotedText = '[Quote: ${reply['user_id']} ${reply['message']}]';
  debugPrint('Replying with: $quotedText');
}


  Future<void> _fetchThreadDetails() async {
    try {
      final threadService = ThreadService();
      final threadDetails = await threadService.getThreadDetails(
        threadId: widget.threadId,
        withPosts: true,
        withFirstPost: true,
        order: 'desc', // Latest posts first
      );
      setState(() {
        _threadData = threadDetails;
        _isLoading = false;
        print(_threadData);
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _threadData?['thread']['title'] ?? 'loading...',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _hasError
              ? const Center(
                  child: Text('An error occurred while fetching data.'),
                )
              : _buildThreadDetails(),
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
            // Post Content
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
  final String? quotedMessage = _extractQuotedMessage(message);

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
              // Avatar
              CircleAvatar(
                backgroundImage: NetworkImage(
                  reply['User']?['avatar_urls']['o'] ?? 'https://via.placeholder.com/150',
                ),
                radius: 20,
              ),
              const SizedBox(width: 10),
              // Username and Post Date
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reply['username'] ?? 'Anonymous',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Posted on ${reply['post_date'] ?? ''}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              // Like Icon
              IconButton(
                icon: const Icon(Icons.thumb_up_alt_outlined),
                onPressed: () {
                  _handleLike(reply);
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Quoted Message
          if (quotedMessage != null)
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                quotedMessage,
                style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
              ),
            ),
          // Actual Message
          Text(
            _removeQuoteFromMessage(message),
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 10),
          // Reply Button
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

}

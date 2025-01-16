import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pgi/core/utils/bbcode_parser.dart';
import 'package:pgi/services/api/xenforo_thread_api.dart';
import 'package:pgi/view/explore/oroganiser_detail_screen.dart';
import 'package:pgi/view/widgets/custom_app_bar.dart';

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
  late String _quotedText;

  @override
  void initState() {
    super.initState();
    _setStatusBarStyle();
    _fetchThreadDetails();
  }

  void _setStatusBarStyle() {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.black,  // Transparent status bar
      statusBarIconBrightness: Brightness.light,  // Light icons for dark backgrounds
      statusBarBrightness: Brightness.dark,  // Adjust for iOS
    ),
  );
}

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  String _stripBBCode(String message) {
  final bbCodeRegex = RegExp(r'\[.*?\]'); // Matches BBCode tags like [b], [i], [quote], etc.
  return message.replaceAll(bbCodeRegex, '').trim(); // Remove BBCode tags
}


 Future<void> _handleReaction(Map<String, dynamic> reply, int reactionType) async {
  final postId = reply['post_id'];
  final username = reply['username'] ?? 'Unknown User';
  final action = reactionType == 1 ? 'liked' : 'disliked';
  
  debugPrint('User $username has $action post $postId');
  try {
     final threadService = ThreadService();
     final response = await threadService.reactOnPost(postId: postId, reactionId: 1);
  if (response['success'] == true) {
           // Message was successfully sent
           _showToast('$username has $action a post');
              _replyToMessageId = null;
              _fetchThreadDetails(); // Refresh the thread to show the new post
            } else {
              _showToast('Failed to react to message. Try again.');
            }
    } catch (e) {
      _showToast('An error occurred: $e');
    }
  } 


  void _handleReply(Map<String, dynamic> reply) {
    setState(() {
      _replyToMessageId = reply['post_id'].toString(); // Capture the ID of the post being replied to
    });
    final quotedText = '[QUOTE="${reply['user_id']}"]${reply['message']}[/QUOTE]\n';
    _quotedText=quotedText;
    // _messageController.text = quotedText;
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
     if (_messageController.text.isEmpty) {
        return;
      }

    if (_quotedText != '') {
      _messageController.text = '$_quotedText\n${_messageController.text}';
    }

        final String message = _messageController.text;
      _messageController.clear();

    try {
      final threadService = ThreadService();
      final response = await threadService.addReply(threadId: threadId, message: message);

        if (response['success'] == true) {
           // Message was successfully sent
           _showToast('Message sent successfully');
              _replyToMessageId = null;
              _fetchThreadDetails(); // Refresh the thread to show the new post
            } else {
              _showToast('Failed to send message. Try again.');
            }
          } catch (e) {
            _showToast('An error occurred: $e');
          }
  }

  void _showToast(String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message)),
  );
}

 @override
Widget build(BuildContext context) {
  final threadId = _threadData?['thread']['thread_id'] ?? 0;

  return Scaffold(
    body: SafeArea(
      child: Column(
        children: [
          CustomAppBarBody(
            title: _threadData?['thread']['title'] ?? 'loading...',
          ),
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
            padding: const EdgeInsets.only(bottom: 1),
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
  final bool isUnread = reply['is_unread'] ?? false;
  final int reactionScore = reply['reaction_score'] ?? 0;

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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reply['username'] ?? 'Anonymous',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Text(
                        'Posted on ${DateFormat('yyyy-MM-dd – kk:mm').format(DateTime.fromMillisecondsSinceEpoch(reply['post_date'] * 1000))}',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(width: 10),
                      
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isUnread ? Colors.red : Colors.green,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child:  Text(
                            isUnread ? 'Unread' : 'Read',
                            style: const TextStyle(color: Colors.white, fontSize: 10),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          SelectableText.rich(
            TextSpan(children: BBCodeParser.parseBBCode(message)),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.thumb_up, color: Colors.blue),
                    onPressed: () => _handleReaction(reply, 1),
                  ),
                  // IconButton(
                  //   icon: const Icon(Icons.thumb_down, color: Colors.red),
                  //   onPressed: () => _handleReaction(reply, -1),
                  // ),
                  Text('$reactionScore'),
                ],
              ),
              TextButton.icon(
                onPressed: () {
                  _handleReply(reply);
                },
                icon: const Icon(Icons.reply, size: 16),
                label: const Text('Reply'),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

 Widget _buildMessageInput(int threadId) {
  return Column(
    children: [
      if (_replyToMessageId != null) _buildQuotedMessage(), // Show quoted message if set
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                minLines: 1,
                maxLines: null,
                decoration: InputDecoration(
                  hintText: 'Enter your message...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(30.0)),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: () => _sendMessage(threadId),
            ),
          ],
        ),
      ),
    ],
  );
}


  Widget _buildQuotedMessage() {
  return Container(
    padding: const EdgeInsets.all(8.0),
    margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
    decoration: BoxDecoration(
      color: Colors.grey.shade200,
      borderRadius: BorderRadius.circular(8.0),
    ),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Replying to ${_threadData?['posts']?.firstWhere((post) => post['post_id'].toString() == _replyToMessageId)['username'] ?? 'Unknown User'}',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
              ),
              Text(
                _stripBBCode(_threadData?['posts']?.firstWhere((post) => post['post_id'].toString() == _replyToMessageId)['message'] ?? ''),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            setState(() {
              _replyToMessageId = null;
              _quotedText = '';
            });
          },
        ),
      ],
    ),
  );
}

}

import 'package:flutter/material.dart';
import 'package:pgi/core/utils/status_bar_util.dart';
import 'package:pgi/data/models/user_state.dart';
import 'package:pgi/services/api/xenforo_conversation_service.dart';
import 'package:pgi/view/explore/oroganiser_detail_screen.dart';
import 'package:pgi/view/widgets/custom_app_bar.dart';
import 'package:provider/provider.dart';


class ChatPage extends StatefulWidget {
  final String title;
  final int messsageId;

  const ChatPage({super.key, required this.title, required this.messsageId});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ConversationService _conversationService = ConversationService();
  final ScrollController _scrollController = ScrollController(); // Added scroll controller
  bool isLoading = true;
  List<dynamic> messages = [];

  @override
  void initState() {
    super.initState();
    StatusBarUtil.setLightStatusBar();
    _fetchChat();
  }

  void _navigateToUserDetails(int userId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => OrganizerDetailsScreen(userId: userId)),
    );
  }

  Future<void> _fetchChat() async {
    setState(() {
      // isLoading = true;
    });
    try {
      final chatMessages = await _conversationService.getConversationMessagesById(widget.messsageId);
      setState(() {
        messages = chatMessages['messages'] ?? [];
        isLoading = false;
      });
      _scrollToBottom(); // Scroll to the latest message
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Failed to load messages: $e');
    }
  }

  void _sendMessage() async {
    if (_messageController.text.isEmpty) {
      return;
    }

    final String messageText = _messageController.text;

    // Add the message locally to the end of the list
    setState(() {
      messages.add({
        'user_id': Provider.of<UserState>(context, listen: false).userDetails?['me']['user_id'] ?? 0,
        'message_parsed': messageText,
        'User': Provider.of<UserState>(context, listen: false).userDetails?['me'] ?? [],
      });
    });

    _messageController.clear(); // Clear the input field
    _scrollToBottom(); // Scroll to the latest message

    try {
      final response = await _conversationService.replyToConversation(
        conversationId: widget.messsageId,
        message: messageText,
      );

      if (response['success'] == true) {
        // _showToast('Message sent successfully');
        _fetchChat(); // Refresh messages from the server
      } else {
        _showToast('Failed to send message. Try again.');
      }
    } catch (e) {
      _showToast('An error occurred: $e');
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userState = Provider.of<UserState>(context);
    final userId = userState.userDetails?['me']['user_id'] ?? 0;

    return Scaffold(
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  CustomAppBarBody(
                    title: widget.title,
                  ),
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController, // Attach the scroll controller
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        final user = message['User'] ?? '';
                        final bool isSender = message['user_id'] == userId;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                          child: Row(
                            mainAxisAlignment: isSender ? MainAxisAlignment.end : MainAxisAlignment.start,
                            children: [
                              if (!isSender)
                                GestureDetector(
                                  onTap: () => _navigateToUserDetails(user['user_id']),
                                  child: CircleAvatar(
                                    backgroundImage: NetworkImage(user['avatar_urls']['s']),
                                    radius: 20,
                                  ),
                                ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Container(
                                  padding: const EdgeInsets.all(12.0),
                                  decoration: BoxDecoration(
                                    color: isSender ? Colors.blue[100] : Colors.green[100],
                                    borderRadius: BorderRadius.circular(16.0),
                                  ),
                                  child: Text(
                                    message['message_parsed'] ?? '',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                              ),
                              if (isSender) const SizedBox(width: 8),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
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
                              hintText: 'Type a message...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.send),
                          onPressed: _sendMessage,
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

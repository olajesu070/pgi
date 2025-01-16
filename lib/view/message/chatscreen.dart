import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
   bool isLoading = true; // Loading state
   List<dynamic> messages = [];

  @override
    void initState() {
      super.initState();
      _setStatusBarStyle();
      _fetchChat();
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

  void _navigateToUserDetails(int userId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => OrganizerDetailsScreen(userId: userId)), // Implement your UserDetailsScreen
    );
  }

  void _fetchChat() async {
    setState(() {
      isLoading = true;
    });
    try {
      final chatMessages = await _conversationService.getConversationMessagesById(widget.messsageId);
      setState(() {
        messages = chatMessages['messages'] ?? [];
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      // Handle error appropriately
      print('Failed to load messages: $e');
    }
  }

   void _sendMessage() async {
  if (_messageController.text.isEmpty) {
    return;
  }

  setState(() {
    messages.insert(0, {
      'user_id': Provider.of<UserState>(context, listen: false).userDetails?['me']['user_id'] ?? 0,
      'message_parsed': _messageController.text,
      'User': Provider.of<UserState>(context, listen: false).userDetails?['me'] ?? [],
    });
  });

  final String message = _messageController.text;
  _messageController.clear();

  try {
    final response = await _conversationService.replyToConversation(
      conversationId: widget.messsageId,
      message: message,
    );

    if (response['success'] == true) {
      // Message was successfully sent
      _showToast('Message sent successfully');
      _fetchChat();
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
    final userState = Provider.of<UserState>(context);
    final userId = userState.userDetails?['me']['user_id'] ?? 0;
    
    return Scaffold(
      body: SafeArea(child:  isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
          children: [
            CustomAppBarBody(
              title: widget.title,
            ),
            Expanded(
          child: ListView.builder(
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
                  message['message'] ?? '',
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
               minLines: 1, // Start with a single line
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
      )
     
        );
      }
    }

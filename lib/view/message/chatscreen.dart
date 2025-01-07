import 'package:flutter/material.dart';
import 'package:pgi/services/api/xenforo_conversation_service.dart';

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
      _fetchChat();
    }

  void _fetchChat() async {
    setState(() {
      isLoading = true;
    });
    try {
      final chatMessages = await _conversationService.getConversationMessageById(widget.messsageId);
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

  void _sendMessage() {
    if (_messageController.text.isNotEmpty) {
      setState(() {
        messages.add({'sender': 'User1', 'message': _messageController.text});
      });
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                bool isSender = messages[index]['sender'] == 'User1';
                return Align(
                  alignment:
                      isSender ? Alignment.centerLeft : Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 16.0),
                    child: Container(
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: isSender ? Colors.blue[100] : Colors.green[100],
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: Text(
                        messages[index]['message']!,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
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
    );
  }
}

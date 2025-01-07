import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pgi/services/api/xenforo_conversation_service.dart';
import 'package:pgi/view/message/chatscreen.dart';
import 'package:pgi/view/widgets/message_card.dart';

class MessageScreen extends StatefulWidget {
  const MessageScreen({super.key});

  @override
  _MessageScreenState createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final ConversationService _conversationService = ConversationService();
  bool isSearching = false;
  bool isLoading = true; // Loading state
  int currentPage = 1;
  int totalPages = 1;
  List<dynamic> conversations = [];

  @override
  void initState() {
    super.initState();
    _fetchConversations();
  }

  Future<void> _fetchConversations() async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await _conversationService.getConversations(page: currentPage);
      setState(() {
        conversations = response['conversations'] ?? [];
        totalPages = response['pagination']['last_page'] ?? 1;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching conversations: $e');
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
        title: isSearching
            ? TextField(
                decoration: const InputDecoration(
                  hintText: "Search...",
                  border: InputBorder.none,
                ),
                onSubmitted: (query) {
                  setState(() {
                    isSearching = false;
                  });
                },
              )
            : const Text("Message"),
        actions: [
          IconButton(
            icon: Icon(isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                isSearching = !isSearching;
              });
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: currentPage > 1
                        ? () {
                            setState(() {
                              currentPage--;
                            });
                            _fetchConversations();
                          }
                        : null,
                    child: const Text("Previous"),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text("Page $currentPage of $totalPages"),
                  ),
                  ElevatedButton(
                    onPressed: currentPage < totalPages
                        ? () {
                            setState(() {
                              currentPage++;
                            });
                            _fetchConversations();
                          }
                        : null,
                    child: const Text("Next"),
                  ),
                ],
              ),
            ),
            const Divider(thickness: 1),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator()) // Loading indicator
                  : conversations.isEmpty
                      ? const Center(child: Text('No conversations available'))
                      : ListView.builder(
                          itemCount: conversations.length,
                          itemBuilder: (context, index) {
                            final conversation = conversations[index];
                            return MessageCard(
                              avatarUrl: conversation['Starter']['avatar_urls']['s'] ??
                                  'https://via.placeholder.com/50',
                              title: conversation['title'] ?? 'No Title',
                              creatorName: conversation['username'] ?? 'Unknown',
                              date: DateFormat('yyyy-MM-dd hh:mma').format(
                                DateTime.fromMillisecondsSinceEpoch(conversation['last_message_date'] * 1000),
                              ),
                              repliesCount: conversation['reply_count'] ?? 0,
                              participantsCount: conversation['recipient_count'] ?? 0,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ChatPage(
                                      title: conversation['title'] ?? 'Chat',
                                      messsageId: conversation['conversation_id'] ?? 0,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

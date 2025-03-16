import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pgi/services/api/xenforo_conversation_service.dart';
import 'package:pgi/view/message/chatscreen.dart';
import 'package:pgi/view/widgets/message_card.dart';
import 'dart:async';

class MessageScreen extends StatefulWidget {
  const MessageScreen({super.key});

  @override
  _MessageScreenState createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final ConversationService _conversationService = ConversationService();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  bool isSearching = false;
  bool isLoading = true;
  int currentPage = 1;
  int totalPages = 1;
  String _searchQuery = ''; // Search query state
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
      final response = await _conversationService.getConversations(
        page: currentPage,
        search: _searchQuery, // Pass search query
      );

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

  /// Handles search with a debounce effect (to avoid excessive API calls)
  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _searchQuery = query;
        currentPage = 1; // Reset pagination on search
      });
      _fetchConversations();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xBE669999),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: isSearching
            ? TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: "Search messages...",
                  border: InputBorder.none,
                ),
                onChanged: _onSearchChanged, // Live search
              )
            : const Text(
                "Messages",
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
        actions: [
          IconButton(
            icon: Icon(isSearching ? Icons.close : Icons.search, color: Colors.white),
            onPressed: () {
              setState(() {
                isSearching = !isSearching;
                if (!isSearching) {
                  _searchController.clear();
                  _onSearchChanged(''); // Reset search
                }
              });
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Pagination Controls
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

            // Conversations List
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : conversations.isEmpty
                      ? const Center(child: Text('No conversations found'))
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

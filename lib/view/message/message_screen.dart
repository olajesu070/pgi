import 'package:flutter/material.dart';
import 'package:pgi/view/message/chatscreen.dart';
import 'package:pgi/view/widgets/message_card.dart';

class MessageScreen extends StatefulWidget {
  const MessageScreen({super.key});

  @override
  _MessageScreenState createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  bool isSearching = false;

  // Sample data for pagination and messages
  int currentPage = 1;
  int totalPages = 5;

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
                  // Handle search action
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
      body: Column(
        children: [
          // Pagination controls
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: currentPage > 1
                      ? () => setState(() {
                          currentPage--;
                        })
                      : null,
                  child: const Text("Previous"),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text("Page $currentPage of $totalPages"),
                ),
                ElevatedButton(
                  onPressed: currentPage < totalPages
                      ? () => setState(() {
                          currentPage++;
                        })
                      : null,
                  child: const Text("Next"),
                ),
              ],
            ),
          ),
          const Divider(thickness: 1),
          // Message list
          Expanded(
            child: ListView.builder(
              itemCount: 10, // Replace with your data count
              itemBuilder: (context, index) {
                return MessageCard(
                  avatarUrl: 'https://via.placeholder.com/50', // Sample avatar
                  title: 'Message Title $index',
                  creatorName: 'Creator $index',
                  date: '12/10/2023',
                  repliesCount: 5 + index,
                  participantsCount: 4,
                  onTap: () {
                     // Navigate to the ChatPage when the message card is tapped
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatPage(title: 'Chat with Creator $index'),
                        ),
                      );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}



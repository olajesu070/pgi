import 'package:flutter/material.dart';
import 'package:pgi/view/widgets/gallery_card.dart';
import 'package:pgi/view/widgets/gallery_details_screen.dart';

class GalleryScreen extends StatelessWidget {
  const GalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Albums'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Handle the addition of a new album
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: galleryItems.length,
        itemBuilder: (context, index) {
          final item = galleryItems[index];
          return GalleryCard(
            imageUrl: item['imageUrl'],
            title: item['title'],
            pictureCount: item['pictureCount'],
            videoCount: item['videoCount'],
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GalleryDetailScreen(title: item['title']),
                ),
              );
            },
          );
        },
      ),
    );
  }
}


final List<Map<String, dynamic>> galleryItems = [
  {
    'imageUrl': 'https://picsum.photos/100/100',
    'title': 'Vacation 2024',
    'pictureCount': 12,
    'videoCount': 5,
  },
  {
    'imageUrl': 'https://picsum.photos/101/101',
    'title': 'Family Events',
    'pictureCount': 20,
    'videoCount': 8,
  },
  {
    'imageUrl': 'https://picsum.photos/102/102',
    'title': 'Nature Photography',
    'pictureCount': 15,
    'videoCount': 3,
  },
  // Add more album entries as needed
];
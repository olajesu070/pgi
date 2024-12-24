import 'package:flutter/material.dart';

class GalleryDetailScreen extends StatelessWidget {
  final String title;

  GalleryDetailScreen({super.key, required this.title});

  final List<String> galleryItems = [
    'https://picsum.photos/100/100', // Example images
    'https://picsum.photos/101/101',
    'https://picsum.photos/102/102',
    // Add more image URLs as needed
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, // Display 3 items per row
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: galleryItems.length + 1, // Extra slot for the "Add" button
          itemBuilder: (context, index) {
            if (index == galleryItems.length) {
              // "Add" button at the end of the grid
              return InkWell(
                onTap: () {
                  _addImageOrVideo(context);
                },
                child: Container(
                  color: Colors.grey.shade300,
                  child: const Icon(
                    Icons.add,
                    size: 36,
                    color: Colors.grey,
                  ),
                ),
              );
            } else {
              // Display each image/video item in the grid
              return ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  galleryItems[index],
                  fit: BoxFit.cover,
                ),
              );
            }
          },
        ),
      ),
    );
  }

  // Method to handle adding an image or video from the phone gallery
  void _addImageOrVideo(BuildContext context) {
    // Show an action to pick an image or video
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text('Add Image'),
              onTap: () {
                // Handle image selection from phone gallery
                Navigator.pop(context); // Close the bottom sheet
              },
            ),
            ListTile(
              leading: const Icon(Icons.video_library),
              title: const Text('Add Video'),
              onTap: () {
                // Handle video selection from phone gallery
                Navigator.pop(context); // Close the bottom sheet
              },
            ),
          ],
        );
      },
    );
  }
}

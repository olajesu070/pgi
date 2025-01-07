import 'package:flutter/material.dart';
import 'package:pgi/services/api/xenforo_media_service.dart';
import 'package:pgi/view/widgets/gallery_card.dart';
import 'package:pgi/view/widgets/gallery_details_screen.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  final mediaService = MediaService();
  List<dynamic> mediaAlbums = []; // State to hold fetched albums
  bool isLoading = true; // Loading indicator

  @override
  void initState() {
    super.initState();
    _fetchMedia();
  }

 Future<void> _fetchMedia() async {
  try {
    final response = await mediaService.fetchAllMediaAlbums();
    
    // Extract the 'albums' field from the response
    final albums = response['albums'] as List<dynamic>;

    setState(() {
      mediaAlbums = albums; // Update state with the list of albums
      isLoading = false;
    });
  } catch (e) {
    print('Error fetching media: $e');
    setState(() {
      isLoading = false;
    });
  }
}


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
      body: SafeArea(
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : mediaAlbums.isEmpty
                ? const Center(
                    child: Text('No albums available.'),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: mediaAlbums.length,
                    itemBuilder: (context, index) {
                      final album = mediaAlbums[index];
                      return GalleryCard(
                        imageUrl: album['thumbnail_url'] ?? 'https://via.placeholder.com/150',
                        title: album['title'] ?? 'Untitled Album',
                        avatarUrl: album['User']?['avatar_urls']?['s'] ?? 'https://via.placeholder.com/50',
                        username: album['username'] ?? 'Unknown User',
                        mediaCount: album['media_count'] ?? 0,
                        viewCount: album['view_count'] ?? 0,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => GalleryDetailScreen(title: album['title'], albumId: album['album_id']),
                            ),
                          );
                        },
                      );
                    },
                  ),
      ),
    );
  }
}

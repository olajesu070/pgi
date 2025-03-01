import 'package:flutter/material.dart';
import 'package:pgi/services/api/xenforo_media_service.dart';
import 'package:pgi/view/gallery/media_upload_screen.dart';
import 'package:pgi/view/widgets/gallery_card.dart';
import 'package:pgi/view/widgets/gallery_details_screen.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  final mediaService = MediaService();
  List<dynamic> mediaAlbums = []; // Albums data
  List<dynamic> mediaCategories = []; // Categories data
  bool isLoading = true; // Loading indicator

  @override
  void initState() {
    super.initState();
    _fetchMedia();
    _fetchMediaCategories();
  }

  Future<void> _fetchMedia() async {
    try {
      final response = await mediaService.fetchAllMediaAlbums();
      final albums = response['albums'] as List<dynamic>;

      setState(() {
        mediaAlbums = albums;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching media: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _fetchMediaCategories() async {
    try {
      final response = await mediaService.fetchAllMediaCategories();
      final categories = response['categories'] as List<dynamic>;

      setState(() {
        mediaCategories = categories;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching media categories: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
              appBar: AppBar(
                title: const Text('Gallery', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),textAlign: TextAlign.center,),
                backgroundColor: const Color(0xBE669999),
                  centerTitle: true,
                elevation: 0,
              bottom: PreferredSize(
              preferredSize: const Size.fromHeight(60.0), // Adjust height as needed
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), // Adjust spacing
                      padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 8), // Adjust spacing
                      decoration: BoxDecoration(
                        color: const Color(0x45AFAEAE), // Gray background color
                        borderRadius: BorderRadius.circular(30), // Rounded corners
                  
                    ),
                    child: TabBar(
                      dividerColor: Colors.transparent,
                      indicator: BoxDecoration(
                        color: Colors.white, // White color for the active tab
                        borderRadius: BorderRadius.circular(25), // Rounded indicator
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.4),
                            spreadRadius: 1,
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      labelColor: Colors.black,
                      unselectedLabelColor: Colors.black.withOpacity(0.6),
                      labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      tabs:  [
                        Container(
                                  height: 40,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: const Color(0x00FFFFFF), // Background hint color for unselected tab
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Text('Categories'),
                                ),
                                Container(
                                  height: 40,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: const Color(0x00FFFFFF),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Text('Albums'),
                                ),
                      ],
                      indicatorColor: Colors.transparent,
                    ),
                  ),
                ),

                    ),
              body: SafeArea(
              child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : TabBarView(
                  children: [
                    // Categories Tab
                    _buildCategoriesList(),
                    // Albums Tab
                    _buildAlbumsList(),
                  ],
                ),
              ),

         floatingActionButton: Builder(
          builder: (BuildContext context) {
            return FloatingActionButton(
              onPressed: () {
                int currentIndex = DefaultTabController.of(context).index;

                if (currentIndex == 1) {
                  // If Albums tab is selected, send mediaAlbums
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MediaUploadPage(albums: mediaAlbums)),
                  );
                } else {
                  // If Categories tab is selected, send mediaCategories
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MediaUploadPage(categories: mediaCategories)),
                  );
                }
              },
              backgroundColor: const Color(0xE40A5338),
              child: const Icon(Icons.add, color: Colors.white),
            );
          },
        ),

      ),
    );
  }

 // Widget to display categories
Widget _buildCategoriesList() {
  if (mediaCategories.isEmpty) {
    return const Center(child: Text('No categories available.'));
  }

  return ListView.builder(
    padding: const EdgeInsets.all(16),
    itemCount: mediaCategories.length,
    itemBuilder: (context, index) {
      if (index == 0) {
        
      // Render normal category cards for other indices
      final category = mediaCategories[index];
        // Special "Show All" card at index 0
        return Card(
          color: Colors.blueAccent, // Optional: Change card color to highlight
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            title: const Text(
              'Show All Media',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
            subtitle: const Text(
              'View all media items across categories',
              style: TextStyle(color: Colors.white70),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GalleryDetailScreen(
                    title: 'All Media',
                    albumId: category['category_id'],
                    mediaType: 'all',
                  ),
                ),
              );
            },
          ),
        );
      }

      // Render normal category cards for other indices
      final category = mediaCategories[index];
      return Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: ListTile(
          title: Text(
            category['title'] ?? 'Untitled Category',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${category['media_count'] ?? 0} media items'),
              Text('Allowed types: ${category['allowed_types']?.join(', ') ?? 'None'}'),
            ],
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GalleryDetailScreen(
                  title: category['title'],
                  albumId: category['category_id'],
                  mediaType: 'category',
                ),
              ),
            );
          },
        ),
      );
    },
  );
}

  
  // Widget to display albums
  Widget _buildAlbumsList() {
    if (mediaAlbums.isEmpty) {
      return const Center(child: Text('No albums available.'));
    }

    return ListView.builder(
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
                builder: (context) => GalleryDetailScreen(
                  title: album['title'], 
                  albumId: album['album_id'], 
                  mediaType: 'album',),
              ),
            );
          },
        );
      },
    );
  }
}

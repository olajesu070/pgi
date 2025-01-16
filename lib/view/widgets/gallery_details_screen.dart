import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:pgi/view/widgets/custom_app_bar.dart';
import 'image_viewer.dart';
import 'video_player_screen.dart';
import 'package:pgi/services/api/xenforo_media_service.dart';

class GalleryDetailScreen extends StatefulWidget {
  final String title;
  final int albumId;
  final String mediaType;

  const GalleryDetailScreen({super.key, required this.title, required this.albumId, required this.mediaType});

  @override
  State<GalleryDetailScreen> createState() => _GalleryDetailScreenState();
}

class _GalleryDetailScreenState extends State<GalleryDetailScreen> {
  bool _isLoading = true;
  bool _hasError = false;
  List<Map<String, dynamic>> _mediaItems = [];
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    if(widget.mediaType == 'album'){
      _fetchMedia();
    }else{
      _fetchCategoryMedia();
    }
  }

  Future<void> _fetchMedia() async {
    try {
      final mediaService = MediaService();
      final response = await mediaService.fetchMediaAlbumById(widget.albumId);
      final media = response['media'];

      setState(() {
        _mediaItems = List<Map<String, dynamic>>.from(media);
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching media: $e');
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

    Future<void> _fetchCategoryMedia() async {
    try {
      final mediaService = MediaService();
      final response = await mediaService.fetchMediaCategoriesById(widget.albumId);
      final media = response['media'];

      setState(() {
        _mediaItems = List<Map<String, dynamic>>.from(media);
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching media: $e');
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBarBody(
            title: widget.title,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _hasError
                      ? const Center(child: Text('Failed to load media'))
                      : GridView.builder(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                          itemCount: _mediaItems.length,
                          itemBuilder: (context, index) {
                            final item = _mediaItems[index];
                            final String thumbnailUrl = item['thumbnail_url'] ?? 'https://via.placeholder.com/150';
                            final String mediaType = item['media_type'] ?? '';
                            final String mediaUrl = item[mediaType == 'embed'?'media_embed_url':'media_url'] ?? '';
                            final String title = item['title'] ?? '';

                            final isImage = mediaType == 'image';
                            // final isEmbed = mediaType == 'embed';

                            return GestureDetector(
                              onTap: () {
                                if (isImage) {
                                  _viewImage(context, title, mediaUrl);
                                } else {
                                  _viewVideo(context, mediaUrl);
                                }
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: isImage
                                    ? Image.network(
                                        thumbnailUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Image.asset(
                                            'assets/gallery.jpeg',
                                            fit: BoxFit.cover,
                                          );
                                        },
                                      )
                                    : Stack(
                                        children: [
                                          Image.network(
                                            thumbnailUrl,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) {
                                              return Image.asset(
                                                'assets/gallery.jpeg',
                                                fit: BoxFit.cover,
                                              );
                                            },
                                          ),
                                          Container(
                                            color: Colors.black.withOpacity(0.5),
                                            child: const Center(
                                              child: Icon(
                                                Icons.play_circle_outline,
                                                size: 50,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            );
                          },
                        ),
            ),
          ),
          ]
        ),
      ),
    );
  }

    Future<void> _viewImage(BuildContext context, String title, String imageUrl) async {
      final String apiKey = dotenv.env['CLIENT_ID'] ?? '7887150025286687';
      final accessToken = await _secureStorage.read(key: 'accessToken');
      print('view url: $imageUrl' );

      final headers = {'Authorization': 'Bearer $accessToken', 'x-api-key': apiKey};

      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(child: CircularProgressIndicator());
        },
      );

      try {
        final response = await http.get(Uri.parse(imageUrl), headers: headers);

        Navigator.pop(context); // Dismiss the loading dialog

        if (response.statusCode == 200) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ImageViewer(title: title, imageBytes: response.bodyBytes),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to load image: ${response.statusCode}')),
          );
        }
      } catch (e) {
        Navigator.pop(context); // Dismiss the loading dialog
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }

  Future<void> _viewVideo(BuildContext context, String videoUrl) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoPlayerScreen(videoUrl: videoUrl),
      ),
    );
  }

}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pgi/core/utils/status_bar_util.dart';
import 'package:pgi/data/models/drop_list_model.dart';
import 'package:pgi/services/api/xenforo_media_service.dart';
import 'package:pgi/view/widgets/custom_app_bar.dart';
import 'package:pgi/view/widgets/custom_button.dart';
import 'package:pgi/view/widgets/custom_text_input.dart';

class MediaUploadPage extends StatefulWidget {
  /// Accepting both lists makes this page dynamic.
  /// When uploading to an album, pass the album list.
  /// When uploading to a category, pass the category list.
  final List<dynamic>? categories;
  final List<dynamic>? albums;

  const MediaUploadPage({
    super.key,
    this.categories,
    this.albums,
  });

  @override
  _MediaUploadPageState createState() => _MediaUploadPageState();
}

class _MediaUploadPageState extends State<MediaUploadPage> {
  /// This flag tells us which mode we are in.
  late bool isAlbumMode;
  
  /// This variable will hold the selected id (album or category)
  int? _selectedId;
  
  /// Only used in album mode to allow creating a new album.
  bool _isCreatingNewAlbum = false;

  final TextEditingController _albumNameController = TextEditingController();
  final TextEditingController _albumDescriptionController = TextEditingController();

  List<File> _selectedFiles = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    StatusBarUtil.setLightStatusBar();

    // Decide mode based on what data was passed.
    // If albums list is provided, assume album mode.
    isAlbumMode = widget.albums != null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const CustomAppBarBody(
              title: 'Upload Media',
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Build the dynamic drop-down
                    SelectDropList(
                      OptionItem(
                        id: '0',
                        title: isAlbumMode ? 'Select an album' : 'Select a category',
                      ),
                      DropListModel([
                        // List items: use the albums list in album mode,
                        // otherwise use the categories list.
                        ...((isAlbumMode ? widget.albums : widget.categories) ?? [])
                            .map((item) => OptionItem(
                                  id: isAlbumMode
                                      ? item['album_id'].toString()
                                      : item['category_id'].toString(),
                                  title: item['title'] ?? 'Untitled',
                                )),
                        // In album mode, provide an option to create a new album.
                        if (isAlbumMode)  OptionItem(id: '-1', title: 'Create new album'),
                      ]),
                      (optionItem) {
                        setState(() {
                          if (isAlbumMode && optionItem.id == '-1') {
                            // When the user selects "Create new album"
                            _selectedId = -1;
                            _isCreatingNewAlbum = true;
                          } else {
                            _selectedId = int.tryParse(optionItem.id);
                            _isCreatingNewAlbum = false;
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    // Only in album mode do we allow the creation of a new album.
                    if (isAlbumMode && (_selectedId == -1 || _isCreatingNewAlbum))
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomTextInput(
                            hintText: 'Album Name',
                            leftIcon: Icons.title,
                            controller: _albumNameController,
                            validator: (value) => value == null || value.isEmpty
                                ? 'Album name is required'
                                : null,
                          ),
                          const SizedBox(height: 8),
                          CustomTextInput(
                            hintText: 'Album Description',
                            leftIcon: Icons.description,
                            maxLines: 3,
                            controller: _albumDescriptionController,
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    // Button to pick files
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: _pickFiles,
                        icon: const Icon(Icons.add_photo_alternate, color: Color(0xFF0A5338)),
                        label: const Text(
                          'Select Photos/Videos',
                          style: TextStyle(color: Color(0xFF0A5338)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Preview selected files
                    Expanded(
                      child: _selectedFiles.isEmpty
                          ? const Center(child: Text('No files selected'))
                          : ListView.builder(
                              itemCount: _selectedFiles.length,
                              itemBuilder: (context, index) {
                                final file = _selectedFiles[index];
                                return ListTile(
                                  leading: file.path.endsWith('.mp4')
                                      ? const Icon(Icons.videocam)
                                      : const Icon(Icons.photo),
                                  title: Text(file.path.split('/').last),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () {
                                      setState(() {
                                        _selectedFiles.removeAt(index);
                                      });
                                    },
                                  ),
                                );
                              },
                            ),
                    ),
                    // Submit button
                    CustomButton(
                      label: 'Upload Media',
                      onPressed: _uploadMedia,
                    ),
                    if (_isLoading)
                      const Center(child: CircularProgressIndicator()),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'mp4'], // Supported extensions
    );

    if (result != null) {
      setState(() {
        _selectedFiles = result.paths.map((path) => File(path!)).toList();
      });
    }
  }

  Future<void> _uploadMedia() async {
    // Validation: In category mode, we expect a valid selection.
    // In album mode, either a valid album or the new album option.
    if (_selectedId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an option')),
      );
      return;
    }

    // For album mode, if creating a new album, the album name is required.
    if (isAlbumMode && _isCreatingNewAlbum && _albumNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an album name')),
      );
      return;
    }

    if (_selectedFiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one file')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Depending on the mode, prepare the correct id parameter.
      if (isAlbumMode) {
        // In album mode, if creating a new album, first create it.
        final albumId = _isCreatingNewAlbum
            ? await _createAlbum(
                _albumNameController.text,
                _albumDescriptionController.text,
              )
            : _selectedId.toString();

        // Upload files with album_id parameter
        for (var file in _selectedFiles) {
          await _uploadFile(file, 'album_id=$albumId');
        }
      } else {
        // In category mode, simply use the selected category id.
        for (var file in _selectedFiles) {
          await _uploadFile(file, 'category_id=${_selectedId.toString()}');
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Media uploaded successfully')),
      );
      _clearForm();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload media: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<String> _createAlbum(String name, String description) async {
    final mediaService = MediaService();
    final response = await mediaService.createMediaAlbum(name: name, description: description);
    // Assuming the API returns the album id under this key
    return response['album']['album_id'].toString();
  }

  Future<void> _uploadFile(File file, String idParam) async {
    final mediaService = MediaService();
    await mediaService.uploadMedia(
      filePath: file.path,
      albumId: idParam, // This parameter key can be parsed by your API
    );
  }

  void _clearForm() {
    setState(() {
      _selectedId = null;
      _isCreatingNewAlbum = false;
      _albumNameController.clear();
      _albumDescriptionController.clear();
      _selectedFiles.clear();
    });
  }
}

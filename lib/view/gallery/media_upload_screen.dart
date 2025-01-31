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
  final List<dynamic> categories;

  const MediaUploadPage({super.key, required this.categories});

  @override
  _MediaUploadPageState createState() => _MediaUploadPageState();
}

class _MediaUploadPageState extends State<MediaUploadPage> {
  int? _selectedAlbum;
  bool _isCreatingNewAlbum = false;
  final TextEditingController _albumNameController = TextEditingController();
  final TextEditingController _albumDescriptionController = TextEditingController();
  List<File> _selectedFiles = [];
  bool _isLoading = false;

    @override
  void initState() {
    super.initState();
    StatusBarUtil.setLightStatusBar();
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
            // Dropdown to select album
            SelectDropList(
              OptionItem(id: '0', title: 'Select a category'),
              DropListModel([
              ...widget.categories.map((category) => OptionItem(id: category['category_id'].toString(), title: category['title'])).toList(),
              OptionItem(id: '-1', title: 'Create new album'),
              ]),
              (optionItem) {
              setState(() {
                if (optionItem.id == '-1') {
                _selectedAlbum = -1;
                _isCreatingNewAlbum = true;
                } else {
                _selectedAlbum = int.parse(optionItem.id);
                _isCreatingNewAlbum = false;
                }
              });
              },
            ),
            const SizedBox(height: 16),
            // Create new album form
            if (_selectedAlbum == -1 || _isCreatingNewAlbum)
              Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTextInput(
                hintText: 'Album Name',
                leftIcon: Icons.title,
                controller: _albumNameController,
                validator: (value) => value == null || value.isEmpty ? 'Album name is required' : null,
                ),
                const SizedBox(height: 8),
                CustomTextInput(
                hintText: 'Album Description',
                leftIcon: Icons.title,
                maxLines: 3,
                controller: _albumDescriptionController,
                ),
                const SizedBox(height: 16),
              ],
              ),
            // File picker button
            Center(
              child: ElevatedButton.icon(
              onPressed: _pickFiles,
              icon: const Icon(Icons.add_photo_alternate, color: Color(0xFF0A5338)),
              label: const Text('Select Photos/Videos', style: TextStyle(color: Color(0xFF0A5338))),
              ),
            ),
            const SizedBox(height: 16),
            // Selected file preview
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
    if ((_selectedAlbum == null || _selectedAlbum! < 0) &&
        !_isCreatingNewAlbum) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select or create an album')),
      );
      return;
    }

    if (_isCreatingNewAlbum && _albumNameController.text.isEmpty) {
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

    // Handle file upload logic
    try {
      // Prepare the album info
      final albumId = _isCreatingNewAlbum
        ? await _createAlbum(_albumNameController.text, _albumDescriptionController.text)
        : _selectedAlbum.toString();

      // Upload each file
      for (var file in _selectedFiles) {
        if (_isCreatingNewAlbum) {
          await _uploadFile(file, 'album_id=$albumId');
        } else {
          await _uploadFile(file, 'category_id=${_selectedAlbum.toString()}');
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
    return response['album']['album_id'].toString();
  }

  Future<void> _uploadFile(File file, String id) async {
    final mediaService = MediaService();
    await mediaService.uploadMedia(
      filePath: file.path,
      albumId: id,
    );
  }

  void _clearForm() {
    setState(() {
      _selectedAlbum = null;
      _isCreatingNewAlbum = false;
      _albumNameController.clear();
      _albumDescriptionController.clear();
      _selectedFiles.clear();
    });
  }
}

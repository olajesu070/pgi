import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pgi/core/utils/status_bar_util.dart';
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
  bool _isLoading = true;

    @override
  void initState() {
    super.initState();
    StatusBarUtil.setLightStatusBar();
  }

  @override
  Widget build(BuildContext context) {
   
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Media'),
      ),
      body: SafeArea(
        child: _isLoading
       ? const Center(child: CircularProgressIndicator())
       : Column(
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
             DropdownButtonFormField<int>(
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  hintStyle: const TextStyle(color: Colors.grey),
                  prefixIcon: const Icon(
                    Icons.album,
                    color: Color(0xFFE4DFDF),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(color: Color(0xFFE4DFDF)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(color: Color(0xFFE4DFDF)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(color: Color(0xFF0A5338)),
                  ),
                  filled: true,
                  fillColor: Colors.transparent,
                ),
                value: _selectedAlbum,
                hint: const Text('Select a category'),
                onChanged: (value) {
                  setState(() {
                    _selectedAlbum = value; 
                    _isCreatingNewAlbum = false; 
                  });
                },
                items: widget.categories
                    .map((category) => DropdownMenuItem<int>(
                          value: category['category_id'],
                          child: Text(category['title']), // Display the category title
                        ))
                    .toList()
                  ..add(
                    const DropdownMenuItem<int>(
                      value: -1, // Special value for creating a new category
                      child: Text("Create New Category"),
                    ),
                  ),
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
                onPressed: _uploadMedia
                )
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

    // Handle file upload logic
    try {
      // Prepare the album info
      final albumId = _selectedAlbum != "create_new"
          ? _selectedAlbum.toString()
          : await _createAlbum(_albumNameController.text, _albumDescriptionController.text);

      // Upload each file (replace this with actual API logic)
      for (var file in _selectedFiles) {
        await _uploadFile(file, albumId);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Media uploaded successfully')),
      );
      _clearForm();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload media: $e')),
      );
    }
  }

  Future<String> _createAlbum(String name, String description) async {
    // API call to create album
    // Replace this with actual API logic
    return Future.value("new_album_id");
  }

  Future<void> _uploadFile(File file, String albumId) async {
    // API call to upload a file to the specified album
    // Replace this with actual API logic
    await Future.delayed(const Duration(seconds: 1));
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

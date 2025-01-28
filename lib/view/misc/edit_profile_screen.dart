import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pgi/core/utils/status_bar_util.dart';
import 'package:pgi/data/models/user_state.dart';
import 'package:pgi/services/api/xenforo_user_api.dart';
import 'package:pgi/view/widgets/custom_app_bar.dart';
import 'package:pgi/view/widgets/custom_button.dart';
import 'package:provider/provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  String _firstname = '';
  String _lastname = '';
  String _email = '';
  String _bio = '';
  File? _selectedImage; // For the selected avatar image
  bool _isLoading = false; // For the loading state
  final XenForoUserApi _api = XenForoUserApi();

  @override
  void initState() {
    super.initState();
    StatusBarUtil.setLightStatusBar();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true; // Start loading
    });

    try {
      // Update user info
      final userUpdateData = {
        'email': _email,
        "about": _bio,
        "custom_fields": {
          "firstname": _firstname,
          'lastname': _lastname,
        },
      };
      final userUpdateSuccess = await _api.updateUserInfo(userUpdateData);

      // Update avatar if a new image is selected
      bool avatarUpdateSuccess = true;
      if (_selectedImage != null) {
        avatarUpdateSuccess = await _api.updateUserAvatar(_selectedImage!);
      }

      if (userUpdateSuccess && avatarUpdateSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Profile updated successfully!'),
        ));
        Navigator.pop(context); // Navigate back
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Failed to update profile.'),
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('An error occurred: $e'),
      ));
    } finally {
      setState(() {
        _isLoading = false; // Stop loading
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    final userState = Provider.of<UserState>(context);
    final userDetails = userState.userDetails;
    final String firstName = userDetails?['me']['custom_fields']['firstname'] ?? '';
    final String lastName = userDetails?['me']['custom_fields']['lastname'] ?? '';
    final String email = userDetails?['me']['email'] ?? '';
    final String about = userDetails?['me']['about'] ?? '';
    final String avatarUrl = userDetails?['me']['avatar_urls']['s'] ?? 'https://picsum.photos/212';

    // Initialize fields if not set
    if (_firstname.isEmpty && _lastname.isEmpty && _email.isEmpty && _bio.isEmpty) {
      _firstname = firstName;
      _lastname = lastName;
      _email = email;
      _bio = about;
    }

   return Scaffold(
  body: SafeArea(
    child: Column(
      children: [
        const CustomAppBarBody(
          title: 'Edit Profile',
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 80),
                    // Profile Image
                    Center(
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage: _selectedImage != null
                              ? FileImage(_selectedImage!)
                              : NetworkImage(avatarUrl) as ImageProvider,
                          child: _selectedImage == null
                              ? const Icon(Icons.edit, size: 30, color: Colors.white)
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // First Name
                    TextFormField(
                      initialValue: _firstname,
                      decoration: const InputDecoration(
                        labelText: 'First Name',
                        prefixIcon: Icon(Icons.person),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _firstname = value;
                        });
                      },
                      enabled: false,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your first name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Last Name
                    TextFormField(
                      initialValue: _lastname,
                      decoration: const InputDecoration(
                        labelText: 'Last Name',
                        prefixIcon: Icon(Icons.person),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _lastname = value;
                        });
                      },
                      enabled: false,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your last name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Email
                    TextFormField(
                      initialValue: _email,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _email = value;
                        });
                      },
                      enabled: false,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Bio
                    TextFormField(
                      initialValue: _bio,
                      decoration: const InputDecoration(
                        labelText: 'Bio',
                        prefixIcon: Icon(Icons.info),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _bio = value;
                        });
                      },
                      enabled: false,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your bio';
                        }
                        return null;
                      },
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    CustomButton(
                      label: 'Save Changes',
                      padding: 5.0,
                      onPressed: _saveProfile,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (_isLoading)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    ),
  ),
);

  }
}

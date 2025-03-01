import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:pgi/core/utils/status_bar_util.dart';
import 'package:pgi/data/models/drop_list_model.dart';
import 'package:pgi/services/api/xenforo_attachment_api.dart';
import 'package:pgi/services/api/xenforo_node_api.dart';
import 'package:pgi/services/api/xenforo_thread_api.dart';
import 'package:pgi/view/widgets/custom_app_bar.dart';
import 'package:pgi/view/widgets/custom_button.dart';
import 'package:pgi/view/widgets/custom_text_input.dart';

class CreateDiscussionScreen extends StatefulWidget {
  const CreateDiscussionScreen({super.key});

  @override
  _CreateDiscussionScreenState createState() => _CreateDiscussionScreenState();
}

class _CreateDiscussionScreenState extends State<CreateDiscussionScreen> {
  final NodeServices apiService = NodeServices();
  final ThreadService threadService = ThreadService();
  final AttachmentService attachmentService = AttachmentService();

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();
  final TextEditingController _pollQuestionController = TextEditingController();
  final List<TextEditingController> _pollResponses = [TextEditingController()];
  final TextEditingController _closePollDaysController = TextEditingController();

  List<Map<String, dynamic>> forums = [];
  bool isLoading = true;
  String errorMessage = '';
  String? _selectedForumId;
  String _selectedType = 'Discussion';
  bool _watchThread = true;
  bool _emailNotification = false;
  bool _allowVoteChange = false;
  bool _displayVotePublicly = false;
  bool _allowResultWithoutVoting = false;

  // Attachment handling
  File? _selectedFile;
  String? _selectedFileName;
  String? _attachmentKey; // Stores uploaded attachment key

  @override
  void initState() {
    super.initState();
    StatusBarUtil.setLightStatusBar();
    _fetchNode();
  }

  Future<void> _fetchNode() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final data = await apiService.getNodes();
      setState(() {
        forums = (data['nodes'] as List<dynamic>)
            .where((node) => node['node_type_id'] == 'Forum')
            .map((node) => {
                  'id': node['node_id'].toString(),
                  'title': node['title'],
                })
            .toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load forums. Please try again later.';
        isLoading = false;
      });
    }
  }

  Future<void> _createDiscussion() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
    });

    try {
      // Upload attachment if a file is selected
      if (_selectedFile != null) {
       await _handleAttachment(_selectedFile!);
      }

      final response = await threadService.createThread(
        nodeId: int.parse(_selectedForumId!), 
        title: _titleController.text, 
        message: _bodyController.text,
        discussionType: _selectedType,
        discussionOpen: true,
        attachmentKey: _attachmentKey,  // Pass uploaded file's key
        customFields: _selectedType == 'Poll' ? {
          'question': _pollQuestionController.text,
          'responses': _pollResponses.map((controller) => controller.text).toList(),
          'close_after_days': int.tryParse(_closePollDaysController.text) ?? 0,
          'allow_vote_change': _allowVoteChange,
          'display_vote_publicly': _displayVotePublicly,
          'allow_result_without_voting': _allowResultWithoutVoting,
          'watch_thread': _watchThread,
          'email_notification': _emailNotification,
        } : {
          'watch_thread': _watchThread,
          'email_notification': _emailNotification,
        }
      );

      if (response['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Discussion created successfully!')),
        );

        // Navigate to newly created discussion
        Navigator.pushReplacementNamed(context, '/discussion/${response['thread_id']}');
      } else {
        throw Exception('Failed to create discussion');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _handleAttachment(File file) async {
  try {
    // Step 1: Create attachment key
    String? attachmentKey = await attachmentService.createAttachmentKey('post');

    if (attachmentKey != null) {
      // Step 2: Upload file using the key
      Map<String, dynamic> uploadResponse = await attachmentService.uploadAttachment(file, attachmentKey);
      debugPrint('Attachment Uploaded: $uploadResponse');

      // Use the attachment key when creating the discussion
      _attachmentKey = attachmentKey;
    }
  } catch (e) {
    debugPrint('Attachment Upload Error: $e');
  }
}

  // File picker for attachment
  Future<void> _pickAttachment() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
        _selectedFileName = result.files.single.name;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const CustomAppBarBody(title: 'Create Discussion'),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isLoading)
                          const Center(child: CircularProgressIndicator())
                        else if (errorMessage.isNotEmpty)
                          Center(child: Text(errorMessage))
                        else
                          _buildForumDropdown(),
                        const SizedBox(height: 16),
                        _buildTypeSelector(),
                        const SizedBox(height: 16),
                     
                        CustomTextInput(
                          hintText: 'Title',
                          leftIcon: Icons.title,
                          controller: _titleController,
                          validator: (value) => value == null || value.isEmpty ? 'Title is required' : null,
                        ),
                        const SizedBox(height: 16),
                        _buildBodyField(),
                        const SizedBox(height: 16),
                        if (_selectedType == 'Poll') _buildPollOptions(),
                        // File Attachment UI
                        _buildAttachmentSection(),

                        _buildCheckboxOptions(),
                        const SizedBox(height: 16),

                        CustomButton(
                          label: 'Create',
                          onPressed: _createDiscussion,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentSection() {
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: _pickAttachment,
          icon: const Icon(Icons.attach_file),
          label: const Text("Add Attachment"),
        ),
        if (_selectedFileName != null) 
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              "Selected File: $_selectedFileName",
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
      ],
    );
  }

  Widget _buildPollOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextInput(
          hintText: 'Poll Question',
          leftIcon: Icons.poll,
          controller: _pollQuestionController,
          validator: (value) => value == null || value.isEmpty ? 'Poll question is required' : null,
        ),
        const SizedBox(height: 8),
        ..._pollResponses.map((controller) => Row(
              children: [
                Expanded(
                  child: CustomTextInput(
                    hintText: 'Response',
                    leftIcon: Icons.question_answer,
                    controller: controller,
                    validator: (value) => value == null || value.isEmpty ? 'Response is required' : null,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: () => setState(() {
                    if (_pollResponses.length > 1) _pollResponses.remove(controller);
                  }),
                ),
              ],
            )),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () => setState(() => _pollResponses.add(TextEditingController())),
        ),
        const SizedBox(height: 8),
        CustomTextInput(
          hintText: 'Close poll after (days)',
          leftIcon: Icons.numbers,
          controller: _closePollDaysController,
          keyboardType: TextInputType.number,
        ),
        SwitchListTile(
          title: const Text('Allow voters to change vote'),
          value: _allowVoteChange,
          activeTrackColor: const Color(0xFF0A5338),
          onChanged: (value) => setState(() => _allowVoteChange = value),
        ),
        SwitchListTile(
          title: const Text('Display vote publicly'),
          value: _displayVotePublicly,
          activeTrackColor: const Color(0xFF0A5338),
          onChanged: (value) => setState(() => _displayVotePublicly = value),
        ),
        SwitchListTile(
          title: const Text('Allow results to be viewed without voting'),
          value: _allowResultWithoutVoting,
          activeTrackColor: const Color(0xFF0A5338),
          onChanged: (value) => setState(() => _allowResultWithoutVoting = value),
        ),
      ],
    );
  }

  Widget _buildForumDropdown() {
    return SizedBox(
      width: double.infinity,
      child: SelectDropList(
        OptionItem(
          id: _selectedForumId ?? '',
          title: forums.firstWhere(
            (forum) => forum['id'] == _selectedForumId, 
            orElse: () => {'title': 'Select Forum'}
          )['title'],
        ),
        DropListModel(
          forums.map((forum) => OptionItem(id: forum['id'], title: forum['title'])).toList(),
        ),
        (optionItem) => setState(() => _selectedForumId = optionItem.id),
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildTypeRadio('Discussion')),
            Expanded(child: _buildTypeRadio('Poll')),
          ],
        ),
        Row(
          children: [
            Expanded(child: _buildTypeRadio('Question')),
          ],
        ),
      ],
    );
  }

  Widget _buildTypeRadio(String type) {
    return RadioListTile<String>(
      title: Text(type, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      value: type,
      activeColor: const Color(0xFF0A5338),
      groupValue: _selectedType,
      onChanged: (value) => setState(() => _selectedType = value ?? 'Discussion'),
    );
  }

   Widget _buildCheckboxOptions() {
    return Column(
      children: [
        CheckboxListTile(
          title: const Text('Watch thread'),
          value: _watchThread,
          activeColor: const Color(0xFF0A5338),
          onChanged: (value) => setState(() => _watchThread = value ?? false),
        ),
        CheckboxListTile(
          title: const Text('Receive email notifications'),
          value: _emailNotification,
          activeColor: const Color(0xFF0A5338),
          onChanged: (value) => setState(() => _emailNotification = value ?? false),
        ),
      ],
    );
  }

  Widget _buildBodyField() {
    return CustomTextInput(
      hintText: 'Body',
      leftIcon: Icons.text_fields,
      controller: _bodyController,
      maxLines: 5,
      validator: (value) => value == null || value.isEmpty ? 'Body is required' : null,
    );
  }
}

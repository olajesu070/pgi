import 'package:flutter/material.dart';
import 'package:pgi/core/utils/status_bar_util.dart';
import 'package:pgi/data/models/drop_list_model.dart';
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
  bool _watchThread = false;
  bool _emailNotification = false;
  bool _allowVoteChange = false;
  bool _displayVotePublicly = false;
  bool _allowResultWithoutVoting = false;

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

    final Map<String, dynamic> discussionData = {
      'nodeId': _selectedForumId,
      'title': _titleController.text,
      'message': _bodyController.text,
      'discussionType': _selectedType,
      'customFields':''
     
    };

    if (_selectedType == 'Poll') {
      discussionData['customFields'] = {
        'question': _pollQuestionController.text,
        'responses': _pollResponses.map((controller) => controller.text).toList(),
        'close_after_days': int.tryParse(_closePollDaysController.text) ?? 0,
        'allow_vote_change': _allowVoteChange,
        'display_vote_publicly': _displayVotePublicly,
        'allow_result_without_voting': _allowResultWithoutVoting,
        'watch_thread': _watchThread,
        'email_notification': _emailNotification,
      };
    }

    try {
      final response = await threadService.createThread(
        nodeId: int.parse(_selectedForumId!), 
        title: _titleController.text, 
        message: _bodyController.text,
        discussionType: _selectedType,
        discussionOpen: true,
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
          SnackBar(content: Text('Discussion created successfully!')),
        );
        Navigator.pop(context);
      } else {
        throw Exception('Failed to create discussion');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
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
                        _buildCheckboxOptions(),
                        const SizedBox(height: 16),
                        CustomButton(
                        label: 'Create',
                        onPressed: _submitForm
                        )
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

  Widget _buildForumDropdown() {
  return SizedBox(
    width: double.infinity, // Ensures it takes full width
    child: SelectDropList(
      OptionItem(id: _selectedForumId ?? '', title: forums.firstWhere((forum) => forum['id'] == _selectedForumId, orElse: () => {'title': 'Select Forum'})['title']),
      DropListModel(forums.map((forum) => OptionItem(id: forum['id'], title: forum['title'])).toList()),
      (optionItem) => setState(() => _selectedForumId = optionItem.id),
    ),
  );
}


  Widget _buildTypeSelector() {
    return Row(
      children: [
        _buildTypeRadio('Discussion'),
        _buildTypeRadio('Poll'),
        _buildTypeRadio('Question'),
      ],
    );
  }

  Widget _buildTypeRadio(String type) {
    return Expanded(
      child: RadioListTile<String>(
        title: Text(type, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold),),
        value: type,
        activeColor: Color(0xFF0A5338),
        groupValue: _selectedType,
        onChanged: (value) => setState(() => _selectedType = value ?? 'Discussion'),
      ),
    );
  }

  Widget _buildBodyField() {
    return  CustomTextInput(
        hintText: 'Body',
        leftIcon: Icons.text_fields,
        controller: _bodyController,
        maxLines: 5,
        validator: (value) => value == null || value.isEmpty ? 'Body is required' : null,
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
          activeTrackColor: Color(0xFF0A5338),
          onChanged: (value) => setState(() => _allowVoteChange = value),
        ),
        SwitchListTile(
          title: const Text('Display vote publicly'),
          value: _displayVotePublicly,
          activeTrackColor: Color(0xFF0A5338),
          onChanged: (value) => setState(() => _displayVotePublicly = value),
        ),
        SwitchListTile(
          title: const Text('Allow results to be viewed without voting'),
          value: _allowResultWithoutVoting,
          activeTrackColor: Color(0xFF0A5338),
          onChanged: (value) => setState(() => _allowResultWithoutVoting = value),
        ),
      ],
    );
  }

  Widget _buildCheckboxOptions() {
    return Column(
      children: [
        CheckboxListTile(
          title: const Text('Watch thread'),
          value: _watchThread,
          activeColor: Color(0xFF0A5338),
          onChanged: (value) => setState(() => _watchThread = value ?? false),
        ),
        CheckboxListTile(
          title: const Text('Receive email notifications'),
          value: _emailNotification,
          activeColor: Color(0xFF0A5338),
          onChanged: (value) => setState(() => _emailNotification = value ?? false),
        ),
      ],
    );
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Discussion created for forum ID: $_selectedForumId')),
      );
      // Add logic to submit the form to the API using the selected forum ID and other fields.
    }
  }
}

import 'package:flutter/material.dart';
import 'package:pgi/core/utils/status_bar_util.dart';
import 'package:pgi/services/api/xenforo_node_api.dart';
import 'package:pgi/view/widgets/custom_app_bar.dart';
import 'package:pgi/view/widgets/custom_text_input.dart';

class CreateDiscussionScreen extends StatefulWidget {
  const CreateDiscussionScreen({super.key});

  @override
  _CreateDiscussionScreenState createState() => _CreateDiscussionScreenState();
}

class _CreateDiscussionScreenState extends State<CreateDiscussionScreen> {
  final NodeServices apiService = NodeServices();
  
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
                        // TextFormField(
                        //   controller: _titleController,
                        //   decoration: const InputDecoration(labelText: 'Title'),
                        //   validator: (value) => value == null || value.isEmpty ? 'Title is required' : null,
                        // ),
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
                        ElevatedButton(
                          onPressed: _submitForm,
                          child: const Text('Create'),
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

  Widget _buildForumDropdown() {
  return SizedBox(
    width: double.infinity, // Ensures it takes full width
    child: DropdownButtonFormField<String>(
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        hintStyle: const TextStyle(color: Colors.grey),
        prefixIcon: const Icon(
          Icons.forum,
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
      value: _selectedForumId,
      hint: const Text('Select Forum'),
      onChanged: (value) => setState(() => _selectedForumId = value),
      items: forums
          .map((forum) => DropdownMenuItem<String>(
                value: forum['id'],
                child: Text(forum['title']),
              ))
          .toList(),
      validator: (value) => value == null ? 'Please select a forum' : null,
      dropdownColor: Colors.white,
      isExpanded: false,  // Avoid stretching the dropdown items
      itemHeight: 48.0,   // Compact height for each item
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
          onChanged: (value) => setState(() => _allowVoteChange = value),
        ),
        SwitchListTile(
          title: const Text('Display vote publicly'),
          value: _displayVotePublicly,
          onChanged: (value) => setState(() => _displayVotePublicly = value),
        ),
        SwitchListTile(
          title: const Text('Allow results to be viewed without voting'),
          value: _allowResultWithoutVoting,
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
          onChanged: (value) => setState(() => _watchThread = value ?? false),
        ),
        CheckboxListTile(
          title: const Text('Receive email notifications'),
          value: _emailNotification,
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

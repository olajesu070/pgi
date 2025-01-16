import 'package:flutter/material.dart';
import 'package:pgi/services/api/xenforo_conversation_service.dart';
import 'package:pgi/view/widgets/custom_app_bar.dart';
import 'package:pgi/view/widgets/custom_button.dart';
import 'package:pgi/view/widgets/custom_text_input.dart';


class CreateMessageScreen extends StatefulWidget {
  final List<int> recipientId;

  const CreateMessageScreen({super.key, required this.recipientId});

  @override
  _CreateMessageScreenState createState() => _CreateMessageScreenState();
}

class _CreateMessageScreenState extends State<CreateMessageScreen> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  bool _allowInvite = false;
  bool _lockMessage = false;

  final ConversationService _conversationService = ConversationService();

 void _sendMessage() async {
  final title = _titleController.text;
  final body = _bodyController.text;
  final recipientId = widget.recipientId;

  debugPrint('recipientId: $recipientId');


  try {
    final response = await _conversationService.createConversation(
      recipientIds: recipientId,  // Pass recipientId in a list
      title: title,
      message: body,
      conversationOpen: !_lockMessage,
      openInvite: _allowInvite,
    );

    if (response['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Message sent successfully!')),
      );
      Navigator.of(context).pop();
    } else {
      // Display error message from API
      final errorMessage = response['errors']?[0]['message'] ?? 'Failed to send message';
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to send message')),
      );
    }
  } catch (e) {
    debugPrint('Error: ${e.toString()}');
     ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to send message')),
      );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          
          children: [
             const CustomAppBarBody(
                title: 'Send Message',
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const SizedBox(height: 50),
                  CustomTextInput(
                    hintText: 'Message Title',
                    leftIcon: Icons.message,
                    controller: _titleController,
                  ),

                  const SizedBox(height: 20),
                  CustomTextInput(
                    hintText: 'Message Body',
                    leftIcon: Icons.message,
                    controller: _bodyController,
                    maxLines: 4,
                  ),

                CheckboxListTile(
                  title: const Text('Allow anyone to invite others'),
                  value: _allowInvite,
                  onChanged: (bool? value) {
                    setState(() {
                      _allowInvite = value ?? false;
                    });
                  },
                ),
                CheckboxListTile(
                  title: const Text('Lock message (no response)'),
                  value: _lockMessage,
                  onChanged: (bool? value) {
                    setState(() {
                      _lockMessage = value ?? false;
                    });
                  },
                ),
                const SizedBox(height: 20),
                CustomButton(
                  label: 'Message',
                  padding: 5.0,
                  onPressed: _sendMessage,
                ),
              ],
            ),
           ),
        )
           
          ],
        ),
      ),
    );
  }
}

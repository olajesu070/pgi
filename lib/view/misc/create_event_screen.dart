import 'package:flutter/material.dart';
import 'package:pgi/view/widgets/custom_button.dart';
import 'package:pgi/view/widgets/custom_text_input.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  _CreateEventScreenState createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  String coverImageUrl = '';
  String title = '';
  String date = '';
  String time = '';
  String centerName = '';
  String address = '';
  String organizerName = '';
  String eventDetails = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Event'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              if (_formKey.currentState?.validate() ?? false) {
                // Save event details action (e.g., API call or navigation)
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Event Created Successfully')),
                );
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Cover Image URL Input

              // TextFormField(
              //   decoration: const InputDecoration(labelText: 'Cover Image URL'),
              //   onChanged: (value) {
              //     setState(() {
              //       coverImageUrl = value;
              //     });
              //   },
              //   validator: (value) {
              //     if (value == null || value.isEmpty) {
              //       return 'Please enter a cover image URL';
              //     }
              //     return null;
              //   },
              // ),
              // SizedBox(height: 16),

              // Event Title Input

               CustomTextInput(
                 hintText: 'Event Title',
                  leftIcon: Icons.event,
                  onChanged: (value) {
                    setState(() {
                      title = value; // Update title variable
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an event title';
                    }
                    return null;
                  },
                ),
              const SizedBox(height: 16),

              // Date Input
              CustomTextInput(
                 hintText: 'Date (YYYY-MM-DD)',
                  leftIcon: Icons.date_range_outlined,
                  onChanged: (value) {
                    setState(() {
                      date = value;
                    });
                  },
                  validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the event date';
                  }
                  return null;
                },
                ),
              const SizedBox(height: 16),

              // Time Input
               CustomTextInput(
                 hintText: 'Time (HH:MM)',
                  leftIcon: Icons.date_range_outlined,
                  onChanged: (value) {
                    setState(() {
                      time = value;
                      });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the event time';
                    }
                    return null;
                  },
                ),
              const SizedBox(height: 16),

              // Center Name Input
               CustomTextInput(
                 hintText: 'Center Name',
                onChanged: (value) {
                  setState(() {
                    centerName = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the center name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Address Input
               CustomTextInput(
                 hintText: 'Address',
                onChanged: (value) {
                  setState(() {
                    address = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Organizer Name Input
               CustomTextInput(
                 hintText: 'Organizer Name',
                onChanged: (value) {
                  setState(() {
                    organizerName = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the organizer name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Event Details Input
               CustomTextInput(
                 hintText: 'Event Details',
                onChanged: (value) {
                  setState(() {
                    eventDetails = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter event details';
                  }
                  return null;
                },
                maxLines: 4,
              ),
              const SizedBox(height: 20),

              // Save Button
              CustomButton(
                  label: 'Create Event',
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                    // Handle the event saving process
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Event Created Successfully')),
                    );
                  }
                  },
                  // color: Colors.blue,
                  textColor: Colors.white,
                ),
             
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:pgi/view/discussion/thread_detail_screen.dart';
import 'package:pgi/view/widgets/custom_app_bar.dart';
import 'package:pgi/view/widgets/custom_button.dart';

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
             const CustomAppBarBody(
                title: 'Contact Us',
              ),

            Expanded(
              child:  Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Information message
                    Text(
                      'For any inquiries, please click the button below to contact us, We are here to assist you with any questions or concerns you may have. Our team is dedicated to providing you with the best support possible.',
                      style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    const Spacer(),

                    // Contact Us Button
                  
                     CustomButton(
                        label: 'Contact Us',
                        padding: 5.0,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>  const ThreadDetailScreen(param: 'https://pgi.org/misc/contact',),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            )
          ]
        )
      ) 
     
    );
  }
}


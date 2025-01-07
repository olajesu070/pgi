import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:pgi/view/misc/policy.dart';
import 'package:pgi/view/widgets/custom_button.dart';
import 'package:pgi/view/widgets/custom_text_input.dart';
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool bulletinSelected = false;
  bool calendarSelected = false;
  bool acceptBylaws = false;
  bool agreeTerms = false;

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController postalCodeController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController countryController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
       
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo
                Center(
                  child: Image.asset(
                    'assets/logo.png', // Update with your actual logo path
                    height: 40,
                  ),
                ),
                const SizedBox(height: 10),

                // Title
                const Text(
                  'Sign Up',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

            // Username Input
            CustomTextInput(
              hintText: 'Username',
              leftIcon: Icons.person,
              controller: usernameController,
            ),
            const SizedBox(height: 10),

            // Email Input
            CustomTextInput(
              hintText: 'Email',
              leftIcon: Icons.email,
              controller: emailController,
            ),
            const SizedBox(height: 10),

            // Phone Number Input
            CustomTextInput(
              hintText: 'Phone Number',
              leftIcon: Icons.phone,
              controller: phoneController,
            ),
            const SizedBox(height: 10),

            // Date of Birth with Dropdowns
            // Row(
            //   children: [
            //     Expanded(child: CustomTextInput(hintText: 'Month')),
            //     const SizedBox(width: 10),
            //     Expanded(child: CustomTextInput(hintText: 'Day')),
            //     const SizedBox(width: 10),
            //     Expanded(child: CustomTextInput(hintText: 'Year')),
            //   ],
            // ),
            // const SizedBox(height: 10),

            // First Name and Last Name 
            Row(
              children: [
                Expanded(child: CustomTextInput(hintText: 'First Name', controller: firstNameController)),
                const SizedBox(width: 10),
                Expanded(child: CustomTextInput(hintText: 'Last Name', controller: lastNameController)),
              ],
            ),
            const SizedBox(height: 10),

            // Street Address Input
            CustomTextInput(
              hintText: 'Street Address',
              leftIcon: Icons.home,
              controller: addressController,
            ),
            const SizedBox(height: 10),

            // State/Territory and Postal Code Inputs
            Row(
              children: [
                Expanded(child: CustomTextInput(hintText: 'State/Territory', controller: stateController)),
                const SizedBox(width: 10),
                Expanded(child: CustomTextInput(hintText: 'Postal Code', controller: postalCodeController)),
              ],
            ),
            const SizedBox(height: 10),

            // City and Country Inputs
            Row(
              children: [
                Expanded(child: CustomTextInput(hintText: 'City', controller: cityController)),
                const SizedBox(width: 10),
                Expanded(child: CustomTextInput(hintText: 'Country', controller: countryController)),
              ],
            ),

            const SizedBox(height: 20),

            // Membership Materials
            const Text(
              'Membership Materials',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            CheckboxListTile(
              value: bulletinSelected,
              onChanged: (value) {
                setState(() {
                  bulletinSelected = value!;
                });
              },
              title: const Text('Bulletin', style: TextStyle(fontSize: 10),),
              controlAffinity: ListTileControlAffinity.leading,
              activeColor: const Color(0xFF0A5338)
            ),
            CheckboxListTile(
              value: calendarSelected,
              onChanged: (value) {
                setState(() {
                  calendarSelected = value!;
                });
              },
              title: const Text('Calendar', style: TextStyle(fontSize: 10)),
              controlAffinity: ListTileControlAffinity.leading,
              activeColor: const Color(0xFF0A5338)
            ),
            const SizedBox(height: 10),
            const Text(
              'Check the boxes to the materials you wish to physically receive in print once you are a PGI member. Note: you may change these settings at any time.',
              style: TextStyle(color: Colors.grey, fontSize: 10),
            ),
            const SizedBox(height: 20),

            // Agreement Checkboxes
            CheckboxListTile(
              value: acceptBylaws,
              onChanged: (value) {
                setState(() {
                  acceptBylaws = value!;
                });
              },
              title: RichText(
                text: TextSpan(
                  children: [
                    const TextSpan(text: 'I accept the ', style: TextStyle(color: Colors.black)),
                    TextSpan(
                      text: 'PGI Bylaws',
                      style: const TextStyle(color: Colors.blue),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          // Navigate to Bylaws page or show dialog
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PrivacyPolicyScreen(),
                            ),
                          );

                        },
                    ),
                  ],
                ),
              ),
              controlAffinity: ListTileControlAffinity.leading,
              activeColor: const Color(0xFF0A5338)
            ),
            CheckboxListTile(
              value: agreeTerms,
              onChanged: (value) {
                setState(() {
                  agreeTerms = value!;
                });
              },
              title: RichText(
                text: TextSpan(
                  children: [
                    const TextSpan(text: 'I agree to the ', style: TextStyle(color: Colors.black)),
                    TextSpan(
                      text: 'Terms',
                      style: const TextStyle(color: Colors.blue),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          // Navigate to Terms page or show dialog
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                             builder: (context) => const PrivacyPolicyScreen(),
                            ),
                          );

                        },
                    ),
                    const TextSpan(text: ' and ', style: TextStyle(color: Colors.black)),
                    TextSpan(
                      text: 'Privacy Policy',
                      style: const TextStyle(color: Colors.blue),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          // Navigate to Privacy Policy page or show dialog
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                             builder: (context) => const PrivacyPolicyScreen(),
                            ),
                          );

                        },
                    ),
                  ],
                ),
              ),
              controlAffinity: ListTileControlAffinity.leading,
              activeColor: const Color(0xFF0A5338)
            ),
            const SizedBox(height: 20),

            // Register Button
            CustomButton(
              label: 'Register',
              onPressed: () {
                // Handle registration logic
              },
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:pgi/core/constants/country_list.dart';
import 'package:pgi/data/models/drop_list_model.dart';
import 'package:pgi/services/api/xenforo_user_api.dart';
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

  final XenForoUserApi _userApi = XenForoUserApi();

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController postalCodeController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String passwordStrength = 'Enter a password'; // For password strength indicator
  String? selectedDay;
  String? selectedMonth;
  String? selectedYear;
  String? selectedCountry;

  final List<String> days = List.generate(31, (index) => (index + 1).toString());
  final List<String> months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];
  final List<String> years =
      List.generate(100, (index) => (DateTime.now().year - index).toString());

  @override
  void initState() {
    super.initState();
    passwordController.addListener(_checkPasswordStrength);
  }

  void _checkPasswordStrength() {
  final password = passwordController.text;

  if (password.isEmpty) {
    setState(() {
      passwordStrength = 'Enter a password';
    });
    return;
  }

  // Regular expressions to check for different character types
  final hasUppercase = password.contains(RegExp(r'[A-Z]')); // At least one uppercase letter
  final hasLowercase = password.contains(RegExp(r'[a-z]')); 
  final hasDigits = password.contains(RegExp(r'[0-9]')); // At least one digit
  final hasSpecialCharacters = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]')); // At least one special character
  final hasMinLength = password.length >= 8; // Minimum length of 8 characters

  if (password.length < 6) {
    setState(() {
      passwordStrength = 'Weak';
    });
  } else if (hasMinLength && hasUppercase && hasDigits ) {
    setState(() {
      passwordStrength = 'Medium';
    });
  } else if (hasMinLength && hasUppercase && hasDigits && hasSpecialCharacters &&hasLowercase) {
    setState(() {
      passwordStrength = 'Strong';
    });
  } else {
    setState(() {
      passwordStrength = 'Weak';
    });
  }
}

  void _createUser() async {
    final data = {
      'username': usernameController.text.trim(),
      'email': emailController.text.trim(),
      'password': passwordController.text,
      'dob[day]': selectedDay, // Use the selected day
      'dob[month]': selectedMonth, // Use the selected month
      'dob[year]': selectedYear, // Use the selected year
      'custom_fields': {
          'firstname': firstNameController.text.trim(),
          'lastname': lastNameController.text.trim(),
          'phone_main': phoneController.text.trim(),
          'address': addressController.text.trim(),
          'city': cityController.text.trim(),
          'state': stateController.text.trim(),
          'postal_code': postalCodeController.text.trim(),
          'country': selectedCountry,
        },
    };

  try {
    // Call the API to create the user
    final user = await _userApi.createUser(data);

    // Show success message and navigate away
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('User ${user.username} created successfully!')),
    );
    Navigator.pop(context);
  } catch (e) {
    // Handle and display errors
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error creating user: $e')),
    );
  }
}



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
                'assets/logo.png',
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

            // Date of Birth
            const Text(
              'Date of Birth',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                    child: SelectDropList(
                    OptionItem(id: selectedDay ?? '', title: selectedDay ?? 'Day'),
                    DropListModel(days.map((day) => OptionItem(id: day, title: day)).toList()),
                    (optionItem) {
                      setState(() {
                      selectedDay = optionItem.title;
                      });
                    },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SelectDropList(
                    OptionItem(id: selectedMonth ?? '', title: selectedMonth ?? 'Month'),
                    DropListModel(months.map((month) => OptionItem(id: month, title: month)).toList()),
                    (optionItem) {
                      setState(() {
                      selectedMonth = optionItem.title;
                      });
                    },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SelectDropList(
                    OptionItem(id: selectedYear ?? '', title: selectedYear ?? 'Year'),
                    DropListModel(years.map((year) => OptionItem(id: year, title: year)).toList()),
                    (optionItem) {
                      setState(() {
                      selectedYear = optionItem.title;
                      });
                    },
                    ),
                  ),
                  ],
                ),
            const SizedBox(height: 10),

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

            // City Input
            CustomTextInput(
              hintText: 'City',
              leftIcon: Icons.location_city,
              controller: cityController,
            ),
            const SizedBox(height: 10),

            // Country Dropdown
            const Text(
              'Country',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            SelectDropList(
              OptionItem(id: selectedCountry ?? '', title: selectedCountry ?? 'Select Country'),
              DropListModel(countryList.map((country) => OptionItem(id: country['id']!, title: country['name']!)).toList()),
              (optionItem) {
              setState(() {
                // Handle country selection
                selectedCountry = optionItem.title;
              });
              },
            ),
            const SizedBox(height: 10),

            // Password Input
            CustomTextInput(
              hintText: 'Password',
              leftIcon: Icons.lock,
              controller: passwordController,
              isPassword: true,
              
            ),
            const SizedBox(height: 8),
            Text(
              'Password Strength: $passwordStrength',
              style: TextStyle(
                color: passwordStrength == 'Weak'
                    ? Colors.red
                    : passwordStrength == 'Medium'
                        ? Colors.orange
                        : Colors.green,
              ),
            ),
            const SizedBox(height: 20),

            // Register Button
            CustomButton(
              label: 'Register',
              onPressed: _createUser
            ),
          ],
        ),
      ),
    );
  }
}

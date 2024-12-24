import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pgi/routes/bottom_navigation.dart';
import 'package:pgi/view/auth/sign_in_screen.dart';
import 'package:pgi/view/auth/sign_up_screen.dart';
import 'package:pgi/view/discussion/discussion_screen.dart';
import 'package:pgi/view/gallery/gallery_screen.dart';
import 'package:pgi/view/message/message_screen.dart';
import 'package:pgi/view/misc/contact_screen.dart';
import 'package:pgi/view/misc/profile.dart';
import 'package:pgi/view/misc/settings.dart';
import 'package:pgi/view/onboarding/onboarding_screen.dart';
import 'package:pgi/view/schedule/schedule_screen.dart';

Future<void> main() async {
  // Ensure that dotenv is loaded before running the app
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  // Run the app
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AppLinks appLinks;

  @override
  void initState() {
    super.initState();

  }

  

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PGI App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      debugShowCheckedModeBanner: false,
      routes: {
        '/': (context) => const OnboardingScreen(),
        '/signIn': (context) => const SignInScreen(),
        '/auth/signIn': (context) => const SignInScreen(),
        '/signUp': (context) => const SignUpScreen(),
        '/home': (context) => const BottomNavigation(),
        '/profile': (context) => const ProfileScreen(userName: 'Logboi'),
        '/discussions': (context) => const DiscussionsScreen(),
        '/gallery': (context) => const GalleryScreen(),
        '/messages': (context) => const MessageScreen(),
        '/schedule': (context) => const ScheduleScreen(),
        '/contact': (context) => ContactUsScreen(),
        '/settings': (context) => const SettingsPage(),
      },
    );
  }
}

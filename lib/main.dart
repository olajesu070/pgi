import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:flutter/rendering.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pgi/core/utils/safe_area_wrapper.dart';
import 'package:pgi/data/models/user_state.dart';
import 'package:pgi/routes/bottom_navigation.dart';
import 'package:pgi/view/auth/loading.dart';
import 'package:pgi/view/auth/sign_up_screen.dart';
import 'package:pgi/view/discussion/discussion_screen.dart';
import 'package:pgi/view/explore/guild.dart';
import 'package:pgi/view/gallery/gallery_screen.dart';
import 'package:pgi/view/message/message_screen.dart';
import 'package:pgi/view/misc/contact_screen.dart';
import 'package:pgi/view/misc/profile.dart';
import 'package:pgi/view/misc/settings.dart';
import 'package:pgi/view/onboarding/onboarding_screen.dart';
import 'package:pgi/view/schedule/schedule_screen.dart';
import 'package:provider/provider.dart';


Future<void> main() async {
  // Ensure that dotenv is loaded before running the app
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  // Set global status bar style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,  // Makes the status bar transparent
      statusBarIconBrightness: Brightness.light,  // Light icons for dark backgrounds
      statusBarBrightness: Brightness.dark,  // Dark icons for light backgrounds (iOS)
    ),
  );
  
  // Run the app
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserState()),
      ],
    child: const MyApp()));
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
       appBarTheme: const AppBarTheme(
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
          ),
        ),
    ),
    initialRoute: '/',
    debugShowCheckedModeBanner: false,
    routes: {
  '/': (context) => const SafeAreaWrapper(child: OnboardingScreen()),
  '/auth/signIn': (context) => const SafeAreaWrapper(child: LoadingPage()),
  '/signUp': (context) => const SafeAreaWrapper(child: SignUpScreen()),
  '/home': (context) => const SafeAreaWrapper(child: BottomNavigation()),
  '/profile': (context) => const SafeAreaWrapper(child: ProfileScreen()),
  '/discussions': (context) => const SafeAreaWrapper(child: DiscussionsScreen()),
  '/gallery': (context) => const SafeAreaWrapper(child: GalleryScreen()),
  '/messages': (context) => const SafeAreaWrapper(child: MessageScreen()),
  '/schedule': (context) => const SafeAreaWrapper(child: ScheduleScreen()),
  '/contact': (context) => SafeAreaWrapper(child: ContactUsScreen()),
  '/settings': (context) => const SafeAreaWrapper(child: SettingsPage()),
  '/guild': (context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;  // Extract arguments
    final param = args?['param'] ?? 0;  // Default value if 'param' is null
    return SafeAreaWrapper(child: Guild(nodeId: param));  // Pass the param to Guild
  },
}

  );
}

}

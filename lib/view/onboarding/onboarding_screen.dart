
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pgi/services/api/oauth2_service.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late OAuth2Service _oauth2Service;
  final AppLinks _appLinks = AppLinks();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _oauth2Service = OAuth2Service(onTokensUpdated: _onTokensUpdated);
    _initializeAppLinks();
    _showStorageContents();
    _autoLogin();  
  }

  Future<void> _showStorageContents() async {
  setState(() {
    _isLoading = true;
  });

  try {
    // Retrieve all stored key-value pairs
    final allStorage = await _secureStorage.readAll();
    debugPrint('Secure Storage Contents:');
    allStorage.forEach((key, value) {
      debugPrint('$key: $value');
    });
  } catch (e) {
    debugPrint('Error reading storage: $e');
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
}

  void _onTokensUpdated() {
    // Handle token updates, e.g., navigate to the main app screen
    Navigator.of(context).pushReplacementNamed('/home');
  }

  void _setLoading(bool loading) {
    setState(() {
      _isLoading = loading;
    });
  }

  void _initializeAppLinks() {
    _appLinks.getInitialLink().then((uri) {
      if (uri != null) {
        debugPrint("Initial deep link received: $uri");
        _oauth2Service.handleRedirect(uri, context);
      }
    });

    _appLinks.uriLinkStream.listen((uri) {
      debugPrint("Deep link received: $uri");
      _oauth2Service.handleRedirect(uri, context);
    });
  }

   void _autoLogin() async {
    _setLoading(true);
    try {
      final accessToken = await _secureStorage.read(key: 'accessToken');
      final refreshToken = await _secureStorage.read(key: 'refreshToken');
      final expirationDateStr = await _secureStorage.read(key: 'expirationDate');

       if (accessToken != null && refreshToken != null && expirationDateStr != null) {
        final expirationDate = DateTime.parse(expirationDateStr);
        debugPrint("date now is ${DateTime.now()} and expireDate is $expirationDate");
        if (DateTime.now().isAfter(expirationDate)) {
          await _oauth2Service.refreshAccessToken(context);
          debugPrint("Access token refreshed successfully.");
        } else {
          debugPrint("Valid access token found. Proceeding to home.");
          _oauth2Service.navigateToHome(context);
        }
      } else {
        debugPrint("No valid tokens found. User needs to log in.");
      }

      // await _oauth2Service.ensureValidAccessToken(context);
    } catch (e) {
      debugPrint("Error during auto-login: $e");
      _setLoading(false);
    }
  }

  void _login() async {
    _setLoading(true);
    try {
      await _oauth2Service.startOAuthFlow(context);
    } catch (e) {
      debugPrint("Error during login: $e");
    } finally {
      _setLoading(false);
    }
  }

  void _signUp() {
    // Placeholder for sign-up logic or navigation
    Navigator.of(context).pushNamed('/signUp'); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/pgi.jpeg', fit: BoxFit.cover),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.3,
              decoration: const BoxDecoration(
                color: Color(0xD70A5338),
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Welcome to PGI',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Welcome to Pyrotechnics Guild International where enthusiasts and professionals connect, share, and celebrate the art of fireworks.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Color(0xDFFFFFFF)),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      TextButton(
                        onPressed: _login,
                        child: const Text(
                          'Login here',
                          style: TextStyle(fontSize: 18, color: Color(0xFFDBDBDB)),
                        ),
                      ),
                      TextButton(
                        onPressed: _signUp,
                        child: const Text(
                          'Sign Up',
                          style: TextStyle(fontSize: 18, color: Color(0xFFDBDBDB)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

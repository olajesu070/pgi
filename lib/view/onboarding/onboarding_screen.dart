import 'dart:developer' as developer;
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
    _initializeOAuth2Service();
    _initializeAppLinks();
    _checkAndRefreshToken();
  }

  void _setLoading(bool loading) {
    setState(() {
      _isLoading = loading;
    });
  }

  void _initializeOAuth2Service() {
    _oauth2Service = OAuth2Service(
      clientId: '3128580506330804',
      clientSecret: 'h57Dml8kYuqgDhspqvQWN9CMGdQQm3_T',
      authorizationEndpoint: 'https://pgi.org/oauth2/authorize',
      tokenEndpoint: 'https://pgi.org/api/oauth2/token',
      redirectUri: 'https://pgi.org/auth/signIn',
      secureStorage: _secureStorage,
      onTokensUpdated: _checkAndRefreshToken,  // Automatically refresh tokens when updated
    );
  }

  void _initializeAppLinks() {
    _appLinks.getInitialLink().then((uri) {
      if (uri != null) {
        developer.log("Initial deep link received: $uri");
        _oauth2Service.handleRedirect(uri, context);
      }
    });

    _appLinks.uriLinkStream.listen((uri) {
      developer.log("Deep link received: $uri");
      _oauth2Service.handleRedirect(uri, context);
    });
  }

  Future<void> _checkAndRefreshToken() async {
    _setLoading(true);
    try {
      final accessToken = await _secureStorage.read(key: 'accessToken');
      final refreshToken = await _secureStorage.read(key: 'refreshToken');
      final expirationDateStr = await _secureStorage.read(key: 'expirationDate');

      if (accessToken != null && refreshToken != null && expirationDateStr != null) {
        final expirationDate = DateTime.parse(expirationDateStr);
        if (DateTime.now().isAfter(expirationDate)) {
          await _oauth2Service.refreshAccessToken(context);
          developer.log("Access token refreshed successfully.");
        } else {
          developer.log("Valid access token found. Proceeding to home.");
          _oauth2Service.navigateToHome(context);
        }
      } else {
        developer.log("No valid tokens found. User needs to log in.");
      }
    } catch (e) {
      developer.log("Error checking or refreshing token: $e");
    } finally {
      _setLoading(false);
    }
  }

  void _login() async {
    _setLoading(true);
    try {
      await _oauth2Service.startOAuthFlow(context);
    } catch (e) {
      developer.log("Error during login: $e");
    } finally {
      _setLoading(false);
    }
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

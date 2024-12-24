import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pgi/services/api/oauth2_service.dart';
import 'package:uni_links2/uni_links.dart'; // For handling deep links

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  late OAuth2Service _oauth2Service;
  String? _accessToken;
  String? _refreshToken;
  String? _expirationDate;

  @override
  void initState() {
    super.initState();
    _oauth2Service = OAuth2Service(
      clientId: '3128580506330804',
      clientSecret: 'h57Dml8kYuqgDhspqvQWN9CMGdQQm3_T',
      authorizationEndpoint: 'https://pgi.org/oauth2/authorize',
      tokenEndpoint: 'https://pgi.org/api/oauth2/token',
      redirectUri: 'https://pgi.org/auth/signIn',
      secureStorage: const FlutterSecureStorage(),
      onTokensUpdated: _loadStoredTokens,
    );
    _initializeAppLinks();
    _loadStoredTokens();
  }

  void _initializeAppLinks() {
    // Handle initial deep link when the app launches
    getInitialUri().then((uri) {
      if (uri != null) {
        print("Initial deep link: $uri");
        _oauth2Service.handleRedirect(uri);
      } else {
        print("No initial deep link found.");
      }
    });

    // Listen for subsequent deep links while the app is running
    uriLinkStream.listen((uri) {
      if (uri != null) {
        print("Deep link received: $uri");
        _oauth2Service.handleRedirect(uri);
      }
    });
  }

  Future<void> _loadStoredTokens() async {
    final storage = const FlutterSecureStorage();
    String? accessToken = await storage.read(key: 'accessToken');
    String? refreshToken = await storage.read(key: 'refreshToken');
    String? expirationDate = await storage.read(key: 'expirationDate');

    setState(() {
      _accessToken = accessToken;
      _refreshToken = refreshToken;
      _expirationDate = expirationDate;
    });
  }

  Future<void> _startLogin() async {
    try {
      await _oauth2Service.startOAuthFlow();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign In'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _startLogin,
                child: const Text('Login with OAuth2'),
              ),
              const SizedBox(height: 20),
              if (_accessToken != null)
                Text('Access Token: $_accessToken'),
              if (_refreshToken != null)
                Text('Refresh Token: $_refreshToken'),
              if (_expirationDate != null)
                Text('Expiration Date: $_expirationDate'),
            ],
          ),
        ),
      ),
    );
  }
}

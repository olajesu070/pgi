import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import 'package:flutter_appauth/flutter_appauth.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  static const FlutterAppAuth appAuth = FlutterAppAuth();

  /// Generates a secure random state parameter for OAuth2 requests.
  static String generateState() {
    final Random random = Random.secure();
    final List<int> values = List<int>.generate(16, (_) => random.nextInt(256)); // 128-bit (16 bytes)
    return base64Url.encode(values).replaceAll('=', ''); // URL-safe string
  }

  Future<void> _login(BuildContext context) async {
    const String clientId = '7887150025286687';
    const String redirectUri = 'https://pgi.org/auth/signIn'; // Deep link
    const String authorizationEndpoint = 'https://pgi.org/oauth2/authorize';
    const String tokenEndpoint = 'https://pgi.org/api/oauth2/token';

    try {
      // Log the start of the login flow
      developer.log('Starting OAuth2 login flow...', name: 'OAuth2Login');

      final String state = generateState();
      // Log generated state
      developer.log('Generated state: $state', name: 'OAuth2Login');

      final AuthorizationTokenResponse result =
          await appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          clientId,
          redirectUri,
          serviceConfiguration: const AuthorizationServiceConfiguration(
            authorizationEndpoint: authorizationEndpoint,
            tokenEndpoint: tokenEndpoint,
          ),
          scopes: ['user:read', 'user:write'], // Define the required scopes
        ),
      );

      if (result != null) {
        // Tokens obtained
        developer.log('Access token obtained successfully', name: 'OAuth2Login');
        developer.log('Access Token: ${result.accessToken}', name: 'OAuth2Login');
        developer.log('Refresh Token: ${result.refreshToken}', name: 'OAuth2Login');

        // Use the access token for API requests
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login Successful!')),
        );
      } else {
        developer.log('Authorization failed or was cancelled by the user.', name: 'OAuth2Login');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Authorization Cancelled')),
        );
      }
    } catch (e, stacktrace) {
      developer.log(
        'Error during OAuth2 login process',
        name: 'OAuth2Login',
        error: e,
        stackTrace: stacktrace,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/pgi.jpeg', // Replace with your image path
              fit: BoxFit.cover,
            ),
          ),
          // Content Overlay
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.3,
              decoration: const BoxDecoration(
                color: Color(0xD70A5338),
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // Title
                  const Text(
                    'Welcome to PGI',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Welcome Note
                  const Text(
                    'Welcome to Pyrotechnics Guild International where enthusiasts and professionals connect, share, and celebrate the art of fireworks.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xDFFFFFFF),
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // Test Flutter Web Auth Button
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/signIn');
                        },
                        child: const Text(
                          'Login here',
                          style: TextStyle(
                            fontSize: 18,
                            color: Color(0xFFDBDBDB),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'dart:convert';
import 'dart:math';
import 'dart:ui';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:pgi/core/utils/scopes.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

class OAuth2Service {
  final String clientId;
  final String clientSecret;
  final String authorizationEndpoint;
  final String tokenEndpoint;
  final String redirectUri;
  final FlutterSecureStorage secureStorage;
  final VoidCallback onTokensUpdated;

  OAuth2Service({
    required this.clientId,
    required this.clientSecret,
    required this.authorizationEndpoint,
    required this.tokenEndpoint,
    required this.redirectUri,
    required this.secureStorage,
    required this.onTokensUpdated,
  });

  /// Starts the OAuth2 flow by opening the authorization URL.
  Future<void> startOAuthFlow() async {
    final state = _generateState();
    final authorizationUrl = Uri.parse(authorizationEndpoint).replace(queryParameters: {
      'response_type': 'code',
      'client_id': clientId,
      'redirect_uri': redirectUri,
      'state': state,
      'scope': getScopesAsString(),
    });

    await secureStorage.write(key: 'authState', value: state);

    if (await canLaunch(authorizationUrl.toString())) {
      await launch(authorizationUrl.toString());
    } else {
      throw Exception('Could not launch authorization URL');
    }
  }

  /// Handles the redirect after user authentication.
  Future<void> handleRedirect(Uri redirect) async {
    final storedState = await secureStorage.read(key: 'authState');

    final queryParameters = redirect.queryParameters;
    final returnedState = queryParameters['state'];
    final authCode = queryParameters['code'];
    final error = queryParameters['error'];

    if (error != null) {
      throw Exception('OAuth2 error: $error');
    }

    if (storedState == null || returnedState != storedState) {
      throw Exception('State mismatch error');
    }

    if (authCode == null) {
      throw Exception('Authorization code not found');
    }

    await _exchangeCodeForToken(authCode);
  }

  /// Exchanges the authorization code for access and refresh tokens.
  Future<void> _exchangeCodeForToken(String authCode) async {
    final response = await http.post(
      Uri.parse(tokenEndpoint),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Authorization': 'Basic ${base64Encode(utf8.encode('$clientId:$clientSecret'))}',
      },
      body: {
        'grant_type': 'authorization_code',
        'code': authCode,
        'redirect_uri': redirectUri,
      },
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final accessToken = responseData['access_token'];
      final refreshToken = responseData['refresh_token'];
      final expiresIn = responseData['expires_in'];

      final expirationDate = DateTime.now().add(Duration(seconds: expiresIn));

      await secureStorage.write(key: 'accessToken', value: accessToken);
      await secureStorage.write(key: 'refreshToken', value: refreshToken);
      await secureStorage.write(key: 'expirationDate', value: expirationDate.toIso8601String());

      onTokensUpdated();
    } else {
      throw Exception('Failed to exchange authorization code for tokens');
    }
  }

  /// Refreshes the access token using the refresh token.
  Future<void> _refreshAccessToken() async {
    final refreshToken = await secureStorage.read(key: 'refreshToken');

    if (refreshToken != null) {
      final response = await http.post(
        Uri.parse(tokenEndpoint),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': 'Basic ${base64Encode(utf8.encode('$clientId:$clientSecret'))}',
        },
        body: {
          'grant_type': 'refresh_token',
          'refresh_token': refreshToken,
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final accessToken = responseData['access_token'];
        final expiresIn = responseData['expires_in'];

        final expirationDate = DateTime.now().add(Duration(seconds: expiresIn));

        await secureStorage.write(key: 'accessToken', value: accessToken);
        await secureStorage.write(key: 'expirationDate', value: expirationDate.toIso8601String());

        onTokensUpdated();
      } else {
        throw Exception('Failed to refresh access token');
      }
    }
  }

  /// Checks if the access token is expired and refreshes it if needed.
  Future<void> refreshTokenIfNeeded() async {
    final expirationDateStr = await secureStorage.read(key: 'expirationDate');

    if (expirationDateStr != null) {
      final expirationDate = DateTime.parse(expirationDateStr);
      if (DateTime.now().isAfter(expirationDate)) {
        await _refreshAccessToken();
      }
    }
  }

  /// Logs out the user by clearing all tokens.
  Future<void> logout() async {
    await secureStorage.deleteAll();
  }

  /// Generates a random state parameter for CSRF protection.
  String _generateState() {
    return const Uuid().v4();
  }
}

import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:http/http.dart' as http;
import 'package:pgi/core/utils/scopes.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class OAuth2Service {
  final String _clientId = dotenv.env['CLIENT_ID'] ?? '';
  final String _clientSecret = dotenv.env['CLIENT_SECRET'] ?? '';  // Replace with actual secret
  final String _authorizationEndpoint = dotenv.env['AUTHORIZATION_ENDPOINT'] ?? '';
  final String _tokenEndpoint = dotenv.env['TOKEN_ENDPOINT'] ?? '';
  final String _redirectUri = dotenv.env['REDIRECT_URI'] ?? '';
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final VoidCallback onTokensUpdated;

  OAuth2Service({required this.onTokensUpdated});

  void navigateToHome(BuildContext context) {
    Navigator.of(context).pushReplacementNamed('/home');
  }

  String _generateState() {
    final random = Random.secure();
    final values = List<int>.generate(32, (i) => random.nextInt(256));
    return base64Url.encode(values).replaceAll('=', '').replaceAll('+', '-').replaceAll('/', '_');
  }

  Uri _getAuthorizationUrl() {
    return Uri.parse(_authorizationEndpoint).replace(queryParameters: {
      'response_type': 'code',
      'client_id': _clientId,
      'redirect_uri': _redirectUri,
      'state': _generateState(),
      'scope': getScopesAsString(),
    });
  }

  Future<void> startOAuthFlow(BuildContext context) async {
    try {
      final authorizationUrl = _getAuthorizationUrl().toString();
      final result = await FlutterWebAuth2.authenticate(
        url: authorizationUrl,
        callbackUrlScheme: Uri.parse(_redirectUri).scheme,
      );
      final uri = Uri.parse(result);
      await handleRedirect(uri, context);
    } catch (e) {
      throw Exception('Error during OAuth flow: $e');
    }
  }

  Future<void> handleRedirect(Uri uri, BuildContext context) async {
    final code = uri.queryParameters['code'];
    if (code == null) {
      throw Exception('Authorization code not found in redirect URI');
    }
    await _exchangeCodeForTokens(code, context);
  }

  Future<void> _exchangeCodeForTokens(String code, BuildContext context) async {
    final response = await http.post(Uri.parse(_tokenEndpoint), headers: {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Authorization': 'Basic ${base64Encode(utf8.encode('$_clientId:$_clientSecret'))}',
    }, body: {
      'grant_type': 'authorization_code',
      'code': code,
      'redirect_uri': _redirectUri,
      'client_id': _clientId,
      'client_secret': _clientSecret,
    });

    if (response.statusCode == 200) {
      await _updateTokens(response.body, context);
    } else {
      throw Exception('Failed to exchange authorization code for tokens');
    }
  }

  Future<void> refreshAccessToken(BuildContext context) async {
    final refreshToken = await _secureStorage.read(key: 'refreshToken');
    if (refreshToken == null) {
      throw Exception('Refresh token not available.');
    }
    final response = await http.post(Uri.parse(_tokenEndpoint), headers: {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Authorization': 'Basic ${base64Encode(utf8.encode('$_clientId:$_clientSecret'))}',
    }, body: {
      'grant_type': 'refresh_token',
      'refresh_token': refreshToken,
      'client_id': _clientId,
      'client_secret': _clientSecret,
    });

    if (response.statusCode == 200) {
      await _updateTokens(response.body, context);
    } else {
      throw Exception('Failed to refresh access token');
    }
  }

  Future<void> _updateTokens(String responseBody, BuildContext context) async {
    final responseData = json.decode(responseBody);
    final accessToken = responseData['access_token'];
    final refreshToken = responseData['refresh_token'] ?? await _secureStorage.read(key: 'refreshToken');
    final expiresIn = responseData['expires_in'];
    final expirationDate = DateTime.now().add(Duration(seconds: expiresIn)).toIso8601String();

    await _secureStorage.write(key: 'accessToken', value: accessToken);
    await _secureStorage.write(key: 'refreshToken', value: refreshToken);
    await _secureStorage.write(key: 'expirationDate', value: expirationDate);
    onTokensUpdated();
    navigateToHome(context);
  }

  Future<void> ensureValidAccessToken(BuildContext context) async {
    final expirationDateStr = await _secureStorage.read(key: 'expirationDate');
    if (expirationDateStr != null && DateTime.now().isAfter(DateTime.parse(expirationDateStr))) {
      await refreshAccessToken(context);
    } else {
      navigateToHome(context);
    }
  }

  Future<void> logout(BuildContext context) async {
    await _secureStorage.deleteAll();
    Navigator.of(context).pushReplacementNamed('/');
  }
}

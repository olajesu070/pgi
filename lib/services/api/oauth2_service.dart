import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:http/http.dart' as http;
import 'package:pgi/core/utils/scopes.dart';
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

  void navigateToHome(BuildContext context) {
    Navigator.of(context).pushReplacementNamed('/home');
  }

  String _generateState() {
    final random = Random.secure();
    final values = List<int>.generate(32, (i) => random.nextInt(256));
    return base64Url.encode(values)
        .replaceAll('=', '')
        .replaceAll('+', '-')
        .replaceAll('/', '_');
  }

  Uri _getAuthorizationUrl() {
    try {
      final authUrl = Uri.parse(authorizationEndpoint);
      return authUrl;
    } catch (e) {
      throw Exception('Invalid authorization endpoint URL: $authorizationEndpoint');
    }
  }

  Future<void> startOAuthFlow(BuildContext context) async {
    final state = _generateState();
    await secureStorage.write(key: 'state', value: state);

    final authorizationUrl = _getAuthorizationUrl().replace(queryParameters: {
      'response_type': 'code',
      'client_id': clientId,
      'redirect_uri': redirectUri,
      'state': state,
      'scope': getScopesAsString(),
    });

    try {
      final result = await FlutterWebAuth2.authenticate(
        url: authorizationUrl.toString(),
        callbackUrlScheme: Uri.parse(redirectUri).scheme,
      );

      final uri = Uri.parse(result);
      await handleRedirect(uri, context);
    } catch (e) {
      print('Error during OAuth flow: $e');
      rethrow;
    }
  }

  Future<void> _updateTokensAndNavigate(
    String accessToken, String refreshToken, String expirationDate, BuildContext context) async {
    await secureStorage.write(key: 'accessToken', value: accessToken);
    await secureStorage.write(key: 'refreshToken', value: refreshToken);
    await secureStorage.write(key: 'expirationDate', value: expirationDate);

    onTokensUpdated();
    navigateToHome(context);
  }

  Future<void> handleRedirect(Uri uri, BuildContext context) async {
    final error = uri.queryParameters['error'];
    if (error != null) {
      throw Exception('Error during OAuth flow: $error');
    }

    final state = uri.queryParameters['state'];
    final storedState = await secureStorage.read(key: 'state');

    if (state != storedState) {
      throw Exception('Invalid state parameter');
    }

    await secureStorage.delete(key: 'state');
    final code = uri.queryParameters['code'];

    if (code != null) {
      final tokenUrl = Uri.parse(tokenEndpoint);

      final headers = {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Authorization': 'Basic ${base64Encode(utf8.encode('$clientId:$clientSecret'))}',
      };
      final body = {
        'grant_type': 'authorization_code',
        'code': code,
        'redirect_uri': redirectUri,
        'client_id': clientId,
        'client_secret': clientSecret,
      };

      final response = await http.post(tokenUrl, headers: headers, body: body);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final accessToken = responseData['access_token'];
        final refreshToken = responseData['refresh_token'];
        final expiresIn = responseData['expires_in'];
        final expirationDate = DateTime.now().add(Duration(seconds: expiresIn)).toIso8601String();

        await _updateTokensAndNavigate(accessToken, refreshToken, expirationDate, context);
      } else {
        throw Exception('Failed to exchange authorization code for tokens');
      }
    } else {
      throw Exception('Authorization code not found in redirect URI');
    }
  }

  Future<void> refreshAccessToken(BuildContext context) async {
    final refreshToken = await secureStorage.read(key: 'refreshToken');

    if (refreshToken == null) {
      throw Exception('Refresh token not available.');
    }

    final tokenUrl = Uri.parse(tokenEndpoint);

    final headers = {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Authorization': 'Basic ${base64Encode(utf8.encode('$clientId:$clientSecret'))}',
    };
    final body = {
      'grant_type': 'refresh_token',
      'refresh_token': refreshToken,
      'client_id': clientId,
      'client_secret': clientSecret,
    };

    final response = await http.post(tokenUrl, headers: headers, body: body);

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      final accessToken = responseData['access_token'];
      final newRefreshToken = responseData['refresh_token'] ?? refreshToken;
      final expiresIn = responseData['expires_in'];
      final expirationDate = DateTime.now().add(Duration(seconds: expiresIn)).toIso8601String();

      await _updateTokensAndNavigate(accessToken, refreshToken, expirationDate, context);
    } else {
      throw Exception('Failed to refresh access token');
    }
  }

  Future<void> ensureValidAccessToken(BuildContext context) async {
    final accessToken = await secureStorage.read(key: 'accessToken');
    final refreshToken = await secureStorage.read(key: 'refreshToken');
    final expirationDateStr = await secureStorage.read(key: 'expirationDate');
    if (expirationDateStr != null) {
      final expirationDate = DateTime.parse(expirationDateStr);
      if (DateTime.now().isAfter(expirationDate)) {
        await refreshAccessToken(context);
      }else {
        navigateToHome(context);
      }
    } else {
     if (expirationDateStr != null) {
       await _updateTokensAndNavigate(accessToken!, refreshToken!, expirationDateStr, context);
     } else {
       throw Exception('Expiration date is null');
     }

    }
  }



}

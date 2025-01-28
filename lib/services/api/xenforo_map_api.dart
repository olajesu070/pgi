import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pgi/services/api/oauth2_service.dart';

class MapService {
  final String baseUrl = dotenv.env['BASE_URL'] ?? 'https://pgi.org/api';
  final String apiKey = dotenv.env['CLIENT_ID'] ?? '7887150025286687';
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final OAuth2Service _oauth2Service;

  MapService(this._oauth2Service);

  Future<void> logResponseToFile(String responseBody) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/response_log.txt');
    await file.writeAsString(responseBody);
    debugPrint('Response logged to: ${file.path}');
  }

  Future<dynamic> _handleResponse(http.Response response, BuildContext context) async {
    if (response.statusCode == 401) {
      try {
        debugPrint('Unauthorized, refreshing token...');
        await _oauth2Service.refreshAccessToken(context);
        return null;  // Retry logic can be added if desired
      } catch (e) {
        await _oauth2Service.logout(context);
        throw Exception('Token expired and refresh failed. Logging out.');
      }
    } else if (response.statusCode >= 200 && response.statusCode < 300) {
      logResponseToFile(response.body);
      return response.body.isNotEmpty ? jsonDecode(response.body) : null;
    } else {
      throw Exception('Error: ${response.statusCode} - ${response.body}');
    }
  }

  /// Get map coordinates
  Future<Map<String, dynamic>> getMapCoordinate(BuildContext context) async {
    final url = Uri.parse('$baseUrl/map/');
    final accessToken = await _secureStorage.read(key: 'accessToken');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'XF-Api-Key': apiKey,
        if (accessToken != null) 'Authorization': 'Bearer $accessToken',
      },
    );
    return await _handleResponse(response, context);
  }
}

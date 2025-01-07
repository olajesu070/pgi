import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'dart:developer' as developer;

class XenForoApiService {
  final String baseUrl = dotenv.env['BASE_URL'] ?? 'https://pgi.org/api';
  final String apiKey = dotenv.env['CLIENT_ID'] ?? '7887150025286687';
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
 

Future<void> logResponseToFile(String responseBody) async {
  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/response_log.txt');
  await file.writeAsString(responseBody);
  debugPrint('Response logged to: ${file.path}');
}

  /// Fetch forum threads
Future<Map<String, dynamic>> getForumThreads() async {

  final url = Uri.parse('$baseUrl/threads');
  final accessToken = await _secureStorage.read(key: 'accessToken');

  debugPrint('Attempting to fetch threads from $url');
  debugPrint('Access Token: ${accessToken != null ? 'Present' : 'Not Present'}');

  try {
    final response = await http
        .get(
          url,
          headers: {
            'Content-Type': 'application/json',
            'XF-Api-Key': apiKey,
            if (accessToken != null) 'Authorization': 'Bearer $accessToken',
          },
        )
        .timeout(const Duration(seconds: 10)); // Handle unresponsive API

    // debugPrint('Response status code: ${response.statusCode}');

    if (response.statusCode == 200) {
      if (response.body.isEmpty) {
        throw Exception('Empty response body received.');
      }
      return jsonDecode(response.body);
    } else if (response.statusCode == 204) {
      debugPrint('No content returned (204)');
      return {};
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized access. Check your API key or token.');
    } else if (response.statusCode == 403) {
      throw Exception('Access forbidden. Ensure you have the correct permissions.');
    } else {
      throw Exception('Failed to load threads. Status code: ${response.statusCode}');
    }
  } catch (e) {
    debugPrint('Exception occurred while fetching threads: $e');
    throw Exception('Error occurred: $e');
  }
}



  // Add more methods for other API endpoints as needed
}

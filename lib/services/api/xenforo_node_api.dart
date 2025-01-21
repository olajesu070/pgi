import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class NodeServices {
  final String baseUrl = dotenv.env['BASE_URL'] ?? 'https://pgi.org/api';
  final String apiKey = dotenv.env['CLIENT_ID'] ?? '7887150025286687';
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

   // Helper method to handle API responses
  Future<dynamic> _handleResponse(http.Response response) async {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      debugPrint('Node info: ${response.body}');
      return response.body.isNotEmpty ? jsonDecode(response.body) : null;
    } else {
      throw Exception('Error: ${response.statusCode} - ${response.body}');
    }
  }

// GET nodes/{id}/
// Gets information about the specified node

Future<Map<String, dynamic>> getNodeById(int id) async {
    final url = Uri.parse('$baseUrl/nodes/$id/');
    final accessToken = await _secureStorage.read(key: 'accessToken');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'XF-Api-Key': apiKey,
        if (accessToken != null) 'Authorization': 'Bearer $accessToken',
      },
    );
    return await _handleResponse(response);
  }

// GET nodes/
// Gets all node

Future<Map<String, dynamic>> getNodes() async {
    final url = Uri.parse('$baseUrl/nodes/');
    final accessToken = await _secureStorage.read(key: 'accessToken');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'XF-Api-Key': apiKey,
        if (accessToken != null) 'Authorization': 'Bearer $accessToken',
      },
    );
    return await _handleResponse(response);
  }
}
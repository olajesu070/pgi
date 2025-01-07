import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class NotificationService {
  final String baseUrl = dotenv.env['BASE_URL'] ?? 'https://pgi.org/api';
  final String apiKey = dotenv.env['CLIENT_ID'] ?? '7887150025286687';
   final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

   // Helper method to handle API responses
  Future<dynamic> _handleResponse(http.Response response) async {
    if (response.statusCode >= 200 && response.statusCode < 300) {
       debugPrint('user info: ${response.body}');
      return response.body.isNotEmpty ? jsonDecode(response.body) : null;
    } else {
      throw Exception('Error: ${response.statusCode} - ${response.body}');
    }
  }

  /// Fetches the list of alerts.
  Future<Map<String, dynamic>> getAlerts({int page = 1, int? cutoff, bool? unviewed, bool? unread}) async {
    
      final Uri uri = Uri.parse('$baseUrl/alerts').replace(queryParameters: {
        'page': page.toString(),
        if (cutoff != null) 'cutoff': cutoff.toString(),
        if (unviewed != null) 'unviewed': unviewed.toString(),
        if (unread != null) 'unread': unread.toString(),
      });
      final accessToken = await _secureStorage.read(key: 'accessToken');

      final response = await http.get(uri, 
      headers: {
        'Content-Type': 'application/json',
        'XF-Api-Key': apiKey,
        if (accessToken != null) 'Authorization': 'Bearer $accessToken',
      });

     return await _handleResponse(response);
  }

  /// Marks all alerts as read or viewed.
  Future<bool> markAllAlerts({bool read = false, bool viewed = false}) async {
    try {
      final Uri uri = Uri.parse('$baseUrl/alerts/mark-all');
      final accessToken = await _secureStorage.read(key: 'accessToken');

      final response = await http.post(uri, 
      headers: {
        'Content-Type': 'application/json',
        'XF-Api-Key': apiKey,
        if (accessToken != null) 'Authorization': 'Bearer $accessToken',
      }, 
      body: jsonEncode({
        'read': read,
        'viewed': viewed,
      }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      } else {
        throw Exception('Failed to mark alerts as read/viewed. Status code: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Error marking alerts: $error');
    }
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:pgi/core/utils/api_handle_response.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class NotificationService {
  final String baseUrl = dotenv.env['BASE_URL'] ?? 'https://pgi.org/api';
  final String apiKey = dotenv.env['CLIENT_ID'] ?? '7887150025286687';
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();


  /// Fetches the list of alerts with optional filters.
  Future<Map<String, dynamic>> getAlerts({int page = 1, int? cutoff, bool? unviewed, bool? unread}) async {
    final Uri uri = Uri.parse('$baseUrl/alerts').replace(queryParameters: {
      'page': page.toString(),
      if (cutoff != null) 'cutoff': cutoff.toString(),
      if (unviewed != null) 'unviewed': unviewed.toString(),
      if (unread != null) 'unread': unread.toString(),
    });
    final accessToken = await _secureStorage.read(key: 'accessToken');

    final response = await http.get(uri, headers: {
      'Content-Type': 'application/json',
      'XF-Api-Key': apiKey,
      if (accessToken != null) 'Authorization': 'Bearer $accessToken',
    });

    return await ApiResponseHelper.handleResponse(response);
  }

  /// Gets information about a specific alert by its ID.
  Future<Map<String, dynamic>> getAlertById(String id) async {
    final Uri uri = Uri.parse('$baseUrl/alerts/$id');
    final accessToken = await _secureStorage.read(key: 'accessToken');

    final response = await http.get(uri, headers: {
      'Content-Type': 'application/json',
      'XF-Api-Key': apiKey,
      if (accessToken != null) 'Authorization': 'Bearer $accessToken',
    });

    return await ApiResponseHelper.handleResponse(response);
  }

  /// Marks an alert as read, unread, or viewed by its ID.
  Future<bool> markAlert(String id, {bool? read, bool? unread, bool? viewed}) async {
    final Uri uri = Uri.parse('$baseUrl/alerts/$id/mark').replace(queryParameters: {
      if (read != null) 'read': read.toString(),
      if (unread != null) 'unread': unread.toString(),
      if (viewed != null) 'viewed': viewed.toString(),
    });
    final accessToken = await _secureStorage.read(key: 'accessToken');

    final response = await http.post(uri, headers: {
      'Content-Type': 'application/json',
      'XF-Api-Key': apiKey,
      if (accessToken != null) 'Authorization': 'Bearer $accessToken',
    });

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['success'] == true;
    } else {
      throw Exception('Failed to mark alert. Status code: ${response.statusCode}');
    }
  }

  /// Marks all alerts as read or viewed.
  Future<bool> markAllAlerts({bool read = false, bool viewed = true}) async {
    final Uri uri = Uri.parse('$baseUrl/alerts/mark-all').replace(queryParameters: {
      'read': read.toString(),
      'viewed': viewed.toString(),
    });
    final accessToken = await _secureStorage.read(key: 'accessToken');

    final response = await http.post(uri, headers: {
      'Content-Type': 'application/json',
      'XF-Api-Key': apiKey,
      if (accessToken != null) 'Authorization': 'Bearer $accessToken',
    });

    return await ApiResponseHelper.handleResponse(response) != null;
  }
}

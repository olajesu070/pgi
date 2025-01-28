import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();


class ApiResponseHelper {
  // Helper method to handle API responses
  static Future<dynamic> handleResponse(http.Response response) async {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      debugPrint('Response: ${response.body}');
      return response.body.isNotEmpty ? jsonDecode(response.body) : null;
    } else if (response.statusCode == 401) {
      // Navigate to the login screen
      Navigator.of(navigatorKey.currentContext!).pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
      throw Exception('Unauthorized: ${response.statusCode} - ${response.body}');
    } else {
      throw Exception('Error: ${response.statusCode} - ${response.body}');
    }
  }
}

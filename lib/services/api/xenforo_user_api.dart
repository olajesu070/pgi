import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

class XenForoUserApi {
  final String baseUrl = dotenv.env['BASE_URL'] ?? 'https://pgi.org/api';
  final String apiKey = dotenv.env['CLIENT_ID'] ?? '7887150025286687';
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();


  Future<Map<String, dynamic>> _handleResponse(http.Response response) async {
    if (response.statusCode == 200) {
      if (response.body.isEmpty) {
        throw Exception('Empty response body received.');
      }
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed with status code: ${response.statusCode}');
    }
  }

  /// Fetch information about the current user
  Future<Map<String, dynamic>> getCurrentUserInfo() async {
    final url = Uri.parse('$baseUrl/me');
    final accessToken = await _secureStorage.read(key: 'accessToken');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'XF-Api-Key': apiKey,
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
      );
      return await _handleResponse(response);
    } catch (e) {
      debugPrint('Error fetching user info: $e');
      rethrow;
    }
  }

  /// Update the current user's avatar
  Future<bool> updateUserAvatar(File avatar) async {
    final url = Uri.parse('$baseUrl/me/avatar');
    final accessToken = await _secureStorage.read(key: 'accessToken');

    try {
      final request = http.MultipartRequest('POST', url)
        ..headers.addAll({
          'XF-Api-Key': apiKey,
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        })
        ..files.add(await http.MultipartFile.fromPath('avatar', avatar.path));

      final response = await http.Response.fromStream(await request.send());
      final responseBody = jsonDecode(response.body);
      return responseBody['success'] == true;
    } catch (e) {
      debugPrint('Error updating avatar: $e');
      rethrow;
    }
  }

  /// Update the current user's email
  Future<bool> updateUserEmail(String currentPassword, String newEmail) async {
    final url = Uri.parse('$baseUrl/me/email');
    final accessToken = await _secureStorage.read(key: 'accessToken');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'XF-Api-Key': apiKey,
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'current_password': currentPassword,
          'email': newEmail,
        }),
      );
      final responseBody = jsonDecode(response.body);
      return responseBody['success'] == true;
    } catch (e) {
      debugPrint('Error updating email: $e');
      rethrow;
    }
  }

  /// Update the current user's password
  Future<bool> updateUserPassword(String currentPassword, String newPassword) async {
    final url = Uri.parse('$baseUrl/me/password');
    final accessToken = await _secureStorage.read(key: 'accessToken');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'XF-Api-Key': apiKey,
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'current_password': currentPassword,
          'new_password': newPassword,
        }),
      );
      final responseBody = jsonDecode(response.body);
      return responseBody['success'] == true;
    } catch (e) {
      debugPrint('Error updating password: $e');
      rethrow;
    }
  }

  /// Update the current user's information
  Future<bool> updateUserInfo(Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/me');
    final accessToken = await _secureStorage.read(key: 'accessToken');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'XF-Api-Key': apiKey,
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(data),
      );
      final responseBody = jsonDecode(response.body);
      return responseBody['success'] == true;
    } catch (e) {
      debugPrint('Error updating user info: $e');
      rethrow;
    }
  }
}

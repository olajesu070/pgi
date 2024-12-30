import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class XenForoForumService {
  final String baseUrl = dotenv.env['BASE_URL'] ?? 'https://pgi.org/api';
  final String apiKey = dotenv.env['CLIENT_ID'] ?? '7887150025286687';
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();



  Future<Map<String, dynamic>> getForumInfo({
    required int forumId,
    bool? withThreads,
    int? page,
    int? prefixId,
    int? starterId,
    int? lastDays,
    bool? unread,
    String? threadType,
    String? order,
    String? direction,
  }) async {
    final accessToken = await _secureStorage.read(key: 'accessToken');
    final queryParameters = {
      if (withThreads != null) 'with_threads': withThreads.toString(),
      if (page != null) 'page': page.toString(),
      if (prefixId != null) 'prefix_id': prefixId.toString(),
      if (starterId != null) 'starter_id': starterId.toString(),
      if (lastDays != null) 'last_days': lastDays.toString(),
      if (unread != null) 'unread': unread.toString(),
      if (threadType != null) 'thread_type': threadType,
      if (order != null) 'order': order,
      if (direction != null) 'direction': direction,
    };

    final uri = Uri.parse('$baseUrl/forums/$forumId').replace(queryParameters: queryParameters);
    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'XF-Api-Key': apiKey,
        if (accessToken != null) 'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch forum info. Status code: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> markForumAsRead({
    required int forumId,
    int? date,
  }) async {
    final accessToken = await _secureStorage.read(key: 'accessToken');
    final uri = Uri.parse('$baseUrl/forums/$forumId/mark-read');
    final body = jsonEncode({
      if (date != null) 'date': date,
    });

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'XF-Api-Key': apiKey,
        if (accessToken != null) 'Authorization': 'Bearer $accessToken',
      },
      body: body,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to mark forum as read. Status code: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> getForumThreads({
    required int forumId,
    int? page,
    int? prefixId,
    int? starterId,
    int? lastDays,
    bool? unread,
    String? threadType,
    String? order,
    String? direction,
  }) async {
    final accessToken = await _secureStorage.read(key: 'accessToken');
    final queryParameters = {
      if (page != null) 'page': page.toString(),
      if (prefixId != null) 'prefix_id': prefixId.toString(),
      if (starterId != null) 'starter_id': starterId.toString(),
      if (lastDays != null) 'last_days': lastDays.toString(),
      if (unread != null) 'unread': unread.toString(),
      if (threadType != null) 'thread_type': threadType,
      if (order != null) 'order': order,
      if (direction != null) 'direction': direction,
    };

    final uri = Uri.parse('$baseUrl/forums/$forumId/threads').replace(queryParameters: queryParameters);
    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'XF-Api-Key': apiKey,
        if (accessToken != null) 'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch forum threads. Status code: ${response.statusCode}');
    }
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ConversationService {
  final String baseUrl = dotenv.env['BASE_URL'] ?? 'https://pgi.org/api';
  final String apiKey = dotenv.env['CLIENT_ID'] ?? '7887150025286687';
   final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Helper method to handle API responses
  Future<dynamic> _handleResponse(http.Response response) async {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response.body.isNotEmpty ? jsonDecode(response.body) : null;
    } else {
      throw Exception('Error: ${response.statusCode} - ${response.body}');
    }
  }

  /// POST conversation-messages/
  /// Replies to a conversation
  Future<Map<String, dynamic>> replyToConversation({
    required int conversationId,
    required String message,
    String? attachmentKey,
  }) async {
    final url = Uri.parse('$baseUrl/conversation-messages/');
    final accessToken = await _secureStorage.read(key: 'accessToken');


    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'XF-Api-Key': apiKey,
        if (accessToken != null) 'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode({
        'conversation_id': conversationId,
        'message': message,
        if (attachmentKey != null) 'attachment_key': attachmentKey,
      }),
    );
    return await _handleResponse(response);
  }

  /// GET conversation-messages/{id}/
  /// Gets a specific conversation message
  Future<Map<String, dynamic>> getConversationMessageById(int id) async {
    final url = Uri.parse('$baseUrl/conversation-messages/$id/');
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

  /// POST conversation-messages/{id}/
  /// Updates a specific conversation message
  Future<Map<String, dynamic>> updateConversationMessage({
    required int messageId,
    required String newMessage,
    String? attachmentKey,
  }) async {
    final url = Uri.parse('$baseUrl/conversation-messages/$messageId/');
    final accessToken = await _secureStorage.read(key: 'accessToken');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'XF-Api-Key': apiKey,
        if (accessToken != null) 'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode({
        'message': newMessage,
        if (attachmentKey != null) 'attachment_key': attachmentKey,
      }),
    );
    return await _handleResponse(response);
  }

  /// POST conversation-messages/{id}/react
  /// Reacts to a specific conversation message
  Future<Map<String, dynamic>> reactToConversationMessage({
    required int messageId,
    required int reactionId,
  }) async {
    final url = Uri.parse('$baseUrl/conversation-messages/$messageId/react');
    final accessToken = await _secureStorage.read(key: 'accessToken');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'XF-Api-Key': apiKey,
        if (accessToken != null) 'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode({
        'reaction_id': reactionId,
      }),
    );
    return await _handleResponse(response);
  }
}

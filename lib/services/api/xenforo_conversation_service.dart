import 'dart:convert';
import 'package:flutter/material.dart';
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
      // debugPrint('messages info: ${response.body}');
      return response.body.isNotEmpty ? jsonDecode(response.body) : null;
    } else {
      throw Exception('Error: ${response.statusCode} - ${response.body}');
    }
  }

 /// GET conversations/
/// Gets the API user's list of conversations with optional filters.
Future<Map<String, dynamic>> getConversations({
  int? page,
  int? starterId,
  int? receiverId,
  bool? starred,
  bool? unread,
  String? search, // 🔍 New search parameter
}) async {
  final queryParams = <String, String>{};
  
  if (page != null) queryParams['page'] = page.toString();
  if (starterId != null) queryParams['starter_id'] = starterId.toString();
  if (receiverId != null) queryParams['receiver_id'] = receiverId.toString();
  if (starred != null) queryParams['starred'] = starred.toString();
  if (unread != null) queryParams['unread'] = unread.toString();
  if (search != null && search.isNotEmpty) queryParams['q'] = search; // 🔍 Add search query

  final url = Uri.parse('$baseUrl/conversations/').replace(queryParameters: queryParams);
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


 Future<Map<String, dynamic>> createConversation({
  required List<int> recipientIds,
  required String title,
  required String message,
  String? attachmentKey,
  bool? conversationOpen,
  bool? openInvite,
}) async {
  // Construct the query parameters
  final queryParams = {
    'recipient_ids': recipientIds.toString(),
    'title': title,
    'message': message,
    if (attachmentKey != null) 'attachment_key': attachmentKey,
    if (conversationOpen != null) 'conversation_open': conversationOpen.toString(),
    if (openInvite != null) 'open_invite': openInvite.toString(),
  };

  // Build the full URL with query parameters
  final url = Uri.parse('$baseUrl/conversations/').replace(queryParameters: queryParams);

  // Retrieve the access token
  final accessToken = await _secureStorage.read(key: 'accessToken');

  // Send the POST request
  final response = await http.post(
    url,
    headers: {
      'Content-Type': 'multipart/form-data',
      'XF-Api-Key': apiKey,
      if (accessToken != null) 'Authorization': 'Bearer $accessToken',
    },
    body: '{}',  // Empty body since we're using query params
  );

  // Log the response for debugging purposes
  debugPrint('Response status: ${response.statusCode}');
  debugPrint('Response body: $response');

  return await _handleResponse(response);
}

  Future<Map<String, dynamic>> replyToConversation({
  required int conversationId,
  required String message,
  String? attachmentKey,
}) async {
  // Build the URL with query parameters
  final url = Uri.parse('$baseUrl/conversation-messages/').replace(queryParameters: {
    'conversation_id': conversationId.toString(),
    'message': message,
    if (attachmentKey != null) 'attachment_key': attachmentKey,
  });

  final accessToken = await _secureStorage.read(key: 'accessToken');

  final response = await http.post( 
    url,
    headers: {
      'XF-Api-Key': apiKey,
      if (accessToken != null) 'Authorization': 'Bearer $accessToken',
    },
  );

  return await _handleResponse(response);
}


  
  ///   GET conversations/{id}/messages
  /// Gets a page of messages in the specified conversation.
  Future<Map<String, dynamic>> getConversationMessagesById(int id) async {
      final url = Uri.parse('$baseUrl/conversations/$id/messages');
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

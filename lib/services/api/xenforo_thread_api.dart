import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:path_provider/path_provider.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class ThreadService {
  final String baseUrl = dotenv.env['BASE_URL'] ?? 'https://pgi.org/api';
  final String apiKey = dotenv.env['CLIENT_ID'] ?? '7887150025286687';
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

Future<void> logResponseToFile(String responseBody) async {
  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/response_log.txt');
  await file.writeAsString(responseBody);
  debugPrint('Response logged to: ${file.path}');
}
  // Helper function to send GET requests
  Future<Map<String, dynamic>> _get(String endpoint) async {
    final accessToken = await _secureStorage.read(key: 'accessToken');
    final response = await http.get(
      Uri.parse('$baseUrl/$endpoint'),
      headers: {'Content-Type': 'application/json',
            'XF-Api-Key': apiKey,
            'Authorization': 'Bearer $accessToken'},
    );
    return _processResponse(response);
  }

  // Helper function to send POST requests
  Future<Map<String, dynamic>> _post(String endpoint, Map<String, dynamic> body) async {
    final accessToken = await _secureStorage.read(key: 'accessToken');
    final response = await http.post(
      Uri.parse('$baseUrl/$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        'XF-Api-Key': apiKey,
        'Authorization': 'Bearer $accessToken'
      },
      body: jsonEncode(body),
    );
    return _processResponse(response);
  }

  // Helper function to send DELETE requests
  Future<Map<String, dynamic>> _delete(String endpoint, {Map<String, dynamic>? body}) async {
    final accessToken = await _secureStorage.read(key: 'accessToken');
    final response = await http.delete(
      Uri.parse('$baseUrl/$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        'XF-Api-Key': apiKey,
        'Authorization': 'Bearer $accessToken'
      },
      body: body != null ? jsonEncode(body) : null,
    );
    return _processResponse(response);
  }

  // Process API response
  Map<String, dynamic> _processResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      // debugPrint('thread info: ${response.body}');
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to connect to API: ${response.body}${response.body}');
    }
  }

  // Helper method to handle API responses
  Future<dynamic> _handleResponse(http.Response response) async {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      // debugPrint('post info: ${response.body}');
      return response.body.isNotEmpty ? jsonDecode(response.body) : null;
    }else if (response.statusCode == 401) {
     // Navigate to the login screen
      Navigator.of(navigatorKey.currentContext!).pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false); 
    } else {
      throw Exception('Error: ${response.statusCode} - ${response.body}');
    }
  }

  // Create a thread
  Future<Map<String, dynamic>> createThread({
    required int nodeId,
    required String title,
    required String message,
    String? discussionType,
    int? prefixId,
    List<String>? tags,
    Map<String, dynamic>? customFields,
    bool? discussionOpen,
    bool? sticky,
    String? attachmentKey,
  }) async {
    final body = {
      'node_id': nodeId,
      'title': title,
      'message': message,
      if (discussionType != null) 'discussion_type': discussionType,
      if (prefixId != null) 'prefix_id': prefixId,
      if (tags != null) 'tags': tags,
      if (customFields != null) 'custom_fields': customFields,
      if (discussionOpen != null) 'discussion_open': discussionOpen,
      if (sticky != null) 'sticky': sticky,
      if (attachmentKey != null) 'attachment_key': attachmentKey,
    };
    return await _post('threads/', body);
  }

  // Get thread details
  Future<Map<String, dynamic>> getThreadDetails({
    required int threadId,
    bool? withPosts,
    int? page,
    bool? withFirstPost,
    bool? withLastPost,
    String? order,
  }) async {
    final queryParams = {
      if (withPosts != null) 'with_posts': withPosts.toString(),
      if (page != null) 'page': page.toString(),
      if (withFirstPost != null) 'with_first_post': withFirstPost.toString(),
      if (withLastPost != null) 'with_last_post': withLastPost.toString(),
      if (order != null) 'order': order,
    };
    final query = Uri(queryParameters: queryParams).query;
    return await _get('threads/$threadId${query.isNotEmpty ? '?$query' : ''}');
  }

  // Update a thread
  Future<Map<String, dynamic>> updateThread({
    required int threadId,
    String? title,
    int? prefixId,
    bool? discussionOpen,
    bool? sticky,
    Map<String, dynamic>? customFields,
    List<String>? addTags,
    List<String>? removeTags,
  }) async {
    final body = {
      if (title != null) 'title': title,
      if (prefixId != null) 'prefix_id': prefixId,
      if (discussionOpen != null) 'discussion_open': discussionOpen,
      if (sticky != null) 'sticky': sticky,
      if (customFields != null) 'custom_fields': customFields,
      if (addTags != null) 'add_tags': addTags,
      if (removeTags != null) 'remove_tags': removeTags,
    };
    return await _post('threads/$threadId/', body);
  }

  

  // Delete a thread
  Future<Map<String, dynamic>> deleteThread({
    required int threadId,
    bool? hardDelete,
    String? reason,
    bool? starterAlert,
    String? starterAlertReason,
  }) async {
    final body = {
      if (hardDelete != null) 'hard_delete': hardDelete,
      if (reason != null) 'reason': reason,
      if (starterAlert != null) 'starter_alert': starterAlert,
      if (starterAlertReason != null) 'starter_alert_reason': starterAlertReason,
    };
    return await _delete('threads/$threadId/', body: body);
  }

  // Move a thread
  Future<Map<String, dynamic>> moveThread({
    required int threadId,
    required int targetNodeId,
    int? prefixId,
    String? title,
    bool? notifyWatchers,
    bool? starterAlert,
    String? starterAlertReason,
  }) async {
    final body = {
      'target_node_id': targetNodeId,
      if (prefixId != null) 'prefix_id': prefixId,
      if (title != null) 'title': title,
      if (notifyWatchers != null) 'notify_watchers': notifyWatchers,
      if (starterAlert != null) 'starter_alert': starterAlert,
      if (starterAlertReason != null) 'starter_alert_reason': starterAlertReason,
    };
    return await _post('threads/$threadId/move', body);
  }

//  /posts/
// Adds a new reply to a thread.
  Future<Map<String, dynamic>> addReply({
    required int threadId,
    required String message,
    String? attachmentKey,
  }) async {
    final url = Uri.parse('$baseUrl/posts/').replace(queryParameters: {
      'thread_id': threadId.toString(),
      'message' : message,
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
  

//   GET posts/{id}/
// Gets information about the specified post.
  Future<Map<String, dynamic>> getPostById(int id) async {
    return await _get('posts/$id/');
  }

//   POST posts/{id}/vote
// Votes on the specified post (if applicable)
// Parameters
// Input	Type	Description
// type	string	 Type of vote, "up" or "down". Use the current type to undo.
  Future<Map<String, dynamic>> voteOnPost({
    required int postId,
    required String type,
  }) async {
    final body = {
      'type': type,
    };
    return await _post('posts/$postId/vote', body);
  }


// POST posts/{id}/react
// Reacts to the specified post
// Parameters
// Input	Type	Description
// reaction_id	integer	 ID of the reaction to use. Use the current reaction ID to undo
   Future<Map<String, dynamic>> reactOnPost({
    required int postId,
    required int reactionId,
  }) async {
    final body = {
      'reaction_id': reactionId,
    };
    return await _post('posts/$postId/react?reaction_id=$reactionId', body);
  }

}

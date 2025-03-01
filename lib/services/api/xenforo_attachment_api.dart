import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AttachmentService {
  final String? baseUrl = dotenv.env['BASE_URL'];
  final String? apiKey = dotenv.env['CLIENT_ID'];


  /// **Step 1: Create a new attachment key**
  Future<String?> createAttachmentKey(String type, {Map<String, String>? context}) async {
    final url = Uri.parse('$baseUrl/attachments/new-key');

    try {
      final response = await http.post(
        url,
        headers: {'Authorization': 'Bearer $apiKey'},
        body: {
          'type': type,
          if (context != null) 'context': jsonEncode(context),
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['key']; // Return the attachment key
      } else {
        throw Exception('Failed to create attachment key: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error creating attachment key: $e');
    }
  }

  /// **Step 2: Upload an attachment using the key**
  Future<Map<String, dynamic>> uploadAttachment(File file, String attachmentKey) async {
    final url = Uri.parse('$baseUrl/attachments/');

    try {
      var request = http.MultipartRequest('POST', url)
        ..headers['Authorization'] = 'Bearer $apiKey'
        ..fields['key'] = attachmentKey
        ..files.add(await http.MultipartFile.fromPath('attachment', file.path));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to upload attachment: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error uploading attachment: $e');
    }
  }

  /// **Step 3: Retrieve uploaded attachment details**
  Future<Map<String, dynamic>> getAttachment(String attachmentKey) async {
    final url = Uri.parse('$baseUrl/attachments/?key=$attachmentKey');

    try {
      final response = await http.get(url, headers: {'Authorization': 'Bearer $apiKey'});

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to fetch attachments: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching attachment: $e');
    }
  }
}

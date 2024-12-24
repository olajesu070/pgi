import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class XenForoApiService {
  final String baseUrl = dotenv.env['BASE_URL'] ?? 'https://pgi.org/api';
  final String apiKey = dotenv.env['CLIENT_ID'] ?? '7887150025286687';

 Future<Map<String, dynamic>> getForumThreads() async {
  final url = Uri.parse('$baseUrl/threads');
  
  try {
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
         'XF-Api-Key': apiKey,
      },
    );

    if (response.statusCode == 200) {
      // If the response contains data, decode and return it
      return jsonDecode(response.body);
    } else if (response.statusCode == 204) {
      // No content returned (successful request but no data)
      return {};  // Return an empty map or handle as needed
    } else {
      // For other status codes, throw an exception
      throw Exception('Failed to load threads. Status code: ${response.statusCode}');
    }
  } catch (e) {
    // Handle any errors that occur during the request
    throw Exception('Error occurred: $e');
  }
}


 Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/auth/');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json', 'XF-Api-Key': apiKey,},
        body: jsonEncode({
          'login': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': 'Invalid credentials'};
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // Add more methods for other API endpoints as needed
}

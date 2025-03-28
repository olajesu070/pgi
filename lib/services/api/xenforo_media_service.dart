import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
class MediaService {
  final String baseUrl = dotenv.env['BASE_URL'] ?? 'https://pgi.org/api';
  final String apiKey = dotenv.env['CLIENT_ID'] ?? '7887150025286687';
    final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Generic method to handle API responses
 Future<Map<String, dynamic>> _handleResponse(http.Response response) async {
    if (response.statusCode == 200) {
      if (response.body.isEmpty) {
        throw Exception('Empty response body received.');
      }
      //  debugPrint('mediainfo: ${response.body}');
      return jsonDecode(response.body);
    } else {
      print('error: ${response.body}');
      throw Exception('Failed with status code: ${response.statusCode}');
    }
  }

  // GET /media/
  Future<Map<String, dynamic>> fetchAllMedia() async {
    final url = Uri.parse('$baseUrl/media/');
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

  // GET media-categories/ 
   Future<Map<String, dynamic>> fetchAllMediaCategories() async {
    final url = Uri.parse('$baseUrl/media-categories/');
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

  // POST /media/
  Future<dynamic> createMedia(int id, Map<String, dynamic> mediaData) async {
    final url = Uri.parse('$baseUrl/media/$id');
     final accessToken = await _secureStorage.read(key: 'accessToken');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'XF-Api-Key': apiKey,
        if (accessToken != null) 'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(mediaData),
    );
    return await _handleResponse(response);
  }
  // POST /media/ (Upload Image)
  Future<dynamic> uploadMedia({
    required String filePath,
    String? categoryId,
    String? albumId,
    String? description,
  }) async {
    final url = Uri.parse(
      '$baseUrl/media${categoryId != null ? '?$categoryId' : albumId != null ? '?$albumId' : ''}',
    );
    final accessToken = await _secureStorage.read(key: 'accessToken');

    final request = http.MultipartRequest('POST', url)
      ..headers.addAll({
        'XF-Api-Key': apiKey,
        if (accessToken != null) 'Authorization': 'Bearer $accessToken',
      })
      ..files.add(await http.MultipartFile.fromPath('file', filePath));

    if (description != null) {
      request.fields['description'] = description;
    }

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();
    print('Uploading to URL: $url');
    if (response.statusCode == 200) {
      return jsonDecode(responseBody);
    } else {
      final errorResponse = jsonDecode(responseBody);
      final errorMessage = errorResponse['errors'] != null && errorResponse['errors'].isNotEmpty
          ? errorResponse['errors'][0]['message']
          : 'Unknown error occurred';
      print('error uploading: $responseBody');
      throw Exception('message: $errorMessage');
    }
  }

  // GET /media/{id}/
  Future<dynamic> fetchMediaById(String id) async {
    final url = Uri.parse('$baseUrl/media/$id/');
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

  // GET media-categories/{id}/ 
   Future<dynamic> fetchMediaCategoriesById(int id) async {
    final url = Uri.parse('$baseUrl/media-categories/$id/content');
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

  // POST /media/{id}/
  Future<dynamic> updateMedia(String id, Map<String, dynamic> mediaData) async {
    final url = Uri.parse('$baseUrl/media/$id/');
    final accessToken = await _secureStorage.read(key: 'accessToken');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'XF-Api-Key': apiKey,
        if (accessToken != null) 'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(mediaData),
    );
    return await _handleResponse(response);
  }

  // DELETE /media/{id}/
  Future<bool> deleteMedia(String id) async {
    final url = Uri.parse('$baseUrl/media/$id/');
    final accessToken = await _secureStorage.read(key: 'accessToken');

    final response = await http.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
        'XF-Api-Key': apiKey,
        if (accessToken != null) 'Authorization': 'Bearer $accessToken',
      },
    );
    return response.statusCode == 204; // Assuming 204 No Content on success
  }

  // GET /media/{id}/comments
  Future<List<dynamic>> fetchMediaComments(String id) async {
    final url = Uri.parse('$baseUrl/media/$id/comments');
    final accessToken = await _secureStorage.read(key: 'accessToken');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'XF-Api-Key': apiKey,
        if (accessToken != null) 'Authorization': 'Bearer $accessToken',
      },
    );
    return await _handleResponse(response) as List<dynamic>;
  }

  // GET /media/{id}/data
  Future<dynamic> fetchMediaData(String id) async {
    final url = Uri.parse('$baseUrl/media/$id/data');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'XF-Api-Key': apiKey,
      },
    );
    return await _handleResponse(response);
  }

  // POST /media/{id}/react
  Future<dynamic> reactToMedia(String id, Map<String, dynamic> reactionData) async {
    final url = Uri.parse('$baseUrl/media/$id/react');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'XF-Api-Key': apiKey,
      },
      body: jsonEncode(reactionData),
    );
    return await _handleResponse(response);
  }

  // GET /media-albums/
  Future<Map<String, dynamic>> fetchAllMediaAlbums() async {
    final url = Uri.parse('$baseUrl/media-albums/');
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

   // GET /media-albums/
  Future<Map<String, dynamic>> fetchMediaAlbumById(int albumId) async {
    final url = Uri.parse('$baseUrl/media-albums/$albumId/media/');
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

  // POST /media-albums/
  Future<dynamic> createMediaAlbum({
    required String name,
    String? description,
  }) async {
    final queryParams = {
      'title': name,
      if (description != null) 'description': description,
    };

    final url = Uri.parse('$baseUrl/media-albums/').replace(queryParameters: queryParams);
    final accessToken = await _secureStorage.read(key: 'accessToken');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'XF-Api-Key': apiKey,
        if (accessToken != null) 'Authorization': 'Bearer $accessToken',
      },
    );
    return await _handleResponse(response);
  }
}

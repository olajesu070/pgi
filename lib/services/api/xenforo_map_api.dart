import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';

class MapService {
  final String baseUrl = dotenv.env['BASE_URL'] ?? 'https://pgi.org/api';
  final String apiKey = dotenv.env['CLIENT_ID'] ?? '7887150025286687';
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Future<void> logResponseToFile(String responseBody) async {
  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/response_log.txt');
  await file.writeAsString(responseBody);
  debugPrint('Response logged to: ${file.path}');
}

  // Helper method to handle API responses
  Future<dynamic> _handleResponse(http.Response response) async {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      print('map info: ${response.body}');
      logResponseToFile(response.body);
      return response.body.isNotEmpty ? jsonDecode(response.body) : null;
    }else if(response.statusCode == 401){
      //  Navigator.pushNamed(context, '/profile');
    } 
    else {
      throw Exception('Error: ${response.statusCode} - ${response.body}');
    }
  }


  /// Get map/
  /// Gets the map coordinates
  Future<Map<String, dynamic>> getMapCoordinate()async{
    final url = Uri.parse('$baseUrl/map/');
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
}
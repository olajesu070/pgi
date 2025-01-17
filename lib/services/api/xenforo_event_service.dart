import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';


class XenforoEventService {
  final String baseUrl = dotenv.env['BASE_URL'] ?? 'https://pgi.org/api';
  final String apiKey = dotenv.env['CLIENT_ID'] ?? '7887150025286687';
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

   // Generic method to handle API responses
 Future<Map<String, dynamic>> _handleResponse(http.Response response) async {
    if (response.statusCode == 200) {
      if (response.body.isEmpty) {
        throw Exception('Empty response body received.');
      }
      // debugPrint('event info: ${response.body}');
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed with status code: ${response.statusCode}${response.body}');
    }
  }

 /// Get all events: GET /api/events 
  /// Fetches all events
  Future<Map<String, dynamic>> fetchEvents({int page = 1}) async {
    final url = Uri.parse('$baseUrl/events?page=$page');
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

  /// Get event details: GET /api/events/<event_id> 
  /// Fetches a specific event
  Future<Map<String, dynamic>> fetchEventById(int id) async {
    final url = Uri.parse('$baseUrl/events/$id/');
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

  /// RSVP to an event: POST /api/events/<event_id>/rsvp 
  /// RSVP to an event
  Future<Map<String, dynamic>> rsvpToEvent({
    required int eventId,
    required String rsvp,
  }) async {
    final url = Uri.parse('$baseUrl/events/$eventId/rsvp/');
    final accessToken = await _secureStorage.read(key: 'accessToken');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'XF-Api-Key': apiKey,
        if (accessToken != null) 'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode({'rsvp': rsvp}),
    );
    return await _handleResponse(response);
  }

  /// Get all categories: GET/api/events/categories
  /// Fetches all event categories
  Future<Map<String, dynamic>> fetchEventCategories() async {
    final url = Uri.parse('$baseUrl/events/categories/');
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

  /// Create a new event: POST /api/events
  /// Creates a new event
  /// Returns the newly created event
  
  Future<Map<String, dynamic>> createEvent({
    required String title,
    required String description,
    required String category,
    required String location,
    required String startDate,
    required String endDate,
  }) async {
    final url = Uri.parse('$baseUrl/events/');
    final accessToken = await _secureStorage.read(key: 'accessToken');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'XF-Api-Key': apiKey,
        if (accessToken != null) 'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode({
        'title': title,
        'description': description,
        'category': category,
        'location': location,
        'start_date': startDate,
        'end_date': endDate,
      }),
    );
    return await _handleResponse(response);
  }
  
  
  /// Delete RSVP: DELETE /api/events/<event_id>/rsvp
  /// Deletes an RSVP to an event
  /// Returns the deleted RSVP
  Future<Map<String, dynamic>> deleteRsvp(int eventId) async {
    final url = Uri.parse('$baseUrl/events/$eventId/rsvp/');
    final accessToken = await _secureStorage.read(key:'accessToken');

    final response = await http.delete(
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


// Create a new event: POST /api/events 
// Update an event: POST /api/events/<event_id> 
// Delete an event: DELETE /api/events/<event_id> 

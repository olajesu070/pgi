import 'dart:convert';
import 'package:flutter/services.dart';

class GeoJsonLoader {
  static Future<Map<String, dynamic>> loadGeoJson() async {
    final jsonString = await rootBundle.loadString('assets/map_data.geojson');
    return json.decode(jsonString);
  }
}

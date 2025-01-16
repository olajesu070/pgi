import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:pgi/services/api/xenforo_map_api.dart';
import 'package:pgi/view/widgets/custom_app_bar.dart';

const apiKey = "SpBinAbdDaWb5uNURKTM";
const styleUrl = "https://api.maptiler.com/maps/hybrid/style.json"; // Use a visible style

class EventMapScreen extends StatefulWidget {
  const EventMapScreen({super.key});

  @override
  _EventMapScreenState createState() => _EventMapScreenState();
}

class _EventMapScreenState extends State<EventMapScreen> {
  MapLibreMapController? _mapController;
  final MapService mapService = MapService();
  List<Map<String, dynamic>> geoJsonData = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
  }

  Future<void> _fetchMapCoordinates() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final data = await mapService.getMapCoordinate();
      final mapData = data['map'];
      if (mapData == null) {
        setState(() {
          geoJsonData = [];
          errorMessage = 'No map data available.';
          isLoading = false;
        });
        return;
      }

      final geoJson = mapData['geojson'];
      final features = geoJson != null ? geoJson['features'] : null;

      if (features == null || features.isEmpty) {
        setState(() {
          geoJsonData = [];
          errorMessage = 'No features available in map data.';
          isLoading = false;
        });
        return;
      }

      geoJsonData = List<Map<String, dynamic>>.from(features);
      for (var geoJson in geoJsonData) {
        _addGeoJsonToMap(geoJson);
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = '$e Failed to load data. Please try again later.';
        isLoading = false;
      });
    }
  }

  void _addGeoJsonToMap(Map<String, dynamic> feature) {
    if (_mapController == null) return;

    final geometry = feature['geometry'];
    if (geometry == null) return;

    final type = geometry['type'];
    final coordinates = geometry['coordinates'];

    if (type == null || coordinates == null) return;

    switch (type) {
      case 'Point':
        _addPointToMap(coordinates);
        break;
      case 'LineString':
        _addLineStringToMap(coordinates);
        break;
      case 'Polygon':
        _addPolygonToMap(coordinates);
        break;
    }
  }

  void _addPointToMap(List<dynamic> coordinates) {
    _mapController?.addSymbol(SymbolOptions(
      geometry: LatLng(coordinates[1], coordinates[0]),
      iconImage: 'default-marker',  // Replace with a working icon from your style
    ));
  }

  void _addLineStringToMap(List<dynamic> coordinates) {
    List<LatLng> latLngList = coordinates
        .map<LatLng>((coord) => LatLng(coord[1], coord[0]))
        .toList();
    _mapController?.addLine(LineOptions(
      geometry: latLngList,
      lineColor: "#FF0000", // Bright red for visibility
      lineWidth: 4.0,
      lineOpacity: 0.8,
    ));
  }

  void _addPolygonToMap(List<dynamic> coordinates) {
    List<LatLng> latLngList = coordinates[0]
        .map<LatLng>((coord) => LatLng(coord[1], coord[0]))
        .toList();
    _mapController?.addFill(FillOptions(
      geometry: [latLngList],
      fillColor: "#00FF00",  // Bright green for visibility
      fillOpacity: 0.5,
    ));
  }

  void _onMapCreated(MapLibreMapController controller) {
    _mapController = controller;
    _fetchMapCoordinates();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const CustomAppBarBody(
            title: 'Event Map',
          ),
          Expanded(
            child: Stack(
              children: [
                MapLibreMap(
                  styleString: "$styleUrl?key=$apiKey",
                  initialCameraPosition: const CameraPosition(
                    target: LatLng(46.42300325164794, -94.2815193249055),
                    zoom: 15.0,
                  ),
                  onMapCreated: _onMapCreated,
                ),
                if (isLoading)
                  const Center(
                    child: CircularProgressIndicator(),
                  ),
                if (errorMessage.isNotEmpty)
                  Center(
                    child: Text(
                      errorMessage,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

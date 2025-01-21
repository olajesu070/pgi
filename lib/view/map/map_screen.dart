import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:pgi/services/api/xenforo_map_api.dart';
import 'package:pgi/view/widgets/custom_app_bar.dart';
import 'package:pgi/view/widgets/map_widget.dart';

const apiKey = "SpBinAbdDaWb5uNURKTM";
const styleUrl = "https://api.maptiler.com/maps/hybrid/style.json";

class EventMapScreen extends StatefulWidget {
  const EventMapScreen({super.key});

  @override
  _EventMapScreenState createState() => _EventMapScreenState();
}

class _EventMapScreenState extends State<EventMapScreen> {
  MapLibreMapController? _mapController;
  final MapService mapService = MapService();
  List<Map<String, dynamic>> geoJsonData = [];
  Map<int, bool> categoryVisibility = {};
  Map<int, String> categoryColors = {};

  @override
  void initState() {
    super.initState();
    _fetchMapData();
  }

  Future<void> _fetchMapData() async {
    final data = await mapService.getMapCoordinate();
    final categories = data['map']['categories'] ?? [];
    final features = data['map']['geojson']['features'] ?? [];

    // Initialize category visibility and color map
    for (var category in categories) {
      int categoryId = category['category_id'];
      String color = "#${category['color']}";
      categoryVisibility[categoryId] = true;
      categoryColors[categoryId] = color;
    }

    geoJsonData = List<Map<String, dynamic>>.from(features);
    setState(() {});
  }

  void _toggleCategoryVisibility(int categoryId) {
    setState(() {
      categoryVisibility[categoryId] = !(categoryVisibility[categoryId] ?? true);
      _updateMapFeatures();
    });
  }

    void _updateMapFeatures() {
      if (_mapController == null) return; // Prevent null controller usage
      _mapController!.clearLines();
      _mapController!.clearSymbols();
      _mapController!.clearFills();
      
      for (var feature in geoJsonData) {
        int categoryId = feature['properties']['category_id'];
        if (categoryVisibility[categoryId] == true) {
          _addGeoJsonToMap(feature, categoryColors[categoryId] ?? "#FFFFFF");
        }
      }
    }

  void _addGeoJsonToMap(Map<String, dynamic> feature, String color) {
    final geometry = feature['geometry'];
    if (geometry == null) return;

    final type = geometry['type'];
    final coordinates = geometry['coordinates'];

    switch (type) {
      case 'Point':
        _addPointToMap(coordinates, color);
        break;
      case 'LineString':
        _addLineStringToMap(coordinates, color);
        break;
      case 'Polygon':
        _addPolygonToMap(coordinates, color);
        break;
    }
  }

  void _addPointToMap(List<dynamic> coordinates, String color) {
    _mapController?.addSymbol(SymbolOptions(
      geometry: LatLng(coordinates[1], coordinates[0]),
      iconImage: 'default-marker',
      iconColor: color,
    ));
  }

  void _addLineStringToMap(List<dynamic> coordinates, String color) {
    List<LatLng> latLngList = coordinates.map((coord) => LatLng(coord[1], coord[0])).toList();
    _mapController?.addLine(LineOptions(
      geometry: latLngList,
      lineColor: color,
      lineWidth: 4.0,
    ));
  }
  

  void _addPolygonToMap(List<dynamic> coordinates, String color) {
  if (coordinates.isEmpty || coordinates[0].isEmpty) return;
  
  List<LatLng> latLngList = coordinates[0]
      .map<LatLng>((coord) => LatLng(coord[1], coord[0]))
      .toList();

    // debugPrint('Print latlng: $latLngList');
  
  _mapController?.addFill(FillOptions(
    geometry: [latLngList],
    fillColor: color,
    fillOpacity: 0.5,
  ));
}

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Column(
        children: [
          CustomAppBarBody(title: 'Event Map', showBackButton: false,),
          Expanded(
            child: Stack(
              children: [
                  MapWidget()
                ],
            ),
          ),
        ],
      ),
    );
  }
}

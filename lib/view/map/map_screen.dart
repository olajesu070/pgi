import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:pgi/services/api/xenforo_map_api.dart';
import 'package:pgi/view/widgets/custom_app_bar.dart';
import 'package:pgi/services/api/oauth2_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

const apiKey = "SpBinAbdDaWb5uNURKTM";
const styleUrl = "https://api.maptiler.com/maps/hybrid/style.json";

class EventMapScreen extends StatefulWidget {
  const EventMapScreen({super.key});

  @override
  _EventMapScreenState createState() => _EventMapScreenState();
}

class _EventMapScreenState extends State<EventMapScreen> {
  MapLibreMapController? _mapController;
  late MapService mapService;
  final OAuth2Service oauth2Service = OAuth2Service(onTokensUpdated: _onTokensUpdated);

  List<Map<String, dynamic>> geoJsonData = [];
  Map<int, bool> categoryVisibility = {};
  Map<int, String> categoryColors = {};
  bool isLocationPermissionGranted = false;

  @override
  void initState() {
    super.initState();
    mapService = MapService(oauth2Service);
    _fetchMapData();
    _checkLocationPermission();
  }

  static void _onTokensUpdated() {
    debugPrint('Tokens have been refreshed');
  }

  Future<void> _checkLocationPermission() async {
    final status = await Permission.locationWhenInUse.request();
    setState(() {
      isLocationPermissionGranted = status.isGranted;
    });
  }

  Future<void> _fetchMapData() async {
    final data = await mapService.getMapCoordinate(context);
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
    if (_mapController == null) return;
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

    _mapController?.addFill(FillOptions(
      geometry: [latLngList],
      fillColor: color,
      fillOpacity: 0.5,
    ));
  }

  Future<void> _showCurrentLocation() async {
    if (!isLocationPermissionGranted) {
      debugPrint('Location permission not granted.');
      return;
    }

    final position = await Geolocator.getCurrentPosition();
    final LatLng userLocation = LatLng(position.latitude, position.longitude);

    _mapController?.addSymbol(SymbolOptions(
      geometry: userLocation,
      iconImage: 'default-marker',
      iconColor: "#FF0000",
    ));

    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(userLocation, 14.0),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const CustomAppBarBody(title: 'Event Map', showBackButton: false),
          Expanded(
            child: Stack(
              children: [
                MapLibreMap(
                   styleString: "$styleUrl?key=$apiKey",
                  onMapCreated: (controller) {
                    _mapController = controller;
                    _updateMapFeatures();
                  },
                  myLocationEnabled: true,
                  myLocationTrackingMode: MyLocationTrackingMode.tracking,
                  initialCameraPosition: const CameraPosition(
                    target: LatLng(0.0, 0.0),
                    zoom: 2.0,
                  ),
                ),
                Positioned(
                  bottom: 20,
                  right: 20,
                  child: FloatingActionButton(
                    onPressed: _showCurrentLocation,
                    backgroundColor: Colors.blue,
                    child: const Icon(Icons.my_location, color: Colors.white),
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

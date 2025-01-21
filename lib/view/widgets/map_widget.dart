import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:pgi/core/utils/color_mapper.dart';
import 'package:pgi/core/utils/geojson_loader.dart';

const apiKey = "SpBinAbdDaWb5uNURKTM";
const styleUrl = "https://api.maptiler.com/maps/hybrid/style.json";

class MapWidget extends StatefulWidget {
  const MapWidget({super.key});

  @override
  _MapWidgetState createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  late MapLibreMapController _controller;

  @override
  Widget build(BuildContext context) {
    return MapLibreMap(
      styleString: "$styleUrl?key=$apiKey",
      initialCameraPosition: const CameraPosition(target: LatLng(46.421, -94.281), zoom: 14),
      onMapCreated: (controller) {
        _controller = controller;
        _loadAndDisplayGeoJson();
      },
    );
  }

  Future<void> _loadAndDisplayGeoJson() async {
    final geoJson = await GeoJsonLoader.loadGeoJson();
    for (var feature in geoJson['features']) {
      final geometry = feature['geometry'];
      final properties = feature['properties'];
      final name = properties['name'];
      final categoryId = properties['category_id'];
      final color = getColorForCategory(categoryId);

      switch (geometry['type']) {
        case 'Point':
          final coordinates = geometry['coordinates'];
          _controller.addSymbol(SymbolOptions(
            geometry: LatLng(coordinates[1], coordinates[0]),
            textField: name,
            textColor: color.toString(),
          ));
          break;
        case 'LineString':
          final coordinates = geometry['coordinates'];
          final latLngs = coordinates.map((coord) => LatLng(coord[1], coord[0])).toList();
          _controller.addLine(LineOptions(
            geometry: latLngs,
            lineColor: color.toString(),
            lineWidth: 3.0,
          ));
          break;
        case 'Polygon':
          final coordinates = geometry['coordinates'][0];
          final latLngs = coordinates.map((coord) => LatLng(coord[1], coord[0])).toList();
          _controller.addFill(FillOptions(
            geometry: [latLngs],
            fillColor: color.toString(),
            fillOpacity: 0.5,
          ));
          break;
      }
    }
  }
}

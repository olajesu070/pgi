import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:pgi/data/models/event.dart';



class EventMapScreen extends StatefulWidget {
  final List<Event> events;

  const EventMapScreen({super.key, required this.events});

  @override
  _EventMapScreenState createState() => _EventMapScreenState();
}

class _EventMapScreenState extends State<EventMapScreen> {
  MapLibreMapController? mapController;
  Map<Symbol, Event> symbolEventMap = {}; // Map to link each Symbol to an Event

  void _onMapCreated(MapLibreMapController controller) {
    mapController = controller;
    _addEventMarkers();
  }

  void _addEventMarkers() {
    for (var event in widget.events) {
      mapController?.addSymbol(
        SymbolOptions(
          geometry: LatLng(event.latitude, event.longitude),
          iconImage: "marker-15", // Use custom marker image if available
          iconSize: 1.5,
        ),
      ).then((symbol) {
        // Store the symbol and event association
        symbolEventMap[symbol] = event;
            });
    }
  }

  void _onSymbolTapped(Symbol symbol) {
    // Retrieve the associated event using the symbol as the key
    final event = symbolEventMap[symbol];
    if (event != null) {
      _showEventDetailsBottomSheet(event);
    }
  }

  void _showEventDetailsBottomSheet(Event event) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(event.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(event.description, style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Close'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Locations'),
      ),
      body: MapLibreMap(
        styleString: "https://demotiles.maplibre.org/style.json", // Replace with your preferred style
        onMapCreated: _onMapCreated,
        onStyleLoadedCallback: () {
          mapController?.onSymbolTapped.add(_onSymbolTapped);
        },
        initialCameraPosition: CameraPosition(
          target: LatLng(widget.events.first.latitude, widget.events.first.longitude),
          zoom: 10.0,
        ),
      ),
    );
  }

  @override
  void dispose() {
    mapController?.onSymbolTapped.remove(_onSymbolTapped);
    mapController?.dispose();
    super.dispose();
  }
}

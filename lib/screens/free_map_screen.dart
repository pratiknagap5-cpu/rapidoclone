import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class FreeMapScreen extends StatefulWidget {
  const FreeMapScreen({super.key});

  @override
  State<FreeMapScreen> createState() => _FreeMapScreenState();
}

class _FreeMapScreenState extends State<FreeMapScreen> {
  int _currentStyleIndex = 0;

  final List<Map<String, String>> _tileStyles = [
    {
      'name': 'Default (Alidade Smooth)',
      'url': 'https://tiles.stadiamaps.com/tiles/alidade_smooth/{z}/{x}/{y}.png',
    },
    {
      'name': 'Dark Style',
      'url': 'https://tiles.stadiamaps.com/tiles/alidade_smooth_dark/{z}/{x}/{y}.png',
    },
    {
      'name': 'Outdoor Style',
      'url': 'https://tiles.stadiamaps.com/tiles/outdoors/{z}/{x}/{y}.png',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Free Map - Stadia Tiles'),
        backgroundColor: const Color(0xFF00C851),
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<int>(
            onSelected: (index) {
              setState(() {
                _currentStyleIndex = index;
              });
            },
            itemBuilder: (context) => _tileStyles.asMap().entries.map((entry) {
              return PopupMenuItem(
                value: entry.key,
                child: Text(entry.value['name']!),
              );
            }).toList(),
            child: const Icon(Icons.layers),
          ),
        ],
      ),
      body: FlutterMap(
        options: const MapOptions(
          initialCenter: LatLng(19.0760, 72.8777), // Mumbai
          initialZoom: 13.0,
        ),
        children: [
          TileLayer(
            urlTemplate: _tileStyles[_currentStyleIndex]['url']!,
            userAgentPackageName: 'com.rapidoapp.app',
          ),
          const MarkerLayer(
            markers: [
              Marker(
                point: LatLng(19.0760, 72.8777),
                width: 80,
                height: 80,
                child: Icon(
                  Icons.location_pin,
                  color: Colors.red,
                  size: 40,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

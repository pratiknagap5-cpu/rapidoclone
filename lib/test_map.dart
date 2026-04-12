import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class SimpleMapTest extends StatelessWidget {
  const SimpleMapTest({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Free Map Test')),
      body: FlutterMap(
        options: const MapOptions(
          initialCenter: LatLng(19.0760, 72.8777), // Mumbai
          initialZoom: 13.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.rapido.app',
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: const LatLng(19.0760, 72.8777),
                width: 80,
                height: 80,
                child: const Icon(
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

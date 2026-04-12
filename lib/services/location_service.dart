import 'dart:math';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/location_model.dart';

class LocationService {
  /// Get current GPS position with permission handling
  static Future<LocationModel?> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return null;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Reverse geocode the position
      String address = await getAddressFromCoordinates(
        position.latitude,
        position.longitude,
      );

      return LocationModel(
        latitude: position.latitude,
        longitude: position.longitude,
        address: address,
      );
    } catch (e) {
      print('Error getting location: $e');
      return null;
    }
  }

  /// Stream live location updates
  static Stream<Position> getLocationStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    );
  }

  /// Reverse geocode coordinates to readable address via Nominatim
  static Future<String> getAddressFromCoordinates(double lat, double lng) async {
    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lng&zoom=18&addressdetails=1',
      );

      final response = await http.get(url, headers: {
        'User-Agent': 'RapidoApp/1.0',
        'Accept-Language': 'en',
      }).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final address = data['address'];

        // Build a concise readable address
        List<String> parts = [];

        if (address['road'] != null) parts.add(address['road']);
        if (address['neighbourhood'] != null) parts.add(address['neighbourhood']);
        if (address['suburb'] != null) parts.add(address['suburb']);
        if (address['city'] != null) {
          parts.add(address['city']);
        } else if (address['town'] != null) {
          parts.add(address['town']);
        } else if (address['village'] != null) {
          parts.add(address['village']);
        }

        if (parts.isNotEmpty) {
          return parts.take(3).join(', ');
        }

        // Fallback to display_name
        final displayName = data['display_name'] as String?;
        if (displayName != null) {
          final shortParts = displayName.split(',').take(3);
          return shortParts.join(',').trim();
        }
      }
    } catch (e) {
      print('Geocoding error: $e');
    }

    return 'Lat: ${lat.toStringAsFixed(4)}, Lng: ${lng.toStringAsFixed(4)}';
  }

  /// Search places using Nominatim
  static Future<List<LocationModel>> searchPlaces(String query) async {
    if (query.trim().isEmpty) return [];

    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?format=json&q=${Uri.encodeComponent(query)}&countrycodes=in&limit=8&addressdetails=1',
      );

      final response = await http.get(url, headers: {
        'User-Agent': 'RapidoApp/1.0',
        'Accept-Language': 'en',
      }).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((place) {
          final displayName = place['display_name'] as String;
          // Shorten display name to 3 parts
          final shortName = displayName.split(',').take(3).join(',').trim();

          return LocationModel(
            latitude: double.parse(place['lat']),
            longitude: double.parse(place['lon']),
            address: shortName,
          );
        }).toList();
      }
    } catch (e) {
      print('Place search error: $e');
    }

    return [];
  }

  /// Get nearby popular places (static fallback data + distance calculation)
  static List<Map<String, dynamic>> getNearbyPlaces(double lat, double lng) {
    final places = [
      {'name': 'Railway Station', 'lat': lat + 0.015, 'lng': lng + 0.008, 'type': 'Station', 'icon': '🚉'},
      {'name': 'City Mall', 'lat': lat - 0.012, 'lng': lng + 0.006, 'type': 'Mall', 'icon': '🛍️'},
      {'name': 'Central Hospital', 'lat': lat + 0.008, 'lng': lng - 0.01, 'type': 'Hospital', 'icon': '🏥'},
      {'name': 'Airport', 'lat': lat + 0.045, 'lng': lng + 0.03, 'type': 'Airport', 'icon': '✈️'},
      {'name': 'Bus Terminal', 'lat': lat - 0.02, 'lng': lng - 0.015, 'type': 'Bus Stop', 'icon': '🚌'},
      {'name': 'Tech Park', 'lat': lat + 0.025, 'lng': lng - 0.02, 'type': 'Office', 'icon': '🏢'},
    ];

    return places.map((place) {
      final distance = calculateDistance(
        lat, lng,
        place['lat'] as double,
        place['lng'] as double,
      );
      return {
        ...place,
        'distance': distance,
      };
    }).toList()
      ..sort((a, b) => (a['distance'] as double).compareTo(b['distance'] as double));
  }

  /// Haversine formula for distance in km
  static double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double R = 6371;
    double dLat = _toRadians(lat2 - lat1);
    double dLon = _toRadians(lon2 - lon1);
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) * cos(_toRadians(lat2)) *
        sin(dLon / 2) * sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  static double _toRadians(double degree) {
    return degree * pi / 180;
  }
}

import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'dart:convert';
import 'dart:math';

class RoutingService {
  /// Get route polyline points from OSRM (free, no API key)
  static Future<List<LatLng>> getRoute(LatLng start, LatLng end) async {
    try {
      final url = Uri.parse(
        'https://router.project-osrm.org/route/v1/driving/'
        '${start.longitude},${start.latitude};'
        '${end.longitude},${end.latitude}'
        '?overview=full&geometries=geojson',
      );

      final response = await http.get(url, headers: {
        'User-Agent': 'RapidoApp/1.0',
      }).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final routes = data['routes'] as List;
        if (routes.isNotEmpty) {
          final geometry = routes[0]['geometry'];
          final coordinates = geometry['coordinates'] as List;

          return coordinates.map<LatLng>((coord) {
            return LatLng(
              (coord[1] as num).toDouble(),
              (coord[0] as num).toDouble(),
            );
          }).toList();
        }
      }
    } catch (e) {
      print('OSRM routing error: $e');
    }

    // Fallback: generate interpolated straight line
    return _generateFallbackRoute(start, end);
  }

  /// Get route distance and duration from OSRM
  static Future<Map<String, double>> getRouteInfo(LatLng start, LatLng end) async {
    try {
      final url = Uri.parse(
        'https://router.project-osrm.org/route/v1/driving/'
        '${start.longitude},${start.latitude};'
        '${end.longitude},${end.latitude}'
        '?overview=false',
      );

      final response = await http.get(url, headers: {
        'User-Agent': 'RapidoApp/1.0',
      }).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final routes = data['routes'] as List;
        if (routes.isNotEmpty) {
          final route = routes[0];
          return {
            'distance': (route['distance'] as num).toDouble() / 1000, // meters to km
            'duration': (route['duration'] as num).toDouble() / 60, // seconds to minutes
          };
        }
      }
    } catch (e) {
      print('OSRM route info error: $e');
    }

    // Fallback to straight-line calculation
    final distance = _haversineDistance(start, end);
    return {
      'distance': distance,
      'duration': distance * 3, // rough estimate: 3 min per km
    };
  }

  /// Generate a smooth fallback route with intermediate points
  static List<LatLng> _generateFallbackRoute(LatLng start, LatLng end) {
    const int numPoints = 20;
    List<LatLng> points = [];

    for (int i = 0; i <= numPoints; i++) {
      final t = i / numPoints;
      // Add slight curve for more realistic path
      final midOffset = sin(t * pi) * 0.002;
      points.add(LatLng(
        start.latitude + (end.latitude - start.latitude) * t + midOffset,
        start.longitude + (end.longitude - start.longitude) * t,
      ));
    }

    return points;
  }

  static double _haversineDistance(LatLng start, LatLng end) {
    const double R = 6371;
    double dLat = _toRadians(end.latitude - start.latitude);
    double dLon = _toRadians(end.longitude - start.longitude);
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(start.latitude)) * cos(_toRadians(end.latitude)) *
        sin(dLon / 2) * sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  static double _toRadians(double degree) {
    return degree * pi / 180;
  }
}

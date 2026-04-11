import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import '../core/constants.dart';

class RouteResult {
  final List<LatLng> coords;
  final String dist; // km
  final String dur; // minutes

  const RouteResult({
    required this.coords,
    required this.dist,
    required this.dur,
  });
}

class RoutingService {
  static Future<RouteResult> fetchRoute(
    double fLat,
    double fLng,
    double tLat,
    double tLng,
  ) async {
    // Try Mapbox Directions API first
    try {
      final url =
          'https://api.mapbox.com/directions/v5/mapbox/driving/$fLng,$fLat;$tLng,$tLat'
          '?overview=full&geometries=geojson'
          '&access_token=$mapboxToken';
      debugPrint('🗺️ Mapbox URL: $url');
      final r = await http.get(Uri.parse(url));
      debugPrint('🗺️ Mapbox status: ${r.statusCode}');
      final d = jsonDecode(r.body) as Map<String, dynamic>;
      final route = (d['routes'] as List?)?.first;
      if (route != null) {
        final coords = (route['geometry']['coordinates'] as List)
            .map(
              (c) => LatLng((c[1] as num).toDouble(), (c[0] as num).toDouble()),
            )
            .toList();
        final dist = ((route['distance'] as num) / 1000).toStringAsFixed(1);
        final dur = ((route['duration'] as num) / 60).round().toString();
        debugPrint(
          '🗺️ Mapbox route: ${coords.length} points, $dist km, $dur min',
        );
        return RouteResult(coords: coords, dist: dist, dur: dur);
      } else {
        debugPrint('🗺️ Mapbox: No route found in response');
      }
    } catch (e) {
      debugPrint('🗺️ Mapbox routing error: $e');
    }

    // Fallback to OSRM (still street-level routing)
    try {
      final url =
          '$osrmBase/$fLng,$fLat;$tLng,$tLat?overview=full&geometries=geojson';
      debugPrint('🗺️ OSRM URL: $url');
      final r = await http.get(Uri.parse(url));
      debugPrint('🗺️ OSRM status: ${r.statusCode}');
      final d = jsonDecode(r.body) as Map<String, dynamic>;
      final route = (d['routes'] as List?)?.first;
      if (route != null) {
        final coords = (route['geometry']['coordinates'] as List)
            .map(
              (c) => LatLng((c[1] as num).toDouble(), (c[0] as num).toDouble()),
            )
            .toList();
        final dist = ((route['distance'] as num) / 1000).toStringAsFixed(1);
        final dur = ((route['duration'] as num) / 60).round().toString();
        debugPrint(
          '🗺️ OSRM route: ${coords.length} points, $dist km, $dur min',
        );
        return RouteResult(coords: coords, dist: dist, dur: dur);
      }
    } catch (e) {
      debugPrint('🗺️ OSRM routing error: $e');
    }

    // If both fail, throw error - no straight line fallback
    throw Exception('Failed to fetch route from both Mapbox and OSRM');
  }

  static Future<String> reverseGeo(double lat, double lng) async {
    try {
      final url = '$nominatimBase?lat=$lat&lon=$lng&format=json';
      final r = await http.get(
        Uri.parse(url),
        headers: {'User-Agent': 'WashGoApp/1.0'},
      );
      final d = jsonDecode(r.body) as Map<String, dynamic>;
      final name = d['display_name'] as String?;
      if (name != null) {
        return name.split(',').take(2).join(', ');
      }
    } catch (_) {}
    return '${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}';
  }
}

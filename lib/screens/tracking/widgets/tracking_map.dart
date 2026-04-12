import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/constants.dart';
import '../../../widgets/map_widget.dart';

final Distance distance = const Distance();

class TrackingMap extends StatelessWidget {
  final LatLng userPos;
  final LatLng driverPos;
  final List<LatLng> routeCoords;
  final double driverRotation;

  const TrackingMap({
    super.key,
    required this.userPos,
    required this.driverPos,
    required this.routeCoords,
    this.driverRotation = 0,
  });

  @override
  Widget build(BuildContext context) {
    // Filter route coordinates to show only from driver position to destination
    // Find the closest point to driver position in the route
    int driverIndex = 0;
    double minDistance = double.infinity;
    for (int i = 0; i < routeCoords.length; i++) {
      final dist = _haversine(
        driverPos.latitude,
        driverPos.longitude,
        routeCoords[i].latitude,
        routeCoords[i].longitude,
      );
      if (dist < minDistance) {
        minDistance = dist;
        driverIndex = i;
      }
    }

    // Only show coordinates from driver position onwards
    final remainingRoute = routeCoords.sublist(driverIndex);

    return FlutterMap(
      options: MapOptions(
        initialCenter: userPos,
        initialZoom: 14,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.washgo.app',
        ),
        PolylineLayer(
          polylines: [
            Polyline(points: remainingRoute, strokeWidth: 4, color: kCyan),
          ],
        ),
        MarkerLayer(
          markers: [userMarker(userPos), carMarker(driverPos, driverRotation)],
        ),
      ],
    );
  }

  double _haversine(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371000; // Earth radius in meters
    final dLat = (lat2 - lat1) * (math.pi / 180);
    final dLon = (lon2 - lon1) * (math.pi / 180);
    final a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1 * (math.pi / 180)) *
            math.cos(lat2 * (math.pi / 180)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.asin(math.sqrt(a));
    return R * c;
  }
}

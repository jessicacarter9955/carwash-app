import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/constants.dart';
import '../../../widgets/map_widget.dart';

class TrackingMap extends StatelessWidget {
  final LatLng userPos;
  final LatLng driverPos;
  final List<LatLng> routeCoords;

  const TrackingMap({
    super.key,
    required this.userPos,
    required this.driverPos,
    required this.routeCoords,
  });

  @override
  Widget build(BuildContext context) {
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
          urlTemplate:
              'https://api.mapbox.com/styles/v1/mapbox/streets-v12/tiles/{z}/{x}/{y}?access_token=$mapboxToken',
          userAgentPackageName: 'com.washgo.app',
        ),
        PolylineLayer(
          polylines: [
            Polyline(points: routeCoords, strokeWidth: 4, color: kCyan),
          ],
        ),
        MarkerLayer(markers: [userMarker(userPos), carMarker(driverPos)]),
      ],
    );
  }
}

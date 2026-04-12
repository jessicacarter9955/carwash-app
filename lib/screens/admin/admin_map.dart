import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/constants.dart';
import '../../../widgets/map_widget.dart';

class AdminMap extends StatelessWidget {
  final List<LatLng> driverPositions;
  final List<LatLng> orderLocations;

  const AdminMap({
    super.key,
    this.driverPositions = const [],
    this.orderLocations = const [],
  });

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: MapOptions(
        initialCenter: const LatLng(kDefaultLat, kDefaultLng),
        initialZoom: 12,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all,
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.washgo.app',
        ),
        MarkerLayer(
          markers: [
            ...driverPositions.map((pos) => carMarker(pos)),
            ...orderLocations.map((pos) => destMarker(pos)),
          ],
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../core/constants.dart';

class WashGoMap extends StatelessWidget {
  final LatLng center;
  final double zoom;
  final List<Marker> markers;
  final List<Polyline> polylines;
  final bool interactive;
  final MapController? controller;

  const WashGoMap({
    super.key,
    required this.center,
    this.zoom = 14,
    this.markers = const [],
    this.polylines = const [],
    this.interactive = true,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final useOSM = mapboxToken.isEmpty;
    return FlutterMap(
      mapController: controller,
      options: MapOptions(
        initialCenter: center,
        initialZoom: zoom,
        interactionOptions: InteractionOptions(
          flags: interactive ? InteractiveFlag.all : InteractiveFlag.none,
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: useOSM
              ? 'https://tile.openstreetmap.org/{z}/{x}/{y}.png'
              : 'https://api.mapbox.com/styles/v1/mapbox/streets-v12/tiles/256/{z}/{x}/{y}@2x?access_token={accessToken}',
          additionalOptions: useOSM ? {} : {'accessToken': mapboxToken},
          userAgentPackageName: 'com.washgo.app',
        ),
        if (polylines.isNotEmpty) PolylineLayer(polylines: polylines),
        if (markers.isNotEmpty) MarkerLayer(markers: markers),
      ],
    );
  }
}

// ── Marker builders ───────────────────────────────────────────
Marker userMarker(LatLng pos) => Marker(
      point: pos,
      width: 32,
      height: 32,
      child: _CircleMarker(bg: kMint, icon: Icons.person, size: 14),
    );

Marker carMarker(LatLng pos, [double rotation = 0]) => Marker(
      point: pos,
      width: 38,
      height: 38,
      child: Transform.rotate(
        angle: rotation * 3.14159 / 180,
        child: _CircleMarker(bg: kCyan, icon: Icons.directions_car, size: 18),
      ),
    );

Marker destMarker(LatLng pos) => Marker(
      point: pos,
      width: 32,
      height: 32,
      child: _CircleMarker(bg: kRed, icon: Icons.location_on, size: 14),
    );

Marker hubMarker(LatLng pos) => Marker(
      point: pos,
      width: 36,
      height: 36,
      child: _CircleMarker(bg: kOrange, icon: Icons.local_car_wash, size: 16),
    );

class _CircleMarker extends StatelessWidget {
  final Color bg;
  final IconData icon;
  final double size;

  const _CircleMarker({
    required this.bg,
    required this.icon,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2.5),
        boxShadow: [
          BoxShadow(
            color: bg.withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Icon(icon, size: size, color: Colors.white),
      ),
    );
  }
}

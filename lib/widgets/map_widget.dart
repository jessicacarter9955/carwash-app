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
          urlTemplate:
              'https://api.mapbox.com/styles/v1/mapbox/streets-v12/tiles/{z}/{x}/{y}?access_token=$mapboxToken',
          userAgentPackageName: 'com.washgo.app',
        ),
        if (polylines.isNotEmpty) PolylineLayer(polylines: polylines),
        if (markers.isNotEmpty) MarkerLayer(markers: markers),
      ],
    );
  }
}

// ── Helper marker builders ─────────────────────────────
Marker userMarker(LatLng pos) => Marker(
  point: pos,
  width: 26,
  height: 26,
  child: _CircleMarker(bg: kMint, icon: Icons.person, size: 12),
);

Marker carMarker(LatLng pos, [double rotation = 0]) => Marker(
  point: pos,
  width: 34,
  height: 34,
  child: RotatedBox(
    quarterTurns: (rotation / 90).round(),
    child: _CircleMarker(bg: kCyan3, icon: Icons.directions_car, size: 16),
  ),
);

Marker destMarker(LatLng pos) => Marker(
  point: pos,
  width: 26,
  height: 26,
  child: _CircleMarker(bg: kRed, icon: Icons.location_on, size: 12),
);

Marker hubMarker(LatLng pos) => Marker(
  point: pos,
  width: 28,
  height: 28,
  child: _CircleMarker(bg: kOrange, icon: Icons.local_shipping, size: 14),
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
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: bg.withOpacity(.4),
            blurRadius: 8,
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

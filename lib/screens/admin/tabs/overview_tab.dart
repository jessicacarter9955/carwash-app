import 'package:flutter/material.dart';
import '../../../core/constants.dart';
import '../../../widgets/map_widget.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class OverviewTab extends StatelessWidget {
  const OverviewTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _AdminCard(
            title: '🗺 Live Fleet',
            badge: '0 online',
            badgeColor: kMint2,
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: SizedBox(
                    height: 240,
                    child: WashGoMap(
                      center: const LatLng(romeLat, romeLng),
                      zoom: 13,
                      interactive: true,
                      markers: [
                        hubMarker(const LatLng(41.9024, 12.5143)),
                        carMarker(const LatLng(romeLat + .01, romeLng - .005)),
                        carMarker(const LatLng(romeLat - .008, romeLng + .01)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _LegendDot(color: kMint2, label: 'Available'),
                    _LegendDot(color: kOrange, label: 'On trip'),
                    _LegendDot(color: kCyan3, label: 'At hub'),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _AdminCard(
            title: '📋 Recent Orders',
            badge: '0 active',
            badgeColor: kOrange,
            child: const Center(
              child: Text(
                'No recent orders',
                style: TextStyle(color: kMuted, fontSize: 13),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _AdminCard extends StatelessWidget {
  final String title, badge;
  final Color badgeColor;
  final Widget child;
  const _AdminCard({
    required this.title,
    required this.badge,
    required this.badgeColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: kBg,
        border: Border.all(color: kBorder),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontFamily: kFontHead,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: badgeColor.withOpacity(.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    fontFamily: kFontHead,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: badgeColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

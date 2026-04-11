import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../core/constants.dart';

class LocationState {
  final double lat;
  final double lng;
  final String address;
  final bool loading;

  const LocationState({
    this.lat = kDefaultLat,
    this.lng = kDefaultLng,
    this.address = 'Detecting location...',
    this.loading = true,
  });

  LocationState copyWith(
          {double? lat, double? lng, String? address, bool? loading}) =>
      LocationState(
        lat: lat ?? this.lat,
        lng: lng ?? this.lng,
        address: address ?? this.address,
        loading: loading ?? this.loading,
      );
}

class LocationNotifier extends StateNotifier<LocationState> {
  LocationNotifier() : super(const LocationState()) {
    _init();
  }

  Future<void> _init() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        state = state.copyWith(
            loading: false, address: 'Location service disabled');
        return;
      }
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
        if (perm == LocationPermission.denied) {
          state = state.copyWith(
              loading: false, address: 'Location permission denied');
          return;
        }
      }
      if (perm == LocationPermission.deniedForever) {
        state = state.copyWith(
            loading: false, address: 'Location permission denied forever');
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final addr = await _reverseGeo(pos.latitude, pos.longitude);
      state = state.copyWith(
          lat: pos.latitude, lng: pos.longitude, address: addr, loading: false);
    } catch (e) {
      state = state.copyWith(loading: false, address: 'Location unavailable');
    }
  }

  Future<String> _reverseGeo(double lat, double lng) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        return '${p.street ?? ''}, ${p.locality ?? ''}'
            .trim()
            .replaceAll(RegExp(r'^,\s*'), '');
      }
    } catch (_) {}
    return '${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}';
  }

  Future<void> refresh() => _init();

  void updateAddress(String address) {
    state = state.copyWith(address: address, loading: false);
  }

  Future<void> geocodeAddress(String address) async {
    state = state.copyWith(loading: true);
    try {
      final locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        final loc = locations.first;
        state = state.copyWith(
          lat: loc.latitude,
          lng: loc.longitude,
          address: address,
          loading: false,
        );
      } else {
        state = state.copyWith(
          address: address,
          loading: false,
        );
      }
    } catch (e) {
      // If geocoding fails, just update the address
      state = state.copyWith(
        address: address,
        loading: false,
      );
    }
  }
}

final locationProvider = StateNotifierProvider<LocationNotifier, LocationState>(
  (_) => LocationNotifier(),
);

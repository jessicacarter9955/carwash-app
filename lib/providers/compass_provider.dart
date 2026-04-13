import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_compass/flutter_compass.dart';

class CompassState {
  final double heading; // 0-360 degrees
  final bool hasPermission;

  const CompassState({
    this.heading = 0.0,
    this.hasPermission = true,
  });

  CompassState copyWith({
    double? heading,
    bool? hasPermission,
  }) =>
      CompassState(
        heading: heading ?? this.heading,
        hasPermission: hasPermission ?? this.hasPermission,
      );
}

class CompassNotifier extends StateNotifier<CompassState> {
  CompassNotifier() : super(const CompassState()) {
    _init();
  }

  void _init() {
    FlutterCompass.events?.listen((event) {
      if (event.heading != null) {
        state = state.copyWith(heading: event.heading!);
      }
    });
  }
}

final compassProvider = StateNotifierProvider<CompassNotifier, CompassState>(
  (_) => CompassNotifier(),
);

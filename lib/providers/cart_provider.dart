import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/cart_item_model.dart';
import 'pricing_provider.dart';

class CartState {
  final Map<String, int> quantities;
  final List<CartItemDefinition> items;
  final String selectedService; // standard, express, dryclean
  final double serviceExtra;
  final Set<String> addons; // fold, scent
  final double addonExtra;
  final String selectedTime;
  final String selectedPaymentMethod;
  // Vehicle selection for car wash
  final String? selectedVehicleId;
  final String? selectedVehicleMake;
  final String? selectedVehicleModel;
  final String? selectedVehicleYear;
  final String? selectedVehicleColor;
  final String? selectedLicensePlate;

  const CartState({
    this.quantities = const {},
    this.items = const [],
    this.selectedService = 'standard',
    this.serviceExtra = 0,
    this.addons = const {},
    this.addonExtra = 0,
    this.selectedTime = 'ASAP ~30min',
    this.selectedPaymentMethod = 'card',
    this.selectedVehicleId,
    this.selectedVehicleMake,
    this.selectedVehicleModel,
    this.selectedVehicleYear,
    this.selectedVehicleColor,
    this.selectedLicensePlate,
  });

  double get itemsTotal => items.fold(0, (sum, item) {
    final qty = quantities[item.key] ?? 0;
    return sum + item.price * qty;
  });

  double get total => itemsTotal + serviceExtra + addonExtra + 2.99;

  bool get hasItems => itemsTotal > 0;

  Map<String, dynamic> get itemsMap {
    final m = <String, dynamic>{};
    for (final item in items) {
      final qty = quantities[item.key] ?? 0;
      if (qty > 0) {
        m[item.key] = {'name': item.name, 'qty': qty, 'price': item.price};
      }
    }
    return m;
  }

  CartState copyWith({
    Map<String, int>? quantities,
    List<CartItemDefinition>? items,
    String? selectedService,
    double? serviceExtra,
    Set<String>? addons,
    double? addonExtra,
    String? selectedTime,
    String? selectedPaymentMethod,
    String? selectedVehicleId,
    String? selectedVehicleMake,
    String? selectedVehicleModel,
    String? selectedVehicleYear,
    String? selectedVehicleColor,
    String? selectedLicensePlate,
  }) => CartState(
    quantities: quantities ?? this.quantities,
    items: items ?? this.items,
    selectedService: selectedService ?? this.selectedService,
    serviceExtra: serviceExtra ?? this.serviceExtra,
    addons: addons ?? this.addons,
    addonExtra: addonExtra ?? this.addonExtra,
    selectedTime: selectedTime ?? this.selectedTime,
    selectedPaymentMethod: selectedPaymentMethod ?? this.selectedPaymentMethod,
    selectedVehicleId: selectedVehicleId ?? this.selectedVehicleId,
    selectedVehicleMake: selectedVehicleMake ?? this.selectedVehicleMake,
    selectedVehicleModel: selectedVehicleModel ?? this.selectedVehicleModel,
    selectedVehicleYear: selectedVehicleYear ?? this.selectedVehicleYear,
    selectedVehicleColor: selectedVehicleColor ?? this.selectedVehicleColor,
    selectedLicensePlate: selectedLicensePlate ?? this.selectedLicensePlate,
  );
}

class CartNotifier extends StateNotifier<CartState> {
  CartNotifier() : super(const CartState()) {
    _initItems();
  }

  void _initItems() {
    final items = List<CartItemDefinition>.from(defaultItems);
    state = state.copyWith(
      items: items,
      quantities: {for (var i in items) i.key: 0},
    );
  }

  void updatePricing(List pricing) {
    final items = List<CartItemDefinition>.from(state.items);
    for (final p in pricing) {
      final idx = items.indexWhere((i) => i.key == p.itemKey);
      if (idx != -1) {
        items[idx] = CartItemDefinition(
          key: p.itemKey,
          name: p.itemName,
          icon: items[idx].icon,
          price: p.price,
        );
      }
    }
    state = state.copyWith(items: items);
  }

  void changeQty(String key, int delta) {
    final qty = state.quantities;
    final newQty = Map<String, int>.from(qty);
    newQty[key] = (newQty[key] ?? 0) + delta;
    if (newQty[key]! < 0) newQty[key] = 0;
    state = state.copyWith(quantities: newQty);
  }

  void selectService(String type) {
    const prices = {'standard': 0.0, 'express': 4.9, 'premium': 7.5};
    state = state.copyWith(
      selectedService: type,
      serviceExtra: prices[type] ?? 0,
    );
  }

  void toggleAddon(String key) {
    const prices = {'fold': 2.0, 'scent': 1.5};
    final addons = Set<String>.from(state.addons);
    if (addons.contains(key)) {
      addons.remove(key);
    } else {
      addons.add(key);
    }
    final addonExtra = addons.fold(0.0, (s, k) => s + (prices[k] ?? 0));
    state = state.copyWith(addons: addons, addonExtra: addonExtra);
  }

  void selectTime(String time) => state = state.copyWith(selectedTime: time);
  void selectPayment(String method) =>
      state = state.copyWith(selectedPaymentMethod: method);

  void selectVehicle({
    required String id,
    required String make,
    required String model,
    required String year,
    required String color,
    required String licensePlate,
  }) {
    state = state.copyWith(
      selectedVehicleId: id,
      selectedVehicleMake: make,
      selectedVehicleModel: model,
      selectedVehicleYear: year,
      selectedVehicleColor: color,
      selectedLicensePlate: licensePlate,
    );
  }

  void reset() {
    _initItems();
    state = state.copyWith(
      selectedService: 'standard',
      serviceExtra: 0,
      addons: {},
      addonExtra: 0,
      selectedTime: 'ASAP ~30min',
      selectedPaymentMethod: 'card',
      selectedVehicleId: null,
      selectedVehicleMake: null,
      selectedVehicleModel: null,
      selectedVehicleYear: null,
      selectedVehicleColor: null,
      selectedLicensePlate: null,
    );
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, CartState>(
  (_) => CartNotifier(),
);

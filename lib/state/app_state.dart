import 'package:flutter/foundation.dart';
import '../models/user_profile.dart';
import '../models/order.dart';

// ── Item model ───────────────────────────────────────
class LaundryItem {
  final String key;
  final String name;
  final String emoji;
  double price;
  int qty;

  LaundryItem({
    required this.key,
    required this.name,
    required this.emoji,
    required this.price,
    this.qty = 0,
  });
}

// ── Currency ─────────────────────────────────────────
enum Currency { usd, eur }

extension CurrencyExt on Currency {
  String get symbol => this == Currency.usd ? '\$' : '€';
  double get rate => this == Currency.usd ? 1.0 : 0.92;
  String get label => this == Currency.usd ? 'USD' : 'EUR';
}

// ── Service type ──────────────────────────────────────
enum ServiceType { standard, express, dryclean }

extension ServiceExt on ServiceType {
  String get label => ['Standard', 'Express', 'Dry Clean'][index];
  double get extra => [0.0, 4.9, 7.5][index];
}

// ── Payment method ────────────────────────────────────
enum PaymentMethod { card, apple, cash }

// ── Addon ─────────────────────────────────────────────
class Addon {
  final String key;
  final String name;
  final double price;
  bool selected;

  Addon({
    required this.key,
    required this.name,
    required this.price,
    this.selected = false,
  });
}

// ── App State ─────────────────────────────────────────
class AppState extends ChangeNotifier {
  // Auth
  UserProfile? currentProfile;
  String? currentUserId;
  String? currentUserEmail;

  // Role
  String currentRole = 'customer'; // customer | driver | admin

  // Location
  double userLat = 41.8988;
  double userLng = 12.4768;
  String userAddress = '';

  // Currency
  Currency currency = Currency.usd;

  // Items
  final Map<String, LaundryItem> items = {
    'shirts': LaundryItem(
      key: 'shirts',
      name: 'Shirts / T-shirts',
      emoji: '👕',
      price: 2.50,
    ),
    'pants': LaundryItem(
      key: 'pants',
      name: 'Pants / Jeans',
      emoji: '👖',
      price: 3.50,
    ),
    'dress': LaundryItem(
      key: 'dress',
      name: 'Dresses',
      emoji: '👗',
      price: 5.00,
    ),
    'jacket': LaundryItem(
      key: 'jacket',
      name: 'Jackets / Coats',
      emoji: '🧥',
      price: 8.00,
    ),
    'sheets': LaundryItem(
      key: 'sheets',
      name: 'Bed Sheets',
      emoji: '🛏',
      price: 6.00,
    ),
    'towels': LaundryItem(
      key: 'towels',
      name: 'Towels',
      emoji: '🏊',
      price: 2.00,
    ),
  };

  // Addons
  final Map<String, Addon> addons = {
    'fold': Addon(key: 'fold', name: 'Folding & Packaging', price: 2.0),
    'scent': Addon(key: 'scent', name: 'Premium Scent', price: 1.5),
  };

  // Service
  ServiceType selectedService = ServiceType.standard;
  String selectedTime = 'ASAP ~30min';
  PaymentMethod selectedPM = PaymentMethod.card;

  // Current order
  AppOrder? currentOrder;

  // Driver state
  bool driverOnline = true;

  // Totals
  double get itemsTotal => items.values.fold(0, (s, i) => s + i.price * i.qty);

  double get addonTotal =>
      addons.values.where((a) => a.selected).fold(0, (s, a) => s + a.price);

  double get serviceExtra => selectedService.extra;

  double get grandTotal => itemsTotal + serviceExtra + addonTotal + 2.99;

  // Currency format
  String fmt(double v) =>
      currency.symbol + (v * currency.rate).toStringAsFixed(2);

  // Mutators
  void setCurrency(Currency c) {
    currency = c;
    notifyListeners();
  }

  void changeQty(String key, int delta) {
    final item = items[key];
    if (item == null) return;
    item.qty = (item.qty + delta).clamp(0, 99);
    notifyListeners();
  }

  void selectService(ServiceType s) {
    selectedService = s;
    notifyListeners();
  }

  void toggleAddon(String key) {
    final a = addons[key];
    if (a == null) return;
    a.selected = !a.selected;
    notifyListeners();
  }

  void selectTime(String t) {
    selectedTime = t;
    notifyListeners();
  }

  void selectPM(PaymentMethod pm) {
    selectedPM = pm;
    notifyListeners();
  }

  void setProfile(UserProfile? p, String? uid, String? email) {
    currentProfile = p;
    currentUserId = uid;
    currentUserEmail = email;
    currentRole = p?.role ?? 'customer';
    notifyListeners();
  }

  void setCurrentOrder(AppOrder? o) {
    currentOrder = o;
    notifyListeners();
  }

  void setLocation(double lat, double lng, {String address = ''}) {
    userLat = lat;
    userLng = lng;
    if (address.isNotEmpty) userAddress = address;
    notifyListeners();
  }

  void setAddress(String address) {
    userAddress = address;
    notifyListeners();
  }

  void setDriverOnline(bool v) {
    driverOnline = v;
    notifyListeners();
  }

  void updateItemPrice(String key, double price) {
    if (items.containsKey(key)) {
      items[key]!.price = price;
      notifyListeners();
    }
  }

  void signOut() {
    currentProfile = null;
    currentUserId = null;
    currentUserEmail = null;
    currentRole = 'customer';
    for (var i in items.values) {
      i.qty = 0;
    }
    for (var a in addons.values) {
      a.selected = false;
    }
    currentOrder = null;
    notifyListeners();
  }
}

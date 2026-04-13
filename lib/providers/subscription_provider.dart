import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/subscription_model.dart';
import '../models/price_model.dart';

class SubscriptionProvider extends ChangeNotifier {
  final _supabase = Supabase.instance.client;
  
  SubscriptionModel? _subscription;
  List<PriceModel> _prices = [];
  bool _loading = true;
  RealtimeChannel? _channel;

  SubscriptionModel? get subscription => _subscription;
  List<PriceModel> get prices => _prices;
  bool get loading => _loading;
  bool get isActive => _subscription?.isActive ?? false;

  Future<void> initialize() async {
    await Future.wait([
      _loadSubscription(),
      _loadPrices(),
    ]);
    _listenToSubscriptionChanges();
  }

  Future<void> _loadSubscription() async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      _loading = false;
      notifyListeners();
      return;
    }

    try {
      final data = await _supabase
          .from('subscriptions')
          .select()
          .eq('user_id', user.id)
          .inFilter('status', ['active', 'trialing'])
          .maybeSingle();

      _subscription =
          data != null ? SubscriptionModel.fromMap(data) : null;
    } catch (e) {
      debugPrint('Errore caricamento subscription: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> _loadPrices() async {
    try {
      final data = await _supabase
          .from('prices')
          .select('*, products(*)')
          .eq('active', true)
          .order('unit_amount');

      _prices = data.map((p) => PriceModel.fromMap(p)).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Errore caricamento prezzi: $e');
    }
  }

  void _listenToSubscriptionChanges() {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    _channel = _supabase
        .channel('subscription-${user.id}')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'subscriptions',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: user.id,
          ),
          callback: (payload) {
            debugPrint('Subscription aggiornata: ${payload.eventType}');
            _loadSubscription(); // Ricarica
          },
        )
        .subscribe();
  }

  @override
  void dispose() {
    _channel?.unsubscribe();
    super.dispose();
  }
}

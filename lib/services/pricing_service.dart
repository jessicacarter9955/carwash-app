import '../core/supabase_client.dart';
import '../state/app_state.dart';

class PricingService {
  static Future<void> loadFromDB(AppState state) async {
    try {
      final data = await supabase.from('service_pricing').select('*');
      for (final row in data as List) {
        final key = row['item_key'] as String?;
        final price = (row['price'] as num?)?.toDouble();
        if (key != null && price != null) {
          state.updateItemPrice(key, price);
        }
      }
    } catch (_) {}
  }
}

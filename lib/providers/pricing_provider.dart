import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/service_pricing_model.dart';
import 'auth_providers.dart';

final pricingProvider = FutureProvider<List<ServicePricingModel>>((ref) async {
  final sb = ref.read(supabaseProvider);
  try {
    final data = await sb.from('service_pricing').select();
    return (data as List).map((m) => ServicePricingModel.fromMap(m)).toList();
  } catch (_) {
    return [];
  }
});

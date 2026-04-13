import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class StripeService {
  final _supabase = Supabase.instance.client;

  // ============================================================
  // METODO 1: Payment Sheet (UI nativa di Stripe)
  // Usato per pagamenti singoli in-app
  // ============================================================
  Future<void> presentPaymentSheet({
    required int amount,
    String currency = 'eur',
    String? description,
  }) async {
    try {
      // 1. Chiedi il PaymentIntent alla Edge Function
      final response = await _supabase.functions.invoke(
        'create-payment-intent',
        body: {
          'amount': amount,
          'currency': currency,
          'description': description,
        },
      );

      if (response.status != 200) {
        throw Exception('Failed to create payment intent');
      }

      final clientSecret = response.data['clientSecret'] as String;

      // 2. Inizializza il Payment Sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'WashGo',
          style: ThemeMode.system,
          // Personalizzazione aspetto
          appearance: PaymentSheetAppearance(
            colors: PaymentSheetAppearanceColors(
              primary: Color(0xFF3B82F6),
            ),
          ),
        ),
      );

      // 3. Mostra il Payment Sheet
      await Stripe.instance.presentPaymentSheet();

      debugPrint('Pagamento completato!');
    } on StripeException catch (e) {
      if (e.error.code == FailureCode.Canceled) {
        debugPrint('Pagamento annullato dall\'utente');
        return;
      }
      rethrow;
    }
  }

  // ============================================================
  // METODO 2: Stripe Checkout (WebView/Browser)
  // Usato principalmente per subscription
  // ============================================================
  Future<void> openCheckout({
    required String priceId,
    String mode = 'subscription',
  }) async {
    try {
      final response = await _supabase.functions.invoke(
        'create-checkout',
        body: {
          'priceId': priceId,
          'mode': mode,
          'successUrl': 'washgo://payment/success',
          'cancelUrl': 'washgo://payment/cancel',
        },
      );

      if (response.status != 200) {
        throw Exception('Failed to create checkout session');
      }

      final url = response.data['url'] as String;
      final uri = Uri.parse(url);

      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      }
    } catch (e) {
      debugPrint('Errore checkout: $e');
      rethrow;
    }
  }

  // ============================================================
  // METODO 3: Customer Portal (gestione abbonamento)
  // ============================================================
  Future<void> openCustomerPortal() async {
    try {
      final response = await _supabase.functions.invoke('customer-portal');

      if (response.status != 200) {
        throw Exception('Failed to open customer portal');
      }

      final url = response.data['url'] as String;
      final uri = Uri.parse(url);

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Errore portale: $e');
      rethrow;
    }
  }
}

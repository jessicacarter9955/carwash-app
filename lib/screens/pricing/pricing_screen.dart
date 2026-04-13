import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/subscription_provider.dart';
import '../../services/stripe_service.dart';
import '../../models/price_model.dart';

class PricingScreen extends StatefulWidget {
  const PricingScreen({super.key});

  @override
  State<PricingScreen> createState() => _PricingScreenState();
}

class _PricingScreenState extends State<PricingScreen> {
  final _stripeService = StripeService();
  String? _loadingPriceId;

  @override
  void initState() {
    super.initState();
    context.read<SubscriptionProvider>().initialize();
  }

  Future<void> _subscribe(PriceModel price) async {
    setState(() => _loadingPriceId = price.id);

    try {
      // Usa Payment Sheet per pagamenti singoli
      // Usa Checkout per subscriptions
      if (price.type == 'one_time') {
        await _stripeService.presentPaymentSheet(
          amount: price.unitAmount,
          currency: price.currency,
          description: price.product?.name,
        );
        _showSuccess('Pagamento completato!');
      } else {
        await _stripeService.openCheckout(
          priceId: price.id,
          mode: 'subscription',
        );
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      setState(() => _loadingPriceId = null);
    }
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scegli il tuo piano')),
      body: Consumer<SubscriptionProvider>(
        builder: (context, provider, child) {
          if (provider.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.isActive) {
            return _buildActiveSubscription(provider);
          }

          return _buildPricingList(provider.prices);
        },
      ),
    );
  }

  Widget _buildActiveSubscription(SubscriptionProvider provider) {
    final sub = provider.subscription!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 80),
            const SizedBox(height: 16),
            Text(
              'Abbonamento Attivo',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Status: ${sub.status}',
              style: const TextStyle(color: Colors.grey),
            ),
            Text(
              'Rinnova il: ${_formatDate(sub.currentPeriodEnd)}',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            OutlinedButton.icon(
              onPressed: _stripeService.openCustomerPortal,
              icon: const Icon(Icons.settings),
              label: const Text('Gestisci Abbonamento'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPricingList(List<PriceModel> prices) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: prices.length,
      itemBuilder: (context, index) {
        final price = prices[index];
        return _PriceCard(
          price: price,
          isLoading: _loadingPriceId == price.id,
          onTap: () => _subscribe(price),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _PriceCard extends StatelessWidget {
  final PriceModel price;
  final bool isLoading;
  final VoidCallback onTap;

  const _PriceCard({
    required this.price,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Immagine prodotto
            if (price.product?.image != null)
              Image.network(
                price.product!.image!,
                height: 60,
                width: 60,
              ),

            // Nome prodotto
            Text(
              price.product?.name ?? 'Piano',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),

            // Descrizione
            if (price.product?.description != null)
              Text(
                price.product!.description!,
                style: const TextStyle(color: Colors.grey),
              ),
            const SizedBox(height: 12),

            // Prezzo
            Text(
              price.formattedPrice,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
            ),

            // Trial
            if (price.trialPeriodDays != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '${price.trialPeriodDays} giorni di prova gratuita',
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // Bottone
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : onTap,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        price.type == 'recurring' ? 'Abbonati' : 'Acquista',
                        style: const TextStyle(fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

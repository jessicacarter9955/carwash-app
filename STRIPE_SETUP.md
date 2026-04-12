# Stripe with Supabase Implementation Guide

## Overview
This guide explains how to implement Stripe payments with Supabase for the car wash app.

## Prerequisites
- Stripe account with API keys (publishable key and secret key)
- Supabase project with database set up
- Flutter app with the carwash codebase

## Step 1: Set up Stripe in Supabase

### 1.1 Add Stripe Extension to Supabase
1. Go to your Supabase project dashboard
2. Navigate to Extensions
3. Search for "Stripe" extension
4. Install the Stripe extension
5. Configure it with your Stripe secret key

### 1.2 Create Database Tables

```sql
-- Create orders table with payment tracking
CREATE TABLE orders (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id),
  driver_id UUID,
  status TEXT DEFAULT 'pending', -- pending, pickup, washing, ready, delivered
  total DECIMAL(10,2),
  payment_intent_id TEXT,
  payment_status TEXT DEFAULT 'unpaid', -- unpaid, paid, failed
  service_type TEXT,
  pickup_address TEXT,
  pickup_lat DECIMAL(10,8),
  pickup_lng DECIMAL(11,8),
  pickup_time TIMESTAMP,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Create order_items table
CREATE TABLE order_items (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  order_id UUID REFERENCES orders(id) ON DELETE CASCADE,
  item_name TEXT,
  item_price DECIMAL(10,2),
  quantity INT DEFAULT 1
);

-- Create payments table
CREATE TABLE payments (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  order_id UUID REFERENCES orders(id),
  stripe_payment_intent_id TEXT UNIQUE,
  amount DECIMAL(10,2),
  currency TEXT DEFAULT 'usd',
  status TEXT DEFAULT 'pending',
  created_at TIMESTAMP DEFAULT NOW()
);
```

## Step 2: Add Stripe to Flutter

### 2.1 Add dependencies to pubspec.yaml
```yaml
dependencies:
  flutter_stripe: ^9.4.0
```

### 2.2 Initialize Stripe in main.dart
```dart
import 'package:flutter_stripe/flutter_stripe.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Stripe
  Stripe.publishableKey = 'pk_test_YOUR_PUBLISHABLE_KEY';
  
  await Supabase.initialize(url: kSupabaseUrl, anonKey: kSupabaseAnonKey);
  // ... rest of your main
}
```

## Step 3: Create Payment Service

### 3.1 Create payment_service.dart
```dart
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PaymentService {
  static Future<Map<String, dynamic>> createPaymentIntent({
    required double amount,
    required String currency,
  }) async {
    try {
      // Call Supabase Edge Function to create payment intent
      final response = await http.post(
        Uri.parse('${kSupabaseUrl}/functions/v1/create-payment-intent'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $kSupabaseAnonKey',
        },
        body: jsonEncode({
          'amount': (amount * 100).toInt(), // Convert to cents
          'currency': currency,
        }),
      );

      final data = jsonDecode(response.body);
      return data;
    } catch (e) {
      throw Exception('Failed to create payment intent: $e');
    }
  }

  static Future<void> processPayment({
    required String clientSecret,
    required Map<String, dynamic> paymentMethod,
  }) async {
    try {
      // Confirm payment with Stripe
      await Stripe.instance.confirmPayment(
        paymentIntentClientSecret: clientSecret,
        data: PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData.fromMap(paymentMethod),
        ),
      );
    } catch (e) {
      throw Exception('Payment failed: $e');
    }
  }
}
```

## Step 4: Create Supabase Edge Function

### 4.1 Create Edge Function for Payment Intent
```typescript
// supabase/functions/create-payment-intent/index.ts
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { Stripe } from 'https://esm.sh/stripe@12.0.0'

const stripe = new Stripe(Deno.env.get('STRIPE_SECRET_KEY')!)

serve(async (req) => {
  try {
    const { amount, currency } = await req.json()
    
    const paymentIntent = await stripe.paymentIntents.create({
      amount,
      currency,
      automatic_payment_methods: {
        enabled: true,
      },
    })

    return new Response(
      JSON.stringify({
        clientSecret: paymentIntent.client_secret,
        paymentIntentId: paymentIntent.id,
      }),
      { headers: { 'Content-Type': 'application/json' } }
    )
  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 400, headers: { 'Content-Type': 'application/json' } }
    )
  }
})
```

## Step 5: Update Checkout Screen

### 5.1 Modify checkout_screen.dart to use Stripe
```dart
import 'package:flutter_stripe/flutter_stripe.dart';
import '../services/payment_service.dart';

class CheckoutScreen extends ConsumerWidget {
  // ... existing code

  Future<void> _placeOrder() async {
    try {
      // Create payment intent
      final paymentData = await PaymentService.createPaymentIntent(
        amount: cart.total,
        currency: 'usd',
      );

      // Process payment
      await PaymentService.processPayment(
        clientSecret: paymentData['clientSecret'],
        paymentMethod: {
          'type': 'Card',
        },
      );

      // Place order after successful payment
      final success = await ref.read(orderProvider.notifier).placeOrder(
        paymentIntentId: paymentData['paymentIntentId'],
      );

      if (success && mounted) {
        ref.read(cartProvider.notifier).reset();
        context.push('/searching');
      }
    } catch (e) {
      if (mounted) {
        showToast(context, '❌ Payment failed: $e');
      }
    }
  }
}
```

## Step 6: Update Order Provider

### 6.1 Add payment intent ID to order placement
```dart
Future<bool> placeOrder({String? paymentIntentId}) async {
  // ... existing code
  
  final order = await sb.from('orders').insert({
    'user_id': userId,
    'total': total,
    'payment_intent_id': paymentIntentId,
    'payment_status': paymentIntentId != null ? 'paid' : 'unpaid',
    // ... other fields
  }).select();
  
  // ... rest of the code
}
```

## Environment Variables

Add these to your Supabase Edge Function environment:
- `STRIPE_SECRET_KEY`: Your Stripe secret key (sk_live_...)

Add these to your Flutter app (lib/core/constants.dart):
- `stripePublishableKey`: Your Stripe publishable key (pk_live_...)

## Demo Mode Bypass

For demo purposes, you can bypass Stripe by:
1. Adding a "Demo Mode" toggle in settings
2. When enabled, skip payment processing and mark orders as paid
3. This allows testing without actual Stripe integration

See the payment bypass implementation in the checkout screen.

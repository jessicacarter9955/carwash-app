-- Stripe Integration Schema for WashGo
-- Run this in Supabase SQL Editor

-- Customers table
CREATE TABLE IF NOT EXISTS public.customers (
  id UUID REFERENCES auth.users(id) PRIMARY KEY,
  stripe_customer_id TEXT UNIQUE,
  email TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Products table
CREATE TABLE IF NOT EXISTS public.products (
  id TEXT PRIMARY KEY,
  name TEXT,
  description TEXT,
  image TEXT,
  active BOOLEAN DEFAULT true,
  metadata JSONB,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Prices table
CREATE TABLE IF NOT EXISTS public.prices (
  id TEXT PRIMARY KEY,
  product_id TEXT REFERENCES public.products(id),
  currency TEXT,
  unit_amount BIGINT,
  type TEXT CHECK (type IN ('one_time', 'recurring')),
  interval TEXT,
  interval_count INTEGER,
  trial_period_days INTEGER,
  active BOOLEAN DEFAULT true,
  metadata JSONB
);

-- Subscriptions table
CREATE TABLE IF NOT EXISTS public.subscriptions (
  id TEXT PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id),
  status TEXT,
  price_id TEXT REFERENCES public.prices(id),
  quantity INTEGER,
  cancel_at_period_end BOOLEAN,
  current_period_start TIMESTAMPTZ,
  current_period_end TIMESTAMPTZ,
  canceled_at TIMESTAMPTZ,
  ended_at TIMESTAMPTZ,
  trial_start TIMESTAMPTZ,
  trial_end TIMESTAMPTZ,
  metadata JSONB,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Orders table (for single payments)
CREATE TABLE IF NOT EXISTS public.orders (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id),
  stripe_payment_intent_id TEXT,
  stripe_checkout_session_id TEXT,
  amount BIGINT,
  currency TEXT DEFAULT 'eur',
  status TEXT DEFAULT 'pending',
  metadata JSONB,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE public.customers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.prices ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.subscriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY "Prodotti pubblici" ON public.products FOR SELECT USING (true);
CREATE POLICY "Prezzi pubblici" ON public.prices FOR SELECT USING (true);
CREATE POLICY "Solo il proprio customer" ON public.customers 
  FOR ALL USING (auth.uid() = id);
CREATE POLICY "Solo le proprie subscription" ON public.subscriptions 
  FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Solo i propri ordini" ON public.orders 
  FOR SELECT USING (auth.uid() = user_id);

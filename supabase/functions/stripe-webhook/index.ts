import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import Stripe from "https://esm.sh/stripe@13.6.0?target=deno";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const stripe = new Stripe(Deno.env.get("STRIPE_SECRET_KEY")!, {
  apiVersion: "2023-10-16",
});

const supabase = createClient(
  Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
);

serve(async (req) => {
  const signature = req.headers.get("stripe-signature");
  if (!signature) return new Response("No signature", { status: 400 });

  try {
    const body = await req.text();
    const event = stripe.webhooks.constructEvent(
      body,
      signature,
      Deno.env.get("STRIPE_WEBHOOK_SECRET")!
    );

    switch (event.type) {
      case "product.created":
      case "product.updated": {
        const product = event.data.object as Stripe.Product;
        await supabase.from("products").upsert({
          id: product.id,
          name: product.name,
          description: product.description,
          image: product.images?.[0] ?? null,
          active: product.active,
          metadata: product.metadata,
        });
        break;
      }
      case "price.created":
      case "price.updated": {
        const price = event.data.object as Stripe.Price;
        await supabase.from("prices").upsert({
          id: price.id,
          product_id:
            typeof price.product === "string"
              ? price.product
              : price.product.id,
          currency: price.currency,
          unit_amount: price.unit_amount,
          type: price.type,
          interval: price.recurring?.interval ?? null,
          interval_count: price.recurring?.interval_count ?? null,
          trial_period_days: price.recurring?.trial_period_days ?? null,
          active: price.active,
          metadata: price.metadata,
        });
        break;
      }
      case "customer.subscription.created":
      case "customer.subscription.updated":
      case "customer.subscription.deleted": {
        const sub = event.data.object as Stripe.Subscription;
        const userId = sub.metadata.supabase_user_id;
        if (!userId) break;

        await supabase.from("subscriptions").upsert({
          id: sub.id,
          user_id: userId,
          status: sub.status,
          price_id: sub.items.data[0]?.price.id,
          quantity: sub.items.data[0]?.quantity,
          cancel_at_period_end: sub.cancel_at_period_end,
          current_period_start: new Date(sub.current_period_start * 1000).toISOString(),
          current_period_end: new Date(sub.current_period_end * 1000).toISOString(),
          canceled_at: sub.canceled_at
            ? new Date(sub.canceled_at * 1000).toISOString()
            : null,
          ended_at: sub.ended_at
            ? new Date(sub.ended_at * 1000).toISOString()
            : null,
          trial_start: sub.trial_start
            ? new Date(sub.trial_start * 1000).toISOString()
            : null,
          trial_end: sub.trial_end
            ? new Date(sub.trial_end * 1000).toISOString()
            : null,
          metadata: sub.metadata,
        });
        break;
      }
      case "payment_intent.succeeded": {
        const pi = event.data.object as Stripe.PaymentIntent;
        await supabase
          .from("orders")
          .update({ status: "completed" })
          .eq("stripe_payment_intent_id", pi.id);
        break;
      }
      case "payment_intent.payment_failed": {
        const pi = event.data.object as Stripe.PaymentIntent;
        await supabase
          .from("orders")
          .update({ status: "failed" })
          .eq("stripe_payment_intent_id", pi.id);
        break;
      }
    }

    return new Response(JSON.stringify({ received: true }), { status: 200 });
  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      status: 400,
    });
  }
});

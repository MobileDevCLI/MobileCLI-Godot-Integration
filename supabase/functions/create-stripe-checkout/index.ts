// MobileCLI Pro - Stripe Checkout Session Creation
// Creates a Stripe Checkout Session (mode: subscription) for $15/month Pro plan.
// Uses Stripe REST API directly (no SDK needed in Deno).

import { createClient } from "https://esm.sh/@supabase/supabase-js@2"

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Content-Type": "application/json"
}

const STRIPE_API_BASE = "https://api.stripe.com"

interface CreateCheckoutRequest {
  user_id: string
}

/**
 * Check if user already has an active subscription (any provider)
 */
async function checkExistingSubscription(userId: string): Promise<{
  exists: boolean
  provider?: string
  status?: string
}> {
  const supabaseUrl = Deno.env.get("SUPABASE_URL")
  const supabaseKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")

  if (!supabaseUrl || !supabaseKey) {
    console.log("Warning: Supabase credentials not configured, skipping duplicate check")
    return { exists: false }
  }

  const supabase = createClient(supabaseUrl, supabaseKey, {
    auth: { autoRefreshToken: false, persistSession: false }
  })

  try {
    const { data, error } = await supabase
      .from("subscriptions")
      .select("status, provider")
      .eq("user_id", userId)
      .in("status", ["active", "trialing"])
      .maybeSingle()

    if (error) {
      console.error("Error checking existing subscription:", error.message)
      return { exists: false }
    }

    if (data) {
      console.log("Found existing subscription:", data.status, "provider:", data.provider)
      return { exists: true, provider: data.provider, status: data.status }
    }

    return { exists: false }
  } catch (e) {
    console.error("Exception checking existing subscription:", e)
    return { exists: false }
  }
}

/**
 * Create a Stripe Checkout Session for subscription
 */
async function createStripeCheckoutSession(
  userId: string
): Promise<{ checkoutUrl: string; sessionId: string }> {
  const stripeSecretKey = Deno.env.get("STRIPE_SECRET_KEY")
  if (!stripeSecretKey) {
    throw new Error("STRIPE_SECRET_KEY not configured")
  }

  const priceId = Deno.env.get("STRIPE_PRICE_ID")
  if (!priceId) {
    throw new Error("STRIPE_PRICE_ID not configured")
  }

  // Build form-encoded body (Stripe API uses form encoding, not JSON)
  const params = new URLSearchParams()
  params.append("mode", "subscription")
  params.append("line_items[0][price]", priceId)
  params.append("line_items[0][quantity]", "1")
  params.append("client_reference_id", userId)
  params.append("metadata[user_id]", userId)
  params.append("success_url", "https://www.mobilecli.com/success?session_id={CHECKOUT_SESSION_ID}")
  params.append("cancel_url", "https://www.mobilecli.com/pricing.html")
  // Enable automatic tax calculation if configured in Stripe Dashboard
  params.append("automatic_tax[enabled]", "true")

  console.log("Creating Stripe Checkout Session for user:", userId)

  const response = await fetch(`${STRIPE_API_BASE}/v1/checkout/sessions`, {
    method: "POST",
    headers: {
      "Authorization": `Bearer ${stripeSecretKey}`,
      "Content-Type": "application/x-www-form-urlencoded",
    },
    body: params.toString(),
  })

  if (!response.ok) {
    const errorBody = await response.text()
    console.error("Stripe API error:", response.status, errorBody)
    throw new Error(`Stripe API error: ${response.status} - ${errorBody}`)
  }

  const session = await response.json()
  console.log("Stripe Checkout Session created:", session.id)

  if (!session.url) {
    throw new Error("No checkout URL in Stripe response")
  }

  return {
    checkoutUrl: session.url,
    sessionId: session.id,
  }
}

Deno.serve(async (req: Request) => {
  // Handle CORS preflight
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders })
  }

  try {
    if (req.method !== "POST") {
      return new Response(
        JSON.stringify({ error: "Method not allowed" }),
        { status: 405, headers: corsHeaders }
      )
    }

    const body: CreateCheckoutRequest = await req.json()
    const { user_id } = body

    if (!user_id) {
      return new Response(
        JSON.stringify({ error: "user_id is required" }),
        { status: 400, headers: corsHeaders }
      )
    }

    // Validate UUID format
    const uuidRegex = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i
    if (!uuidRegex.test(user_id)) {
      return new Response(
        JSON.stringify({ error: "Invalid user_id format" }),
        { status: 400, headers: corsHeaders }
      )
    }

    console.log("=== Creating Stripe Checkout ===")
    console.log("User ID:", user_id)

    // Check for existing active subscription
    const existing = await checkExistingSubscription(user_id)
    if (existing.exists) {
      console.log("=== DUPLICATE PREVENTED ===")
      return new Response(
        JSON.stringify({
          error: "duplicate_subscription",
          message: "You already have an active subscription",
          provider: existing.provider,
          status: existing.status
        }),
        { status: 409, headers: corsHeaders }
      )
    }

    // Create Stripe Checkout Session
    const { checkoutUrl, sessionId } = await createStripeCheckoutSession(user_id)

    console.log("=== Checkout Session Created ===")
    console.log("Session ID:", sessionId)
    console.log("Checkout URL:", checkoutUrl)

    return new Response(
      JSON.stringify({
        success: true,
        checkout_url: checkoutUrl,
        session_id: sessionId,
        message: "Redirect user to checkout_url to complete payment"
      }),
      { status: 200, headers: corsHeaders }
    )

  } catch (err: any) {
    console.error("Error creating checkout session:", err.message || err)
    return new Response(
      JSON.stringify({
        error: "Failed to create checkout session",
        details: err.message
      }),
      { status: 500, headers: corsHeaders }
    )
  }
})

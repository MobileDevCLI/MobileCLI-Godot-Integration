// MobileCLI Pro - Stripe Customer Portal Session Creation
// Creates a Stripe Billing Portal session so users can manage their subscription:
// cancel, update payment method, view invoices.

import { createClient } from "https://esm.sh/@supabase/supabase-js@2"

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Content-Type": "application/json"
}

const STRIPE_API_BASE = "https://api.stripe.com"

interface PortalRequest {
  user_id: string
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

    const body: PortalRequest = await req.json()
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

    console.log("=== Creating Portal Session ===")
    console.log("User ID:", user_id)

    // Look up stripe_customer_id from subscriptions table
    const supabaseUrl = Deno.env.get("SUPABASE_URL")
    const supabaseKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")

    if (!supabaseUrl || !supabaseKey) {
      return new Response(
        JSON.stringify({ error: "Server configuration error" }),
        { status: 500, headers: corsHeaders }
      )
    }

    const supabase = createClient(supabaseUrl, supabaseKey, {
      auth: { autoRefreshToken: false, persistSession: false }
    })

    const { data: subscription, error: dbError } = await supabase
      .from("subscriptions")
      .select("stripe_customer_id")
      .eq("user_id", user_id)
      .eq("provider", "stripe")
      .maybeSingle()

    if (dbError) {
      console.error("Database error:", dbError.message)
      return new Response(
        JSON.stringify({ error: "Failed to look up subscription" }),
        { status: 500, headers: corsHeaders }
      )
    }

    if (!subscription?.stripe_customer_id) {
      return new Response(
        JSON.stringify({ error: "No Stripe subscription found for this user" }),
        { status: 404, headers: corsHeaders }
      )
    }

    const stripeCustomerId = subscription.stripe_customer_id
    console.log("Found Stripe customer:", stripeCustomerId)

    // Create Stripe Billing Portal Session
    const stripeSecretKey = Deno.env.get("STRIPE_SECRET_KEY")
    if (!stripeSecretKey) {
      return new Response(
        JSON.stringify({ error: "Stripe not configured" }),
        { status: 500, headers: corsHeaders }
      )
    }

    const params = new URLSearchParams()
    params.append("customer", stripeCustomerId)
    params.append("return_url", "https://www.mobilecli.com")

    const response = await fetch(`${STRIPE_API_BASE}/v1/billing_portal/sessions`, {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${stripeSecretKey}`,
        "Content-Type": "application/x-www-form-urlencoded",
      },
      body: params.toString(),
    })

    if (!response.ok) {
      const errorBody = await response.text()
      console.error("Stripe Portal API error:", response.status, errorBody)
      return new Response(
        JSON.stringify({ error: "Failed to create portal session" }),
        { status: 500, headers: corsHeaders }
      )
    }

    const portalSession = await response.json()
    console.log("Portal session created:", portalSession.id)

    return new Response(
      JSON.stringify({
        success: true,
        portal_url: portalSession.url,
        session_id: portalSession.id
      }),
      { status: 200, headers: corsHeaders }
    )

  } catch (err: any) {
    console.error("Error creating portal session:", err.message || err)
    return new Response(
      JSON.stringify({
        error: "Failed to create portal session",
        details: err.message
      }),
      { status: 500, headers: corsHeaders }
    )
  }
})

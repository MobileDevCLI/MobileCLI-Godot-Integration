# MobileCLI Pro - Current State (For AI Context Recovery)

**Date:** January 28, 2026
**Status:** Stripe Integration Complete (Pending Deployment)
**Version:** 2.1.0 (Stripe + PayPal dual payment)

---

## LATEST WORK: Stripe Payment Integration

**Completed January 28, 2026**

### What Changed
Added Stripe as a second payment provider alongside PayPal. Users can now subscribe via:
- **Card payment** (Stripe Checkout) - new
- **PayPal** - existing, unchanged

### New Edge Functions Created
| Function | File | Purpose |
|----------|------|---------|
| `create-stripe-checkout` | `supabase/functions/create-stripe-checkout/index.ts` | Creates Stripe Checkout Session (subscription mode) |
| `stripe-webhook` | `supabase/functions/stripe-webhook/index.ts` | Handles Stripe webhooks with HMAC-SHA256 signature verification |
| `create-portal-session` | `supabase/functions/create-portal-session/index.ts` | Creates Stripe Customer Portal session for subscription management |

### Files Modified
| File | What Changed |
|------|-------------|
| `PaywallActivity.kt` | Added "Subscribe with Card" button, `openStripeCheckout()` method, `createStripeCheckoutSession()` API call |
| `LicenseManager.kt` | Added `stripe_subscription_id`, `stripe_customer_id`, `provider` to `Subscription` data class |
| `AccountActivity.kt` | Smart subscription management: Stripe Portal for Stripe users, PayPal autopay for PayPal users. Added `getSubscriptionProvider()`, `openStripePortal()`, `createPortalSession()` methods |
| `activity_paywall.xml` | Added Stripe button (purple #635BFF), "or" divider, updated PayPal button (blue #0070BA), auto-renewal disclosure text |
| `deploy-functions.yml` | Added deploy steps for 3 new edge functions |

### Files NOT Modified (Protected)
- BootstrapInstaller.kt, SetupWizard.kt, MainActivity.kt
- SupabaseClient.kt, LoginActivity.kt, SplashActivity.kt
- build.gradle.kts (no new dependencies - Stripe uses REST API)
- create-subscription/index.ts, paypal-webhook/index.ts (PayPal code untouched)

### Database Migration Required
Run in Supabase SQL Editor:
```sql
ALTER TABLE subscriptions
  ADD COLUMN IF NOT EXISTS stripe_subscription_id TEXT,
  ADD COLUMN IF NOT EXISTS stripe_customer_id TEXT,
  ADD COLUMN IF NOT EXISTS provider TEXT DEFAULT 'paypal';
```

### Supabase Secrets Required
Set via Supabase Dashboard > Edge Functions > Secrets:
- `STRIPE_SECRET_KEY` = `sk_test_...` (test mode first, then `sk_live_...`)
- `STRIPE_WEBHOOK_SECRET` = `whsec_...` (from Stripe webhook endpoint registration)
- `STRIPE_PRICE_ID` = `price_...` (from Stripe Products page)

### Stripe Webhook Registration (Manual)
1. Go to Stripe Dashboard > Developers > Webhooks > Add endpoint
2. URL: `https://mwxlguqukyfberyhtkmg.supabase.co/functions/v1/stripe-webhook`
3. Events: `checkout.session.completed`, `invoice.paid`, `invoice.payment_failed`, `customer.subscription.updated`, `customer.subscription.deleted`
4. Copy signing secret (`whsec_...`) to Supabase secrets

---

## PREVIOUS WORK: Auth/Payment Flow Fixes

**Completed January 25, 2026**

### Changes Made
1. **Fixed support email** - Changed `support@mobilecli.com` to `mobiledevcli@gmail.com`
2. **Added webhook logging** - All PayPal events logged to `webhook_logs` table
3. **Added payment history** - All payments recorded to `payment_history` table
4. **Processing tracking** - Webhook marks events as processed with result status

### New Database Tables Required
Run in Supabase SQL Editor:
```sql
CREATE TABLE IF NOT EXISTS webhook_logs (...);
CREATE TABLE IF NOT EXISTS payment_history (...);
```
See full SQL in docs or commit message.

---

## PREVIOUS WORK: PayPal Documentation Archive

**Completed January 25, 2026**

Created complete PayPal integration documentation in `docs/paypal/`:

| File | Purpose |
|------|---------|
| `README.md` | Overview and quick start |
| `STORY.md` | Full development history |
| `SETUP_GUIDE.md` | Step-by-step setup from scratch |
| `WEBHOOK_CODE.md` | Working webhook with explanations |
| `DATABASE_SCHEMA.md` | All SQL needed |
| `TROUBLESHOOTING.md` | Common problems and solutions |
| `TEST_PAYLOADS.md` | How to test webhooks |

**Key Fix Documented:** Changed `.update()` to `.upsert()` in webhook to fix silent failures.

---

## LATEST APK

**File:** `/sdcard/Download/MobileCLI-Pro-v2.0.0-rc.3.apk`

This APK includes all previous fixes plus:
- **Fixed AccountActivity delete email** - Now uses correct mobiledevcli@gmail.com
- All support emails now correct
- Webhook logging and payment history
- Browser-based Google OAuth
- Back button navigation fix

**Note:** A new APK build is needed to include the Stripe UI changes.

---

## APK VERSION HISTORY (For Revert)

| Version | File | Changes |
|---------|------|---------|
| **v2.0.0-rc.3** | `MobileCLI-Pro-v2.0.0-rc.3.apk` | All email fixes complete |
| v2.0.0-rc.2 | `MobileCLI-Pro-v2.0.0-rc.2.apk` | Support email fix, webhook logging |
| v2.0.8-BACKFIX | `MobileCLI-Pro-v2.0.8-BACKFIX.apk` | Back button navigation fix |
| v2.0.7-BROWSER-OAUTH | `MobileCLI-Pro-v2.0.7-BROWSER-OAUTH.apk` | Browser-based Google OAuth with PKCE |
| v2.0.6-STABLE | `MobileCLI-Pro-v2.0.6-STABLE.apk` | Crash loop fix, stable |
| v2.0.5-FIXED | `MobileCLI-Pro-v2.0.5-FIXED.apk` | LoginActivity onResume fix |
| v2.0.4-GOOGLE-RESTORED | `MobileCLI-Pro-v2.0.4-GOOGLE-RESTORED.apk` | Restored SDK Google OAuth |
| v2.0.3-OAUTH-FIX | `MobileCLI-Pro-v2.0.3-OAUTH-FIX.apk` | Browser-based OAuth attempt |
| v2.0.2-RESTORE-FIX | `MobileCLI-Pro-v2.0.2-RESTORE-FIX.apk` | Restore Purchase button clickability |
| v2.0.1-PAYMENT-FIX | `MobileCLI-Pro-v2.0.1-PAYMENT-FIX.apk` | PayPal deep link handler |
| v2.0.0-FINAL | `MobileCLI-Pro-v2.0.0-FINAL.apk` | Original release |

All APKs stored in `/sdcard/Download/` for easy revert.

---

## KEY IDS

| Item | Value |
|------|-------|
| PayPal Plan ID | `P-3RH33892X5467024SNFZON2Y` |
| PayPal Button ID | `DHCKPWE3PJ684` |
| Supabase Project | `mwxlguqukyfberyhtkmg` |
| PayPal Webhook URL | `https://mwxlguqukyfberyhtkmg.supabase.co/functions/v1/paypal-webhook` |
| Stripe Webhook URL | `https://mwxlguqukyfberyhtkmg.supabase.co/functions/v1/stripe-webhook` |
| Stripe Checkout URL | `https://mwxlguqukyfberyhtkmg.supabase.co/functions/v1/create-stripe-checkout` |
| Stripe Portal URL | `https://mwxlguqukyfberyhtkmg.supabase.co/functions/v1/create-portal-session` |
| Website | `https://www.mobilecli.com` |
| Success Page | `https://www.mobilecli.com/success` |

---

## PAYMENT FLOWS

### Stripe Flow (New)
```
User clicks "Subscribe with Card"
    |
    v
App calls create-stripe-checkout Edge Function
    |
    v
Stripe Checkout page opens (hosted by Stripe)
    |
    v
User enters card details
    |
    v
Stripe processes payment, sends webhook (HMAC-SHA256 verified)
    |
    v
stripe-webhook Edge Function: UPSERT subscription (status='active', provider='stripe')
    |
    v
User returns to app -> polling detects active subscription -> Pro access
```

### PayPal Flow (Existing, Unchanged)
```
User clicks "Subscribe with PayPal"
    |
    v
PayPal checkout (with custom_id = user_id)
    |
    v
User completes payment
    |
    v
PayPal webhook -> UPSERT (creates row if needed)
    |
    v
status = 'active' in database
    |
    v
User returns to app -> "Restore Purchase" -> Pro access
```

### Subscription Management
```
User opens Account -> "Manage Subscription"
    |
    v
Check provider field in subscriptions table
    |
    ├── provider = 'stripe' -> Open Stripe Customer Portal
    |                           (cancel, update card, view invoices)
    |
    └── provider = 'paypal' or null -> Open PayPal autopay page
```

---

## PAYPAL STATUS

**Status:** WORKING and DOCUMENTED

**The Fix (January 25, 2026):**
- Problem: Webhook using `.update()` returned empty array when no row matched
- Solution: Changed to `.upsert()` with `onConflict: "user_id"`
- Now creates subscription row if missing, updates if exists

**Full Documentation:** See `docs/paypal/` directory

---

## STRIPE STATUS

**Status:** CODE COMPLETE - Pending deployment and configuration

**What's Done:**
- All 3 edge functions written (checkout, webhook, portal)
- Webhook has HMAC-SHA256 signature verification
- Event deduplication via webhook_logs table
- Kotlin UI updated (Stripe button, provider-aware account management)
- GitHub Actions updated to deploy new functions

**What User Needs To Do:**
1. Run database migration (ALTER TABLE)
2. Set Supabase secrets (STRIPE_SECRET_KEY, STRIPE_WEBHOOK_SECRET, STRIPE_PRICE_ID)
3. Register webhook endpoint in Stripe Dashboard
4. Configure Customer Portal in Stripe Dashboard
5. Push code to trigger GitHub Actions deployment
6. Test with Stripe test card `4242 4242 4242 4242`
7. Build new APK with Stripe UI

---

## KNOWN ISSUES (To Fix)

### PayPal custom_id Reliability
- **Problem:** PayPal subscription URLs don't reliably pass `custom_id` as URL parameter
- **Impact:** Webhook can't find user unless PayPal email matches Google login email
- **Solution Needed:** Use PayPal JavaScript SDK to pass custom_id properly
- **Workaround:** User must use same email for Google login and PayPal
- **Note:** This problem does NOT affect Stripe (client_reference_id is reliable)

### Subscription Verification
- User must click "Restore Purchase" manually after payment
- Auto-verification removed to prevent crash loops
- Webhook logs should be checked in Supabase dashboard

---

## FEATURES COMPLETED

### Authentication & Payments
- Google OAuth + Email/Password login
- Stripe subscription ($15/month via card) - NEW
- PayPal subscription ($15/month via PayPal)
- Stripe webhook with HMAC-SHA256 signature verification - NEW
- PayPal webhook handles all subscription events (with UPSERT fix)
- Stripe Customer Portal for subscription management - NEW
- Multi-device login support
- Payment success deep link handler

### Account Management (Industry Standard)
- Account screen with profile display
- Logout button with confirmation
- Manage Subscription (Stripe Portal or PayPal, based on provider) - UPDATED
- Restore Purchase functionality
- Delete Account option (updated text for Stripe)

### Bug Fixes Applied
- Fixed: Account screen transparent background
- Fixed: Deprecated onBackPressed (Android 13+)
- Fixed: Webhook field mismatch
- Fixed: PayPal 404 on return
- Fixed: Restore Purchase button not responding
- Fixed: Google OAuth error handling
- Fixed: Crash loop
- Fixed: "Immediately kicks away" issue
- Fixed: Google OAuth not working (browser-based OAuth)
- **Fixed: Webhook silent failure (UPSERT)**

---

## GIT TAGS

| Tag | Description |
|-----|-------------|
| `paypal-working-jan25` | Complete working PayPal integration |

To recover PayPal-only:
```bash
git checkout paypal-working-jan25
# Read docs/paypal/SETUP_GUIDE.md
```

---

## IMPORTANT FILES

| File | Purpose |
|------|---------|
| `CURRENT_STATE.md` | Quick AI context recovery |
| `docs/paypal/` | **Complete PayPal archive** |
| `CLAUDE.md` | AI environment guide |
| `app/src/main/java/com/termux/auth/LoginActivity.kt` | Login + Google OAuth |
| `app/src/main/java/com/termux/auth/PaywallActivity.kt` | Stripe + PayPal subscription |
| `app/src/main/java/com/termux/auth/LicenseManager.kt` | Subscription verification |
| `app/src/main/java/com/termux/auth/AccountActivity.kt` | Account management (Stripe/PayPal aware) |
| `supabase/functions/create-stripe-checkout/index.ts` | Stripe Checkout Session creation |
| `supabase/functions/stripe-webhook/index.ts` | Stripe webhook handler (signature verified) |
| `supabase/functions/create-portal-session/index.ts` | Stripe Customer Portal session |
| `supabase/functions/paypal-webhook/index.ts` | PayPal webhook (UPSERT version) |
| `supabase/functions/create-subscription/index.ts` | PayPal subscription creation |
| `supabase/setup_subscriptions.sql` | Database setup SQL |

---

## DO NOT MODIFY

- BootstrapInstaller.kt
- SetupWizard.kt
- MainActivity.kt (except drawer setup)
- gradle.properties

---

## VERIFICATION PLAN (Test Mode)

1. Deploy edge functions via GitHub Actions push
2. Test `create-stripe-checkout` with curl:
   ```bash
   curl -X POST https://mwxlguqukyfberyhtkmg.supabase.co/functions/v1/create-stripe-checkout \
     -H "Content-Type: application/json" \
     -d '{"user_id": "test-uuid-here"}'
   ```
3. Open checkout URL, use Stripe test card `4242 4242 4242 4242`
4. Verify webhook fires (check `webhook_logs` table)
5. Verify `subscriptions` table updated: `status='active'`, `provider='stripe'`
6. Test Customer Portal via `create-portal-session`
7. Test `invoice.payment_failed` with test card `4000 0000 0000 0341`
8. Once all tests pass, switch to live keys

## GO-LIVE CHECKLIST

1. Replace `sk_test_` with `sk_live_` in Supabase secrets
2. Create live webhook endpoint (same URL, Stripe live mode)
3. Replace `whsec_` test secret with live secret
4. Update Price ID from test to live product
5. Verify one real test transaction
6. Commit final config changes

---

*Last updated: January 28, 2026 - Stripe integration code complete*

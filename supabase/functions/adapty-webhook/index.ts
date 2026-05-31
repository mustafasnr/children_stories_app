import "jsr:@supabase/functions-js/edge-runtime.d.ts"
import { createClient } from "jsr:@supabase/supabase-js@2"

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

Deno.serve(async (req) => {
  // 1. CORS Preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  // 2. Only allow POST requests
  if (req.method !== 'POST') {
    return new Response(JSON.stringify({ error: 'Method Not Allowed' }), {
      status: 405,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    })
  }

  try {
    // 3. Authorization header check (if secret is configured in env)
    const authHeader = req.headers.get('Authorization')
    const webhookSecret = Deno.env.get('ADAPTY_WEBHOOK_SECRET')
    
    if (webhookSecret && authHeader !== webhookSecret) {
      console.warn('Unauthorized request attempt: Invalid Authorization header value.')
      return new Response(JSON.stringify({ error: 'Unauthorized' }), {
        status: 401,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      })
    }

    // 4. Parse request body
    const bodyText = await req.text()
    if (!bodyText || bodyText.trim() === '') {
      // Empty body is treated as a validation request
      console.log('Received empty body. Responding with empty JSON object verification.')
      return new Response(JSON.stringify({}), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200,
      })
    }

    let body
    try {
      body = JSON.parse(bodyText)
    } catch (e) {
      console.error('Failed to parse request body as JSON:', e)
      return new Response(JSON.stringify({ error: 'Invalid JSON body' }), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 400,
      })
    }

    // 5. Verification check
    // Adapty sends POST validation request containing an empty JSON object '{}'
    // or when checking connections.
    if (Object.keys(body).length === 0 || !body.event_type) {
      console.log('Received verification request. Responding with {}')
      return new Response(JSON.stringify({}), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200,
      })
    }

    console.log(`Processing event: ${body.event_type} for customer_user_id: ${body.customer_user_id}`)

    const customerUserId = body.customer_user_id
    if (!customerUserId) {
      console.log('No customer_user_id present in the payload. Skipping database update.')
      return new Response(JSON.stringify({ success: true, message: 'Skipped: No customer_user_id' }), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200,
      })
    }

    // Defensive check: Ensure customerUserId is a valid UUID to prevent Postgres type matching errors
    const uuidRegex = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i
    if (!uuidRegex.test(customerUserId)) {
      console.log(`customer_user_id '${customerUserId}' is not a valid UUID. Skipping database update.`)
      return new Response(JSON.stringify({ success: true, message: 'Skipped: customer_user_id is not a valid UUID' }), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200,
      })
    }

    // 6. Determine premium status (isPremium)
    const eventProperties = body.event_properties || {}
    let isPremium = false

    if (body.event_type === 'access_level_updated') {
      const accessLevelId = eventProperties.access_level_id || body.data?.access_level?.id
      const isActive = eventProperties.is_active !== undefined 
        ? eventProperties.is_active 
        : body.data?.access_level?.is_active

      if (accessLevelId === 'premium') {
        isPremium = !!isActive
      } else {
        console.log(`Access level ID is '${accessLevelId}' (expected 'premium'). Ignoring access status update.`)
        return new Response(JSON.stringify({ success: true, message: 'Ignored non-premium access level change' }), {
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          status: 200,
        })
      }
    } else {
      // For general subscription events
      if (eventProperties.profile_has_access_level !== undefined) {
        isPremium = !!eventProperties.profile_has_access_level
      } else if (eventProperties.is_active !== undefined) {
        isPremium = !!eventProperties.is_active
      } else {
        // Fallback checks based on event type if properties are completely missing
        const positiveEvents = [
          'subscription_started',
          'subscription_renewed',
          'subscription_renewal_reactivated',
          'trial_started',
          'trial_renewal_reactivated',
          'trial_converted',
          'entered_grace_period',
        ]
        const negativeEvents = [
          'subscription_expired',
          'subscription_refunded',
          'trial_expired',
        ]
        if (positiveEvents.includes(body.event_type)) {
          isPremium = true
        } else if (negativeEvents.includes(body.event_type)) {
          isPremium = false
        } else {
          console.log(`Ignored event: ${body.event_type} - No access level information.`)
          return new Response(JSON.stringify({ success: true, message: `Ignored event: ${body.event_type}` }), {
            headers: { ...corsHeaders, 'Content-Type': 'application/json' },
            status: 200,
          })
        }
      }
    }

    console.log(`Updating user ${customerUserId} is_premium to ${isPremium}`)

    // 7. Update database profiles table
    const supabaseUrl = Deno.env.get('SUPABASE_URL') || ''
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') || ''

    if (!supabaseUrl || !supabaseServiceKey) {
      console.error('Supabase credentials environment variables are missing.')
      return new Response(JSON.stringify({ error: 'Internal configuration error' }), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 500,
      })
    }

    const supabase = createClient(supabaseUrl, supabaseServiceKey)

    const { data, error } = await supabase
      .from('profiles')
      .update({
        is_premium: isPremium,
        updated_at: new Date().toISOString(),
      })
      .eq('id', customerUserId)
      .select()

    if (error) {
      console.error(`Database error updating profile ${customerUserId}:`, error)
      return new Response(JSON.stringify({ error: error.message }), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 500,
      })
    }

    console.log(`Successfully updated profile ${customerUserId}. Rows affected: ${data?.length || 0}`)

    return new Response(JSON.stringify({ success: true, updated: data?.length || 0, is_premium: isPremium }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 200,
    })
  } catch (error) {
    console.error('Unhandled webhook error:', error)
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 400,
    })
  }
})

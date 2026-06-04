import { createClient } from "https://esm.sh/@supabase/supabase-js@2"

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type, x-admin-api-key',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
}

Deno.serve(async (req) => {
  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  // Verify Admin API Key
  const adminKey = req.headers.get('x-admin-api-key')
  const expectedKey = Deno.env.get('ADMIN_API_KEY')
  
  if (!expectedKey) {
    return new Response(
      JSON.stringify({ error: "ADMIN_API_KEY env variable is not set on the server." }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 500 }
    )
  }

  if (adminKey !== expectedKey) {
    return new Response(
      JSON.stringify({ error: "Unauthorized: Invalid x-admin-api-key" }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 401 }
    )
  }

  try {
    const { action, data } = await req.json()
    
    // Initialize Supabase Client with service role key (bypasses RLS)
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '',
      {
        auth: {
          persistSession: false,
        },
      }
    )

    if (action === 'create_book') {
      // 1. Insert into books table
      const { data: book, error: bookError } = await supabaseClient
        .from('books')
        .insert({
          id: data.id,
          cover_url: data.cover_url,
          category_id: data.category_id,
          is_premium: data.is_premium ?? false,
          is_featured: data.is_featured ?? false,
          age_min: data.age_min ?? 3,
          age_max: data.age_max ?? 10,
          read_time_minutes: data.read_time_minutes ?? 5,
          page_count: data.page_count ?? 0,
        })
        .select()
        .single()

      if (bookError) throw bookError

      // 2. Insert translations if provided
      if (data.translations && data.translations.length > 0) {
        const translationsToInsert = data.translations.map((t: any) => ({
          book_id: book.id,
          language_code: t.language_code,
          title: t.title,
          description: t.description,
        }))

        const { error: transError } = await supabaseClient
          .from('book_translations')
          .insert(translationsToInsert)

        if (transError) throw transError
      }

      return new Response(JSON.stringify({ success: true, book }), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200,
      })
    } 
    
    else if (action === 'create_page') {
      // 1. Insert into pages table
      const { data: page, error: pageError } = await supabaseClient
        .from('pages')
        .insert({
          book_id: data.book_id,
          page_number: data.page_number,
          image_url: data.image_url,
        })
        .select()
        .single()

      if (pageError) throw pageError

      // 2. Insert page translations if provided
      if (data.translations && data.translations.length > 0) {
        const translationsToInsert = data.translations.map((t: any) => ({
          page_id: page.id,
          language_code: t.language_code,
          text_content: t.text_content,
          audio_seek_seconds: t.audio_seek_seconds ?? 0.0,
        }))

        const { error: transError } = await supabaseClient
          .from('page_translations')
          .insert(translationsToInsert)

        if (transError) throw transError
      }

      // 3. Update page_count in books table automatically
      const { count } = await supabaseClient
        .from('pages')
        .select('*', { count: 'exact', head: true })
        .eq('book_id', data.book_id)

      await supabaseClient
        .from('books')
        .update({ page_count: count ?? 0 })
        .eq('id', data.book_id)

      return new Response(JSON.stringify({ success: true, page }), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200,
      })
    } 
    
    else if (action === 'create_audio') {
      // Insert or update book audio narration
      const { data: audio, error: audioError } = await supabaseClient
        .from('book_audio')
        .upsert({
          book_id: data.book_id,
          language_code: data.language_code,
          audio_url: data.audio_url,
          duration_seconds: data.duration_seconds ?? 0,
        }, { onConflict: 'book_id,language_code' })
        .select()
        .single()

      if (audioError) throw audioError

      return new Response(JSON.stringify({ success: true, audio }), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200,
      })
    }

    return new Response(JSON.stringify({ error: `Unknown action: ${action}` }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 400,
    })

  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 400,
    })
  }
})

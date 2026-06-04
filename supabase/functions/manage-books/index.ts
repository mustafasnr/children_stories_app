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
      const bookId = data.book_id;
      const pageNumber = data.page_number;
      const imageUrl = data.image_url;
      const translations = data.translations || [];

      // We need to insert/update the page inside pages_data for each translated language
      const results = [];
      for (const t of translations) {
        const langCode = t.language_code;
        const textContent = t.text_content;
        const audioSeekSeconds = t.audio_seek_seconds ?? 0.0;

        // Fetch existing row
        const { data: existingRow } = await supabaseClient
          .from('pages')
          .select('id, pages_data')
          .eq('book_id', bookId)
          .eq('language_code', langCode)
          .maybeSingle();

        let pagesList = existingRow?.pages_data || [];
        if (!Array.isArray(pagesList)) {
          pagesList = [];
        }

        // Check if page already exists in the list
        const pageIdx = pagesList.findIndex((p: any) => p.page_number === pageNumber);
        const newPageObj = {
          page_number: pageNumber,
          image_url: imageUrl,
          text_content: textContent,
          audio_seek_seconds: audioSeekSeconds,
        };

        if (pageIdx !== -1) {
          pagesList[pageIdx] = newPageObj;
        } else {
          pagesList.push(newPageObj);
        }

        // Sort by page_number
        pagesList.sort((a: any, b: any) => a.page_number - b.page_number);

        // Upsert back
        const { data: pageRow, error: pageError } = await supabaseClient
          .from('pages')
          .upsert({
            book_id: bookId,
            language_code: langCode,
            pages_data: pagesList,
            updated_at: new Date().toISOString()
          }, { onConflict: 'book_id,language_code' })
          .select()
          .single();

        if (pageError) throw pageError;
        results.push(pageRow);
      }

      // Update page_count in books table automatically based on the max count of pages across translations
      const { data: pageRows } = await supabaseClient
        .from('pages')
        .select('pages_data')
        .eq('book_id', bookId);

      let maxPages = 0;
      if (pageRows) {
        for (const row of pageRows) {
          if (Array.isArray(row.pages_data) && row.pages_data.length > maxPages) {
            maxPages = row.pages_data.length;
          }
        }
      }

      await supabaseClient
        .from('books')
        .update({ page_count: maxPages })
        .eq('id', bookId);

      return new Response(JSON.stringify({ success: true, results }), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200,
      });
    }

    else if (action === 'save_book_pages') {
      const bookId = data.book_id;
      const langCode = data.language_code;
      const pages = data.pages || []; // Array of { page_number, image_url, text_content, audio_seek_seconds }

      // Sort by page_number to ensure correct ordering
      pages.sort((a: any, b: any) => a.page_number - b.page_number);

      const { data: pageRow, error: pageError } = await supabaseClient
        .from('pages')
        .upsert({
          book_id: bookId,
          language_code: langCode,
          pages_data: pages,
          updated_at: new Date().toISOString()
        }, { onConflict: 'book_id,language_code' })
        .select()
        .single();

      if (pageError) throw pageError;

      // Update page_count in books table automatically based on the max count of pages across translations
      const { data: pageRows } = await supabaseClient
        .from('pages')
        .select('pages_data')
        .eq('book_id', bookId);

      let maxPages = 0;
      if (pageRows) {
        for (const row of pageRows) {
          if (Array.isArray(row.pages_data) && row.pages_data.length > maxPages) {
            maxPages = row.pages_data.length;
          }
        }
      }

      await supabaseClient
        .from('books')
        .update({ page_count: maxPages })
        .eq('id', bookId);

      return new Response(JSON.stringify({ success: true, pageRow }), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200,
      });
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

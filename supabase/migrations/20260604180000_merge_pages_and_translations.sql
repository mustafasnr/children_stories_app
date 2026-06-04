-- Rename old tables to allow migration
ALTER TABLE public.page_translations RENAME TO old_page_translations;
ALTER TABLE public.pages RENAME TO old_pages;

-- Create the new pages table with pages_data jsonb
CREATE TABLE public.pages (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  book_id UUID NOT NULL REFERENCES public.books(id) ON DELETE CASCADE,
  language_code TEXT NOT NULL REFERENCES public.languages(code) ON DELETE CASCADE,
  pages_data JSONB NOT NULL DEFAULT '[]'::jsonb,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  CONSTRAINT pages_book_id_language_code_key UNIQUE (book_id, language_code)
);

-- Migrate old page and translation data to new structure
INSERT INTO public.pages (book_id, language_code, pages_data, created_at, updated_at)
SELECT 
    op.book_id,
    opt.language_code,
    jsonb_agg(
        jsonb_build_object(
            'page_number', op.page_number,
            'image_url', op.image_url,
            'text_content', opt.text_content,
            'audio_seek_seconds', opt.audio_seek_seconds
        ) ORDER BY op.page_number
    ) AS pages_data,
    MIN(op.created_at) AS created_at,
    MIN(op.created_at) AS updated_at
FROM public.old_pages op
JOIN public.old_page_translations opt ON op.id = opt.page_id
GROUP BY op.book_id, opt.language_code;

-- Drop old tables
DROP TABLE public.old_page_translations;
DROP TABLE public.old_pages;

-- Enable RLS and create select policy
ALTER TABLE public.pages ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Pages require auth" ON public.pages
FOR SELECT
TO authenticated
USING (
  (EXISTS (
    SELECT 1 FROM public.books
    WHERE books.id = pages.book_id AND books.is_premium = false
  )) OR (
    EXISTS (
      SELECT 1 FROM public.subscriptions
      WHERE subscriptions.id = auth.uid()
        AND subscriptions.is_premium = true
        AND (subscriptions.expires_at IS NULL OR subscriptions.expires_at > now())
    )
  )
);

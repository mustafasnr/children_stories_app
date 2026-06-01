-- 1. Create subscriptions table
create table if not exists public.subscriptions (
    id uuid not null primary key references public.profiles(id) on delete cascade,
    is_premium boolean not null default false,
    expires_at timestamp with time zone,
    created_at timestamp with time zone not null default now(),
    updated_at timestamp with time zone not null default now()
);

-- 2. Enable Row Level Security (RLS)
alter table public.subscriptions enable row level security;

-- 3. Add RLS select policy for owner
create policy "Users can select their own subscription"
on public.subscriptions
for select
using (auth.uid() = id);

-- 4. Migrate existing subscription data from profiles to subscriptions table
insert into public.subscriptions (id, is_premium, expires_at, created_at, updated_at)
select id, is_premium, null, created_at, updated_at
from public.profiles
on conflict (id) do update set
    is_premium = excluded.is_premium,
    updated_at = excluded.updated_at;

-- 5. Recreate dependent RLS policies referencing subscriptions table
-- Recreate Pages policy
drop policy if exists "Pages require auth" on public.pages;
create policy "Pages require auth" on public.pages
for select to authenticated
using (
    (exists (select 1 from public.books where books.id = pages.book_id and books.is_premium = false))
    or
    (exists (select 1 from public.subscriptions where subscriptions.id = auth.uid() and subscriptions.is_premium = true and (subscriptions.expires_at is null or subscriptions.expires_at > now())))
);

-- Recreate Page Translations policy
drop policy if exists "Page translations require auth" on public.page_translations;
create policy "Page translations require auth" on public.page_translations
for select to authenticated
using (
    (exists (select 1 from public.pages join public.books on books.id = pages.book_id where pages.id = page_translations.page_id and books.is_premium = false))
    or
    (exists (select 1 from public.subscriptions where subscriptions.id = auth.uid() and subscriptions.is_premium = true and (subscriptions.expires_at is null or subscriptions.expires_at > now())))
);

-- Recreate Book Audio policy
drop policy if exists "Audio requires auth" on public.book_audio;
create policy "Audio requires auth" on public.book_audio
for select to authenticated
using (
    (exists (select 1 from public.books where books.id = book_audio.book_id and books.is_premium = false))
    or
    (exists (select 1 from public.subscriptions where subscriptions.id = auth.uid() and subscriptions.is_premium = true and (subscriptions.expires_at is null or subscriptions.expires_at > now())))
);

-- 6. Drop trigger protecting subscription columns on profiles table
drop trigger if exists tr_protect_profile_columns on public.profiles;
drop function if exists public.protect_profile_columns();

-- 7. Remove subscription columns from profiles table
alter table public.profiles drop column if exists is_premium;
alter table public.profiles drop column if exists adapty_customer_user_id;

-- Create policy to allow authenticated users to select audio objects based on book premium status or subscription status
create policy "Allow select for audio objects" on storage.objects
  for select
  to authenticated
  using (
    bucket_id = 'audio'
    and (
      (
        split_part(name, '/', 1) ~* '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$'
        and exists (
          select 1 from public.books
          where books.id = (split_part(name, '/', 1))::uuid
            and books.is_premium = false
        )
      )
      or
      exists (
        select 1 from public.subscriptions
        where subscriptions.id = auth.uid()
          and subscriptions.is_premium = true
          and (subscriptions.expires_at is null or subscriptions.expires_at > now())
      )
    )
  );

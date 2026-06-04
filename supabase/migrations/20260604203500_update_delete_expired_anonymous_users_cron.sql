-- Update the security definer function to clean up anonymous accounts strictly based on created_at
create or replace function public.delete_expired_anonymous_users()
returns void
language plpgsql
security definer -- execute with privileges of the creator (postgres) to allow deleting from auth.users
as $$
begin
  delete from auth.users
  where is_anonymous = true
    and created_at < now() - interval '30 days';
end;
$$;

-- Ensure pg_cron extension is enabled
create extension if not exists pg_cron;

-- Create security definer function to clean up anonymous accounts
create or replace function public.delete_expired_anonymous_users()
returns void
language plpgsql
security definer -- execute with privileges of the creator (postgres) to allow deleting from auth.users
as $$
begin
  delete from auth.users
  where is_anonymous = true
    and coalesce(last_sign_in_at, created_at) < now() - interval '30 days';
end;
$$;

-- Schedule the cleanup job to run daily at 00:00 UTC
-- Unschedule first if it already exists to prevent duplicate entries
do $$
begin
  if exists (select 1 from cron.job where jobname = 'delete-expired-anonymous-users-job') then
    perform cron.unschedule('delete-expired-anonymous-users-job');
  end if;
end;
$$;

select cron.schedule(
  'delete-expired-anonymous-users-job',
  '0 0 * * *',
  'select public.delete_expired_anonymous_users();'
);

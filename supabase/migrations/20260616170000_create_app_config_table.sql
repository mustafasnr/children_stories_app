-- Create app_config table
create table public.app_config (
  key text primary key,
  value text not null
);

-- Insert default configurations
insert into public.app_config (key, value) values
  ('min_version', '1.0.0'),
  ('store_url', 'https://play.google.com/store/apps/details?id=com.senin.app');

-- Enable RLS
alter table public.app_config enable row level security;

-- Create policy to allow public select (read-only)
create policy "public read"
  on public.app_config for select
  using (true);

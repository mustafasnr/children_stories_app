-- Add latest version configurations for soft updates
insert into public.app_config (key, value) values
  ('latest_version_android', '1.0.7'),
  ('latest_version_ios', '1.0.7')
on conflict (key) do update set value = excluded.value;

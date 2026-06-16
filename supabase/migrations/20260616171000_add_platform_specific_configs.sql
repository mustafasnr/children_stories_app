-- Insert platform specific configurations
insert into public.app_config (key, value) values
  ('min_version_android', '1.0.0'),
  ('min_version_ios', '1.0.0'),
  ('store_url_android', 'https://play.google.com/store/apps/details?id=com.senin.app'),
  ('store_url_ios', 'https://apps.apple.com/us/app/children-stories/id1234567890')
on conflict (key) do update set value = excluded.value;

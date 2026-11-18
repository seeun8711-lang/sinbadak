-- 신바닥 웹: 관객이 올린 신바닥 (누끼 PNG) 저장. 승인한 것만 다른 사람에게 보임
create table if not exists public.soles (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  path text not null,               -- storage 'soles' 버킷 안 경로
  w int, h int,
  approved boolean not null default false
);
alter table public.soles enable row level security;
drop policy if exists "add unapproved sole" on public.soles;
create policy "add unapproved sole" on public.soles for insert to anon with check (approved = false);
drop policy if exists "see approved soles" on public.soles;
create policy "see approved soles" on public.soles for select to anon using (approved = true);
grant insert, select on public.soles to anon;

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('soles', 'soles', true, 3145728, array['image/png', 'image/webp'])
on conflict (id) do nothing;
drop policy if exists "upload sole image" on storage.objects;
create policy "upload sole image" on storage.objects for insert to anon
  with check (bucket_id = 'soles' and (storage.foldername(name))[1] = 'u');

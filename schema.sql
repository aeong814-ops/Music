-- hearthisong Supabase schema. Run this entire file in Supabase SQL Editor.
create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  nickname text not null default 'MUSIC LOVER',
  created_at timestamptz not null default now()
);

create table if not exists public.playlists (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  title text not null check (char_length(title) between 1 and 80),
  description text not null default '' check (char_length(description) <= 240),
  is_public boolean not null default true,
  cover_symbol text not null default '♫',
  cover_style integer not null default 0 check (cover_style between 0 and 5),
  created_at timestamptz not null default now()
);

create table if not exists public.tracks (
  id uuid primary key default gen_random_uuid(),
  playlist_id uuid not null references public.playlists(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  title text not null check (char_length(title) between 1 and 120),
  artist text not null default '' check (char_length(artist) <= 120),
  youtube_id text not null check (youtube_id ~ '^[A-Za-z0-9_-]{11}$'),
  youtube_url text not null,
  created_at timestamptz not null default now()
);

create table if not exists public.likes (
  id uuid primary key default gen_random_uuid(),
  playlist_id uuid not null references public.playlists(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  created_at timestamptz not null default now(),
  unique(playlist_id,user_id)
);

create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path = '' as $$
begin
  insert into public.profiles(id,nickname)
  values(new.id, coalesce(nullif(new.raw_user_meta_data->>'nickname',''), split_part(new.email,'@',1)))
  on conflict (id) do nothing;
  return new;
end;
$$;
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created after insert on auth.users
for each row execute procedure public.handle_new_user();

alter table public.profiles enable row level security;
alter table public.playlists enable row level security;
alter table public.tracks enable row level security;
alter table public.likes enable row level security;

-- Public profiles are visible so public playlists can show their creator.
drop policy if exists "profiles are viewable" on public.profiles;
create policy "profiles are viewable" on public.profiles for select using (true);
drop policy if exists "users update own profile" on public.profiles;
create policy "users update own profile" on public.profiles for update using (auth.uid() = id) with check (auth.uid() = id);

-- Public playlists can be discovered; private playlists are visible only to their owner.
drop policy if exists "read public or own playlists" on public.playlists;
create policy "read public or own playlists" on public.playlists for select using (is_public = true or auth.uid() = user_id);
drop policy if exists "create own playlists" on public.playlists;
create policy "create own playlists" on public.playlists for insert with check (auth.uid() = user_id);
drop policy if exists "update own playlists" on public.playlists;
create policy "update own playlists" on public.playlists for update using (auth.uid() = user_id) with check (auth.uid() = user_id);
drop policy if exists "delete own playlists" on public.playlists;
create policy "delete own playlists" on public.playlists for delete using (auth.uid() = user_id);

-- Tracks inherit visibility from their parent playlist; only the playlist owner can edit them.
drop policy if exists "read tracks for visible playlists" on public.tracks;
create policy "read tracks for visible playlists" on public.tracks for select using (exists(select 1 from public.playlists p where p.id = playlist_id and (p.is_public = true or p.user_id = auth.uid())));
drop policy if exists "add tracks to own playlists" on public.tracks;
create policy "add tracks to own playlists" on public.tracks for insert with check (auth.uid() = user_id and exists(select 1 from public.playlists p where p.id = playlist_id and p.user_id = auth.uid()));
drop policy if exists "delete tracks from own playlists" on public.tracks;
create policy "delete tracks from own playlists" on public.tracks for delete using (exists(select 1 from public.playlists p where p.id = playlist_id and p.user_id = auth.uid()));

-- Likes are visible on public playlists and can only be managed by their owner.
drop policy if exists "read likes" on public.likes;
create policy "read likes" on public.likes for select using (auth.uid() = user_id or exists(select 1 from public.playlists p where p.id = playlist_id and p.is_public = true));
drop policy if exists "create own likes" on public.likes;
create policy "create own likes" on public.likes for insert with check (auth.uid() = user_id and exists(select 1 from public.playlists p where p.id = playlist_id and p.is_public = true));
drop policy if exists "delete own likes" on public.likes;
create policy "delete own likes" on public.likes for delete using (auth.uid() = user_id);

create index if not exists playlists_user_created_idx on public.playlists(user_id,created_at desc);
create index if not exists playlists_public_created_idx on public.playlists(is_public,created_at desc);
create index if not exists tracks_playlist_created_idx on public.tracks(playlist_id,created_at);

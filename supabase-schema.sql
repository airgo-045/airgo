-- AIRGO database schema. Run in Supabase Dashboard > SQL Editor.
create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  email text,
  role text not null default 'owner' check (role in ('owner','admin')),
  created_at timestamptz not null default now()
);
alter table public.profiles enable row level security;
create policy "Users can read own profile" on public.profiles for select to authenticated using (auth.uid() = id);
create or replace function public.handle_new_user() returns trigger language plpgsql security definer set search_path=public as $$
begin insert into public.profiles(id,email,role) values(new.id,new.email,'owner') on conflict(id) do nothing; return new; end; $$;
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created after insert on auth.users for each row execute procedure public.handle_new_user();

create or replace function public.is_admin() returns boolean language sql stable security definer set search_path=public as $$
  select exists(select 1 from public.profiles where id=auth.uid() and role='admin');
$$;

create table if not exists public.businesses (
 id uuid primary key default gen_random_uuid(),
 name text not null,
 phone text not null,
 address text not null,
 latitude double precision not null check(latitude between -90 and 90),
 longitude double precision not null check(longitude between -180 and 180),
 services text[] not null default '{}',
 open_time time,
 close_time time,
 status text not null default 'pending' check(status in ('pending','approved','rejected','inactive')),
 rating_avg numeric(2,1) not null default 0,
 review_count integer not null default 0,
 created_at timestamptz not null default now()
);
alter table public.businesses enable row level security;
create policy "Anyone can view approved businesses" on public.businesses for select to anon, authenticated using(status='approved' or public.is_admin());
create policy "Admins can insert businesses" on public.businesses for insert to authenticated with check(public.is_admin());
create policy "Admins can update businesses" on public.businesses for update to authenticated using(public.is_admin()) with check(public.is_admin());
create policy "Admins can delete businesses" on public.businesses for delete to authenticated using(public.is_admin());

create table if not exists public.business_requests (
 id uuid primary key default gen_random_uuid(),
 owner_id uuid not null references auth.users(id) on delete cascade,
 business_name text not null,
 phone text not null,
 address text not null,
 services text[] not null default '{}',
 open_time time,
 close_time time,
 map_link text,
 latitude double precision,
 longitude double precision,
 owner_email text generated always as (null) stored,
 status text not null default 'pending' check(status in ('pending','approved','rejected')),
 created_at timestamptz not null default now()
);
alter table public.business_requests enable row level security;
create policy "Owners can submit requests" on public.business_requests for insert to authenticated with check(owner_id=auth.uid());
create policy "Owners can view own requests" on public.business_requests for select to authenticated using(owner_id=auth.uid() or public.is_admin());
create policy "Admins can manage requests" on public.business_requests for update to authenticated using(public.is_admin()) with check(public.is_admin());
create policy "Admins can read requests" on public.business_requests for select to authenticated using(public.is_admin());

create table if not exists public.reviews (
 id uuid primary key default gen_random_uuid(),
 business_id uuid not null references public.businesses(id) on delete cascade,
 rating integer not null check(rating between 1 and 5),
 comment text check(char_length(comment)<=500),
 created_at timestamptz not null default now()
);
alter table public.reviews enable row level security;
create policy "Anyone can read reviews" on public.reviews for select to anon, authenticated using(true);
-- MVP: public review submission. Add CAPTCHA/rate limiting before broad public launch.
create policy "Anyone can submit a review" on public.reviews for insert to anon, authenticated with check(true);

-- Create the first admin account by signing up through the app, then run:
-- update public.profiles set role='admin' where email='YOUR_ADMIN_EMAIL';
-- IMPORTANT: Keep this admin email private. Never expose the Supabase service_role key in browser code.

-- ============================================================
-- GANGBOX — Supabase setup
-- Run this once in your project's SQL Editor (Supabase dashboard
-- → SQL Editor → New query → paste → Run).
-- ============================================================

create extension if not exists "pgcrypto";

-- ---------- tables ----------
create table if not exists employees (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  trade text,
  created_at timestamptz default now()
);

create table if not exists sites (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  customer text,
  address text,
  type text,
  bill_rate numeric default 0,
  created_at timestamptz default now()
);

create table if not exists tasks (
  id uuid primary key default gen_random_uuid(),
  label text unique not null,
  created_at timestamptz default now()
);

create table if not exists entries (
  id uuid primary key default gen_random_uuid(),
  employee_id uuid references employees(id) on delete cascade,
  site_id uuid references sites(id) on delete set null,
  clock_in timestamptz not null,
  clock_out timestamptz,
  lat double precision,
  lng double precision,
  task text,
  created_at timestamptz default now()
);

create table if not exists edits (
  id uuid primary key default gen_random_uuid(),
  entry_id uuid,
  employee_id uuid,
  employee_name text,
  action text not null,          -- 'created' | 'edited' | 'deleted'
  field text,                    -- 'clock_in' | 'clock_out' | 'task' | 'site'
  old_value text,
  new_value text,
  note text,
  changed_at timestamptz default now()
);

create table if not exists settings (
  id int primary key default 1,
  manager_pin text,
  company_name text,
  constraint settings_singleton check (id = 1)
);

-- starting manager PIN (CHANGE THIS, or change it later inside the app)
insert into settings (id, manager_pin) values (1, '1234')
  on conflict (id) do nothing;

-- default task list (managers can add more in the app)
insert into tasks (label) values
  ('Framing'), ('Drywall / Hang'), ('Trim & Finish'), ('Demo'),
  ('Foundation / Concrete'), ('Roofing'), ('Decking'),
  ('Site Prep / Cleanup'), ('Punch List'), ('Material Pickup')
on conflict (label) do nothing;

-- ---------- access ----------
grant usage on schema public to anon;
grant all on all tables in schema public to anon;

alter table employees enable row level security;
alter table sites     enable row level security;
alter table tasks     enable row level security;
alter table entries   enable row level security;
alter table settings  enable row level security;
alter table edits     enable row level security;

-- Permissive policies: the field app authenticates with the public anon key,
-- so anyone with the app's link can read/write. That's the normal trade-off
-- for a small-crew time clock (like an unlocked punch clock at the shop).
-- To require real logins instead, see "Locking it down" in the README.
drop policy if exists "anon all employees" on employees;
drop policy if exists "anon all sites" on sites;
drop policy if exists "anon all tasks" on tasks;
drop policy if exists "anon all entries" on entries;
drop policy if exists "anon read settings" on settings;
drop policy if exists "anon write settings" on settings;
drop policy if exists "anon all edits" on edits;

create policy "anon all employees" on employees for all to anon using (true) with check (true);
create policy "anon all sites"     on sites     for all to anon using (true) with check (true);
create policy "anon all tasks"     on tasks     for all to anon using (true) with check (true);
create policy "anon all entries"   on entries   for all to anon using (true) with check (true);
create policy "anon read settings" on settings  for select to anon using (true);
create policy "anon write settings" on settings for update to anon using (true) with check (true);
create policy "anon all edits"     on edits     for all to anon using (true) with check (true);

-- ---------- realtime (live updates across phones) ----------
do $$
begin
  begin
    alter publication supabase_realtime add table employees, sites, tasks, entries, settings, edits;
  exception when duplicate_object then null;
  end;
end $$;

-- Done. Put your Project URL + anon key into config.js and deploy.

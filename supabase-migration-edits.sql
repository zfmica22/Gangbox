-- ============================================================
-- GANGBOX — migration: add the time-card audit log
-- Run this ONLY if you already set up an earlier version and
-- don't want to re-run the full supabase-setup.sql.
-- (Safe to run more than once.)
-- ============================================================

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

grant all on edits to anon;
alter table edits enable row level security;
drop policy if exists "anon all edits" on edits;
create policy "anon all edits" on edits for all to anon using (true) with check (true);

do $$
begin
  begin
    alter publication supabase_realtime add table edits;
  exception when duplicate_object then null;
  end;
end $$;

-- Correctly locked-down generic fixture; not CityHaus schema.
create table public.fixture_notes (id uuid primary key default gen_random_uuid(), owner_id uuid not null, body text not null);
alter table public.fixture_notes enable row level security;
revoke all on public.fixture_notes from anon, authenticated;
grant select, insert, update on public.fixture_notes to authenticated;
create policy notes_select_own on public.fixture_notes for select to authenticated using (owner_id = (select auth.uid()));
create policy notes_insert_own on public.fixture_notes for insert to authenticated with check (owner_id = (select auth.uid()));
create policy notes_update_own on public.fixture_notes for update to authenticated using (owner_id = (select auth.uid())) with check (owner_id = (select auth.uid()));
create table public.fixture_public_items (id uuid primary key default gen_random_uuid(), is_public boolean not null default false, label text not null);
alter table public.fixture_public_items enable row level security;
revoke all on public.fixture_public_items from anon, authenticated;
grant select on public.fixture_public_items to anon, authenticated;
create policy items_select_public on public.fixture_public_items for select to anon, authenticated using (is_public);
create view public.fixture_items_view with (security_invoker = true) as select id, label from public.fixture_public_items;
revoke all on public.fixture_items_view from anon, authenticated;
grant select on public.fixture_items_view to anon, authenticated;

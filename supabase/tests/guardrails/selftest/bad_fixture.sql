-- Deliberately insecure generic fixtures used only to test guardrail detection.
create table public.fixture_no_rls (id int primary key);
create table public.fixture_rls (id int primary key, owner uuid);
alter table public.fixture_rls enable row level security;
create policy implicit_public on public.fixture_rls for select using (true);
create policy upd_no_check on public.fixture_rls for update to authenticated using (owner = auth.uid());
create policy open_write on public.fixture_rls for delete to authenticated using (true);
create policy meta_based on public.fixture_rls for select to authenticated using ((auth.jwt() -> 'user_metadata' ->> 'role') = 'admin');
create function public.fixture_definer() returns int language sql security definer as $$ select 1 $$;
create view public.fixture_view as select * from public.fixture_rls;
create materialized view public.fixture_matview as select 1 as x;

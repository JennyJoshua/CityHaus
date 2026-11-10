-- Exercises identity switching against generic fixture tables; not CityHaus tests.
\set ON_ERROR_STOP on
begin;
insert into public.fixture_notes (owner_id,body) values
('aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa','a1'),
('aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa','a2'),
('bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb','b1');
insert into public.fixture_public_items (is_public,label) values (true,'shown'),(false,'hidden');
select test_helpers.as_anon();
select test_helpers.assert_eq('H01 anon uid is null',(select count(*) from (select auth.uid() u) x where u is null),1);
select test_helpers.assert_denied('H02 anon cannot read private table','select * from public.fixture_notes');
select test_helpers.assert_eq('H03 anon sees only public items',(select count(*) from public.fixture_public_items),1);
select test_helpers.assert_denied('H04 anon cannot write public items','update public.fixture_public_items set label = ''x''');
select test_helpers.assert_eq('H05 anon sees public view rows only',(select count(*) from public.fixture_items_view),1);
select test_helpers.as_superuser();
select test_helpers.as_authenticated(test_helpers.provider_a_id());
select test_helpers.assert_eq('H06 A uid matches',(select count(*) from (select auth.uid() u) x where u = test_helpers.provider_a_id()),1);
select test_helpers.assert_eq('H07 A sees own rows',(select count(*) from public.fixture_notes),2);
select test_helpers.assert_eq('H08 A sees none of B rows',(select count(*) from public.fixture_notes where owner_id = test_helpers.provider_b_id()),0);
select test_helpers.assert_denied('H09 A cannot insert row owned by B',format('insert into public.fixture_notes(owner_id,body) values (%L,''x'')',test_helpers.provider_b_id()));
select test_helpers.assert_denied('H10 A cannot reassign own row to B',format('update public.fixture_notes set owner_id = %L where body = ''a1''',test_helpers.provider_b_id()));
do $$ declare n int; begin update public.fixture_notes set body='hacked' where body='b1'; get diagnostics n = row_count; perform test_helpers.assert_eq('H11 A update of B row affects 0 rows',n,0); end $$;
select test_helpers.assert_denied('H12 A cannot delete','delete from public.fixture_notes');
select test_helpers.as_superuser();
select test_helpers.as_authenticated(test_helpers.provider_b_id());
select test_helpers.assert_eq('H14 B sees own rows',(select count(*) from public.fixture_notes),1);
select test_helpers.assert_eq('H15 B sees none of A rows',(select count(*) from public.fixture_notes where owner_id = test_helpers.provider_a_id()),0);
select test_helpers.as_superuser();
rollback;

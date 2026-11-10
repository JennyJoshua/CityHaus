-- Test-only helpers for switching between access identities inside a
-- transaction. Apply AFTER bootstrap and migrations. Never apply to a hosted DB.
--
-- Identities: anonymous visitor, Provider A, Provider B.
-- The ADMINISTRATOR identity is intentionally NOT implemented: the trusted,
-- server-controlled admin mechanism is an unresolved owner decision.

create schema if not exists test_helpers;
grant usage on schema test_helpers to anon, authenticated;

create function test_helpers.provider_a_id() returns uuid language sql immutable
  as $$ select 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa'::uuid $$;
create function test_helpers.provider_b_id() returns uuid language sql immutable
  as $$ select 'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb'::uuid $$;

create function test_helpers.as_anon() returns void language plpgsql as $$
begin
  perform set_config('request.jwt.claims', '', true);
  execute 'set local role anon';
end $$;

create function test_helpers.as_authenticated(uid uuid) returns void language plpgsql as $$
begin
  perform set_config('request.jwt.claims',
    json_build_object('sub', uid, 'role', 'authenticated')::text, true);
  execute 'set local role authenticated';
end $$;

create function test_helpers.as_superuser() returns void language plpgsql as $$
begin
  execute 'reset role';
  perform set_config('request.jwt.claims', '', true);
end $$;

create function test_helpers.assert_eq(label text, actual bigint, expected bigint)
returns void language plpgsql as $$
begin
  if actual is distinct from expected then
    raise exception 'FAIL: % (expected %, got %)', label, expected, actual;
  end if;
  raise notice 'PASS: %', label;
end $$;

create function test_helpers.assert_denied(label text, sql text)
returns void language plpgsql as $$
begin
  begin
    execute sql;
  exception when insufficient_privilege then
    raise notice 'PASS: % (denied)', label;
    return;
  end;
  raise exception 'FAIL: % (statement was allowed)', label;
end $$;

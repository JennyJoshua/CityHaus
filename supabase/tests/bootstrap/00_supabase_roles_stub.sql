-- TEST-ONLY BOOTSTRAP. NOT A MIGRATION. NEVER APPLY TO A HOSTED PROJECT.
-- Approximation of Supabase roles/auth objects for plain local PostgreSQL.
create role anon nologin noinherit;
create role authenticated nologin noinherit;
create role service_role nologin noinherit bypassrls;
create role authenticator login noinherit password null;
grant anon, authenticated, service_role to authenticator;

create schema if not exists extensions;
create schema if not exists auth;
create table auth.users (
  id uuid primary key default gen_random_uuid(),
  email text,
  raw_app_meta_data jsonb not null default '{}'::jsonb,
  raw_user_meta_data jsonb not null default '{}'::jsonb
);
create function auth.jwt() returns jsonb language sql stable as $$
  select coalesce(nullif(current_setting('request.jwt.claim',true),''),
                  nullif(current_setting('request.jwt.claims',true),''))::jsonb
$$;
create function auth.uid() returns uuid language sql stable as $$
  select nullif(coalesce(current_setting('request.jwt.claim.sub',true),
    (nullif(current_setting('request.jwt.claims',true),'')::jsonb ->> 'sub')),'')::uuid
$$;
create function auth.role() returns text language sql stable as $$
  select coalesce(current_setting('request.jwt.claim.role',true),
    (nullif(current_setting('request.jwt.claims',true),'')::jsonb ->> 'role'))::text
$$;
grant usage on schema public, auth, extensions to anon, authenticated, service_role;
grant execute on function auth.jwt(), auth.uid(), auth.role() to anon, authenticated, service_role;
alter default privileges in schema public grant all on tables to anon, authenticated, service_role;
alter default privileges in schema public grant all on sequences to anon, authenticated, service_role;
alter default privileges in schema public grant all on functions to anon, authenticated, service_role;

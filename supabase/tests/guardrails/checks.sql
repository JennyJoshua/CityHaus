-- Schema-agnostic security guardrails for objects in the exposed public schema.
-- Each returned row is a violation. An empty schema passes vacuously.
-- CHECK G01: RLS on every public table
-- CHECK G02: explicit policy roles
-- CHECK G03: UPDATE/ALL policies have USING and WITH CHECK
-- CHECK G04: no SECURITY DEFINER functions in public
-- CHECK G05: views use security_invoker=true; no materialized/foreign tables
-- CHECK G06: API roles lack TRUNCATE/REFERENCES/TRIGGER
-- CHECK G07: anon lacks UPDATE/DELETE
-- CHECK G08: no unconditional true write policies
-- CHECK G09: no user-editable metadata authorization
-- CHECK G10: no anon-executable RPC functions
with rel as (
  select c.oid, c.relname, c.relkind, c.relrowsecurity, c.reloptions
  from pg_class c join pg_namespace n on n.oid = c.relnamespace
  where n.nspname = 'public' and c.relkind in ('r','p','v','m','f')
    and not exists (select 1 from pg_depend d where d.objid = c.oid and d.deptype = 'e')
),
fn as (
  select p.oid, p.proname, p.prosecdef, p.prorettype
  from pg_proc p join pg_namespace n on n.oid = p.pronamespace
  where n.nspname = 'public' and p.prokind in ('f','p')
    and not exists (select 1 from pg_depend d where d.objid = p.oid and d.deptype = 'e')
),
pol as (select * from pg_policies where schemaname = 'public')
select check_id, object, detail from (
  select 'G01' check_id, relname::text object, 'RLS is not enabled' detail
    from rel where relkind in ('r','p') and not relrowsecurity
  union all
  select 'G02', tablename || '.' || policyname, 'policy applies to PUBLIC; name explicit roles'
    from pol where roles = '{public}'::name[]
  union all
  select 'G03', tablename || '.' || policyname, cmd || ' policy missing USING or WITH CHECK'
    from pol where cmd in ('UPDATE','ALL') and (qual is null or with_check is null)
  union all
  select 'G04', proname::text, 'SECURITY DEFINER function in exposed schema'
    from fn where prosecdef
  union all
  select 'G05', relname::text, 'view without security_invoker=true'
    from rel where relkind = 'v' and not coalesce(reloptions @> array['security_invoker=true'], false)
  union all
  select 'G05', relname::text, 'materialized/foreign table exposed (cannot enforce RLS)'
    from rel where relkind in ('m','f')
  union all
  select 'G06', r.relname || ' -> ' || role, 'holds TRUNCATE/REFERENCES/TRIGGER'
    from rel r cross join (values ('anon'),('authenticated')) roles(role)
    where r.relkind in ('r','p') and
      (has_table_privilege(role,r.oid,'TRUNCATE') or has_table_privilege(role,r.oid,'REFERENCES') or has_table_privilege(role,r.oid,'TRIGGER'))
  union all
  select 'G07', relname::text, 'anon holds UPDATE or DELETE'
    from rel where relkind in ('r','p','v') and
      (has_table_privilege('anon',oid,'UPDATE') or has_table_privilege('anon',oid,'DELETE'))
  union all
  select 'G08', tablename || '.' || policyname, cmd || ' policy is unconditional true'
    from pol where cmd in ('INSERT','UPDATE','DELETE','ALL') and
      (btrim(coalesce(qual,'')) = 'true' or btrim(coalesce(with_check,'')) = 'true')
  union all
  select 'G09', tablename || '.' || policyname, 'policy references user-editable metadata'
    from pol where (coalesce(qual,'') || ' ' || coalesce(with_check,'')) ~* '(user_metadata|raw_user_meta_data)'
  union all
  select 'G10', proname::text, 'function executable by anon (callable via RPC)'
    from fn where prorettype <> 'trigger'::regtype and has_function_privilege('anon',oid,'EXECUTE')
) v order by 1,2,3;

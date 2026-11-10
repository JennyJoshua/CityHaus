# Setup, conventions and validation

## Migration conventions

- Location: `supabase/migrations/`; one forward-only SQL file per change.
- Name: `YYYYMMDDHHMMSS_short_snake_case.sql` (14-digit UTC timestamp, unique, lowercase). Enforced by M01.
- Never edit a migration after it is merged; add a new one.
- Every new table: enable RLS, revoke default API-role grants, then add explicit minimal grants and policies (`TO anon` / `TO authenticated`; UPDATE with USING and WITH CHECK).
- No data seeding in migrations; `supabase/seed.sql` is empty.
- Suggested ordering (confirm after the spec): extensions/helpers → lookup tables → profiles → providers → properties and children → enquiries/verification/reports/audit → policies and grants → storage.

## Layout added by Claude's package

```
supabase/config.toml
supabase/migrations/       (empty, .gitkeep only)
supabase/seed.sql          (empty)
supabase/.gitignore
supabase/tests/            (bootstrap, helpers, guardrails, runners)
docs/phase1/               (assessment, register, matrix, tests, setup)
```

## What you can run now (plain local PostgreSQL ≥ 15, disposable server only)

```bash
export PGHOST=localhost PGUSER=postgres
bash supabase/tests/run-selftests.sh
bash supabase/tests/run-guardrails.sh
```

The runners create throw-away databases and cluster-wide test roles. Never point them at a hosted project. With zero migrations, `run-guardrails.sh` reports that its checks were vacuous.

## When Docker is available (preferred, not yet run)

```bash
npx supabase start
npx supabase db reset
npx supabase test db
```

`supabase link`, `db push` and any hosted-project command are out of scope for Phase 1.

## Completed vs pending

Completed: structure, conventions, assessment, decision register, matrix template, requirements, guardrails, harness, runners. Pending/blocked: migrations, policies, grants, storage, behavioural tests, admin tests.

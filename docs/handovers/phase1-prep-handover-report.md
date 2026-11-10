# CityHaus Phase 1 — preparation handover report

Issue #1 · branch `phase1/supabase-db-foundation` (base `3b53eaa`) · scope: spec-independent work only, as authorised by the owner.

## Summary

The Database and Backend Specification v1.0 was not available, so **no migrations, tables, policies or grants were written**. This package contains the repository structure, documentation, decision register, RLS matrix template, and a security-test harness that does not depend on schema details.

## Files included in Claude's ZIP

```
docs/handovers/phase1-prep-handover-report.md
docs/phase1/README.md
docs/phase1/repository-assessment.md
docs/phase1/schema-decision-register.md
docs/phase1/security-requirements.md
docs/phase1/rls-policy-matrix.md
docs/phase1/test-strategy.md
docs/phase1/setup-and-validation.md
supabase/.gitignore
supabase/config.toml
supabase/seed.sql
supabase/migrations/.gitkeep
supabase/tests/run-selftests.sh
supabase/tests/run-guardrails.sh
supabase/tests/bootstrap/00_supabase_roles_stub.sql
supabase/tests/helpers/identity_helpers.sql
supabase/tests/guardrails/checks.sql
supabase/tests/guardrails/selftest/bad_fixture.sql
supabase/tests/guardrails/selftest/good_fixture.sql
supabase/tests/guardrails/selftest/identity_harness_selftest.sql
```

## Environment and what was actually executed

- PostgreSQL 16.15 installed and run locally (disposable). Supabase CLI 3.0.0 obtained via npm and used only for `supabase init`. **Docker is not available**, so the Supabase local stack, `supabase db reset` and `supabase test db` were **not run**. pgTAP was not used.
- `config.toml` declares Postgres major 17; tests ran on 16.15.

| Run | Result |
|---|---|
| `run-selftests.sh` — all 10 guardrails (G01–G10) detect deliberately insecure fixtures | 10/10 detected |
| `run-selftests.sh` — compliant fixture yields zero violations | passed |
| `run-selftests.sh` — identity harness (anon, Provider A, Provider B) on **generic fixtures** | 16/16 passed |
| `run-guardrails.sh` — M01 naming, M02 clean apply, G01–G10, M03 determinism | passed, **vacuously: 0 migrations** |

These results demonstrate the test harness works. They are **not** evidence that CityHaus is secure: no CityHaus tables, policies or administrator tests exist or ran. Provider A vs Provider B isolation was demonstrated only on fixture tables.

## Not done / blocked

- Migrations for the 11 tables, constraints, indexes, RLS, grants, storage policies.
- Behavioural tests for anon / Provider A / Provider B / administrator (register in `docs/phase1/test-strategy.md`; admin identity needs D-ADMIN-01).
- Security/performance advisors (no test project provided).
- **Commit, push and pull request**: Claude's environment has no GitHub credentials. Owner is adding this work to the branch; PR not opened.

## Needed from the owner

1. Database and Backend Specification v1.0 (or answers to `schema-decision-register.md`).
2. Decisions on admin mechanism (D-ADMIN-01), public provider fields (D-PUBLIC-01), moderation states (D-PROP-01), auth method/SMS cost (D-AUTH-01), config review (D-CONFIG-01).

## Boundary confirmation

No hosted Supabase project was created, selected or contacted; no migration applied remotely; no deployment; `main` untouched; no app code changed; no paid service introduced. Findings about existing app issues (missing `expo-image-picker` dependency, README/structure mismatch) are reported only.

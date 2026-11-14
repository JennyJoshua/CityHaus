# CityHaus Phase 1 — Supabase Database Foundation (preparation package)

Issue: #1 · Branch: `phase1/supabase-db-foundation` · Baseline: Database and Backend Specification v1.0 (**not available to the implementer**)

## Status at a glance

| Area | Status |
|---|---|
| Repository assessment | Done — `repository-assessment.md` |
| Supabase directory + migration conventions | Done (no migrations yet) |
| Schema decision register | Done — **needs owner answers** |
| RLS policy matrix | Template only — blocked on decisions |
| Security requirements | Done (known requirements only) |
| Schema-agnostic security guardrails + harness | Done and executed locally |
| Migrations for the 11 tables | **BLOCKED** — spec missing |
| RLS policies, grants, storage policies | **BLOCKED** — spec missing |
| Real CityHaus security tests (anon / A / B / admin) | **BLOCKED** — need schema |
| Real Supabase local stack run, advisors | **NOT RUN** — no Docker; no test project provided |
| Pull request | **NOT OPENED** — no GitHub credentials in the implementation environment |

## Documents

- `repository-assessment.md` — what exists in the repo and compatibility notes
- `schema-decision-register.md` — missing columns/types/constraints/decisions
- `security-requirements.md` — requirements stated in the handover and Issue #1
- `rls-policy-matrix.md` — matrix template (anon, Provider A, Provider B, admin)
- `test-strategy.md` — strategy, test-case register, what is executable now
- `setup-and-validation.md` — migration conventions, how to run what exists

## Rule for this phase

No column, status value, moderation workflow, reservation structure, policy or grant has been invented. Anything not stated in the handover or Issue #1 is listed as UNDECIDED in the decision register.

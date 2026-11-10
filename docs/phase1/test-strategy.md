# Test strategy and test-case register

## Identities

| Identity | Mechanism in tests |
|---|---|
| Anonymous visitor | `test_helpers.as_anon()` → `SET LOCAL ROLE anon`, no JWT claims |
| Provider A / Provider B | `test_helpers.as_authenticated(provider_a_id() / provider_b_id())` → role `authenticated`, JWT `sub` set |
| Administrator | **Not implemented** — blocked on D-ADMIN-01. Do not guess a claim or table |

Tests run in a transaction as a superuser and switch role with `SET LOCAL ROLE` so they exercise grants and RLS as the API roles would. Because the session is a superuser, `SET ROLE` escalation can't be tested this way; a real API connection uses the non-superuser `authenticator`.

## Layers

1. **Structural** (runs now): migration naming/order/clean apply/determinism (M01–M03); guardrails G01–G10.
2. **Harness self-test** (runs now): generic fixtures prove each guardrail detects violations, compliant SQL passes, and identity switching isolates rows.
3. **CityHaus behavioural** (blocked): once schema, policies and admin mechanism exist. Preferred home: pgTAP files under `supabase/tests/database/` run with `supabase test db` on the local stack.
4. **Advisors / storage** (not run): Supabase security and performance advisors only if the owner explicitly provides a test project; storage policy tests need the local stack.

## Test-case register

| ID | Identity | Expectation | Status |
|---|---|---|---|
| ST-01..03 | – | Migration names valid/ordered; clean apply; deterministic | EXECUTED (vacuous: 0 migrations) |
| ST-04..13 | – | Guardrails G01–G10 | EXECUTED (vacuous on empty schema; fixtures prove detection) |
| H01–H16 | anon / A / B | Harness isolation mechanics on generic fixtures | EXECUTED (16 pass) |
| T-ANON-01..07 | Anon | Public reads, enquiry insert only, no private data/writes | BLOCKED / NOT RUN |
| T-A-01..07 | Provider A | Own-row access; cannot alter ownership/moderation/verification; no access to B | BLOCKED |
| T-B-01 | Provider B | Mirror cross-provider isolation checks | BLOCKED |
| T-ADM-01..03 | Admin | Review/approve, reject forged user_metadata admin, audit actions | BLOCKED (D-ADMIN-01) |
| T-STO-01 | all | Property image bucket policies; verification bucket private | NOT RUN |


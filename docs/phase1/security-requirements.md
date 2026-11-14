# Known security requirements

Drawn from the Phase 1 handover and Issue #1. "Guardrail" names the executed schema-agnostic check, where one exists (`supabase/tests/guardrails/checks.sql`).

| # | Requirement | Automated guardrail |
|---|---|---|
| S1 | RLS enabled on every table in exposed schemas | G01 |
| S2 | Explicit `TO anon` / `TO authenticated` on policies; ownership predicates | G02 (roles); ownership needs real schema |
| S3 | UPDATE policies have both USING and WITH CHECK | G03 |
| S4 | Avoid SECURITY DEFINER; if needed: non-exposed schema, restricted EXECUTE, caller validated, documented | G04 |
| S5 | Views use `security_invoker = true` | G05 |
| S6 | Explicit grants, least privilege (no TRUNCATE/REFERENCES/TRIGGER to API roles; anon cannot UPDATE/DELETE) | G06, G07 |
| S7 | Never authorise from `user_metadata` | G09 |
| S8 | Admin authority from trusted server-controlled source | Needs D-ADMIN-01 |
| S9 | No service-role/secret key in client code | App out of scope |
| S10 | Public sees only approved, active listings; not draft/rejected/suspended/archived | Needs schema |
| S11 | Providers cannot change ownership, moderation status or verification status | Needs schema |
| S12 | Cross-provider reads and writes denied | Needs schema |
| S13 | Verification records and documents private (table and storage) | Needs schema + storage |
| S14 | Anonymous may submit enquiries only; enquiry ≠ payment or booking | Needs schema |
| S15 | Migrations ordered, deterministic, clean-apply | M01–M03 |

Guardrail notes: G08 flags unconditional `true` write policies and G10 flags RPC-callable functions for `anon`. Any deliberate exception must be documented and reviewed.

## Unresolved authorization decisions

D-ADMIN-01, D-PUBLIC-01, D-PROP-01/02, D-ENQ-01/02, D-VER-01, D-REP-01, D-AUD-01, D-STO-01 (see the decision register).

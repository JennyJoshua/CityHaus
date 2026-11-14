# CityHaus Phase 1 — Specification Reconciliation Report

**Date:** 2026-11-10  
**Branch:** `phase1/supabase-db-foundation`  
**Related PR:** #2  
**Related issue:** #1  
**Purpose:** Reconcile the current Phase 1 preparation documents against the owner-approved Database and Backend Specification v1.0 before any schema, RLS, grant, or storage implementation.

## 1. Executive result

**Status: BLOCKED — the exact approved Specification v1.0 text is not present in the repository, Issue #1, or the accessible project records reviewed for this reconciliation.**

The project record confirms that the owner approved Database Specification v1.0 as the technical baseline and authorized Phase 1. It also explicitly says not to infer missing security-sensitive details. However, the full specification—including exact table columns, data types, nullability, defaults, constraints, relationships, indexes, status workflows, storage policies, and detailed authorization rules—was not available to the implementer.

This report therefore does not reconstruct or replace Specification v1.0. It separates confirmed requirements from assumptions and unresolved details.

## 2. Sources reviewed

1. `docs/handovers/phase1-supabase-db-foundation.md`
2. `docs/phase1/README.md`
3. `docs/phase1/schema-decision-register.md`
4. `docs/phase1/security-requirements.md`
5. `docs/phase1/rls-policy-matrix.md`
6. `docs/phase1/test-strategy.md`
7. GitHub Issue #1: Phase 1: Implement Supabase database foundation
8. Project history confirming owner approval of Database Specification v1.0 and the instruction not to infer missing security-sensitive details.

The preparation documents and Issue #1 consistently identify Specification v1.0 as the baseline but do not contain its full schema definitions.

## 3. Confirmed requirements that can be carried forward

The following are established in the handover and/or Issue #1 and can be retained without inventing schema details:

### Product and scope
- Public guests browse and search without accounts.
- Registration is for individual providers and business providers; there is no buyer/guest account role.
- Reservation requests are enquiries, not confirmed bookings or payments.
- No integrated payments in this phase.
- Currency is PGK initially.
- Implement repository-side database foundation only; do not add Expo app-side Supabase integration in this phase.
- Required core tables:
  1. `profiles`
  2. `provider_profiles`
  3. `locations`
  4. `properties`
  5. `property_images`
  6. `amenities`
  7. `property_amenities`
  8. `reservation_requests`
  9. `verification_records`
  10. `reports`
  11. `admin_audit_logs`

### Access and security
- Public users may read only approved, active public property information and deliberately public provider information.
- Providers may manage only their own permitted profiles, properties, images, and enquiries.
- Providers must not approve their own listings or verification.
- Verification records and documents must remain private.
- Administrator authority must come from trusted server-controlled authorization, never user-editable `user_metadata`.
- RLS must be enabled on every application table in exposed schemas.
- Use explicit least-privilege grants and policies.
- Never expose service-role or secret keys in client code.
- Cross-provider reads and writes must be denied.
- Reservation enquiries must not imply payment or a guaranteed booking.

## 4. Preparation-document findings

| Area | Current preparation state | Reconciliation result |
|---|---|---|
| Table inventory | 11 approved table names recorded | Confirmed at table-name level only |
| Columns and data types | Not defined | Blocked on exact specification |
| Primary and foreign keys | Several relationships marked implied | Must not implement implied relationships as approved facts |
| Nullability/defaults/checks | Not defined | Blocked |
| Indexes | Not defined | Blocked except routine indexes justified by the exact schema/spec |
| Property moderation workflow | Public approved+active requirement known; full states/transitions absent | Blocked |
| Provider profile visibility | Only deliberately public fields may be exposed | Exact fields absent |
| Reservation request model | Anonymous enquiry capability known | Fields, status, retention, guest read-back, spam controls absent |
| Verification | Must be private; providers cannot approve themselves | Record model, review workflow, retention, provider visibility absent |
| Reports | Table name known | Reportable target, reporter identity/privacy, reasons and workflow absent |
| Admin audit logs | Table name known | Event model, append-only enforcement, reader/writer permissions absent |
| Administrator authorization | Must be trusted/server-controlled | Exact mechanism absent |
| Storage | Property images and private verification documents required | Bucket names, limits, paths, MIME types and exact policies absent |
| Automated tests | Generic harness exists | CityHaus behavioural tests remain unimplemented |

## 5. Decisions that must not be guessed

The following are implementation blockers unless they are explicitly defined in the original approved specification:

- Exact columns, PostgreSQL types, nullability, defaults and uniqueness for all 11 tables.
- Primary-key strategy and all foreign-key relationships, including delete/update behaviour.
- Property and verification status values and permitted transitions.
- Whether approval and active publication are represented separately.
- Exact public provider fields and public property projection.
- Which fields a provider may edit after a listing has been submitted or approved.
- Reservation enquiry fields, guest data handling, status transitions, provider responses, guest read-back, rate limiting/spam protection and retention.
- Verification evidence fields, reviewer identity, provider visibility, retention and document access.
- Report targets, reporter identity/privacy, reasons, moderation status and visibility.
- Audit event fields, append-only guarantees and authorized readers.
- Trusted administrator authorization mechanism.
- Storage bucket names, public/private configuration, file limits, MIME types, path conventions and policies.
- Any required Postgres extensions or external services.

## 6. Technical review items already identified

These are preparation-environment/configuration questions, not product-schema decisions:

1. The committed Supabase config declares PostgreSQL major version 17, while the preparation handover reports local guardrail testing on PostgreSQL 16.15. Reconcile before claiming local-stack compatibility.
2. The local config has development Auth defaults (including email confirmation disabled and a minimum password setting of 6). These are not production recommendations and must not be copied into a hosted project without review.
3. Generic SQL harness tests and vacuous checks against zero CityHaus migrations do not demonstrate CityHaus schema or RLS security.
4. No hosted Supabase project has been selected or modified, and no remote migration has been applied.

## 7. Required next input

Before schema implementation can safely proceed, the implementation team needs the **complete approved Database and Backend Specification v1.0**, including any appendices or amendments covering:

- Full table definitions and relationships.
- Role and permission matrix.
- Listing and verification workflows.
- Reservation enquiry workflow.
- Public/private field classification.
- Storage requirements and policies.
- Administrator authorization.
- Acceptance criteria.

The original specification should be supplied or made accessible as-is. It should not be replaced by this reconciliation report or re-created from table names and high-level summaries.

## 8. Implementation gate

Until the exact approved specification is available and reconciled:

- Do not create CityHaus schema migrations.
- Do not write CityHaus RLS policies or grants.
- Do not create storage policies based on guessed bucket names or paths.
- Do not invent status enums, workflows, columns or authorization claims.
- Continue only with non-speculative documentation and tooling corrections that do not alter product or security behavior.

Once the specification is available, update the decision register and RLS matrix against it, resolve any genuine conflicts with the owner, then proceed with migrations and tests on `phase1/supabase-db-foundation`.

## 9. Safety confirmation

This reconciliation did not create or select a hosted Supabase project, connect to a live database, apply migrations, deploy, merge, or modify `main`.

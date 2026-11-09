# CityHaus Phase 1 — Supabase Database Foundation

**Status:** Authorized for implementation  
**Baseline:** CityHaus Database Specification v1.0  
**Target repository:** `JennyJoshua/CityHaus`  
**Working branch:** `phase1/supabase-db-foundation`  
**Target base:** `main`

## Owner-approved scope

Implement the database foundation only. Do not integrate Supabase into the Expo application in this phase.

### Deliverables

1. Supabase project configuration and ordered SQL migrations.
2. Core schema:
   - `profiles`
   - `provider_profiles`
   - `locations`
   - `properties`
   - `property_images`
   - `amenities`
   - `property_amenities`
   - `reservation_requests`
   - `verification_records`
   - `reports`
   - `admin_audit_logs`
3. Foreign keys, uniqueness, check constraints, indexes and timestamp handling.
4. RLS enabled on every application table in exposed schemas.
5. Explicit grants and least-privilege RLS policies.
6. Tests covering anonymous access, provider A, provider B and administrator access.
7. Storage configuration/policies for property images and private verification documents.
8. Setup, migration and test documentation.

## Product rules

- Public guests browse without accounts.
- Only individual and business providers register.
- Public users see only approved, active property listings and deliberately public provider fields.
- Providers manage only their own profile, properties, images and enquiries.
- Providers cannot approve their own listings or verification.
- Guest reservation enquiries do not imply payment or a guaranteed booking.
- Currency is PGK initially.
- Administrator authority must be assigned through a trusted server-controlled mechanism.

## Security requirements

- Never use user-editable `user_metadata` for authorization.
- Never put service-role or secret keys in client code.
- Keep identity and verification documents private.
- Use explicit `TO anon` / `TO authenticated` policy roles and ownership predicates.
- UPDATE policies must include both `USING` and `WITH CHECK`.
- Avoid `SECURITY DEFINER`; if genuinely necessary, place the function in a non-exposed schema, restrict execution grants, validate caller identity and document why it is required.
- If creating views, use `security_invoker = true` where appropriate.
- Test that cross-provider reads and writes are denied.

## Boundaries

- Do not create or select a hosted Supabase project.
- Do not apply migrations to any hosted database.
- Do not deploy or publish.
- Do not change the Expo application or add app-side Supabase integration.
- Do not add guest accounts, payments, booking guarantees or unrelated features.
- Do not modify `main`; submit a pull request targeting `main`.
- Do not merge the pull request. The owner performs final review and merge.
- Licensing clearance remains deferred and is required before commercial launch.

## Required validation

- Verify migration ordering and clean-database application.
- Run SQL/RLS tests with distinct test identities.
- Confirm public users cannot read draft, rejected, suspended or archived listings.
- Confirm providers cannot change ownership, moderation status or verification status.
- Confirm verification storage is not publicly readable.
- Run relevant Supabase security and performance advisors where a test project is explicitly provided.
- Report any manual dashboard setup that cannot be represented in migrations.

## Handover requirements

Before opening the PR, provide:
- Summary of files changed.
- Migration names and schema summary.
- RLS policy matrix.
- Test commands and actual results.
- Security advisor results, if run.
- Any deviations from Database Specification v1.0 and their reasons.
- Confirmation that no hosted project was modified and no deployment occurred.

## Important

If a material security or data-model decision is needed that changes the approved product behavior, stop and ask the owner. Routine implementation details may be handled within this scope.

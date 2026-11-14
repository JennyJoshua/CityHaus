# CityHaus Database and Backend Specification v1.0 — Reconstructed Draft

**Document status:** Reconstructed technical draft — owner review required  
**Version:** 1.0-draft  
**Date:** 14 November 2026  
**Product:** CityHaus  
**Repository:** `JennyJoshua/CityHaus`  
**Implementation branch:** `phase1/supabase-db-foundation`  
**Related work:** Issue #1; draft PR #2

> **Document authority and limitation**
>
> The previously approved original document could not be recovered. This document reconstructs the specification from retained owner decisions, the Phase 1 handover, GitHub Issue #1, and the current preparation documents. It is not represented as a verbatim copy of the lost document.
>
> Confirmed product decisions are marked **CONFIRMED**. Technical designs that need owner approval are marked **PROPOSED**. Details that cannot safely be decided from available evidence are marked **OPEN**. No implementation authorization is implied by this draft.

---

## 1. Purpose

Define the product-facing backend requirements, database architecture, data model, access control, storage, workflows, and acceptance criteria for the first CityHaus database foundation.

The specification is intended to guide implementation of a secure, maintainable Supabase/PostgreSQL backend for a national Papua New Guinea accommodation/property discovery platform.

## 2. Product decisions and principles

### 2.1 Confirmed owner decisions

| Decision | Owner decision | Status |
|---|---|---|
| D1 — Market | National, Papua New Guinea | CONFIRMED |
| D2 — Booking model | Direct | CONFIRMED |
| D3 — Brand | CityHaus | CONFIRMED |

### 2.2 Confirmed product rules from the Phase 1 handover and Issue #1

- Members of the public can browse and search without creating an account.
- There is no buyer/guest account registration role.
- Registration is for **Individual Providers** and **Business Providers**.
- Providers manage their own permitted provider information, properties, images, and enquiries.
- Public users see only properties that are approved and active, plus deliberately public provider information.
- Providers cannot approve their own properties or their own verification.
- Reservation requests are enquiries; they are not confirmed bookings, payments, or guarantees of availability.
- Integrated payments are outside Phase 1.
- PGK is the initial currency.
- Verification records and evidence documents are private.
- Administrator authority must be derived from a trusted server-controlled mechanism, never user-editable `user_metadata`.
- Cross-provider access to private data must be denied.
- The database foundation is Phase 1; Expo application integration is outside this phase.
- Licensing clearance remains deferred. Commercial launch is not authorized until inherited code licensing and reuse rights are resolved.

### 2.3 Product principles

1. Guest-first discovery: public browsing must not require registration.
2. Direct contact: CityHaus facilitates an enquiry to the relevant provider; it does not promise a confirmed reservation.
3. Provider accountability: providers control only their own permitted records.
4. Moderated publication: a provider cannot unilaterally publish or approve a property.
5. Privacy by default: identity, contact, enquiry and verification data are not public merely because a property is public.
6. PNG-first: location hierarchy, contact conventions, and PGK must support Papua New Guinea.
7. Auditable administration: privileged moderation and verification actions should be attributable and auditable.

## 3. Scope

### 3.1 Phase 1 database/backend scope

- Supabase project configuration for local development.
- PostgreSQL schema and ordered SQL migrations.
- Authentication-linked profile model for provider accounts.
- Individual and business provider profiles.
- Location, property, image, and amenity records.
- Direct reservation-enquiry records.
- Provider verification records.
- User-submitted reports.
- Administrative audit records.
- RLS, explicit grants, and trusted administrator authorization.
- Supabase Storage policies for property images and private verification evidence.
- Repeatable database, authorization, and storage tests.
- Setup and migration documentation.

### 3.2 Out of scope for Phase 1

- Expo/mobile application integration.
- Buyer or guest account registration.
- Integrated payments, deposits, commissions, refunds, or payment reconciliation.
- Guaranteed booking, inventory locking, or real-time availability guarantees.
- Automated identity verification through a paid third-party service.
- Commercial launch before licensing clearance.
- Production deployment or hosted migration without separate owner approval.

## 4. Users and authorization identities

| Identity | Description | Authentication |
|---|---|---|
| Anonymous visitor | Public user browsing and submitting an enquiry | No account |
| Individual provider | Person listing accommodation/property | Supabase Auth account |
| Business provider | Business listing accommodation/property | Supabase Auth account |
| Administrator/moderator | Trusted operator reviewing providers, properties, reports and verification | Authenticated identity plus trusted server-controlled authorization |

**OPEN:** The exact administrator provisioning mechanism must be selected before implementation. Recommended approach: a protected server-controlled role/claim or private database role mapping managed only through trusted administrative operations. Never trust a role supplied in user-editable metadata or by the client.

## 5. Backend architecture

### 5.1 Proposed architecture

- **Database:** Supabase-managed PostgreSQL.
- **Authentication:** Supabase Auth for individual and business provider accounts.
- **Authorization:** PostgreSQL grants and RLS; privileged workflows executed only through trusted server-side operations.
- **File storage:** Supabase Storage.
- **Schema management:** version-controlled SQL migrations in `supabase/migrations/`.
- **Tests:** disposable local/test database and distinct authorization identities.
- **Client:** Expo application integration is a later phase and must use only public client credentials; never service-role credentials.

### 5.2 Security boundaries

- Treat all client input as untrusted.
- RLS is mandatory on every exposed application table.
- Grant only the minimum required table, sequence, and function privileges.
- Use explicit policy roles such as `anon` and `authenticated`.
- Every UPDATE policy must have both `USING` and `WITH CHECK`.
- Avoid SECURITY DEFINER functions. Any necessary exception requires documented justification, restricted execution grants, safe search path, and caller validation.
- Views exposed through the API must use `security_invoker = true` where applicable.
- Do not expose private schemas or sensitive tables through the Data API.
- Do not store service-role keys or secrets in the mobile app or public repository.
- Do not use `raw_user_meta_data` or `user_metadata` as an authorization source.

## 6. Database model

The following 11 tables are the established Phase 1 table inventory. Their names are retained from the handover. The responsibilities below are confirmed at a high level; candidate columns are design proposals and must be checked against owner decisions before migrations are written.

### 6.1 `profiles`

**Purpose:** Application profile associated with a Supabase Auth user.

Proposed fields:
- `id` — UUID primary key, matching `auth.users.id`.
- `created_at`, `updated_at` — timestamps.
- `account_status` — proposed account lifecycle field.
- `display_name` — proposed display name.
- `contact_email` — proposed contact field, subject to privacy rules.
- `contact_phone` — proposed contact field, subject to privacy rules.

Rules:
- One application profile per Auth user.
- The client cannot assign itself administrator privileges.
- Do not make private contact information public by exposing this table.
- Exact profile fields, account statuses and deletion behavior: **OPEN**.

### 6.2 `provider_profiles`

**Purpose:** Provider-specific information for individual and business providers.

Proposed fields:
- `id` — UUID primary key.
- `profile_id` — proposed FK to `profiles.id`.
- `provider_type` — proposed values `individual` or `business`.
- `public_display_name` — proposed public-facing name.
- `business_legal_name` — proposed private business identity field where applicable.
- `public_description` — proposed public description.
- `public_phone`, `public_email`, `public_whatsapp` — proposed contact fields; exact public exposure is an owner decision.
- `verification_status` — proposed read-only-to-provider status.
- `created_at`, `updated_at`.

Rules:
- A provider profile belongs to one authenticated profile.
- Provider type cannot be changed by arbitrary client updates after registration without a trusted process.
- Providers cannot write verification status.
- Only explicitly approved public fields may be exposed to anonymous users.
- Exact fields and whether one user may have multiple provider profiles: **OPEN**.

### 6.3 `locations`

**Purpose:** Structured Papua New Guinea location directory for property discovery.

Proposed fields:
- `id` — UUID primary key.
- `name` — location name.
- `location_type` — proposed hierarchy level.
- `parent_location_id` — optional self-reference for hierarchy.
- `country_code` — proposed country identifier, defaulting to PNG where appropriate.
- `latitude`, `longitude` — optional coordinates.
- `is_active` — proposed directory control.
- `created_at`, `updated_at`.

Rules:
- Public users may need to read active location values for search filters.
- Provider-submitted property locations must resolve to valid location records or follow an owner-approved custom-location process.
- Exact hierarchy (province, district, LLG, town/locality), coordinate policy, and who maintains the directory: **OPEN**.

### 6.4 `properties`

**Purpose:** Accommodation/property listings submitted by providers and moderated before public publication.

Proposed fields:
- `id` — UUID primary key.
- `provider_profile_id` — proposed FK to `provider_profiles.id`.
- `location_id` — proposed FK to `locations.id`.
- `title`, `description` — proposed listing content.
- `property_type` — proposed controlled classification.
- `address_text` — proposed optional address/area description.
- `latitude`, `longitude` — proposed optional map coordinates.
- `price_amount` — proposed numeric amount.
- `currency_code` — proposed PGK default.
- `capacity` — proposed guest capacity.
- `moderation_status` — proposed moderation lifecycle.
- `publication_status` — proposed active/inactive publication control.
- `submitted_at`, `reviewed_at`, `reviewed_by` — proposed moderation metadata.
- `created_at`, `updated_at`.

Rules:
- A provider may create and manage only their own permitted listings.
- Provider ownership must be derived from trusted identity relationships, not an arbitrary submitted owner ID.
- A provider cannot approve, publish, or alter reviewer-controlled fields.
- Anonymous users may read only approved and active listings.
- Draft, rejected, suspended, and archived listings must not be visible publicly.
- Public property reads must not reveal private provider, moderation, or verification fields.
- Whether approval and active publication are separate fields, exact statuses, listing types, pricing units, capacity rules and edit-after-approval behavior: **OPEN**.

### 6.5 `property_images`

**Purpose:** Metadata for property photographs stored in Supabase Storage.

Proposed fields:
- `id` — UUID primary key.
- `property_id` — proposed FK to `properties.id`.
- `storage_path` — proposed object path; avoid treating arbitrary client URLs as trusted.
- `alt_text` — proposed accessibility description.
- `display_order` — proposed sort order.
- `is_primary` — proposed primary-image indicator.
- `moderation_status` — proposed review status if image moderation is required.
- `created_at`.

Rules:
- Providers can manage images only for properties they own.
- Public image access is allowed only when the parent property is publicly approved and active.
- Exact image count, file size, MIME types, image moderation, bucket and path format: **OPEN**.

### 6.6 `amenities`

**Purpose:** Controlled catalogue of property features/amenities.

Proposed fields:
- `id` — UUID primary key.
- `name` — display name.
- `slug` — stable identifier.
- `description` — optional explanation.
- `is_active` — proposed catalogue control.
- `display_order` — proposed ordering.
- `created_at`, `updated_at`.

Rules:
- Providers must not be able to create arbitrary public catalogue entries unless explicitly authorized.
- Exact catalogue ownership, localization and seed values: **OPEN**.

### 6.7 `property_amenities`

**Purpose:** Many-to-many relationship between properties and amenities.

Proposed fields:
- `property_id` — proposed FK.
- `amenity_id` — proposed FK.
- `created_at`.

Proposed key: composite primary key `(property_id, amenity_id)`.

Rules:
- Provider changes must be restricted to amenities attached to the provider's own property.
- Public reads follow parent property visibility.
- Exact deletion behavior: **OPEN**.

### 6.8 `reservation_requests`

**Purpose:** Direct enquiries from guests to providers about a property.

Proposed fields:
- `id` — UUID primary key.
- `property_id` — proposed FK to `properties.id`.
- `provider_profile_id` — proposed recipient/provider FK, or derived relation.
- `guest_name` — proposed guest contact name.
- `guest_email` — proposed guest email.
- `guest_phone` — proposed guest phone.
- `requested_check_in`, `requested_check_out` — proposed dates if date-based enquiries are required.
- `guest_count` — proposed party size.
- `message` — proposed enquiry message.
- `status` — proposed enquiry workflow status.
- `provider_response` — proposed response content or separate response model if needed.
- `created_at`, `updated_at`.

Rules:
- Anonymous visitors can submit enquiries for eligible public listings.
- Submission is not a confirmed booking, payment, availability guarantee, or inventory lock.
- Providers may access enquiries only for properties they own.
- Providers must not access another provider's enquiries.
- Guest personal data must never be public.
- Anonymous users must not gain broad SELECT access to enquiry records.
- Spam/rate limiting must be considered; database RLS alone may not be sufficient.
- Guest read-back, enquiry status values, provider response model, date rules, retention and abuse controls: **OPEN**.

### 6.9 `verification_records`

**Purpose:** Track provider identity/business verification and associated review outcomes.

Proposed fields:
- `id` — UUID primary key.
- `provider_profile_id` — proposed FK.
- `verification_type` — proposed category.
- `status` — proposed review status.
- `submitted_at`, `reviewed_at` — proposed timestamps.
- `reviewed_by` — proposed trusted administrator identity.
- `review_notes` — proposed private notes.
- `created_at`, `updated_at`.

Rules:
- Verification information is private.
- Providers cannot approve their own verification or edit reviewer-controlled fields.
- Anonymous visitors cannot read verification records.
- Verification documents must be stored privately and delivered only through authorized server-controlled access.
- Exact evidence fields, document retention, provider visibility of review notes, status values and reviewer workflow: **OPEN**.

### 6.10 `reports`

**Purpose:** Record reports/complaints submitted about listings or providers.

Proposed fields:
- `id` — UUID primary key.
- `property_id` — optional proposed target FK.
- `provider_profile_id` — optional proposed target FK.
- `reporter_profile_id` — nullable proposed FK for authenticated reporters; anonymous reporting identity needs a privacy design.
- `reason_code` — proposed controlled reason.
- `details` — proposed report description.
- `status` — proposed moderation status.
- `reviewed_by`, `reviewed_at` — proposed review metadata.
- `created_at`, `updated_at`.

Rules:
- Reports are not public.
- Reporters should not gain access to internal moderation notes.
- Providers should not be able to alter or delete reports about themselves.
- Exact anonymous reporting support, reporter privacy, target types and workflow: **OPEN**.

### 6.11 `admin_audit_logs`

**Purpose:** Append-only record of sensitive administrative actions.

Proposed fields:
- `id` — UUID primary key.
- `actor_id` — trusted administrator identity.
- `action` — action identifier.
- `target_table` — affected entity type.
- `target_id` — affected entity identifier.
- `before_data`, `after_data` — optional structured change snapshots, subject to sensitive-data minimization.
- `reason` — optional moderation reason.
- `created_at` — immutable event timestamp.

Rules:
- Ordinary providers and anonymous visitors cannot read or write audit records.
- Audit records must not be editable or deletable by ordinary application roles.
- Only trusted server-side administrative operations may append records.
- Exact retention, access, data minimization, and actor identity representation: **OPEN**.

## 7. Relationships and integrity

The following relationships are proposed from table responsibilities, not confirmed original schema decisions:

- `profiles.id` ↔ `auth.users.id` (one-to-one).
- `provider_profiles.profile_id` → `profiles.id`.
- `properties.provider_profile_id` → `provider_profiles.id`.
- `properties.location_id` → `locations.id`.
- `property_images.property_id` → `properties.id`.
- `property_amenities.property_id` → `properties.id`.
- `property_amenities.amenity_id` → `amenities.id`.
- `reservation_requests.property_id` → `properties.id`.
- `verification_records.provider_profile_id` → `provider_profiles.id`.
- `reports` target relationships → properties and/or providers, subject to approved reporting model.
- `admin_audit_logs` actor and target references → trusted identities and audited entities, subject to audit design.

**OPEN:** Exact FK delete/update actions, unique constraints, indexes, cascade strategy, soft deletion and retention behavior must be approved. Avoid cascading deletion of records that are legally, operationally or audit-sensitive.

## 8. Proposed workflow definitions

The product rules establish that moderation and enquiries exist, but the exact original state machines were not recovered. The following are proposals for owner review only.

### 8.1 Property moderation proposal

Possible states:
- `draft`
- `submitted`
- `under_review`
- `approved`
- `rejected`
- `suspended`
- `archived`

Publication eligibility should require both an approved moderation decision and an active publication state. Only trusted administrators may approve, reject or suspend. Providers may edit draft/rejected content; changes to approved content may require re-review. Exact transitions and edit rules require approval.

### 8.2 Provider verification proposal

Possible states:
- `not_submitted`
- `pending`
- `under_review`
- `verified`
- `rejected`
- `expired`

Only trusted administrators may set review outcomes. The provider may submit or replace evidence through an authorized process. Exact states, evidence and re-verification rules require approval.

### 8.3 Reservation enquiry proposal

Possible states:
- `new`
- `viewed`
- `responded`
- `closed`
- `spam`

These states describe communication workflow only. None means a booking is confirmed or paid. Exact state transitions and whether guests can check an enquiry using a secure token require approval.

### 8.4 Report workflow proposal

Possible states:
- `open`
- `under_review`
- `actioned`
- `dismissed`

Only trusted moderators may change review outcomes. Exact reasons, target types and notifications require approval.

## 9. Row Level Security and permission requirements

The table below defines minimum security intent. It is not SQL and does not authorize implementation of unresolved behaviors.

| Resource | Anonymous | Provider | Administrator |
|---|---|---|---|
| Profiles | No private profile access | Own permitted profile only | Trusted administrative access |
| Provider profiles | Deliberately public fields only | Own permitted fields | Trusted administrative access |
| Locations | Read active public lookup values, if approved | Read for listing forms | Manage catalogue |
| Properties | Read approved + active only | Manage own permitted listings | Moderate and administer |
| Property images | Read images of public properties only | Manage own property images | Moderate/administer |
| Amenities | Read active catalogue values, if approved | Attach permitted amenities to own property | Manage catalogue |
| Property amenities | Follow property visibility | Manage own property relationships | Administer |
| Reservation requests | Submit only; no broad read | Read/respond only for own properties | Trusted administrative access |
| Verification records | Denied | Own permitted submission/status view only, subject to approved privacy design | Trusted review access |
| Reports | Submit only if anonymous reporting is approved; no read | No access to private reports about others | Trusted moderation access |
| Admin audit logs | Denied | Denied | Restricted trusted access |

Additional requirements:
- Test Provider A against Provider B data for every provider-owned table.
- Prevent clients from changing owner IDs, verification outcomes, moderation states, admin role fields and audit records.
- Ensure views and RPC functions do not bypass the intended policies.
- Test Storage policies independently from table RLS.
- Do not rely on hiding UI controls as security.

## 10. Supabase Storage

Two logical storage categories are required by the Phase 1 handover:

### 10.1 Property images

- Images associated with property listings.
- Public delivery is allowed only for properties that satisfy approved + active publication rules.
- Upload, replacement and deletion must be limited to the owning provider's permitted property.
- Exact bucket name, object path, image formats, file size, count limits, transformation and moderation rules: **OPEN**.

### 10.2 Verification evidence

- Private identity/business verification documents.
- No public bucket or public object URLs.
- Access limited to the relevant provider's permitted submission flow and trusted reviewers.
- Use short-lived authorized access where a reviewer/provider must retrieve a file.
- Exact bucket name, object path, file types, size limits, malware scanning and retention: **OPEN**.

## 11. Data protection and privacy

- Collect only data necessary for provider onboarding, property discovery, enquiries, moderation and verification.
- Public property responses must be deliberately shaped; do not expose whole rows containing private fields.
- Guest enquiry details are private and accessible only to the intended provider and authorized administrators.
- Verification documents and sensitive review notes are private.
- Avoid placing secrets, identity documents or unnecessary personal data in logs.
- Define retention and deletion rules before production launch.
- Establish a process for correcting provider data and handling account closure.
- Applicable PNG legal/privacy obligations must be reviewed before commercial launch; this specification does not constitute legal advice.

## 12. Data validation and performance

Proposed baseline requirements:
- Foreign keys for all approved relationships.
- Check constraints for valid numeric/date ranges and controlled values where appropriate.
- Unique constraints for stable identifiers and true one-to-one relationships.
- Index foreign-key columns and frequently filtered public search fields based on query patterns.
- Avoid speculative indexes without query justification.
- Use consistent UTC timestamps at the database boundary.
- Maintain `updated_at` consistently for mutable records.
- Use numeric fixed-precision types for money, never floating-point.
- Use a currency code alongside amounts if multi-currency support may be needed later; PGK remains the initial supported currency.
- Validate enquiry dates, capacity and required contact details server-side.
- Define pagination and sensible query row limits for public search.

**OPEN:** Exact monetary precision, date/time semantics, location search strategy, geospatial extension, pagination limits and expected data volumes.

## 13. Migration and environment management

- All schema changes must be committed as ordered SQL migrations.
- Migrations must apply cleanly to a fresh local database.
- Migrations must be deterministic and reviewed before application.
- Seed only stable, approved reference data; do not invent production provider/property records.
- Local/test configuration must be clearly separated from hosted configuration.
- Never commit secrets or local environment files.
- No hosted Supabase project may be selected or modified as part of this specification drafting.
- Merging code into GitHub must not itself be treated as database deployment.
- Hosted migrations require a separate explicit owner approval and a reviewed backup/rollback plan.

## 14. Required verification and test matrix

Tests must use separate identities and verify both allowed and denied access.

| Test identity | Required tests |
|---|---|
| Anonymous visitor | Public approved/active property reads; cannot read drafts, rejected, suspended or archived properties; can submit permitted enquiry; cannot read private enquiries, verification or audit data |
| Provider A | Can manage own permitted profile/listings/images; cannot approve own property or verification; cannot change protected owner/status fields |
| Provider B | Same allowed operations for own data |
| Provider A against Provider B | Cannot read or alter Provider B private profile, properties, images, enquiries or verification data |
| Administrator | Trusted admin can perform approved moderation and verification tasks; unauthorized authenticated user cannot obtain admin powers |
| Storage | Public property image access follows listing publication; verification documents are never public; cross-provider object access is denied |
| Audit | Privileged actions are recorded; ordinary roles cannot alter or delete audit records |

Additional validation:
- Migration naming and ordering.
- Clean database application.
- RLS enabled on all exposed application tables.
- Least-privilege grants.
- No unauthorized SECURITY DEFINER functions.
- No unsafe views or public RPC execution.
- Storage policy tests.
- Schema consistency and migration repeatability.
- Supabase security/performance advisors where a test project is available.

A generic fixture test is not evidence of CityHaus security. Tests must run against the actual CityHaus schema.

## 15. Acceptance criteria for Phase 1

Phase 1 is complete only when:

1. All 11 approved core tables are implemented with owner-approved columns and relationships.
2. Constraints, indexes and timestamp handling are documented and tested.
3. RLS is enabled on every exposed application table.
4. Explicit grants and RLS policies enforce the permission matrix.
5. Anonymous guests can perform only approved public reads and enquiry submission.
6. Providers are isolated from each other's private data and can manage only their own permitted records.
7. Providers cannot approve their own listings or verification.
8. Trusted administrator access is implemented and tested without user-editable metadata authorization.
9. Property image and private verification storage policies are implemented and tested.
10. Audit records are protected against ordinary client modification.
11. Tests pass for anonymous, Provider A, Provider B, cross-provider denial and administrator access.
12. Fresh migrations apply cleanly and setup documentation is reproducible.
13. Any unresolved deviations are recorded and approved.
14. A pull request is reviewed by the owner; no automatic merge or hosted database deployment occurs.

## 16. Open decision register — owner approval required

These decisions were not recoverable from the retained records. They must be resolved before the affected implementation is finalized.

| ID | Decision required | Current state |
|---|---|---|
| O-01 | Exact provider profile fields and public/private field list | OPEN |
| O-02 | Whether one Auth account may own multiple provider profiles | OPEN |
| O-03 | Exact PNG location hierarchy and who maintains it | OPEN |
| O-04 | Property types, required fields, pricing units and capacity rules | OPEN |
| O-05 | Exact property moderation statuses and transitions | OPEN |
| O-06 | Whether moderation approval and active publication are separate controls | OPEN |
| O-07 | Provider edit rules after property submission/approval | OPEN |
| O-08 | Property image bucket, limits, formats, paths and moderation | OPEN |
| O-09 | Exact enquiry fields, date rules and guest contact requirements | OPEN |
| O-10 | Enquiry status workflow, provider response and guest read-back | OPEN |
| O-11 | Enquiry spam prevention and personal-data retention | OPEN |
| O-12 | Verification evidence types, statuses, reviewer workflow and retention | OPEN |
| O-13 | Verification document bucket and authorized retrieval rules | OPEN |
| O-14 | Report target types, anonymous reporting and report workflow | OPEN |
| O-15 | Audit event schema, retention and authorized readers | OPEN |
| O-16 | Trusted administrator provisioning/authorization mechanism | OPEN |
| O-17 | UUID and timestamp conventions, soft deletion and FK delete behavior | OPEN |
| O-18 | PostgreSQL extensions, geospatial search and indexing approach | OPEN |
| O-19 | Auth settings and provider sign-in method for hosted deployment | OPEN |
| O-20 | Data retention, account closure and privacy handling | OPEN |

## 17. Implementation sequence after owner approval

1. Resolve the open decisions needed for the database schema and security model.
2. Freeze the schema and permission matrix as the approved v1.0 baseline.
3. Implement core schema migrations.
4. Implement grants and RLS.
5. Implement Storage buckets and policies.
6. Implement trusted admin operations and audit behavior.
7. Run CityHaus-specific security and functional tests.
8. Update Issue #1 and PR #2 with evidence.
9. Owner reviews and merges the code.
10. Apply migrations to the intended hosted Supabase project only after separate explicit approval.

## 18. Change control

- This document is a reconstructed draft because the original approved specification could not be recovered.
- Owner-confirmed product decisions must not be changed by implementation agents.
- Proposed technical designs require explicit owner approval before they become binding where they materially affect privacy, authorization, product workflow or data retention.
- Any implementation deviation must be documented in the pull request.
- No hosted database action, production deployment, paid service, destructive action or main-branch merge is authorized by this document.

---

**End of reconstructed draft.**

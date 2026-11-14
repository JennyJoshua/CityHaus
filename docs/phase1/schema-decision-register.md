# Schema decision register

Nothing below is a design; it is a list of what is **missing**. Status values: `ESTABLISHED` (stated in handover/Issue #1), `IMPLIED` (suggested by a name, needs confirmation), `UNDECIDED` (owner or spec must answer).

## 1. Relationships

| Relationship | Status | Source |
|---|---|---|
| Providers (individual and business) register; no buyer/guest account role | ESTABLISHED | Handover product rules |
| Provider owns their profile, properties, images, enquiries | ESTABLISHED | Handover product rules |
| Anonymous guests submit reservation enquiries | ESTABLISHED | Issue #1 |
| Public sees only approved, active properties + deliberately public provider fields | ESTABLISHED | Handover |
| Providers cannot approve own listing or verification | ESTABLISHED | Handover |
| Verification documents/records are private | ESTABLISHED | Handover |
| Admin authority assigned server-side, never from `user_metadata` | ESTABLISHED | Handover |
| profiles → auth user | IMPLIED | table name |
| provider_profiles → profiles | IMPLIED | table name |
| properties → provider, → location | IMPLIED | ownership rule; README area filter |
| property_images → properties | IMPLIED | table name, ownership rule |
| property_amenities ↔ properties × amenities (junction) | IMPLIED | table name |
| reservation_requests → properties | IMPLIED | table name |
| verification_records → provider or property? | UNDECIDED | |
| reports → what is reported (property, provider, both?) and by whom | UNDECIDED | |
| admin_audit_logs → acting admin, audited object | UNDECIDED | |

## 2. Global decisions

| ID | Question |
|---|---|
| D-GEN-01 | Primary key type and convention (uuid vs bigint) |
| D-GEN-02 | Timestamp columns, type, and how `updated_at` is maintained; soft delete? |
| D-GEN-03 | Status columns: Postgres enum vs text + CHECK |
| D-GEN-04 | Naming conventions |
| D-GEN-05 | Price: type/precision, PGK-only column or currency column, rental period units |
| D-GEN-06 | Postgres extensions allowed (e.g. PostGIS for coordinates) |
| D-CONFIG-01 | Review CLI-default `supabase/config.toml` (major_version 17 vs target project; signup/confirmation settings; `auto_expose_new_tables`) |
| D-AUTH-01 | Provider sign-in method (README: phone OTP). SMS provider may be a paid service |
| D-ADMIN-01 | Trusted admin mechanism (handover requires server-controlled; mechanism not specified). Guardrail G09 blocks `user_metadata` use |
| D-PROD-01 | Reconcile README (guests/hosts, call/WhatsApp, offline payment) with handover (providers, enquiries) |
| D-LOOKUP-01 | Who maintains amenities and locations and whether seed data is required |

## 3. Per-table missing definitions

For every table, all columns, data types, nullability, defaults, unique and check constraints, foreign-key `ON DELETE` behaviour and indexes are UNDECIDED.

- **profiles** — link to auth user; provider type; contact fields; whether admin is represented here.
- **provider_profiles** — individual vs business attributes; exactly which fields are public (prototype has WhatsApp, Facebook); where verification state is exposed.
- **locations** — hierarchy, coordinates, public read.
- **properties** — property types and moderation workflow. Handover names draft, rejected, suspended, archived and a public "approved, active" state, but not full states/transitions or whether approval and active are one or two fields. Capacity, availability, editable fields after approval.
- **property_images** — storage path vs URL, ordering, primary image, limits, moderation, public/private bucket.
- **amenities / property_amenities** — who maintains lookup values and key/delete behaviour.
- **reservation_requests** — guest fields, dates, party size, message, status and response workflow; anonymous spam controls; personal-data retention; insert vs function; read-back permissions; must not imply payment or booking guarantee.
- **verification_records** — collected information, statuses, reviewer, provider visibility, retention.
- **reports** — who may report, reasons, status, reporter privacy, provider visibility.
- **admin_audit_logs** — logged actions, append-only enforcement, writers and readers.

## 4. Storage

Bucket names, public/private settings, size and MIME limits, path convention and storage policies are UNDECIDED. Known requirement: verification documents bucket must not be publicly readable.

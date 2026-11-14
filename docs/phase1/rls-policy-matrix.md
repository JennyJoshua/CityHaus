# RLS policy matrix (TEMPLATE — not an implemented policy set)

Legend: **REQ-DENY** = denial required by the handover/Issue #1; **REQ-ALLOW(cond)** = access required, exact predicate still undecided; **UNDECIDED** = owner/spec decision needed. No cell is a policy; nothing here is applied.

| Table | Op | Anonymous | Provider A (own rows) | Provider A on B | Administrator |
|---|---|---|---|---|---|
| profiles | SELECT | UNDECIDED | REQ-ALLOW(own) | REQ-DENY | UNDECIDED |
| profiles | INSERT/UPDATE/DELETE | UNDECIDED | UNDECIDED (role/admin fields REQ-DENY) | REQ-DENY | UNDECIDED |
| provider_profiles | SELECT | public fields only; list = D-PUBLIC-01 | own, full | public fields only | UNDECIDED |
| provider_profiles | INSERT/UPDATE/DELETE | UNDECIDED | own; verification fields REQ-DENY | REQ-DENY | UNDECIDED |
| locations | SELECT/writes | UNDECIDED | UNDECIDED | UNDECIDED | UNDECIDED |
| properties | SELECT | approved + active only; deny draft/rejected/suspended/archived | own, any state | public listings only | UNDECIDED |
| properties | INSERT | REQ-DENY | own | REQ-DENY | UNDECIDED |
| properties | UPDATE | REQ-DENY | own; ownership + moderation status REQ-DENY | REQ-DENY | UNDECIDED |
| properties | DELETE | REQ-DENY | UNDECIDED | REQ-DENY | UNDECIDED |
| property_images | SELECT | only for public properties | own | public only | UNDECIDED |
| property_images | writes | REQ-DENY | own | REQ-DENY | UNDECIDED |
| amenities | all | UNDECIDED | UNDECIDED | UNDECIDED | UNDECIDED |
| property_amenities | SELECT | public properties only | own | public only | UNDECIDED |
| property_amenities | writes | REQ-DENY | own | REQ-DENY | UNDECIDED |
| reservation_requests | INSERT | submit only; fields D-ENQ-01 | UNDECIDED | UNDECIDED | UNDECIDED |
| reservation_requests | SELECT | guest read-back UNDECIDED | enquiries on own properties | REQ-DENY | UNDECIDED |
| reservation_requests | UPDATE/DELETE | REQ-DENY | response workflow UNDECIDED | REQ-DENY | UNDECIDED |
| verification_records | SELECT | REQ-DENY | provider visibility UNDECIDED | REQ-DENY | UNDECIDED |
| verification_records | writes | REQ-DENY | provider writes/status UNDECIDED | REQ-DENY | UNDECIDED |
| reports | all | UNDECIDED | UNDECIDED | UNDECIDED | UNDECIDED |
| admin_audit_logs | all | UNDECIDED | UNDECIDED | UNDECIDED | UNDECIDED |
| storage: property images | all | UNDECIDED | UNDECIDED | UNDECIDED | UNDECIDED |
| storage: verification docs | read | REQ-DENY | UNDECIDED | REQ-DENY | UNDECIDED |

"Inferred" denials from guest/no-account rules are not literal spec requirements and need confirmation before implementation.

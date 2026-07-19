# Textile Marketplace MVP API Contract

Date: 2026-07-10

Status: Draft v1 generated after API discovery rounds 1-10.

Primary sources:

- `outputs/textile-marketplace-api-contract-discovery.md`
- `outputs/textile-marketplace-database-design.md`
- `outputs/textile-marketplace-figma-wireframe-spec.md`
- `outputs/textile-marketplace-mvp-system-design.md`

## 1. Contract Purpose

This document defines the backend API contract for the Android-first private MVP of the textile marketplace.

The API sits between the Flutter app/admin dashboard and Supabase-managed infrastructure. The mobile app and admin dashboard must not directly write marketplace database tables.

The contract covers:

- mobile OTP onboarding
- role confirmation
- profile completion
- search
- profile detail and contact reveal logging
- job-worker work cards
- manufacturer work-needed posts
- media upload
- manual verification
- saved items
- reports
- notifications
- settings
- share/contact analytics
- admin operations
- cross-cutting errors, retries, metadata, and compatibility

## 2. Self-Critique Pass Before Finalizing

Before writing this contract, the major risk areas were checked against the discovery, database, wireframe, and system-design documents.

### 2.1 Things That Could Easily Be Designed Wrong

1. **Direct Supabase access leaking into the app contract**
   - Bad design: Flutter writes directly to database tables or public Supabase table APIs.
   - Final decision: Flutter and admin call backend API/BFF endpoints. Supabase Auth, PostgreSQL, and Storage are infrastructure behind the backend.

2. **Overbuilding enterprise admin permissions**
   - Bad design: implement full admin RBAC too early.
   - Final decision: database keeps role support for future, but MVP treats every active admin as super-admin. This is acceptable only because the private MVP admin set is tiny and all actions are audited.

3. **Underspecifying abuse controls because the product owner asked for no limits**
   - Bad design: literal unlimited OTP/uploads/search/report/contact APIs.
   - Final decision: no product-visible quotas in private MVP, but invisible provider and infrastructure safeguards remain mandatory.

4. **Counting job-worker profiles as complete without any work**
   - Bad design: a job worker can be 100% complete while having no searchable work card.
   - Final decision: job-worker completion requires at least one published valid work card.

5. **Treating verification as visibility**
   - Bad design: only verified profiles are public.
   - Final decision: completed profiles can be public without blue tick. Verification controls trust badge, not basic visibility.

6. **Making public search cards expose contact details**
   - Bad design: search result cards show mobile number or full address.
   - Final decision: contact/address appears only on profile detail during free MVP, and the backend records contact reveal once per viewer/profile.

7. **Making reports too clean by discarding duplicates**
   - Bad design: unique report per user/target/reason loses repeated signal.
   - Final decision: store repeated reports, but admin queue must group them.

8. **Confusing work-needed `publish` as a stored status**
   - Bad design: status contains both `publish` and `active`.
   - Final decision: `publish` is an API action; `active` is the published/searchable status.

9. **Leaking verification documents**
   - Bad design: owner/public can download identity/GST proof after upload.
   - Final decision: owners see safe status/name only. Admin access is private, short-lived, and audited.

10. **Pretending the OpenAPI file is the complete backend implementation**
    - Bad design: over-specific schema that fights implementation.
    - Final decision: OpenAPI is an MVP implementation draft with stable endpoints, states, and DTO boundaries. Field-level additions may happen during implementation if backward compatible.

## 3. Global API Rules

### 3.1 Transport And Format

- Base path: `/v1`
- Protocol: HTTPS only
- Format: JSON request and response bodies
- ID format: UUID string
- Timestamp format: ISO 8601 UTC
- Pagination: cursor pagination for lists/search
- Page sizes: bounded by backend defaults and maximums

### 3.2 Authentication Boundary

Flutter calls backend auth endpoints. The backend talks to Supabase Auth.

The client stores access/refresh tokens in Android secure storage and sends only the backend access token to the marketplace API.

FastAPI verifies Supabase asymmetric access-token JWTs locally using the project's cached JWKS. It validates signature, issuer, audience, expiry, subject, and `session_id`, then enforces the local user/account/session state. OTP verification, refresh, and provider logout remain Supabase Auth operations. Current-device logout marks the local `user_auth_sessions` row revoked so server restarts do not restore access.

### 3.3 Error Envelope

Every error response should follow:

```json
{
  "error": {
    "code": "validation_failed",
    "message": "Please check the highlighted fields.",
    "details": {},
    "field_errors": {
      "mobile": "Please enter the mobile number"
    },
    "request_id": "req_..."
  }
}
```

User-facing messages stay simple. Debug details stay in logs/admin tooling.

Common error codes:

- `validation_failed`
- `unauthorized`
- `forbidden`
- `not_found`
- `account_suspended`
- `profile_incomplete`
- `minimum_photos_required`
- `verification_pending_locked`
- `upload_not_ready`
- `app_update_required`
- `provider_unavailable`
- `internal_error`

### 3.4 Idempotency

Use idempotency keys for retryable create/submit/transition operations:

- OTP verification/account creation
- role confirmation
- profile completion
- work-card publish
- work-needed publish/close
- media complete
- verification submit/resubmit
- report submit may create repeated reports intentionally, so idempotency is optional and must not accidentally collapse deliberate new reports.

### 3.5 No Product-Visible Limits In Private MVP

The private MVP should not show user-facing quotas for OTP, search, uploads, reports, or contact actions.

Hidden safeguards remain mandatory:

- SMS provider caps
- request body size limits
- file size and MIME checks
- storage limits
- abusive IP/device blocking
- emergency admin kill switches
- admin/test bypasses

## 4. Core Roles And States

### 4.1 User Roles

Allowed role values:

- `business`
- `job_worker`
- `skilled_worker`

Role is selected after OTP verification and becomes immutable after profile completion. To change role after completion, the user must terminate the account and create a new profile with another valid flow.

### 4.2 Account Status

- `active`
- `suspended`
- `terminated`

Suspended users can access only Logout and Contact Support. Their profile/content is removed from search and public discovery.

### 4.3 Profile Visibility

- `draft`
- `public`
- `hidden_by_user`
- `suspended_by_admin`
- `deleted`

Completed profiles become public after final save if required fields are complete. Verification is not required for public visibility.

### 4.4 Verification Status

- `unverified`
- `pending`
- `verified`
- `changes_requested`
- `rejected`

Use separate owner/admin flag:

- `reverification_required: boolean`

Sensitive edits on verified profiles set:

- `verification_status = unverified`
- `is_verified = false`
- `reverification_required = true`

### 4.5 Work Card Status

For job-worker work cards:

- `draft`
- `published`
- `hidden_by_user`
- `removed_by_admin`
- `deleted`

Job-worker profile completion requires at least one published valid work card.

### 4.6 Work-Needed Post Status

For manufacturer/business demand posts:

- `draft`
- `active`
- `paused`
- `closed_by_user`
- `removed_by_admin`
- `deleted`

`publish` is an action. `active` is the published/searchable state.

## 5. Authentication And Onboarding

### 5.1 Request OTP

`POST /v1/auth/otp/request`

Request:

```json
{
  "mobile": "+919999999999"
}
```

Response:

```json
{
  "otp_request_id": "uuid",
  "message": "OTP sent"
}
```

Security:

- Return generic messages to avoid mobile-number enumeration.
- Provider hard caps remain even though product-visible quotas are not shown.

### 5.2 Verify OTP

`POST /v1/auth/otp/verify`

Request:

```json
{
  "mobile": "+919999999999",
  "otp": "123456",
  "otp_request_id": "uuid",
  "device": {
    "device_id": "install-id",
    "platform": "android",
    "app_version": "1.0.0"
  }
}
```

Response states:

- `complete_basic_account`
- `role_selection_required`
- `home`
- `account_blocked`

### 5.3 Complete Basic Account

`POST /v1/auth/account`

Request:

```json
{
  "display_name": "Aayush Kotadia",
  "accepted_terms_version": "2026-07-10",
  "accepted_privacy_version": "2026-07-10"
}
```

Consent is stored only after OTP succeeds.

### 5.4 Confirm Role

`POST /v1/auth/role/confirm`

Request:

```json
{
  "role": "job_worker"
}
```

The endpoint is idempotent and creates the matching profile shell.

### 5.5 Logout

`POST /v1/auth/logout`

Default MVP logout revokes the current device/session.

## 6. Me And Profile APIs

### 6.1 Bootstrap

`GET /v1/me`

Returns:

- user
- role
- account status
- profile summary
- completion score
- missing completion flags
- verification summary
- allowed next actions
- notification unread count

### 6.2 Owner Profile

`GET /v1/me/profile`

Returns owner-only fields:

- editable profile fields
- locked field metadata
- completion flags
- verification status
- draft/private status
- safe verification document labels

### 6.3 Update Owner Profile

`PATCH /v1/me/profile`

Rules:

- owner name and mobile are locked after completion
- profile editing is locked while verification is pending
- sensitive verified-field edits remove blue tick and set `reverification_required`
- mobile app cannot change role after profile completion

### 6.4 Complete Profile

`POST /v1/me/profile/complete`

Completion requirements:

Business:

- business name
- owner name
- business category
- manufacture/sell details
- product type/category where applicable
- address/locality/city/state/pincode/free-text address
- minimum 3 shop/business photos

Job worker:

- workshop/business name where applicable
- owner name
- work/workshop address/locality
- workplace photos
- at least one published valid work card

Skilled worker:

- name
- skill/mastery
- experience
- area/address
- contact
- recommended worker photo

### 6.5 Hide/Show Own Profile

`POST /v1/me/profile/hide`

`POST /v1/me/profile/show`

Hide removes from search/recommended/similar lists. Saved/direct links can still open the profile with status rules.

### 6.6 Profile Form Taxonomy

`GET /v1/taxonomy/categories?category_type={type}&parent_id={optional_uuid}`

Returns active category IDs and labels for authenticated profile and marketplace
forms. Supported types are `business_category`, `work_category`, `work_name`,
`product_type`, and `skill`. The backend remains the only database access layer;
mobile and admin clients do not read category tables directly.

### 6.7 Address Location Options And Validation

- `GET /v1/locations/states?q={optional_prefix}`
- `GET /v1/locations/districts?state_id={id}&q={optional_prefix}`
- `POST /v1/locations/validate-address`

These authenticated endpoints use backend-owned India Post reference data. State and city/district IDs are canonical; profile text fields remain display snapshots. A state/PIN or district/PIN mismatch is rejected. An area that does not exactly match a postal-office name returns a warning and suggested areas instead of falsely rejecting the address.

## 7. Search APIs

### 7.1 Search

`GET /v1/search`

Query parameters:

- `target`: `business`, `job_worker`, `skilled_worker`
- `q`: text query
- `business_mode`: `work_needed_posts` or `profiles`
- `job_worker_mode`: `work_cards` or `profiles`
- `filters`: category, work type, product type, locality, experience, verified only
- `sort`: `best`, `verified_first`, `nearby`, `most_photos`, `recent`
- `cursor`
- `limit`

Rules:

- search one target persona at a time
- business search defaults to work-needed posts
- job-worker search defaults to matching work cards and can switch to matching job-worker profiles
- the search target is fixed by the Home discovery card; users do not switch personas inside Search
- result cards never include contact number or full address
- exact/category/alias/keyword matching first, conservative fuzzy fallback
- log search after execution

## 8. Public Profile Detail And Contact Reveal

### 8.1 Get Public Profile

`GET /v1/profiles/{profile_id}`

During free private MVP:

- returns contact number and full address on profile detail
- records one `contact_reveals` row per viewer/profile
- opening the same profile again does not consume another reveal

Search/saved cards must not expose contact/address.

Public users see:

- public profile fields
- public role-specific fields needed by the business, job-worker, or karigar profile tab
- media carousel
- work cards or work-needed posts depending on profile type
- blue tick if verified
- call/WhatsApp/save actions

Public users do not see:

- verification checklist
- private proof media
- admin notes
- search debug scores
- private audit data

## 9. Work Cards

Owner endpoints:

- `GET /v1/me/work-cards`
- `POST /v1/me/work-cards`
- `PATCH /v1/me/work-cards/{work_card_id}`
- `POST /v1/me/work-cards/{work_card_id}/publish`
- `POST /v1/me/work-cards/{work_card_id}/hide`
- `POST /v1/me/work-cards/{work_card_id}/show`
- `DELETE /v1/me/work-cards/{work_card_id}`

Rules:

- only job-worker profiles can own work cards
- category first, then work name, product type, photos, description
- custom `Other` text is searchable immediately and creates category suggestions
- minimum 3 ready public photos before publish
- publish updates search text/vector, ranking, photo count, and last activity
- deleted is soft delete

## 10. Work-Needed Posts

Owner endpoints:

- `GET /v1/me/work-needed-posts`
- `POST /v1/me/work-needed-posts`
- `PATCH /v1/me/work-needed-posts/{post_id}`
- `POST /v1/me/work-needed-posts/{post_id}/publish`
- `POST /v1/me/work-needed-posts/{post_id}/pause`
- `POST /v1/me/work-needed-posts/{post_id}/resume`
- `POST /v1/me/work-needed-posts/{post_id}/close`
- `DELETE /v1/me/work-needed-posts/{post_id}`

Rules:

- only business profiles can own work-needed posts
- draft support is required
- publish requires required fields and minimum 3 ready public photos
- closed posts do not require close reason in MVP
- active posts are searchable

## 11. Media Upload

Endpoints:

- `POST /v1/media/upload-intent`
- `POST /v1/media/{media_asset_id}/complete`
- `POST /v1/media/{media_asset_id}/retry`
- `POST /v1/media/{media_asset_id}/cancel`
- `DELETE /v1/media/{media_asset_id}`

Rules:

- backend creates a pending media record before issuing upload details
- signed direct-to-storage upload is scoped to one backend-generated private staging path and expires after two hours
- the client uploads as multipart `PUT` using form field `file`
- backend downloads and validates actual bytes before promoting public images to the public bucket
- fallback to backend-proxied upload if signed upload cannot be secured
- public photos and private verification documents use separate storage areas
- first uploaded ready image is cover
- upload order is carousel order
- no reorder/cover picker in MVP
- deletion is blocked if it would drop below required photo minimum
- owner cannot preview/download private verification proof after upload
- cancel marks an abandoned pending/failed media row as deleted

## 12. Verification

Owner endpoints:

- `GET /v1/me/verification`
- `POST /v1/me/verification/prepare`
- `POST /v1/me/verification/submit`
- `POST /v1/me/verification/resubmit`
- `GET /v1/me/verification/cases/{case_id}`

Admin endpoints:

- `GET /v1/admin/verification-cases`
- `GET /v1/admin/verification-cases/{case_id}`
- `POST /v1/admin/verification-cases/{case_id}/approve`
- `POST /v1/admin/verification-cases/{case_id}/request-changes`
- `POST /v1/admin/verification-cases/{case_id}/reject`

Rules:

- manual admin review in MVP
- blue tick only after admin final approval
- verification is free
- optional ID/GST proof is supporting evidence
- `prepare` creates the draft case needed to scope optional private proof uploads before submission
- no raw Aadhaar/PAN/identity number storage
- one active verification case per profile
- pending verification locks profile edits
- rejected profile stays public but unverified
- owner sees simple status and admin message only
- private proof documents retained during private MVP with admin-only audited access

## 13. Saved Items, Reports, Notifications, Contact, Share

### 13.1 Saved Items

- `GET /v1/me/saved-items`
- `POST /v1/me/saved-items`
- `DELETE /v1/me/saved-items/{saved_item_id}`

Saved target types:

- `profile`
- `work_card`
- `work_needed_post`

Saved create/remove are idempotent.

Each saved-item response includes `profile_role` so the mobile app can group
privacy-safe cards into Business, Job Worker, and Karigar tabs without guessing.

### 13.2 Reports

`POST /v1/reports`

Report target types:

- `profile`
- `work_card`
- `work_needed_post`

Reasons:

- `wrong_contact`
- `wrong_category`
- `inappropriate_photo`
- `wrong_details`
- `fake_profile`
- `spam`
- `other`

Repeated reports are allowed and stored. Admin queue groups them.

### 13.3 Notifications

- `GET /v1/me/notifications`
- `POST /v1/me/notifications/{notification_id}/read`
- `POST /v1/me/device-tokens`

In-app notifications are always stored. Push can be disabled by user settings.

### 13.4 Settings

- `GET /v1/me/settings`
- `PATCH /v1/me/settings`

Settings:

- push notification enabled/disabled
- hide from search

### 13.5 Contact Actions

`POST /v1/contact-actions`

Action types:

- `call`
- `whatsapp`
- `address`

Log event before opening external app where possible. Failure to log must not block the user action.

### 13.6 Share Links

`POST /v1/share-links`

Backend generates canonical share/deep links and logs share events.

Shared links must not expose contact/address directly without app/account rules.

## 14. Admin API

Admin endpoints are under `/v1/admin`.

MVP admin model:

- all active admins are super-admin
- database role support remains for future
- admin dashboard never writes directly to database tables
- every sensitive admin mutation writes audit log

Core admin capabilities:

- verification queue and decisions
- profile/user list
- seed profile creation
- moderation/status changes
- suspension/unsuspension
- report queue
- analytics summary
- CSV exports

Admin-created seed profiles:

- can be public/searchable before claimed
- are internally marked as admin-seeded
- can only be created from whitelisted profile fields in the Phase 24 dashboard

User-owned content:

- admin cannot directly edit public user-authored profile/work/post fields
- admin can request changes, moderate, remove, suspend, approve/reject, or change status fields

Exports:

- profiles
- verification cases
- reports
- search summary
- contact summary

Exports must exclude private proof document URLs and raw sensitive identity data.
Phase 24 generates the CSV synchronously, stores it in private storage, returns a
15-minute signed URL, and audit logs the export. Async export jobs can replace this
without changing the dashboard workflow when dataset size requires it.

## 15. Observability And Privacy

Request/device metadata may be logged:

- IP address
- user agent
- device id/install id
- platform
- app version

Rules:

- admin/system-only access
- retention policy needed before public launch
- do not log unnecessary hardware identifiers
- no raw Aadhaar/PAN/identity numbers
- no public proof-document URLs

## 16. Schema Corrections Required Before Implementation

Carry these into database migrations and code:

1. Job-worker completion requires at least one published valid work card.
2. Work-needed posts include `draft`; `publish` is an action and `active` is the public state.
3. Reports must not have a uniqueness constraint on reporter/target/reason.
4. Admin roles can exist in schema, but MVP auth treats all active admins as super-admin.
5. No product-visible rate-limit quota tables/fields in MVP responses.
6. Contact reveal is recorded once per viewer/profile when profile detail returns contact/address.
7. Re-verification after sensitive edits uses `verification_status = unverified` plus `reverification_required = true`.

## 17. Next Implementation Step

Use this document with:

- `api/openapi.yaml`
- `outputs/textile-marketplace-api-authorization-matrix.md`
- `outputs/textile-marketplace-screen-api-traceability.md`

Then implement backend modules in this order:

1. auth/session/me
2. profile completion
3. media upload
4. work cards/work-needed posts
5. search
6. profile detail/contact reveal
7. verification/admin review
8. saved/report/share/contact/notifications/settings
9. admin analytics/export

# Textile Marketplace MVP API Contract Discovery

Status: In discovery  
Created: 2026-07-09  
Target: Android-first private MVP for selected Surat users

## 1. Purpose

This file records product and policy decisions needed to design the MVP backend API contract.

It is not the final API specification and does not authorize backend implementation. After discovery is complete, it will be used to produce:

1. `outputs/textile-marketplace-mvp-api-contract.md`
2. `api/openapi.yaml`
3. `outputs/textile-marketplace-api-authorization-matrix.md`
4. `outputs/textile-marketplace-screen-api-traceability.md`
5. A reviewed backend implementation plan

## 2. Decision Method

- Ask questions in focused rounds.
- Before preparing **every question round**, fully re-read the current versions of these three mandatory source documents:
  1. `outputs/textile-marketplace-database-design.md`
  2. `outputs/textile-marketplace-figma-wireframe-spec.md`
  3. `outputs/textile-marketplace-mvp-system-design.md`
- Also re-read this API discovery file before every round so previously approved API decisions are not asked again.
- Read other discovery and flow documents whenever the current topic needs additional context.
- Do not repeat decisions already settled in requirements, app-flow, wireframe, or database discovery.
- Ask the product owner only about choices that affect user behaviour, permissions, privacy, trust, cost, or business policy.
- The architect chooses routine technical conventions such as JSON naming, standard HTTP status codes, resource naming, and internal code organization.
- Do not ask a question merely because it is normally included in an API checklist. Ask it only when the existing documents do not already provide a reliable answer and the decision would materially affect the contract.
- Before asking a question, deeply evaluate:
  - what the existing documents already require;
  - whether the question is genuinely unresolved;
  - the likely consequences of each realistic answer;
  - effects on the wireframe, database, API, security, privacy, cost, and MVP timeline;
  - whether the choice should belong to the product owner or should be an architect-owned default.
- For every product-owner question:
  - explain the decision in plain language;
  - provide two or more realistic options when alternatives genuinely exist;
  - state concrete advantages and disadvantages for each option;
  - identify the recommended option and explain why it best fits this marketplace;
  - clearly mark any assumption or uncertainty;
  - ask the product owner to approve, reject, or modify the recommendation.
- Do not present artificial alternatives when only one responsible implementation is acceptable. In that case, state the proposed architect-owned decision and its reasoning for review.
- After receiving answers, do not immediately move to another round. First:
  1. compare every answer with the three mandatory source documents and prior API decisions;
  2. identify conflicts or ambiguity instead of silently resolving them;
  3. interpret the answer into a precise API/product decision;
  4. append the result to this file;
  5. record its API, authorization, database, wireframe, and security implications;
  6. list any remaining uncertainty;
  7. update the discovery progress table.
- Preserve the product owner's meaning. Do not replace an answer with the architect's preference without explicit approval.
- Start the next round only after the previous round has been saved and verified in this file.

### 2.1 Mandatory Pre-Round Evidence

Before each round, the working update must confirm:

- all three mandatory documents were read from disk in their current form;
- this discovery file was read;
- settled decisions relevant to the round were extracted;
- duplicate or already-answered questions were removed;
- remaining questions passed the material-impact test.

The reread cannot be replaced by conversation memory, a previous summary, or an older review.

### 2.2 Required Answer Record Format

Each completed round must be appended using this structure:

```markdown
### Question N: Short decision name

**Options presented**

- Option A: ...
- Option B: ...

**Architect recommendation before answer**

...

**Product owner answer**

...

**Accepted decision**

...

**Reasoning**

...

**Contract implications**

- Endpoints:
- Authorization:
- Validation:
- Database:
- Wireframe/client states:
- Security/privacy:

**Remaining uncertainty**

...
```

The product owner's answer may be normalized for clarity, but its meaning must not be changed.

## 3. Source Documents

- `outputs/textile-marketplace-requirements-discovery.md`
- `outputs/textile-marketplace-app-flow-spec.md`
- `outputs/textile-marketplace-figma-wireframe-spec.md`
- `outputs/textile-marketplace-database-schema-discovery.md`
- `outputs/textile-marketplace-database-design.md`
- `outputs/textile-marketplace-mvp-system-design.md`
- `outputs/textile-marketplace-autoplan-review.md`

## 4. Locked Decisions Carried Forward

### Product boundary

- The MVP is an Android-only private demo for selected Surat users.
- It is a discovery, directory, verification, and lead-generation product.
- Order management, marketplace payments, ratings, chat, voice search, maps, iOS, and automated KYC are outside the MVP.

### Client and backend boundary

- Flutter and the admin dashboard call a backend API/BFF.
- The mobile app does not directly write marketplace tables.
- Supabase-managed PostgreSQL, Auth, and Storage are infrastructure behind the backend boundary.
- Service-role or database credentials are never exposed to mobile or browser clients.
- RLS remains enabled as defence in depth.

### Identity and account

- Account creation requires name, mobile number, and OTP verification.
- Role selection occurs after OTP verification.
- One active mobile number maps to one active account.
- One account owns one role-specific profile.
- Role becomes immutable after profile completion.
- Terminated accounts release the mobile number for a new account.

### Marketplace objects

- Published work cards are the main searchable objects for job workers.
- Work-needed posts are separate manufacturer demand objects.
- Profiles appear in search only after minimum role-specific completion.
- Public result cards do not expose contact number or full address.
- Contact number and full address are visible on profile detail during the free private MVP.

### Verification and sensitive data

- Verification is manually reviewed by admins in the MVP.
- A blue tick appears only after final admin approval.
- Verification supports pending, approved, changes-requested, and rejected outcomes.
- Identity proofs and verification documents are private and admin-only.
- No Aadhaar number or PAN is stored.
- Optional identity proof and GST proof are supporting evidence, not automatic verification.

### Search

- Search supports one target persona at a time.
- PostgreSQL full-text search, trigram matching, categories, aliases, and local terms are used first.
- Search must support filters, sorting, suggestions, and pagination.
- Search activity is logged for quality analysis.

## 5. Planned Discovery Rounds

1. Authentication, session, account creation, and role confirmation
2. Profile completion, editing, visibility, and public/private response fields
3. Search requests, result responses, filters, sorting, and pagination
4. Work-card and work-needed-post creation and lifecycle
5. Media upload, processing, ordering, privacy, and deletion
6. Verification submission, admin review, locking, and resubmission
7. Saved items, reports, notifications, contact actions, and analytics
8. Admin permissions, exports, audit, suspension, and seed profiles
9. Cross-cutting API behaviour: errors, retries, idempotency, rate limits, versioning, observability, and compatibility
10. Final conflict review and scope lock

The number of rounds can decrease when existing documents already answer a topic completely.

## 6. Architect-Owned Defaults

Unless a later product decision requires otherwise:

- REST over HTTPS with JSON.
- Resource-oriented URLs that do not mirror database table access.
- OpenAPI 3.1 as the contract format.
- `/v1` API version prefix.
- UUID identifiers represented as strings.
- ISO 8601 UTC timestamps.
- A consistent structured error envelope with stable machine-readable error codes.
- Cursor pagination for changing search feeds and offset-free large collections.
- Bounded page sizes.
- Server-enforced authorization and validation.
- Idempotency protection for retryable create/submit operations.
- Optimistic concurrency or explicit state checks for sensitive status transitions.
- Request IDs, structured logs, audit records, and latency/error metrics.
- Backward-compatible additive changes during the MVP.

## 7. Discovery Progress

| Round | Topic | Status |
|---|---|---|
| 1 | Authentication, session, account, role | Complete |
| 2 | Profile contract and visibility | Complete |
| 3 | Search contract | Complete |
| 4 | Work and work-needed lifecycle | Complete |
| 5 | Media | Complete |
| 6 | Verification | Complete |
| 7 | User actions and notifications | Complete |
| 8 | Admin | Complete |
| 9 | Cross-cutting API behaviour | Complete |
| 10 | Final review | Complete |

## 8. Round 1: Authentication, Session, Account, And Role

Status: Completed after product-owner answers on 2026-07-10.

### 8.1 Mandatory Pre-Round Evidence

Read in full from disk on 2026-07-09 before preparing this round:

1. `outputs/textile-marketplace-database-design.md`
2. `outputs/textile-marketplace-figma-wireframe-spec.md`
3. `outputs/textile-marketplace-mvp-system-design.md`
4. `outputs/textile-marketplace-api-contract-discovery.md`

Additional current sections checked:

- account and first-open flow in `outputs/textile-marketplace-app-flow-spec.md`
- authentication, age, consent, and all-India decisions in `outputs/textile-marketplace-requirements-discovery.md`

### 8.2 Settled Decisions Extracted Before Asking Questions

- New-user sequence remains: name and mobile -> OTP -> role selection -> full-screen role confirmation -> Home.
- Search and exact contact/address access require OTP-authenticated accounts.
- Returning users with a valid stored session go directly from Splash to Home.
- Mobile OTP is the only MVP login method.
- SMS is the MVP OTP delivery channel.
- Registration supports users throughout India; international registration is not an MVP requirement.
- One active mobile number maps to one active account.
- One account owns one role-specific profile.
- Role selection cannot be skipped and becomes immutable after profile completion.
- An interrupted user who has verified OTP but not confirmed a role must resume at role selection.
- Role confirmation must atomically assign the user role and create the matching profile shell.
- Logout is available in Settings and does not require a confirmation dialog.
- Age restriction was explicitly rejected for the initial product, so this round will not reopen it.
- Self-service account termination is shown as future scope in the app-flow specification, while the database supports terminated accounts and mobile-number reuse.
- General terms/privacy are required before public launch; verification-document consent is represented separately in the database.
- The mobile app and admin dashboard cannot directly write marketplace tables.
- Whether Supabase Auth itself is called directly by Flutter or proxied through the backend remains unresolved.

### 8.3 Duplicate Or Non-Material Questions Removed

This round will not ask again:

- whether OTP is required;
- whether role selection occurs before or after OTP;
- whether users can have multiple roles;
- whether role can change after completion;
- whether search is available before login;
- whether the app supports users across India;
- whether the MVP has an age restriction;
- whether logout needs confirmation;
- OTP digit count, HTTP status codes, token field names, or endpoint naming.

### 8.4 Architect-Owned Defaults Proposed For Round 1

Unless the product-owner answers require a change:

- Normalize Indian mobile numbers to E.164 `+91XXXXXXXXXX`.
- Do not create an application `users` row before OTP succeeds.
- Do not persist an unverified name as an application user.
- Return generic OTP-request responses that do not reveal whether a mobile number already has an account.
- Use provider-backed OTP expiry, resend cooldown, attempt limits, IP/device rate limits, and abuse monitoring.
- Store access and refresh tokens only in Android secure storage.
- Send the access token only to the marketplace backend API.
- After OTP verification, return an explicit onboarding state such as `role_selection_required`, `home`, or `account_blocked`.
- Make role confirmation idempotent so retries cannot create duplicate profiles.
- Make normal logout revoke only the current device session; an all-device logout can be added later.

These are technical defaults, not yet recorded as accepted product-owner decisions.

### 8.5 Material Decisions Requiring Product-Owner Approval

1. Supabase Auth integration boundary.
2. Returning-user behaviour on the existing name-and-mobile screen.
3. Session lifetime.
4. Multiple-device session policy.
5. General terms/privacy consent during the private MVP.
6. Suspended-account access behaviour.

Answers saved below.

### Question 1: Supabase Auth Integration Boundary

**Options presented**

- Option A: Backend-proxied Supabase Auth. Flutter calls marketplace backend endpoints for OTP request, OTP verification, refresh, and logout. The backend calls Supabase Auth and returns the app session.
- Option B: Flutter calls Supabase Auth directly, then calls marketplace backend for all marketplace data.
- Option C: Fully custom OTP and session service.

**Architect recommendation before answer**

Option A. It best matches the already-accepted boundary that the app calls the backend and the backend calls infrastructure/database services. It costs more backend work than the fastest Supabase SDK path, but it avoids training the Flutter app around direct Supabase access.

**Product owner answer**

Option A: Backend-proxied Supabase Auth.

**Accepted decision**

The MVP auth contract will use backend-proxied Supabase Auth. Flutter will call the marketplace backend for OTP request, OTP verification, refresh/session handling, and logout. Supabase Auth remains infrastructure behind the backend boundary.

**Reasoning**

This keeps the security and product architecture consistent: frontend -> backend API/BFF -> Supabase Auth/PostgreSQL/Storage. It also keeps future migration easier because Flutter depends on the app API contract, not Supabase client semantics.

**Contract implications**

- Endpoints: include `POST /v1/auth/request-otp`, `POST /v1/auth/verify-otp`, `POST /v1/auth/refresh`, and `POST /v1/auth/logout`.
- Authorization: auth endpoints are public except refresh/logout; marketplace endpoints require backend-validated bearer session.
- Validation: backend normalizes Indian mobile numbers, rate-limits OTP requests, and returns generic request responses.
- Database: app `users` row is created or looked up only after OTP succeeds; `auth_user_id` maps to Supabase Auth user id.
- Wireframe/client states: OTP screens remain, but the client treats account creation and login as the same OTP-backed flow.
- Security/privacy: Supabase service role and database credentials never appear in Flutter; failed OTP attempts do not create app users.

**Remaining uncertainty**

The exact Supabase Auth operational method will be selected during implementation, but the public API boundary is locked.

### Question 2: Returning User After Logout Or Reinstallation

**Options presented**

- Option A: Preserve the current wireframe exactly: name + mobile + OTP for everyone; if the mobile already exists, ignore the entered name.
- Option B: Mobile-first adaptive onboarding. User enters mobile, verifies OTP, and the backend decides whether this is an existing account or a new account. Existing users go Home; new users continue to name and role selection.
- Option C: Separate Login and Create Account screens.

**Architect recommendation before answer**

Option B. It is the cleanest product behavior for real users because logout/reinstall should feel like signing in again, not like creating a duplicate account. It does require a correction to the current wireframe/spec because the existing Create Account screen puts name before OTP.

**Product owner answer**

Option B: Mobile-first adaptive onboarding. If the user logs out or reinstalls, the app behaves like a new app open: the user verifies the mobile number again, and the backend identifies whether this mobile already has an account.

**Accepted decision**

Use adaptive OTP onboarding. After OTP verification:

- If the mobile belongs to an active existing user with a confirmed role, return `next_state = home`.
- If the mobile is new, return `next_state = complete_basic_account` or equivalent, then collect name and role.
- If OTP was verified but role was not confirmed earlier, return `next_state = role_selection_required`.
- If the account is suspended, return `next_state = account_blocked`.

**Reasoning**

One mobile number maps to one active account. Returning users should not create or overwrite profile identity just because the app was reinstalled or the user logged out. The backend must be the source of truth for whether the mobile is new, existing, incomplete, or blocked.

**Contract implications**

- Endpoints: `POST /v1/auth/verify-otp` must return user/session plus onboarding state.
- Authorization: role/account-completion endpoints require the verified session returned from OTP.
- Validation: do not allow duplicate active users for the same normalized mobile.
- Database: user creation is conditional after OTP success; existing users update `last_login_at` and session/device records.
- Wireframe/client states: the wireframe should be corrected from a pure `Create Account` first screen to an OTP-first adaptive entry flow, or the current screen must be interpreted as a combined sign-in/create flow.
- Security/privacy: OTP request responses must not reveal whether a mobile is registered; only OTP-verified users receive account state.

**Remaining uncertainty**

The final UI copy can still say `Continue` instead of `Login`, but the API behavior is adaptive.

### Question 3: Session Lifetime

**Options presented**

- Option A: Remain logged in until logout, suspension, or token revocation.
- Option B: Expire after 30 days of inactivity.
- Option C: Force OTP again every 30 days.

**Architect recommendation before answer**

Option A. It is the lowest-friction MVP behavior and matches user expectations for an Android marketplace app.

**Product owner answer**

Option A: Remain logged in until logout, suspension, or token revocation.

**Accepted decision**

Sessions should persist across normal app restarts. Users remain logged in unless they explicitly logout, the account is suspended, tokens are revoked, or the refresh/session mechanism fails and requires OTP again.

**Reasoning**

The app is low-literacy and usage may be intermittent. Frequent re-login adds friction without improving MVP trust meaningfully.

**Contract implications**

- Endpoints: `POST /v1/auth/refresh` supports session renewal where needed.
- Authorization: backend rejects revoked, expired, terminated, or suspended sessions.
- Validation: secure session refresh must be tied to valid provider/session state.
- Database: update `last_login_at`, device/session metadata, and revocation status where applicable.
- Wireframe/client states: Splash can route directly to Home when a valid session exists.
- Security/privacy: refresh tokens must be stored only in secure Android storage.

**Remaining uncertainty**

Implementation will follow the provider's concrete token lifetime model while preserving this product behavior.

### Question 4: Multiple Active Devices

**Options presented**

- Option A: Allow multiple active devices.
- Option B: Keep only the newest session.
- Option C: Allow a maximum of two active devices.

**Architect recommendation before answer**

Option A for MVP. It avoids support issues when users change phones, reinstall, or share access in a small workshop context.

**Product owner answer**

Option A: Allow multiple active devices for MVP.

**Accepted decision**

Allow multiple active sessions/devices per user in the MVP.

**Reasoning**

The private demo does not need strict device control. Search, profile completion, and contact actions benefit more from low friction than from single-device enforcement.

**Contract implications**

- Endpoints: device registration endpoint should upsert FCM/device records.
- Authorization: any valid active session for an active user can access the app.
- Validation: device identifiers and push tokens should be updated on login/app start.
- Database: `user_devices` can store multiple active device rows per user.
- Wireframe/client states: no special multi-device UI in MVP.
- Security/privacy: suspicious activity can be logged, but no user-facing device management is required now.

**Remaining uncertainty**

All-devices logout and device list management are future features.

### Question 5: General Terms And Privacy Consent

**Options presented**

- Option A: Capture explicit Terms/Privacy acceptance during onboarding and store accepted document version plus timestamp after OTP succeeds. Verification-document consent remains separate.
- Option B: Show notice text only; continuing means acceptance.
- Option C: Defer general consent until public launch.

**Architect recommendation before answer**

Option A. Even for private testing, real user data, contact details, photos, and verification uploads create privacy obligations. Store only proof of accepted document version/timestamp, not unnecessary consent metadata.

**Product owner answer**

Store the accepted document version and timestamp only after OTP succeeds. Verification-document consent remains separate.

**Accepted decision**

General Terms/Privacy acceptance is required in onboarding for real-user testing, but it is persisted only after OTP succeeds and the mobile has been verified. Verification-document/upload consent remains a separate consent/check during verification submission.

**Reasoning**

Do not store consent against an unverified mobile number. Once OTP succeeds, the user identity is traceable enough to record accepted policy version and timestamp.

**Contract implications**

- Endpoints: OTP verification or basic-account completion must accept consent version fields, or a dedicated `POST /v1/me/consents` endpoint must be available before Home access.
- Authorization: consent persistence requires a verified session.
- Validation: backend verifies current terms/privacy versions and rejects missing required consent before allowing normal app access.
- Database: add a `user_consents` table or equivalent to store `user_id`, `consent_type`, `document_version`, `accepted_at`; keep verification consent separate on verification submission/cases.
- Wireframe/client states: entry flow needs a small consent checkbox/link before completion; final UI correction required.
- Security/privacy: minimize stored data to document version and timestamp; do not store raw unnecessary consent text per user.

**Remaining uncertainty**

The database design currently does not explicitly list `user_consents`; this must be added in the final API/database correction pass.

### Question 6: Suspended Account Behaviour

**Options presented**

- Option A: Block access except Logout and Contact Support.
- Option B: Permit search but hide contact/actions.
- Option C: Permit normal app access but hide own profile.

**Architect recommendation before answer**

Option A. Suspension should be clear and enforceable. Partial access creates trust and abuse loopholes.

**Product owner answer**

Option A: Block access except Logout and Contact Support.

**Accepted decision**

Suspended users cannot use marketplace features. They can only see a blocked-account state with Logout and Contact Support actions.

**Reasoning**

Suspension is an admin safety control. A suspended user should not be able to search, view contacts, post work, upload media, or contact other profiles.

**Contract implications**

- Endpoints: most `/v1` endpoints return a structured `account_suspended` error for suspended users; support/logout endpoints remain available.
- Authorization: account status is checked on every authenticated request, not only at login.
- Validation: suspended users cannot mutate profile/work/media/verification data.
- Database: `users.account_status = 'suspended'` drives access; profile may also be `suspended_by_admin` if public visibility must be removed.
- Wireframe/client states: add blocked-account state later if not already in wireframe; Settings/Logout and Contact Support remain reachable.
- Security/privacy: reduces misuse risk after admin action; all suspension-related admin actions must be audit logged.

**Remaining uncertainty**

Support channel details remain future/lightweight, but WhatsApp/call support is already accepted in Settings.

### Round 1 Architect-Owned Defaults Accepted

The product-owner answers did not conflict with the proposed technical defaults, so these defaults are accepted for the API contract unless later implementation constraints force a reviewed change:

- Normalize Indian mobile numbers to E.164 `+91XXXXXXXXXX`.
- Do not create an application `users` row before OTP succeeds.
- Do not persist an unverified name as an application user.
- Return generic OTP-request responses that do not reveal whether a mobile number already has an account.
- Use provider-backed OTP expiry, resend cooldown, attempt limits, IP/device rate limits, and abuse monitoring.
- Store access and refresh tokens only in Android secure storage.
- Send the access token only to the marketplace backend API.
- After OTP verification, return an explicit onboarding state such as `role_selection_required`, `home`, `complete_basic_account`, or `account_blocked`.
- Make role confirmation idempotent so retries cannot create duplicate profiles.
- Make normal logout revoke only the current device session; all-device logout can be added later.

## 9. Round 2: Profile Contract, Editing, Visibility, And Public Response Fields

Status: Completed after product-owner answers on 2026-07-10.

### 9.1 Mandatory Pre-Round Evidence

Read from disk on 2026-07-10 before preparing this round:

1. `outputs/textile-marketplace-database-design.md`
2. `outputs/textile-marketplace-figma-wireframe-spec.md`
3. `outputs/textile-marketplace-mvp-system-design.md`
4. `outputs/textile-marketplace-api-contract-discovery.md`

Additional relevant sections considered from the already-approved source set:

- My Profile, profile completion, owner views, and settings behavior in the Figma wireframe spec.
- `users`, `profiles`, role-specific tables, profile visibility, completion scoring, and profile change history in the database design.
- data access rules, profile APIs, security boundary, and MVP contact visibility in the MVP system design.
- Round 1 accepted decisions for backend-proxied auth, adaptive onboarding, session state, and suspended account behavior.

### 9.2 Settled Decisions Extracted Before Asking Questions

- One active user owns one active role-specific profile.
- Role selection creates the matching profile shell after OTP verification and role confirmation.
- Role cannot change after profile completion.
- Profiles appear in search only after minimum role-specific required fields are complete.
- Incomplete profiles can be saved and completed later.
- My Profile shows owner-only controls plus a public-preview style profile view.
- Public result cards never show contact number or full address.
- Profile detail can show contact number and full address during the free MVP.
- Public users see only the blue tick, not verification breakdown.
- Owner name and mobile number are locked after completion.
- Profile editing while verification is pending is locked.
- Sensitive changes are recorded in `profile_change_history` and can require re-verification.
- Users can temporarily hide their profile from search through Settings.
- Suspended accounts are blocked except Logout and Contact Support.

### 9.3 Duplicate Or Non-Material Questions Removed

This round will not ask again:

- which fields each role collects;
- whether incomplete profiles can be saved;
- whether role changes are allowed;
- whether contact/address appears on result cards;
- whether profile detail shows contact/address in MVP;
- whether verification details are public;
- whether owner name/mobile are locked;
- whether a Settings screen exists;
- whether a profile can be hidden from search;
- exact JSON key names, HTTP status codes, or component naming.

### 9.4 Architect-Owned Defaults Proposed For Round 2

Unless the product-owner answers require a change:

- Use `GET /v1/me` for app bootstrap: user, role, profile shell, completion state, verification status summary, and allowed next actions.
- Use `GET /v1/me/profile` for owner profile detail including draft/private owner-only fields and edit permissions.
- Use `PATCH /v1/me/profile` for draft profile updates and role-specific profile fields.
- Use `POST /v1/me/profile/complete` or equivalent for the state transition from draft/incomplete to completed/public.
- Use `GET /v1/profiles/{profile_id}` for public profile detail.
- Public profile responses include contact/address in MVP only after backend authorization and contact-reveal logging.
- Owner-only responses include missing-field flags, completion score, verification status, and editable/locked field metadata.
- Public responses do not include internal verification checklist, private media, admin notes, search logs, or audit data.
- Backend calculates `completion_score`, `completion_flags`, `visibility_status`, and search eligibility; the client only displays them.
- Backend records `profile_change_history` for meaningful profile edits.
- Backend treats `hidden_by_user`, `suspended_by_admin`, and `deleted` as non-searchable states.
- Profile writes must be idempotent or safe to retry where mobile networks can duplicate requests.

These are technical defaults, not yet recorded as accepted product-owner decisions.

### 9.5 Material Decisions Requiring Product-Owner Approval

1. Whether completing minimum required profile fields automatically makes the profile public/search-visible, or whether a separate publish action is needed.
2. Whether a job-worker profile can show as 100% complete before the first work card is published.
3. How verified profiles behave after the owner edits sensitive public fields.
4. What `Hide from search` means for old saved profiles and shared/direct profile links.
5. Whether opening a profile detail should automatically count as contact/address reveal in the MVP API.

Answers saved below.

### Question 1: Profile Completion Publish Behavior

**Options presented**

- Option A: Auto-public after the user taps final `Save` once required fields are complete.
- Option B: Separate `Publish profile` action.
- Option C: Keep hidden until admin verification.

**Architect recommendation before answer**

Option A. It is simple, matches the "complete profile to get business" product promise, and supports the low-friction private launch.

**Product owner answer**

Option A.

**Accepted decision**

After required role-specific profile fields are complete, tapping final `Save` completes the profile and makes it public/search-eligible according to the role's search rules. There is no separate `Publish profile` action in the MVP.

**Reasoning**

The MVP must reduce friction. A separate publish step creates another state users may not understand. Admin verification controls the blue tick, not whether a basic completed profile can be visible.

**Contract implications**

- Endpoints: `POST /v1/me/profile/complete` or equivalent completes and publishes the profile in one transition.
- Authorization: only the profile owner can complete their profile; suspended users cannot.
- Validation: backend enforces required fields and required media counts before completion.
- Database: set `profiles.visibility_status = 'public'` when completion succeeds, unless the user has explicitly hidden the profile.
- Wireframe/client states: final profile screen keeps `Save` and `Verify My Profile`; no separate publish CTA.
- Security/privacy: user consent for profile publishing/contact visibility must be recorded before or during completion.

**Remaining uncertainty**

Final API/database correction must align this with the new adaptive onboarding and consent decisions.

### Question 2: Job Worker Completion Versus First Work Card

**Options presented**

- Option A: Profile can be 100% complete, but job worker appears in work search only after at least one published work card.
- Option B: Do not mark job-worker profile 100% until first work card exists.
- Option C: Auto-create first work card from profile details.

**Architect recommendation before answer**

Option A. It keeps profile completeness separate from marketplace search readiness. Work cards remain the proper searchable unit for job-worker services.

**Product owner answer**

The answer was labelled `2B`, but the written decision matches Option A: profile can be 100% complete, but a job worker appears in work search only after at least one published work card. During profile completion, the app should ask the job worker to add at least one work.

**Accepted decision**

Job-worker profile completion and job-worker work-search readiness are separate states:

- A job-worker profile can show 100% profile completion after required profile fields and workplace/shop photos are complete.
- The job worker does not appear in job-worker work search until at least one work card is published.
- The profile-completion flow should strongly prompt or route the user to add at least one work card.

**Reasoning**

This avoids fake or low-quality work cards while still letting the user finish their profile. Search must return actual work cards because the user searches for work like flat hemming, embroidery, digital print, etc.

**Contract implications**

- Endpoints: `GET /v1/me` should return both `completion_score` and a separate readiness flag such as `work_search_ready`.
- Authorization: only job-worker users can create work cards under their profile.
- Validation: profile completion does not require a published work card; work-search eligibility does.
- Database: current database design says a job worker needs at least one published work card for minimum complete profile; this is now a known correction. Final schema/API docs should separate `profile_completed_at` or `completion_score` from work-card search eligibility.
- Wireframe/client states: after job-worker profile completion, show a strong prompt such as `Add your first work to appear in search`.
- Security/privacy: no added sensitive data risk.

**Remaining uncertainty**

The final database design should be corrected so "minimum complete profile" does not conflict with "work-search ready" for job workers.

### Question 3: Verified Profile Sensitive Edits

**Options presented**

- Option A: Keep profile public, remove blue tick or mark re-verification needed until admin approves again.
- Option B: Hide profile until admin re-approves.
- Option C: Keep old public version while new edits wait for approval.

**Architect recommendation before answer**

Option A. It keeps active businesses discoverable while protecting trust by removing the verified signal until the new information is reviewed.

**Product owner answer**

Option A: Keep profile public, remove blue tick / mark re-verification needed until admin approves again.

**Accepted decision**

If a verified profile owner edits sensitive public fields, the profile remains public, but the blue tick is removed and verification status changes to a re-verification-needed state until admin approval.

**Reasoning**

This balances marketplace liquidity with trust. The profile should not disappear immediately, but the app must not show verified status for changed data that admin has not reviewed.

**Contract implications**

- Endpoints: `PATCH /v1/me/profile` must detect sensitive field changes and update verification state.
- Authorization: owner can edit allowed fields except locked fields; suspended users cannot.
- Validation: mobile number and locked owner-name rules still apply.
- Database: create `profile_change_history` rows with `requires_reverification = true`; update `profiles.verification_status` from `verified` to `unverified` or `changes_requested` based on final state naming; set `is_verified = false`.
- Wireframe/client states: owner sees re-verification needed; public users simply stop seeing the blue tick.
- Security/privacy: admin audit/change history is required for trust-sensitive edits.

**Remaining uncertainty**

Final status naming should decide whether this API state is `unverified`, `changes_requested`, or a new `reverification_required`. The current database allowed statuses do not include `reverification_required`.

### Question 4: Hide From Search Scope

**Options presented**

- Option A: Remove from search/recommended/similar lists, but old saved/direct links still open profile.
- Option B: Remove from search and block other users from opening old saved/direct links.

**Architect recommendation before answer**

Option B was recommended for stronger privacy, but Option A is still a valid literal "hide from search" behavior.

**Product owner answer**

Option A: Remove from search/recommended/similar lists, but old saved/direct links still open profile.

**Accepted decision**

`Hide from search` means the profile is removed from search results, recommended lists, and similar profiles. Existing saved items and direct/shared profile links can still open the profile.

**Reasoning**

The user-facing meaning is specifically "hide from search", not "make private". This preserves saved/direct access while keeping the profile out of discovery feeds.

**Contract implications**

- Endpoints: settings/profile visibility endpoint updates `profiles.visibility_status = 'hidden_by_user'`.
- Authorization: only the owner can hide or unhide their profile; suspended profiles remain admin-controlled.
- Validation: hidden profiles are excluded from search feeds even if complete.
- Database: `hidden_by_user` must be treated as non-searchable but not deleted or inaccessible by id.
- Wireframe/client states: Settings warning should say the profile will not appear in search, not that nobody can view it.
- Security/privacy: this is not a privacy lock. Sensitive fields still require normal authenticated profile-detail authorization and contact-reveal logging.

**Remaining uncertainty**

If users later expect true private mode, this behavior must be revisited.

### Question 5: Profile Detail Contact Reveal Behavior

**Options presented**

- Option A: Opening profile detail automatically returns contact/address and records a `contact_reveals` row.
- Option B: Profile detail loads public info first, then app silently calls a second reveal API for contact/address.
- Option C: Return contact/address with no reveal record.

**Architect recommendation before answer**

Option A. It matches the MVP UI while preserving analytics and future paid-contact logic.

**Product owner answer**

Option A: Opening profile detail automatically returns contact/address and records a `contact_reveals` row.

**Accepted decision**

During the free MVP, opening a profile detail automatically returns contact number and full address when the viewer is authorized, and the backend creates or updates one `contact_reveals` record for the viewer/profile pair.

**Reasoning**

The MVP wireframe shows contact/address directly on profile detail. Recording the reveal creates analytics and future quota/subscription compatibility without adding UI friction.

**Contract implications**

- Endpoints: `GET /v1/profiles/{profile_id}` records a reveal when returning contact/address, or internally calls a reveal service as part of the request.
- Authorization: viewer must be authenticated, active, and not suspended.
- Validation: one reveal counts only once per `viewer_user_id + revealed_profile_id`; repeated profile opens update `last_revealed_at` and `reveal_count`.
- Database: use `contact_reveals` unique `(viewer_user_id, revealed_profile_id)`; include optional `source_type/source_id`.
- Wireframe/client states: no separate `Show Contact` action in MVP.
- Security/privacy: profile detail access is traceable; IP/device/user-agent can be stored where available.

**Remaining uncertainty**

Later paid phase can split public-detail and contact-reveal APIs without changing the MVP UI immediately.

### Round 2 Architect-Owned Defaults Accepted

The product-owner answers did not conflict with these technical defaults, so they are accepted for the API contract unless later implementation constraints force a reviewed change:

- Use `GET /v1/me` for app bootstrap: user, role, profile shell, completion state, verification status summary, and allowed next actions.
- Use `GET /v1/me/profile` for owner profile detail including draft/private owner-only fields and edit permissions.
- Use `PATCH /v1/me/profile` for draft profile updates and role-specific profile fields.
- Use `POST /v1/me/profile/complete` or equivalent for the state transition from draft/incomplete to completed/public.
- Use `GET /v1/profiles/{profile_id}` for public profile detail.
- Public profile responses include contact/address in MVP only after backend authorization and contact-reveal logging.
- Owner-only responses include missing-field flags, completion score, verification status, editable/locked field metadata, and search-readiness flags.
- Public responses do not include internal verification checklist, private media, admin notes, search logs, or audit data.
- Backend calculates `completion_score`, `completion_flags`, `visibility_status`, work-search readiness, and search eligibility; the client only displays them.
- Backend records `profile_change_history` for meaningful profile edits.
- Backend treats `hidden_by_user`, `suspended_by_admin`, and `deleted` as non-searchable states.
- Profile writes must be idempotent or safe to retry where mobile networks can duplicate requests.

## 10. Round 3: Search Requests, Result Responses, Filters, Sorting, And Pagination

Status: Completed after product-owner answers on 2026-07-10.

### 10.1 Mandatory Pre-Round Evidence

Read from disk on 2026-07-10 before preparing this round:

1. `outputs/textile-marketplace-database-design.md`
2. `outputs/textile-marketplace-figma-wireframe-spec.md`
3. `outputs/textile-marketplace-mvp-system-design.md`
4. `outputs/textile-marketplace-api-contract-discovery.md`

Relevant sections considered:

- Searchable entities, search text composition, ranking fields, search indexes, and analytics tables in the database design.
- Home/search screens, result-card anatomy, filters, empty states, and critical search journey in the Figma wireframe spec.
- MVP search behavior, PostgreSQL search strategy, ranking formula, and API surface in the system design.
- Round 2 decisions separating public profile visibility from job-worker work-search readiness and making profile detail contact reveal automatic.

### 10.2 Settled Decisions Extracted Before Asking Questions

- Search requires an authenticated active user.
- Search supports one target persona at a time.
- Home has three find cards and Search has persona tabs.
- Search can be opened from Home with a preselected target persona or globally from bottom navigation.
- Before typing, Search shows recommended profiles/results for the selected persona.
- Job-worker search result cards are work-card first: work photos, work name, category, product type, job-worker name, blue tick if verified.
- Manufacturer result cards open manufacturer detail with Work Needed selected.
- Job-worker result cards open job-worker detail with Work List selected.
- Karigar result cards open karigar detail.
- Result cards do not show contact number or full address.
- Filters include category/work type, product type, locality, experience, and verified-only.
- Sorting includes verified first, nearby/locality, most photos, recently added, and similar flexible future sorts.
- No-results state should offer invite/share and clear filters when filters are active.
- Search logs are stored with raw query, normalized query, target persona, filters, result count, and timestamp.
- PostgreSQL FTS, trigram, category aliases, normalized locality, cached ranking fields, and search vectors are the MVP search backend.

### 10.3 Duplicate Or Non-Material Questions Removed

This round will not ask again:

- whether search is before or after login;
- whether search is global across all personas at once;
- whether persona tabs exist;
- whether result cards show contact/address;
- which filter names exist in the wireframe;
- whether aliases/local terms are needed;
- whether search logs are stored;
- whether OpenSearch/Meilisearch is needed in the MVP;
- exact SQL ranking weights or HTTP parameter names.

### 10.4 Architect-Owned Defaults Proposed For Round 3

Unless product-owner answers require a change:

- Use one search endpoint with `target_persona` rather than three separate endpoint families: `GET /v1/search`.
- Return a `result_type` for every item: `profile`, `work_card`, or `work_needed_post`.
- For `target_persona = job_worker`, primary results are published `work_cards`, not whole profiles.
- For `target_persona = business`, primary results can be business profiles and/or active work-needed posts depending on context.
- For `target_persona = skilled_worker`, primary results are skilled-worker profiles.
- Every result includes a compact card DTO specifically shaped for the mobile result card.
- Search responses include `applied_filters`, `available_filter_facets` where cheap, `sort`, `next_cursor`, `result_count`, and `search_log_id`.
- Recommended results use the same endpoint with empty query and a recommended/default sort.
- Search suggestions can be returned by a lightweight suggestions endpoint or included in search response when the query is short.
- Cursor pagination is used, with bounded page size.
- Backend logs searches after execution; client should not call a separate logging endpoint for normal searches.
- Backend never returns private verification data, raw search debug scores, contact number, or full address in search results.

These are technical defaults, not yet recorded as accepted product-owner decisions.

### 10.5 Material Decisions Requiring Product-Owner Approval

1. Whether business search should return business profile cards only, work-needed post cards only, or a mixed list.
2. Whether job-worker search should ever show a job-worker profile card when no specific work card matches.
3. What recommended results should prioritize before the user types.
4. How strict the first MVP search should be when the query is misspelled or ambiguous.
5. Whether search result count should show exact counts or avoid counts in the UI/API.

Answers saved below.

### Question 1: Business Search Result Mode

**Options presented**

- Option A: Business profile cards only.
- Option B: Work-needed post cards only.
- Option C: Mixed list of business profile cards plus work-needed post cards.

**Architect recommendation before answer**

Option C was recommended because it supports both business discovery and active demand discovery. However, it creates more mixed-card complexity.

**Product owner answer**

Use a tab/segmented choice inside business search. The user is asked what search they want to make: `Work Needed Posts` or `Profiles`. Default is `Work Needed Posts`.

**Accepted decision**

Business search will not use a single mixed list by default. It will have a second-level mode:

- `Work Needed Posts` default.
- `Profiles` when the user chooses direct business/profile search.

The selected business search mode controls which result-card type and backend query are used.

**Reasoning**

This keeps the UI clearer than a mixed list while still supporting both business use cases. A job worker looking for demand sees work-needed posts first. A user who wants to find businesses directly can switch to profiles.

**Contract implications**

- Endpoints: `GET /v1/search` should support `target_persona=business` plus a mode/scope parameter such as `business_search_mode=work_needed_posts|profiles`.
- Authorization: authenticated active user required.
- Validation: default mode is `work_needed_posts` when `target_persona=business` and no mode is supplied.
- Database: query either active `work_needed_posts` or public business `profiles`, not both unless a future mixed mode is added.
- Wireframe/client states: business search needs a secondary segmented control/tabs for `Work Needed Posts` and `Profiles`; default selected tab is `Work Needed Posts`.
- Security/privacy: result cards still do not expose contact number or full address.

**Remaining uncertainty**

The existing wireframe spec should be corrected to add this business-search sub-tab behavior.

### Question 2: Related Job-Worker Profiles When Work Cards Do Not Match

**Options presented**

- Option A: No, only show matching work cards.
- Option B: Yes, show related job-worker profiles below exact work-card matches.
- Option C: Only show invite/share empty state.

**Architect recommendation before answer**

Option B for early MVP. It reduces empty results while keeping exact work-card matches primary.

**Product owner answer**

Option B: show related job-worker profiles below exact work-card matches.

**Accepted decision**

Job-worker search primarily returns matching work cards. If exact or strong work-card matches are limited, the response may include a clearly separated `related_profiles` section below the work-card results.

**Reasoning**

Early supply will be sparse. Showing related profiles can help users discover possible providers without weakening the core rule that work cards are the main searchable object.

**Contract implications**

- Endpoints: `GET /v1/search` for `target_persona=job_worker` may return `items` plus `related_profiles`.
- Authorization: authenticated active user required.
- Validation: related profiles must still be public, complete, not hidden, not suspended, and role `job_worker`.
- Database: search work cards first; profile fallback uses profile search text/category/locality signals.
- Wireframe/client states: UI should label fallback profiles clearly, for example `Related job workers`.
- Security/privacy: no contact/address in related profile cards.

**Remaining uncertainty**

The exact threshold for showing related profiles is an implementation/ranking detail and should be tuned after demo data.

### Question 3: Recommended Results Before Query

**Options presented**

- Option A: Verified + complete + photo-rich profiles/work cards.
- Option B: Recently added first.
- Option C: Locality-first.

**Architect recommendation before answer**

Option A. It gives the strongest first impression and aligns with trust-first marketplace behavior.

**Product owner answer**

Option A: verified, complete, photo-rich profiles/work cards.

**Accepted decision**

Before the user types, recommended results should prioritize verified, complete, photo-rich profiles/work cards.

**Reasoning**

The first screen must build trust. Good photos, complete data, and verification matter more than recency for the initial demo experience.

**Contract implications**

- Endpoints: empty-query `GET /v1/search` returns recommended results using the same result DTOs.
- Authorization: authenticated active user required.
- Validation: recommendations exclude hidden/suspended/deleted entities.
- Database: ranking uses cached `is_verified`, `completion_score`, `photo_count`, and `ranking_score`.
- Wireframe/client states: recommended result cards appear before user types.
- Security/privacy: no private data in recommended cards.

**Remaining uncertainty**

If too few verified profiles exist in the private demo, the ranking can fall back to complete/photo-rich unverified profiles without changing the contract.

### Question 4: Typo And Ambiguous Search Strictness

**Options presented**

- Option A: Conservative: exact category/alias/keyword first, small fuzzy fallback.
- Option B: Broad fuzzy matching.
- Option C: Exact only.

**Architect recommendation before answer**

Option A. It balances accuracy and practical spelling tolerance.

**Product owner answer**

Option A: conservative search with exact category/alias/keyword first and small fuzzy fallback.

**Accepted decision**

MVP search should be conservative. It ranks exact category, alias, and keyword matches first. It uses limited fuzzy/trigram fallback for spelling mistakes and local variations, but should not flood the UI with weak matches.

**Reasoning**

For this marketplace, wrong matches damage trust. A small fuzzy fallback helps with spelling mistakes while preserving relevance.

**Contract implications**

- Endpoints: `GET /v1/search` accepts raw query and returns normalized/applied query metadata where useful.
- Authorization: authenticated active user required.
- Validation: backend normalizes query; empty/short queries use recommendation behavior.
- Database: use category aliases, normalized search text, FTS, and trigram fallback in ranking.
- Wireframe/client states: suggestions under search can guide users when the query is ambiguous.
- Security/privacy: raw queries are admin-restricted analytics data.

**Remaining uncertainty**

Exact ranking thresholds are implementation details and should be tuned using search logs.

### Question 5: Exact Search Result Count

**Options presented**

- Option A: Show exact count like `127 results`.
- Option B: Avoid exact count; show text like `Best matches`.
- Option C: Show approximate count later, not MVP.

**Architect recommendation before answer**

Option B was recommended to avoid slow count queries and false precision. Option A is familiar but can become expensive later.

**Product owner answer**

Option A: show exact result counts because it is familiar. The known downside is count-query cost later.

**Accepted decision**

The MVP search API should return an exact `result_count`, and the UI may show exact counts.

**Reasoning**

The product owner prefers familiar search behavior. At the private MVP scale, exact counts should be acceptable if implemented carefully.

**Contract implications**

- Endpoints: search response includes exact `result_count`.
- Authorization: authenticated active user required.
- Validation: bounded page size still applies independently of total count.
- Database: queries must be indexed; count logic must be monitored. If counts become slow, later switch to approximate or capped counts through a reviewed contract change.
- Wireframe/client states: UI may show `X results` or similar.
- Security/privacy: counts should not expose private/hidden/suspended entities.

**Remaining uncertainty**

Performance of exact counts must be watched as data grows; this is acceptable for private MVP but may need revision before scale.

### Round 3 Architect-Owned Defaults Accepted

The product-owner answers did not conflict with these technical defaults, except that business search now has an explicit secondary mode. Accepted defaults:

- Use one search endpoint with `target_persona`: `GET /v1/search`.
- Return a `result_type` for every item: `profile`, `work_card`, or `work_needed_post`.
- For `target_persona = job_worker`, primary results are published `work_cards`; related job-worker profiles may be returned separately.
- For `target_persona = business`, use `business_search_mode=work_needed_posts|profiles`; default is `work_needed_posts`.
- For `target_persona = skilled_worker`, primary results are skilled-worker profiles.
- Every result includes a compact card DTO specifically shaped for the mobile result card.
- Search responses include `applied_filters`, `available_filter_facets` where cheap, `sort`, `next_cursor`, exact `result_count`, and `search_log_id`.
- Recommended results use the same endpoint with empty query and a recommended/default sort.
- Search suggestions can be returned by a lightweight suggestions endpoint or included in search response when the query is short.
- Cursor pagination is used, with bounded page size.
- Backend logs searches after execution; client should not call a separate logging endpoint for normal searches.
- Backend never returns private verification data, raw search debug scores, contact number, or full address in search results.

## 11. Round 4: Work-Card And Work-Needed-Post Creation And Lifecycle

Status: Completed after product-owner answers on 2026-07-10.

### 11.1 Mandatory Pre-Round Evidence

Read from disk on 2026-07-10 before preparing this round:

1. `outputs/textile-marketplace-database-design.md`
2. `outputs/textile-marketplace-figma-wireframe-spec.md`
3. `outputs/textile-marketplace-mvp-system-design.md`
4. `outputs/textile-marketplace-api-contract-discovery.md`

Relevant sections considered:

- `work_cards`, `work_card_product_types`, `work_needed_posts`, `work_needed_post_product_types`, category suggestions, media photo counts, and lifecycle statuses in the database design.
- Add Work Card, Add Work Needed Post, owner Work List, owner Work Needed Posts, and critical journeys in the wireframe spec.
- Work entries, work-needed posts, search design, API surface, and MVP build scope in the system design.
- Round 2 decision separating job-worker profile completion from work-search readiness.
- Round 3 decision that business search defaults to work-needed posts and job-worker search is work-card first.

### 11.2 Settled Decisions Extracted Before Asking Questions

- Job-worker work cards are the main searchable objects for job-worker search.
- Work-needed posts are manufacturer/business demand objects.
- Add Work Card is entered from My Profile -> Work List -> sticky `+`.
- Add Work Needed Post is entered from My Profile -> Work Needed Posts -> sticky `+`.
- Add Work Card and Add Work Needed Post use one long form, not step-by-step.
- Add Work Card fields are category, work name, product type, photos, and description.
- Add Work Needed Post fields are category, name of work, product type, photos, and description.
- Category/work name can use `Other` with custom text.
- Product type is required.
- Minimum 3 photos are required before publishing work cards and work-needed posts.
- Add Work Card submit label is `Save and Publish`.
- Add Work Needed Post submit label is `Save and Publish`.
- Work-needed posts publish as active in MVP.
- Manufacturers can edit, delete, pause, close, and manage their own work-needed posts.
- Job workers can edit, add photos, hide/show, and delete their own work cards.
- There is no auto-expiry for work-needed posts in MVP, but status and timestamps exist for future stale reminders.
- Hidden/deleted/removed content should not appear in search.

### 11.3 Duplicate Or Non-Material Questions Removed

This round will not ask again:

- whether work cards exist;
- whether work-needed posts exist;
- where add buttons appear;
- whether forms are long form or step-by-step;
- which core fields are collected;
- whether custom category/work text is allowed;
- whether photos are required;
- whether 3 photos are required before publish;
- whether work-needed posts are active after publish;
- whether users can edit/delete their own content;
- whether auto-expiry exists in MVP.

### 11.4 Architect-Owned Defaults Proposed For Round 4

Unless product-owner answers require a change:

- Use owner-scoped endpoints:
  - `GET /v1/me/work-cards`
  - `POST /v1/me/work-cards`
  - `PATCH /v1/me/work-cards/{work_card_id}`
  - `POST /v1/me/work-cards/{work_card_id}/publish`
  - `POST /v1/me/work-cards/{work_card_id}/hide`
  - `POST /v1/me/work-cards/{work_card_id}/show`
  - `DELETE /v1/me/work-cards/{work_card_id}`
  - equivalent `/v1/me/work-needed-posts` endpoints.
- Backend enforces role ownership: only job workers can own work cards; only business profiles can own work-needed posts.
- Backend validates mapped or custom category/work name, at least one product type, description limits, and minimum 3 ready public photos before publish.
- Backend creates `category_suggestions` for custom category/work/product text.
- Backend updates `search_text`, `search_vector`, `photo_count`, `last_activity_at`, and `ranking_score` after create/edit/publish/hide/delete.
- Public detail endpoints never expose owner-only edit controls; owner endpoints do.
- Delete is soft delete.
- Admin removal uses `removed_by_admin` and cannot be reversed by the normal owner endpoint.

These are technical defaults, not yet recorded as accepted product-owner decisions.

### 11.5 Material Decisions Requiring Product-Owner Approval

1. Whether server-side drafts for Add Work and Add Work Needed should be visible in MVP, or whether the app only supports `Save and Publish`.
2. Whether edits to already-published work cards/posts go live immediately or require the user to publish again.
3. What should happen to saved/direct links when a work card or work-needed post is hidden, closed, or deleted.
4. Whether work-needed posts should require a closed reason when the manufacturer closes them.
5. Whether custom `Other` category/work/product text should be searchable immediately or only after admin mapping.

Answers saved below.

### Question 1: Draft Support For Work Cards And Work-Needed Posts

**Options presented**

- Option A: No visible drafts; user only uses `Save and Publish`.
- Option B: Support drafts for both work cards and work-needed posts.
- Option C: Drafts only for work cards, not work-needed posts.

**Architect recommendation before answer**

Option B. It is safer for poor internet, image upload failure, and long forms. It also matches the existing database status model.

**Product owner answer**

Option B: support drafts for both work cards and work-needed posts.

**Accepted decision**

The API will support drafts for both work cards and work-needed posts. The main user-facing action can still be `Save and Publish`, but backend draft states exist and can be shown in owner lists.

**Reasoning**

Photo upload and long-form entry can fail on weak mobile networks. Drafts prevent data loss and align with existing statuses in the database design.

**Contract implications**

- Endpoints: create/update endpoints can persist `draft` rows; publish endpoints transition drafts to `published` or `active`.
- Authorization: only the owner can view and edit their drafts; admins can view through admin tools.
- Validation: draft saves allow incomplete data; publish enforces category/work/product/photo requirements.
- Database: use `work_cards.status = 'draft'`; for work-needed posts, ensure draft status is allowed or add it in final schema correction if missing.
- Wireframe/client states: owner work lists can show draft rows with status chips.
- Security/privacy: drafts are owner/admin-only and must not appear in public search.

**Remaining uncertainty**

Current database design has `draft` for work cards but work-needed post statuses list `active`, `paused`, `closed_by_user`, `removed_by_admin`, `deleted`; final schema correction should add `draft` for work-needed posts.

### Question 2: Published Item Edits

**Options presented**

- Option A: Owner edits go live immediately and search updates.
- Option B: Edited item becomes draft until user republishes.
- Option C: Admin must approve edits.

**Architect recommendation before answer**

Option A. It is simple and appropriate for the MVP because work cards and work-needed posts are not verified documents.

**Product owner answer**

Option A: owner edits go live immediately and search updates.

**Accepted decision**

Owner edits to published work cards and active work-needed posts go live immediately. Backend updates search text, ranking fields, and timestamps after the edit.

**Reasoning**

This keeps the marketplace lightweight. Admin moderation remains available through reports and admin removal, but normal edits should not require another publish or admin step.

**Contract implications**

- Endpoints: `PATCH /v1/me/work-cards/{id}` and `PATCH /v1/me/work-needed-posts/{id}` update live content when status is public/active.
- Authorization: owner-only; suspended users cannot edit.
- Validation: edited published content must still satisfy publish requirements.
- Database: update `search_text`, `search_vector`, `last_activity_at`, `ranking_score`, and `updated_at`.
- Wireframe/client states: no extra republish screen after edit.
- Security/privacy: reports/admin moderation handle bad edits.

**Remaining uncertainty**

Admin review for abusive edits can be added later if misuse appears.

### Question 3: Saved And Direct Links For Hidden, Closed, Or Deleted Content

**Options presented**

- Option A: Hidden/closed items still open from saved/direct links with status shown; deleted items show unavailable.
- Option B: Hidden/closed/deleted all show unavailable.
- Option C: Hidden opens, closed/deleted unavailable.

**Architect recommendation before answer**

Option A. It preserves context and saved history while keeping hidden/closed items out of discovery.

**Product owner answer**

Option A: hidden/closed items still open from saved/direct links with status shown; deleted items show unavailable.

**Accepted decision**

Hidden and closed work cards/posts do not appear in search, recommendations, or similar lists, but they can still open from saved/direct links with a clear status. Deleted items show an unavailable state.

**Reasoning**

Saved/direct access remains useful, while search stays clean. Soft delete prevents broken data and preserves history.

**Contract implications**

- Endpoints: public detail endpoints can return hidden/closed content by id if viewer is authorized, with `status` included; deleted returns structured unavailable/not-found.
- Authorization: owner/admin always see their own/admin-managed records; normal users can see hidden/closed only via direct detail access when allowed.
- Validation: hidden/closed excluded from search queries.
- Database: soft-delete for deleted records; preserve closed/hidden rows.
- Wireframe/client states: detail screens should display `Hidden`, `Closed`, or similar status when opened from saved/direct link.
- Security/privacy: hidden is not private; it is removed from discovery only.

**Remaining uncertainty**

If users later expect hidden to mean private, this must be revisited.

### Question 4: Close Reason For Work-Needed Posts

**Options presented**

- Option A: No close reason in MVP.
- Option B: Optional close reason.
- Option C: Mandatory close reason.

**Architect recommendation before answer**

Option A. It keeps closing a post low-friction.

**Product owner answer**

Option A: no close reason in MVP.

**Accepted decision**

Manufacturers can close work-needed posts without giving a close reason in the MVP.

**Reasoning**

The product is still validating basic posting and discovery. Close reasons are useful analytics but not worth the extra friction now.

**Contract implications**

- Endpoints: `POST /v1/me/work-needed-posts/{id}/close` does not require a reason field.
- Authorization: owner-only; admins can remove through admin endpoints.
- Validation: closed posts cannot be closed repeatedly except idempotent success/no-op.
- Database: set `status = 'closed_by_user'` and `closed_at = now()`; `close_reason` can remain absent/null.
- Wireframe/client states: close action can be one tap or simple confirmation if added later.
- Security/privacy: no added risk.

**Remaining uncertainty**

Close reason can be added later as optional analytics without breaking the current contract.

### Question 5: Searchability Of Custom `Other` Text

**Options presented**

- Option A: Searchable immediately as custom text, while admin mapping happens later.
- Option B: Searchable only after admin maps it.
- Option C: Searchable only as keyword, not as category/filter until mapped.

**Architect recommendation before answer**

Option A. It captures real textile vocabulary from day one and avoids blocking discoverability while the taxonomy matures.

**Product owner answer**

Option A: custom `Other` category/work/product text is searchable immediately while admin mapping happens later.

**Accepted decision**

Custom category, work, and product text entered through `Other` is searchable immediately. The backend also creates category-suggestion rows so admin can map the term later.

**Reasoning**

The Surat textile vocabulary will not be perfect at launch. Users must not wait for admin taxonomy cleanup before their real work terms become searchable.

**Contract implications**

- Endpoints: create/update endpoints accept mapped ids or custom text fields.
- Authorization: owner-only create/update; admin maps suggestions later.
- Validation: custom text is normalized and length-limited; abusive text can be moderated.
- Database: store custom text on work cards/posts/product-type rows and create `category_suggestions`.
- Wireframe/client states: `Other` opens custom text input and can still publish.
- Security/privacy: custom user text needs moderation/reporting but no sensitive-data expansion.

**Remaining uncertainty**

Custom text may create noisy search until admin cleans aliases/categories; search logs should guide mapping.

### Round 4 Architect-Owned Defaults Accepted

The product-owner answers did not conflict with these technical defaults, except work-needed posts now explicitly need draft support. Accepted defaults:

- Use owner-scoped endpoints:
  - `GET /v1/me/work-cards`
  - `POST /v1/me/work-cards`
  - `PATCH /v1/me/work-cards/{work_card_id}`
  - `POST /v1/me/work-cards/{work_card_id}/publish`
  - `POST /v1/me/work-cards/{work_card_id}/hide`
  - `POST /v1/me/work-cards/{work_card_id}/show`
  - `DELETE /v1/me/work-cards/{work_card_id}`
  - equivalent `/v1/me/work-needed-posts` endpoints.
- Backend enforces role ownership: only job workers can own work cards; only business profiles can own work-needed posts.
- Backend validates mapped or custom category/work name, at least one product type, description limits, and minimum 3 ready public photos before publish.
- Backend creates `category_suggestions` for custom category/work/product text.
- Backend updates `search_text`, `search_vector`, `photo_count`, `last_activity_at`, and `ranking_score` after create/edit/publish/hide/delete.
- Public detail endpoints never expose owner-only edit controls; owner endpoints do.
- Delete is soft delete.
- Admin removal uses `removed_by_admin` and cannot be reversed by the normal owner endpoint.

## 12. Round 5: Media Upload, Processing, Ordering, Privacy, And Deletion

Status: Completed after product-owner answers on 2026-07-10.

### 12.1 Mandatory Pre-Round Evidence

Read from disk on 2026-07-10 before preparing this round:

1. `outputs/textile-marketplace-database-design.md`
2. `outputs/textile-marketplace-figma-wireframe-spec.md`
3. `outputs/textile-marketplace-mvp-system-design.md`
4. `outputs/textile-marketplace-api-contract-discovery.md`

Relevant sections considered:

- `media_assets`, public/private visibility, media status, media polymorphic linking, sort order, document types, profile/work/post photo requirements, sensitive verification media, and privacy notes in the database design.
- Photo upload, carousel, gallery, upload failure, permission required, minimum photo validation, profile completion photo step, Add Work, Add Work Needed, and verification states in the wireframe spec.
- Supabase Storage, image compression, private verification bucket, signed URLs, backend boundary, and storage failure modes in the system design.
- Round 1 backend-proxied auth boundary.
- Round 2 public profile/contact reveal behavior and sensitive edit re-verification.
- Round 4 draft and publish behavior for work cards/posts.

### 12.2 Settled Decisions Extracted Before Asking Questions

- The app is photo-first for trust and search result quality.
- Users upload profile/shop/workplace/work/work-needed photos from the mobile app.
- Profile/shop/workplace photos and work photos are public media.
- Verification documents and identity/GST proof media are private admin-only media.
- One `media_assets` table is used with `entity_type` and `entity_id`.
- Media has `visibility = public` or `private_admin_only`.
- Media has `sort_order` for carousel ordering.
- The first uploaded image is the cover by default.
- Store original, compressed, and thumbnail paths.
- Media statuses include pending/uploaded/processing/ready/failed/deleted.
- Minimum photo counts are enforced by backend, not just UI.
- Business/shop photos and job-worker workplace photos need minimum 3 for trust/verification.
- Work cards and work-needed posts require minimum 3 photos before publish.
- User can change public photos, but changing verified shop/workplace photos triggers re-verification.
- While verification is pending, profile editing is locked.
- No video in MVP.
- Mobile app compresses photos to save data.
- Upload failed state is `Unable to upload, please retry`.
- Permission denied state is `Permission required`.

### 12.3 Duplicate Or Non-Material Questions Removed

This round will not ask again:

- whether photos are required;
- whether minimum 3 photos is required;
- whether videos are included;
- whether media has public/private visibility;
- whether sort order exists;
- whether the first image is cover by default;
- whether mobile compression is needed;
- whether verification documents are private;
- whether public photo edits can trigger re-verification;
- whether upload failure and permission states exist.

### 12.4 Architect-Owned Defaults Proposed For Round 5

Unless product-owner answers require a change:

- Use backend-authorized upload sessions rather than direct table writes.
- Use endpoints such as:
  - `POST /v1/media/upload-intent`
  - `POST /v1/media/{media_asset_id}/complete`
  - `PATCH /v1/media/{media_asset_id}`
  - `DELETE /v1/media/{media_asset_id}`
- Store media metadata first with `upload_status = pending_upload`, then mark ready after upload verification.
- Backend validates entity ownership before issuing any upload intent.
- Public images and private verification documents use separate storage locations/buckets.
- Public image reads can use CDN/public URLs where safe; private proof reads use short-lived signed URLs for owner/admin/status views only where allowed.
- Backend validates MIME type, size, dimensions, media kind, entity type, and visibility.
- Backend updates `photo_count`, cover/sort order, and re-verification flags after media changes.
- Deleted media is soft-deleted in metadata and removed from public responses.
- Media upload operations are idempotent or retry-safe.

These are technical defaults, not yet recorded as accepted product-owner decisions.

### 12.5 Material Decisions Requiring Product-Owner Approval

1. Whether the mobile app may upload file bytes directly to storage using a short-lived backend-issued signed URL, or whether all bytes must proxy through the backend API.
2. What should happen if a published work card/post/profile would fall below the required photo minimum after the owner deletes photos.
3. Whether users can reorder photos and choose a cover photo in MVP, or whether first-uploaded cover and upload order are enough.
4. Whether owners can view/download their own private verification documents after upload.
5. Whether the app should allow replacing photos while upload/processing is still pending, or require retry/cancel first.

### Question 1: Secure Upload Path

**Options presented**

- Option A: Mobile uploads file bytes directly to storage using a short-lived backend-issued scoped upload URL or upload token.
- Option B: Mobile uploads all file bytes through the backend API, and the backend writes to storage.
- Option C: Use direct storage upload from the mobile SDK without a marketplace backend upload intent.

**Architect recommendation before answer**

Option A, but only with strict backend-controlled upload intents. It avoids sending large photo bytes through the backend while still preserving the product rule that the mobile app cannot write arbitrary storage/database objects. Option C is not acceptable for this product because it weakens the backend boundary.

**Product owner answer**

Option A, only if there is no security loophole. The product owner is not fully sure and wants the secure option.

**Accepted decision**

Use backend-issued, short-lived, scoped upload intents for MVP media uploads only if the implementation can enforce authentication, ownership, entity type, entity id, media kind, visibility/bucket, expected path prefix, max file size, MIME type, expiry, and backend completion verification. If the storage provider or backend cannot enforce these controls safely, fall back to backend-proxied file upload for that media type.

**Reasoning**

The app will be photo-heavy, so direct-to-storage upload is better for cost and backend scalability. The security boundary is still the backend: the client asks the backend for permission to upload exactly one allowed file for exactly one owned entity, then the backend verifies the uploaded object before it becomes usable.

**Contract implications**

- Endpoints: `POST /v1/media/upload-intent` returns a constrained upload target; `POST /v1/media/{media_asset_id}/complete` verifies the uploaded object before `ready`.
- Authorization: upload intent requires an authenticated active user and backend ownership checks for the target profile/work/post/verification case.
- Validation: upload intent fixes media kind, entity type, entity id, visibility, bucket/path prefix, allowed MIME types, max bytes, and expiry.
- Database: create `media_assets` with `upload_status = 'pending_upload'` before issuing upload details; update to `uploaded`, `processing`, `ready`, or `failed` only after backend verification.
- Wireframe/client states: upload UI can show progress, retry, cancel, and failed states without exposing storage details.
- Security/privacy: public and private media must use separate buckets/path policies; private verification uploads never receive public URLs; stale pending uploads are cleaned up later.

**Remaining uncertainty**

The exact Supabase Storage signed-upload capability and policy shape must be verified during implementation. If it cannot safely scope uploads to the intended path and user, backend-proxied upload becomes the safe fallback.

### Question 2: Deleting Required Photos

**Options presented**

- Option A: Block deletion when it would take the entity below the required photo minimum until a replacement photo is uploaded.
- Option B: Allow deletion but automatically unpublish or hide the entity until the minimum is restored.
- Option C: Allow deletion and keep the entity visible even below the required minimum.

**Architect recommendation before answer**

Option A. It is easiest for low-digital-literacy users to understand and prevents published search objects from silently becoming invalid.

**Product owner answer**

Option A: block deletion until replacement photo is uploaded.

**Accepted decision**

For entities with a required minimum photo count, the delete-media endpoint must reject deletion if it would reduce ready public photos below the required minimum. The client should ask the user to upload a replacement first.

**Reasoning**

The marketplace depends on photo trust. Blocking invalid deletion keeps the entity valid and avoids confusing hidden/unpublished states.

**Contract implications**

- Endpoints: `DELETE /v1/media/{media_asset_id}` can return a validation error such as `minimum_photos_required`.
- Authorization: owner-only for public profile/work/post media; admins can remove inappropriate media through admin endpoints with separate moderation effects.
- Validation: backend calculates current ready, non-deleted photo count before deletion.
- Database: keep `photo_count` cached only after successful deletion; do not allow owner deletion below minimum for published/complete objects.
- Wireframe/client states: show `Minimum 3 photos required` and guide the user to add a replacement.
- Security/privacy: prevents abuse where users publish photo-rich profiles and then remove trust evidence.

**Remaining uncertainty**

Admin moderation removal may need a separate rule later: if admin removes inappropriate photos below the minimum, the entity may need to be hidden or marked action-required.

### Question 3: Cover Photo And Ordering In MVP

**Options presented**

- Option A: First uploaded image is cover; upload order is carousel order; no reorder or cover picker in MVP.
- Option B: Let users choose cover and reorder photos from day one.
- Option C: Backend chooses cover automatically based on image quality later.

**Architect recommendation before answer**

Option A. It matches the database and wireframe, reduces UI complexity, and is enough for the private MVP.

**Product owner answer**

Option A: first uploaded is cover, upload order is carousel order; no reorder/cover picker in MVP.

**Accepted decision**

MVP media ordering is upload-order based. The first ready uploaded image becomes the cover/default carousel image. Users cannot reorder media or pick a custom cover in the MVP.

**Reasoning**

The MVP needs good enough photo display, not a photo-management tool. Reorder/cover controls can be added later because `sort_order` already exists in the database.

**Contract implications**

- Endpoints: create/upload completion assigns `sort_order`; no public owner endpoint for reorder or cover selection in MVP.
- Authorization: owner can upload/delete allowed media only.
- Validation: first ready image for an entity is treated as cover.
- Database: maintain `sort_order`; optional `is_cover` can be derived or cached later if needed.
- Wireframe/client states: carousel shows the large first image with dots; no drag/drop or cover controls.
- Security/privacy: no additional risk.

**Remaining uncertainty**

If users complain that poor first photos reduce leads, a reorder/cover picker can be added without changing the core media table.

### Question 4: Owner Access To Private Verification Documents

**Options presented**

- Option A: Owner can see private document status/name only, not reopen or download the private file.
- Option B: Owner can reopen/download their own private uploaded proof through a short-lived signed URL.
- Option C: Owner cannot see document status after upload.

**Architect recommendation before answer**

Option A. It gives enough confidence to the owner while minimizing sensitive document exposure.

**Product owner answer**

Option A: owner can see document status/name only, not reopen/download the private file.

**Accepted decision**

After private verification document upload, the owner can see metadata such as document type, submitted status, review status, and safe display name. The owner cannot reopen, preview, or download the private proof file through the normal mobile app.

**Reasoning**

Identity/GST proof uploads are sensitive. The app should avoid creating extra download surfaces unless there is a strong user need.

**Contract implications**

- Endpoints: owner verification/status endpoints return private document metadata only, not file URLs.
- Authorization: admin/verifier endpoints can access private documents with audit logging; owner normal endpoints cannot download them.
- Validation: private media cannot be requested through public media URLs.
- Database: keep private `media_assets` linked to `verification_case`; expose only non-sensitive fields in owner DTOs.
- Wireframe/client states: verification status can show uploaded document label/status but no preview action.
- Security/privacy: reduces sensitive-data leakage and screenshot/download risk.

**Remaining uncertainty**

A future data-access/export workflow may need to let users request copies through support or a controlled privacy flow before public launch.

### Question 5: Replacing Pending Or Failed Uploads

**Options presented**

- Option A: Require the user to retry or cancel the current pending/failed upload first, then upload a replacement.
- Option B: Allow immediate replacement while the previous upload is still pending/processing.
- Option C: Automatically replace any pending upload when the user selects a new file.

**Architect recommendation before answer**

Option A. It keeps upload state simple and avoids duplicate media records or uncertain carousel order.

**Product owner answer**

Option A: require retry or cancel first, then upload replacement.

**Accepted decision**

The media API will not allow replacing a pending or processing upload in-place. The user must retry the failed/pending upload or cancel/delete the pending media asset first, then start a new upload intent.

**Reasoning**

Mobile networks are unreliable. Explicit retry/cancel keeps state understandable and avoids background race conditions.

**Contract implications**

- Endpoints: `POST /v1/media/{id}/retry` or a new upload intent for the same pending media can be supported; `POST /v1/media/{id}/cancel` marks abandoned pending uploads as deleted/cancelled.
- Authorization: owner-only for retry/cancel on user-owned media.
- Validation: replacement upload is rejected while another media asset is pending/processing for the same slot if the client is trying to replace it directly.
- Database: preserve clear upload statuses and avoid ambiguous overwrite semantics.
- Wireframe/client states: show retry/cancel actions on failed or stuck upload cards.
- Security/privacy: reduces orphaned object and wrong-entity attachment risk.

**Remaining uncertainty**

The final status vocabulary may need `cancelled` in addition to `deleted`, or cancellation can use `deleted` with an audit/status reason.

### Round 5 Architect-Owned Defaults Accepted

The product-owner answers did not conflict with these technical defaults, so they are accepted for the API contract unless implementation verification forces a reviewed change:

- Use backend-authorized upload sessions; never allow direct client writes to marketplace tables.
- Use:
  - `POST /v1/media/upload-intent`
  - `POST /v1/media/{media_asset_id}/complete`
  - `POST /v1/media/{media_asset_id}/retry` or equivalent
  - `POST /v1/media/{media_asset_id}/cancel` or equivalent
  - `DELETE /v1/media/{media_asset_id}`
- Store media metadata first with `upload_status = 'pending_upload'`, then mark ready only after backend verification.
- Backend validates entity ownership before issuing any upload intent.
- Public images and private verification documents use separate storage buckets or path policy zones.
- Public image reads can use public/CDN URLs only for public-ready media.
- Private proof media never appears in public or owner downloadable responses; admin access must be audited.
- Backend validates MIME type, size, dimensions, media kind, entity type, and visibility.
- Backend updates `photo_count`, `sort_order`, search/ranking caches, and re-verification flags after media changes.
- Deleted media is soft-deleted in metadata and removed from normal public responses.
- Media upload operations are idempotent or retry-safe.

## 13. Round 6: Verification Submission, Admin Review, Locking, And Resubmission

Status: Completed after product-owner answers on 2026-07-10.

### 13.1 Mandatory Pre-Round Evidence

Read from disk on 2026-07-10 before preparing this round:

1. `outputs/textile-marketplace-database-design.md`
2. `outputs/textile-marketplace-figma-wireframe-spec.md`
3. `outputs/textile-marketplace-mvp-system-design.md`
4. `outputs/textile-marketplace-api-contract-discovery.md`

Relevant sections considered:

- `verification_cases`, `verification_checks`, `verification_provider_checks`, `profile_gst_details`, admin users, admin audit logs, private media, and no raw Aadhaar/PAN storage in the database design.
- My Profile verification button, pending review state, approved state, rejected/changes-requested notification, profile editing lock while pending, optional ID/GST upload, and blue-tick-only public verification display in the wireframe spec.
- Manual admin verification, privacy, Aadhaar/GST research notes, private bucket, audit logs, and no automated KYC in the MVP system design.
- Round 1 consent/session/account decisions.
- Round 2 profile visibility and sensitive-edit re-verification decision.
- Round 5 private verification document upload/privacy decision.

### 13.2 Settled Decisions Extracted Before Asking Questions

- Verification is manually reviewed by admins in MVP.
- Verification is free in MVP and later.
- A profile gets public blue tick only after `admin_final_review = approved`.
- Public users see only the blue tick, not verification breakdown.
- Owners see verification status in My Profile and notifications.
- Verification can be submitted only after required profile fields are complete.
- Verification submission includes profile details, photos, optional identity proof, and optional GST proof where applicable.
- Identity proof and GST proof are supporting evidence, not mandatory universal requirements.
- No raw Aadhaar number, PAN, or identity number is stored.
- Private verification documents are admin-only; owner sees status/name only.
- Profile editing is locked while verification is pending.
- If admin requests changes, notes are shown to the owner and the owner can resubmit.
- Verification status values include `unverified`, `pending`, `verified`, `changes_requested`, and `rejected`.
- Sensitive edits after verification keep the profile public but remove the blue tick until re-approved.
- Admin review actions must be audit logged.

### 13.3 Duplicate Or Non-Material Questions Removed

This round will not ask again:

- whether verification is manual or automated in MVP;
- whether blue tick requires admin approval;
- whether verification is free;
- whether optional ID/GST proof exists;
- whether Aadhaar/PAN raw numbers should be stored;
- whether public users see verification details;
- whether pending verification locks profile editing;
- whether notifications are sent for verification outcomes;
- whether admin actions are audit logged.

### 13.4 Architect-Owned Defaults Proposed For Round 6

Unless product-owner answers require a change:

- Use owner endpoints such as:
  - `GET /v1/me/verification`
  - `POST /v1/me/verification/submit`
  - `POST /v1/me/verification/resubmit`
  - `GET /v1/me/verification/cases/{case_id}`
- Use admin endpoints such as:
  - `GET /v1/admin/verification-cases`
  - `GET /v1/admin/verification-cases/{case_id}`
  - `POST /v1/admin/verification-cases/{case_id}/approve`
  - `POST /v1/admin/verification-cases/{case_id}/request-changes`
  - `POST /v1/admin/verification-cases/{case_id}/reject`
- Allow only one active verification case per profile at a time.
- Use idempotency keys for submit/resubmit to avoid duplicate cases from mobile retries.
- The backend creates/checks `verification_checks` from profile data and uploaded evidence at submission time.
- Admin approval updates `profiles.verification_status`, `profiles.is_verified`, and `profiles.verified_at`.
- Admin changes-requested/rejected stores `notes_to_user` and sends in-app plus push notification.
- Admin proof-file access uses short-lived URLs and creates audit logs.

These are technical defaults, not yet recorded as accepted product-owner decisions.

### 13.5 Material Decisions Requiring Product-Owner Approval

1. What should happen when admin fully rejects a verification case rather than requesting changes.
2. Whether users can cancel or edit a pending verification submission before admin reviews it.
3. What exact API state should represent a previously verified profile that needs re-verification after sensitive edits.
4. How long private identity/GST proof documents should be retained after admin review for the MVP/private demo.
5. How much verification checklist detail the owner should see in My Profile.

### Question 1: Full Rejection Behaviour

**Options presented**

- Option A: Rejected verification keeps the completed profile public but unverified; the user can submit again after changes.
- Option B: Rejected verification hides the profile until the user fixes and resubmits.
- Option C: Rejected verification blocks self-resubmission and requires support/admin assistance.

**Architect recommendation before answer**

Option A. Verification should control the blue tick, not marketplace visibility, unless the profile is fraudulent or unsafe enough for admin suspension/removal.

**Product owner answer**

Yes. The profile should stay public but unverified, and the user can submit again after changes.

**Accepted decision**

When admin rejects a normal verification case, the profile remains public if it otherwise satisfies profile-completion and visibility rules. The profile is unverified, has no public blue tick, and the owner can make changes and submit verification again.

**Reasoning**

This keeps marketplace supply visible while preserving trust. Rejection means "not verified", not necessarily "bad profile". Admin suspension/removal remains the separate tool for scam, unsafe, or abusive profiles.

**Contract implications**

- Endpoints: admin reject endpoint updates the case/profile state; owner submit endpoint remains available after allowed changes.
- Authorization: owner can resubmit only for their own profile; admins can suspend/remove separately when rejection is due to serious abuse.
- Validation: resubmission requires required profile fields and evidence to be valid again.
- Database: set `verification_cases.status = 'rejected'`, `profiles.verification_status = 'rejected'` or equivalent owner-visible state, and `profiles.is_verified = false`; keep `visibility_status = 'public'` unless separate moderation action changes it.
- Wireframe/client states: My Profile shows rejected/unverified with admin message; public profile simply has no blue tick.
- Security/privacy: do not expose rejection reason publicly.

**Remaining uncertainty**

Final DTO naming should distinguish normal `rejected` from admin `suspended_by_admin` so the client does not treat both as the same state.

### Question 2: Pending Verification Edit Or Cancel

**Options presented**

- Option A: User cannot change, cancel, or edit a pending verification submission until admin approves, rejects, or requests changes.
- Option B: User can cancel before admin opens the case.
- Option C: User can edit pending submission and overwrite evidence before admin decides.

**Architect recommendation before answer**

Option A. It keeps admin review evidence stable and matches the wireframe rule that pending review locks edit buttons.

**Product owner answer**

Yes. User is unable to change, cancel, or edit while verification is pending.

**Accepted decision**

While a verification case is pending review, the owner cannot edit profile details tied to verification, cancel the case, replace submitted evidence, or submit another case. The owner must wait for admin approval, rejection, or changes-requested.

**Reasoning**

Mutable pending evidence creates review confusion and audit risk. The MVP needs a clean manual queue more than flexible mid-review edits.

**Contract implications**

- Endpoints: owner edit/profile/media/verification endpoints return locked-state errors for verification-sensitive changes while pending.
- Authorization: only admins/verifiers can transition pending cases.
- Validation: one active pending case per profile.
- Database: maintain a pending case lock; do not create replacement verification cases until terminal/admin-returned state.
- Wireframe/client states: show pending review status and disabled edit controls.
- Security/privacy: preserves evidence integrity for admin review.

**Remaining uncertainty**

None for MVP.

### Question 3: Re-Verification State After Sensitive Edits

**Options presented**

- Option A: Use `verification_status = 'unverified'` plus `reverification_required = true` after sensitive edits.
- Option B: Add a new status value `reverification_required`.
- Option C: Use `verification_status = 'changes_requested'`.

**Architect recommendation before answer**

Option A. It avoids expanding the core status list while still letting owner/admin APIs show the precise reason.

**Product owner answer**

Yes.

**Accepted decision**

When a verified profile changes sensitive fields, the backend removes public verified status and uses `verification_status = 'unverified'` with a separate owner/admin flag such as `reverification_required = true`.

**Reasoning**

Public users only need to know whether the profile currently has a blue tick. The owner/admin side needs to know why the tick disappeared and what action is required.

**Contract implications**

- Endpoints: `PATCH /v1/me/profile` detects sensitive edits and updates verification summary fields in owner responses.
- Authorization: owner can edit allowed non-locked fields; admin can review re-verification cases.
- Validation: pending verification locks still apply.
- Database: add or derive `reverification_required`; keep allowed `verification_status` values unchanged.
- Wireframe/client states: owner sees re-verification needed; public sees no blue tick.
- Security/privacy: avoids implying old admin approval still covers changed trust-sensitive data.

**Remaining uncertainty**

Final schema correction should explicitly include `reverification_required` if not already present.

### Question 4: Private Proof Document Retention

**Options presented**

- Option A: Keep private ID/GST proof documents during the private MVP after admin review with strict admin-only access and audit logs.
- Option B: Delete private proof documents after review and retain only verification status/check results.
- Option C: Keep only documents for rejected/changes-requested cases and delete after approval.

**Architect recommendation before answer**

Option A for the private MVP, with a clear requirement to create a retention/deletion policy before public launch. It supports auditability while the user base is small and manually controlled.

**Product owner answer**

Yes.

**Accepted decision**

For the private MVP, private identity/GST proof documents are retained after admin review in private storage. Access remains admin-only, audited, and hidden from public and normal owner download flows. A formal retention/deletion policy is required before public launch.

**Reasoning**

Manual verification may need evidence review after disputes, mistaken approvals, or support issues. The privacy risk is controlled by private MVP scope, private buckets, and audit logs, but this must not become an indefinite public-launch habit without policy.

**Contract implications**

- Endpoints: no owner download endpoint for proof documents; admin proof access requires verifier/admin role and audit logging.
- Authorization: private proof URLs are short-lived and admin-scoped only.
- Validation: document uploads remain optional/supporting evidence; no raw ID numbers are stored.
- Database: keep private `media_assets` linked to verification cases; retain access/audit records.
- Wireframe/client states: owner sees document status/name only.
- Security/privacy: add retention policy as a pre-public-launch requirement; monitor admin access.

**Remaining uncertainty**

Exact retention duration is not locked for public launch.

### Question 5: Owner Verification Detail Level

**Options presented**

- Option A: Owner sees simple verification status and admin message only, not the full internal checklist.
- Option B: Owner sees full checklist status for every verification check.
- Option C: Owner sees uploaded evidence details and internal admin checklist.

**Architect recommendation before answer**

Option A. It is simpler for users and avoids exposing internal verification heuristics.

**Product owner answer**

Yes.

**Accepted decision**

In My Profile, the owner sees a simple verification status such as `Pending review`, `Approved`, `Rejected`, or `Changes requested`, plus a short admin message when action is needed. The owner does not see the full internal checklist.

**Reasoning**

The product needs clear next action, not internal audit complexity. Full checklist exposure can confuse users and expose moderation logic.

**Contract implications**

- Endpoints: owner verification DTO returns status, submitted timestamp, safe document labels/status, and `notes_to_user`; it does not return internal `verification_checks`.
- Authorization: internal checklist remains admin-only.
- Validation: changes-requested flow may expose only targeted fields/actions needed for resubmission.
- Database: keep checklist rows internal; expose summarized state through API.
- Wireframe/client states: simple badge/status near completion percentage and short message in notifications/My Profile.
- Security/privacy: reduces leakage of verification heuristics and private review notes.

**Remaining uncertainty**

None for MVP.

### Round 6 Architect-Owned Defaults Accepted

The product-owner answers did not conflict with these technical defaults, so they are accepted for the API contract unless implementation constraints force a reviewed change:

- Use owner endpoints:
  - `GET /v1/me/verification`
  - `POST /v1/me/verification/submit`
  - `POST /v1/me/verification/resubmit`
  - `GET /v1/me/verification/cases/{case_id}`
- Use admin endpoints:
  - `GET /v1/admin/verification-cases`
  - `GET /v1/admin/verification-cases/{case_id}`
  - `POST /v1/admin/verification-cases/{case_id}/approve`
  - `POST /v1/admin/verification-cases/{case_id}/request-changes`
  - `POST /v1/admin/verification-cases/{case_id}/reject`
- Allow only one active verification case per profile at a time.
- Use idempotency keys for submit/resubmit to avoid duplicate cases from mobile retries.
- The backend creates/checks `verification_checks` from profile data and uploaded evidence at submission time.
- Admin approval updates `profiles.verification_status`, `profiles.is_verified`, and `profiles.verified_at`.
- Admin changes-requested/rejected stores `notes_to_user` and sends in-app plus push notification.
- Admin proof-file access uses short-lived URLs and creates audit logs.

## 14. Round 7: Saved Items, Reports, Notifications, Contact Actions, And Analytics

Status: Completed after product-owner answers on 2026-07-10.

### 14.1 Mandatory Pre-Round Evidence

Read from disk on 2026-07-10 before preparing this round:

1. `outputs/textile-marketplace-database-design.md`
2. `outputs/textile-marketplace-figma-wireframe-spec.md`
3. `outputs/textile-marketplace-mvp-system-design.md`
4. `outputs/textile-marketplace-api-contract-discovery.md`

Relevant sections considered:

- `saved_items`, `reports`, `notifications`, `user_settings`, `search_logs`, `profile_view_events`, `contact_action_events`, `share_events`, and `contact_reveals` in the database design.
- Saved screen tabs, saved card remove button, share sheet, report sheet, notification list, settings notification toggle, contact support, hide from search, and profile detail action rows in the wireframe spec.
- FCM push notifications, admin analytics, contact/profile event logging, no profile-owner analytics in MVP, contact/address after OTP, and backend boundary in the system design.
- Round 2 profile detail contact reveal behaviour.
- Round 3 search logging behaviour.
- Round 4 saved/direct-link hidden/deleted item behaviour.
- Round 6 verification notification behaviour.

### 14.2 Settled Decisions Extracted Before Asking Questions

- Saved screen exists with Business, Job Worker, and Karigar tabs.
- Saved cards look like search result cards and include remove action.
- User can save profiles, work cards, and work-needed posts.
- Search result cards and saved cards do not show contact number or full address.
- Share is available from profile detail header.
- Share sheet supports copy link, WhatsApp, SMS, X, email, LinkedIn, and native share apps.
- Report is available from profile detail three-dot menu.
- Report reason list includes wrong contact, wrong category, inappropriate photo, and wrong details.
- Report has no optional text box in the MVP wireframe.
- Notifications are shown from the Home bell as a simple list.
- Notification row includes title, short message, and date/time.
- Empty notification text is `No notifications`.
- Settings includes notification settings, hide from search, contact support, and logout.
- Contact support uses WhatsApp/call support button.
- Contact number and address are visible on profile detail in MVP after OTP login.
- Contact reveal should be recorded even in free launch when profile detail returns contact/address.
- A reveal counts only once per viewer user and revealed profile.
- Search logs and contact/profile events are admin analytics only, not visible to profile owners in MVP.

### 14.3 Duplicate Or Non-Material Questions Removed

This round will not ask again:

- whether Saved screen exists;
- whether saved items are grouped by persona tabs;
- whether users can save profile/work/work-needed content;
- whether contact/address appears on result or saved cards;
- whether share/report actions exist;
- whether report has an optional text box in the MVP;
- whether notifications exist in-app and as push;
- whether verification status notifications exist;
- whether contact reveal analytics are invisible to users in MVP;
- whether contact reveal records are created during free launch.

### 14.4 Architect-Owned Defaults Proposed For Round 7

Unless product-owner answers require a change:

- Use endpoints such as:
  - `GET /v1/me/saved-items`
  - `POST /v1/me/saved-items`
  - `DELETE /v1/me/saved-items/{saved_item_id}`
  - `POST /v1/reports`
  - `GET /v1/me/notifications`
  - `POST /v1/me/notifications/{notification_id}/read`
  - `POST /v1/me/device-tokens`
  - `PATCH /v1/me/settings`
  - `POST /v1/contact-actions`
  - `POST /v1/share-events`
- Saved create is idempotent for `(user_id, target_type, target_id)`.
- Saved remove is idempotent.
- Deleted saved targets show unavailable or are omitted based on the response mode; hidden/closed targets can still open with status from saved/direct link.
- In-app notifications are always stored in the database; push delivery is best-effort.
- Notification `read_at` is nullable; unread means `read_at is null`.
- Contact-action and share analytics are accepted as fire-and-forget client calls; failure must not block call/WhatsApp/share actions.
- Analytics endpoints are admin-only in MVP.

These are technical defaults, not yet recorded as accepted product-owner decisions.

### 14.5 Material Decisions Requiring Product-Owner Approval

1. Whether reports in MVP can target only profiles, or profiles plus specific work cards and work-needed posts.
2. How duplicate reports from the same user should behave.
3. Whether tapping Call, WhatsApp, or address should create a contact-action event before opening the external app.
4. Whether share actions should use a backend-generated canonical deep link and log a share event.
5. Whether notification settings should disable only push notifications while in-app notifications continue to be stored.

### Question 1: Report Target Scope

**Options presented**

- Option A: Reports can target only profiles.
- Option B: Reports can target profiles, work cards, and work-needed posts.

**Architect recommendation before answer**

Option B. Wrong category, wrong photo, and wrong details can belong to a specific work card or work-needed post, not only the whole profile.

**Product owner answer**

Option B: reports on profiles, work cards, and work-needed posts.

**Accepted decision**

MVP reports can target public profiles, work cards, and work-needed posts.

**Reasoning**

This gives admin the exact object that needs review. Reporting only the profile would make moderation noisy when the problem is one photo, one work card, or one work-needed post.

**Contract implications**

- Endpoints: `POST /v1/reports` accepts `reported_entity_type` values for `profile`, `work_card`, and `work_needed_post`.
- Authorization: authenticated active users can report public/openable entities; suspended users cannot create reports.
- Validation: backend validates target type, target id, report reason, and that the target is reportable.
- Database: `reports.reported_entity_type` and `reported_entity_id` support these three target types.
- Wireframe/client states: report action remains on profile detail in MVP; later it can be added to work-card/post menus if UI feedback requires.
- Security/privacy: report payload must not expose private profile/contact data to other users.

**Remaining uncertainty**

The wireframe currently places report on profile detail only. API can support specific work/post targets now; the first UI may pass the currently viewed profile or selected work/post context.

### Question 2: Duplicate Reports From Same User

**Options presented**

- Option A: Allow multiple reports from the same user for the same target/reason and store all reports.
- Option B: Allow one active report per user, target, and reason; duplicate submissions update or ignore the existing report.
- Option C: Allow one lifetime report per user and target.

**Architect recommendation before answer**

Option B was initially recommended to reduce admin noise.

**Product owner answer**

Option A. The user should be able to send reports, and the app should store all their reports in one place if needed. The product owner challenged why this would not be cleaner for admin.

**Accepted decision**

Allow multiple reports from the same user, including repeated reports for the same target/reason. Do not collapse or discard repeat reports at write time. Admin APIs should group reports by target, reason, reporter, and status so the admin queue remains clean while preserving every submitted report.

**Reasoning**

Repeated reports can be useful signal: a wrong contact may remain wrong, an inappropriate photo may be re-uploaded, or a user may report separate issues over time. Clean admin UX should be solved by grouping and filtering, not by losing report history.

**Contract implications**

- Endpoints: `POST /v1/reports` creates a new report row for each valid submission.
- Authorization: authenticated active users can create reports; rate limits still apply to prevent abuse.
- Validation: no uniqueness constraint on `(reporter_user_id, reported_entity_type, reported_entity_id, reason)`.
- Database: keep all report rows; add admin query/grouping fields and indexes by target/status/reason/reporter/created_at.
- Wireframe/client states: after report submit, return to previous screen and show toast `Report submitted`.
- Security/privacy: apply rate limits and admin abuse tooling so repeated reporting cannot be used to harass or flood moderation.

**Remaining uncertainty**

The admin dashboard needs a grouped report queue so "allow multiple" does not become operational noise.

### Question 3: Contact Action Logging

**Options presented**

- Option A: When user taps Call, WhatsApp, or address, log contact-action event first, then open the external app.
- Option B: Open the external app only and do not log action events.

**Architect recommendation before answer**

Option A. Contact actions are the strongest MVP signal that the marketplace is creating real leads.

**Product owner answer**

Option A: when user taps Call, WhatsApp, or address, log event first, then open external app.

**Accepted decision**

When a user taps Call, WhatsApp, or address from profile detail, the client calls the backend to log a contact-action event, then opens the external phone/WhatsApp/maps/address action.

**Reasoning**

Searches and profile views are weaker signals. Contact taps show marketplace value and will later inform monetization, ranking, and fraud monitoring.

**Contract implications**

- Endpoints: `POST /v1/contact-actions` records action type, target profile, optional source type/id, and request metadata where available.
- Authorization: authenticated active users only; contact action requires that contact/address would be visible to that user.
- Validation: allowed action types include `call`, `whatsapp`, and `address`.
- Database: write `contact_action_events`; link to `contact_reveals` when applicable.
- Wireframe/client states: action row remains Call, WhatsApp, Save; logging is invisible to user.
- Security/privacy: event records may include device/IP/user-agent where available and must be admin-only.

**Remaining uncertainty**

Implementation should use a very short timeout or fire-and-forget fallback so analytics failure does not block urgent user contact.

### Question 4: Share Link Generation And Share Analytics

**Options presented**

- Option A: Backend generates canonical deep links and logs share events.
- Option B: Mobile app builds links locally and logs share events separately.
- Option C: No share analytics.

**Architect recommendation before answer**

Option A. Backend-generated links are safer for future app links, Play Store fallback, entity routing, and analytics.

**Product owner answer**

Option A: backend generates canonical deep link and logs share event.

**Accepted decision**

Share actions use backend-generated canonical links. The backend logs a share event for the shared entity and returns the link/share payload to the mobile app for the native share sheet.

**Reasoning**

The app will later need deep links, install fallback, and analytics across WhatsApp/SMS/social channels. Central link generation avoids inconsistent client-side URL formats.

**Contract implications**

- Endpoints: `POST /v1/share-events` or `POST /v1/share-links` creates/logs a share and returns canonical URL/payload.
- Authorization: authenticated active users can share openable public entities.
- Validation: target type/id must be shareable and not deleted/removed.
- Database: write `share_events` with user, target, channel if known, and created timestamp.
- Wireframe/client states: share sheet options remain copy link, WhatsApp, SMS, X, email, LinkedIn, and native apps.
- Security/privacy: shared links must not expose private contact details directly; opened links require app/account rules before showing contact/address.

**Remaining uncertainty**

Final public web/deep-link fallback behavior can be implemented later, but link shape should be stable now.

### Question 5: Notification Settings Scope

**Options presented**

- Option A: User can disable push notifications, but in-app notifications are still stored.
- Option B: User can disable both push and in-app notifications.
- Option C: No notification settings in MVP.

**Architect recommendation before answer**

Option A. Important verification/status messages should always remain visible inside the app, even if the user disables phone push.

**Product owner answer**

Option A: user can disable push notifications, but in-app notifications are still stored.

**Accepted decision**

Notification settings can disable push delivery, but in-app notifications continue to be created and shown in the Notifications list.

**Reasoning**

Users should control phone interruptions, but verification decisions, change requests, and important account/profile messages need an in-app record.

**Contract implications**

- Endpoints: `PATCH /v1/me/settings` updates push-notification preference; `GET /v1/me/notifications` still returns stored notifications.
- Authorization: user can edit only their own settings.
- Validation: notification preference affects push delivery only, not DB notification creation.
- Database: `user_settings.preferences_json` or equivalent stores push preference; `notifications` rows continue to be inserted.
- Wireframe/client states: Settings notification toggle controls push; Notifications empty/list remains available.
- Security/privacy: important account/security notifications should remain visible in-app regardless of push state.

**Remaining uncertainty**

Later public launch may need finer notification categories; MVP uses one push on/off setting.

### Round 7 Architect-Owned Defaults Accepted

The product-owner answers did not conflict with these technical defaults, except duplicate reports are not collapsed. Accepted defaults:

- Use endpoints:
  - `GET /v1/me/saved-items`
  - `POST /v1/me/saved-items`
  - `DELETE /v1/me/saved-items/{saved_item_id}`
  - `POST /v1/reports`
  - `GET /v1/me/notifications`
  - `POST /v1/me/notifications/{notification_id}/read`
  - `POST /v1/me/device-tokens`
  - `PATCH /v1/me/settings`
  - `POST /v1/contact-actions`
  - `POST /v1/share-links` or `POST /v1/share-events`
- Saved create is idempotent for `(user_id, target_type, target_id)`.
- Saved remove is idempotent.
- Deleted saved targets show unavailable or are omitted based on the response mode; hidden/closed targets can still open with status from saved/direct link.
- In-app notifications are always stored in the database; push delivery is best-effort.
- Notification `read_at` is nullable; unread means `read_at is null`.
- Contact-action and share analytics failures must not block the user from calling, WhatsApping, opening address, or sharing.
- Analytics endpoints are admin-only in MVP.
- Reports are not uniqueness-limited by reporter/target/reason; admin queues must group repeated reports.

## 15. Round 8: Admin Permissions, Exports, Audit, Suspension, And Seed Profiles

Status: Completed after product-owner answers on 2026-07-10.

### 15.1 Mandatory Pre-Round Evidence

Read from disk on 2026-07-10 before preparing this round:

1. `outputs/textile-marketplace-database-design.md`
2. `outputs/textile-marketplace-figma-wireframe-spec.md`
3. `outputs/textile-marketplace-mvp-system-design.md`
4. `outputs/textile-marketplace-api-contract-discovery.md`

Relevant sections considered:

- `admin_users`, `admin_audit_logs`, admin roles, reports, notifications, admin-created profile fields, `created_by_admin_user_id`, `claim_status`, `admin_access_grants`, category management, search logs, and export/migration order in the database design.
- The wireframe explicitly excludes admin screens but defines report, notification, hide-from-search, and public profile behaviours the admin API must support.
- Basic web admin dashboard, manual verification, categories/aliases, profile management, analytics, CSV export, admin-created seed profiles, audit log viewer, and no full support chat in the MVP system design.
- Round 1 suspension behaviour: suspended users are blocked except Logout and Contact Support.
- Round 2 hide/search and profile visibility behaviour.
- Round 6 verification admin review behaviour.
- Round 7 report creation and analytics behaviour.

### 15.2 Settled Decisions Extracted Before Asking Questions

- Admin dashboard is required for MVP, even if basic.
- Admin dashboard is web-based if easy.
- Admin needs broad operational control for the private demo.
- Manual verification review is required.
- Admin can approve, reject, or request changes on verification cases.
- Admin can add seed/test profiles for demo and initial launch.
- Admin-created seed profiles are marked internally for testing/seed tracking.
- No bulk import is required at the start.
- No field-agent workflow is required at the start.
- Admin analytics include total profiles, verified profiles, search terms, contact/profile views, contact reveals, and top categories.
- Admin can send notifications.
- Admin actions should be logged, especially sensitive changes.
- CSV/export support is included in the MVP system design.
- User-facing admin screens are not part of the mobile wireframe.

### 15.3 Duplicate Or Non-Material Questions Removed

This round will not ask again:

- whether admin dashboard exists;
- whether verification is manual;
- whether admin can create seed profiles;
- whether admin analytics exist;
- whether admin actions are audit logged;
- whether mobile wireframe needs admin screens;
- whether field agents are needed in MVP;
- whether bulk import is needed at launch.

### 15.4 Architect-Owned Defaults Proposed For Round 8

Unless product-owner answers require a change:

- Use backend-only admin endpoints under `/v1/admin`.
- Admin dashboard never writes directly to marketplace tables.
- Admin authentication is separate from normal mobile user auth or requires an admin role mapped server-side.
- Every sensitive admin mutation writes `admin_audit_logs`.
- Admin list endpoints use pagination, filters, and export jobs where result sets can grow.
- Verification proof document access uses short-lived URLs and audit logs.
- Admin analytics are read-only and never exposed to normal users.
- Admin-created profiles include internal flags such as `created_by_admin_user_id`, `is_admin_seeded`, and `claim_status`.
- Admin destructive actions are soft-delete/suspend/remove, not hard delete.

These are technical defaults, not yet recorded as accepted product-owner decisions.

### 15.5 Material Decisions Requiring Product-Owner Approval

1. Whether the MVP admin API should implement role-based admin permissions from day one, or keep all admins as super-admin initially.
2. Whether admin-created seed profiles should be publicly searchable before a real user claims them.
3. Whether admin suspension should block only the account, only hide the profile/content, or do both together.
4. Which CSV exports should exist in MVP.
5. Whether admin can directly edit user profile/work/post data, or only request changes from the owner except for moderation/status fields.

### Question 1: MVP Admin Permission Model

**Options presented**

- Option A: All admins are super-admin in the MVP.
- Option B: Role-based admin permissions from day one: `super_admin`, `verifier`, `support`, `viewer`.

**Architect recommendation before answer**

Option B. Verification documents, reports, exports, and suspension are sensitive enough that role separation is healthier even in an MVP.

**Product owner answer**

Option A: all admins are super-admin in MVP.

**Accepted decision**

For the MVP, every active admin account is treated as a full-access super-admin by the admin API. The database can still keep a `role` column for future separation, but MVP authorization does not need per-admin capability branching.

**Reasoning**

The MVP is run by a very small founder/admin group. Implementing role-based admin permission screens now adds overhead. The tradeoff is higher risk, so admin accounts must be limited, protected, and audited.

**Contract implications**

- Endpoints: `/v1/admin/*` endpoints require active admin authentication; no fine-grained admin role checks in MVP.
- Authorization: all active admins have full admin access.
- Validation: admin account must be explicitly provisioned; normal mobile users cannot become admins through profile data.
- Database: keep `admin_users.role` with `super_admin` default for future; do not require verifier/support/viewer roles in MVP.
- Wireframe/client states: no mobile impact; admin dashboard can be simpler.
- Security/privacy: strict admin account control, audit logging, and no shared admin accounts are more important because every admin is powerful.

**Remaining uncertainty**

Before broader team/public launch, split admin permissions into at least verifier, support, viewer, and super-admin.

### Question 2: Public Searchability Of Admin-Seeded Profiles

**Options presented**

- Option A: Admin-created seed profiles are public/searchable before claimed, internally marked as admin-seeded.
- Option B: Admin-created seed profiles stay hidden until claimed by a real user.
- Option C: Admin-created seed profiles are public but visibly labelled as admin-added.

**Architect recommendation before answer**

Option A. Seed profiles exist to create initial marketplace liquidity for private demos; visible public labels may reduce trust and are not needed if admin uses only accurate known data.

**Product owner answer**

Option A: public/searchable before claimed, internally marked as admin-seeded.

**Accepted decision**

Admin-created seed profiles can be public and searchable before a real user claims them. They are internally marked as admin-seeded/unclaimed, but the public app does not need to show an "admin added" label in the MVP.

**Reasoning**

The private demo needs enough supply to make search useful. Keeping seed status internal allows admin to track data provenance without weakening user trust in the marketplace UI.

**Contract implications**

- Endpoints: admin profile-create endpoints can create public profile shells without `owner_user_id`.
- Authorization: only admins can create or edit unclaimed seed profiles.
- Validation: seed profiles still need minimum public fields/photos before being searchable.
- Database: use `owner_user_id = null`, `created_by_admin_user_id`, `is_admin_seeded`, and `claim_status = 'unclaimed'` or equivalent.
- Wireframe/client states: public result/profile cards look normal unless later product decision adds a label.
- Security/privacy: admin must only seed data that is safe/authorized to publish; seed creation is audit logged.

**Remaining uncertainty**

Claim flow is not implemented in MVP; admin may manually convert/assign later.

### Question 3: Admin Suspension Effect

**Options presented**

- Option A: Suspend account only, but profile may remain visible.
- Option B: Hide profile/content only, but account can still use the app.
- Option C: Do both: block account except Logout/Support and remove profile/content from search/public lists.

**Architect recommendation before answer**

Option C for serious admin suspension. A suspended user should not keep participating, and their profile should not keep receiving leads through public discovery.

**Product owner answer**

Option C: block account except Logout/Support and remove profile/content from search/public lists.

**Accepted decision**

Admin suspension blocks the account from normal app use except Logout and Contact Support, and removes that user's profile/content from search, recommendation, similar-profile lists, and public discovery.

**Reasoning**

Suspension is a trust/safety action. Leaving either the account or public profile active creates a gap: the user could continue abuse, or other users could contact a suspended profile.

**Contract implications**

- Endpoints: authenticated app endpoints return `account_suspended` except logout/support; public profile/content endpoints return unavailable or non-public for suspended profiles.
- Authorization: only admin can suspend/unsuspend.
- Validation: suspension requires an admin reason/note internally even if not shown to the user.
- Database: set `users.account_status = 'suspended'`; set `profiles.visibility_status = 'suspended_by_admin'`; dependent work cards/posts are excluded from public/search responses.
- Wireframe/client states: blocked account state allows Logout and Contact Support.
- Security/privacy: suspension and unsuspension are sensitive admin actions and must be audit logged.

**Remaining uncertainty**

The user-facing suspension message copy can be finalized during app implementation.

### Question 4: MVP CSV Exports

**Options presented**

- Option A: Profiles only.
- Option B: Profiles, verification cases, reports, and search/contact analytics summary.
- Option C: No CSV exports in MVP.

**Architect recommendation before answer**

Option B. The private demo needs enough exportability to inspect marketplace quality, verification work, reports, and demand signals outside the app.

**Product owner answer**

Option B: profiles, verification cases, reports, and search/contact analytics summary.

**Accepted decision**

MVP admin exports include profiles, verification cases, reports, and search/contact analytics summaries.

**Reasoning**

Exports will help evaluate demo progress, clean data, inspect reports, and understand which searches/contact actions prove marketplace value. They must not become a sensitive-data leak.

**Contract implications**

- Endpoints: admin export endpoints support datasets such as `profiles`, `verification_cases`, `reports`, `search_summary`, and `contact_summary`.
- Authorization: admin-only; in MVP all active admins can export.
- Validation: exports should support filters/date ranges where useful and reject unknown datasets.
- Database: export queries read from core profile, verification, report, search, contact, and analytics tables.
- Wireframe/client states: no mobile impact.
- Security/privacy: export activity is audit logged; exports must not include private proof document URLs, raw internal notes beyond needed admin fields, or raw sensitive identity numbers.

**Remaining uncertainty**

Large export jobs can start synchronous for MVP if data is tiny, but the contract should allow async export jobs later.

### Question 5: Admin Editing Of User Content

**Options presented**

- Option A: Admin can directly edit profile/work/post fields.
- Option B: Admin can only change moderation/status fields and request changes from owner; direct edits are allowed only for admin-seeded profiles.
- Option C: Admin cannot edit anything, only approve/reject.

**Architect recommendation before answer**

Option B. Directly editing real user content creates trust and accountability problems, but admin-seeded demo profiles need admin editing.

**Product owner answer**

Option B: admin can only change moderation/status fields and request changes from owner; direct edits only for admin-seeded profiles.

**Accepted decision**

For real user-owned profiles/work cards/work-needed posts, admin can change moderation/status fields, approve/reject/request changes, suspend/remove content, and send notes. Admin cannot directly edit the user's public business/work data. Admin can directly edit admin-seeded profiles because those profiles are owned/managed by the platform until claimed.

**Reasoning**

User-owned marketplace data should remain user-authored. Admin correction should happen through request-changes workflows, not silent edits. Seed profiles are different because admin is the data owner until claim.

**Contract implications**

- Endpoints: admin moderation/status endpoints are separate from owner edit endpoints; admin seed-profile edit endpoints are allowed for unclaimed seeded profiles.
- Authorization: only admins can moderate; only owner can edit real user content except status/moderation actions.
- Validation: admin edit endpoints reject direct content edits when `owner_user_id` exists unless the field is moderation/status/admin note.
- Database: write `admin_audit_logs` for all admin changes; preserve user-owned content history in owner edit flows.
- Wireframe/client states: owner receives request-changes notification when admin needs content fixed.
- Security/privacy: prevents silent admin tampering with user business data.

**Remaining uncertainty**

If field agents are added later, they may need a separate assisted-edit/consent workflow.

### Round 8 Architect-Owned Defaults Accepted

The product-owner answers did not conflict with these technical defaults, except fine-grained admin roles are deferred. Accepted defaults:

- Use backend-only admin endpoints under `/v1/admin`.
- Admin dashboard never writes directly to marketplace tables.
- Admin authentication is separate from normal mobile user auth or requires an admin account mapped server-side.
- Every sensitive admin mutation writes `admin_audit_logs`.
- Admin list endpoints use pagination and filters.
- Verification proof document access uses short-lived URLs and audit logs.
- Admin analytics are read-only and never exposed to normal users.
- Admin-created profiles include internal flags such as `created_by_admin_user_id`, `is_admin_seeded`, and `claim_status`.
- Admin destructive actions are soft-delete/suspend/remove, not hard delete.
- Fine-grained admin roles remain a post-MVP hardening item.

## 16. Round 9: Cross-Cutting API Behaviour, Errors, Retries, Rate Limits, Versioning, And Observability

Status: Completed after product-owner answers on 2026-07-10.

### 16.1 Mandatory Pre-Round Evidence

Read from disk on 2026-07-10 before preparing this round:

1. `outputs/textile-marketplace-database-design.md`
2. `outputs/textile-marketplace-figma-wireframe-spec.md`
3. `outputs/textile-marketplace-mvp-system-design.md`
4. `outputs/textile-marketplace-api-contract-discovery.md`

Relevant sections considered:

- Database design conventions, status constraints, audit logs, analytics/event tables, search/contact logs, admin export, and sensitive-data notes.
- Wireframe loading, empty, error, retry, permission, validation, disabled-button, upload failure, and connection-issue states.
- System design security/privacy controls, rate limiting on OTP/uploads/search, failure modes, structured logs/audit, and `/v1` API boundary.
- Prior API rounds that established backend-proxied auth, idempotent role confirmation, cursor pagination, retry-safe media upload, idempotent saved items, contact/share fire-and-forget analytics, and admin audit logging.

### 16.2 Settled Decisions Extracted Before Asking Questions

- API uses `/v1` prefix.
- REST over HTTPS with JSON.
- UUID ids as strings and ISO 8601 UTC timestamps.
- Cursor pagination for changing feeds/search and bounded page sizes.
- Server-enforced authorization and validation.
- Mobile/admin do not directly write database tables.
- Important writes should be idempotent or retry-safe.
- Search, contact actions, share events, profile views, and admin actions are logged.
- OTP, uploads, and search need rate limiting.
- The app has explicit loading, retry, validation, permission, upload failed, and connection issue states.
- Analytics failures should not block contact/share actions.

### 16.3 Duplicate Or Non-Material Questions Removed

This round will not ask again:

- whether the API is `/v1`;
- whether the app uses backend API/BFF instead of direct table writes;
- whether cursor pagination exists;
- whether media uploads are retry-safe;
- whether saved create/remove is idempotent;
- whether analytics are admin-only;
- whether OTP/upload/search rate limiting exists.

### 16.4 Architect-Owned Defaults Proposed For Round 9

Unless product-owner answers require a change:

- Use one structured error envelope:
  - `code`
  - `message`
  - `details`
  - `request_id`
  - optional `field_errors`
- Use stable machine-readable error codes such as `validation_failed`, `unauthorized`, `forbidden`, `not_found`, `rate_limited`, `account_suspended`, `minimum_photos_required`, and `verification_pending_locked`.
- Return a `request_id` in every response and log it server-side.
- Use idempotency keys for create/submit/transition endpoints that mobile may retry.
- Use server-side request validation and consistent 4xx/5xx semantics.
- Use additive backward-compatible API changes during MVP; breaking changes require a new route/version or client update gate.
- Log request metadata carefully without storing unnecessary sensitive data.

These are technical defaults, not yet recorded as accepted product-owner decisions.

### 16.5 Material Decisions Requiring Product-Owner Approval

1. Whether user-facing API error messages should be very simple and generic, while detailed debug information stays server/admin-only.
2. Whether failed analytics/event logging should ever block user actions such as Call, WhatsApp, share, save, or report.
3. Whether API rate limits should be strict from day one for OTP, search, uploads, reports, and contact actions, even during private demo.
4. Whether old mobile app versions should be allowed with backward-compatible responses only, or whether the backend can force update/upgrade when contract changes.
5. Whether request/device metadata such as IP, user-agent, device id, and app version should be logged for security/debugging where available.

### Question 1: User-Facing Error Detail Level

**Options presented**

- Option A: Simple user-facing message, detailed debug stays server/admin-only.
- Option B: Return detailed technical error to app.

**Architect recommendation before answer**

Option A. Users need clear action, not technical internals. Debug details belong in logs/admin tools.

**Product owner answer**

Option A: simple user-facing message, detailed debug stays server/admin-only.

**Accepted decision**

The API returns simple client-safe messages and stable machine-readable error codes. Detailed stack traces, SQL/provider errors, internal validation context, and debug data remain server/admin-only.

**Reasoning**

Low-digital-literacy users need short actionable messages. Technical details create confusion and can leak implementation or security information.

**Contract implications**

- Endpoints: all endpoints use a structured error envelope with `code`, `message`, `request_id`, optional `field_errors`, and safe `details`.
- Authorization: admin-only diagnostics can access deeper server logs where permitted.
- Validation: field-level validation errors can be returned in simple language.
- Database: no direct database/provider error messages leak to clients.
- Wireframe/client states: UI shows messages like `Please enter the mobile number`, `Incorrect OTP`, `Unable to upload, please retry`, and `Connection issue`.
- Security/privacy: reduces information leakage.

**Remaining uncertainty**

Final UI copy can be refined during implementation.

### Question 2: Analytics Failure Blocking User Actions

**Options presented**

- Option A: Analytics/event logging failure never blocks Call, WhatsApp, share, save, or report.
- Option B: Block until event is saved.

**Architect recommendation before answer**

Option A. Analytics is valuable but should not break the core user action.

**Product owner answer**

Option A: analytics/event logging failure never blocks Call, WhatsApp, share, save, or report.

**Accepted decision**

Failed analytics/event logging must not block user-facing actions such as Call, WhatsApp, share, save, or report.

**Reasoning**

The marketplace exists to connect people. A logging outage should not stop a user from contacting a business/job worker/karigar or reporting a problem.

**Contract implications**

- Endpoints: contact/share/report/save flows should tolerate event-log failure; critical business mutation failures still return errors.
- Authorization: action authorization is separate from analytics persistence.
- Validation: event logging can be retried or dropped depending on action criticality.
- Database: analytics/event tables are not on the critical path for external app open actions.
- Wireframe/client states: user proceeds normally even if invisible analytics fails.
- Security/privacy: security-critical audit logs for admin actions remain mandatory and are not treated as optional analytics.

**Remaining uncertainty**

Report creation itself is a user action and should be saved; only secondary analytics around the report should be non-blocking.

### Question 3: Rate Limits During Private Demo

**Options presented**

- Option A: Strict rate limits for OTP, search, uploads, reports, and contact actions from day one.
- Option B: Loose or no limits during private demo.

**Architect recommendation before answer**

Option A, with admin/test bypasses, because OTP/SMS and uploads are abuse/cost-sensitive.

**Product owner answer**

No limit for OTP, search, uploads, reports, and contact actions.

**Accepted decision**

For the private MVP, do not enforce product-visible usage quotas or normal-user friction limits on OTP, search, uploads, reports, or contact actions. However, the backend/provider must still keep minimum invisible safety controls: SMS provider hard caps, storage/file-size limits, request-size limits, abusive IP/device blocking, emergency admin kill switches, and test/admin bypasses where needed.

**Reasoning**

The product owner wants private-demo users to move freely without being blocked by rate-limit friction. Literal unlimited OTP and upload access is not safe because it can create SMS bombing, storage abuse, cost spikes, or service instability. The correct compromise is no product-visible quota in the private demo, but hard infrastructure guardrails remain.

**Contract implications**

- Endpoints: normal responses should not show "quota used" or contact/search/upload limits in MVP.
- Authorization: active authenticated users get normal access; emergency abuse blocks can override.
- Validation: upload size/type/photo-count validation still applies; OTP provider and SMS gateway limits still apply.
- Database: no user-facing quota counters are needed for MVP rate limits; abuse/security logs may still record request metadata.
- Wireframe/client states: do not design quota-limit UI for MVP; generic retry/error may appear if provider/infrastructure refuses abuse.
- Security/privacy: this intentionally weakens strict anti-abuse posture for speed/private testing, so admin monitoring and provider caps are required.

**Remaining uncertainty**

This conflicts with the earlier system-design wording "rate limiting on OTP, uploads, and search." Final API/spec pass should rewrite that as "no product-visible limits during private MVP; hidden provider/infrastructure safety controls remain mandatory."

### Question 4: Old Mobile App Version Handling

**Options presented**

- Option A: Keep backward-compatible responses when possible, but backend can force update for breaking/security changes.
- Option B: Always support all old app versions.
- Option C: No version control in MVP.

**Architect recommendation before answer**

Option A. It balances speed with safety.

**Product owner answer**

Option A: keep backward-compatible responses when possible, but backend can force update for breaking/security changes.

**Accepted decision**

The backend should keep responses backward-compatible where reasonable, but it may force app update for breaking contract changes, severe bugs, or security/privacy fixes.

**Reasoning**

During MVP, the app and API will evolve quickly. Backward compatibility avoids needless breakage, but old versions cannot be supported forever if they become unsafe.

**Contract implications**

- Endpoints: include client app version/platform metadata in requests where possible.
- Authorization: backend can return a structured `app_update_required` error/state.
- Validation: compatibility checks happen early in request handling.
- Database: device/app-version metadata may be stored with user devices/session records.
- Wireframe/client states: future forced-update screen may be needed; not central to MVP wireframe.
- Security/privacy: allows fast response to vulnerable old builds.

**Remaining uncertainty**

Minimum app-version policy can be simple config in MVP.

### Question 5: Request And Device Metadata Logging

**Options presented**

- Option A: Log IP, user-agent, device id, and app version where available for security/debugging.
- Option B: Avoid all metadata logging.

**Architect recommendation before answer**

Option A, with admin-only access and later retention controls.

**Product owner answer**

Option A: log IP, user-agent, device id, and app version where available for security/debugging.

**Accepted decision**

The backend can log request/device metadata such as IP address, user agent, device id, platform, and app version where available for security, debugging, abuse investigation, and analytics quality.

**Reasoning**

This helps investigate OTP abuse, fake reports, contact misuse, upload issues, app version bugs, and admin/security incidents.

**Contract implications**

- Endpoints: request middleware captures metadata where available; action/event endpoints may store relevant metadata.
- Authorization: metadata is admin/system-only, not visible to normal users.
- Validation: device id should be an app-generated/device-install identifier, not unnecessary hardware identifiers.
- Database: event/log tables may include `ip_address`, `user_agent`, `device_id`, and `app_version`.
- Wireframe/client states: no user-visible impact.
- Security/privacy: retention and access limits are required before public launch; do not log more than needed.

**Remaining uncertainty**

Retention duration and masking rules are not locked for public launch.

### Round 9 Architect-Owned Defaults Accepted

The product-owner answers did not conflict with these technical defaults, except strict rate limits are changed to no product-visible limits with hidden abuse safeguards. Accepted defaults:

- Use one structured error envelope:
  - `code`
  - `message`
  - `details`
  - `request_id`
  - optional `field_errors`
- Use stable machine-readable error codes such as `validation_failed`, `unauthorized`, `forbidden`, `not_found`, `account_suspended`, `minimum_photos_required`, `verification_pending_locked`, and `app_update_required`.
- Return a `request_id` in every response and log it server-side.
- Use idempotency keys for create/submit/transition endpoints that mobile may retry.
- Use server-side request validation and consistent 4xx/5xx semantics.
- Use additive backward-compatible API changes during MVP; breaking/security changes may trigger forced update.
- Log request metadata carefully without storing unnecessary sensitive data.
- Keep provider/infrastructure safety controls even though user-visible product quotas are disabled for the private MVP.

## 17. Round 10: Final Conflict Review And Scope Lock

Status: Completed after product-owner answers on 2026-07-10.

### 17.1 Mandatory Pre-Round Evidence

Read from disk on 2026-07-10 before preparing this round:

1. `outputs/textile-marketplace-database-design.md`
2. `outputs/textile-marketplace-figma-wireframe-spec.md`
3. `outputs/textile-marketplace-mvp-system-design.md`
4. `outputs/textile-marketplace-api-contract-discovery.md`

Relevant sections considered:

- All completed API discovery rounds 1-9.
- Database design areas affected by API answers: role/profile completion, work-needed status, verification status, media upload status, reports, admin roles, contact reveal/event tables, app/user settings, and request metadata.
- Wireframe states affected by API answers: onboarding, profile completion, search cards, profile detail contact reveal, verification states, saved/report/share/notification/settings, and error/empty/loading states.
- MVP system design conflicts around rate limiting, admin roles, Supabase/backend boundary, verification, exports, and no paid/subscription enforcement in MVP.

### 17.2 Conflicts And Corrections Found Before Asking Questions

1. **Rate limits wording conflict**
   - Earlier system design says OTP, uploads, and search need rate limiting.
   - Round 9 product answer says no limits for OTP, search, uploads, reports, and contact actions.
   - Proposed final wording: no product-visible limits/quotas in private MVP, but hidden provider/infrastructure abuse safeguards remain mandatory.

2. **Admin roles conflict**
   - Database supports admin roles such as `super_admin`, `verifier`, `support`, and `viewer`.
   - Round 8 product answer says all admins are super-admin in MVP.
   - Proposed final wording: keep role column for future, but MVP treats all active admins as full-access super-admin.

3. **Job-worker profile completion vs work-search readiness**
   - Earlier database/profile wording can imply a job worker needs a work card for profile completion.
   - Round 2 says job-worker profile can become 100% complete without a work card, but job-worker work search requires at least one published work card.
   - Proposed final wording: separate `profile_completion` from `work_search_readiness`.

4. **Work-needed post status**
   - Database design originally included active/paused/closed/removed/deleted style statuses.
   - Round 4 explicitly requires drafts for work-needed posts.
   - Proposed final wording: include `draft` for work-needed posts and owner publish flow.

5. **Public contact reveal in free MVP**
   - MVP shows contact/address directly on profile detail.
   - Round 2 still requires `contact_reveals` records when profile detail returns contact/address.
   - Proposed final wording: profile detail returns contact/address during free MVP and records one reveal per viewer/profile.

6. **Private proof retention**
   - MVP keeps private proof documents after review.
   - System design says retention policy is needed before public launch.
   - Proposed final wording: private MVP retains proof with admin-only audited access; public launch requires retention/deletion policy.

7. **Duplicate reports**
   - Database may be read as a normal report table, but Round 7 allows repeated reports.
   - Proposed final wording: no uniqueness constraint on reporter/target/reason; admin queues group reports.

### 17.3 Duplicate Or Non-Material Questions Removed

This round will not ask for new product features. It exists only to lock the final API discovery source of truth before producing the API contract, OpenAPI draft, authorization matrix, and screen-to-API traceability.

### 17.4 Material Final Decisions Requiring Product-Owner Approval

1. Approve the rate-limit correction: no product-visible limits in private MVP, but hidden provider/infrastructure safeguards remain mandatory.
2. Approve keeping database admin role support while MVP treats all active admins as super-admin.
3. Approve separating job-worker profile completion from work-search readiness.
4. Approve adding `draft` to work-needed post lifecycle in final API/database correction.
5. Approve final scope lock: after this round, stop discovery and generate the final API contract documents.

### Question 1: Rate-Limit Correction

**Options presented**

- Option A: Approve no product-visible limits/quotas in private MVP, but hidden provider/infrastructure safeguards remain mandatory.
- Option B: Keep strict user-visible rate limits from day one.

**Architect recommendation before answer**

Option A, with the warning that "no limits" must not mean disabling provider hard caps, file-size checks, abuse blocking, or emergency controls.

**Product owner answer**

No product-visible limits/quotas in private MVP, but hidden provider/infrastructure safeguards remain mandatory.

**Accepted decision**

The final API contract must not expose product-visible quotas or normal-user rate-limit UI for OTP, search, uploads, reports, or contact actions in the private MVP. The backend and providers still keep invisible abuse and cost safeguards.

**Reasoning**

Private demo users should not hit artificial product limits while the app is being tested. At the same time, OTP/SMS, uploads, and high-volume traffic can create real cost and security incidents, so infrastructure safeguards remain non-negotiable.

**Contract implications**

- Endpoints: no quota fields or "remaining limit" responses for MVP user flows.
- Authorization: emergency abuse blocks and admin/test bypasses are allowed.
- Validation: file-size, MIME type, payload-size, OTP provider caps, and storage limits remain enforced.
- Database: user-facing quota tables remain future monetization placeholders; abuse/security logs may store request metadata.
- Wireframe/client states: no quota-limit UI in MVP.
- Security/privacy: provider/infrastructure safeguards are required even though users do not see quota messaging.

**Remaining uncertainty**

Public launch may need visible limits, clearer abuse messaging, and formal rate-limit policies.

### Question 2: Admin Role Correction

**Options presented**

- Option A: Keep database admin role support for future, but MVP treats all active admins as super-admin.
- Option B: Enforce fine-grained roles in MVP.

**Architect recommendation before answer**

Option A as a pragmatic MVP correction, with a post-MVP hardening note.

**Product owner answer**

Database can keep admin role support for future, but MVP treats all active admins as super-admin.

**Accepted decision**

The database may keep role columns and future role names, but MVP admin authorization treats every active admin as full-access super-admin.

**Reasoning**

The MVP admin group is small. Fine-grained roles would slow implementation. The cost is risk, so admin accounts must be few, protected, and audited.

**Contract implications**

- Endpoints: `/v1/admin/*` checks active admin status, not fine-grained capability.
- Authorization: all active admins can verify, moderate, export, suspend, manage categories, and create seed profiles.
- Validation: normal user accounts cannot self-promote.
- Database: keep `admin_users.role` for future but default/use `super_admin` in MVP.
- Wireframe/client states: no mobile impact.
- Security/privacy: admin audit logs become especially important.

**Remaining uncertainty**

Before adding more team members, implement proper `super_admin`, `verifier`, `support`, and `viewer` permissions.

### Question 3: Job-Worker Profile Completion Correction

**Options presented**

- Option A: Keep earlier split: job-worker profile can be 100% complete without a work card, but appears in work search only after a published work card.
- Option B: Final correction: job-worker profile is not 100% complete until at least one work card is added.

**Architect recommendation before answer**

Option A was previously recommended for conceptual separation, but Option B better matches the product owner's final requirement and the marketplace's photo-first search behavior.

**Product owner answer**

In job-worker profile completion, he should add at least one work; then only 100% profile is complete.

**Accepted decision**

This final answer supersedes the earlier Round 2 decision. A job-worker/value-adder profile is not 100% complete until the user has added at least one valid work card. That work card must meet the MVP publish requirements before the profile can show as fully complete and rank as complete.

**Reasoning**

For job workers, the work card is the real searchable/trust object. A job-worker profile without any work card is not useful enough to count as complete in this marketplace.

**Contract implications**

- Endpoints: `GET /v1/me` and `GET /v1/me/profile` return incomplete profile state for job workers with zero valid work cards.
- Authorization: only the profile owner can add the required work card.
- Validation: job-worker completion calculation requires at least one publishable/published work card with required fields and photos.
- Database: completion calculation must include a job-worker work-card requirement; `completion_flags` should include `missing_work_card`.
- Wireframe/client states: profile completion prompt for job workers must push "Add at least one work" before 100%.
- Security/privacy: no special risk.

**Remaining uncertainty**

Final implementation must decide whether a draft-but-valid work card counts. The safer contract is: only a published work card counts for 100% completion.

### Question 4: Work-Needed Post Lifecycle Correction

**Options presented**

- Option A: Add `draft` to work-needed post lifecycle and keep publish/active/paused/closed/removed/deleted behavior.
- Option B: Keep only active/paused/closed/removed/deleted without draft.

**Architect recommendation before answer**

Option A. It matches Round 4 draft support and gives manufacturers a safe save-before-publish flow.

**Product owner answer**

Work-needed posts must support draft plus publish/active/paused/closed/removed/deleted states.

**Accepted decision**

Work-needed posts must support a draft state and owner publish flow. In the final API contract, `publish` is represented as an action/transition, while the public published state is `active`. The lifecycle is: `draft`, `active`, `paused`, `closed_by_user`, `removed_by_admin`, and `deleted`.

**Reasoning**

Users may need to save an incomplete post while adding photos/details. A draft state avoids forcing incomplete demand posts into public search.

**Contract implications**

- Endpoints: work-needed posts support create draft, update draft, publish, pause, resume, close, delete, and admin remove.
- Authorization: only business profiles can own work-needed posts; admins can remove/moderate.
- Validation: publishing requires required fields and minimum photos.
- Database: add `draft` to work-needed status constraints; use `active` as the published/searchable status.
- Wireframe/client states: Add Work Needed can save/publish; My Profile can show work-needed post status.
- Security/privacy: no special risk.

**Remaining uncertainty**

Exact enum names in OpenAPI should be stable and map cleanly to database text constraints.

### Question 5: Final Scope Lock And Artifact Generation

**Options presented**

- Option A: Stop discovery after this round and generate final API contract artifacts.
- Option B: Continue asking more discovery rounds.

**Architect recommendation before answer**

Option A. The remaining decisions are implementation-level and should move into the API contract, authorization matrix, traceability, and OpenAPI draft.

**Product owner answer**

Generate `textile-marketplace-mvp-api-contract.md`, `api/openapi.yaml`, authorization matrix, and screen-to-API traceability.

**Accepted decision**

API discovery is complete. Generate the final API contract documents:

1. `outputs/textile-marketplace-mvp-api-contract.md`
2. `api/openapi.yaml`
3. `outputs/textile-marketplace-api-authorization-matrix.md`
4. `outputs/textile-marketplace-screen-api-traceability.md`

Before writing these files, perform a self-critique pass and resolve known conflicts according to the final Round 10 decisions.

**Reasoning**

The API discovery now has enough product, trust, privacy, lifecycle, and admin decisions to produce implementable contract documents. More discovery would slow execution.

**Contract implications**

- Endpoints: final contract should cover auth, profile, search, work cards, work-needed posts, media, verification, saved/report/share/contact/notification/settings, admin, exports, and cross-cutting behavior.
- Authorization: final matrix should separate anonymous, authenticated user, owner, admin, suspended user, and public/openable states.
- Validation: final OpenAPI should include the main request/response shapes and status enums.
- Database: final docs must call out schema corrections for job-worker completion, work-needed draft status, duplicate reports, no product-visible rate limits, and admin role handling.
- Wireframe/client states: traceability document maps major screens to required APIs.
- Security/privacy: backend boundary, private proof handling, audit logs, metadata logging, and hidden safeguards must be explicit.

**Remaining uncertainty**

The OpenAPI file will be a v1 implementation draft, not a generated exhaustive backend schema. It should be reviewed again before coding.

### Round 10 Final Scope Lock Accepted

Final API discovery decisions are locked as of 2026-07-10. The final API contract documents should be generated from:

- the completed API discovery rounds 1-10;
- `outputs/textile-marketplace-database-design.md`;
- `outputs/textile-marketplace-figma-wireframe-spec.md`;
- `outputs/textile-marketplace-mvp-system-design.md`.

Known corrections to carry into final artifacts:

- No product-visible limits/quotas in the private MVP; hidden provider/infrastructure safeguards remain mandatory.
- MVP admin API treats all active admins as super-admin, while database role support remains for future hardening.
- Job-worker profile completion requires at least one published valid work card.
- Work-needed posts support `draft`; `publish` is an action and `active` is the published/searchable state.
- Profile detail returns contact/address during free MVP and records one contact reveal per viewer/profile.
- Private proof documents are retained during private MVP with admin-only audited access; public launch requires retention/deletion policy.
- Duplicate reports are allowed and stored; admin queues must group reports.

# Textile Marketplace 25-Phase Build Plan

Status: source-of-truth implementation plan  
Date: 2026-07-11  
Supersedes: `outputs/textile-marketplace-build-phases-and-folder-structure.md`

## 1. Source Documents Read For This Plan

This 25-phase plan is built after reading the project Markdown documents under `outputs/`:

- `outputs/eraser-mid-fidelity-wireframe-brief.md`
- `outputs/textile-marketplace-api-authorization-matrix.md`
- `outputs/textile-marketplace-api-contract-discovery.md`
- `outputs/textile-marketplace-app-flow-discovery.md`
- `outputs/textile-marketplace-app-flow-spec.md`
- `outputs/textile-marketplace-autoplan-review.md`
- `outputs/textile-marketplace-build-phases-and-folder-structure.md`
- `outputs/textile-marketplace-database-design.md`
- `outputs/textile-marketplace-database-schema-discovery.md`
- `outputs/textile-marketplace-detailed-wireframe-discovery.md`
- `outputs/textile-marketplace-figma-wireframe-spec.md`
- `outputs/textile-marketplace-mid-fidelity-wireframe-spec.md`
- `outputs/textile-marketplace-mvp-api-contract.md`
- `outputs/textile-marketplace-mvp-system-design.md`
- `outputs/textile-marketplace-requirements-discovery.md`
- `outputs/textile-marketplace-screen-api-traceability.md`
- `outputs/textile-marketplace-tech-stack-decision.md`

## 2. Non-Negotiable Build Rules

These rules must be followed before starting any phase:

1. Read this 25-phase plan.
2. Read the phase-specific Markdown files listed under that phase.
3. Read the current code folders touched by that phase.
4. Criticize the planned approach before coding.
5. Implement only the phase scope unless a blocker forces a small supporting change.
6. Verify the phase exit criteria before moving forward.
7. Do not let Flutter or the admin dashboard write marketplace database tables directly.

The architecture remains:

```text
Flutter Android app -> FastAPI backend API/BFF -> Supabase Auth/Postgres/Storage
Next.js admin app   -> FastAPI backend API/BFF -> Supabase Auth/Postgres/Storage
```

## 3. Selected Folder Structure

### 3.1 Folder Structure Critique

Option A: `apps/`, `services/`, `packages/`.

- Good for mature monorepos.
- Less clear for a solo founder because the database layer becomes hidden inside service conventions.
- Easier to over-abstract before the first MVP works.

Option B: `backend/`, `frontend/`, `database/`.

- Clear separation for the actual project parts.
- Easier to explain, inspect, and code with AI assistance.
- Keeps database artifacts visible instead of burying them inside backend folders.
- Slightly less "large company monorepo" style, but better for this MVP.

Option C: separate repositories.

- Cleaner deployment boundaries later.
- Too much coordination overhead now.
- Slower for API, mobile, admin, and migration changes that must move together.

Selected decision: use one monorepo with explicit `backend/`, `frontend/`, `database/`, `api/`, `infra/`, `scripts/`, and `outputs/`.

### 3.2 Final Folder Structure

```text
D:\value
  api
    openapi.yaml
    generated
      mobile
      admin

  backend
    app
      main.py
      core
        config.py
        errors.py
        logging.py
        security.py
        pagination.py
        idempotency.py
      db
        session.py
        models
        repositories
      integrations
        supabase_auth.py
        supabase_storage.py
        fcm.py
      modules
        auth
        me
        profiles
        search
        work_cards
        work_needed_posts
        media
        verification
        saved_items
        reports
        notifications
        contact_actions
        share_links
        admin
      schemas
      services
    tests
      unit
      integration
      contract
    pyproject.toml
    .env.example

  database
    alembic.ini
    migrations
      env.py
      versions
    seeds
      001_business_subtypes.sql
      002_textile_categories.sql
      003_category_aliases.sql
      004_app_settings.sql
    sql
      rls
      indexes
      views
    README.md

  frontend
    mobile
      textile_marketplace_app
        lib
          app
          core
          features
            auth
            home
            search
            profiles
            my_profile
            work_cards
            work_needed_posts
            media
            verification
            saved
            reports
            notifications
            settings
          generated
          shared
        test
        pubspec.yaml
        .env.example

    admin
      src
        app
        components
        features
          auth
          dashboard
          verification
          profiles
          seed_profiles
          reports
          taxonomy
          analytics
          exports
        generated
        lib
      package.json
      .env.example

  infra
    supabase
      buckets.md
      storage-policies.sql
      rls.sql
    render
    vercel

  scripts
    validate_openapi.py
    generate_clients.ps1
    seed_dev_data.py
    smoke_api.ps1

  outputs
    textile-marketplace-*.md
```

### 3.3 Backend Module Pattern

Use this structure for backend modules once they have real logic:

```text
backend/app/modules/<module_name>
  router.py
  schemas.py
  service.py
  repository.py
  permissions.py
```

Keep small modules simple at first. Do not split files just to look enterprise.

## 4. Phase Execution Template

Every phase should be executed with this small checklist:

```text
1. Read this phase plan.
2. Read phase-specific docs.
3. Read current code touched by the phase.
4. Write a short critique of the intended approach.
5. Implement the smallest complete slice.
6. Run validation/tests.
7. Record any decision changes in outputs/.
```

## 5. The 25 Phases

### Phase 1: Source Lock And Repository Skeleton

Read before starting:

- `outputs/textile-marketplace-25-phase-build-plan.md`
- `outputs/textile-marketplace-tech-stack-decision.md`
- `outputs/textile-marketplace-mvp-system-design.md`
- `outputs/textile-marketplace-autoplan-review.md`

Critique before selection:

- If coding starts without a stable folder skeleton, the project will become random files created by each next task.
- If the folder structure is too enterprise-heavy, it will slow a solo MVP before the product loop is proven.
- If old 10-phase planning remains active, future work will drift.

Selected decision:

- Create only the folder skeleton, environment examples, and validation placeholders.
- Treat this 25-phase plan as the current build-order source of truth.

Build scope:

- Create root folders: `backend`, `frontend`, `database`, `api`, `infra`, `scripts`.
- Keep `outputs/` as planning and decision records.
- Add minimal README notes for local setup and phase rule.

Exit criteria:

- Folder skeleton exists.
- No business logic is implemented yet.
- Old build plan is clearly superseded.

### Phase 2: Local Development Tooling And Environment Contracts

Read before starting:

- `outputs/textile-marketplace-tech-stack-decision.md`
- `outputs/textile-marketplace-mvp-api-contract.md`
- `outputs/textile-marketplace-api-authorization-matrix.md`

Critique before selection:

- If `.env` files are improvised later, secrets and provider URLs will leak into code.
- If Docker/local scripts are overbuilt now, setup will consume time before any product behavior exists.
- If tool versions are not pinned, AI-generated commands will drift.

Selected decision:

- Create lightweight local tooling first: environment examples, install commands, validation scripts, and local run commands.

Build scope:

- Backend `.env.example`.
- Mobile `.env.example`.
- Admin `.env.example`.
- Root setup notes.
- Basic `scripts/validate_openapi.py`.
- Basic PowerShell scripts for generation and smoke checks.

Exit criteria:

- A new developer can see which environment variables are required.
- No real secrets are committed.
- OpenAPI validation can run locally.

### Phase 3: OpenAPI Contract And Generated Client Pipeline

Read before starting:

- `api/openapi.yaml`
- `outputs/textile-marketplace-mvp-api-contract.md`
- `outputs/textile-marketplace-screen-api-traceability.md`
- `outputs/textile-marketplace-api-authorization-matrix.md`

Critique before selection:

- If Flutter and admin hand-write API clients, response-shape drift will start immediately.
- If the OpenAPI file is treated as perfect, implementation will fight missing fields.
- If the contract is regenerated too late, frontend work will block on backend naming changes.

Selected decision:

- Keep OpenAPI as the central external contract, but allow backward-compatible field additions during implementation.

Build scope:

- Validate OpenAPI.
- Choose client generation tooling for Dart and TypeScript.
- Generate initial clients into `api/generated/mobile` and `api/generated/admin`, or directly into frontend generated folders if the tool works better that way.
- Add a contract-test placeholder in backend.

Exit criteria:

- OpenAPI parses.
- Client generation command is documented.
- Flutter/admin can import generated API types or have a clear path to do so.

### Phase 4: FastAPI Backend Core

Read before starting:

- `outputs/textile-marketplace-tech-stack-decision.md`
- `outputs/textile-marketplace-mvp-api-contract.md`
- `outputs/textile-marketplace-api-authorization-matrix.md`

Critique before selection:

- If all modules are created fully upfront, there will be empty enterprise-looking code.
- If there is no shared error envelope, every endpoint will invent its own errors.
- If auth/security dependencies are added after endpoints, permissions will become inconsistent.

Selected decision:

- Build a small but real FastAPI core with config, errors, logging, request IDs, auth dependency placeholders, and health checks.

Build scope:

- `backend/app/main.py`
- `backend/app/core/config.py`
- `backend/app/core/errors.py`
- `backend/app/core/logging.py`
- `backend/app/core/security.py`
- `backend/app/core/pagination.py`
- Health endpoint.
- Shared error envelope.

Exit criteria:

- Backend starts locally.
- Health endpoint works.
- Error response format matches the API contract.

### Phase 5: Database Migration Foundation

Read before starting:

- `outputs/textile-marketplace-database-design.md`
- `outputs/textile-marketplace-database-schema-discovery.md`
- `outputs/textile-marketplace-tech-stack-decision.md`

Critique before selection:

- If migrations live only in backend internals, the database design becomes less visible.
- If migrations are written as loose SQL files only, SQLAlchemy models and migrations can drift.
- If all schema is added in one huge migration, rollback and review become painful.

Selected decision:

- Keep Alembic under `database/`, with migrations importing backend SQLAlchemy metadata when useful.

Build scope:

- `database/alembic.ini`
- `database/migrations/env.py`
- First migration for PostgreSQL extensions:
  - `pgcrypto`
  - `pg_trgm`
- Migration naming rules.

Exit criteria:

- Empty database can run the first migration.
- Migration command is documented.
- Backend can connect to the migrated database.

### Phase 6: Identity, Admin, Device, Settings Schema

Read before starting:

- `outputs/textile-marketplace-database-design.md`
- `outputs/textile-marketplace-api-authorization-matrix.md`
- `outputs/textile-marketplace-mvp-api-contract.md`

Critique before selection:

- If auth provider IDs are not mapped carefully, Supabase Auth and app users will drift.
- If admin users are delayed too long, verification and moderation cannot be tested.
- If settings/devices are ignored, push notifications and hide-from-search will become hacks later.

Selected decision:

- Build base identity tables before profile tables.

Build scope:

- `users`
- `user_settings`
- `user_devices`
- `admin_users`
- `admin_audit_logs`
- `app_settings`
- Active mobile uniqueness for non-terminated users.

Exit criteria:

- User account lifecycle states exist: `active`, `suspended`, `terminated`.
- Admin audit table exists before admin mutations are built.
- Free launch mode can be stored in `app_settings`.

### Phase 7: Taxonomy And Seed Data Schema

Read before starting:

- `outputs/textile-marketplace-requirements-discovery.md`
- `outputs/textile-marketplace-database-design.md`
- `outputs/textile-marketplace-database-schema-discovery.md`

Critique before selection:

- If taxonomy is hardcoded in Flutter, search and admin mapping will fail.
- If taxonomy is over-modeled too early, field vocabulary changes will be slow.
- If local aliases are ignored, Surat textile search quality will be poor.

Selected decision:

- Store taxonomy in normalized tables with aliases and suggestions.

Build scope:

- `categories`
- `category_aliases`
- `category_suggestions`
- `business_subtypes`
- Seed files for initial textile work categories, work names, product types, and business subtypes.

Exit criteria:

- Flat hemming, embroidery, digital print, zari work, dupatta, saree, fabric, and similar MVP terms exist in seed data.
- Custom user-entered terms can later create suggestions.

### Phase 8: Core Profile Schema And Role Extension Tables

Read before starting:

- `outputs/textile-marketplace-database-design.md`
- `outputs/textile-marketplace-requirements-discovery.md`
- `outputs/textile-marketplace-figma-wireframe-spec.md`

Critique before selection:

- If one giant profile table stores every role field, the schema becomes messy quickly.
- If each role has a fully separate profile table, search and contact reveal become duplicated.
- If profile visibility is mixed with verification, unverified but legitimate users will disappear.

Selected decision:

- Use one common `profiles` table plus role-specific extension tables.

Build scope:

- `profiles`
- `business_profiles`
- `business_profile_product_types`
- `profile_business_subtypes`
- `job_worker_profiles`
- `skilled_worker_profiles`
- `profile_gst_details`
- `profile_change_history`

Exit criteria:

- One active user can own one active profile.
- Role-specific fields are separate.
- Verification status and visibility status are independent.

### Phase 9: Marketplace Content Schema

Read before starting:

- `outputs/textile-marketplace-database-design.md`
- `outputs/textile-marketplace-mvp-api-contract.md`
- `outputs/textile-marketplace-screen-api-traceability.md`

Critique before selection:

- If job-worker work is stored only as profile text, search cards cannot be photo-first work cards.
- If work-needed posts are modeled like job posts with hiring workflows, the MVP expands beyond connection.
- If status values are rigid enums, product learning will require painful migrations.

Selected decision:

- Make work cards and work-needed posts first-class searchable objects with text CHECK status values.

Build scope:

- `work_cards`
- `work_card_product_types`
- `work_needed_posts`
- `work_needed_post_product_types`
- Status constraints:
  - work cards: `draft`, `published`, `hidden_by_user`, `removed_by_admin`, `deleted`
  - work-needed posts: `draft`, `active`, `paused`, `closed_by_user`, `removed_by_admin`, `deleted`

Exit criteria:

- Job-worker work can be searched separately from profile data.
- Manufacturer demand posts can be searched separately from business profile data.

### Phase 10: Media, Verification, Analytics, And Placeholder Schema

Read before starting:

- `outputs/textile-marketplace-database-design.md`
- `outputs/textile-marketplace-mvp-api-contract.md`
- `outputs/textile-marketplace-api-authorization-matrix.md`

Critique before selection:

- If media is added after profile/work APIs, upload logic will be bolted on.
- If verification tables are delayed, blue tick and admin review cannot be tested.
- If analytics tables are skipped, the launch will have no evidence of what users searched or revealed.

Selected decision:

- Add cross-cutting schema before implementing the endpoint modules that use it.

Build scope:

- `media_assets`
- `verification_cases`
- `verification_checks`
- `verification_provider_checks`
- `saved_items`
- `reports`
- `notifications`
- `search_logs`
- `profile_view_events`
- `contact_action_events`
- `share_events`
- `contact_reveals`
- Inert monetization placeholders:
  - `user_contact_quotas`
  - `subscription_plans`
  - `user_subscriptions`
  - `payment_transactions`
  - `admin_access_grants`

Exit criteria:

- All MVP tables exist.
- Future payment/contact-reveal tables exist but are not product-visible.
- Private verification media can be separated by visibility.

### Phase 11: Supabase Auth, OTP, Session, And `GET /me`

Read before starting:

- `outputs/textile-marketplace-api-contract-discovery.md`
- `outputs/textile-marketplace-mvp-api-contract.md`
- `outputs/textile-marketplace-api-authorization-matrix.md`
- `outputs/textile-marketplace-tech-stack-decision.md`

Critique before selection:

- If Flutter calls Supabase Auth directly, the project violates the agreed backend boundary.
- If auth is mocked too long, every later endpoint will need rework.
- If OTP responses reveal account existence, mobile-number enumeration risk increases.

Selected decision:

- Implement backend-proxied Supabase Auth through FastAPI.

Build scope:

- `POST /v1/auth/otp/request`
- `POST /v1/auth/otp/verify`
- `POST /v1/auth/account`
- `POST /v1/auth/logout`
- `GET /v1/me`
- Device metadata capture.
- Generic OTP responses.
- Suspended account response handling.

Exit criteria:

- OTP-verified user can get a backend session.
- App user row is created or reused only after OTP succeeds.
- `GET /v1/me` returns onboarding state.

### Phase 12: Flutter Entry, OTP, Role Selection, And Profile Shell

Read before starting:

- `outputs/textile-marketplace-figma-wireframe-spec.md`
- `outputs/textile-marketplace-app-flow-spec.md`
- `outputs/textile-marketplace-screen-api-traceability.md`
- `outputs/textile-marketplace-mvp-api-contract.md`

Critique before selection:

- If the app starts with search before account creation, it violates the flow spec.
- If role selection happens before OTP, returning-user behavior gets confused.
- If role confirmation is only local state, backend profile ownership breaks.

Selected decision:

- Build the entry flow exactly as locked: Splash -> OTP/account -> role selection -> role confirmation -> Home.

Build scope:

- Flutter app shell.
- Secure token storage.
- Splash routing from `GET /v1/me`.
- Create Account / Continue screen.
- OTP Verification.
- Select Role.
- Role Confirmation.
- Backend `POST /v1/auth/role/confirm`.
- Profile shell creation.

Exit criteria:

- New user reaches Home after OTP and role confirmation.
- Returning user reaches Home directly when session is valid.
- Role is saved server-side.

### Phase 13: Owner Profile APIs And Completion Engine

Read before starting:

- `outputs/textile-marketplace-mvp-api-contract.md`
- `outputs/textile-marketplace-database-design.md`
- `outputs/textile-marketplace-screen-api-traceability.md`

Critique before selection:

- If completion logic is only in Flutter, users can bypass required fields.
- If profile completion ignores job-worker work cards, empty job-worker profiles will pollute search.
- If sensitive edits are not tracked now, re-verification will be unreliable.

Selected decision:

- Put role-specific completion rules in backend services.

Build scope:

- `GET /v1/me/profile`
- `PATCH /v1/me/profile`
- `POST /v1/me/profile/complete`
- `POST /v1/me/profile/hide`
- `POST /v1/me/profile/show`
- Completion score and flags.
- Locked field logic.
- Re-verification flags for sensitive changes.

Exit criteria:

- Business, job-worker, and skilled-worker completion rules are enforced server-side.
- Job-worker profile cannot become 100% complete without at least one published valid work card.
- Hide/show changes discovery visibility.

### Phase 14: Flutter My Profile And Profile Completion

Read before starting:

- `outputs/textile-marketplace-figma-wireframe-spec.md`
- `outputs/textile-marketplace-detailed-wireframe-discovery.md`
- `outputs/textile-marketplace-screen-api-traceability.md`
- `outputs/textile-marketplace-mvp-api-contract.md`

Critique before selection:

- If profile forms are too long and unguided, low-literacy users will drop off.
- If the UI hides completion requirements, users will not understand why they are not visible.
- If owner controls look like public profile actions, the app will confuse users.

Selected decision:

- Build role-specific profile completion screens with progress, save behavior, and owner-only controls.

Build scope:

- My Profile dashboard.
- Completion card.
- Business profile form.
- Job-worker profile form.
- Karigar profile form.
- Owner profile preview.
- Settings link for hide from search.

Exit criteria:

- User can save incomplete profile.
- User sees completion percentage and missing items.
- Completed profile state matches backend response.

### Phase 15: Supabase Storage And Media Upload APIs

Read before starting:

- `outputs/textile-marketplace-mvp-api-contract.md`
- `outputs/textile-marketplace-database-design.md`
- `outputs/textile-marketplace-api-authorization-matrix.md`

Critique before selection:

- If signed upload URLs are too broad, users can write outside their allowed area.
- If backend proxies every file forever, cost and latency may rise.
- If upload state is not recorded before upload, failed uploads become hard to recover.

Selected decision:

- Backend creates media records and scoped upload intents. Use signed direct upload only if safely scoped; otherwise backend-proxy upload can be used.

Build scope:

- Supabase public/private buckets.
- `POST /v1/media/upload-intent`
- `POST /v1/media/{media_asset_id}/complete`
- `POST /v1/media/{media_asset_id}/retry`
- `POST /v1/media/{media_asset_id}/cancel`
- `DELETE /v1/media/{media_asset_id}`
- File type, size, width, height checks.
- Profile/shop/workplace photos may be deleted below the completion minimum; published work cards and active/paused/closed work-needed posts retain minimum-photo deletion protection.

Exit criteria:

- Public photos and private verification documents are separated.
- Media lifecycle supports pending, ready, failed, canceled, deleted.
- Owner cannot download private verification proof after upload.

### Phase 16: Flutter Media Upload UX

Read before starting:

- `outputs/textile-marketplace-figma-wireframe-spec.md`
- `outputs/textile-marketplace-screen-api-traceability.md`
- `outputs/textile-marketplace-mvp-api-contract.md`

Critique before selection:

- If images are uploaded uncompressed, poor-network users will suffer.
- If upload errors are vague, low-literacy users will not recover.
- If photo minimum rules appear only at publish time, users will be surprised.

Selected decision:

- Build compression, upload grid, progress, retry, cancel, and clear validation states.

Build scope:

- Image picker.
- Image compression.
- Upload button and grid.
- Upload progress.
- Retry/cancel failed upload.
- Minimum 3 photos validation where required.
- Full-screen gallery for public/detail photos.

Exit criteria:

- User can upload photos from profile, work card, and work-needed flows.
- Failed upload shows `Unable to upload, please retry`.
- Minimum photo errors match the wireframe copy.

### Phase 17: Job-Worker Work Card Backend

Read before starting:

- `outputs/textile-marketplace-mvp-api-contract.md`
- `outputs/textile-marketplace-database-design.md`
- `outputs/textile-marketplace-screen-api-traceability.md`

Critique before selection:

- If work cards are built after search UI, search will be fake.
- If custom `Other` entries are rejected, the taxonomy will miss real Surat vocabulary.
- If publish is not a server-side transition, invalid work cards can enter search.

Selected decision:

- Build draft-first work cards with a strict publish action.

Build scope:

- `GET /v1/me/work-cards`
- `POST /v1/me/work-cards`
- `PATCH /v1/me/work-cards/{work_card_id}`
- `POST /v1/me/work-cards/{work_card_id}/publish`
- `POST /v1/me/work-cards/{work_card_id}/hide`
- `POST /v1/me/work-cards/{work_card_id}/show`
- `DELETE /v1/me/work-cards/{work_card_id}`
- Category suggestion creation for custom terms.
- Search text/vector update on publish/edit.

Exit criteria:

- Job worker can create draft work card.
- Publish requires category, work name, product type, description, and minimum 3 ready photos.
- Published work card updates profile completion.

### Phase 18: Flutter Job-Worker Work Card Flow

Read before starting:

- `outputs/textile-marketplace-figma-wireframe-spec.md`
- `outputs/textile-marketplace-screen-api-traceability.md`
- `outputs/textile-marketplace-detailed-wireframe-discovery.md`

Critique before selection:

- If Add Work is step-by-step, it conflicts with the locked wireframe.
- If work list controls are hidden, job workers will not know how to add/edit work.
- If custom categories are not easy, users will abandon missing options.

Selected decision:

- Build My Profile -> Work List -> sticky plus -> one long Add Work form.

Build scope:

- Owner Work List tab.
- Add Work Card form.
- Category dropdown.
- Work name dropdown.
- Product type selector.
- Other/custom text fields.
- Photo grid.
- Save and Publish.
- Edit, hide/show, delete actions.

Exit criteria:

- Job worker can add a work card from My Profile.
- Published card returns to Work List and appears as published.
- Empty state says `Add your first work to appear in search`.

### Phase 19: Manufacturer Work-Needed Backend

Read before starting:

- `outputs/textile-marketplace-mvp-api-contract.md`
- `outputs/textile-marketplace-database-design.md`
- `outputs/textile-marketplace-screen-api-traceability.md`

Critique before selection:

- If work-needed posts are omitted, job workers cannot discover manufacturer demand.
- If all posts publish immediately without draft support, interrupted users lose data.
- If close/pause semantics are overbuilt, MVP becomes job-board software instead of a connection directory.

Selected decision:

- Build draft support plus publish-to-active, pause, resume, close, and soft delete.

Build scope:

- `GET /v1/me/work-needed-posts`
- `POST /v1/me/work-needed-posts`
- `PATCH /v1/me/work-needed-posts/{post_id}`
- `POST /v1/me/work-needed-posts/{post_id}/publish`
- `POST /v1/me/work-needed-posts/{post_id}/pause`
- `POST /v1/me/work-needed-posts/{post_id}/resume`
- `POST /v1/me/work-needed-posts/{post_id}/close`
- `DELETE /v1/me/work-needed-posts/{post_id}`

Exit criteria:

- Business owner can create draft post.
- Publish requires required fields and minimum 3 ready photos.
- Active posts can later be searched.

### Phase 20: Flutter Manufacturer Work-Needed Flow

Read before starting:

- `outputs/textile-marketplace-figma-wireframe-spec.md`
- `outputs/textile-marketplace-screen-api-traceability.md`
- `outputs/textile-marketplace-app-flow-spec.md`

Critique before selection:

- If manufacturer actions are hidden under settings, the user journey becomes unclear.
- If post status controls are complicated, users will not understand the difference between pause and close.
- If photos are optional here, job workers will not understand what the manufacturer wants.

Selected decision:

- Build My Profile -> Work Needed Posts -> sticky plus -> one long Add Work Needed form.

Build scope:

- Work Needed owner tab.
- Add Work Needed form.
- Category, work name, product type, description.
- Minimum 3 photos.
- Save and Publish.
- Pause, resume, close, delete.

Exit criteria:

- Manufacturer can publish an active work-needed post.
- New post appears in the owner list.
- Status transitions are visible and simple.

### Phase 21: PostgreSQL Search Backend

Read before starting:

- `outputs/textile-marketplace-mvp-api-contract.md`
- `outputs/textile-marketplace-database-design.md`
- `outputs/textile-marketplace-requirements-discovery.md`
- `outputs/textile-marketplace-screen-api-traceability.md`

Critique before selection:

- If search waits until the end, the core product remains unproven.
- If fuzzy search is too aggressive, wrong local results will reduce trust.
- If search ranking is over-optimized early, implementation will slow before enough data exists.

Selected decision:

- Build PostgreSQL search with exact/category/alias/keyword first and conservative fuzzy fallback.

Build scope:

- `GET /v1/search`
- Search one target persona at a time.
- Business modes: `work_needed_posts`, `profiles`.
- Job-worker search returns work cards first.
- Skilled-worker search returns profiles.
- Filters:
  - category/work type
  - product type
  - locality
  - experience
  - verified only
- Sort:
  - best
  - verified first
  - nearby/locality match
  - most photos
  - recent
- Search logs.
- Search vector and trigram indexes.

Exit criteria:

- Searching `flat hemming` returns job-worker work cards.
- Result cards do not include contact or full address.
- Query, normalized query, filters, target, result count are logged.

### Phase 22: Flutter Home, Search, Results, Profile Detail, Contact Reveal

Read before starting:

- `outputs/textile-marketplace-figma-wireframe-spec.md`
- `outputs/textile-marketplace-screen-api-traceability.md`
- `outputs/textile-marketplace-mvp-api-contract.md`
- `outputs/eraser-mid-fidelity-wireframe-brief.md`

Critique before selection:

- If Home is overloaded, low-literacy users will not understand where to start.
- If profile detail is built before search cards, card-to-detail behavior may not match.
- If contact reveal is local-only, analytics and future monetization will break.

Selected decision:

- Build the main discovery journey end to end: Home -> Search -> Result -> Profile detail -> Call/WhatsApp.

Build scope:

- Home with three find cards.
- Search screen with tabs.
- Recommended results.
- Filter sheet.
- Loading skeleton.
- No results and invite action.
- Job-worker result cards.
- Manufacturer result cards.
- Karigar result cards.
- `GET /v1/profiles/{profile_id}` detail.
- Contact reveal logging once per viewer/profile.
- Call and WhatsApp buttons.

Exit criteria:

- Manufacturer can find a flat hemming job worker and contact them.
- Search cards hide contact/address.
- Profile detail shows contact/address during free MVP and records reveal.

### Phase 23: Saved, Share, Reports, Contact Actions, Notifications, Settings

Read before starting:

- `outputs/textile-marketplace-mvp-api-contract.md`
- `outputs/textile-marketplace-screen-api-traceability.md`
- `outputs/textile-marketplace-figma-wireframe-spec.md`
- `outputs/textile-marketplace-api-authorization-matrix.md`

Critique before selection:

- If saved/share/report are delayed too long, profile detail feels unfinished.
- If report duplication is blocked, admin loses repeated abuse signal.
- If analytics failures block user actions, the app will feel broken in poor networks.

Selected decision:

- Build support actions after core discovery works, with analytics failures non-blocking where specified.

Build scope:

- `GET /v1/me/saved-items`
- `POST /v1/me/saved-items`
- `DELETE /v1/me/saved-items/{saved_item_id}`
- `POST /v1/reports`
- `POST /v1/contact-actions`
- `POST /v1/share-links`
- `GET /v1/me/notifications`
- `POST /v1/me/notifications/{notification_id}/read`
- `POST /v1/me/device-tokens`
- `GET /v1/me/settings`
- `PATCH /v1/me/settings`
- Saved screen.
- Share sheet.
- Report reason sheet.
- Notifications screen.
- Settings screen.
- Hide from search setting.

Exit criteria:

- User can save, share, report, call, WhatsApp, mark notifications read, and change push setting.
- In-app notifications are stored even if push is disabled.
- Report submission creates admin-reviewable rows.

### Phase 24: Verification And Admin Dashboard MVP

Read before starting:

- `outputs/textile-marketplace-mvp-api-contract.md`
- `outputs/textile-marketplace-database-design.md`
- `outputs/textile-marketplace-api-authorization-matrix.md`
- `outputs/textile-marketplace-screen-api-traceability.md`
- `outputs/textile-marketplace-requirements-discovery.md`

Critique before selection:

- If verification is built without admin review, blue tick has no trust value.
- If admin can freely edit user-owned content, audit and user trust become weak.
- If admin dashboard becomes a giant platform now, MVP will stall.

Selected decision:

- Build the smallest real admin dashboard that can verify, seed, moderate, inspect reports, and see basic analytics.

Build scope:

Owner verification:

- `GET /v1/me/verification`
- `POST /v1/me/verification/submit`
- `POST /v1/me/verification/resubmit`

Admin API:

- `GET /v1/admin/me`
- `GET /v1/admin/verification-cases`
- `GET /v1/admin/verification-cases/{case_id}`
- `POST /v1/admin/verification-cases/{case_id}/approve`
- `POST /v1/admin/verification-cases/{case_id}/request-changes`
- `POST /v1/admin/verification-cases/{case_id}/reject`
- `GET /v1/admin/profiles`
- `POST /v1/admin/seed-profiles`
- `POST /v1/admin/profiles/{profile_id}/suspend`
- `POST /v1/admin/profiles/{profile_id}/unsuspend`
- `GET /v1/admin/reports`
- `GET /v1/admin/analytics/summary`
- `POST /v1/admin/exports`

Admin frontend:

- Admin login/me.
- Verification queue.
- Verification detail.
- Approve/request changes/reject.
- Profile list.
- Seed profile create.
- Reports queue.
- Suspend/unsuspend.
- Basic analytics cards.
- CSV export trigger.

Exit criteria:

- Admin can approve verification and public blue tick appears.
- Admin can request changes and user can resubmit.
- Admin can seed demo profiles.
- Admin can suspend/remove from discovery.
- Admin mutations are audit logged.

### Phase 25: Hardening, QA, Deployment, And Private Demo Launch

Read before starting:

- All project Markdown documents under `outputs/`
- `api/openapi.yaml`
- Current backend, frontend, database, and infra code

Critique before selection:

- If the app launches without end-to-end testing, field users will find basic broken flows.
- If privacy is reviewed after launch, verification documents and contact data may be mishandled.
- If deployment is done before seed data and admin recovery are ready, the private demo cannot be operated.

Selected decision:

- Treat launch as a phase, not a single deploy command.

Build scope:

- API contract tests.
- Database migration test from empty database.
- Android happy-path test.
- Backend integration tests for:
  - OTP/session
  - profile completion
  - media upload lifecycle
  - work card publish
  - work-needed publish
  - search
  - contact reveal de-duplication
  - verification review
  - suspension access blocking
- Admin smoke tests.
- Seed data:
  - 20-50 business profiles
  - 50-100 job-worker work cards
  - 20-50 skilled worker profiles
  - Surat locality/category aliases
- Deployment:
  - Supabase Pro before real private users
  - FastAPI on Render or Railway initially
  - Admin on Vercel or Render
  - Android APK/internal testing build
- Security/privacy checks:
  - no secrets in repo
  - no direct Supabase service key in frontend
  - no raw Aadhaar/PAN/identity number fields
  - private verification media not public
  - admin exports exclude proof-document URLs

Exit criteria:

- Three critical journeys work end to end:
  1. Manufacturer finds flat hemming job worker.
  2. Job worker adds work card.
  3. Manufacturer posts work needed.
- Admin can verify, request changes, seed profiles, inspect reports, and suspend.
- Private demo can start with selected Surat users.

## 6. Phase Dependency Map

```text
1 -> 2 -> 3 -> 4 -> 5
5 -> 6 -> 7 -> 8 -> 9 -> 10
6 -> 11 -> 12
8 -> 13 -> 14
10 -> 15 -> 16
9 -> 17 -> 18
9 -> 19 -> 20
7,9,13,17,19 -> 21
12,14,18,20,21 -> 22
22 -> 23
10,13,15,16,23 -> 24
1-24 -> 25
```

## 7. What Must Not Enter These 25 Phases

Do not build in the MVP:

- Payments/subscriptions.
- iOS app.
- Voice search.
- Map/GPS search.
- Ratings/reviews.
- Chat.
- Automated Aadhaar/GST provider verification.
- OpenSearch/Meilisearch.
- Redis queue/caching layer.
- Field-agent app.
- Complex admin RBAC.
- Order management.

The database may keep placeholders for future monetization and provider verification, but the product must not expose those flows in the MVP.

## 8. First Phase To Start Coding

Start with Phase 1.

Do not start Flutter UI, database tables, or auth integration before the repository skeleton and local execution rules exist.

The first useful coding target is:

```text
Phase 1 -> Phase 2 -> Phase 3 -> Phase 4 -> Phase 5
```

After Phase 5, the project has enough structure to safely build real database schema and API modules.

# Textile Marketplace MVP Build Phases And Folder Structure

Superseded: use `outputs/textile-marketplace-25-phase-build-plan.md` for implementation planning.

Status: implementation planning draft  
Date: 2026-07-10  
Inputs:

- `outputs/textile-marketplace-tech-stack-decision.md`
- `outputs/textile-marketplace-mvp-api-contract.md`
- `api/openapi.yaml`
- `outputs/textile-marketplace-database-design.md`
- `outputs/textile-marketplace-figma-wireframe-spec.md`
- `outputs/textile-marketplace-screen-api-traceability.md`
- `outputs/textile-marketplace-api-authorization-matrix.md`

## 1. Build Principle

Do not build every API area at the same time.

Build the marketplace in vertical slices:

1. Account exists.
2. User selects role.
3. User completes enough profile data to become visible.
4. Job worker adds a searchable work card.
5. Manufacturer can search it.
6. Manufacturer opens profile detail and sees contact/address.
7. Admin can verify and moderate the profile.

This proves the core product loop before secondary features.

## 2. Self-Critique Before Phasing

### Risk 1: Starting With Flutter UI Before Backend Contracts Work

That would create beautiful screens backed by fake data. For this product, search, profile visibility, media upload, and verification rules are the real complexity. The API and database foundation must come first.

### Risk 2: Building The Whole Admin Panel Too Early

Admin is required, but a full giant-style admin panel will slow the MVP. The first admin build should handle verification, seed profiles, reports, and basic profile control. Advanced analytics/export can come after the marketplace loop works.

### Risk 3: Treating Search As A Late Feature

Search is the product. It must appear early, but not before there is real data to search. Build search immediately after profile/work-card creation works.

### Risk 4: Overengineering For 50M Users In The First Repo

The architecture should not block scale later, but the MVP should remain a modular monolith. The first build should have clean modules, migrations, indexes, logs, and API boundaries, not microservices.

### Risk 5: Letting Supabase Leak Into The App Boundary

The selected stack uses Supabase-managed Auth/Postgres/Storage, but Flutter and Next.js must call FastAPI. Supabase table APIs are not the product backend.

## 3. Recommended Repo Structure

Use one monorepo for the MVP so API contract, backend, mobile, admin, and docs stay aligned.

```text
D:\value
  api
    openapi.yaml
    generated
      mobile
      admin

  apps
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
          shared
        test

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
          analytics
          exports
        lib
        generated

  services
    api
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
      alembic
        versions
      tests
        unit
        integration
        contract

  infra
    supabase
      buckets.md
      rls.sql
      seed_taxonomy.sql
    render
    vercel

  scripts
    validate_openapi.py
    seed_dev_data.py
    generate_clients.ps1

  outputs
    textile-marketplace-*.md
```

## 4. Backend Module Shape

Each FastAPI module should follow the same shape:

```text
modules/<module_name>
  router.py
  schemas.py
  service.py
  repository.py
  permissions.py
  errors.py
```

Use this when the module has enough complexity. For tiny modules, keep `permissions.py` and `errors.py` inside `service.py` until they grow.

Example:

```text
modules/work_cards
  router.py          # HTTP endpoints
  schemas.py         # request/response DTOs
  service.py         # business rules: draft, publish, hide, delete
  repository.py      # SQLAlchemy queries
  permissions.py     # job-worker owner checks
```

## 5. Phase 0: Project Foundation

Goal: create a buildable repo skeleton and stop future drift.

Deliverables:

- FastAPI app skeleton under `services/api`.
- Flutter app skeleton under `apps/mobile/textile_marketplace_app`.
- Next.js admin skeleton under `apps/admin`.
- `.env.example` files for backend, mobile, and admin.
- OpenAPI validation script.
- Basic CI/local commands documented.
- Health endpoint.
- Shared error envelope implemented in backend.

API areas:

- `GET /health` or internal health endpoint.
- No user-facing marketplace APIs yet.

Exit criteria:

- Backend starts locally.
- Mobile app starts and can point to backend base URL.
- Admin app starts and can point to backend base URL.
- `api/openapi.yaml` parses in validation.

## 6. Phase 1: Database Foundation And Migrations

Goal: create the schema foundation before writing business APIs.

Deliverables:

- Alembic configured.
- PostgreSQL extensions migration:
  - `pgcrypto`
  - `pg_trgm`
  - full-text search support
- Core identity/profile tables:
  - `users`
  - `profiles`
  - `business_profiles`
  - `job_worker_profiles`
  - `skilled_worker_profiles`
  - `profile_gst_details`
- Taxonomy tables:
  - `categories`
  - `category_aliases`
  - `category_suggestions`
  - `business_subtypes`
  - profile subtype/product mapping tables
- App settings table with free launch mode.
- Initial seed taxonomy for textile categories, work names, and product types.

Exit criteria:

- Fresh database can migrate from zero.
- Seed taxonomy can be loaded repeatedly without duplicates.
- Basic DB indexes exist for profile role/visibility/location.

## 7. Phase 2: Auth, Session, Role Selection

Goal: make onboarding real.

APIs:

- `POST /v1/auth/otp/request`
- `POST /v1/auth/otp/verify`
- `POST /v1/auth/account`
- `POST /v1/auth/role/confirm`
- `POST /v1/auth/logout`
- `GET /v1/me`

Backend deliverables:

- Supabase Auth integration behind FastAPI.
- Session/JWT validation middleware.
- Account creation after OTP succeeds.
- Role confirmation creates matching profile shell.
- Suspended-user guard.
- Idempotency handling for OTP/account/role.

Mobile deliverables:

- Splash.
- Create Account.
- OTP Verification.
- Select Role.
- Role Confirmation.
- Home route after role confirmation.

Exit criteria:

- New user can complete OTP, enter name, confirm role, and land on Home.
- Existing logged-in user opens directly to Home.
- Role is not directly changeable after completion.

## 8. Phase 3: Owner Profile Completion

Goal: users can create real public profiles.

APIs:

- `GET /v1/me/profile`
- `PATCH /v1/me/profile`
- `POST /v1/me/profile/complete`
- `POST /v1/me/profile/hide`
- `POST /v1/me/profile/show`
- `PATCH /v1/me/settings`

Backend deliverables:

- Role-specific profile DTOs.
- Completion score and missing flags.
- Draft/public/hidden profile visibility.
- Locked field rules.
- Profile change history.
- Search text generation for profile-level fields.

Mobile deliverables:

- My Profile dashboard.
- Business completion form.
- Job worker completion form.
- Skilled worker completion form.
- Profile preview.
- Hide from search setting.

Exit criteria:

- Business profile can become public after required fields and photos.
- Skilled worker profile can become public after required fields.
- Job worker profile cannot reach 100% until it has at least one published valid work card.

## 9. Phase 4: Media Upload

Goal: photos and private verification documents work through backend-controlled upload flow.

APIs:

- `POST /v1/media/upload-intent`
- `POST /v1/media/{media_asset_id}/complete`
- `POST /v1/media/{media_asset_id}/retry`
- `POST /v1/media/{media_asset_id}/cancel`
- `DELETE /v1/media/{media_asset_id}`

Backend deliverables:

- Supabase Storage integration.
- Public bucket and private verification bucket setup.
- Pending media record before upload.
- Upload complete verification.
- Minimum photo enforcement in backend.
- Delete blocking when deletion would violate minimum required photos.

Mobile deliverables:

- Upload button.
- Uploaded photo grid.
- Upload failed/retry/cancel states.
- Minimum 3 photos validation where required.
- Image compression before upload.

Exit criteria:

- User can upload profile/shop/workplace photos.
- User cannot publish/complete where minimum photo rules fail.
- Private verification files are not publicly readable.

## 10. Phase 5: Work Cards And Work-Needed Posts

Goal: create the marketplace inventory and demand objects.

APIs:

- `GET /v1/me/work-cards`
- `POST /v1/me/work-cards`
- `PATCH /v1/me/work-cards/{work_card_id}`
- `DELETE /v1/me/work-cards/{work_card_id}`
- `POST /v1/me/work-cards/{work_card_id}/publish`
- `POST /v1/me/work-cards/{work_card_id}/hide`
- `POST /v1/me/work-cards/{work_card_id}/show`
- `GET /v1/me/work-needed-posts`
- `POST /v1/me/work-needed-posts`
- `PATCH /v1/me/work-needed-posts/{post_id}`
- `DELETE /v1/me/work-needed-posts/{post_id}`
- `POST /v1/me/work-needed-posts/{post_id}/publish`
- `POST /v1/me/work-needed-posts/{post_id}/pause`
- `POST /v1/me/work-needed-posts/{post_id}/resume`
- `POST /v1/me/work-needed-posts/{post_id}/close`

Backend deliverables:

- Work-card drafts and publish action.
- Work-needed drafts and active publish action.
- Custom category/work/product text handling.
- Category suggestion creation.
- Search text/vector update on publish/edit.
- Photo count and ranking-field cache updates.

Mobile deliverables:

- Job worker Work List owner tab.
- Add Work Card form.
- Add Work Card custom `Other` flow.
- Manufacturer Work Needed owner tab.
- Add Work Needed Post form.
- Active/paused/closed states.

Exit criteria:

- Job worker can publish at least one searchable work card with 3 photos.
- Manufacturer can publish an active work-needed post with 3 photos.
- Published edits update search fields.

## 11. Phase 6: Search And Profile Detail

Goal: prove discovery and contact reveal.

APIs:

- `GET /v1/search`
- `GET /v1/profiles/{profile_id}`

Backend deliverables:

- Search for one persona target at a time:
  - business profiles
  - business work-needed posts
  - job-worker work cards
  - skilled worker profiles
- Business search mode:
  - `work_needed_posts`
  - `profiles`
- Exact/category/alias/keyword search.
- Conservative fuzzy fallback.
- Filters:
  - category/work type
  - product type
  - locality
  - experience
  - verified only
- Sort:
  - verified first
  - nearby/locality match
  - most photos
  - recently added
- Search logging.
- Profile detail returns contact/address in free MVP.
- Contact reveal row recorded once per viewer/profile.

Mobile deliverables:

- Home find cards route into Search.
- Global Search screen.
- Search tabs: Business, Job Worker, Karigar.
- Recommended results before query.
- Result cards without contact/address.
- Profile detail with contact/address.
- Full-screen gallery.

Exit criteria:

- Manufacturer can search `flat hemming`, open a job-worker result, and see contact/address on detail.
- Search result cards never show mobile number or full address.
- Contact reveal is not duplicated when the same user opens the same profile again.

## 12. Phase 7: Save, Share, Report, Contact Actions, Notifications

Goal: finish the visible supporting loops around profile detail.

APIs:

- `GET /v1/me/saved-items`
- `POST /v1/me/saved-items`
- `DELETE /v1/me/saved-items/{saved_item_id}`
- `POST /v1/reports`
- `GET /v1/me/notifications`
- `POST /v1/me/notifications/{notification_id}/read`
- `POST /v1/me/device-tokens`
- `POST /v1/contact-actions`
- `POST /v1/share-links`

Backend deliverables:

- Saved items for profile/work card/work-needed post.
- Report creation for profile/work card/work-needed post.
- Contact action logging.
- Share link generation.
- Notification table.
- Device token registration.
- FCM integration for verification/status notifications.

Mobile deliverables:

- Saved screen with Business / Job Worker / Karigar tabs.
- Save button state.
- Share sheet.
- Report reason sheet.
- Notifications list.
- Notification empty state.
- Call/WhatsApp action logging before external app open where possible.

Exit criteria:

- User can save, reopen, share, report, call, WhatsApp, and see notifications.
- Analytics/logging failure does not block call, WhatsApp, share, or save.

## 13. Phase 8: Verification And Admin MVP

Goal: make trust and moderation usable for private launch.

Owner APIs:

- `GET /v1/me/verification`
- `POST /v1/me/verification/submit`
- `POST /v1/me/verification/resubmit`

Admin APIs:

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

Backend deliverables:

- Verification cases and checks.
- Pending verification locks profile editing.
- Approved verification sets blue tick.
- Changes requested sends owner-visible message.
- Rejected profile stays public but unverified.
- Admin audit logs.
- Admin seeded profile creation.
- Report queue grouped by target/reason.
- Suspend/unsuspend.

Admin deliverables:

- Admin login/me.
- Verification queue.
- Verification detail.
- Approve/request changes/reject actions.
- Profile list.
- Seed profile creation.
- Reports queue.
- Basic suspension controls.

Mobile deliverables:

- Verify My Profile action.
- Pending state.
- Approved blue tick state.
- Changes requested notification and resubmit screen.

Exit criteria:

- Admin can verify a submitted profile and blue tick appears publicly.
- Admin can request changes and user can resubmit.
- Admin can create seed profiles for testing.
- Admin can suspend profile/user from discovery.

## 14. Phase 9: Admin Analytics, Export, Hardening

Goal: prepare private demo/testing with selected Surat users.

APIs:

- `GET /v1/admin/analytics/summary`
- `POST /v1/admin/exports`

Backend deliverables:

- Analytics summary:
  - total profiles
  - verified profiles
  - search terms
  - contact reveals
  - top categories
- CSV export jobs for:
  - profiles
  - verification cases
  - reports
  - search/contact analytics summary
- Security log review.
- Privacy review for raw search logs and verification documents.
- Basic provider safeguards for OTP/upload/search abuse.

Admin deliverables:

- Dashboard summary cards.
- Export button.
- Export status/download.

Exit criteria:

- Private demo admin can inspect growth, verification, reports, and contact activity.
- Sensitive export actions are audit logged.

## 15. Phase 10: Private MVP QA And Demo Readiness

Goal: ship a usable private Android MVP.

Testing scope:

- API contract tests against `api/openapi.yaml`.
- Migration test from empty database.
- Auth/onboarding happy path and failed OTP path.
- Profile completion for all three roles.
- Media upload failure/retry/cancel.
- Job worker work card publish.
- Manufacturer work-needed publish.
- Search result latency check with seed data.
- Profile detail contact reveal de-duplication.
- Verification approve/request changes/reject.
- Suspended user access restriction.
- Admin audit log creation.

Demo seed data:

- 20-50 business profiles.
- 50-100 job-worker work cards.
- 20-50 skilled worker profiles.
- Realistic Surat locality/category aliases.

Exit criteria:

- The three critical journeys work end to end:
  1. Manufacturer finds flat hemming job worker.
  2. Job worker adds work card.
  3. Manufacturer posts work needed.
- App can be tested by selected Surat users.
- Admin can recover from bad data without database access.

## 16. What Not To Build In MVP Phases

Do not build these until after private MVP feedback:

- Payments/subscriptions.
- iOS.
- Voice search.
- Map/GPS search.
- Ratings.
- Chat.
- Automated Aadhaar/GST provider verification.
- OpenSearch/Meilisearch.
- Redis queue/caching layer.
- Field-agent app.
- Complex admin RBAC.

## 17. Suggested First Coding Sprint

Sprint 1 should not try to include Flutter polish.

Recommended Sprint 1:

1. Create monorepo folders.
2. Create FastAPI skeleton.
3. Create Alembic setup.
4. Create first migrations for users/profiles/taxonomy.
5. Create auth/session/me endpoints.
6. Validate OpenAPI parsing.
7. Create a tiny Flutter app shell that can call `GET /v1/me`.

This gives a working foundation without pretending the marketplace is complete.

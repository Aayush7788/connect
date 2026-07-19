# AGENTS.md

This file is the root instruction guide for AI coding agents working on this repository.

It applies to the whole project unless a more specific nested `AGENTS.md` is added later.

## Project Overview

This project is an Android-first private MVP for a Surat-first textile marketplace named `Connect` in the wireframes.

The product connects:

- Manufacturers / businesses.
- Job workers / value adders / workshops.
- Skilled workers / karigars.

The MVP is a discovery, directory, verification, and lead-generation app. It is not an order-management, payment, chat, ratings, voice-search, map-search, or iOS project in the MVP.

The core loop to prove is:

1. A user creates an account with mobile OTP.
2. The user selects one locked profile role.
3. The user completes a role-specific profile.
4. A job worker publishes searchable work cards.
5. A manufacturer searches for work such as `flat hemming`.
6. The manufacturer opens profile detail and sees contact/address.
7. Admin can manually verify, seed, moderate, and inspect reports.

## Source Of Truth

Before making product, architecture, database, API, or UI decisions, read the relevant source documents in `outputs/`.

Primary implementation plan:

- `outputs/textile-marketplace-25-phase-build-plan.md`

Core source documents:

- `outputs/textile-marketplace-tech-stack-decision.md`
- `outputs/textile-marketplace-mvp-system-design.md`
- `outputs/textile-marketplace-mvp-api-contract.md`
- `outputs/textile-marketplace-api-authorization-matrix.md`
- `outputs/textile-marketplace-screen-api-traceability.md`
- `outputs/textile-marketplace-database-design.md`
- `outputs/textile-marketplace-figma-wireframe-spec.md`
- `outputs/textile-marketplace-requirements-discovery.md`

Discovery/history documents:

- `outputs/textile-marketplace-api-contract-discovery.md`
- `outputs/textile-marketplace-database-schema-discovery.md`
- `outputs/textile-marketplace-detailed-wireframe-discovery.md`
- `outputs/textile-marketplace-app-flow-discovery.md`
- `outputs/textile-marketplace-app-flow-spec.md`
- `outputs/textile-marketplace-autoplan-review.md`
- `outputs/eraser-mid-fidelity-wireframe-brief.md`
- `outputs/textile-marketplace-mid-fidelity-wireframe-spec.md`

Superseded:

- `outputs/textile-marketplace-build-phases-and-folder-structure.md` is superseded by the 25-phase plan.

If documents conflict, prefer the latest explicit decision in this order:

1. Current user instruction.
2. `outputs/textile-marketplace-25-phase-build-plan.md`.
3. `outputs/textile-marketplace-mvp-api-contract.md`.
4. `outputs/textile-marketplace-database-design.md`.
5. `outputs/textile-marketplace-figma-wireframe-spec.md`.
6. Earlier discovery files.

## Mandatory Phase Workflow

Do not start random implementation work.

For every phase:

1. Read `outputs/textile-marketplace-25-phase-build-plan.md`.
2. Read the phase-specific Markdown files listed inside that phase.
3. Read the current code folders touched by the phase.
4. Criticize the intended approach before coding.
5. Implement only the phase scope unless a blocker requires a small supporting change.
6. Run the phase's relevant validation/tests.
7. Verify exit criteria before moving to the next phase.
8. Record important decision changes in `outputs/`.

Do not skip the critique step. The user explicitly wants decisions challenged before selection.

## Git Branch And Merge Workflow

Every implementation phase must be developed on its own branch.

Branch rules:

- Start each phase from a clean, up-to-date `main`.
- Create one branch per phase.
- Recommended branch format: `phase-<number>-<short-name>`.
- Example: `phase-02-local-dev-tooling`.
- Do not implement multiple phases on the same branch unless the user explicitly approves it.

Commit rules:

- Run the relevant tests, lint, validation, or smoke checks before committing.
- Do not commit broken or unverified phase work.
- Make commits inside the phase branch after the relevant checks pass.
- Keep commits scoped to the active phase.
- Do not mix unrelated refactors, experiments, or future-phase work into the phase branch.

Merge rules:

- Merge a phase branch into `main` only after the phase exit criteria are verified.
- Merge with `--no-ff`; do not fast-forward phase branches into `main`.
- After merge, push `main`.
- Keep the phase branch until the user confirms it can be deleted.

Standard manual flow:

```powershell
git switch main
git pull --ff-only
git switch -c phase-02-local-dev-tooling

git status --short
git add .
git commit -m "phase 02: local development tooling"

git switch main
git pull --ff-only
git merge --no-ff phase-02-local-dev-tooling -m "merge phase 02 local development tooling"
git push origin main
```

If tests cannot be run because the project is still being scaffolded, state that clearly before committing and in the final response.

## Architecture Rules

The selected MVP stack is:

- Mobile: Flutter + Dart.
- Backend: FastAPI + Python.
- Database: Supabase-managed PostgreSQL in Mumbai.
- Storage: Supabase Storage.
- Admin: Next.js + TypeScript.
- Notifications: Firebase Cloud Messaging.

The system boundary is strict:

```text
Flutter Android app -> FastAPI backend API/BFF -> Supabase Auth/Postgres/Storage
Next.js admin app   -> FastAPI backend API/BFF -> Supabase Auth/Postgres/Storage
```

Rules:

- Flutter must not write marketplace database tables directly.
- Next.js admin must not write marketplace database tables directly.
- Supabase is infrastructure, not the public product backend.
- FastAPI owns validation, permissions, workflow state, and business rules.
- PostgreSQL is the source of truth.
- Search starts in PostgreSQL using category, keyword, aliases, full-text search, trigram fallback, locality filters, and cached ranking fields.
- Do not introduce microservices for the MVP.
- Do not introduce OpenSearch, Meilisearch, Redis, queues, payments, provider KYC, chat, ratings, maps, voice search, or iOS unless the user explicitly reopens scope.

## Folder Structure

The selected repo shape is one monorepo with clear boundaries:

```text
api/
backend/
database/
frontend/
  mobile/
  admin/
infra/
scripts/
outputs/
```

Use the detailed structure from `outputs/textile-marketplace-25-phase-build-plan.md`.

Expected responsibilities:

- `api/`: OpenAPI contract and generated clients.
- `backend/`: FastAPI app, modules, integrations, tests.
- `database/`: Alembic migrations, seeds, SQL policies/indexes/views.
- `frontend/mobile/`: Flutter Android app.
- `frontend/admin/`: Next.js admin dashboard.
- `infra/`: Supabase, Render/Railway, Vercel deployment notes/config.
- `scripts/`: local validation, generation, seeding, smoke checks.
- `outputs/`: planning, discovery, architecture, design, and decision records.

If a subproject becomes complex, add a nested `AGENTS.md` inside that subfolder. The closest `AGENTS.md` should take precedence for that subtree.

## Backend Rules

Use FastAPI as a modular monolith.

Backend module shape when a module has real logic:

```text
backend/app/modules/<module_name>/
  router.py
  schemas.py
  service.py
  repository.py
  permissions.py
```

Keep tiny modules simple; do not split files purely to look enterprise.

Backend must enforce:

- OTP-authenticated access for marketplace APIs.
- Role-specific ownership and permissions.
- Suspended-user restrictions.
- Profile completion rules.
- Job-worker profile completion requiring at least one published valid work card.
- Public result cards never returning contact number or full address.
- Profile detail returning contact/address during free MVP and recording contact reveal once per viewer/profile.
- Manual verification status transitions.
- Admin audit logs for sensitive admin mutations.
- Simple user-facing errors with detailed debug information only in logs/admin tools.

Use the API contract in `api/openapi.yaml` and `outputs/textile-marketplace-mvp-api-contract.md`.

## Database Rules

Use PostgreSQL with migrations.

Database rules:

- Use UUID primary keys with `gen_random_uuid()` for main tables.
- Use plural snake_case table names.
- Use text status fields with CHECK constraints, not PostgreSQL enum types, unless the user explicitly changes this decision.
- Keep one common `profiles` table plus role-specific extension tables.
- Keep work cards and work-needed posts as first-class searchable objects.
- Keep public media and private verification documents separated.
- Do not store raw Aadhaar, PAN, or identity proof numbers.
- Keep verification documents private and admin-only.
- Keep analytics/search/contact-reveal logs from day one.
- Keep future monetization tables inert in MVP.

Do not hard-delete core marketplace data unless a phase explicitly requires it. Use soft delete where the database design specifies lifecycle history.

## Mobile App Rules

Use Flutter + Dart for Android MVP.

Mobile app rules:

- No search before account creation.
- Flow is Splash -> Create Account / OTP -> Select Role -> Role Confirmation -> Home.
- Role selection happens after OTP verification.
- Role is locked after profile completion.
- Every user sees the same Home with three discovery cards.
- Bottom navigation is role-specific: business uses Home, Add Post, Saved, My Profile; job worker uses Home, Add Work, Saved, My Profile; karigar uses Home, Saved, My Profile.
- Search is entered only through a Home discovery card; its persona target is fixed and the focused Search screen has no bottom navigation.
- Add Post and Add Work open dedicated owner list screens; My Profile is profile-only.
- Result cards are photo-first.
- Result cards never show contact number or full address.
- Profile detail can show contact/address in MVP.
- Public users see only blue tick, not verification breakdown.
- UI must support low to mixed digital literacy: large touch targets, simple words, obvious actions, minimal explanation.
- Use image compression before upload.
- Show loading, empty, validation, permission, and upload-failed states.

Follow `outputs/textile-marketplace-figma-wireframe-spec.md` and `outputs/textile-marketplace-screen-api-traceability.md` for screen behavior.

## Admin Rules

Admin is a web dashboard using Next.js + TypeScript and the same backend API.

MVP admin model:

- All active admins are treated as super-admin in MVP.
- Keep role support in database for future.
- Admin dashboard never writes directly to database tables.
- Admin cannot directly edit user-owned public profile/work/post fields except via allowed moderation/status/request-change workflows.
- Admin can directly edit admin-seeded profiles until they are claimed.
- Every sensitive admin mutation must write an audit log.

Admin MVP must support:

- Verification queue and decisions.
- Profile list.
- Seed profile creation.
- Reports queue.
- Suspend/unsuspend.
- Basic analytics summary.
- CSV export trigger.

## Security And Privacy Rules

Never commit secrets.

Do not expose:

- Supabase service role key.
- Database credentials.
- Private verification document URLs.
- Raw proof document data.
- Raw Aadhaar/PAN/identity numbers.

Sensitive rules:

- Verification proof documents live in private storage.
- Owners can see safe document status/name only; they cannot re-download private proof documents after upload.
- Admin proof access must be short-lived and audited.
- Public users see blue tick only, not verification checklist.
- Search logs may contain sensitive free text. Keep raw query access admin/system-only.
- Contact/address appears only on profile detail during free MVP, not on result cards or saved cards.

## Product Scope Guardrails

Do not build these in MVP:

- Payments/subscriptions.
- iOS.
- Voice search.
- Map/GPS search.
- Ratings/reviews.
- Chat.
- Customer support chat/call.
- Automated Aadhaar/GST provider verification.
- OpenSearch/Meilisearch.
- Redis queue/caching layer.
- Field-agent app.
- Complex admin RBAC.
- Order management.

If the user asks for one of these, first explain that it is outside the current MVP phase and ask whether they want to reopen scope.

## Build And Test Commands

The project is still being scaffolded. Until Phase 1-5 create concrete commands, do not invent working commands.

Expected command locations after scaffolding:

- OpenAPI validation: `python scripts/validate_openapi.py`
- Backend tests: run from `backend/`
- Database migrations: run from `database/`
- Flutter tests/analyze: run from `frontend/mobile/textile_marketplace_app/`
- Admin lint/build/tests: run from `frontend/admin/`

When commands exist, run the relevant checks before finishing a coding task. If a command cannot run because scaffolding is not complete, say that clearly in the final response.

## Coding Style

General:

- Keep edits scoped to the active phase.
- Prefer clear, boring, maintainable code.
- Do not introduce abstractions until they remove real duplication or match an existing pattern.
- Do not do unrelated refactors.
- Preserve user-created changes.
- Use ASCII in code/docs unless a file already uses non-ASCII or the content requires it.
- Do not write the comment's in code.
- use the gstack skills wherever necessary.

Python/FastAPI:

- Use typed Pydantic request/response schemas.
- Keep DB queries in repositories or clearly separated query helpers.
- Keep business rules in services.
- Keep permission checks explicit.
- Return the shared API error envelope.

Flutter:

- Keep features under `lib/features/<feature>/`.
- Keep generated clients in `lib/generated/` or the generated location chosen in Phase 3.
- Use Riverpod/go_router/Dio as selected in the stack decision.
- Keep UI consistent with the wireframe spec.

Next.js admin:

- Use generated API client types where available.
- Keep admin screens feature-scoped.
- Do not put service-role secrets in browser code.

Database:

- Use migrations for schema changes.
- Add indexes intentionally, especially for search and analytics.
- Keep seed data idempotent.

## Documentation Rules

When implementation changes a locked decision:

- Update the relevant `outputs/` document or create a new decision note.
- Do not silently change architecture, API, schema, or UX behavior.
- If changing OpenAPI, update `api/openapi.yaml` and regenerate clients if generation exists.
- If changing database schema, update migrations and the database design docs when needed.

## Review Checklist Before Final Response

Before finishing a task, check:

- Did you follow the current phase?
- Did you create/use a phase-specific branch?
- Did you read the phase-specific docs?
- Did you keep Flutter/admin behind the FastAPI backend?
- Did you avoid MVP out-of-scope features?
- Did you avoid direct database writes from frontend/admin?
- Did you preserve privacy rules for contact, address, and verification documents?
- Did you run relevant tests or explain why they could not run?
- Did you commit only after checks passed or after explicitly documenting why checks could not run?
- Did you merge completed phase branches with `--no-ff`?
- Did you mention changed files clearly?

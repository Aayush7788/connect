# Textile Marketplace Screen-To-API Traceability

Date: 2026-07-10

Status: Draft v1 aligned with the Figma wireframe spec and API contract.

## 1. Purpose

This file maps mobile/admin-visible screens and flows to backend APIs. Use it while implementing Flutter screens so every screen has a clear data source and mutation path.

## 2. Entry And Onboarding

| Screen | Primary APIs | Notes |
|---|---|---|
| Splash | `GET /v1/me` when token exists | If no token, go to Create Account. If session valid and role confirmed, go Home. |
| Create Account | `POST /v1/auth/otp/request` | Collect name/mobile in UI, but persist account only after OTP succeeds. |
| OTP Verification | `POST /v1/auth/otp/verify`, `POST /v1/auth/account` | Verify OTP, then create/complete basic account and store consent versions. |
| Role Selection | `POST /v1/auth/role/confirm` | Role creates matching profile shell. |
| Role Confirmation | `POST /v1/auth/role/confirm` idempotently | User cannot go back after final confirm. |

## 3. Home And Search

| Screen | Primary APIs | Notes |
|---|---|---|
| Home | `GET /v1/me`, `GET /v1/search` optional recommendations | Shows greeting, notification count, completion banner, three find cards. |
| Search from Home card | `GET /v1/search?target=...` | Preselect target based on Home card. Empty query shows recommendations. |
| Global Search | `GET /v1/search` | User selects Business, Job Worker, or Karigar tab. |
| Search Loading | Same pending request | Show skeleton cards. |
| Search Empty | `GET /v1/search` result count 0 | Show invite/share action; clear filters if filters active. |
| Search Error | Failed `GET /v1/search` | Retry; show connection issue if repeated. |

## 4. Search Result Cards

| Result Type | API Source | Card Data | Hidden Data |
|---|---|---|---|
| Business profile | `GET /v1/search?target=business&business_mode=profiles` | photos, business name, category, manufacture/sell summary, blue tick | contact, full address |
| Work-needed post | `GET /v1/search?target=business&business_mode=work_needed_posts` | photos, work type, category, product type, business name, blue tick | contact, full address |
| Job-worker work card | `GET /v1/search?target=job_worker` | work photos, work name, category, product type, job worker name, blue tick | contact, full address |
| Karigar profile | `GET /v1/search?target=skilled_worker` | worker photo, skill, experience, name, blue tick | contact, full address |

## 5. Profile Detail

| Screen | Primary APIs | Notes |
|---|---|---|
| Job Worker Detail - Work List | `GET /v1/profiles/{profile_id}` | Default tab shows all public work cards. Also records contact reveal once per viewer/profile because profile detail returns contact/address in free MVP. |
| Job Worker Detail - Profile | `GET /v1/profiles/{profile_id}` | Shows workplace photos, work types, locality, contact, address. |
| Manufacturer Detail - Work Needed | `GET /v1/profiles/{profile_id}` | Default tab shows active work-needed posts. |
| Manufacturer Detail - Profile | `GET /v1/profiles/{profile_id}` | Shows shop photos, manufacture/sell info, contact, address. |
| Karigar Detail | `GET /v1/profiles/{profile_id}` | Simple detail screen with contact/address. |
| Similar Profiles | Included in profile detail or later `GET /v1/search` | Do not include contact/address in similar cards. |
| Full-screen Gallery | URLs from profile detail/media DTO | Private proof media never appears here. |

## 6. Profile Detail Actions

| UI Action | API | External Action |
|---|---|---|
| Call | `POST /v1/contact-actions` with `action_type=call` | Open dialer after log attempt |
| WhatsApp | `POST /v1/contact-actions` with `action_type=whatsapp` | Open WhatsApp after log attempt |
| Address | `POST /v1/contact-actions` with `action_type=address` | Open address/map intent if implemented |
| Save | `POST /v1/me/saved-items` | Button changes to Saved |
| Remove saved | `DELETE /v1/me/saved-items/{id}` | Remove from Saved screen |
| Share | `POST /v1/share-links` | Native share sheet with returned link |
| Report | `POST /v1/reports` | Toast `Report submitted` |

Analytics/share/contact failures must not block the visible user action, except report creation itself should show success/failure because report is the user action.

## 7. My Profile And Completion

| Screen | Primary APIs | Notes |
|---|---|---|
| My Profile Dashboard | `GET /v1/me`, `GET /v1/me/profile` | Shows name, role, mobile, completion percent, verification status, edit controls. |
| Business Completion | `GET /v1/taxonomy/categories`, `PATCH /v1/me/profile`, media APIs, `POST /v1/me/profile/complete` | Loads business/product options through FastAPI; requires shop photos minimum 3. |
| Job Worker Completion | `PATCH /v1/me/profile`, work-card APIs, media APIs, `POST /v1/me/profile/complete` | Requires at least one published valid work card for 100%. |
| Skilled Worker Completion | `GET /v1/taxonomy/categories`, `PATCH /v1/me/profile`, media APIs, `POST /v1/me/profile/complete` | Loads skill options through FastAPI; worker photo recommended; required fields enforced by backend. |
| Edit Profile | `GET /v1/me/profile`, `PATCH /v1/me/profile` | Locked fields cannot change; pending verification locks verification-sensitive edits. |
| Hide From Search | `PATCH /v1/me/settings` or profile hide/show endpoint | Settings toggle controls visibility. |

## 8. Add Work Card

| Screen | Primary APIs | Notes |
|---|---|---|
| Work List Owner Tab | `GET /v1/me/work-cards` | Shows owner work cards and add button. |
| Add Work Card Form | `POST /v1/me/work-cards`, media upload APIs | Can save draft. Custom `Other` text creates category suggestions. |
| Publish Work Card | `POST /v1/me/work-cards/{id}/publish` | Requires category/work/product/description and minimum 3 ready photos. |
| Edit Work Card | `PATCH /v1/me/work-cards/{id}` | Published edits go live immediately and update search. |
| Delete Work Card | `DELETE /v1/me/work-cards/{id}` | Soft delete. |

## 9. Add Work-Needed Post

| Screen | Primary APIs | Notes |
|---|---|---|
| Work Needed Owner Tab | `GET /v1/me/work-needed-posts` | Shows owner posts and add button. |
| Add Work Needed Form | `POST /v1/me/work-needed-posts`, media upload APIs | Supports draft. |
| Publish Work Needed | `POST /v1/me/work-needed-posts/{id}/publish` | Sets status to `active`. |
| Pause/Resume/Close | pause/resume/close endpoints | No close reason required in MVP. |
| Delete Work Needed | `DELETE /v1/me/work-needed-posts/{id}` | Soft delete. |

## 10. Media Upload

| Screen/State | Primary APIs | Notes |
|---|---|---|
| Upload button | `POST /v1/media/upload-intent` | Backend validates ownership and target entity. |
| Upload progress | Storage upload from signed intent or backend-proxied upload | Direct storage only if safely scoped. |
| Complete upload | `POST /v1/media/{id}/complete` | Backend verifies object before ready. |
| Upload failed | `POST /v1/media/{id}/retry` or cancel | UI text: `Unable to upload, please retry`. |
| Cancel upload | `POST /v1/media/{id}/cancel` | Required before replacement. |
| Delete photo | `DELETE /v1/media/{id}` | Block if deletion drops entity below minimum photos. |

## 11. Verification

| Screen | Primary APIs | Notes |
|---|---|---|
| Verify My Profile Button | `GET /v1/me/verification` | Enabled only after completion requirements. |
| Submit Verification | media APIs, `POST /v1/me/verification/submit` | Optional ID/GST proof; private media. |
| Pending Review | `GET /v1/me/verification` | Editing locked. |
| Approved | `GET /v1/me`, `GET /v1/me/verification` | Blue tick public. |
| Rejected | `GET /v1/me/verification` | Profile remains public but unverified. |
| Changes Requested | `GET /v1/me/verification`, `POST /v1/me/verification/resubmit` | Show admin message; targeted resubmit. |
| Notifications | `GET /v1/me/notifications` | Verification messages appear in list and push if enabled. |

## 12. Saved, Share, Report, Notifications, Settings

| Screen | Primary APIs | Notes |
|---|---|---|
| Saved | `GET /v1/me/saved-items` | Tabs: Business, Job Worker, Karigar. Cards do not show contact/address. |
| Saved Empty | `GET /v1/me/saved-items` empty | Text: `No saved profiles`. |
| Share Sheet | `POST /v1/share-links` | Then native share sheet. |
| Report Sheet | `POST /v1/reports` | Target can be profile, work card, or work-needed post. |
| Notifications | `GET /v1/me/notifications` | Simple list with title, message, date/time. |
| Mark Notification Read | `POST /v1/me/notifications/{id}/read` | `read_at` set server-side. |
| Settings | `GET /v1/me/settings`, `PATCH /v1/me/settings` | Load and change push on/off; hide from search; logout. |
| Contact Support | Static support config or future API | Suspended users can access support. |

## 13. Admin Dashboard Traceability

| Admin View | Primary APIs | Notes |
|---|---|---|
| Admin Login/Me | admin auth/session API, `GET /v1/admin/me` | MVP all admins are super-admin. |
| Verification Queue | `GET /v1/admin/verification-cases` | Filters by status/role/date. |
| Verification Detail | `GET /v1/admin/verification-cases/{id}` | Includes private proof access through audited short-lived URL. |
| Verification Actions | approve/request-changes/reject endpoints | Audit logged; sends notification. |
| Profiles | `GET /v1/admin/profiles` | Filter by role/status/verified/seeded. |
| Seed Profile Create/Edit | `POST /v1/admin/seed-profiles`, patch seed endpoint | Public/searchable if complete. |
| Suspend/Unsuspend | profile/user suspension endpoints | Blocks account and removes content from discovery. |
| Reports Queue | `GET /v1/admin/reports` | Group repeated reports by target/reason/reporter/status. |
| Categories/Aliases | category admin endpoints | Manage taxonomy and suggestions. |
| Analytics | `GET /v1/admin/analytics/summary` | Search/contact/profile view summary. |
| Exports | `POST /v1/admin/exports`, `GET /v1/admin/exports/{id}` | Profiles, verification, reports, search/contact summary. |

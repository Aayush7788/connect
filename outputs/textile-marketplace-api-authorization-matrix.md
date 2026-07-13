# Textile Marketplace API Authorization Matrix

Date: 2026-07-10

Status: Draft v1 aligned with `textile-marketplace-mvp-api-contract.md`.

## 1. Actor Types

| Actor | Meaning |
|---|---|
| Anonymous | No valid app session |
| Authenticated user | Active OTP-authenticated mobile app user |
| Profile owner | Authenticated user who owns the target profile/content |
| Business owner | Profile owner with role `business` |
| Job worker owner | Profile owner with role `job_worker` |
| Skilled worker owner | Profile owner with role `skilled_worker` |
| Suspended user | Authenticated user with `account_status = suspended` |
| Admin | Active admin account; MVP treats all admins as super-admin |

## 2. Global Authorization Rules

| Rule | Decision |
|---|---|
| Mobile app database access | Never writes directly to marketplace tables |
| Admin dashboard database access | Never writes directly to marketplace tables |
| Normal API access | Requires active authenticated user unless explicitly public/openable |
| Suspended user | Can access only Logout and Contact Support |
| Admin in MVP | All active admins have full admin access |
| Admin audit | Sensitive admin mutations must write audit logs |
| Verification documents | Admin-only file access; owner sees safe status/name only |
| Contact/address | Returned on profile detail during free MVP after OTP login and contact reveal logging |

## 3. Endpoint Matrix

| API Area | Endpoint/Action | Anonymous | Authenticated User | Owner | Role Rule | Admin | Suspended User |
|---|---|---:|---:|---:|---|---:|---:|
| Auth | `POST /v1/auth/otp/request` | Yes | Yes | N/A | Any mobile | N/A | Yes |
| Auth | `POST /v1/auth/otp/verify` | Yes | Yes | N/A | Any mobile | N/A | Yes |
| Auth | `POST /v1/auth/account` | No | Yes | Self | No role required | N/A | No |
| Auth | `POST /v1/auth/role/confirm` | No | Yes | Self | Before completed role lock | N/A | No |
| Auth | `POST /v1/auth/logout` | No | Yes | Self | Any role | N/A | Yes |
| Me | `GET /v1/me` | No | Yes | Self | Any role | N/A | Limited blocked state |
| Profile | `GET /v1/me/profile` | No | Yes | Self | Any role | N/A | No |
| Profile | `PATCH /v1/me/profile` | No | No | Yes | Role-specific fields | N/A | No |
| Profile | `POST /v1/me/profile/complete` | No | No | Yes | Role-specific completion | N/A | No |
| Profile | `POST /v1/me/profile/hide` | No | No | Yes | Any role | N/A | No |
| Profile | `POST /v1/me/profile/show` | No | No | Yes | Any role | N/A | No |
| Search | `GET /v1/search` | No | Yes | N/A | Any target persona | Admin can also call | No |
| Public profile | `GET /v1/profiles/{id}` | No | Yes | N/A | Openable public/saved/direct target | Admin can inspect separately | No |
| Work cards | `GET /v1/me/work-cards` | No | No | Yes | Job worker only | N/A | No |
| Work cards | `POST /v1/me/work-cards` | No | No | Yes | Job worker only | N/A | No |
| Work cards | `PATCH /v1/me/work-cards/{id}` | No | No | Yes | Job worker only; owner only | N/A | No |
| Work cards | publish/hide/show/delete | No | No | Yes | Job worker only; owner only | Admin remove via admin API | No |
| Work-needed | `GET /v1/me/work-needed-posts` | No | No | Yes | Business only | N/A | No |
| Work-needed | `POST /v1/me/work-needed-posts` | No | No | Yes | Business only | N/A | No |
| Work-needed | `PATCH /v1/me/work-needed-posts/{id}` | No | No | Yes | Business only; owner only | N/A | No |
| Work-needed | publish/pause/resume/close/delete | No | No | Yes | Business only; owner only | Admin remove via admin API | No |
| Media | `POST /v1/media/upload-intent` | No | No | Yes | Owner of target entity | Admin for seed/review flows | No |
| Media | complete/retry/cancel/delete | No | No | Yes | Owner of media target | Admin moderation separate | No |
| Verification | `GET /v1/me/verification` | No | Yes | Self | Any completed profile | Admin separate | No |
| Verification | submit/resubmit | No | No | Yes | Profile complete; not pending | Admin separate | No |
| Saved | `GET /v1/me/saved-items` | No | Yes | Self | Any role | N/A | No |
| Saved | save/remove | No | Yes | Self | Any role | N/A | No |
| Reports | `POST /v1/reports` | No | Yes | Reporter | Any role | Admin reads separately | No |
| Notifications | `GET /v1/me/notifications` | No | Yes | Self | Any role | N/A | No |
| Notifications | mark read | No | Yes | Self | Own notification | N/A | No |
| Device token | `POST /v1/me/device-tokens` | No | Yes | Self | Android MVP | N/A | No |
| Settings | `PATCH /v1/me/settings` | No | Yes | Self | Any role | N/A | No |
| Settings | `GET /v1/me/settings` | No | Yes | Self | Any role | N/A | No |
| Contact action | `POST /v1/contact-actions` | No | Yes | Actor | Contact-visible target | Admin analytics read | No |
| Share link | `POST /v1/share-links` | No | Yes | Actor | Shareable target | Admin analytics read | No |
| Admin verification | `/v1/admin/verification-cases*` | No | No | N/A | N/A | Yes | N/A |
| Admin profiles | `/v1/admin/profiles*` | No | No | N/A | N/A | Yes | N/A |
| Admin seed profiles | create/edit | No | No | N/A | N/A | Yes | N/A |
| Admin reports | `/v1/admin/reports*` | No | No | N/A | N/A | Yes | N/A |
| Admin categories | `/v1/admin/categories*` | No | No | N/A | N/A | Yes | N/A |
| Admin analytics | `/v1/admin/analytics/*` | No | No | N/A | N/A | Yes | N/A |
| Admin exports | `/v1/admin/exports*` | No | No | N/A | N/A | Yes | N/A |
| Admin suspension | suspend/unsuspend | No | No | N/A | N/A | Yes | N/A |

## 4. Field-Level Visibility

| Field/Data | Search Card | Profile Detail | Owner Profile | Admin |
|---|---:|---:|---:|---:|
| Name/business name | Yes | Yes | Yes | Yes |
| Public photos | Yes | Yes | Yes | Yes |
| Work/work-needed data | Yes | Yes | Yes | Yes |
| Mobile/contact | No | Yes in free MVP | Yes | Yes |
| Full address | No | Yes in free MVP | Yes | Yes |
| Blue tick | Yes | Yes | Yes | Yes |
| Verification checklist | No | No | No | Yes |
| Verification document status/name | No | No | Safe summary | Yes |
| Verification proof file URL | No | No | No | Admin short-lived audited URL |
| Admin notes | No | No | Only `notes_to_user` where applicable | Yes |
| Search/contact analytics | No | No | No in MVP | Yes |
| Audit logs | No | No | No | Yes |

## 5. Sensitive Transitions

| Transition | Required Actor | Notes |
|---|---|---|
| Confirm role | Authenticated user | Idempotent; creates profile shell |
| Complete profile | Owner | Role-specific validation |
| Complete job-worker profile | Job worker owner | Requires at least one published valid work card |
| Publish work card | Job worker owner | Requires minimum 3 ready photos |
| Publish work-needed post | Business owner | Requires minimum 3 ready photos |
| Submit verification | Owner | Requires complete profile and no active pending case |
| Approve verification | Admin | Sets blue tick |
| Request verification changes | Admin | Sends owner-visible message |
| Reject verification | Admin | Profile stays public but unverified |
| Suspend account/profile | Admin | Blocks account and removes from discovery |
| Export data | Admin | Audit logged |

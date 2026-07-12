# Phase 10 Cross-Cutting Schema Implementation Note

Date: 2026-07-12

## Scope Implemented

Phase 10 adds the schema foundations needed before the API modules for media uploads, manual verification, saved items, reports, notifications, analytics, contact reveal logging, and future paid contact access.

New tables:

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
- `user_contact_quotas`
- `subscription_plans`
- `user_subscriptions`
- `payment_transactions`
- `admin_access_grants`

Already-existing tables reused from the identity foundation:

- `user_devices`
- `user_settings`
- `app_settings`

## Decisions

- `media_assets` remains polymorphic with `entity_type` and `entity_id` for MVP flexibility. Backend services must validate target existence and ownership before issuing upload intents or completing uploads.
- Private proof media is protected with database checks: `document` media must be `private_admin_only`, and `identity_proof`, `masked_aadhaar`, and `gst_proof` document types cannot be public.
- `profile_gst_details.proof_media_asset_id` now has a real foreign key to `media_assets.id`.
- Verification uses one active case per profile through a partial unique index on `verification_cases(profile_id)` for `draft`, `pending_review`, and `changes_requested`.
- Reports intentionally have no uniqueness constraint. Repeated reports from the same user are stored for admin grouping and abuse signal analysis.
- `contact_reveals` has a unique `(viewer_user_id, revealed_profile_id)` index. Reopening the same profile should update the existing row and increment `reveal_count`, not consume another future quota.
- Payment/subscription tables are present but inert. `subscription_plans.is_active` defaults to `false`; no product-visible paid behavior is enabled in MVP.
- Every new public-schema table has RLS enabled and direct access revoked from `anon` and `authenticated`. FastAPI remains the product API boundary.

## Backend Rules Left For Later Phases

- Enforce media target ownership and minimum photo counts in API services.
- Keep private proof files inaccessible to owners after upload; owners can see only safe status/name metadata.
- Admin proof access must use short-lived URLs and write admin audit logs.
- On profile detail, upsert `contact_reveals` once per viewer/profile and update `last_revealed_at` / `reveal_count`.
- Analytics logging failures must not block visible user actions such as call, WhatsApp, save, or share.

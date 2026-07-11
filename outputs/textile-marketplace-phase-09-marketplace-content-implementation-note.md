# Phase 9 Marketplace Content Schema Implementation Note

Phase 9 implements first-class searchable marketplace content:

- `work_cards`
- `work_card_product_types`
- `work_needed_posts`
- `work_needed_post_product_types`

Design choices:

- `work_cards.profile_id` references `job_worker_profiles.profile_id`, not only
  `profiles.id`, so the database prevents non-job-worker profiles from owning
  work cards.
- `work_needed_posts.profile_id` references `business_profiles.profile_id`, so
  only business profiles can own demand posts.
- Work cards default to `draft`.
- Work-needed posts also default to `draft`, following the API contract and phase
  plan where `publish` is an action and `active` is the searchable state. This
  intentionally corrects the older database-design table text that listed
  `active` as the default.
- Published/searchable content requires nonblank title, category or custom
  category, work name or custom work name, and cached `photo_count >= 3`.
- Product-type rows support either mapped taxonomy IDs or nonblank custom text,
  with partial unique indexes for mapped and normalized custom values.

Security posture:

- RLS is enabled on every Phase 9 table.
- Direct `anon` and `authenticated` table privileges are revoked.
- Mobile and admin clients must keep using backend/API routes for important reads
  and writes.

Important dependency:

- Actual photo rows are not created in Phase 9. `photo_count` is a cached field
  that will be maintained by backend/media workflows after Phase 10 introduces
  `media_assets`.
- The database cannot enforce "at least one product type row before publish"
  without triggers or deferred cross-row checks. The backend publish service must
  enforce that rule.

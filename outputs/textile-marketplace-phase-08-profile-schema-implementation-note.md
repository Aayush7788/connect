# Phase 8 Profile Schema Implementation Note

Phase 8 implements the core profile schema from the database design:

- `profiles`
- `business_profiles`
- `business_profile_product_types`
- `profile_business_subtypes`
- `job_worker_profiles`
- `skilled_worker_profiles`
- `profile_gst_details`
- `profile_change_history`

The common `profiles` table owns role, visibility, verification, completion,
location, ranking, and search fields. Role-specific details stay in extension
tables so each role can evolve without overloading one wide table.

Security posture:

- RLS is enabled on every Phase 8 table.
- Direct `anon` and `authenticated` table privileges are revoked.
- Mobile and admin clients must continue to use backend/API routes for important
  reads and writes.

Important dependency:

- `profile_gst_details.proof_media_asset_id` is intentionally a UUID without a
  foreign key in this phase because `media_assets` is created later in Phase 10.
  Phase 10 should add the FK or a follow-up migration once the media table
  exists.

Taxonomy integration:

- `category_suggestions.profile_id` now has a foreign key to `profiles.id`.
  Phase 7 left it as a placeholder because the profile table did not exist yet.

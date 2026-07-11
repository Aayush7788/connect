# Textile Marketplace Database Schema Discovery

Date: 2026-07-07
Status: Database discovery started
Purpose: Capture database schema decisions before producing the final database design.

## Source Files Read

- `outputs/textile-marketplace-mvp-system-design.md`
- `outputs/textile-marketplace-detailed-wireframe-discovery.md`
- `outputs/textile-marketplace-app-flow-spec.md`
- `outputs/textile-marketplace-requirements-discovery.md`

## Working Rules

- The assistant asks database-schema questions in rounds.
- Each round must be based on the source files and previously saved answers.
- Do not repeat already-settled app-flow, wireframe, or MVP-scope questions.
- The user can answer by option letters/numbers or custom text.
- After each user answer, append the resolved database decisions to this file.
- Final database design must use this discovery file plus the source files above.

## Already Confirmed Product Facts Relevant To Schema

### Product Scope

- Android-first MVP.
- Private selected Surat demo/testing first.
- MVP supports all three personas:
  - Manufacturer / Business.
  - Job Worker / Value Adder.
  - Skilled Worker / Karigar.
- One mobile number should have only one account.
- One user account has exactly one profile.
- Role is selected after OTP verification.
- Role is locked after profile completion.
- If user wants another role later, they should terminate the account and create a new account with another mobile number.
- Search is the core marketplace behavior.
- No order management in MVP.
- No payments/subscription enforcement in MVP.
- Contact/address are fully visible in MVP/private launch.
- Contact reveal locking and subscriptions should be prepared for later.
- Ratings/reviews are later, not MVP.
- Admin dashboard is required for manual verification, categories, analytics, and user/profile management.

### Profile And Role Data

- Manufacturer/business profile needs fields such as business name, owner name, manufacture/sell details, category, product type, shop photos, address, and optional GST proof later.
- Job Worker profile needs workshop name, owner name, workplace photos, type of work, category, product type, address, and work cards.
- Skilled Worker / Karigar profile needs name, skill, experience, photo, contact, and address.
- Profile completeness percentage affects ranking.
- Complete and verified profiles rank above incomplete/unverified profiles.
- Users can hide their profile from search from Settings.
- Verification pending locks editing and shows disabled edit buttons.

### Work And Demand Data

- Job Worker / Value Adder can add multiple work cards.
- Each work card has one category.
- Work card fields:
  - Category.
  - Work name.
  - Product type.
  - Photos.
  - Description.
- Work card minimum photos in latest wireframe decision: 3.
- Work card publishes immediately.
- Job Worker can edit/delete work cards.
- Manufacturer can add multiple work-needed posts.
- Work-needed post fields:
  - Category.
  - Name/type of work needed.
  - Product type.
  - Photos.
  - Description.
- Work-needed post minimum photos: 3.
- Work-needed post publishes as active.
- Manufacturer can edit, delete, pause, or close work-needed posts.
- No automatic expiry in MVP.

### Search And Taxonomy

- Search target types:
  - Businesses.
  - Job Workers.
  - Karigars.
- Search result should return matching work entries for Job Worker searches, not just whole profiles.
- Search dimensions include category/work type, product type, locality, experience, verified only, photos, and machine-type work later.
- Search needs category + keyword + aliases/local terms in MVP.
- Categories and aliases must be admin-editable.
- Unknown category/work names should support `Other` plus custom text.
- Search logs should be stored from day one.

### Media

- Users upload photos in app.
- Profile/shop/workplace photos are public in app.
- Verification documents are private/admin-only.
- Photos are compressed on mobile.
- Profile/shop photos target: 3 to 5.
- Work photos target: 4 to 10 from earlier requirements, but latest wireframe requires minimum 3 for work cards and work-needed posts.
- Videos are not in MVP.

### Verification

- MVP uses manual document/photo upload and admin review.
- Blue tick means admin-approved verified profile.
- Public users see only blue tick, not verification detail breakdown.
- Verification data may include:
  - Profile details.
  - Shop/workplace photos.
  - Optional ID proof.
  - Optional GST proof for business/job worker.
- Avoid storing raw Aadhaar number as normal application data.
- Prefer private proof documents and verification status.
- Provider-backed KYC/GST can come later through integration tables.

### Saved, Reports, Notifications, Settings

- Users can save profiles/work/work-needed items.
- Saved screen groups by Business, Job Worker, Karigar.
- Save action changes to `Saved`.
- Reports are only from profile detail three-dot menu in latest wireframe.
- Report reasons:
  - Wrong contact.
  - Wrong category.
  - Inappropriate photo.
  - Wrong details.
- No optional report text in latest wireframe.
- Notifications are a simple list with title, short message, and date/time.
- MVP notifications focus on verification/status.
- Settings includes notification settings, hide from search, contact support, logout.

### Analytics And Admin

- Store search logs from day one.
- Store profile/contact view events where possible.
- Contact/profile analytics are invisible to normal users in MVP.
- Admin analytics should include total profiles, verified profiles, search terms, contact reveals/views, and top categories.
- Admin actions should be audit logged.
- Admin-created seed profiles should be marked as admin/testing data.

## Round Log

## Round 1: Database Foundation

User answered on 2026-07-07.

### Answers

1. Primary key strategy:
   - User said yes to UUID primary keys, but is not fully sure.
   - Database design should stay flexible.

2. User and profile relationship:
   - Users and profiles are connected.
   - Only a user has their profile.
   - Interpret as one user owns exactly one profile.

3. Shared profile plus role-specific tables:
   - User said yes, but is not fully sure.
   - Keep this as the recommended default, but design should be understandable and flexible.

4. Role storage:
   - User does not want role treated as duplicated loosely.
   - Role should be locked to the connected user/profile relationship.
   - Database design should enforce one selected role for the account/profile.

5. Delete strategy:
   - Yes to soft delete first.

6. Status fields:
   - Yes, store status fields from day one.

7. Category strategy:
   - Use normalized category tables.
   - User is not fully sure and wants industry-standard design according to product needs.

8. Media table:
   - Yes to one media/assets table, but be cautious.
   - The design must avoid becoming confusing or unsafe for private verification files.

9. Job worker search object:
   - Yes, work cards should be the main searchable object for job-worker search.

10. Work-needed posts:
   - Yes, store work-needed posts separately from profiles and work cards.

11. Verification model:
   - Yes, store verification as cases/history, not only one field.

12. Search and contact/profile events:
   - Yes, store search logs and contact/profile events from day one.

### Resolved Database Foundation Decisions

- Use UUIDs as the default primary key strategy for main tables.
- Use separate `users` and `profiles` concepts.
- Enforce one user to one profile.
- Use a shared `profiles` table for common marketplace fields.
- Use role-specific detail tables for Manufacturer / Business, Job Worker / Value Adder, and Skilled Worker / Karigar.
- Role is locked to the account/profile and must be consistent across the connected user/profile data.
- Use soft delete through status/deleted timestamp fields instead of immediate hard delete.
- Store status fields from day one for users, profiles, work cards, posts, verification, media, and admin review flows.
- Use normalized category and alias tables, while still preserving user-entered free text for unmapped textile terms.
- Use a centralized `media_assets` table, with strict fields for ownership, linked entity, visibility, and private verification files.
- Treat Job Worker work cards / work entries as the main searchable unit.
- Store Manufacturer work-needed posts as separate demand/discovery objects.
- Store verification using cases/history and status, with current status also available on profile for fast reads.
- Store search logs and profile/contact events from day one.

### Open / Flexible Notes

- UUID default is accepted but can be revisited if the final backend/database stack strongly prefers another sortable public ID format such as ULID.
- Shared profile plus role-specific detail tables is accepted as the current best structure, but the final schema should explain why this is better than one large profile table.
- Category normalization is accepted, but the final schema should be practical for textile categories, product types, aliases, and unknown user-entered terms.
- Media design must clearly separate public profile/work photos from private verification proof documents.

## Round 2: Users, Profiles, Roles, Visibility, And Contact Fields

User answered on 2026-07-07.

### Answers

1. Profile row creation:
   - Create `user` after OTP verification.
   - Create `profile` after role confirmation.

2. Incomplete profile search visibility:
   - Only show profiles in search after minimum required fields are complete.

3. Mobile number changes:
   - Mobile number is locked for MVP.
   - Admin-assisted change can be added later.

4. Owner name locking:
   - Lock owner name after profile completion.

5. Profile visibility field:
   - Use `visibility_status` with values:
     - `draft`
     - `public`
     - `hidden_by_user`
     - `suspended_by_admin`
     - `deleted`

6. Current verification status on profile:
   - Store current verification status on profile.
   - Values:
     - `unverified`
     - `pending`
     - `verified`
     - `changes_requested`
     - `rejected`

7. Profile completion:
   - Store `completion_score` number.
   - Store `completion_flags` JSON for missing items.

8. Role-specific profile table names:
   - `business_profiles`
   - `job_worker_profiles`
   - `skilled_worker_profiles`

9. Business subtypes:
   - Initial subtype values:
     - `manufacturer`
     - `wholesaler`
     - `trader`
     - `retailer`
     - `other`
   - User adds these subtypes during profile creation by mentioning what they do.

10. Contact fields:
   - Store `primary_mobile` from user auth.
   - Store `alternate_contact_number` on profile.
   - No separate WhatsApp number confirmed in this round.

11. Address structure:
   - Address line.
   - Locality.
   - City.
   - State.
   - Pincode.
   - Free-text full address.

12. Admin-created seed profiles:
   - Allow profiles without a real user initially.
   - Store:
     - `created_by_admin`
     - `claim_status`

### Resolved Database Decisions

- Account creation sequence:
  - OTP verified -> create `users` row.
  - Role confirmed -> create `profiles` row with selected role.
- Profiles should not appear in search until role-specific minimum required fields are complete.
- `users.mobile_number` is immutable in MVP.
- Owner name is locked after profile completion.
- Use a multi-state profile visibility model instead of a simple `is_public` boolean.
- Keep current profile verification status on `profiles` for fast display and ranking.
- Keep detailed verification history in verification tables.
- Store profile completion as both a numeric score and structured missing/completed flags.
- Use role-specific extension tables:
  - `business_profiles`
  - `job_worker_profiles`
  - `skilled_worker_profiles`
- Business subtype should support real textile business overlap and future flexibility.
- Contact model:
  - `users.primary_mobile` / auth mobile is the source of login identity.
  - `profiles.alternate_contact_number` supports business contact needs.
- Store structured address fields plus full free-text address.
- Admin seed profiles can exist before a user claims/owns them.

### Open / Flexible Notes

- Business subtype modeling still needs one more schema decision:
  - single selected subtype vs multiple subtype mapping table vs free-text plus selected subtype.
- Admin seed profile claim flow needs later decisions:
  - how a real user claims a seeded profile,
  - what proof is required,
  - whether admin must approve the claim.
- WhatsApp number is not included yet; can be added later if product feedback shows it is needed.

## Round 3: Categories, Work Cards, Product Types, And Work-Needed Posts

User answered on 2026-07-07.

### Answers

1. Category database structure:
   - Use one `categories` table.
   - Initial `category_type` values:
     - `work_category`
     - `work_name`
     - `product_type`
   - User is not fully sure, so final design should remain flexible and explain the tradeoff.
   - Remove `machine_type` from MVP schema.

2. Category hierarchy:
   - Use parent-child hierarchy.
   - Initial examples:
     - Embroidery:
       - Zari work.
       - Bead work.
       - Aari work.
       - Khatli work.
       - Machine embroidery.
       - Hand embroidery.
     - Decorative and hand work:
       - Mirror work.
       - Hand work.
       - Khatli work.
       - Lace work.
       - Diamond work.
       - Zardhad diamond work.
       - Sarokhi diamond work.
     - Printing:
       - Digital print.
       - Khadi print.
       - Wax print.
       - Table print.
       - Block print.
       - Ajrakh print.
       - Brush print.
     - Dyeing and traditional processes:
       - Hand dyeing.
       - Murgha print.
       - Shibori print.
       - Lahariya print.
     - Fabric finishing:
       - Crush pleating.
       - Other pleating processes.
       - Washing.
       - Finishing.
       - Cutting.
       - Folding.
       - Packing.
     - Stitching:
       - Flat hemming.
       - Overlock stitching.
       - Other specialised stitching processes.

3. Product types for work cards:
   - Allow multiple product types per work card.
   - Require at least one product type.
   - Example: flat hemming can apply to dupatta, saree, and fabric.

4. Custom `Other` entries:
   - Store custom text on the work card/post.
   - Also create a `category_suggestions` row for admin mapping.

5. Work card status values:
   - `draft`
   - `published`
   - `hidden_by_user`
   - `removed_by_admin`
   - `deleted`

6. Work-needed post status values:
   - `active`
   - `paused`
   - `closed_by_user`
   - `removed_by_admin`
   - `deleted`

7. Photo count handling:
   - Store photos in `media_assets`.
   - Cache `photo_count` on profile/work/post for fast ranking.

8. Experience fields:
   - Store profile-level experience.
   - Also allow optional per-work-card experience.

9. Business subtypes:
   - Use a many-to-many mapping table so one business can be manufacturer + wholesaler + trader.
   - Also store optional free text such as `what they do`.

10. Search text storage:
   - Store normalized `search_text` on:
     - Work cards.
     - Work-needed posts.
     - Profiles.
   - Generate `search_text` from name, category, product, aliases/local terms, and relevant profile fields.

11. Machine type:
   - Do not include machine type in the MVP schema.
   - Remove this field for now.

12. Work-needed post expiry:
   - No auto-expiry now.
   - Store `last_activity_at` and `closed_at` for future stale reminders.

### Resolved Database Decisions

- Use a single flexible `categories` table with `category_type` for taxonomy dimensions.
- Initial category types:
  - `work_category`
  - `work_name`
  - `product_type`
- Do not include `machine_type` in MVP.
- Use `parent_id` on categories to support hierarchy.
- Use an admin-editable category hierarchy seeded with textile process groups such as Embroidery, Decorative and hand work, Printing, Dyeing, Fabric finishing, and Stitching.
- Work cards can map to multiple product types through a join table.
- Work cards must have at least one product type.
- Unknown user-entered work/category/product terms should be preserved as raw text and also sent to `category_suggestions`.
- Work cards have lifecycle status:
  - draft -> published -> hidden/removed/deleted.
- Work-needed posts have lifecycle status:
  - active -> paused/closed/removed/deleted.
- `media_assets` remains the source for actual photos.
- Cache `photo_count` on key searchable entities for ranking and fast result cards.
- Store experience both at profile level and optionally per work card.
- Model business subtype as many-to-many plus free text.
- Store generated normalized search text on profiles, work cards, and work-needed posts.
- Work-needed posts do not expire automatically in MVP, but store timestamps to support future stale reminders.

### Open / Flexible Notes

- `categories.category_type` may need additional values later such as `material`, `finish`, or `business_subtype`, but these should not be added until needed.
- The final schema should explain how `work_category` differs from `work_name`, because this can confuse future development if not documented.
- Search text generation must be owned by backend logic so user-entered category changes update searchable text consistently.

## Round 4: Media, Photos, Documents, And Verification Files

User answered on 2026-07-07.

### Answers

1. Public vs private media storage:
   - Use one `media_assets` table.
   - Use `visibility` values:
     - `public`
     - `private_admin_only`

2. Media linked entity style:
   - Use typed link fields:
     - `entity_type`
     - `entity_id`
   - Example entity types:
     - `profile`
     - `work_card`
     - `work_needed_post`
     - `verification_case`

3. Photo ordering:
   - Store `sort_order` on media so profile/work carousel order can be controlled.

4. Main/cover photo:
   - First uploaded image is the cover.
   - Do not add `is_cover` for MVP.

5. Image variants:
   - Store original path plus compressed/mobile thumbnail paths later:
     - `original_path`
     - `compressed_path`
     - `thumbnail_path`

6. Upload status:
   - Use values:
     - `pending_upload`
     - `uploaded`
     - `processing`
     - `ready`
     - `failed`
     - `deleted`

7. Minimum photo validation:
   - Enforce minimum photo rules in backend, not only mobile UI.

8. Verification document types:
   - Store `document_type` values:
     - `identity_proof`
     - `masked_aadhaar`
     - `gst_proof`
     - `shop_photo`
     - `workplace_photo`
     - `other`

9. Verification document deletion/replacement:
   - User cannot delete verification documents while verification is pending.
   - Allow replacement before submit.
   - Allow replacement after admin requests changes.

10. Verified public photo changes:
   - User can change public photos.
   - If shop/workplace photos change after verification, mark the profile as needing re-verification.

11. File metadata:
   - Store:
     - file size.
     - MIME type.
     - width.
     - height.
     - uploaded_by_user_id.
     - created_at.

12. Future video support:
   - Keep `media_kind` values:
     - `image`
     - `document`
   - Do not add video until needed.

### Resolved Database Decisions

- Use a single `media_assets` table for all media metadata.
- Use `visibility` to separate public app media from private admin-only verification files.
- Use typed polymorphic linking through `entity_type` and `entity_id`.
- Store `sort_order` for carousel ordering.
- Cover image is derived from first uploaded/lowest sort order media for that entity.
- Keep room for image variants:
  - original.
  - compressed.
  - thumbnail.
- Use upload lifecycle status to support poor internet, retries, image processing, and deletion.
- Backend must enforce photo-count requirements for profiles, work cards, and work-needed posts.
- Verification document uploads should be typed without storing raw Aadhaar number as a normal data field.
- Verification documents are locked during pending review.
- Replacing sensitive verified media should trigger re-verification.
- Store file metadata needed for validation, admin review, and future image optimization.
- Do not include video in MVP media schema.

### Open / Flexible Notes

- Polymorphic `entity_type` + `entity_id` is flexible but weaker than normal foreign keys; final schema should call out this tradeoff and enforce validity in backend/service logic.
- If media integrity becomes complex later, the schema can add join tables such as `profile_media`, `work_card_media`, and `verification_media` without changing storage buckets.
- First-uploaded cover behavior should be implemented as "lowest active sort_order" so reordering later remains possible.

## Round 5: Verification, Admin Review, And Audit Logs

User answered on 2026-07-07.

### Answers

1. Verification submission model:
   - Use one `verification_cases` row per profile submission.
   - Store checklist items inside `verification_checks`.

2. Verification checklist items:
   - Use these checks:
     - `profile_details`
     - `mobile`
     - `shop_or_workplace_photos`
     - `identity_proof`
     - `gst_proof`
     - `admin_final_review`

3. Final verified condition:
   - Profile gets verified only after `admin_final_review = approved`.
   - Other checks are supporting evidence.

4. Changes requested flow:
   - Same verification case becomes `changes_requested`.
   - Store `notes_to_user`.
   - User resubmits the same case.

5. Sensitive changes after verification:
   - Create a new verification case.
   - Set profile status to `unverified` or `changes_requested`.

6. GST fields:
   - Store:
     - `gstin`
     - `gst_legal_name`
     - `gst_trade_name`
     - `gst_status`
     - `gst_reviewed_at`

7. Identity proof storage:
   - Do not store ID number.
   - Store only:
     - document type.
     - media link.
     - review status.

8. Admin users:
   - Use `admin_users` with roles:
     - `super_admin`
     - `verifier`
     - `support`
     - `viewer`

9. Admin audit log:
   - Use one generic `admin_audit_logs` table with:
     - actor.
     - action.
     - entity_type.
     - entity_id.
     - before_json.
     - after_json.

10. Future verification provider checks:
    - Create `verification_provider_checks` now.
    - Keep it unused in MVP.

### Resolved Database Decisions

- Verification history must be modeled with `verification_cases`, not just a single status column on profile.
- Verification checklist review should be row-based in `verification_checks`, because admin/manual review history matters.
- `admin_final_review` is the only check that actually grants the public blue tick.
- `notes_to_user` belongs on the active verification case for the changes-requested loop.
- Sensitive verified-profile changes should start a fresh verification case and remove or downgrade verified status until reviewed.
- GST data should be structured enough for future automated provider verification.
- Identity proof should avoid storing raw ID numbers in the application database.
- Admin permissions should be role-based from the beginning.
- Admin mutations must be written to a generic audit log.
- A future-facing `verification_provider_checks` table should exist even if manual review is used first.

### Open / Flexible Notes

- Final schema must define exactly which profile fields are "sensitive" and trigger re-verification.
- `verification_checks` should likely be rows rather than JSON so every check has status, reviewer, notes, and timestamps.
- Need decide whether `admin_audit_logs.before_json` and `after_json` store full entity snapshots or only changed fields.
- Need decide if GST fields live on role-specific business/job-worker profile tables or in a shared `profile_gst_details` table.

## Round 6: Saved Items, Reports, Notifications, Search Logs, And Analytics

User answered on 2026-07-08.

### Answers

1. Saved items table:
   - Use one `saved_items` table with:
     - `user_id`
     - `target_type`
     - `target_id`

2. Saved item uniqueness:
   - Enforce that one user can save the same target only once.

3. Reports table:
   - Use one `reports` table with:
     - `reported_entity_type`
     - `reported_entity_id`
     - `reason`
     - `message`
     - `status`

4. Report reasons:
   - Use current reasons:
     - `wrong_contact`
     - `wrong_category`
     - `inappropriate_photo`
     - `wrong_details`
   - Also keep future-safe reasons:
     - `fake_profile`
     - `spam`
     - `other`

5. Report status lifecycle:
   - Use:
     - `submitted`
     - `in_review`
     - `resolved_no_action`
     - `action_taken`
     - `dismissed`

6. Notifications:
   - Store every notification in DB using a `notifications` table.
   - Store notification rows even if push notification is also sent.

7. Notification read tracking:
   - Use nullable `read_at`.
   - Unread means `read_at IS NULL`.

8. Search logs:
   - Store `search_logs` with:
     - `user_id`
     - `query`
     - `normalized_query`
     - `target_persona`
     - `filters_json`
     - `result_count`
     - `created_at`

9. Action analytics:
   - Use separate event tables for important actions instead of one generic event table:
     - `profile_view_events`
     - `contact_action_events`
     - `share_events`

10. Analytics retention:
    - Keep analytics/search logs indefinitely for MVP.
    - Design `created_at` indexes so later data can be deleted or archived.

### Resolved Database Decisions

- Saved items are polymorphic so the same table can save profiles, work cards, and work-needed posts.
- Saved uniqueness should be enforced at DB level with a unique key over `user_id`, `target_type`, and `target_id`.
- Reports are polymorphic and can target different public entities.
- Report reasons should include both MVP UI reasons and future-safe abuse reasons.
- Report review needs a real status lifecycle, not just a boolean.
- Notifications must be durable in the database because the app has an in-app notification list.
- Notification read state should use `read_at`, not a separate boolean.
- Search logs should be stored from MVP day one because search quality is core to the marketplace.
- Important analytics events should use separate tables for cleaner admin analytics and easier indexing.
- Analytics tables should be timestamp-indexed to support later retention/archive jobs.

### Open / Flexible Notes

- Polymorphic saved/report targets need backend validation because normal foreign keys cannot directly enforce every target table.
- Final schema should define allowed `target_type` and `reported_entity_type` values clearly.
- Need decide whether anonymous/admin-created seed profiles can appear in analytics before being claimed by a real user.
- Need decide if notification preferences are one JSON settings row or normalized per notification category.

## Round 7: Contact Reveal, Free Launch Mode, And Subscription-Ready Tables

User answered on 2026-07-08.

### Answers

1. Contact reveal tracking:
   - Create `contact_reveals` even during free launch when the backend returns contact/address on profile detail.
   - Reason: analytics from day one and easier future paid logic.

2. Duplicate reveal counting:
   - One reveal should count only once per `viewer_user_id` + `revealed_profile_id`.
   - Reopening the same profile should not consume another reveal.

3. Reveal target:
   - `contact_reveals` should always reveal a full profile, not a work card or post directly.
   - Store optional `source_type` and `source_id` to know whether the user came from a work card or work-needed post.
   - User is not fully sure, so keep this optional and nullable.

4. Launch mode config:
   - Add an `app_settings` or `feature_flags` table with `contact_reveal_mode` values:
     - `free_unlimited`
     - `quota_limited`
     - `subscription_required`

5. Free reveal quota:
   - Use `user_contact_quotas` with:
     - `free_reveals_total`
     - `free_reveals_used`
     - `verified_bonus_total`
     - `subscription_reveals_unlimited`

6. Subscription tables:
   - Create these tables now but do not use them in MVP:
     - `subscription_plans`
     - `user_subscriptions`
     - `payment_transactions`

7. Plan type:
   - Future plan periods:
     - `monthly`
     - `yearly`
   - Same features for all personas.
   - Do not include subscriptions in MVP behavior.

8. Admin free access:
   - Add `admin_access_grants` so admin can give free or unlimited access to early Surat users without payment.

9. Contact reveal abuse tracking:
   - Store these fields on contact reveal/action events where available:
     - `ip_address`
     - `device_id`
     - `user_agent`
     - `created_at`

10. Future locked contact rule:
    - In the later paid phase, contact/address is allowed only if the user has one of:
      - active free launch mode.
      - remaining free quota.
      - active subscription.
      - admin grant.

### Resolved Database Decisions

- Contact reveal history should exist from MVP day one, even while contact/address is free.
- Contact reveal counting should be idempotent for the same viewer/profile pair.
- The reveal target is the full profile; work cards and work-needed posts are only optional source attribution.
- Feature flags/app settings should control the contact reveal mode so the business model can change without schema changes.
- Free reveal quota needs a dedicated user-level table.
- Subscription and payment tables should exist as future-ready schema but remain unused in MVP behavior.
- Plan periods are monthly and yearly, with no persona-specific plan differences initially.
- Admin-granted free access should be represented explicitly instead of faking a payment/subscription row.
- Contact/action events may store device/network metadata for future abuse detection.
- Paid-phase contact access should be decided by a clear access rule:
  - free mode OR remaining quota OR active subscription OR admin grant.

### Open / Flexible Notes

- `source_type` and `source_id` on `contact_reveals` should stay nullable and should not become part of the uniqueness rule.
- Final schema should decide whether `free_reveals_used` is stored as a counter, calculated from `contact_reveals`, or both.
- Device and IP metadata must be treated as sensitive operational data with careful admin access.
- Payment provider-specific fields should stay generic until Razorpay/Stripe/other provider is selected.

## Round 8: Search Indexes, Constraints, And Data Integrity

User answered on 2026-07-08.

### Answers

1. PostgreSQL search implementation:
   - Store `search_text` on:
     - profiles.
     - work cards.
     - work-needed posts.
   - Also store PostgreSQL full-text `search_vector`.

2. Search text update owner:
   - Backend/service updates `search_text` whenever profile, work, or category data changes.

3. Category aliases:
   - Create `category_aliases` with:
     - `category_id`
     - `alias_text`
     - `normalized_alias`
     - `language`
     - `source`
   - Reason: supports local terms, spelling variants, Hindi, Gujarati, and Hinglish later.

4. Location indexing:
   - Store and index:
     - `normalized_locality`
     - `city`
     - `state`
     - `pincode`
   - No GPS for MVP.

5. Cached ranking fields:
   - Cache ranking fields on profile, work card, and work-needed post:
     - `photo_count`
     - `completion_score`
     - `is_verified`
     - `last_activity_at`
     - `ranking_score`
   - Reason: search results stay fast.

6. Status constraints:
   - Use text fields with CHECK constraints.
   - Reason: flexible enough while still safe.
   - User wants flexibility in database design.

7. Polymorphic target validation:
   - Use CHECK constraints for allowed type values.
   - Enforce actual target existence in backend.
   - User is not fully sure, so keep this as tentative.

8. Admin audit JSON:
   - Store full `before_json` and `after_json` for admin actions only.

9. Notification preferences:
   - Use one `user_settings` row with JSON preferences for MVP.

10. Search log privacy:
    - Store raw query for analytics.
    - Later add masking/redaction for phone-like strings.
    - For MVP, restrict admin access to search logs.
    - User is not fully sure, so keep this as tentative.

### Resolved Database Decisions

- Searchable entities need both human-readable/generated `search_text` and PostgreSQL full-text search support.
- Backend application logic owns `search_text` generation for MVP.
- Category aliases are first-class schema objects because local textile terms and mixed-language search are core product needs.
- Location search/filtering is text/locality based for MVP, not GPS/PostGIS based.
- Ranking should rely on cached fields to keep result pages fast.
- Use text + CHECK constraints instead of PostgreSQL enums for flexible status evolution.
- Admin audit snapshots should be complete for admin actions, but access must be restricted.
- Use JSON-based user settings for MVP notification preferences.

### Open / Flexible Notes

- Polymorphic target validation is accepted tentatively; final schema should clearly document backend enforcement requirements.
- Search log privacy is accepted tentatively; final schema should mark search logs as sensitive admin-only data.
- Search vector implementation can be a stored/generated column or a normal column updated by backend; final schema should choose one.
- Ranking score formula is not defined yet; schema only needs to store the cached value and source fields.

## Round 9: Account Lifecycle, Ownership, Field Locking, And Role-Wise Profile Fields

User answered on 2026-07-08.

### Answers

1. Account/profile deletion:
   - Use soft delete.
   - User account becomes `terminated`.
   - Profile becomes `deleted`.
   - Important history and audit data stays stored.

2. Mobile number reuse:
   - After account termination, the same mobile number should automatically be reusable.
   - User can create a new profile for that number.

3. Role immutability:
   - Role is immutable after profile completion.
   - Any future admin-assisted role change must be logged.

4. Locked fields:
   - Enforce locked fields in backend.
   - Do not use a separate `locked_fields` table.
   - Store changes in `profile_change_history`.

5. Admin-created seed profiles:
   - Profile can have `owner_user_id = NULL` if created by admin.
   - Store:
     - `created_by_admin_user_id`
     - `claim_status`

6. Claim request tables:
   - Do not prepare `profile_claim_requests` now.

7. Claim approval method:
   - No claim approval method now.

8. Child data delete behavior:
   - Do not hard cascade core marketplace data.
   - Soft delete profiles, work cards, and work-needed posts.
   - Keep media, events, and audit linked for history.

9. Sensitive changes that trigger re-verification:
   - Only these changes should trigger re-verification:
     - business/workshop name.
     - address/locality.
     - workplace photos.
     - GST details.
     - identity proof.

10. Backend access model:
    - Mobile app never writes directly to tables.
    - All important writes go through backend/API/Edge Functions.
    - Database RLS still exists as a safety layer.
    - This directly addresses the concern about Supabase frontend direct database access.

### Role-Wise Profile Field Requirements

#### Manufacturer / Business

| Field | Required? | Verification / Usage |
|---|---|---|
| Mobile number | Mandatory | OTP |
| Business name | Mandatory | Admin review |
| Owner name | Mandatory | Manual review |
| Business category | Mandatory | Admin/category check |
| What they manufacture/sell | Mandatory | Profile review |
| Shop/business address | Mandatory | Manual review |
| Area/locality/city | Mandatory | Search/local ranking |
| Shop photos | Mandatory | Minimum 3 photos |
| Product/work photos | Recommended | Improves trust |
| GSTIN | Optional but strongly recommended | Manual GST portal check |
| Aadhaar/identity proof | Optional for MVP | Only masked/alternate ID |
| PAN | No for MVP | Not needed |

#### Job Worker / Value Adder / Workshop

| Field | Required? | Verification / Usage |
|---|---|---|
| Mobile number | Mandatory | OTP |
| Workshop/business name | Mandatory if workshop | Admin review |
| Owner name | Mandatory | Manual review |
| Work category | Mandatory | Search taxonomy |
| Work name | Mandatory | Search result |
| Product type | Mandatory | Search filter |
| Work photos | Mandatory | At least 1 per work card |
| Workplace/shop photos | Mandatory for blue tick | Minimum 3 photos |
| Work address / area | Mandatory | Local discovery |
| GSTIN | Optional | Only if they have GST |
| Identity proof | Optional for MVP | For blue tick or paid phase |
| PAN | No for MVP | Not needed |

#### Skilled Worker / Karigar

| Field | Required? | Verification / Usage |
|---|---|---|
| Mobile number | Mandatory | OTP |
| Name | Mandatory | Profile |
| Skill/mastery | Mandatory | Search |
| Experience | Mandatory | Trust |
| Area/address | Mandatory | Local discovery |
| Worker photo | Recommended | Trust |
| Work photos | Recommended | Better ranking |
| Identity proof | Optional | For blue tick |
| GSTIN | No | Usually not applicable |
| PAN | No | Not needed |
| Aadhaar number | No | Avoid |

### Resolved Database Decisions

- Soft deletion is the default for accounts, profiles, work cards, and work-needed posts.
- Mobile uniqueness should apply to active/non-terminated users only so terminated numbers can be reused.
- Role is immutable after profile completion and any exceptional admin role change must be audited.
- Backend logic owns locked-field enforcement and must write profile changes to `profile_change_history`.
- Admin-created seed profiles can exist without an owner user.
- Profile claiming is not part of the current schema scope beyond basic `claim_status`.
- Core marketplace child records should not be hard-cascaded away.
- Re-verification is triggered only by a narrow sensitive-field list.
- App writes should go through backend/API/Edge Functions, with RLS as a second layer.
- Role-specific required fields should drive profile completion and verification readiness.

### Open / Flexible Notes

- Latest answer says job-worker work cards require at least 1 photo, while earlier wireframe answers mentioned minimum 3 photos. Final schema should confirm the MVP rule before enforcing it.
- `claim_status` may be simple for now, such as `unclaimed`, `claimed`, `not_claimable`, without a full claim-request workflow.
- If mobile numbers are reusable after termination, login/account creation must avoid accidentally reconnecting a terminated profile.
- Owner name remains locked after profile completion from earlier answers, but is not included in the latest re-verification trigger list.

## Round 10: Final Schema Lock

User answered on 2026-07-08.

### Answers

1. Primary keys:
   - Use PostgreSQL `uuid` primary keys with `gen_random_uuid()` for all main tables.
   - Keep database design flexible.

2. Table naming:
   - Use plural snake_case table names, such as:
     - `users`
     - `profiles`
     - `work_cards`
     - `media_assets`

3. Profile table structure:
   - Use one common `profiles` table.
   - Use role-specific extension tables:
     - `business_profiles`
     - `job_worker_profiles`
     - `skilled_worker_profiles`

4. GST storage:
   - Use shared `profile_gst_details` table linked to `profile_id`.
   - Use it only when applicable.
   - Reason: avoids duplicating GST columns in business and job-worker tables.

5. Identity proof storage:
   - No ID number columns anywhere.
   - Store only verification media, document type, and review status.

6. Work-card photo minimum:
   - Minimum 3 photos.

7. Shop/workplace photo minimum:
   - Keep minimum 3 photos for business/shop/workplace verification.

8. Category model:
   - Use one `categories` table with parent-child hierarchy and `category_type`.
   - Add `category_aliases`.

9. Media model:
   - Keep one polymorphic `media_assets` table with `entity_type` and `entity_id` for MVP.

10. Final database design output:
    - Create one Markdown file with:
      - ERD.
      - table list.
      - columns.
      - constraints.
      - indexes.
      - search strategy.
      - verification model.
      - admin model.
      - migration order.

### Resolved Database Decisions

- Use UUID primary keys with `gen_random_uuid()` on all main tables.
- Use plural snake_case table and column names.
- Use shared `profiles` plus role-specific extension tables.
- Store GST data in `profile_gst_details`, not duplicated role tables.
- Do not store identity proof numbers.
- Enforce minimum 3 photos for job-worker work cards.
- Enforce minimum 3 photos for business/shop/workplace verification.
- Use hierarchical categories plus aliases.
- Use polymorphic `media_assets` for MVP.
- Discovery is complete enough to produce the first full database design artifact.

### Open / Flexible Notes

- "Flexible" means prefer CHECK constraints and nullable future-facing columns over hard PostgreSQL enum types where business statuses may evolve.
- Work-card minimum photo conflict is resolved in favor of 3 photos.
- Future versions may split polymorphic media links into strict join tables if integrity needs grow.

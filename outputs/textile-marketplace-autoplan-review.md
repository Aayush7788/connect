# Textile Marketplace Autoplan Document Review

Reviewed files:

- `outputs/textile-marketplace-database-schema-discovery.md`
- `outputs/textile-marketplace-database-design.md`
- `outputs/textile-marketplace-figma-wireframe-spec.md`

Review date: 2026-07-08

Correction pass status: addressed on 2026-07-08.

Updated source documents:

- `outputs/textile-marketplace-database-design.md`
- `outputs/textile-marketplace-figma-wireframe-spec.md`

Resolved in the correction pass:

- Added business profile product-type mapping to the database design.
- Added custom work category text for work cards and work-needed posts.
- Replaced nullable composite product-type key guidance with row ids plus partial uniqueness guidance.
- Added owner-side work/post action controls to the wireframe spec.
- Added verification changes-requested resubmission flow to the wireframe spec.
- Added owner/person name to sensitive re-verification triggers.
- Removed the duplicate contact reveal index recommendation.

## Verdict

The documents are directionally strong and mostly consistent with the MVP decisions:

- Android-first private demo.
- One account, one profile.
- Role selection after OTP.
- Backend/API/BFF writes instead of direct mobile-to-table writes.
- PostgreSQL source of truth.
- Work cards and work-needed posts as first-class marketplace objects.
- Manual verification first.
- No payments, ratings, chat, voice search, iOS, maps, or order management in MVP.

However, the docs are not yet ready to turn directly into migrations and API contracts. A few schema gaps and wireframe handoff gaps should be fixed before coding.

## High-Priority Findings

### 1. Business profile product types are in the wireframe but missing from the schema

The wireframe business profile completion includes `Product type`, but `business_profiles` only stores `business_category_id`, `manufacture_sell_details`, and `product_notes`.

Impact:

- Manufacturer/business search cannot reliably filter by product type.
- Business result cards and profile completion will collect structured data that has no normalized table.
- Search quality will drift into free-text matching too early.

Recommendation:

Add a normalized mapping table:

```sql
business_profile_product_types (
  profile_id uuid references profiles(id),
  product_type_category_id uuid null references categories(id),
  custom_product_type_text text null,
  created_at timestamptz not null default now()
)
```

Use an `id uuid pk` or partial unique indexes, not a nullable composite primary key.

### 2. Custom category text is supported in the wireframe but not directly stored on work cards/posts

The wireframe allows `Other -> Type category` for Add Work Card, but `work_cards` and `work_needed_posts` only have `custom_work_name`, not `custom_work_category_text`.

Impact:

- User-entered custom categories can be suggested to admin, but the work card/post itself cannot display or search that custom category cleanly before admin mapping.
- Search text generation will need awkward joins to `category_suggestions`, which is not ideal for the primary searchable entity.

Recommendation:

Add:

- `work_cards.custom_work_category_text`
- `work_needed_posts.custom_work_category_text`

Still create `category_suggestions` rows for admin mapping.

### 3. Product-type mapping primary key design is incomplete for custom product types

`work_card_product_types` says the primary key recommendation is `(work_card_id, product_type_category_id)` where mapped, but `product_type_category_id` is nullable because custom product types are allowed.

Impact:

- A normal primary key cannot contain nullable columns.
- Custom product-type rows need their own row identity.
- Duplicate custom entries will be hard to control without a proper uniqueness plan.

Recommendation:

Use:

```sql
id uuid primary key
work_card_id uuid not null references work_cards(id)
product_type_category_id uuid null references categories(id)
custom_product_type_text text null
```

Then add partial uniqueness:

```sql
unique (work_card_id, product_type_category_id)
where product_type_category_id is not null

unique (work_card_id, lower(custom_product_type_text))
where custom_product_type_text is not null
```

Apply the same pattern to `work_needed_post_product_types`.

### 4. Owner-side work/post management is under-specified in the wireframe

The database supports these statuses:

- Work cards: draft, published, hidden, removed, deleted.
- Work-needed posts: active, paused, closed, removed, deleted.

But the wireframe owner screens mostly show list + add button. They do not clearly show:

- Edit work card.
- Delete/hide work card.
- Add more photos to a work card.
- Pause/close/delete a work-needed post.
- Edit a work-needed post.

Impact:

- Flutter implementation will invent these controls later.
- Owner flows will be incomplete for real users.
- Database states will exist without obvious UI entry points.

Recommendation:

Add owner-card action menus to:

- `04.07 My Profile - Job Worker Owner Work List`
- `04.08 My Profile - Manufacturer Owner Work Needed`

Minimum actions:

- Job worker work card: Edit, Add photos, Hide, Delete.
- Manufacturer work-needed post: Edit, Pause, Close, Delete.

### 5. Changes-requested verification loop is not fully designed in the wireframe

The schema supports `changes_requested`, notes to user, and resubmission. The wireframe shows the notification row but does not define what happens after the user taps it.

Impact:

- Verification support flow is incomplete.
- Users may see "Changes requested" but not know where to fix and resubmit.
- Backend state exists without a clear screen journey.

Recommendation:

Add or annotate:

- Notification tap opens My Profile verification area.
- Show admin message.
- Unlock only the requested fields/documents.
- CTA: `Update and Resubmit`.

## Medium-Priority Findings

### 6. Owner name is locked but not listed as a re-verification trigger

`profiles.owner_name` is marked locked after completion, but the sensitive-change list omits owner name.

Recommendation:

Add owner/person name to the sensitive-change rules, at least for admin-assisted changes.

### 7. Search indexes miss important product-type filter paths

The index strategy has core profile/work/post indexes and FTS/trigram indexes, but it does not list product-type mapping indexes.

Recommendation:

Add indexes for:

- `work_card_product_types(product_type_category_id, work_card_id)`
- `work_needed_post_product_types(product_type_category_id, work_needed_post_id)`
- future `business_profile_product_types(product_type_category_id, profile_id)`

Also consider rank/status indexes for published work cards and active work-needed posts.

### 8. Duplicate contact reveal index

The design has both a normal index and unique index on `(viewer_user_id, revealed_profile_id)`.

Recommendation:

Keep only the unique index unless a different covering/sort index is needed.

### 9. Verification media/doc privacy needs consent and retention metadata

The docs correctly avoid raw Aadhaar/PAN numbers, but uploaded identity document images can still contain sensitive personal data.

Recommendation:

Before launch, add one of:

- `verification_cases.consent_accepted_at`
- `verification_cases.consent_version`
- `media_assets.retention_policy`
- `media_assets.purge_after`

This is not necessary for private demo coding if identity proof stays optional, but it should be decided before real launch.

### 10. Skilled worker skills may need a multi-skill table

The schema has `primary_skill_category_id` plus `skill_mastery`. The original product model allows workers with one or more skills.

Recommendation:

For MVP, single skill is acceptable. If multi-skill search is important from day one, add:

```sql
skilled_worker_skills (
  profile_id uuid references profiles(id),
  skill_category_id uuid null references categories(id),
  custom_skill_text text null,
  experience_years integer null,
  is_primary boolean not null default false
)
```

## What Looks Correct

- The backend boundary is correct: app/admin should call backend APIs, not direct public table writes.
- One profile per active user is correctly modeled.
- Role-specific extension tables are the right shape.
- Category + alias model is correct for Surat/local-language search.
- Work cards as the main job-worker searchable object is correct.
- Work-needed posts as separate demand objects are correct.
- `media_assets` polymorphic model is acceptable for MVP, as long as backend validation is strict.
- Verification cases + checks is the right model.
- Admin audit logging is correctly included.
- Search logs and contact reveal analytics from day one are correct.
- Wireframe correctly keeps result cards free of contact/address.
- Wireframe correctly puts contact/address only on profile detail for MVP.
- Wireframe correctly excludes payment/subscription/admin screens from the mobile MVP wireframe.

## Recommended Next Action

Do one correction pass before moving to API contracts:

1. Update `textile-marketplace-database-design.md` for the schema issues above.
2. Update `textile-marketplace-figma-wireframe-spec.md` for owner-side edit/status controls and verification resubmission.
3. Then create the MVP API contract, mapping each screen action to endpoint, database tables, validation, and response states.

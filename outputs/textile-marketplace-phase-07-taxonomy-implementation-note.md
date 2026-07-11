# Phase 7 Taxonomy Implementation Note

Date: 2026-07-11

## Scope Implemented

Phase 7 added the taxonomy and seed-data foundation:

- `categories`
- `category_aliases`
- `category_suggestions`
- `business_subtypes`
- `database/seeds/001_initial_taxonomy.sql`

The live migration also seeds the MVP textile taxonomy required for initial search:

- Work categories: embroidery, decorative and hand work, printing, dyeing and traditional processes, fabric finishing, stitching.
- Work names including flat hemming, digital print, zari work, overlock stitching, lace work, mirror work, khatli work, printing variants, dyeing variants, and finishing/stitching terms.
- Product types including dupatta, saree, fabric, kurti, dress material, lehenga, blouse, gown, scarf, and shawl.
- Business subtypes: manufacturer, wholesaler, trader, retailer, other.
- Initial alias/local terms such as pico, piko, hemming, digi print, jari work, bharat work, sari, saari, kapda, and chunni.

## Implementation Decisions

`category_suggestions.profile_id` exists now as a nullable UUID, but Phase 7 does not add a foreign key to `profiles` because the `profiles` table is created in Phase 8. Phase 8 should add the FK after `profiles` exists.

The current `categories` model uses a single `parent_id`, so one work name can belong to one parent category. The discovery notes mention `Khatli work` under more than one textile group. For the MVP seed, it is inserted once under `Embroidery`; aliases and future admin mapping can improve cross-category matching without introducing a many-parent taxonomy table yet.

## Verification

The Phase 7 live database check confirmed:

- 4 taxonomy tables exist.
- RLS is enabled on all 4 taxonomy tables.
- 6 work categories are seeded.
- 33 work names are seeded.
- 10 product types are seeded.
- 22 aliases are seeded.
- 5 business subtypes are seeded.

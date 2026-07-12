insert into categories (
  category_type,
  parent_id,
  name,
  slug,
  normalized_name,
  sort_order,
  metadata
)
select
  v.category_type,
  null,
  v.name,
  v.slug,
  v.normalized_name,
  v.sort_order,
  '{}'::jsonb
from (
  values
    ('business_category', 'Manufacturing', 'manufacturing', 'manufacturing', 10),
    ('business_category', 'Wholesale', 'wholesale', 'wholesale', 20),
    ('business_category', 'Trading', 'trading', 'trading', 30),
    ('business_category', 'Retail', 'retail', 'retail', 40),
    ('business_category', 'Process house', 'process-house', 'process house', 50),
    ('business_category', 'Textile brand', 'textile-brand', 'textile brand', 60),
    ('business_category', 'Other textile business', 'other-textile-business', 'other textile business', 70),
    ('work_category', 'Embroidery', 'embroidery', 'embroidery', 10),
    ('work_category', 'Decorative and hand work', 'decorative-hand-work', 'decorative and hand work', 20),
    ('work_category', 'Printing', 'printing', 'printing', 30),
    ('work_category', 'Dyeing and traditional processes', 'dyeing-traditional-processes', 'dyeing and traditional processes', 40),
    ('work_category', 'Fabric finishing', 'fabric-finishing', 'fabric finishing', 50),
    ('work_category', 'Stitching', 'stitching', 'stitching', 60),
    ('product_type', 'Dupatta', 'dupatta', 'dupatta', 10),
    ('product_type', 'Saree', 'saree', 'saree', 20),
    ('product_type', 'Fabric', 'fabric', 'fabric', 30),
    ('product_type', 'Kurti', 'kurti', 'kurti', 40),
    ('product_type', 'Dress material', 'dress-material', 'dress material', 50),
    ('product_type', 'Lehenga', 'lehenga', 'lehenga', 60),
    ('product_type', 'Blouse', 'blouse', 'blouse', 70),
    ('product_type', 'Gown', 'gown', 'gown', 80),
    ('product_type', 'Scarf', 'scarf', 'scarf', 90),
    ('product_type', 'Shawl', 'shawl', 'shawl', 100)
) as v(category_type, name, slug, normalized_name, sort_order)
on conflict (category_type, slug) do nothing;

insert into categories (
  category_type,
  parent_id,
  name,
  slug,
  normalized_name,
  sort_order,
  metadata
)
select
  'work_name',
  p.id,
  v.name,
  v.slug,
  v.normalized_name,
  v.sort_order,
  '{}'::jsonb
from (
  values
    ('embroidery', 'Zari work', 'zari-work', 'zari work', 10),
    ('embroidery', 'Bead work', 'bead-work', 'bead work', 20),
    ('embroidery', 'Aari work', 'aari-work', 'aari work', 30),
    ('embroidery', 'Khatli work', 'khatli-work', 'khatli work', 40),
    ('embroidery', 'Machine embroidery', 'machine-embroidery', 'machine embroidery', 50),
    ('embroidery', 'Hand embroidery', 'hand-embroidery', 'hand embroidery', 60),
    ('decorative-hand-work', 'Mirror work', 'mirror-work', 'mirror work', 10),
    ('decorative-hand-work', 'Hand work', 'hand-work', 'hand work', 20),
    ('decorative-hand-work', 'Lace work', 'lace-work', 'lace work', 30),
    ('decorative-hand-work', 'Diamond work', 'diamond-work', 'diamond work', 40),
    ('decorative-hand-work', 'Zardhad diamond work', 'zardhad-diamond-work', 'zardhad diamond work', 50),
    ('decorative-hand-work', 'Sarokhi diamond work', 'sarokhi-diamond-work', 'sarokhi diamond work', 60),
    ('printing', 'Digital print', 'digital-print', 'digital print', 10),
    ('printing', 'Khadi print', 'khadi-print', 'khadi print', 20),
    ('printing', 'Wax print', 'wax-print', 'wax print', 30),
    ('printing', 'Table print', 'table-print', 'table print', 40),
    ('printing', 'Block print', 'block-print', 'block print', 50),
    ('printing', 'Ajrakh print', 'ajrakh-print', 'ajrakh print', 60),
    ('printing', 'Brush print', 'brush-print', 'brush print', 70),
    ('dyeing-traditional-processes', 'Hand dyeing', 'hand-dyeing', 'hand dyeing', 10),
    ('dyeing-traditional-processes', 'Murgha print', 'murgha-print', 'murgha print', 20),
    ('dyeing-traditional-processes', 'Shibori print', 'shibori-print', 'shibori print', 30),
    ('dyeing-traditional-processes', 'Lahariya print', 'lahariya-print', 'lahariya print', 40),
    ('fabric-finishing', 'Crush pleating', 'crush-pleating', 'crush pleating', 10),
    ('fabric-finishing', 'Pleating', 'pleating', 'pleating', 20),
    ('fabric-finishing', 'Washing', 'washing', 'washing', 30),
    ('fabric-finishing', 'Finishing', 'finishing', 'finishing', 40),
    ('fabric-finishing', 'Cutting', 'cutting', 'cutting', 50),
    ('fabric-finishing', 'Folding', 'folding', 'folding', 60),
    ('fabric-finishing', 'Packing', 'packing', 'packing', 70),
    ('stitching', 'Flat hemming', 'flat-hemming', 'flat hemming', 10),
    ('stitching', 'Overlock stitching', 'overlock-stitching', 'overlock stitching', 20),
    ('stitching', 'Specialised stitching', 'specialised-stitching', 'specialised stitching', 30)
) as v(parent_slug, name, slug, normalized_name, sort_order)
join categories p
  on p.category_type = 'work_category'
 and p.slug = v.parent_slug
on conflict (category_type, slug) do nothing;

insert into category_aliases (
  category_id,
  alias_text,
  normalized_alias,
  language,
  source
)
select
  c.id,
  v.alias_text,
  v.normalized_alias,
  v.language,
  'import'
from (
  values
    ('work_name', 'flat-hemming', 'Pico', 'pico', 'hinglish'),
    ('work_name', 'flat-hemming', 'Piko', 'piko', 'hinglish'),
    ('work_name', 'flat-hemming', 'Hemming', 'hemming', 'en'),
    ('work_name', 'flat-hemming', 'Flat hem', 'flat hem', 'en'),
    ('work_name', 'overlock-stitching', 'Overlock', 'overlock', 'en'),
    ('work_name', 'digital-print', 'Digital printing', 'digital printing', 'en'),
    ('work_name', 'digital-print', 'Digi print', 'digi print', 'hinglish'),
    ('work_name', 'zari-work', 'Zari', 'zari', 'en'),
    ('work_name', 'zari-work', 'Jari work', 'jari work', 'hinglish'),
    ('work_name', 'aari-work', 'Aari', 'aari', 'en'),
    ('work_name', 'mirror-work', 'Mirror', 'mirror', 'en'),
    ('work_name', 'lace-work', 'Lace', 'lace', 'en'),
    ('work_category', 'embroidery', 'Bharat work', 'bharat work', 'hinglish'),
    ('work_category', 'printing', 'Print work', 'print work', 'en'),
    ('work_category', 'stitching', 'Silai work', 'silai work', 'hinglish'),
    ('product_type', 'dupatta', 'Dupatta job', 'dupatta job', 'en'),
    ('product_type', 'dupatta', 'Chunni', 'chunni', 'hinglish'),
    ('product_type', 'saree', 'Sari', 'sari', 'en'),
    ('product_type', 'saree', 'Saari', 'saari', 'hinglish'),
    ('product_type', 'fabric', 'Cloth', 'cloth', 'en'),
    ('product_type', 'fabric', 'Kapda', 'kapda', 'hinglish'),
    ('product_type', 'dress-material', 'Dress material job', 'dress material job', 'en')
) as v(category_type, slug, alias_text, normalized_alias, language)
join categories c
  on c.category_type = v.category_type
 and c.slug = v.slug
on conflict (category_id, normalized_alias) do nothing;

insert into business_subtypes (
  code,
  label,
  sort_order
)
values
  ('manufacturer', 'Manufacturer', 10),
  ('wholesaler', 'Wholesaler', 20),
  ('trader', 'Trader', 30),
  ('retailer', 'Retailer', 40),
  ('other', 'Other', 50)
on conflict (code) do nothing;

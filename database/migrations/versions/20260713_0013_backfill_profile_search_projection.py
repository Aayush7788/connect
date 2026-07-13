"""backfill profile search projection

Revision ID: 20260713_0013
Revises: 20260713_0012
Create Date: 2026-07-13 20:30:00.000000
"""

from collections.abc import Sequence

from alembic import op
import sqlalchemy as sa


revision: str = "20260713_0013"
down_revision: str | None = "20260713_0012"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


def upgrade() -> None:
    op.execute(
        sa.text(
            """
            with profile_terms as (
                select
                    p.id,
                    lower(
                        regexp_replace(
                            concat_ws(
                                ' ',
                                p.public_name,
                                p.owner_name,
                                p.locality,
                                p.city,
                                p.state,
                                bp.business_name,
                                bp.manufacture_sell_details,
                                bp.product_notes,
                                jwp.workshop_name,
                                jwp.work_summary,
                                swp.skill_mastery,
                                swp.bio,
                                business_category.name,
                                skill_category.name,
                                product_terms.names,
                                alias_terms.names
                            ),
                            '\\s+',
                            ' ',
                            'g'
                        )
                    ) as search_text
                from profiles p
                left join business_profiles bp on bp.profile_id = p.id
                left join job_worker_profiles jwp on jwp.profile_id = p.id
                left join skilled_worker_profiles swp on swp.profile_id = p.id
                left join categories business_category
                    on business_category.id = bp.business_category_id
                left join categories skill_category
                    on skill_category.id = swp.primary_skill_category_id
                left join lateral (
                    select string_agg(
                        coalesce(category.name, product.custom_product_type_text),
                        ' '
                    ) as names
                    from business_profile_product_types product
                    left join categories category
                        on category.id = product.product_type_category_id
                    where product.profile_id = p.id
                ) product_terms on true
                left join lateral (
                    select string_agg(alias.normalized_alias, ' ') as names
                    from category_aliases alias
                    where alias.is_active = true
                    and alias.category_id in (
                        select category_id
                        from (
                            select bp.business_category_id as category_id
                            union all
                            select swp.primary_skill_category_id
                            union all
                            select product.product_type_category_id
                            from business_profile_product_types product
                            where product.profile_id = p.id
                        ) profile_categories
                        where category_id is not null
                    )
                ) alias_terms on true
                where p.deleted_at is null
            )
            update profiles profile
            set
                normalized_locality = nullif(
                    lower(regexp_replace(btrim(profile.locality), '\\s+', ' ', 'g')),
                    ''
                ),
                search_text = profile_terms.search_text,
                search_vector = to_tsvector('simple', profile_terms.search_text)
            from profile_terms
            where profile.id = profile_terms.id
            """
        )
    )


def downgrade() -> None:
    pass

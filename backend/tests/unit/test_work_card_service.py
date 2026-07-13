from datetime import datetime, timezone
from decimal import Decimal
from uuid import uuid4

import pytest

from app.core.auth_context import CurrentUser
from app.core.errors import ApiError, ErrorCode
from app.db.models.identity import User
from app.db.models.marketplace import WorkCardProductType
from app.db.models.profile import Profile
from app.db.models.taxonomy import Category
from app.modules.profiles.service import CompletionResult
from app.modules.work_cards.repository import OwnerWorkCardContext, WorkCardBundle
from app.modules.work_cards.schemas import WorkCardUpsertRequest
from app.modules.work_cards.service import WorkCardService


class FakeProfileService:
    def __init__(self, complete: bool = True) -> None:
        self.complete = complete
        self.refreshed: list = []

    def refresh_completion(self, profile_id):
        self.refreshed.append(profile_id)
        if self.complete:
            return CompletionResult(score=100, flags={"published_work_card": True})
        return CompletionResult(score=80, flags={"published_work_card": False})


class FakeWorkCardRepository:
    def __init__(self, context: OwnerWorkCardContext) -> None:
        self.context = context
        self.cards: dict = {}
        self.products: dict = {}
        self.photo_counts: dict = {}
        self.categories: dict = {}
        self.suggestions: dict = {}
        self.commits = 0

    def get_owner_context(self, user_id, *, for_update=False):
        if user_id == self.context.user.id:
            return self.context
        return None

    def list_owned_bundles(self, user_id):
        return [
            self.hydrate_card(context=self.context, card=card)
            for card in self.cards.values()
            if card.status != "deleted"
        ]

    def get_owned_bundle(
        self,
        *,
        user_id,
        work_card_id,
        for_update=False,
        include_deleted=False,
    ):
        card = self.cards.get(work_card_id)
        if user_id != self.context.user.id or card is None:
            return None
        if not include_deleted and card.status == "deleted":
            return None
        return self.hydrate_card(context=self.context, card=card)

    def get_by_creation_key(self, *, profile_id, idempotency_key):
        return next(
            (
                card
                for card in self.cards.values()
                if card.profile_id == profile_id
                and card.creation_idempotency_key == idempotency_key
            ),
            None,
        )

    def hydrate_card(self, *, context, card):
        category_ids = {
            category_id
            for category_id in (card.work_category_id, card.work_name_category_id)
            if category_id is not None
        }
        category_ids.update(
            item.product_type_category_id
            for item in self.products.get(card.id, [])
            if item.product_type_category_id is not None
        )
        return WorkCardBundle(
            context=context,
            card=card,
            product_types=self.products.get(card.id, []),
            media=[],
            categories={
                category_id: self.categories[category_id]
                for category_id in category_ids
                if category_id in self.categories
            },
        )

    def get_active_categories(self, category_ids):
        return {
            category_id: self.categories[category_id]
            for category_id in category_ids
            if category_id in self.categories
        }

    def get_categories(self, category_ids):
        return {
            category_id: self.categories[category_id]
            for category_id in category_ids
            if category_id in self.categories
        }

    def category_aliases(self, category_ids):
        return ["silai"] if category_ids else []

    def replace_product_types(self, *, work_card_id, category_ids, custom_values):
        self.products[work_card_id] = [
            WorkCardProductType(
                id=uuid4(),
                work_card_id=work_card_id,
                product_type_category_id=category_id,
                created_at=datetime.now(timezone.utc),
            )
            for category_id in category_ids
        ] + [
            WorkCardProductType(
                id=uuid4(),
                work_card_id=work_card_id,
                custom_product_type_text=value,
                created_at=datetime.now(timezone.utc),
            )
            for value in custom_values
        ]

    def sync_pending_suggestions(
        self,
        *,
        user_id,
        profile_id,
        work_card_id,
        suggestions,
    ):
        self.suggestions[work_card_id] = suggestions

    def ready_public_photo_count(self, work_card_id):
        return self.photo_counts.get(work_card_id, 0)

    def set_search_vector(self, card, search_text):
        card.search_vector = search_text

    def add(self, card):
        card.id = uuid4()
        now = datetime.now(timezone.utc)
        card.created_at = now
        card.updated_at = now
        card.photo_count = 0
        card.ranking_score = Decimal("0")
        self.cards[card.id] = card

    def flush(self):
        return None

    def commit(self):
        self.commits += 1

    def rollback(self):
        return None

    @staticmethod
    def safe_media_name(media):
        return "work.jpg"


def make_service():
    user_id = uuid4()
    now = datetime.now(timezone.utc)
    user = User(
        id=user_id,
        auth_user_id=uuid4(),
        display_name="Aayush",
        primary_mobile="+919999999999",
        account_status="active",
        role="job_worker",
        profile_completed_at=now,
    )
    profile = Profile(
        id=uuid4(),
        owner_user_id=user_id,
        role="job_worker",
        public_name="Surat Hemming Works",
        visibility_status="draft",
        verification_status="unverified",
        completion_score=80,
        completion_flags={},
        photo_count=3,
        ranking_score=Decimal("0"),
        is_verified=False,
        reverification_required=False,
    )
    context = OwnerWorkCardContext(user=user, profile=profile)
    repository = FakeWorkCardRepository(context)
    profile_service = FakeProfileService()
    service = WorkCardService(
        repository=repository,
        profile_service=profile_service,
        public_media_url=lambda path: f"https://storage.test/{path}",
    )
    current_user = CurrentUser(
        user_id=user_id,
        auth_user_id=user.auth_user_id,
        mobile=user.primary_mobile,
        role="job_worker",
        account_status="active",
    )
    return service, repository, profile_service, current_user


def add_mapped_taxonomy(repository: FakeWorkCardRepository):
    category_id = uuid4()
    work_name_id = uuid4()
    product_id = uuid4()
    repository.categories = {
        category_id: Category(
            id=category_id,
            category_type="work_category",
            name="Stitching",
            slug="stitching",
            normalized_name="stitching",
            is_active=True,
            sort_order=0,
            metadata_json={},
        ),
        work_name_id: Category(
            id=work_name_id,
            parent_id=category_id,
            category_type="work_name",
            name="Flat hemming",
            slug="flat-hemming",
            normalized_name="flat hemming",
            is_active=True,
            sort_order=0,
            metadata_json={},
        ),
        product_id: Category(
            id=product_id,
            category_type="product_type",
            name="Dupatta",
            slug="dupatta",
            normalized_name="dupatta",
            is_active=True,
            sort_order=0,
            metadata_json={},
        ),
    }
    return category_id, work_name_id, product_id


def test_create_is_idempotent_and_records_custom_taxonomy_suggestions() -> None:
    service, repository, profile_service, current_user = make_service()
    payload = WorkCardUpsertRequest(
        custom_category_text="Local stitching",
        custom_work_name="Patli silai",
        custom_product_texts=["Dupatta"],
        description="Clean edge finishing.",
    )

    first = service.create_work_card(
        current_user=current_user,
        payload=payload,
        idempotency_key="work-card-1",
    )
    second = service.create_work_card(
        current_user=current_user,
        payload=payload,
        idempotency_key="work-card-1",
    )

    assert first.id == second.id
    assert len(repository.cards) == 1
    assert repository.suggestions[first.id]["work_name"] == [
        ("Patli silai", "patli silai")
    ]
    assert profile_service.refreshed == [repository.context.profile.id]


def test_publish_requires_three_ready_photos() -> None:
    service, repository, _, current_user = make_service()
    category_id, work_name_id, product_id = add_mapped_taxonomy(repository)
    created = service.create_work_card(
        current_user=current_user,
        payload=WorkCardUpsertRequest(
            category_id=category_id,
            work_name_id=work_name_id,
            product_type_ids=[product_id],
            description="Clean flat hemming for dupattas.",
        ),
        idempotency_key=None,
    )
    repository.photo_counts[created.id] = 2

    with pytest.raises(ApiError) as exc_info:
        service.publish_work_card(
            current_user=current_user,
            work_card_id=created.id,
        )

    assert exc_info.value.code == ErrorCode.MINIMUM_PHOTOS_REQUIRED
    assert repository.cards[created.id].status == "draft"


def test_publish_materializes_search_and_completes_job_worker_profile() -> None:
    service, repository, profile_service, current_user = make_service()
    category_id, work_name_id, product_id = add_mapped_taxonomy(repository)
    created = service.create_work_card(
        current_user=current_user,
        payload=WorkCardUpsertRequest(
            category_id=category_id,
            work_name_id=work_name_id,
            product_type_ids=[product_id],
            description="Clean flat hemming for dupattas.",
            experience_years=7,
        ),
        idempotency_key=None,
    )
    repository.photo_counts[created.id] = 3

    published = service.publish_work_card(
        current_user=current_user,
        work_card_id=created.id,
    )

    card = repository.cards[created.id]
    assert published.status == "published"
    assert published.photo_count == 3
    assert "flat hemming" in (card.search_text or "")
    assert "dupatta" in (card.search_text or "")
    assert "silai" in (card.search_text or "")
    assert card.ranking_score == Decimal("4.5")
    assert repository.context.profile.visibility_status == "public"
    assert profile_service.refreshed[-1] == repository.context.profile.id


def test_pending_verification_locks_work_card_mutations() -> None:
    service, repository, _, current_user = make_service()
    repository.context.profile.verification_status = "pending"

    with pytest.raises(ApiError) as exc_info:
        service.create_work_card(
            current_user=current_user,
            payload=WorkCardUpsertRequest(),
            idempotency_key=None,
        )

    assert exc_info.value.code == ErrorCode.VERIFICATION_PENDING_LOCKED


def test_inactive_mapped_category_still_displays_but_cannot_be_published() -> None:
    service, repository, _, current_user = make_service()
    category_id, work_name_id, product_id = add_mapped_taxonomy(repository)
    created = service.create_work_card(
        current_user=current_user,
        payload=WorkCardUpsertRequest(
            category_id=category_id,
            work_name_id=work_name_id,
            product_type_ids=[product_id],
            description="Clean flat hemming for dupattas.",
        ),
        idempotency_key=None,
    )
    repository.photo_counts[created.id] = 3
    repository.categories[work_name_id].is_active = False

    listed = service.list_owner_work_cards(current_user)
    with pytest.raises(ApiError) as exc_info:
        service.publish_work_card(
            current_user=current_user,
            work_card_id=created.id,
        )

    assert listed.items[0].work_name == "Flat hemming"
    assert exc_info.value.code == ErrorCode.VALIDATION_FAILED

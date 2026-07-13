from datetime import datetime, timezone
from decimal import Decimal
from uuid import uuid4

import pytest

from app.core.auth_context import CurrentUser
from app.core.errors import ApiError, ErrorCode
from app.db.models.identity import User
from app.db.models.marketplace import WorkNeededPostProductType
from app.db.models.profile import Profile
from app.db.models.taxonomy import Category
from app.modules.work_needed_posts.repository import OwnerWorkNeededContext
from app.modules.work_needed_posts.repository import WorkNeededPostBundle
from app.modules.work_needed_posts.schemas import WorkNeededPostUpsertRequest
from app.modules.work_needed_posts.service import WorkNeededPostService


class FakeWorkNeededPostRepository:
    def __init__(self, context: OwnerWorkNeededContext) -> None:
        self.context = context
        self.posts: dict = {}
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
            self.hydrate_post(context=self.context, post=post)
            for post in self.posts.values()
            if post.status != "deleted"
        ]

    def get_owned_bundle(
        self,
        *,
        user_id,
        post_id,
        for_update=False,
        include_deleted=False,
    ):
        post = self.posts.get(post_id)
        if user_id != self.context.user.id or post is None:
            return None
        if not include_deleted and post.status == "deleted":
            return None
        return self.hydrate_post(context=self.context, post=post)

    def get_by_creation_key(self, *, profile_id, idempotency_key):
        return next(
            (
                post
                for post in self.posts.values()
                if post.profile_id == profile_id
                and post.creation_idempotency_key == idempotency_key
            ),
            None,
        )

    def hydrate_post(self, *, context, post):
        category_ids = {
            category_id
            for category_id in (post.work_category_id, post.work_name_category_id)
            if category_id is not None
        }
        category_ids.update(
            item.product_type_category_id
            for item in self.products.get(post.id, [])
            if item.product_type_category_id is not None
        )
        return WorkNeededPostBundle(
            context=context,
            post=post,
            product_types=self.products.get(post.id, []),
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
            and self.categories[category_id].is_active
        }

    def get_categories(self, category_ids):
        return {
            category_id: self.categories[category_id]
            for category_id in category_ids
            if category_id in self.categories
        }

    def category_aliases(self, category_ids):
        return ["silai"] if category_ids else []

    def replace_product_types(self, *, post_id, category_ids, custom_values):
        self.products[post_id] = [
            WorkNeededPostProductType(
                id=uuid4(),
                work_needed_post_id=post_id,
                product_type_category_id=category_id,
                created_at=datetime.now(timezone.utc),
            )
            for category_id in category_ids
        ] + [
            WorkNeededPostProductType(
                id=uuid4(),
                work_needed_post_id=post_id,
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
        post_id,
        suggestions,
    ):
        self.suggestions[post_id] = suggestions

    def ready_public_photo_count(self, post_id):
        return self.photo_counts.get(post_id, 0)

    def set_search_vector(self, post, search_text):
        post.search_vector = search_text

    def add(self, post):
        post.id = uuid4()
        now = datetime.now(timezone.utc)
        post.created_at = now
        post.updated_at = now
        post.photo_count = 0
        post.ranking_score = Decimal("0")
        self.posts[post.id] = post

    def flush(self):
        return None

    def commit(self):
        self.commits += 1

    def rollback(self):
        return None

    @staticmethod
    def safe_media_name(media):
        return "needed-work.jpg"


def make_service(*, role: str = "business"):
    user_id = uuid4()
    now = datetime.now(timezone.utc)
    user = User(
        id=user_id,
        auth_user_id=uuid4(),
        display_name="Aayush",
        primary_mobile="+919999999999",
        account_status="active",
        role=role,
        profile_completed_at=now,
    )
    profile = Profile(
        id=uuid4(),
        owner_user_id=user_id,
        role=role,
        public_name="Surat Dupatta House",
        visibility_status="public",
        verification_status="unverified",
        completion_score=100,
        completion_flags={},
        photo_count=3,
        ranking_score=Decimal("0"),
        is_verified=False,
        reverification_required=False,
    )
    context = OwnerWorkNeededContext(user=user, profile=profile)
    repository = FakeWorkNeededPostRepository(context)
    service = WorkNeededPostService(
        repository=repository,
        public_media_url=lambda path: f"https://storage.test/{path}",
    )
    current_user = CurrentUser(
        user_id=user_id,
        auth_user_id=user.auth_user_id,
        mobile=user.primary_mobile,
        role=role,
        account_status="active",
    )
    return service, repository, current_user


def add_mapped_taxonomy(repository: FakeWorkNeededPostRepository):
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


def create_complete_draft(service, repository, current_user):
    category_id, work_name_id, product_id = add_mapped_taxonomy(repository)
    created = service.create_post(
        current_user=current_user,
        payload=WorkNeededPostUpsertRequest(
            category_id=category_id,
            work_name_id=work_name_id,
            product_type_ids=[product_id],
            description="Need clean flat hemming for dupattas.",
        ),
        idempotency_key=None,
    )
    repository.photo_counts[created.id] = 3
    return created


def test_create_is_idempotent_and_records_custom_taxonomy_suggestions() -> None:
    service, repository, current_user = make_service()
    payload = WorkNeededPostUpsertRequest(
        custom_category_text="Local stitching",
        custom_work_name="Patli silai",
        custom_product_texts=["Dupatta"],
        description="Need clean edge finishing.",
    )

    first = service.create_post(
        current_user=current_user,
        payload=payload,
        idempotency_key="work-needed-1",
    )
    second = service.create_post(
        current_user=current_user,
        payload=payload,
        idempotency_key="work-needed-1",
    )

    assert first.id == second.id
    assert len(repository.posts) == 1
    assert repository.suggestions[first.id]["work_name"] == [
        ("Patli silai", "patli silai")
    ]


def test_creation_key_cannot_be_reused_with_different_details() -> None:
    service, _, current_user = make_service()
    service.create_post(
        current_user=current_user,
        payload=WorkNeededPostUpsertRequest(custom_work_name="Flat hemming"),
        idempotency_key="same-key",
    )

    with pytest.raises(ApiError) as exc_info:
        service.create_post(
            current_user=current_user,
            payload=WorkNeededPostUpsertRequest(custom_work_name="Embroidery"),
            idempotency_key="same-key",
        )

    assert exc_info.value.code == ErrorCode.VALIDATION_FAILED


def test_publish_requires_complete_details_and_three_ready_photos() -> None:
    service, repository, current_user = make_service()
    created = create_complete_draft(service, repository, current_user)
    repository.photo_counts[created.id] = 2

    with pytest.raises(ApiError) as exc_info:
        service.publish_post(
            current_user=current_user,
            post_id=created.id,
            idempotency_key="publish-1",
        )

    assert exc_info.value.code == ErrorCode.MINIMUM_PHOTOS_REQUIRED
    assert repository.posts[created.id].status == "draft"


def test_publish_materializes_search_and_is_idempotent() -> None:
    service, repository, current_user = make_service()
    created = create_complete_draft(service, repository, current_user)

    first = service.publish_post(
        current_user=current_user,
        post_id=created.id,
        idempotency_key="publish-1",
    )
    second = service.publish_post(
        current_user=current_user,
        post_id=created.id,
        idempotency_key="publish-1",
    )

    post = repository.posts[created.id]
    assert first.status == second.status == "active"
    assert first.photo_count == 3
    assert "flat hemming" in (post.search_text or "")
    assert "dupatta" in (post.search_text or "")
    assert "silai" in (post.search_text or "")
    assert post.ranking_score == Decimal("4")


def test_active_post_can_pause_resume_and_close_idempotently() -> None:
    service, repository, current_user = make_service()
    created = create_complete_draft(service, repository, current_user)
    service.publish_post(
        current_user=current_user,
        post_id=created.id,
        idempotency_key=None,
    )

    paused = service.pause_post(current_user=current_user, post_id=created.id)
    resumed = service.resume_post(current_user=current_user, post_id=created.id)
    closed = service.close_post(
        current_user=current_user,
        post_id=created.id,
        idempotency_key="close-1",
    )
    closed_again = service.close_post(
        current_user=current_user,
        post_id=created.id,
        idempotency_key="close-1",
    )

    assert paused.status == "paused"
    assert resumed.status == "active"
    assert closed.status == closed_again.status == "closed_by_user"
    assert repository.posts[created.id].closed_at is not None


def test_active_post_cannot_clear_required_fields() -> None:
    service, repository, current_user = make_service()
    created = create_complete_draft(service, repository, current_user)
    service.publish_post(
        current_user=current_user,
        post_id=created.id,
        idempotency_key=None,
    )

    with pytest.raises(ApiError) as exc_info:
        service.update_post(
            current_user=current_user,
            post_id=created.id,
            payload=WorkNeededPostUpsertRequest(description=None),
        )

    assert exc_info.value.code == ErrorCode.VALIDATION_FAILED
    assert repository.posts[created.id].status == "active"
    assert repository.posts[created.id].description is not None


def test_draft_cannot_be_paused_or_closed() -> None:
    service, repository, current_user = make_service()
    created = create_complete_draft(service, repository, current_user)

    with pytest.raises(ApiError):
        service.pause_post(current_user=current_user, post_id=created.id)
    with pytest.raises(ApiError):
        service.close_post(
            current_user=current_user,
            post_id=created.id,
            idempotency_key=None,
        )


def test_pending_verification_and_wrong_role_block_mutations() -> None:
    service, repository, current_user = make_service()
    repository.context.profile.verification_status = "pending"

    with pytest.raises(ApiError) as pending_error:
        service.create_post(
            current_user=current_user,
            payload=WorkNeededPostUpsertRequest(),
            idempotency_key=None,
        )
    assert pending_error.value.code == ErrorCode.VERIFICATION_PENDING_LOCKED

    wrong_service, _, wrong_user = make_service(role="job_worker")
    with pytest.raises(ApiError) as role_error:
        wrong_service.create_post(
            current_user=wrong_user,
            payload=WorkNeededPostUpsertRequest(),
            idempotency_key=None,
        )
    assert role_error.value.code == ErrorCode.FORBIDDEN


def test_delete_is_soft_and_excluded_from_owner_list() -> None:
    service, repository, current_user = make_service()
    created = create_complete_draft(service, repository, current_user)

    service.delete_post(current_user=current_user, post_id=created.id)
    service.delete_post(current_user=current_user, post_id=created.id)

    post = repository.posts[created.id]
    assert post.status == "deleted"
    assert post.deleted_at is not None
    assert service.list_owner_posts(current_user).items == []

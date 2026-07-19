from datetime import datetime, timezone
from types import SimpleNamespace
from uuid import uuid4

import pytest

from app.core.auth_context import CurrentUser
from app.core.errors import ApiError, ErrorCode
from app.modules.profiles.repository import CompletionEvidence, OwnerProfileBundle
from app.modules.profiles.schemas import ProfileUpdateRequest
from app.modules.profiles.service import ProfileService


class FakeProfileRepository:
    def __init__(
        self, bundle: OwnerProfileBundle, evidence: CompletionEvidence
    ) -> None:
        self.bundle = bundle
        self.evidence = evidence
        self.commits = 0
        self.histories: list[dict] = []
        self.suggestions: list[str] = []
        self.business_category_suggestions: list[str] = []
        self.skill_suggestions: list[str] = []

    def get_owner_bundle(self, user_id, *, for_update=False):
        return self.bundle if self.bundle.user.id == user_id else None

    def completion_evidence(self, profile):
        return self.evidence

    def category_ids_are_valid(self, category_ids, *, allowed_types):
        return True

    def get_categories(self, category_ids):
        return {
            category_id: SimpleNamespace(name="Mapped category")
            for category_id in category_ids
        }

    def category_aliases(self, category_ids):
        return []

    @staticmethod
    def set_search_vector(profile, search_text):
        profile.search_vector = search_text

    def replace_business_product_types(
        self,
        *,
        profile_id,
        category_ids,
        custom_values,
    ):
        self.bundle.product_types = [
            SimpleNamespace(
                product_type_category_id=category_id,
                custom_product_type_text=None,
            )
            for category_id in category_ids
        ] + [
            SimpleNamespace(
                product_type_category_id=None,
                custom_product_type_text=value,
            )
            for value in custom_values
        ]
        self.evidence.business_product_type_count = len(self.bundle.product_types)

    def create_product_type_suggestions(
        self,
        *,
        user_id,
        profile_id,
        values,
    ):
        self.suggestions.extend(values)

    def create_business_category_suggestion(
        self,
        *,
        user_id,
        profile_id,
        value,
    ):
        self.business_category_suggestions.append(value)

    def replace_skilled_worker_skills(
        self,
        *,
        profile_id,
        category_ids,
        custom_values,
    ):
        self.bundle.skills = [
            SimpleNamespace(
                skill_category_id=category_id,
                custom_skill_text=None,
            )
            for category_id in category_ids
        ] + [
            SimpleNamespace(
                skill_category_id=None,
                custom_skill_text=value,
            )
            for value in custom_values
        ]

    def create_skill_suggestions(
        self,
        *,
        user_id,
        profile_id,
        values,
    ):
        self.skill_suggestions.extend(values)

    def add_change_history(self, **values):
        self.histories.append(values)

    @staticmethod
    def safe_media_name(media):
        return "photo.jpg"

    def flush(self):
        return None

    def commit(self):
        self.commits += 1


def make_bundle(role: str) -> OwnerProfileBundle:
    user = SimpleNamespace(
        id=uuid4(),
        primary_mobile="+919999999999",
        account_status="active",
        profile_completed_at=None,
    )
    profile = SimpleNamespace(
        id=uuid4(),
        role=role,
        public_name="Aayush",
        owner_name="Aayush",
        alternate_contact_number=None,
        full_address="Ring Road, Surat",
        address_line1="Ring Road",
        address_line2=None,
        locality="Ring Road",
        city="Surat",
        state="Gujarat",
        pincode="395002",
        state_id=None,
        district_id=None,
        location_validation_status="valid",
        location_validated_at=None,
        visibility_status="draft",
        verification_status="unverified",
        completion_score=0,
        completion_flags={},
        photo_count=0,
        is_verified=False,
        reverification_required=False,
        last_activity_at=None,
    )
    skills = []
    if role == "business":
        role_profile = SimpleNamespace(
            business_name="Connect Textiles",
            business_category_id=uuid4(),
            custom_business_category=None,
            manufacture_sell_details="Dupattas",
            product_notes=None,
        )
    elif role == "job_worker":
        role_profile = SimpleNamespace(
            workshop_name="Aayush Hemming",
            has_workshop=True,
            work_summary="Flat hemming",
            profile_experience_years=4,
        )
    else:
        skill_id = uuid4()
        role_profile = SimpleNamespace(
            primary_skill_category_id=skill_id,
            skill_mastery="Zari hand work",
            experience_years=3,
            bio=None,
        )
        skills = [
            SimpleNamespace(
                skill_category_id=skill_id,
                custom_skill_text=None,
            )
        ]
    return OwnerProfileBundle(
        user=user,
        profile=profile,
        role_profile=role_profile,
        product_types=[],
        skills=skills,
        media=[],
    )


def make_service(
    role: str,
    *,
    photos: int = 3,
    products: int = 0,
    work_cards: int = 0,
) -> tuple[ProfileService, FakeProfileRepository, CurrentUser]:
    bundle = make_bundle(role)
    repository = FakeProfileRepository(
        bundle,
        CompletionEvidence(
            public_photo_count=photos,
            required_profile_photo_count=photos,
            business_product_type_count=products,
            published_valid_work_card_count=work_cards,
        ),
    )
    service = ProfileService(repository)
    current_user = CurrentUser(
        user_id=bundle.user.id,
        auth_user_id=uuid4(),
        mobile=bundle.user.primary_mobile,
        role=role,
        account_status="active",
    )
    return service, repository, current_user


def test_business_completion_requires_product_type_and_three_shop_photos() -> None:
    service, repository, current_user = make_service("business", photos=2, products=0)

    with pytest.raises(ApiError) as exc_info:
        service.complete_owner_profile(current_user)

    assert exc_info.value.code == ErrorCode.PROFILE_INCOMPLETE
    assert set(exc_info.value.details["missing_fields"]) == {
        "product_type",
        "shop_photos",
    }
    assert repository.bundle.profile.visibility_status == "draft"


def test_complete_business_profile_publishes_and_locks_owner_name() -> None:
    service, repository, current_user = make_service("business", photos=3, products=1)

    response = service.complete_owner_profile(current_user)

    assert response.profile.completion_score == 100
    assert response.profile.visibility_status == "public"
    assert repository.bundle.user.profile_completed_at is not None
    assert "owner_name" in response.locked_fields
    assert "connect textiles" in repository.bundle.profile.search_text
    assert "mapped category" in repository.bundle.profile.search_text


def test_owner_profile_returns_url_only_for_ready_public_media() -> None:
    service, repository, current_user = make_service("business", products=1)
    repository.bundle.media = [
        SimpleNamespace(
            id=uuid4(),
            media_kind="image",
            visibility="public",
            upload_status="ready",
            sort_order=0,
            document_type="shop_photo",
            original_path="profile/profile-id/photo.jpg",
            thumbnail_path="profile/profile-id/photo-thumbnail.jpg",
        ),
        SimpleNamespace(
            id=uuid4(),
            media_kind="image",
            visibility="public",
            upload_status="failed",
            sort_order=1,
            document_type="shop_photo",
            original_path="staging/photo.jpg",
            thumbnail_path=None,
        ),
    ]
    service.public_media_url = lambda path: f"https://media.test/{path}"

    response = service.get_owner_profile(current_user)

    assert response.media[0].url == ("https://media.test/profile/profile-id/photo.jpg")
    assert response.media[0].thumbnail_url == (
        "https://media.test/profile/profile-id/photo-thumbnail.jpg"
    )
    assert response.media[1].url is None


def test_job_worker_cannot_reach_complete_without_published_valid_work_card() -> None:
    service, repository, current_user = make_service(
        "job_worker", photos=3, work_cards=0
    )

    response = service.get_owner_profile(current_user)
    assert response.profile.completion_score < 100
    assert response.profile.completion_flags["published_work_card"] is False

    with pytest.raises(ApiError) as exc_info:
        service.complete_owner_profile(current_user)
    assert exc_info.value.code == ErrorCode.PROFILE_INCOMPLETE

    repository.evidence.published_valid_work_card_count = 1
    completed = service.complete_owner_profile(current_user)
    assert completed.profile.completion_score == 100
    assert completed.profile.visibility_status == "public"


def test_skilled_worker_zero_years_is_valid_only_after_value_is_provided() -> None:
    service, repository, current_user = make_service("skilled_worker", photos=0)
    repository.bundle.role_profile.experience_years = None

    before = service.get_owner_profile(current_user)
    assert before.profile.completion_flags["experience"] is False

    after = service.update_owner_profile(
        current_user=current_user,
        payload=ProfileUpdateRequest(experience_years=0),
    )
    assert after.profile.completion_flags["experience"] is True
    assert after.profile.completion_score == 100


def test_empty_skill_detail_is_saved_as_an_incomplete_draft() -> None:
    service, repository, current_user = make_service("skilled_worker", photos=0)

    response = service.update_owner_profile(
        current_user=current_user,
        payload=ProfileUpdateRequest(skill_mastery=None),
    )

    assert repository.bundle.role_profile.skill_mastery == ""
    assert response.profile.completion_flags["skill_mastery"] is False
    assert response.profile.completion_score < 100


def test_multiple_skills_and_custom_skill_are_saved_and_searchable() -> None:
    service, repository, current_user = make_service("skilled_worker", photos=0)
    first_skill_id = uuid4()
    second_skill_id = uuid4()

    response = service.update_owner_profile(
        current_user=current_user,
        payload=ProfileUpdateRequest(
            skill_category_ids=[first_skill_id, second_skill_id],
            custom_skills=["Mirror finishing"],
        ),
    )

    assert [item.skill_category_id for item in repository.bundle.skills] == [
        first_skill_id,
        second_skill_id,
        None,
    ]
    assert repository.bundle.skills[-1].custom_skill_text == "Mirror finishing"
    assert repository.skill_suggestions == ["Mirror finishing"]
    assert response.profile.completion_flags["skills"] is True
    assert response.role_specific["skills"] == [
        "Mapped category",
        "Mapped category",
        "Mirror finishing",
    ]
    assert "mirror finishing" in repository.bundle.profile.search_text


def test_pending_verification_locks_profile_edits() -> None:
    service, repository, current_user = make_service("job_worker")
    repository.bundle.profile.verification_status = "pending"

    with pytest.raises(ApiError) as exc_info:
        service.update_owner_profile(
            current_user=current_user,
            payload=ProfileUpdateRequest(work_summary="Updated"),
        )

    assert exc_info.value.code == ErrorCode.VERIFICATION_PENDING_LOCKED
    assert not repository.histories


def test_completed_profile_rejects_owner_name_change() -> None:
    service, repository, current_user = make_service("business", products=1)
    repository.bundle.user.profile_completed_at = datetime.now(timezone.utc)

    with pytest.raises(ApiError) as exc_info:
        service.update_owner_profile(
            current_user=current_user,
            payload=ProfileUpdateRequest(owner_name="Another Owner"),
        )

    assert exc_info.value.code == ErrorCode.FORBIDDEN
    assert repository.bundle.profile.owner_name == "Aayush"


def test_sensitive_edit_removes_verification_and_writes_change_history() -> None:
    service, repository, current_user = make_service("business", products=1)
    repository.bundle.profile.visibility_status = "public"
    repository.bundle.profile.verification_status = "verified"
    repository.bundle.profile.is_verified = True

    response = service.update_owner_profile(
        current_user=current_user,
        payload=ProfileUpdateRequest(locality="New Textile Market"),
    )

    assert response.profile.verification_status == "unverified"
    assert response.profile.is_verified is False
    assert response.profile.reverification_required is True
    assert repository.bundle.profile.normalized_locality == "new textile market"
    assert repository.histories[0]["requires_reverification"] is True


def test_hide_and_show_change_discovery_visibility_only_when_complete() -> None:
    service, repository, current_user = make_service(
        "job_worker", photos=3, work_cards=1
    )
    repository.bundle.profile.visibility_status = "public"

    hidden = service.hide_owner_profile(current_user)
    assert hidden.profile.visibility_status == "hidden_by_user"

    shown = service.show_owner_profile(current_user)
    assert shown.profile.visibility_status == "public"

    repository.evidence.published_valid_work_card_count = 0
    service.hide_owner_profile(current_user)
    with pytest.raises(ApiError) as exc_info:
        service.show_owner_profile(current_user)
    assert exc_info.value.code == ErrorCode.PROFILE_INCOMPLETE


def test_role_specific_payload_rejects_fields_from_another_role() -> None:
    service, _, current_user = make_service("skilled_worker")

    with pytest.raises(ApiError) as exc_info:
        service.update_owner_profile(
            current_user=current_user,
            payload=ProfileUpdateRequest(business_name="Not allowed"),
        )

    assert exc_info.value.code == ErrorCode.VALIDATION_FAILED
    assert "business_name" in exc_info.value.field_errors


def test_custom_business_product_creates_mapping_suggestion() -> None:
    service, repository, current_user = make_service("business", products=0)

    response = service.update_owner_profile(
        current_user=current_user,
        payload=ProfileUpdateRequest(custom_product_types=["New Dupatta Style"]),
    )

    assert repository.suggestions == ["New Dupatta Style"]
    assert response.profile.completion_flags["product_type"] is True


def test_custom_business_category_is_saved_and_searchable() -> None:
    service, repository, current_user = make_service("business", products=1)

    response = service.update_owner_profile(
        current_user=current_user,
        payload=ProfileUpdateRequest(custom_business_category="Dupatta exporter"),
    )

    assert repository.bundle.role_profile.custom_business_category == (
        "Dupatta exporter"
    )
    assert repository.business_category_suggestions == ["Dupatta exporter"]
    assert response.role_specific["custom_business_category"] == ("Dupatta exporter")
    assert "dupatta exporter" in repository.bundle.profile.search_text

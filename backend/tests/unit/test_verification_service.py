from types import SimpleNamespace
from uuid import uuid4

import pytest

from app.core.auth_context import CurrentUser
from app.core.errors import ApiError, ErrorCode
from app.modules.verification.schemas import VerificationSubmitRequest
from app.modules.verification.service import VerificationService


class FakeVerificationRepository:
    def __init__(self) -> None:
        self.profile = SimpleNamespace(
            id=uuid4(),
            owner_user_id=uuid4(),
            completion_score=100,
            verification_status="unverified",
            is_verified=False,
            reverification_required=False,
        )
        self.case = None
        self.case_checks = []
        self.documents = []
        self.notifications = []
        self.commits = 0

    def owner_profile(self, user_id, *, for_update=False):
        return self.profile if user_id == self.profile.owner_user_id else None

    def active_case(self, profile_id, *, for_update=False):
        if self.case and self.case.status in {
            "draft",
            "pending_review",
            "changes_requested",
        }:
            return self.case
        return None

    def latest_case(self, profile_id):
        return self.case

    def case_for_owner(self, case_id, user_id):
        if (
            self.case
            and self.case.id == case_id
            and user_id == self.profile.owner_user_id
        ):
            return self.case
        return None

    def checks(self, case_id):
        return self.case_checks

    def private_documents(self, case_id):
        return self.documents

    def add_case(self, case):
        case.id = uuid4()
        self.case = case

    def add_checks(self, checks):
        for check in checks:
            check.id = uuid4()
        self.case_checks = checks

    def add_notification(self, notification):
        self.notifications.append(notification)

    def flush(self):
        return None

    def commit(self):
        self.commits += 1


def make_service():
    repository = FakeVerificationRepository()
    current_user = CurrentUser(
        user_id=repository.profile.owner_user_id,
        auth_user_id=uuid4(),
        mobile="+919999999999",
        role="business",
        account_status="active",
    )
    return VerificationService(repository), repository, current_user


def test_submit_creates_pending_case_and_locks_profile() -> None:
    service, repository, current_user = make_service()

    response = service.submit(
        current_user=current_user,
        payload=VerificationSubmitRequest(),
    )

    assert response.verification_status == "pending"
    assert response.case_status == "pending_review"
    assert repository.profile.is_verified is False
    assert repository.notifications[0].notification_type == "verification_submitted"
    assert {check.check_type for check in repository.case_checks} == {
        "profile_details",
        "mobile",
        "shop_or_workplace_photos",
        "identity_proof",
        "gst_proof",
        "admin_final_review",
    }


def test_private_document_requires_explicit_consent() -> None:
    service, repository, current_user = make_service()
    prepared = service.prepare(current_user)
    repository.documents = [
        SimpleNamespace(
            id=uuid4(),
            document_type="identity_proof",
            upload_status="ready",
        )
    ]

    with pytest.raises(ApiError) as exc_info:
        service.submit(
            current_user=current_user,
            payload=VerificationSubmitRequest(),
        )

    assert prepared.case_status == "draft"
    assert exc_info.value.code == ErrorCode.VALIDATION_FAILED


def test_changes_requested_case_resubmits_same_case() -> None:
    service, repository, current_user = make_service()
    service.prepare(current_user)
    repository.case.status = "changes_requested"
    repository.case.resubmission_count = 0
    repository.case.notes_to_user = "Add a clear workplace photo."
    repository.profile.verification_status = "changes_requested"

    response = service.resubmit(
        current_user=current_user,
        payload=VerificationSubmitRequest(),
    )

    assert response.active_case_id == repository.case.id
    assert repository.case.resubmission_count == 1
    assert repository.case.status == "pending_review"


def test_incomplete_profile_cannot_prepare_verification() -> None:
    service, repository, current_user = make_service()
    repository.profile.completion_score = 80

    with pytest.raises(ApiError) as exc_info:
        service.prepare(current_user)

    assert exc_info.value.code == ErrorCode.PROFILE_INCOMPLETE

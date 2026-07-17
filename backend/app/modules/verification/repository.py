from uuid import UUID

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.db.models.cross_cutting import MediaAsset, Notification
from app.db.models.cross_cutting import VerificationCase, VerificationCheck
from app.db.models.profile import Profile


ACTIVE_CASE_STATUSES = ("draft", "pending_review", "changes_requested")


class VerificationRepository:
    def __init__(self, session: Session) -> None:
        self.session = session

    def owner_profile(
        self, user_id: UUID, *, for_update: bool = False
    ) -> Profile | None:
        statement = select(Profile).where(
            Profile.owner_user_id == user_id,
            Profile.deleted_at.is_(None),
        )
        if for_update:
            statement = statement.with_for_update()
        return self.session.scalar(statement)

    def active_case(
        self,
        profile_id: UUID,
        *,
        for_update: bool = False,
    ) -> VerificationCase | None:
        statement = (
            select(VerificationCase)
            .where(
                VerificationCase.profile_id == profile_id,
                VerificationCase.status.in_(ACTIVE_CASE_STATUSES),
            )
            .order_by(VerificationCase.created_at.desc())
        )
        if for_update:
            statement = statement.with_for_update()
        return self.session.scalar(statement)

    def latest_case(self, profile_id: UUID) -> VerificationCase | None:
        return self.session.scalar(
            select(VerificationCase)
            .where(VerificationCase.profile_id == profile_id)
            .order_by(VerificationCase.created_at.desc())
            .limit(1)
        )

    def case_for_owner(self, case_id: UUID, user_id: UUID) -> VerificationCase | None:
        return self.session.scalar(
            select(VerificationCase)
            .join(Profile, Profile.id == VerificationCase.profile_id)
            .where(
                VerificationCase.id == case_id,
                Profile.owner_user_id == user_id,
                Profile.deleted_at.is_(None),
            )
        )

    def checks(self, case_id: UUID) -> list[VerificationCheck]:
        return list(
            self.session.scalars(
                select(VerificationCheck)
                .where(VerificationCheck.verification_case_id == case_id)
                .order_by(VerificationCheck.created_at, VerificationCheck.check_type)
            )
        )

    def private_documents(self, case_id: UUID) -> list[MediaAsset]:
        return list(
            self.session.scalars(
                select(MediaAsset)
                .where(
                    MediaAsset.entity_type == "verification_case",
                    MediaAsset.entity_id == case_id,
                    MediaAsset.visibility == "private_admin_only",
                    MediaAsset.upload_status == "ready",
                    MediaAsset.deleted_at.is_(None),
                )
                .order_by(MediaAsset.sort_order, MediaAsset.created_at)
            )
        )

    def add_case(self, case: VerificationCase) -> None:
        self.session.add(case)

    def add_checks(self, checks: list[VerificationCheck]) -> None:
        self.session.add_all(checks)

    def add_notification(self, notification: Notification) -> None:
        self.session.add(notification)

    def flush(self) -> None:
        self.session.flush()

    def commit(self) -> None:
        self.session.commit()

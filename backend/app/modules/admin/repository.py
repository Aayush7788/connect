from dataclasses import dataclass
from uuid import UUID

from sqlalchemy import desc, func, select
from sqlalchemy.orm import Session

from app.db.models.cross_cutting import ContactActionEvent, MediaAsset, Notification
from app.db.models.cross_cutting import ProfileViewEvent, Report, SearchLog
from app.db.models.cross_cutting import VerificationCase, VerificationCheck
from app.db.models.identity import AdminAuditLog, AdminUser, User
from app.db.models.profile import Profile


@dataclass
class VerificationBundle:
    case: VerificationCase
    profile: Profile
    owner: User | None
    checks: list[VerificationCheck]
    documents: list[MediaAsset]


class AdminRepository:
    def __init__(self, session: Session) -> None:
        self.session = session

    def admin_for_user(self, user_id: UUID) -> AdminUser | None:
        return self.session.scalar(
            select(AdminUser).where(
                AdminUser.user_id == user_id,
                AdminUser.status == "active",
            )
        )

    def verification_rows(
        self,
        *,
        status: str | None,
        offset: int,
        limit: int,
    ) -> list[tuple[VerificationCase, Profile, User | None]]:
        statement = (
            select(VerificationCase, Profile, User)
            .join(Profile, Profile.id == VerificationCase.profile_id)
            .outerjoin(User, User.id == Profile.owner_user_id)
            .order_by(
                VerificationCase.submitted_at.desc().nullslast(),
                VerificationCase.created_at.desc(),
            )
            .offset(offset)
            .limit(limit)
        )
        if status is not None:
            statement = statement.where(VerificationCase.status == status)
        return [tuple(row) for row in self.session.execute(statement)]

    def verification_bundle(
        self,
        case_id: UUID,
        *,
        for_update: bool = False,
    ) -> VerificationBundle | None:
        statement = (
            select(VerificationCase, Profile, User)
            .join(Profile, Profile.id == VerificationCase.profile_id)
            .outerjoin(User, User.id == Profile.owner_user_id)
            .where(VerificationCase.id == case_id)
        )
        if for_update:
            statement = statement.with_for_update(of=(VerificationCase, Profile))
        row = self.session.execute(statement).one_or_none()
        if row is None:
            return None
        case, profile, owner = row
        checks_statement = (
            select(VerificationCheck)
            .where(VerificationCheck.verification_case_id == case_id)
            .order_by(VerificationCheck.created_at, VerificationCheck.check_type)
        )
        if for_update:
            checks_statement = checks_statement.with_for_update()
        checks = list(self.session.scalars(checks_statement))
        documents = list(
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
        return VerificationBundle(case, profile, owner, checks, documents)

    def profile_rows(
        self,
        *,
        role: str | None,
        verification_status: str | None,
        is_admin_seeded: bool | None,
        offset: int,
        limit: int,
    ) -> list[tuple[Profile, User | None]]:
        statement = (
            select(Profile, User)
            .outerjoin(User, User.id == Profile.owner_user_id)
            .where(Profile.deleted_at.is_(None))
            .order_by(Profile.created_at.desc())
            .offset(offset)
            .limit(limit)
        )
        if role is not None:
            statement = statement.where(Profile.role == role)
        if verification_status is not None:
            statement = statement.where(
                Profile.verification_status == verification_status
            )
        if is_admin_seeded is not None:
            statement = statement.where(Profile.is_admin_seeded == is_admin_seeded)
        return [tuple(row) for row in self.session.execute(statement)]

    def profile_with_owner(
        self,
        profile_id: UUID,
        *,
        for_update: bool = False,
    ) -> tuple[Profile, User | None] | None:
        statement = (
            select(Profile, User)
            .outerjoin(User, User.id == Profile.owner_user_id)
            .where(Profile.id == profile_id, Profile.deleted_at.is_(None))
        )
        if for_update:
            statement = statement.with_for_update(of=Profile)
        row = self.session.execute(statement).one_or_none()
        return tuple(row) if row is not None else None

    def add_seed_profile(self, profile: Profile, role_profile: object) -> None:
        self.session.add(profile)
        self.session.flush()
        role_profile.profile_id = profile.id
        self.session.add(role_profile)

    def report_rows(
        self,
        *,
        status: str | None,
        grouped: bool,
        offset: int,
        limit: int,
    ):
        if grouped:
            statement = (
                select(
                    Report.reported_entity_type,
                    Report.reported_entity_id,
                    Report.reason,
                    func.count(Report.id),
                    func.max(Report.created_at),
                )
                .group_by(
                    Report.reported_entity_type,
                    Report.reported_entity_id,
                    Report.reason,
                )
                .order_by(func.max(Report.created_at).desc())
                .offset(offset)
                .limit(limit)
            )
            if status is not None:
                statement = statement.where(Report.status == status)
            return list(self.session.execute(statement))
        statement = (
            select(Report)
            .order_by(Report.created_at.desc())
            .offset(offset)
            .limit(limit)
        )
        if status is not None:
            statement = statement.where(Report.status == status)
        return list(self.session.scalars(statement))

    def analytics(self) -> dict:
        contact_rows = self.session.execute(
            select(
                ContactActionEvent.action_type, func.count(ContactActionEvent.id)
            ).group_by(ContactActionEvent.action_type)
        )
        search_rows = self.session.execute(
            select(SearchLog.normalized_query, func.count(SearchLog.id).label("count"))
            .where(func.nullif(func.btrim(SearchLog.normalized_query), "").is_not(None))
            .group_by(SearchLog.normalized_query)
            .order_by(desc("count"))
            .limit(10)
        )
        return {
            "total_profiles": self.session.scalar(
                select(func.count(Profile.id)).where(Profile.deleted_at.is_(None))
            )
            or 0,
            "verified_profiles": self.session.scalar(
                select(func.count(Profile.id)).where(
                    Profile.is_verified.is_(True),
                    Profile.deleted_at.is_(None),
                )
            )
            or 0,
            "pending_verifications": self.session.scalar(
                select(func.count(VerificationCase.id)).where(
                    VerificationCase.status == "pending_review"
                )
            )
            or 0,
            "submitted_reports": self.session.scalar(
                select(func.count(Report.id)).where(Report.status == "submitted")
            )
            or 0,
            "profile_views": self.session.scalar(
                select(func.count(ProfileViewEvent.id))
            )
            or 0,
            "contact_actions": {
                str(action): int(count) for action, count in contact_rows
            },
            "top_search_terms": [
                {"term": str(term), "count": int(count)} for term, count in search_rows
            ],
        }

    def export_rows(self, dataset: str) -> tuple[list[str], list[tuple]]:
        if dataset == "profiles":
            rows = self.session.execute(
                select(
                    Profile.id,
                    Profile.role,
                    Profile.public_name,
                    Profile.visibility_status,
                    Profile.verification_status,
                    Profile.is_verified,
                    Profile.city,
                    Profile.state,
                    Profile.pincode,
                    Profile.is_admin_seeded,
                    Profile.created_at,
                ).where(Profile.deleted_at.is_(None))
            )
            return [
                "id",
                "role",
                "public_name",
                "visibility_status",
                "verification_status",
                "is_verified",
                "city",
                "state",
                "pincode",
                "is_admin_seeded",
                "created_at",
            ], list(rows)
        if dataset == "verification_cases":
            rows = self.session.execute(
                select(
                    VerificationCase.id,
                    VerificationCase.profile_id,
                    VerificationCase.case_reason,
                    VerificationCase.status,
                    VerificationCase.resubmission_count,
                    VerificationCase.submitted_at,
                    VerificationCase.reviewed_at,
                )
            )
            return [
                "id",
                "profile_id",
                "case_reason",
                "status",
                "resubmission_count",
                "submitted_at",
                "reviewed_at",
            ], list(rows)
        if dataset == "reports":
            rows = self.session.execute(
                select(
                    Report.id,
                    Report.reported_entity_type,
                    Report.reported_entity_id,
                    Report.reason,
                    Report.status,
                    Report.created_at,
                )
            )
            return [
                "id",
                "reported_entity_type",
                "reported_entity_id",
                "reason",
                "status",
                "created_at",
            ], list(rows)
        if dataset == "search_summary":
            rows = self.session.execute(
                select(
                    SearchLog.normalized_query,
                    SearchLog.target_persona,
                    func.count(SearchLog.id),
                    func.max(SearchLog.created_at),
                ).group_by(SearchLog.normalized_query, SearchLog.target_persona)
            )
            return [
                "query",
                "target_persona",
                "search_count",
                "last_searched_at",
            ], list(rows)
        rows = self.session.execute(
            select(
                ContactActionEvent.action_type,
                func.count(ContactActionEvent.id),
                func.max(ContactActionEvent.created_at),
            ).group_by(ContactActionEvent.action_type)
        )
        return ["action_type", "action_count", "last_action_at"], list(rows)

    def add_notification(self, notification: Notification) -> None:
        self.session.add(notification)

    def add_audit(self, audit: AdminAuditLog) -> None:
        self.session.add(audit)

    def flush(self) -> None:
        self.session.flush()

    def commit(self) -> None:
        self.session.commit()

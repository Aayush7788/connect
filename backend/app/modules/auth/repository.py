from datetime import datetime, timezone
from uuid import UUID

from sqlalchemy import Select, func, select
from sqlalchemy.orm import Session

from app.db.models.cross_cutting import Notification
from app.db.models.identity import User, UserAuthSession, UserDevice, UserSetting
from app.db.models.profile import BusinessProfile
from app.db.models.profile import JobWorkerProfile
from app.db.models.profile import Profile
from app.db.models.profile import SkilledWorkerProfile
from app.modules.auth.schemas import DeviceInfo


class AuthRepository:
    def __init__(self, session: Session) -> None:
        self.session = session

    def get_user_by_auth_user_id(self, auth_user_id: UUID) -> User | None:
        return self.session.scalar(
            select(User).where(
                User.auth_user_id == auth_user_id,
                User.deleted_at.is_(None),
            )
        )

    def get_user_by_mobile(self, mobile: str) -> User | None:
        return self.session.scalar(
            select(User).where(
                User.primary_mobile == mobile,
                User.account_status != "terminated",
                User.deleted_at.is_(None),
            )
        )

    def create_user_after_otp(self, *, auth_user_id: UUID, mobile: str) -> User:
        user = User(
            auth_user_id=auth_user_id,
            display_name="",
            primary_mobile=mobile,
            account_status="active",
            last_login_at=datetime.now(timezone.utc),
        )
        self.session.add(user)
        self.session.flush()
        self.session.add(UserSetting(user_id=user.id))
        return user

    def attach_auth_user_id(self, *, user: User, auth_user_id: UUID) -> None:
        user.auth_user_id = auth_user_id

    def mark_login(self, user: User) -> None:
        user.last_login_at = datetime.now(timezone.utc)

    def get_user_and_auth_session(
        self,
        *,
        auth_user_id: UUID,
        session_id: UUID,
    ) -> tuple[User | None, UserAuthSession | None]:
        row = self.session.execute(
            select(User, UserAuthSession)
            .outerjoin(
                UserAuthSession,
                (UserAuthSession.user_id == User.id)
                & (UserAuthSession.session_id == session_id),
            )
            .where(
                User.auth_user_id == auth_user_id,
                User.deleted_at.is_(None),
            )
        ).one_or_none()
        if row is None:
            return None, None
        return row[0], row[1]

    def register_auth_session(
        self,
        *,
        user: User,
        session_id: UUID,
        expires_at: datetime,
        device: DeviceInfo | None,
    ) -> UserAuthSession:
        auth_session = self.session.get(UserAuthSession, session_id)
        if auth_session is None:
            auth_session = UserAuthSession(
                session_id=session_id,
                user_id=user.id,
                device_id=device.device_id if device else None,
                status="active",
                expires_at=expires_at,
                last_seen_at=datetime.now(timezone.utc),
            )
            self.session.add(auth_session)
            return auth_session
        if auth_session.user_id != user.id or auth_session.status == "revoked":
            return auth_session
        auth_session.expires_at = expires_at
        auth_session.last_seen_at = datetime.now(timezone.utc)
        if device is not None and device.device_id is not None:
            auth_session.device_id = device.device_id
        return auth_session

    def revoke_auth_session(self, *, user_id: UUID, session_id: UUID) -> bool:
        auth_session = self.session.scalar(
            select(UserAuthSession).where(
                UserAuthSession.session_id == session_id,
                UserAuthSession.user_id == user_id,
            )
        )
        if auth_session is None:
            return False
        auth_session.status = "revoked"
        auth_session.revoked_at = datetime.now(timezone.utc)
        return True

    @staticmethod
    def extend_auth_session_expiry(
        auth_session: UserAuthSession,
        expires_at: datetime,
    ) -> bool:
        if expires_at <= auth_session.expires_at:
            return False
        auth_session.expires_at = expires_at
        auth_session.last_seen_at = datetime.now(timezone.utc)
        return True

    def update_basic_account(
        self,
        *,
        user: User,
        display_name: str,
        accepted_terms_version: str,
        accepted_privacy_version: str,
    ) -> None:
        now = datetime.now(timezone.utc)
        user.display_name = display_name
        user.accepted_terms_version = accepted_terms_version
        user.accepted_terms_at = now
        user.accepted_privacy_version = accepted_privacy_version
        user.accepted_privacy_at = now

    def upsert_device(self, *, user: User, device: DeviceInfo | None) -> None:
        if device is None or device.device_id is None:
            return

        now = datetime.now(timezone.utc)
        user_device = self.session.scalar(
            select(UserDevice).where(
                UserDevice.user_id == user.id,
                UserDevice.device_id == device.device_id,
                UserDevice.status == "active",
            )
        )
        if user_device is None:
            user_device = UserDevice(
                user_id=user.id,
                device_id=device.device_id,
                platform=device.platform,
                fcm_token=device.fcm_token,
                app_version=device.app_version,
                status="active",
                last_seen_at=now,
            )
            self.session.add(user_device)
            return

        user_device.platform = device.platform
        user_device.app_version = device.app_version
        user_device.last_seen_at = now
        if device.fcm_token is not None:
            user_device.fcm_token = device.fcm_token

    def get_profile_for_user(self, user_id: UUID) -> Profile | None:
        return self.session.scalar(
            select(Profile).where(
                Profile.owner_user_id == user_id,
                Profile.deleted_at.is_(None),
            )
        )

    def create_profile_shell(self, *, user: User, role: str) -> Profile:
        profile = Profile(
            owner_user_id=user.id,
            role=role,
            public_name=user.display_name or None,
            owner_name=user.display_name or None,
            visibility_status="draft",
            verification_status="unverified",
            completion_score=0,
            completion_flags={},
            photo_count=0,
            is_verified=False,
            ranking_score=0,
        )
        self.session.add(profile)
        self.session.flush()

        if role == "business":
            self.session.add(
                BusinessProfile(
                    profile_id=profile.id,
                    business_name="",
                    manufacture_sell_details="",
                )
            )
        elif role == "job_worker":
            self.session.add(JobWorkerProfile(profile_id=profile.id))
        elif role == "skilled_worker":
            self.session.add(
                SkilledWorkerProfile(
                    profile_id=profile.id,
                    skill_mastery="",
                    experience_years=None,
                )
            )
        return profile

    def unread_notification_count(self, user_id: UUID) -> int:
        count_statement: Select[tuple[int]] = select(func.count(Notification.id)).where(
            Notification.user_id == user_id,
            Notification.read_at.is_(None),
        )
        return int(self.session.scalar(count_statement) or 0)

    def get_me_snapshot(self, user_id: UUID) -> tuple[User, Profile | None, int] | None:
        unread_count = (
            select(func.count(Notification.id))
            .where(
                Notification.user_id == User.id,
                Notification.read_at.is_(None),
            )
            .correlate(User)
            .scalar_subquery()
        )
        row = self.session.execute(
            select(User, Profile, unread_count.label("unread_count"))
            .outerjoin(
                Profile,
                (Profile.owner_user_id == User.id) & (Profile.deleted_at.is_(None)),
            )
            .where(User.id == user_id, User.deleted_at.is_(None))
        ).one_or_none()
        if row is None:
            return None
        return row[0], row[1], int(row[2] or 0)

    def commit(self) -> None:
        self.session.commit()

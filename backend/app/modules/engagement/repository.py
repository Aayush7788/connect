from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import PurePosixPath
from typing import Callable, cast
from uuid import UUID

from sqlalchemy import and_, func, or_, select
from sqlalchemy.orm import Session

from app.db.models.cross_cutting import ContactActionEvent, MediaAsset
from app.db.models.cross_cutting import Notification, Report, SavedItem, ShareEvent
from app.db.models.identity import User, UserDevice, UserSetting
from app.db.models.marketplace import WorkCard, WorkNeededPost
from app.db.models.profile import JobWorkerProfile, Profile, SkilledWorkerProfile
from app.modules.engagement.schemas import ProfileRole, SavedItemResponse
from app.modules.media.schemas import MediaAssetResponse
from app.modules.search.schemas import SearchResultResponse


@dataclass(frozen=True)
class SavedPage:
    items: list[SavedItemResponse]
    total: int
    consumed: int


class EngagementRepository:
    def __init__(
        self,
        session: Session,
        public_media_url: Callable[[str], str] | None = None,
    ) -> None:
        self.session = session
        self.public_media_url = public_media_url

    def target_profile(self, target_type: str, target_id: UUID) -> Profile | None:
        if target_type == "profile":
            return self.session.scalar(
                select(Profile)
                .outerjoin(User, User.id == Profile.owner_user_id)
                .where(
                    Profile.id == target_id,
                    *self._accessible_profile_conditions(),
                )
            )
        if target_type == "work_card":
            return self.session.scalar(
                select(Profile)
                .join(WorkCard, WorkCard.profile_id == Profile.id)
                .outerjoin(User, User.id == Profile.owner_user_id)
                .where(
                    WorkCard.id == target_id,
                    WorkCard.status.in_(("published", "hidden_by_user")),
                    WorkCard.deleted_at.is_(None),
                    *self._accessible_profile_conditions(),
                )
            )
        return self.session.scalar(
            select(Profile)
            .join(WorkNeededPost, WorkNeededPost.profile_id == Profile.id)
            .outerjoin(User, User.id == Profile.owner_user_id)
            .where(
                WorkNeededPost.id == target_id,
                WorkNeededPost.status.in_(("active", "paused", "closed_by_user")),
                WorkNeededPost.deleted_at.is_(None),
                *self._accessible_profile_conditions(),
            )
        )

    def saved_item(
        self,
        *,
        user_id: UUID,
        target_type: str,
        target_id: UUID,
    ) -> SavedItem | None:
        return self.session.scalar(
            select(SavedItem).where(
                SavedItem.user_id == user_id,
                SavedItem.target_type == target_type,
                SavedItem.target_id == target_id,
            )
        )

    def add_saved_item(
        self,
        *,
        user_id: UUID,
        target_type: str,
        target_id: UUID,
    ) -> SavedItem:
        saved = SavedItem(
            user_id=user_id,
            target_type=target_type,
            target_id=target_id,
        )
        self.session.add(saved)
        self.session.flush()
        return saved

    def list_saved(
        self,
        *,
        user_id: UUID,
        target_type: str | None,
        offset: int,
        limit: int,
    ) -> SavedPage:
        statement = select(SavedItem).where(SavedItem.user_id == user_id)
        if target_type is not None:
            statement = statement.where(SavedItem.target_type == target_type)
        total = int(
            self.session.scalar(
                select(func.count()).select_from(statement.subquery())
            )
            or 0
        )
        page = list(
            self.session.scalars(
                statement
                .order_by(SavedItem.created_at.desc(), SavedItem.id.desc())
                .offset(offset)
                .limit(limit)
            )
        )
        responses = []
        for saved in page:
            profile = self.target_profile(saved.target_type, saved.target_id)
            if profile is None:
                continue
            responses.append(self.saved_response(saved, profile))
        return SavedPage(
            items=responses,
            total=total,
            consumed=len(page),
        )

    def remove_saved(self, *, user_id: UUID, saved_item_id: UUID) -> bool:
        saved = self.session.scalar(
            select(SavedItem).where(
                SavedItem.id == saved_item_id,
                SavedItem.user_id == user_id,
            )
        )
        if saved is None:
            return False
        self.session.delete(saved)
        return True

    def saved_response(
        self,
        saved: SavedItem,
        profile: Profile,
    ) -> SavedItemResponse:
        return SavedItemResponse(
            id=saved.id,
            target_type=cast(str, saved.target_type),
            target_id=saved.target_id,
            profile_role=cast(ProfileRole, profile.role),
            card=self._card(saved.target_type, saved.target_id, profile),
        )

    def add_report(
        self,
        *,
        user_id: UUID,
        target_type: str,
        target_id: UUID,
        reason: str,
    ) -> Report:
        report = Report(
            reporter_user_id=user_id,
            reported_entity_type=target_type,
            reported_entity_id=target_id,
            reason=reason,
            status="submitted",
        )
        self.session.add(report)
        self.session.flush()
        return report

    def list_notifications(
        self,
        *,
        user_id: UUID,
        offset: int,
        limit: int,
    ) -> tuple[list[Notification], int]:
        statement = select(Notification).where(Notification.user_id == user_id)
        total = int(
            self.session.scalar(
                select(func.count()).select_from(statement.subquery())
            )
            or 0
        )
        items = list(
            self.session.scalars(
                statement
                .order_by(Notification.created_at.desc(), Notification.id.desc())
                .offset(offset)
                .limit(limit)
            )
        )
        return items, total

    def notification(
        self, *, user_id: UUID, notification_id: UUID
    ) -> Notification | None:
        return self.session.scalar(
            select(Notification).where(
                Notification.id == notification_id,
                Notification.user_id == user_id,
            )
        )

    def register_device(
        self,
        *,
        user_id: UUID,
        fcm_token: str,
        platform: str,
        device_id: str | None,
        app_version: str | None,
    ) -> None:
        device = self.session.scalar(
            select(UserDevice).where(UserDevice.fcm_token == fcm_token)
        )
        if device is None and device_id is not None:
            device = self.session.scalar(
                select(UserDevice).where(
                    UserDevice.user_id == user_id,
                    UserDevice.device_id == device_id,
                    UserDevice.status == "active",
                )
            )
        if device is None:
            device = UserDevice(user_id=user_id, platform=platform)
            self.session.add(device)
        device.user_id = user_id
        device.fcm_token = fcm_token
        device.device_id = device_id
        device.platform = platform
        device.app_version = app_version
        device.status = "active"
        device.last_seen_at = datetime.now(timezone.utc)

    def user_setting(self, user_id: UUID) -> UserSetting:
        setting = self.session.scalar(
            select(UserSetting).where(UserSetting.user_id == user_id)
        )
        if setting is None:
            setting = UserSetting(user_id=user_id, locale="en")
            self.session.add(setting)
            self.session.flush()
        return setting

    def owner_profile(self, user_id: UUID) -> Profile | None:
        return self.session.scalar(
            select(Profile).where(
                Profile.owner_user_id == user_id,
                Profile.deleted_at.is_(None),
            )
        )

    def add_contact_action(
        self,
        *,
        user_id: UUID,
        profile_id: UUID,
        action_type: str,
        source_type: str | None,
        source_id: UUID | None,
        ip_address: str | None,
        device_id: str | None,
        user_agent: str | None,
    ) -> None:
        self.session.add(
            ContactActionEvent(
                actor_user_id=user_id,
                target_profile_id=profile_id,
                action_type=action_type,
                source_type=source_type,
                source_id=source_id,
                ip_address=ip_address,
                device_id=device_id,
                user_agent=user_agent,
            )
        )

    def add_share(
        self,
        *,
        user_id: UUID,
        target_type: str,
        target_id: UUID,
        channel: str | None,
        ip_address: str | None,
        device_id: str | None,
        user_agent: str | None,
    ) -> None:
        self.session.add(
            ShareEvent(
                user_id=user_id,
                target_type=target_type,
                target_id=target_id,
                share_channel=channel,
                ip_address=ip_address,
                device_id=device_id,
                user_agent=user_agent,
            )
        )

    def commit(self) -> None:
        self.session.commit()

    def rollback(self) -> None:
        self.session.rollback()

    def _card(
        self,
        target_type: str,
        target_id: UUID,
        profile: Profile,
    ) -> SearchResultResponse | None:
        if target_type == "work_card":
            work = self.session.get(WorkCard, target_id)
            if work is None:
                return None
            title = work.title
            category = work.custom_work_name or work.custom_work_category_text
            description = work.description
            experience = work.experience_years
            activity = work.last_activity_at
            photo_count = work.photo_count
        elif target_type == "work_needed_post":
            post = self.session.get(WorkNeededPost, target_id)
            if post is None:
                return None
            title = post.title
            category = post.custom_work_name or post.custom_work_category_text
            description = post.description
            experience = None
            activity = post.last_activity_at
            photo_count = post.photo_count
        else:
            title = profile.public_name or "Profile"
            category = None
            description = None
            activity = profile.last_activity_at
            experience = self._profile_experience(profile)
            photo_count = profile.photo_count
        photos = self._photos(target_type, target_id)
        return SearchResultResponse(
            result_type=cast(str, target_type),
            id=target_id,
            profile_id=profile.id,
            title=title,
            subtitle=profile.public_name if target_type != "profile" else None,
            category=category,
            description=description,
            locality=profile.locality,
            experience_years=experience,
            is_verified=profile.is_verified,
            photo_count=photo_count,
            photos=photos,
            last_activity_at=activity,
        )

    def _profile_experience(self, profile: Profile) -> int | None:
        if profile.role == "job_worker":
            value = self.session.get(JobWorkerProfile, profile.id)
            return value.profile_experience_years if value else None
        if profile.role == "skilled_worker":
            value = self.session.get(SkilledWorkerProfile, profile.id)
            return value.experience_years if value else None
        return None

    def _photos(self, entity_type: str, entity_id: UUID) -> list[MediaAssetResponse]:
        assets = list(
            self.session.scalars(
                select(MediaAsset)
                .where(
                    MediaAsset.entity_type == entity_type,
                    MediaAsset.entity_id == entity_id,
                    MediaAsset.media_kind == "image",
                    MediaAsset.visibility == "public",
                    MediaAsset.upload_status == "ready",
                    MediaAsset.deleted_at.is_(None),
                )
                .order_by(MediaAsset.sort_order, MediaAsset.created_at)
                .limit(5)
            )
        )
        return [
            MediaAssetResponse(
                id=asset.id,
                media_kind="image",
                visibility="public",
                upload_status=asset.upload_status,
                url=self._public_url(asset.compressed_path or asset.original_path),
                thumbnail_url=self._public_url(asset.thumbnail_path),
                sort_order=asset.sort_order,
                document_type=asset.document_type,
                safe_display_name=PurePosixPath(asset.original_path).name,
            )
            for asset in assets
        ]

    def _public_url(self, path: str | None) -> str | None:
        if path is None or self.public_media_url is None:
            return None
        return self.public_media_url(path)

    @staticmethod
    def _accessible_profile_conditions():
        return (
            Profile.visibility_status.in_(("public", "hidden_by_user")),
            Profile.completion_score == 100,
            Profile.deleted_at.is_(None),
            or_(
                Profile.owner_user_id.is_(None),
                and_(User.account_status == "active", User.deleted_at.is_(None)),
            ),
        )

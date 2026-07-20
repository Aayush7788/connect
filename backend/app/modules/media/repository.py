from dataclasses import dataclass
from uuid import UUID

from sqlalchemy import func, select
from sqlalchemy.orm import Session

from app.db.models.cross_cutting import MediaAsset, VerificationCase
from app.db.models.marketplace import WorkCard, WorkNeededPost
from app.db.models.profile import Profile


@dataclass
class MediaTarget:
    entity_type: str
    entity: Profile | WorkCard | WorkNeededPost | VerificationCase
    profile: Profile


@dataclass
class OwnedMedia:
    media: MediaAsset
    target: MediaTarget


class MediaRepository:
    def __init__(self, session: Session) -> None:
        self.session = session

    def get_owned_target(
        self,
        *,
        user_id: UUID,
        entity_type: str,
        entity_id: UUID,
        for_update: bool = False,
    ) -> MediaTarget | None:
        if entity_type == "profile":
            statement = select(Profile).where(
                Profile.id == entity_id,
                Profile.owner_user_id == user_id,
                Profile.deleted_at.is_(None),
            )
            if for_update:
                statement = statement.with_for_update()
            profile = self.session.scalar(statement)
            if profile is None:
                return None
            return MediaTarget(entity_type=entity_type, entity=profile, profile=profile)

        if entity_type == "work_card":
            statement = (
                select(WorkCard, Profile)
                .join(Profile, Profile.id == WorkCard.profile_id)
                .where(
                    WorkCard.id == entity_id,
                    WorkCard.deleted_at.is_(None),
                    Profile.owner_user_id == user_id,
                    Profile.deleted_at.is_(None),
                )
            )
        elif entity_type == "work_needed_post":
            statement = (
                select(WorkNeededPost, Profile)
                .join(Profile, Profile.id == WorkNeededPost.profile_id)
                .where(
                    WorkNeededPost.id == entity_id,
                    WorkNeededPost.deleted_at.is_(None),
                    Profile.owner_user_id == user_id,
                    Profile.deleted_at.is_(None),
                )
            )
        elif entity_type == "verification_case":
            statement = (
                select(VerificationCase, Profile)
                .join(Profile, Profile.id == VerificationCase.profile_id)
                .where(
                    VerificationCase.id == entity_id,
                    Profile.owner_user_id == user_id,
                    Profile.deleted_at.is_(None),
                )
            )
        else:
            return None
        if for_update:
            statement = statement.with_for_update()
        row = self.session.execute(statement).one_or_none()
        if row is None:
            return None
        entity, profile = row
        return MediaTarget(entity_type=entity_type, entity=entity, profile=profile)

    def get_owned_media(
        self,
        *,
        user_id: UUID,
        media_asset_id: UUID,
        for_update: bool = False,
    ) -> OwnedMedia | None:
        statement = select(MediaAsset).where(
            MediaAsset.id == media_asset_id,
            MediaAsset.uploaded_by_user_id == user_id,
            MediaAsset.deleted_at.is_(None),
        )
        if for_update:
            statement = statement.with_for_update()
        media = self.session.scalar(statement)
        if media is None:
            return None
        target = self.get_owned_target(
            user_id=user_id,
            entity_type=media.entity_type,
            entity_id=media.entity_id,
            for_update=for_update,
        )
        if target is None:
            return None
        return OwnedMedia(media=media, target=target)

    def next_sort_order(self, *, entity_type: str, entity_id: UUID) -> int:
        current = self.session.scalar(
            select(func.max(MediaAsset.sort_order)).where(
                MediaAsset.entity_type == entity_type,
                MediaAsset.entity_id == entity_id,
                MediaAsset.deleted_at.is_(None),
            )
        )
        return int(current if current is not None else -1) + 1

    def ready_public_photo_count(
        self,
        *,
        entity_type: str,
        entity_id: UUID,
        document_type: str | None = None,
    ) -> int:
        statement = select(func.count(MediaAsset.id)).where(
            MediaAsset.entity_type == entity_type,
            MediaAsset.entity_id == entity_id,
            MediaAsset.media_kind == "image",
            MediaAsset.visibility == "public",
            MediaAsset.upload_status == "ready",
            MediaAsset.deleted_at.is_(None),
        )
        if document_type is not None:
            statement = statement.where(MediaAsset.document_type == document_type)
        return int(self.session.scalar(statement) or 0)

    def list_ready_public_photos(
        self,
        *,
        entity_type: str,
        entity_id: UUID,
        document_type: str,
        exclude_media_id: UUID | None = None,
    ) -> list[MediaAsset]:
        statement = select(MediaAsset).where(
            MediaAsset.entity_type == entity_type,
            MediaAsset.entity_id == entity_id,
            MediaAsset.media_kind == "image",
            MediaAsset.visibility == "public",
            MediaAsset.document_type == document_type,
            MediaAsset.upload_status == "ready",
            MediaAsset.deleted_at.is_(None),
        )
        if exclude_media_id is not None:
            statement = statement.where(MediaAsset.id != exclude_media_id)
        return list(
            self.session.scalars(
                statement.order_by(MediaAsset.sort_order, MediaAsset.created_at)
            )
        )

    def sync_target_photo_count(self, target: MediaTarget) -> None:
        if not hasattr(target.entity, "photo_count"):
            return
        target.entity.photo_count = self.ready_public_photo_count(
            entity_type=target.entity_type,
            entity_id=target.entity.id,
        )

    def add(self, media: MediaAsset) -> None:
        self.session.add(media)

    def flush(self) -> None:
        self.session.flush()

    def commit(self) -> None:
        self.session.commit()

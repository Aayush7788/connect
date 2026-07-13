import base64
from datetime import datetime, timezone
from uuid import UUID

from app.core.auth_context import CurrentUser
from app.core.errors import ApiError, ErrorCode
from app.modules.engagement.repository import EngagementRepository
from app.modules.engagement.schemas import ContactActionRequest
from app.modules.engagement.schemas import CreateReportRequest, CreateShareLinkRequest
from app.modules.engagement.schemas import NotificationResponse, NotificationsResponse
from app.modules.engagement.schemas import RegisterDeviceTokenRequest
from app.modules.engagement.schemas import ReportResponse, SavedItemsResponse
from app.modules.engagement.schemas import SaveItemRequest, SavedItemResponse
from app.modules.engagement.schemas import ShareLinkResponse
from app.modules.engagement.schemas import UpdateSettingsRequest, UserSettingsResponse


class EngagementService:
    def __init__(self, repository: EngagementRepository, share_base_url: str) -> None:
        self.repository = repository
        self.share_base_url = share_base_url.rstrip("/")

    def save_item(
        self,
        *,
        current_user: CurrentUser,
        payload: SaveItemRequest,
    ) -> SavedItemResponse:
        profile = self._target_profile(payload.target_type, payload.target_id)
        try:
            saved = self.repository.saved_item(
                user_id=current_user.user_id,
                target_type=payload.target_type,
                target_id=payload.target_id,
            )
            if saved is None:
                saved = self.repository.add_saved_item(
                    user_id=current_user.user_id,
                    target_type=payload.target_type,
                    target_id=payload.target_id,
                )
            self.repository.commit()
            return self.repository.saved_response(saved, profile)
        except Exception:
            self.repository.rollback()
            raise

    def list_saved(
        self,
        *,
        current_user: CurrentUser,
        target_type: str | None,
        cursor: str | None,
        limit: int,
    ) -> SavedItemsResponse:
        offset = self._decode_cursor(cursor)
        page = self.repository.list_saved(
            user_id=current_user.user_id,
            target_type=target_type,
            offset=offset,
            limit=limit,
        )
        next_offset = offset + page.consumed
        return SavedItemsResponse(
            items=page.items,
            next_cursor=self._encode_cursor(next_offset)
            if next_offset < page.total
            else None,
        )

    def remove_saved(
        self,
        *,
        current_user: CurrentUser,
        saved_item_id: UUID,
    ) -> None:
        try:
            self.repository.remove_saved(
                user_id=current_user.user_id,
                saved_item_id=saved_item_id,
            )
            self.repository.commit()
        except Exception:
            self.repository.rollback()
            raise

    def report(
        self,
        *,
        current_user: CurrentUser,
        payload: CreateReportRequest,
    ) -> ReportResponse:
        self._target_profile(payload.reported_entity_type, payload.reported_entity_id)
        try:
            report = self.repository.add_report(
                user_id=current_user.user_id,
                target_type=payload.reported_entity_type,
                target_id=payload.reported_entity_id,
                reason=payload.reason,
            )
            self.repository.commit()
            return ReportResponse(id=report.id, status=report.status)
        except Exception:
            self.repository.rollback()
            raise

    def notifications(
        self,
        *,
        current_user: CurrentUser,
        cursor: str | None,
        limit: int,
    ) -> NotificationsResponse:
        offset = self._decode_cursor(cursor)
        notifications, total = self.repository.list_notifications(
            user_id=current_user.user_id,
            offset=offset,
            limit=limit,
        )
        next_offset = offset + len(notifications)
        return NotificationsResponse(
            items=[self._notification(item) for item in notifications],
            next_cursor=self._encode_cursor(next_offset)
            if next_offset < total
            else None,
        )

    def mark_notification_read(
        self,
        *,
        current_user: CurrentUser,
        notification_id: UUID,
    ) -> NotificationResponse:
        notification = self.repository.notification(
            user_id=current_user.user_id,
            notification_id=notification_id,
        )
        if notification is None:
            self._not_found("Notification")
        if notification.read_at is None:
            notification.read_at = datetime.now(timezone.utc)
        try:
            self.repository.commit()
            return self._notification(notification)
        except Exception:
            self.repository.rollback()
            raise

    def register_device(
        self,
        *,
        current_user: CurrentUser,
        payload: RegisterDeviceTokenRequest,
    ) -> None:
        try:
            self.repository.register_device(
                user_id=current_user.user_id,
                fcm_token=payload.fcm_token,
                platform=payload.platform,
                device_id=payload.device_id,
                app_version=payload.app_version,
            )
            self.repository.commit()
        except Exception:
            self.repository.rollback()
            raise

    def update_settings(
        self,
        *,
        current_user: CurrentUser,
        payload: UpdateSettingsRequest,
    ) -> UserSettingsResponse:
        setting = self.repository.user_setting(current_user.user_id)
        profile = self.repository.owner_profile(current_user.user_id)
        preferences = dict(setting.notification_preferences or {})
        if payload.push_notifications_enabled is not None:
            preferences["push_notifications_enabled"] = (
                payload.push_notifications_enabled
            )
            setting.notification_preferences = preferences
        if payload.hidden_from_search is not None:
            if profile is None:
                self._not_found("Profile")
            profile.visibility_status = (
                "hidden_by_user"
                if payload.hidden_from_search
                else "public"
                if profile.completion_score == 100
                else "draft"
            )
            profile.last_activity_at = datetime.now(timezone.utc)
        try:
            self.repository.commit()
        except Exception:
            self.repository.rollback()
            raise
        return UserSettingsResponse(
            push_notifications_enabled=preferences.get(
                "push_notifications_enabled", True
            ),
            hidden_from_search=bool(
                profile and profile.visibility_status == "hidden_by_user"
            ),
        )

    def settings(self, *, current_user: CurrentUser) -> UserSettingsResponse:
        setting = self.repository.user_setting(current_user.user_id)
        profile = self.repository.owner_profile(current_user.user_id)
        preferences = dict(setting.notification_preferences or {})
        try:
            self.repository.commit()
        except Exception:
            self.repository.rollback()
            raise
        return UserSettingsResponse(
            push_notifications_enabled=preferences.get(
                "push_notifications_enabled", True
            ),
            hidden_from_search=bool(
                profile and profile.visibility_status == "hidden_by_user"
            ),
        )

    def log_contact_action(
        self,
        *,
        current_user: CurrentUser,
        payload: ContactActionRequest,
        ip_address: str | None,
        device_id: str | None,
        user_agent: str | None,
    ) -> None:
        profile = self._target_profile("profile", payload.profile_id)
        if profile.visibility_status not in {"public", "hidden_by_user"}:
            self._not_found("Profile")
        try:
            self.repository.add_contact_action(
                user_id=current_user.user_id,
                profile_id=payload.profile_id,
                action_type=payload.action_type,
                source_type=payload.source_type,
                source_id=payload.source_id,
                ip_address=ip_address,
                device_id=device_id,
                user_agent=user_agent,
            )
            self.repository.commit()
        except Exception:
            self.repository.rollback()
            raise

    def share_link(
        self,
        *,
        current_user: CurrentUser,
        payload: CreateShareLinkRequest,
        ip_address: str | None,
        device_id: str | None,
        user_agent: str | None,
    ) -> ShareLinkResponse:
        profile = self._target_profile(payload.target_type, payload.target_id)
        segment = {
            "profile": "profiles",
            "work_card": "work-cards",
            "work_needed_post": "work-needed-posts",
        }[payload.target_type]
        url = f"{self.share_base_url}/{segment}/{payload.target_id}"
        title = profile.public_name or "Textile profile"
        try:
            self.repository.add_share(
                user_id=current_user.user_id,
                target_type=payload.target_type,
                target_id=payload.target_id,
                channel=payload.channel,
                ip_address=ip_address,
                device_id=device_id,
                user_agent=user_agent,
            )
            self.repository.commit()
        except Exception:
            self.repository.rollback()
            raise
        return ShareLinkResponse(
            url=url,
            share_text=f"View {title} on Connect: {url}",
        )

    def _target_profile(self, target_type: str, target_id: UUID):
        profile = self.repository.target_profile(target_type, target_id)
        if profile is None:
            self._not_found("Profile")
        return profile

    @staticmethod
    def _notification(notification) -> NotificationResponse:
        return NotificationResponse(
            id=notification.id,
            title=notification.title,
            message=notification.message,
            created_at=notification.created_at,
            read_at=notification.read_at,
        )

    @staticmethod
    def _encode_cursor(offset: int) -> str:
        return base64.urlsafe_b64encode(str(offset).encode()).decode().rstrip("=")

    @staticmethod
    def _decode_cursor(cursor: str | None) -> int:
        if cursor is None:
            return 0
        try:
            value = int(
                base64.urlsafe_b64decode(cursor + "=" * (-len(cursor) % 4)).decode()
            )
            if value < 0:
                raise ValueError
            return value
        except (ValueError, UnicodeDecodeError):
            raise ApiError(
                status_code=422,
                code=ErrorCode.VALIDATION_FAILED,
                message="Please refresh and try again.",
                field_errors={"cursor": "This cursor is invalid or expired."},
            ) from None

    @staticmethod
    def _not_found(label: str) -> None:
        raise ApiError(
            status_code=404,
            code=ErrorCode.NOT_FOUND,
            message=f"{label} is unavailable.",
        )

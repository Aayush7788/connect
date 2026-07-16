from dataclasses import dataclass
from typing import Any, Protocol

from supabase import create_client
from storage3.exceptions import StorageApiError

from app.core.config import Settings


PUBLIC_IMAGE_MIME_TYPES = ("image/jpeg", "image/png", "image/webp")
PRIVATE_DOCUMENT_MIME_TYPES = (*PUBLIC_IMAGE_MIME_TYPES, "application/pdf")
SIGNED_UPLOAD_TTL_SECONDS = 2 * 60 * 60


class StorageObjectNotFound(Exception):
    pass


class StorageProviderError(Exception):
    pass


@dataclass(frozen=True)
class SignedUpload:
    url: str
    expires_in_seconds: int = SIGNED_UPLOAD_TTL_SECONDS


class MediaStorageGateway(Protocol):
    def create_signed_upload(self, *, bucket: str, path: str) -> SignedUpload: ...

    def object_info(self, *, bucket: str, path: str) -> dict[str, Any]: ...

    def download(self, *, bucket: str, path: str) -> bytes: ...

    def upload(
        self,
        *,
        bucket: str,
        path: str,
        content: bytes,
        mime_type: str,
    ) -> None: ...

    def remove(self, *, bucket: str, path: str) -> None: ...

    def public_url(self, *, bucket: str, path: str) -> str: ...


class SupabaseStorageGateway:
    def __init__(self, settings: Settings) -> None:
        if settings.supabase_url is None or settings.supabase_service_role_key is None:
            raise RuntimeError(
                "SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY are required for storage."
            )
        self._client = create_client(
            settings.supabase_url,
            settings.supabase_service_role_key.get_secret_value(),
        )

    def create_signed_upload(self, *, bucket: str, path: str) -> SignedUpload:
        try:
            result = self._client.storage.from_(bucket).create_signed_upload_url(path)
            return SignedUpload(url=str(result["signed_url"]))
        except StorageApiError as error:
            raise StorageProviderError("Unable to create upload URL.") from error

    def object_info(self, *, bucket: str, path: str) -> dict[str, Any]:
        try:
            return self._client.storage.from_(bucket).info(path)
        except StorageApiError as error:
            if str(error.status) == "404":
                raise StorageObjectNotFound(path) from error
            raise StorageProviderError("Unable to inspect stored object.") from error

    def download(self, *, bucket: str, path: str) -> bytes:
        try:
            return self._client.storage.from_(bucket).download(path)
        except StorageApiError as error:
            if str(error.status) == "404":
                raise StorageObjectNotFound(path) from error
            raise StorageProviderError("Unable to validate stored object.") from error

    def upload(
        self,
        *,
        bucket: str,
        path: str,
        content: bytes,
        mime_type: str,
    ) -> None:
        try:
            self._client.storage.from_(bucket).upload(
                path=path,
                file=content,
                file_options={
                    "content-type": mime_type,
                    "cache-control": "31536000",
                    "upsert": "false",
                },
            )
        except StorageApiError as error:
            raise StorageProviderError("Unable to store validated media.") from error

    def remove(self, *, bucket: str, path: str) -> None:
        try:
            self._client.storage.from_(bucket).remove([path])
        except StorageApiError as error:
            if str(error.status) == "404":
                raise StorageObjectNotFound(path) from error
            raise StorageProviderError("Unable to remove stored object.") from error

    def public_url(self, *, bucket: str, path: str) -> str:
        return self._client.storage.from_(bucket).get_public_url(path)


def ensure_storage_buckets(settings: Settings) -> None:
    gateway = SupabaseStorageGateway(settings)
    storage = gateway._client.storage
    max_bytes = settings.max_upload_mb * 1024 * 1024
    desired = {
        settings.supabase_public_media_bucket: {
            "public": True,
            "file_size_limit": max_bytes,
            "allowed_mime_types": list(PUBLIC_IMAGE_MIME_TYPES),
        },
        settings.supabase_private_verification_bucket: {
            "public": False,
            "file_size_limit": max_bytes,
            "allowed_mime_types": list(PRIVATE_DOCUMENT_MIME_TYPES),
        },
    }
    existing = {bucket.id for bucket in storage.list_buckets()}
    for bucket_id, options in desired.items():
        if bucket_id in existing:
            storage.update_bucket(bucket_id, options=options)
        else:
            storage.create_bucket(bucket_id, options=options)

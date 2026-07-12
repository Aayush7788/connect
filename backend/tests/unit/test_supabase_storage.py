from types import SimpleNamespace

from app.core.config import Settings
from app.integrations.supabase_storage import PRIVATE_DOCUMENT_MIME_TYPES
from app.integrations.supabase_storage import PUBLIC_IMAGE_MIME_TYPES
from app.integrations.supabase_storage import ensure_storage_buckets


class FakeStorageAdmin:
    def __init__(self) -> None:
        self.updated: list[tuple[str, dict]] = []
        self.created: list[tuple[str, dict]] = []

    def list_buckets(self):
        return [SimpleNamespace(id="public-media")]

    def update_bucket(self, bucket_id, *, options):
        self.updated.append((bucket_id, options))

    def create_bucket(self, bucket_id, *, options):
        self.created.append((bucket_id, options))


def test_bucket_setup_is_idempotent_and_keeps_documents_private(monkeypatch) -> None:
    storage = FakeStorageAdmin()
    client = SimpleNamespace(storage=storage)
    monkeypatch.setattr(
        "app.integrations.supabase_storage.create_client",
        lambda url, key: client,
    )
    settings = Settings(
        app_env="test",
        supabase_url="https://project.supabase.co",
        supabase_service_role_key="secret",
    )

    ensure_storage_buckets(settings)

    public_id, public_options = storage.updated[0]
    private_id, private_options = storage.created[0]
    assert public_id == "public-media"
    assert public_options["public"] is True
    assert public_options["allowed_mime_types"] == list(PUBLIC_IMAGE_MIME_TYPES)
    assert private_id == "verification-documents"
    assert private_options["public"] is False
    assert private_options["allowed_mime_types"] == list(PRIVATE_DOCUMENT_MIME_TYPES)

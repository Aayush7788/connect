import argparse
import sys
from io import BytesIO
from pathlib import Path

from PIL import Image, ImageOps
from sqlalchemy import select


REPO_ROOT = Path(__file__).resolve().parents[1]
BACKEND_DIR = REPO_ROOT / "backend"
if str(BACKEND_DIR) not in sys.path:
    sys.path.insert(0, str(BACKEND_DIR))

from app.core.config import get_settings  # noqa: E402
from app.db.models.cross_cutting import MediaAsset  # noqa: E402
from app.db.session import create_session_factory  # noqa: E402
from app.integrations.supabase_storage import SupabaseStorageGateway  # noqa: E402


def create_thumbnail(content: bytes) -> bytes:
    output = BytesIO()
    with Image.open(BytesIO(content)) as source:
        image = ImageOps.exif_transpose(source)
        image.thumbnail((480, 480), Image.Resampling.LANCZOS)
        if image.mode not in {"RGB", "L"}:
            image = image.convert("RGB")
        image.save(output, format="JPEG", quality=72, optimize=True)
    return output.getvalue()


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--apply", action="store_true")
    arguments = parser.parse_args()
    settings = get_settings()
    storage = SupabaseStorageGateway(settings)
    session_factory = create_session_factory(settings)
    with session_factory() as session:
        assets = list(
            session.scalars(
                select(MediaAsset).where(
                    MediaAsset.media_kind == "image",
                    MediaAsset.visibility == "public",
                    MediaAsset.upload_status == "ready",
                    MediaAsset.thumbnail_path.is_(None),
                    MediaAsset.deleted_at.is_(None),
                )
            )
        )
        print(f"ready_public_images_without_thumbnail={len(assets)}")
        if not arguments.apply:
            return 0
        for asset in assets:
            content = storage.download(
                bucket=settings.supabase_public_media_bucket,
                path=asset.original_path,
            )
            thumbnail_path = (
                f"{asset.entity_type}/{asset.entity_id}/{asset.id}-thumbnail.jpg"
            )
            storage.upload(
                bucket=settings.supabase_public_media_bucket,
                path=thumbnail_path,
                content=create_thumbnail(content),
                mime_type="image/jpeg",
            )
            asset.thumbnail_path = thumbnail_path
            session.commit()
            print(f"thumbnail_ready={asset.id}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

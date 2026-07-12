from pathlib import Path
import sys


ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "backend"))


def main() -> int:
    from app.core.config import Settings
    from app.integrations.supabase_storage import ensure_storage_buckets

    settings = Settings()
    ensure_storage_buckets(settings)
    print(
        "Storage buckets ready: "
        f"{settings.supabase_public_media_bucket}, "
        f"{settings.supabase_private_verification_bucket}"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

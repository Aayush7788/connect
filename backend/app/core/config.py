from functools import lru_cache
from pathlib import Path

from pydantic import Field, SecretStr
from pydantic_settings import BaseSettings, SettingsConfigDict


BACKEND_DIR = Path(__file__).resolve().parents[2]


class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        env_file=BACKEND_DIR / ".env",
        env_file_encoding="utf-8",
        extra="ignore",
    )

    app_env: str = "development"
    app_name: str = "Connect Textile Marketplace API"
    api_base_url: str = "http://127.0.0.1:8000"
    share_base_url: str = "https://connect.example"
    api_v1_prefix: str = "/v1"
    log_level: str = "info"
    enable_debug_errors: bool = False

    database_url: SecretStr | None = None
    supabase_url: str | None = None
    supabase_anon_key: SecretStr | None = None
    supabase_service_role_key: SecretStr | None = None
    supabase_jwt_secret: SecretStr | None = None
    supabase_public_media_bucket: str = "public-media"
    supabase_private_verification_bucket: str = "verification-documents"

    fcm_service_account_json_path: str | None = None
    cors_allowed_origins: str = "http://localhost:3000,http://127.0.0.1:3000"
    contact_reveal_mode: str = "free_unlimited"
    max_upload_mb: int = Field(default=10, ge=1, le=100)
    max_image_dimension: int = Field(default=12000, ge=1000, le=30000)
    max_image_pixels: int = Field(default=40_000_000, ge=1_000_000)

    @property
    def cors_origins(self) -> list[str]:
        return [
            origin.strip()
            for origin in self.cors_allowed_origins.split(",")
            if origin.strip()
        ]

    @property
    def is_development(self) -> bool:
        return self.app_env.lower() in {"development", "dev", "local", "test"}


@lru_cache
def get_settings() -> Settings:
    return Settings()

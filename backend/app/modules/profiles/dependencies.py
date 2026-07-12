from fastapi import Depends
from sqlalchemy.orm import Session

from app.db.session import get_db_session
from app.modules.profiles.repository import ProfileRepository
from app.modules.profiles.service import ProfileService


def get_profile_service(
    session: Session = Depends(get_db_session),
) -> ProfileService:
    return ProfileService(ProfileRepository(session))

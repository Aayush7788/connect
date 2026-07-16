from fastapi import Depends
from sqlalchemy.orm import Session

from app.db.session import get_db_session
from app.modules.locations.repository import LocationRepository
from app.modules.locations.service import LocationService


def get_location_service(
    session: Session = Depends(get_db_session),
) -> LocationService:
    return LocationService(LocationRepository(session))


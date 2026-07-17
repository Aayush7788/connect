from fastapi import Depends
from sqlalchemy.orm import Session

from app.db.session import get_db_session
from app.modules.verification.repository import VerificationRepository
from app.modules.verification.service import VerificationService


def get_verification_service(
    session: Session = Depends(get_db_session),
) -> VerificationService:
    return VerificationService(VerificationRepository(session))

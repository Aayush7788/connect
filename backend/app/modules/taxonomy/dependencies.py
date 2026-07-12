from fastapi import Depends
from sqlalchemy.orm import Session

from app.db.session import get_db_session
from app.modules.taxonomy.repository import TaxonomyRepository


def get_taxonomy_repository(
    session: Session = Depends(get_db_session),
) -> TaxonomyRepository:
    return TaxonomyRepository(session)

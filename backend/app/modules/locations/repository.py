from dataclasses import dataclass

from sqlalchemy import func, select
from sqlalchemy.orm import Session

from app.db.models.location import LocationDistrict, LocationState
from app.db.models.location import PostalArea, PostalCode


@dataclass(frozen=True)
class PostalValidationRecord:
    pincode: str
    state_id: int
    state_name: str
    district_id: int
    district_name: str
    areas: list[str]


class LocationRepository:
    def __init__(self, session: Session) -> None:
        self.session = session

    def states(self, normalized_query: str, limit: int) -> list[LocationState]:
        statement = select(LocationState).order_by(LocationState.name)
        if normalized_query:
            statement = statement.where(
                LocationState.normalized_name.startswith(normalized_query)
            )
        return list(self.session.scalars(statement.limit(limit)))

    def districts(
        self,
        *,
        state_id: int,
        normalized_query: str,
        limit: int,
    ) -> list[LocationDistrict]:
        statement = (
            select(LocationDistrict)
            .where(LocationDistrict.state_id == state_id)
            .order_by(LocationDistrict.name)
        )
        if normalized_query:
            statement = statement.where(
                LocationDistrict.normalized_name.startswith(normalized_query)
            )
        return list(self.session.scalars(statement.limit(limit)))

    def state(self, state_id: int) -> LocationState | None:
        return self.session.get(LocationState, state_id)

    def district(self, district_id: int) -> LocationDistrict | None:
        return self.session.get(LocationDistrict, district_id)

    def postal_code(self, pincode: str) -> PostalCode | None:
        return self.session.get(PostalCode, pincode)

    def areas(self, pincode: str, limit: int = 12) -> list[PostalArea]:
        statement = (
            select(PostalArea)
            .where(PostalArea.pincode == pincode)
            .order_by(PostalArea.name)
            .limit(limit)
        )
        return list(self.session.scalars(statement))

    def validation_data(self, pincode: str) -> PostalValidationRecord | None:
        statement = (
            select(
                PostalCode.pincode,
                PostalCode.state_id,
                LocationState.name.label("state_name"),
                PostalCode.district_id,
                LocationDistrict.name.label("district_name"),
                func.array_agg(PostalArea.name)
                .filter(PostalArea.id.is_not(None))
                .label("areas"),
            )
            .join(LocationState, LocationState.id == PostalCode.state_id)
            .join(LocationDistrict, LocationDistrict.id == PostalCode.district_id)
            .outerjoin(PostalArea, PostalArea.pincode == PostalCode.pincode)
            .where(PostalCode.pincode == pincode)
            .group_by(
                PostalCode.pincode,
                PostalCode.state_id,
                LocationState.name,
                PostalCode.district_id,
                LocationDistrict.name,
            )
        )
        row = self.session.execute(statement).one_or_none()
        if row is None:
            return None
        return PostalValidationRecord(
            pincode=row.pincode,
            state_id=row.state_id,
            state_name=row.state_name,
            district_id=row.district_id,
            district_name=row.district_name,
            areas=sorted(row.areas or [])[:12],
        )

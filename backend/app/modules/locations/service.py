import re
import unicodedata

from app.modules.locations.repository import LocationRepository
from app.modules.locations.schemas import AddressValidationRequest
from app.modules.locations.schemas import AddressValidationResponse
from app.modules.locations.schemas import LocationOption, LocationOptionList


def normalize_location(value: str | None) -> str:
    normalized = unicodedata.normalize("NFKC", value or "").casefold()
    return " ".join(re.sub(r"[^a-z0-9]+", " ", normalized).split())


class LocationService:
    def __init__(self, repository: LocationRepository) -> None:
        self.repository = repository

    def states(self, query: str | None, limit: int) -> LocationOptionList:
        rows = self.repository.states(normalize_location(query), limit)
        return LocationOptionList(
            items=[LocationOption(id=row.id, name=row.name) for row in rows]
        )

    def districts(
        self,
        *,
        state_id: int,
        query: str | None,
        limit: int,
    ) -> LocationOptionList:
        rows = self.repository.districts(
            state_id=state_id,
            normalized_query=normalize_location(query),
            limit=limit,
        )
        return LocationOptionList(
            items=[LocationOption(id=row.id, name=row.name) for row in rows]
        )

    def validate(self, payload: AddressValidationRequest) -> AddressValidationResponse:
        postal = self.repository.validation_data(payload.pincode)
        if postal is None:
            return AddressValidationResponse(
                status="invalid",
                pincode=payload.pincode,
                state_matches=False,
                district_matches=False,
                area_matches=None,
                message="Enter a valid India Post PIN code.",
            )

        canonical_state = LocationOption(id=postal.state_id, name=postal.state_name)
        canonical_district = LocationOption(
            id=postal.district_id, name=postal.district_name
        )
        state_matches = payload.state_id == postal.state_id
        district_matches = payload.district_id == postal.district_id
        suggestions = postal.areas
        area_matches: bool | None = None
        if payload.area:
            entered_area = normalize_location(payload.area)
            area_matches = any(
                entered_area == normalize_location(area)
                or entered_area in normalize_location(area)
                or normalize_location(area) in entered_area
                for area in suggestions
            )

        if not state_matches or not district_matches:
            return AddressValidationResponse(
                status="invalid",
                pincode=payload.pincode,
                state_matches=state_matches,
                district_matches=district_matches,
                area_matches=area_matches,
                canonical_state=canonical_state,
                canonical_district=canonical_district,
                suggested_areas=suggestions,
                message="This PIN code belongs to a different state or city/district.",
            )
        if payload.area and area_matches is False:
            return AddressValidationResponse(
                status="warning",
                pincode=payload.pincode,
                state_matches=True,
                district_matches=True,
                area_matches=False,
                canonical_state=canonical_state,
                canonical_district=canonical_district,
                suggested_areas=suggestions,
                message="PIN is valid. Check the area or choose a suggested postal area.",
            )
        return AddressValidationResponse(
            status="valid",
            pincode=payload.pincode,
            state_matches=True,
            district_matches=True,
            area_matches=area_matches,
            canonical_state=canonical_state,
            canonical_district=canonical_district,
            suggested_areas=suggestions,
            message="PIN code matches the selected state and city/district.",
        )

from types import SimpleNamespace

from app.modules.locations.schemas import AddressValidationRequest
from app.modules.locations.repository import PostalValidationRecord
from app.modules.locations.service import LocationService


class FakeLocationRepository:
    def __init__(self) -> None:
        self.gujarat = SimpleNamespace(id=1, name="Gujarat")
        self.surat = SimpleNamespace(id=10, state_id=1, name="Surat")
        self.postal_code_row = SimpleNamespace(
            pincode="395002", state_id=1, district_id=10
        )

    def states(self, normalized_query, limit):
        return [self.gujarat] if "gujarat".startswith(normalized_query) else []

    def districts(self, *, state_id, normalized_query, limit):
        return (
            [self.surat]
            if state_id == 1 and "surat".startswith(normalized_query)
            else []
        )

    def state(self, state_id):
        return self.gujarat if state_id == 1 else None

    def district(self, district_id):
        return self.surat if district_id == 10 else None

    def postal_code(self, pincode):
        return self.postal_code_row if pincode == "395002" else None

    def areas(self, pincode, limit=12):
        return [
            SimpleNamespace(name="Surat Textile Market", normalized_name="surat textile market"),
            SimpleNamespace(name="Ring Road", normalized_name="ring road"),
        ]

    def validation_data(self, pincode):
        if pincode != "395002":
            return None
        return PostalValidationRecord(
            pincode="395002",
            state_id=1,
            state_name="Gujarat",
            district_id=10,
            district_name="Surat",
            areas=["Surat Textile Market", "Ring Road"],
        )


def test_state_and_district_prefix_search() -> None:
    service = LocationService(FakeLocationRepository())

    assert service.states("gu", 50).items[0].name == "Gujarat"
    assert service.districts(state_id=1, query="su", limit=100).items[0].name == "Surat"


def test_matching_address_is_valid() -> None:
    service = LocationService(FakeLocationRepository())

    result = service.validate(
        AddressValidationRequest(
            state_id=1,
            district_id=10,
            pincode="395002",
            area="Ring Road",
        )
    )

    assert result.status == "valid"
    assert result.area_matches is True


def test_state_or_district_mismatch_is_invalid() -> None:
    service = LocationService(FakeLocationRepository())

    result = service.validate(
        AddressValidationRequest(
            state_id=2,
            district_id=20,
            pincode="395002",
            area="Ring Road",
        )
    )

    assert result.status == "invalid"
    assert result.canonical_state.name == "Gujarat"
    assert result.canonical_district.name == "Surat"


def test_unknown_area_returns_warning_and_suggestions() -> None:
    service = LocationService(FakeLocationRepository())

    result = service.validate(
        AddressValidationRequest(
            state_id=1,
            district_id=10,
            pincode="395002",
            area="Unknown Area",
        )
    )

    assert result.status == "warning"
    assert "Ring Road" in result.suggested_areas

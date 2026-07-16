from typing import Literal

from pydantic import BaseModel, ConfigDict, Field, field_validator


class LocationOption(BaseModel):
    id: int
    name: str


class LocationOptionList(BaseModel):
    items: list[LocationOption]


class AddressValidationRequest(BaseModel):
    model_config = ConfigDict(extra="forbid")

    state_id: int = Field(gt=0)
    district_id: int = Field(gt=0)
    pincode: str = Field(min_length=6, max_length=6)
    area: str | None = Field(default=None, max_length=160)

    @field_validator("pincode")
    @classmethod
    def valid_pincode(cls, value: str) -> str:
        if not value.isdigit():
            raise ValueError("Pincode must contain 6 digits.")
        return value

    @field_validator("area")
    @classmethod
    def strip_area(cls, value: str | None) -> str | None:
        if value is None:
            return None
        return value.strip() or None


class AddressValidationResponse(BaseModel):
    status: Literal["valid", "warning", "invalid"]
    pincode: str
    state_matches: bool
    district_matches: bool
    area_matches: bool | None
    canonical_state: LocationOption | None = None
    canonical_district: LocationOption | None = None
    suggested_areas: list[str] = Field(default_factory=list)
    message: str


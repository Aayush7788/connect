from datetime import datetime

from sqlalchemy import BigInteger, Boolean, DateTime, ForeignKey, Index, Integer
from sqlalchemy import SmallInteger, String, Text, UniqueConstraint, text
from sqlalchemy.orm import Mapped, mapped_column

from app.db.base import Base


class LocationState(Base):
    __tablename__ = "location_states"
    __table_args__ = (
        UniqueConstraint("normalized_name"),
        Index("idx_location_states_name", "normalized_name"),
    )

    id: Mapped[int] = mapped_column(SmallInteger, primary_key=True, autoincrement=True)
    name: Mapped[str] = mapped_column(Text)
    normalized_name: Mapped[str] = mapped_column(Text)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=text("now()"), nullable=False
    )


class LocationDistrict(Base):
    __tablename__ = "location_districts"
    __table_args__ = (
        UniqueConstraint("state_id", "normalized_name"),
        Index("idx_location_districts_state_name", "state_id", "normalized_name"),
    )

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    state_id: Mapped[int] = mapped_column(
        SmallInteger, ForeignKey("location_states.id"), nullable=False
    )
    name: Mapped[str] = mapped_column(Text)
    normalized_name: Mapped[str] = mapped_column(Text)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=text("now()"), nullable=False
    )


class PostalCode(Base):
    __tablename__ = "postal_codes"
    __table_args__ = (
        Index("idx_postal_codes_state_district", "state_id", "district_id"),
    )

    pincode: Mapped[str] = mapped_column(String(6), primary_key=True)
    state_id: Mapped[int] = mapped_column(
        SmallInteger, ForeignKey("location_states.id"), nullable=False
    )
    district_id: Mapped[int] = mapped_column(
        Integer, ForeignKey("location_districts.id"), nullable=False
    )
    is_delivery: Mapped[bool] = mapped_column(
        Boolean, server_default=text("true"), nullable=False
    )
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=text("now()"), nullable=False
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=text("now()"), nullable=False
    )


class PostalArea(Base):
    __tablename__ = "postal_areas"
    __table_args__ = (
        UniqueConstraint("pincode", "normalized_name"),
        Index("idx_postal_areas_pincode_name", "pincode", "normalized_name"),
    )

    id: Mapped[int] = mapped_column(BigInteger, primary_key=True, autoincrement=True)
    pincode: Mapped[str] = mapped_column(
        String(6), ForeignKey("postal_codes.pincode"), nullable=False
    )
    name: Mapped[str] = mapped_column(Text)
    normalized_name: Mapped[str] = mapped_column(Text)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=text("now()"), nullable=False
    )


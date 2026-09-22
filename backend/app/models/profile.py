from datetime import datetime, timezone
import uuid
from typing import List, Optional
from sqlalchemy import String, Integer, Float, Boolean, DateTime, ForeignKey, JSON
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.models.base import Base


class Profile(Base):
    __tablename__ = "profiles"

    id: Mapped[str] = mapped_column(
        String(36),
        primary_key=True,
        default=lambda: str(uuid.uuid4())
    )
    user_id: Mapped[str] = mapped_column(
        String(36),
        ForeignKey("users.id", ondelete="CASCADE"),
        unique=True,
        index=True,
        nullable=False
    )
    display_name: Mapped[str] = mapped_column(
        String(100),
        nullable=False
    )
    age: Mapped[Optional[int]] = mapped_column(
        Integer,
        nullable=True
    )
    gender: Mapped[Optional[str]] = mapped_column(
        String(50),
        nullable=True
    )
    timezone: Mapped[str] = mapped_column(
        String(100),
        default="UTC",
        nullable=False
    )
    wellness_goals: Mapped[List[str]] = mapped_column(
        JSON,
        default=list,
        nullable=False
    )
    sleep_hours_target: Mapped[Optional[float]] = mapped_column(
        Float,
        default=8.0,
        nullable=True
    )
    activity_level: Mapped[Optional[str]] = mapped_column(
        String(50),
        default="moderate",
        nullable=True
    )
    onboarding_completed: Mapped[bool] = mapped_column(
        Boolean,
        default=False,
        nullable=False
    )
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        default=lambda: datetime.now(timezone.utc),
        nullable=False
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        default=lambda: datetime.now(timezone.utc),
        onupdate=lambda: datetime.now(timezone.utc),
        nullable=False
    )

    user: Mapped["User"] = relationship(
        "User",
        back_populates="profile"
    )

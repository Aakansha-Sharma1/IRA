from datetime import date, datetime, timezone
import uuid

from sqlalchemy import CheckConstraint, Date, DateTime, ForeignKey, Index, Integer, String, Text
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.models.base import Base


class MoodEntry(Base):
    __tablename__ = "mood_entries"
    __table_args__ = (
        CheckConstraint("mood IN ('very_low', 'low', 'neutral', 'good', 'very_good')", name="ck_mood_entries_mood"),
        CheckConstraint("intensity BETWEEN 1 AND 5", name="ck_mood_entries_intensity"),
        CheckConstraint("note IS NULL OR char_length(note) <= 280", name="ck_mood_entries_note_length"),
        Index("ix_mood_entries_user_id_created_at", "user_id", "created_at"),
        Index("ix_mood_entries_user_id_entry_date", "user_id", "entry_date", unique=True),
    )

    id: Mapped[str] = mapped_column(
        String(36),
        primary_key=True,
        default=lambda: str(uuid.uuid4()),
    )
    user_id: Mapped[str] = mapped_column(
        String(36),
        ForeignKey("users.id", ondelete="CASCADE"),
        index=True,
        nullable=False,
    )
    mood: Mapped[str] = mapped_column(
        String(20),
        nullable=False,
    )
    intensity: Mapped[int] = mapped_column(
        Integer,
        nullable=False,
    )
    note: Mapped[str | None] = mapped_column(
        Text,
        nullable=True,
    )
    entry_date: Mapped[date] = mapped_column(
        Date,
        nullable=False,
    )
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        default=lambda: datetime.now(timezone.utc),
        nullable=False,
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        default=lambda: datetime.now(timezone.utc),
        onupdate=lambda: datetime.now(timezone.utc),
        nullable=False,
    )

    user: Mapped["User"] = relationship(
        "User",
        back_populates="mood_entries",
    )

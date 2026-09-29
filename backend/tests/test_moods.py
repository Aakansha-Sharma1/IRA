import uuid

import pytest
from httpx import ASGITransport, AsyncClient

from app.main import app


@pytest.fixture
def anyio_backend():
    return "asyncio"


async def _register_and_onboard(client: AsyncClient, email: str, password: str, name: str) -> str:
    reg = await client.post(
        "/api/v1/auth/register",
        json={"email": email, "password": password},
    )
    assert reg.status_code == 201
    token = reg.json()["access_token"]
    headers = {"Authorization": f"Bearer {token}"}
    profile = await client.post(
        "/api/v1/profile",
        headers=headers,
        json={
            "display_name": name,
            "timezone": "UTC",
            "wellness_goals": ["Sleep Better"],
            "activity_level": "moderate",
            "onboarding_completed": True,
        },
    )
    assert profile.status_code == 201
    return token


@pytest.mark.asyncio
async def test_create_and_list_moods_for_authenticated_user():
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as client:
        token = await _register_and_onboard(
            client,
            f"mood_{uuid.uuid4().hex[:8]}@example.com",
            "TestPassword123!",
            "User A",
        )
        headers = {"Authorization": f"Bearer {token}"}

        created = await client.post(
            "/api/v1/moods",
            headers=headers,
            json={"mood": "good", "intensity": 4, "note": "Felt steady and productive.", "entry_date": "2026-09-28"},
        )
        assert created.status_code == 201
        payload = created.json()
        assert payload["mood"] == "good"
        assert payload["intensity"] == 4
        assert payload["note"] == "Felt steady and productive."

        listed = await client.get("/api/v1/moods", headers=headers)
        assert listed.status_code == 200
        assert len(listed.json()) == 1
        assert listed.json()[0]["mood"] == "good"


@pytest.mark.asyncio
async def test_mood_validation_and_user_isolation():
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as client:
        token_a = await _register_and_onboard(
            client,
            f"mood_a_{uuid.uuid4().hex[:8]}@example.com",
            "TestPassword123!",
            "User A",
        )
        token_b = await _register_and_onboard(
            client,
            f"mood_b_{uuid.uuid4().hex[:8]}@example.com",
            "TestPassword123!",
            "User B",
        )
        headers_a = {"Authorization": f"Bearer {token_a}"}
        headers_b = {"Authorization": f"Bearer {token_b}"}

        invalid_mood = await client.post(
            "/api/v1/moods",
            headers=headers_a,
            json={"mood": "awesome", "intensity": 3, "entry_date": "2026-09-28"},
        )
        assert invalid_mood.status_code == 422

        invalid_intensity = await client.post(
            "/api/v1/moods",
            headers=headers_a,
            json={"mood": "good", "intensity": 9, "entry_date": "2026-09-28"},
        )
        assert invalid_intensity.status_code == 422

        long_note = "x" * 301
        long_note_resp = await client.post(
            "/api/v1/moods",
            headers=headers_a,
            json={"mood": "good", "intensity": 3, "note": long_note, "entry_date": "2026-09-28"},
        )
        assert long_note_resp.status_code == 422

        created = await client.post(
            "/api/v1/moods",
            headers=headers_a,
            json={"mood": "neutral", "intensity": 3, "entry_date": "2026-09-29"},
        )
        assert created.status_code == 201
        mood_id = created.json()["id"]

        get_other = await client.get(f"/api/v1/moods/{mood_id}", headers=headers_b)
        assert get_other.status_code == 404

        update_other = await client.put(
            f"/api/v1/moods/{mood_id}",
            headers=headers_b,
            json={"mood": "very_good", "intensity": 5},
        )
        assert update_other.status_code == 404

        duplicate = await client.post(
            "/api/v1/moods",
            headers=headers_a,
            json={"mood": "good", "intensity": 4, "entry_date": "2026-09-29"},
        )
        assert duplicate.status_code == 409


@pytest.mark.asyncio
async def test_update_and_get_single_mood():
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as client:
        token = await _register_and_onboard(
            client,
            f"mood_update_{uuid.uuid4().hex[:8]}@example.com",
            "TestPassword123!",
            "User C",
        )
        headers = {"Authorization": f"Bearer {token}"}

        created = await client.post(
            "/api/v1/moods",
            headers=headers,
            json={"mood": "low", "intensity": 2, "entry_date": "2026-09-30"},
        )
        assert created.status_code == 201
        mood_id = created.json()["id"]

        single = await client.get(f"/api/v1/moods/{mood_id}", headers=headers)
        assert single.status_code == 200
        assert single.json()["mood"] == "low"

        updated = await client.put(
            f"/api/v1/moods/{mood_id}",
            headers=headers,
            json={"mood": "good", "intensity": 4, "note": "Feeling better after a walk."},
        )
        assert updated.status_code == 200
        assert updated.json()["mood"] == "good"
        assert updated.json()["note"] == "Feeling better after a walk."


@pytest.mark.asyncio
async def test_mood_requires_authentication():
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as client:
        unauth = await client.get("/api/v1/moods")
        assert unauth.status_code == 401

        invalid = await client.get("/api/v1/moods", headers={"Authorization": "Bearer invalid"})
        assert invalid.status_code == 401

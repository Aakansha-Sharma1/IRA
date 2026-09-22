import uuid
import pytest
from httpx import AsyncClient, ASGITransport
from app.main import app


@pytest.fixture
def anyio_backend():
    return "asyncio"


@pytest.mark.asyncio
async def test_full_auth_and_profile_flow():
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as client:
        unique_email = f"user_{uuid.uuid4().hex[:8]}@example.com"
        password = "TestPassword123!"

        # 1. Register new user
        reg_res = await client.post(
            "/api/v1/auth/register",
            json={"email": unique_email, "password": password}
        )
        assert reg_res.status_code == 201
        reg_data = reg_res.json()
        assert "access_token" in reg_data
        assert reg_data["user"]["email"] == unique_email
        token = reg_data["access_token"]
        headers = {"Authorization": f"Bearer {token}"}

        # 2. Duplicate registration fails (409)
        dup_res = await client.post(
            "/api/v1/auth/register",
            json={"email": unique_email, "password": password}
        )
        assert dup_res.status_code == 409

        # 3. Login with valid credentials
        login_res = await client.post(
            "/api/v1/auth/login",
            json={"email": unique_email, "password": password}
        )
        assert login_res.status_code == 200
        assert "access_token" in login_res.json()

        # 4. Login with invalid password fails (401)
        bad_login = await client.post(
            "/api/v1/auth/login",
            json={"email": unique_email, "password": "WrongPassword!"}
        )
        assert bad_login.status_code == 401

        # 5. /auth/me with token succeeds
        me_res = await client.get("/api/v1/auth/me", headers=headers)
        assert me_res.status_code == 200
        assert me_res.json()["email"] == unique_email

        # 6. /auth/me without token fails (401)
        unauth_me = await client.get("/api/v1/auth/me")
        assert unauth_me.status_code == 401

        # 7. GET /profile before onboarding returns 404
        profile_res = await client.get("/api/v1/profile", headers=headers)
        assert profile_res.status_code == 404

        # 8. POST /profile with invalid age fails (422)
        invalid_profile = await client.post(
            "/api/v1/profile",
            headers=headers,
            json={
                "display_name": "Test User",
                "age": 150,  # exceeds 120 limit
                "timezone": "America/New_York",
            }
        )
        assert invalid_profile.status_code == 422

        # 9. POST /profile creates valid profile (Onboarding)
        create_profile_res = await client.post(
            "/api/v1/profile",
            headers=headers,
            json={
                "display_name": "Alex Rivera",
                "age": 28,
                "gender": "Non-binary",
                "timezone": "America/New_York",
                "wellness_goals": ["Reduce Stress", "Sleep Better", "Mindfulness"],
                "sleep_hours_target": 7.5,
                "activity_level": "moderate",
                "onboarding_completed": True
            }
        )
        assert create_profile_res.status_code == 201
        created_data = create_profile_res.json()
        assert created_data["display_name"] == "Alex Rivera"
        assert created_data["age"] == 28
        assert created_data["onboarding_completed"] is True
        assert "Reduce Stress" in created_data["wellness_goals"]

        # 10. GET /profile now succeeds and returns persisted data
        get_profile_res = await client.get("/api/v1/profile", headers=headers)
        assert get_profile_res.status_code == 200
        assert get_profile_res.json()["display_name"] == "Alex Rivera"
        assert get_profile_res.json()["sleep_hours_target"] == 7.5

        # 11. PUT /profile updates fields
        update_profile_res = await client.put(
            "/api/v1/profile",
            headers=headers,
            json={
                "display_name": "Alex R.",
                "sleep_hours_target": 8.0
            }
        )
        assert update_profile_res.status_code == 200
        assert update_profile_res.json()["display_name"] == "Alex R."
        assert update_profile_res.json()["sleep_hours_target"] == 8.0

        # 12. Profile Isolation: create User B and verify User B cannot access User A's profile
        user_b_email = f"user_b_{uuid.uuid4().hex[:8]}@example.com"
        reg_b = await client.post(
            "/api/v1/auth/register",
            json={"email": user_b_email, "password": password}
        )
        token_b = reg_b.json()["access_token"]
        headers_b = {"Authorization": f"Bearer {token_b}"}

        # User B profile should be 404 not found (isolated from User A)
        user_b_profile = await client.get("/api/v1/profile", headers=headers_b)
        assert user_b_profile.status_code == 404

        # 13. Logout
        logout_res = await client.post("/api/v1/auth/logout")
        assert logout_res.status_code == 200

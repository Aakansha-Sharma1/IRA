import pytest
from app.core.security import hash_password, verify_password, create_access_token, decode_access_token
from app.schemas.auth import RegisterRequest, LoginRequest


def test_password_hashing():
    raw = "MySecurePassword123!"
    hashed = hash_password(raw)
    assert hashed != raw
    assert verify_password(raw, hashed) is True
    assert verify_password("WrongPassword123!", hashed) is False


def test_jwt_token_flow():
    user_data = {"sub": "user_12345", "email": "test@ira.ai"}
    token = create_access_token(user_data)
    assert isinstance(token, str)
    assert len(token) > 20

    decoded = decode_access_token(token)
    assert decoded is not None
    assert decoded["sub"] == "user_12345"
    assert decoded["email"] == "test@ira.ai"


def test_jwt_invalid_token():
    assert decode_access_token("invalid.token.here") is None


def test_validation_schemas():
    reg = RegisterRequest(email="user@ira.ai", password="password123")
    assert reg.email == "user@ira.ai"
    assert reg.password == "password123"

    login = LoginRequest(email="user@ira.ai", password="password123")
    assert login.email == "user@ira.ai"

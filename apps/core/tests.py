"""Tests for core app including health check endpoint."""

import pytest
from django.test import Client
from django.urls import reverse


@pytest.mark.django_db
class TestHealthCheck:
    """Tests for the health check endpoint."""

    def test_health_check_returns_200(self, client: Client):
        """Health check returns 200 when database is accessible."""
        response = client.get("/health/")
        assert response.status_code == 200

    def test_health_check_returns_json(self, client: Client):
        """Health check returns JSON response."""
        response = client.get("/health/")
        assert response["Content-Type"] == "application/json"

    def test_health_check_contains_status(self, client: Client):
        """Health check response contains status field."""
        response = client.get("/health/")
        data = response.json()
        assert "status" in data
        assert data["status"] == "healthy"

    def test_health_check_contains_database_status(self, client: Client):
        """Health check response contains database status."""
        response = client.get("/health/")
        data = response.json()
        assert "database" in data
        assert data["database"] == "ok"

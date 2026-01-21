"""
Pytest configuration for Disneybound Planner.
"""

import os

import django
from django.conf import settings

# Configure Django settings before running tests
os.environ.setdefault("DJANGO_SETTINGS_MODULE", "config.settings")


def pytest_configure():
    """Configure Django for pytest."""
    settings.DEBUG = False
    django.setup()

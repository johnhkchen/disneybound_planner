# T-001: Initialize Django project with uv

> **Status**: Done
> **Parent EP**: EP-001
> **Created**: 2026-01-20
> **Assignee**: Agent
> **Priority**: High

---

## Description

Initialize the Django project using uv package manager with proper directory structure and core dependencies.

## Acceptance Criteria

- [x] Project initialized with `uv init --python 3.13`
- [x] Django 6.0.1 installed
- [x] Core dependencies added (django-allauth, django-htmx, django-components, etc.)
- [x] Dev dependencies added (pytest, ruff, mypy)
- [x] Django apps created in `apps/` directory
- [x] `config/` module created as main Django config

## Technical Notes

### Files Created

- `pyproject.toml` - Project configuration
- `uv.lock` - Locked dependencies
- `config/` - Django settings module
- `apps/` - Django applications:
  - `accounts/` - User authentication
  - `characters/` - Disney character data
  - `outfits/` - Outfit builder
  - `trips/` - Trip planning
  - `scraping/` - Web scraping
  - `ai/` - BAML/LLM integration

### Dependencies Installed

Core:
- django==6.0.1
- django-allauth==65.14.0
- django-htmx==1.27.0
- django-components==0.144.0
- django-tailwind==4.4.2
- psycopg==3.3.2
- baml-py==0.217.0

Dev:
- pytest==9.0.2
- pytest-django==4.11.1
- ruff==0.14.13
- mypy==1.19.1

## Testing

- [x] `uv run python manage.py check` passes

## Notes

All dependencies are at latest stable versions as of 2026-01-20.

---

## Work Log

| Date | Update |
|------|--------|
| 2026-01-20 | Created and completed |

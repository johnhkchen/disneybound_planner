# EP-001: Project Foundation & Architecture

> **Status**: In Progress
> **Created**: 2026-01-20
> **Sprint**: 0
> **Author**: Agent

---

## Summary

Set up the foundational Django project with all core infrastructure: PostgreSQL, Tailwind CSS with semantic layers, django-components, HTMX, authentication, and BAML for LLM integration.

## Motivation

Establish a clean, well-architected foundation that supports:
- Rapid feature development
- Clean, maintainable templates using semantic CSS
- HTMX-powered interactivity without heavy JavaScript
- AI-powered features via BAML and Gemini 2.5
- User authentication for saved outfit lists

## Proposed Solution

### Technical Approach

1. **Django 6.0.1** as the core framework
2. **PostgreSQL** via Docker Compose for data persistence
3. **Tailwind CSS v4** with `@layer` directives for semantic component classes
4. **django-components** for reusable template components
5. **django-template-partials** for HTMX partial rendering
6. **django-allauth** for authentication (email + social)
7. **BAML** for structured LLM calls to Gemini 2.5

### Affected Components

- [x] Project initialization with uv
- [x] Django apps structure (`apps/`)
- [ ] `config/settings.py` - Django configuration
- [ ] `docker-compose.yml` - PostgreSQL setup
- [ ] `static/css/` - Tailwind semantic layers
- [ ] `templates/` - Base template hierarchy
- [ ] `baml/` - BAML schema definitions

## Acceptance Criteria

- [ ] Project runs with `just dev`
- [ ] PostgreSQL connects via Docker Compose
- [ ] Tailwind compiles with semantic component classes
- [ ] Base template hierarchy established
- [ ] Authentication working (signup, login, logout)
- [ ] BAML can call Gemini 2.5 API
- [ ] All tests pass with `just test`

## Linked Tickets

| Ticket | Title | Status |
|--------|-------|--------|
| T-001 | Initialize Django project with uv | Done |
| T-002 | Set up PostgreSQL with Docker Compose | Pending |
| T-003 | Configure Tailwind semantic CSS system | Pending |
| T-004 | Set up base template hierarchy | Pending |
| T-005 | Configure django-allauth authentication | Pending |
| T-006 | Set up BAML with Gemini integration | Pending |

## Open Questions

- [x] Which Python version? **Answer: 3.13**
- [x] Which LLM provider? **Answer: Gemini 2.5**
- [ ] Social auth providers to enable initially? (Google, Apple, etc.)

## Notes

- Using Django 6.0.1 which has native template partials support
- psycopg3 (3.3.2) used instead of deprecated psycopg2
- Tailwind semantic approach: define component classes in CSS, use them in templates

---

## Changelog

| Date | Change |
|------|--------|
| 2026-01-20 | Created, T-001 completed |

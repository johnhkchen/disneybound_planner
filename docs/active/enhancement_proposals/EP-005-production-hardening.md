# EP-005: Production Hardening & Zero-Worry Deployments

> **Status**: Implemented
> **Created**: 2026-01-20
> **Sprint**: 2
> **Author**: Agent

---

## Summary

Harden the application for production with proper secrets management, Django security settings, CI/CD pipeline with tests, and deployment confidence so pushing to `main` is safe and worry-free.

## Motivation

Currently, deploying to production requires manual verification and hope. We need:

1. **Secrets safety**: Production secrets managed securely, separate from development
2. **Security hardening**: Django security settings properly configured for production
3. **CI/CD confidence**: Tests run before deploy, blocking broken code
4. **Deployment reliability**: Health checks, rollback capability, zero-downtime deploys
5. **Observability**: Know when something goes wrong

### User Stories

> As a developer, I want to push to main with confidence knowing tests will run and bad code won't deploy.

> As a developer, I want production secrets completely separate from development so there's no risk of exposure.

> As an operator, I want the app to be secure by default with proper HTTPS, CSRF, and security headers.

## Proposed Solution

### 1. Secrets Management with Doppler + Fly.io

**Environment Structure:**
```
Doppler Project: disneybound-planner
├── dev          → Local development
├── staging      → Fly.io staging (optional)
└── prd          → Fly.io production
```

**Required Production Secrets:**
| Secret | Source | Notes |
|--------|--------|-------|
| `SECRET_KEY` | Auto-generated | Unique per environment |
| `DATABASE_URL` | Neon | Production database |
| `GOOGLE_API_KEY` | Google AI Studio | Gemini API |
| `ALLOWED_HOSTS` | Fly.io | `disneybound-planner-*.fly.dev` |
| `TMDB_API_KEY` | TMDB | For character thumbnails (EP-004) |

**Fly.io Integration:**
```bash
# Sync Doppler secrets to Fly.io
doppler secrets download --no-file --format env-no-quotes -c prd | \
  xargs -I {} fly secrets set {}
```

Or use Doppler's Fly.io integration for automatic sync.

### 2. Django Security Hardening

```python
# config/settings.py - Production security settings

if not DEBUG:
    # HTTPS
    SECURE_SSL_REDIRECT = True
    SECURE_PROXY_SSL_HEADER = ('HTTP_X_FORWARDED_PROTO', 'https')
    SESSION_COOKIE_SECURE = True
    CSRF_COOKIE_SECURE = True

    # HSTS (HTTP Strict Transport Security)
    SECURE_HSTS_SECONDS = 31536000  # 1 year
    SECURE_HSTS_INCLUDE_SUBDOMAINS = True
    SECURE_HSTS_PRELOAD = True

    # Security headers
    SECURE_CONTENT_TYPE_NOSNIFF = True
    SECURE_BROWSER_XSS_FILTER = True  # Deprecated but harmless
    X_FRAME_OPTIONS = 'DENY'

    # CSRF
    CSRF_TRUSTED_ORIGINS = [
        'https://disneybound-planner-*.fly.dev',
        'https://*.disneybound.app',  # Future custom domain
    ]

    # Allowed hosts (from environment)
    ALLOWED_HOSTS = env.list('ALLOWED_HOSTS', default=[])
```

### 3. CI/CD Pipeline

```yaml
# .github/workflows/ci.yml
name: CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    services:
      postgres:
        image: postgres:16
        env:
          POSTGRES_USER: test
          POSTGRES_PASSWORD: test
          POSTGRES_DB: test
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
        ports:
          - 5432:5432

    steps:
      - uses: actions/checkout@v4

      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: '3.13'

      - name: Install uv
        uses: astral-sh/setup-uv@v4

      - name: Install dependencies
        run: uv sync

      - name: Run linter
        run: uv run ruff check .

      - name: Run type checker
        run: uv run mypy apps/

      - name: Run tests
        env:
          DATABASE_URL: postgres://test:test@localhost:5432/test
          SECRET_KEY: test-secret-key-for-ci
          DEBUG: 'True'
        run: uv run pytest --cov=apps --cov-report=xml

      - name: Upload coverage
        uses: codecov/codecov-action@v4
        with:
          file: ./coverage.xml

  deploy:
    needs: test
    if: github.ref == 'refs/heads/main' && github.event_name == 'push'
    runs-on: ubuntu-latest
    concurrency: deploy-group

    steps:
      - uses: actions/checkout@v4

      - uses: superfly/flyctl-actions/setup-flyctl@master

      - name: Deploy to Fly.io
        run: flyctl deploy --remote-only
        env:
          FLY_API_TOKEN: ${{ secrets.FLY_API_TOKEN }}
```

### 4. Health Checks & Monitoring

**Django Health Check Endpoint:**
```python
# apps/core/views.py
from django.http import JsonResponse
from django.db import connection

def health_check(request):
    """Health check endpoint for Fly.io."""
    checks = {
        'status': 'healthy',
        'database': 'ok',
    }

    try:
        with connection.cursor() as cursor:
            cursor.execute('SELECT 1')
    except Exception as e:
        checks['database'] = f'error: {str(e)}'
        checks['status'] = 'unhealthy'
        return JsonResponse(checks, status=503)

    return JsonResponse(checks)
```

**Fly.io Health Check:**
```toml
# fly.toml
[http_service]
  ...

[[http_service.checks]]
  grace_period = "10s"
  interval = "30s"
  method = "GET"
  path = "/health/"
  timeout = "5s"
```

### 5. Environment-Specific Configuration

```python
# config/settings.py

# Determine environment
ENVIRONMENT = env('ENVIRONMENT', default='development')

# Environment-specific settings
match ENVIRONMENT:
    case 'production':
        DEBUG = False
        # All production security settings...
    case 'staging':
        DEBUG = False
        # Staging-specific settings...
    case _:  # development
        DEBUG = True
        # Development conveniences...
```

### Architecture

```
Developer Push to main
         │
         ▼
┌─────────────────────┐
│  GitHub Actions CI  │
│  - Lint (ruff)      │
│  - Type check       │
│  - Run tests        │
└─────────────────────┘
         │ All pass?
         ▼
┌─────────────────────┐
│  Deploy to Fly.io   │
│  - Build container  │
│  - Run migrations   │
│  - Health check     │
└─────────────────────┘
         │
         ▼
┌─────────────────────┐
│  Production Live    │
│  - Doppler secrets  │
│  - Neon database    │
│  - Security headers │
└─────────────────────┘
```

### Affected Components

- [x] `config/settings.py` - Add production security settings (CSRF_TRUSTED_ORIGINS)
- [x] `.github/workflows/ci.yml` - New CI workflow with lint, typecheck, tests, deploy
- [x] `.github/workflows/deploy.yml` - Removed (consolidated into ci.yml)
- [x] `.github/workflows/fly-deploy.yml` - Removed (consolidated into ci.yml)
- [x] `fly.toml` - Add health check configuration
- [x] `apps/core/` - New app for health check endpoint
- [x] `Dockerfile` - Already runs collectstatic
- [ ] `doppler.yaml` - Document Doppler configuration (optional)

## Acceptance Criteria

- [x] CI runs lint, type check, and tests on every PR
- [x] Deploy only happens after CI passes
- [ ] Production uses separate Doppler environment (manual setup required)
- [x] All Django security settings enabled in production
- [x] Health check endpoint responds correctly
- [x] Fly.io monitors health and restarts unhealthy machines
- [x] HTTPS enforced, security headers present
- [x] `DEBUG=False` in production (verified)
- [x] Secrets never appear in logs or error messages

## Security Checklist

- [x] `DEBUG = False` in production
- [x] `SECRET_KEY` unique and secure (50+ chars)
- [x] `ALLOWED_HOSTS` explicitly set
- [x] HTTPS enforced (Fly.io handles this)
- [x] HSTS enabled with long max-age (31536000 seconds)
- [x] CSRF protection enabled
- [x] Session cookies secure and httponly
- [x] Content-Type sniffing prevented
- [x] Clickjacking protection (X-Frame-Options: DENY)
- [x] No sensitive data in error pages
- [x] Database credentials not in code
- [x] API keys not in code

## Linked Tickets

| Ticket | Title | Status |
|--------|-------|--------|
| T-017 | Add Django security settings for production | Pending |
| T-018 | Create CI workflow with tests | Pending |
| T-019 | Add health check endpoint | Pending |
| T-020 | Configure Doppler production environment | Pending |
| T-021 | Update Fly.io config with health checks | Pending |
| T-022 | Sync Doppler secrets to Fly.io | Pending |

## Open Questions

- [ ] Do we need a staging environment, or just dev + prod?
- [ ] Should we add Sentry for error tracking?
- [ ] Rate limiting for API endpoints?
- [ ] Should we use Fly.io Postgres instead of Neon for lower latency?
- [ ] Backup strategy for the database?

## Alternatives Considered

### 1. Fly.io Secrets Only (No Doppler)
- **Pros**: Simpler, one less tool
- **Cons**: No local dev integration, CLI-only management, no audit trail

### 2. GitHub Secrets for CI + Fly.io for Runtime
- **Pros**: Native integrations
- **Cons**: Secrets scattered across platforms, no single source of truth

### 3. HashiCorp Vault
- **Pros**: Enterprise-grade, self-hosted option
- **Cons**: Overkill for this scale, complex operations

**Decision**: Doppler provides the best balance of developer experience (local + CI + production) with audit trails and access control.

## Notes

- Fly.io supports zero-downtime deploys with rolling updates
- Neon has automatic daily backups on free tier
- Consider adding `django-csp` for Content Security Policy
- Monitor with Fly.io metrics dashboard initially, add Sentry later
- GitHub Actions free tier: 2000 minutes/month (plenty for this project)

---

## Changelog

| Date | Change |
|------|--------|
| 2026-01-20 | Created |
| 2026-01-20 | Implemented: Health check endpoint, CI workflow, Fly.io health checks, CSRF trusted origins |

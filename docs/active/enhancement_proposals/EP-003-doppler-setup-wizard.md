# EP-003: Doppler Secrets Management & Setup Wizard

> **Status**: Draft
> **Created**: 2026-01-20
> **Sprint**: 1
> **Author**: Agent

---

## Summary

Replace manual `.env` file management with Doppler for centralized secrets management, and create an interactive `just setup` wizard that guides developers through local environment configuration.

## Motivation

Currently, developers must manually:
1. Copy `.env.example` to `.env`
2. Obtain secrets from team members or documentation
3. Manually edit `.env` with correct values
4. Hope they didn't miss anything

This is error-prone, insecure (secrets shared via Slack/email), and creates friction for new team members. Doppler provides:
- Centralized secrets management with access control
- Environment-specific configs (dev, staging, production)
- Automatic secret rotation support
- Audit logs for compliance
- CLI integration for local development

### User Stories

> As a new developer, I want to run a single setup command that guides me through configuration so I can start coding quickly without hunting for secrets.

> As a team lead, I want secrets managed centrally so I can rotate API keys without coordinating with every developer.

> As a DevOps engineer, I want production secrets isolated from development so we reduce the risk of accidental exposure.

## Proposed Solution

### 1. Doppler Integration

Set up Doppler with three environments:
- **dev** - Local development (safe defaults, test API keys)
- **staging** - Staging deployment on Fly.io
- **prd** - Production deployment on Fly.io

Secrets to manage:
- `SECRET_KEY` - Django secret key
- `DATABASE_URL` - Neon Postgres connection string
- `GOOGLE_API_KEY` - Gemini API for BAML
- `GOOGLE_CLIENT_ID` - OAuth (optional)
- `GOOGLE_CLIENT_SECRET` - OAuth (optional)

### 2. Interactive Setup Wizard

Replace the current `just setup` with an interactive wizard that:

1. **Checks prerequisites**
   - Python version
   - uv installed
   - Doppler CLI installed (prompts to install if missing)

2. **Doppler authentication**
   - Prompts user to login: `doppler login`
   - Selects project: `doppler setup`
   - Configures environment (dev by default)

3. **Fallback to .env**
   - If user opts out of Doppler, guides through manual `.env` setup
   - Validates required secrets are present

4. **Database setup**
   - Prompts for Neon connection string OR offers to create dev branch
   - Tests database connection
   - Runs migrations

5. **BAML setup**
   - Checks for `GOOGLE_API_KEY`
   - Generates BAML client

6. **Verification**
   - Runs `just check` to validate setup
   - Shows next steps

### Architecture

```
just setup
    │
    ├─► Check prerequisites (Python, uv)
    │
    ├─► Doppler or .env?
    │       │
    │       ├─► Doppler: doppler login → doppler setup
    │       │
    │       └─► .env: Interactive prompts for each secret
    │
    ├─► Database connection test
    │
    ├─► Run migrations
    │
    ├─► Generate BAML client
    │
    └─► Verify with Django check
```

### Affected Components

- [ ] `justfile` - Replace `setup` with interactive wizard
- [ ] `scripts/setup.sh` - New setup script (called by justfile)
- [ ] `.env.example` - Update with Doppler instructions
- [ ] `README.md` - Update setup instructions
- [ ] `docs/` - Add Doppler setup guide
- [ ] `fly.toml` - Configure Doppler for production (optional)
- [ ] `.github/workflows/` - Update CI to use Doppler

## Acceptance Criteria

- [ ] Developer can run `just setup` and be guided through complete local setup
- [ ] Doppler CLI integration works for fetching secrets
- [ ] Fallback to `.env` works for developers who prefer not to use Doppler
- [ ] Setup wizard validates all required secrets are present
- [ ] Setup wizard tests database connectivity before proceeding
- [ ] Setup wizard runs migrations automatically
- [ ] Setup wizard generates BAML client
- [ ] Clear error messages when prerequisites are missing
- [ ] Setup is idempotent (safe to run multiple times)

## Technical Details

### Doppler Project Structure

```
disneybound-planner/
├── dev         # Local development
├── staging     # Fly.io staging
└── prd         # Fly.io production
```

### Required Secrets

| Secret | Required | Description |
|--------|----------|-------------|
| `SECRET_KEY` | Yes | Django secret key |
| `DATABASE_URL` | Yes | Neon Postgres URL |
| `GOOGLE_API_KEY` | Yes | Gemini API key |
| `GOOGLE_CLIENT_ID` | No | Google OAuth |
| `GOOGLE_CLIENT_SECRET` | No | Google OAuth |
| `DEBUG` | No | Defaults to True in dev |
| `ALLOWED_HOSTS` | No | Defaults to localhost |

### Justfile Commands

```just
# Interactive setup wizard
setup:
    ./scripts/setup.sh

# Setup with Doppler (skip prompts)
setup-doppler:
    doppler run -- uv sync
    doppler run -- uv run python manage.py migrate
    just baml-generate

# Setup with .env (skip prompts)
setup-env:
    uv sync
    uv run python manage.py migrate
    just baml-generate

# Run command with Doppler secrets
run *ARGS:
    doppler run -- {{ ARGS }}

# Start dev server with Doppler
dev:
    doppler run -- uv run python manage.py runserver
```

### Setup Script Flow

```bash
#!/usr/bin/env bash
# scripts/setup.sh

echo "🏰 Disneybound Planner Setup Wizard"
echo ""

# 1. Check Python
python_version=$(python3 --version 2>&1)
echo "✓ $python_version"

# 2. Check uv
if ! command -v uv &> /dev/null; then
    echo "✗ uv not found. Install: curl -LsSf https://astral.sh/uv/install.sh | sh"
    exit 1
fi
echo "✓ uv installed"

# 3. Secrets management choice
echo ""
echo "How would you like to manage secrets?"
echo "  1) Doppler (recommended for teams)"
echo "  2) Local .env file"
read -p "Choice [1/2]: " choice

if [ "$choice" = "1" ]; then
    # Doppler flow
    if ! command -v doppler &> /dev/null; then
        echo "Installing Doppler CLI..."
        brew install dopplerhq/cli/doppler || curl -Ls https://cli.doppler.com/install.sh | sh
    fi
    doppler login
    doppler setup
else
    # .env flow
    if [ ! -f .env ]; then
        cp .env.example .env
        echo "Created .env from template"
    fi
    # Interactive prompts for missing values...
fi

# 4. Sync dependencies
uv sync

# 5. Test database & migrate
echo "Testing database connection..."
uv run python manage.py check --database default
uv run python manage.py migrate

# 6. Generate BAML client
just baml-generate

# 7. Final check
echo ""
echo "Running verification..."
uv run python manage.py check

echo ""
echo "✨ Setup complete! Run 'just dev' to start."
```

## Linked Tickets

| Ticket | Title | Status |
|--------|-------|--------|
| T-007 | Create Doppler project and configure environments | Pending |
| T-008 | Write interactive setup.sh script | Pending |
| T-009 | Update justfile with Doppler commands | Pending |
| T-010 | Update documentation for new setup flow | Pending |
| T-011 | Configure CI/CD to use Doppler | Pending |

## Open Questions

- [ ] Should we support both Doppler and Fly.io secrets, or migrate fully to Doppler?
- [ ] Do we need a staging environment on Fly.io, or just dev + production?
- [ ] Should the setup wizard create a Neon database branch automatically?
- [ ] How do we handle secrets for CI (GitHub Actions)?

## Alternatives Considered

### 1. Keep using .env files
- **Pros**: Simple, no external dependencies
- **Cons**: Insecure sharing, manual sync, no audit trail

### 2. Use Fly.io secrets only
- **Pros**: Already integrated for deployment
- **Cons**: No local dev support, CLI-only interface

### 3. Use AWS Secrets Manager / HashiCorp Vault
- **Pros**: Enterprise-grade, self-hosted option
- **Cons**: Overkill for this project, complex setup

### 4. Use 1Password CLI
- **Pros**: Many devs already have 1Password
- **Cons**: Personal vs team accounts, less dev-focused

**Decision**: Doppler offers the best balance of simplicity, security, and developer experience for a team project.

## Notes

- Doppler free tier supports up to 5 team members
- Doppler CLI caches secrets locally for offline development
- Can integrate with Fly.io via `doppler secrets download` in Dockerfile
- Setup wizard should be idempotent - safe to run multiple times

---

## Changelog

| Date | Change |
|------|--------|
| 2026-01-20 | Created |

# Disneybound Planner - Project Commands
# Run `just` to see all available commands

set dotenv-load

default:
    @just --list

# =============================================================================
# DEVELOPMENT
# =============================================================================

# Start development server
dev:
    uv run python manage.py runserver

# Run tests
test:
    uv run python manage.py test

# Run database migrations
migrate:
    uv run python manage.py migrate

# Create new migrations
makemigrations *ARGS:
    uv run python manage.py makemigrations {{ ARGS }}

# Start Django shell
shell:
    uv run python manage.py shell

# Run any Django management command
manage *ARGS:
    uv run python manage.py {{ ARGS }}

# Sync dependencies
sync:
    uv sync

# Lock dependencies
lock:
    uv lock

# =============================================================================
# QUALITY
# =============================================================================

# Run linter
lint:
    uv run ruff check .

# Fix linting issues
lint-fix:
    uv run ruff check . --fix

# Format code
format:
    uv run ruff format .

# Run type checker
typecheck:
    uv run mypy apps/

# Run all quality checks
check: lint test

# =============================================================================
# TAILWIND
# =============================================================================

# Initialize Tailwind theme app (run once during setup)
tailwind-init:
    uv run python manage.py tailwind init theme
    @echo "Now uncomment 'theme' in config/settings.py THIRD_PARTY_APPS"

# Start Tailwind CSS watcher
tailwind:
    uv run python manage.py tailwind start

# Build Tailwind CSS for production
tailwind-build:
    uv run python manage.py tailwind build

# Install Tailwind dependencies
tailwind-install:
    uv run python manage.py tailwind install

# =============================================================================
# BAML
# =============================================================================

# Generate BAML client
baml-generate:
    uv run baml-cli generate

# Test BAML functions
baml-test:
    uv run baml-cli test

# =============================================================================
# DEPLOYMENT (Fly.io)
# =============================================================================

# Deploy to Fly.io
deploy:
    fly deploy

# View production logs
logs:
    fly logs

# SSH into production machine
ssh:
    fly ssh console

# List all secrets
secrets:
    fly secrets list

# Set a secret
secret key value:
    fly secrets set {{ key }}={{ value }}

# Set DATABASE_URL from Neon
db-url url:
    fly secrets set DATABASE_URL={{ url }}

# Generate a new Django secret key
gen-secret-key:
    @uv run python -c "from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())"

# =============================================================================
# MAINTENANCE
# =============================================================================

# Update all packages to latest stable versions
update-packages:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "Updating core dependencies..."
    uv add --upgrade django django-allauth django-htmx django-components django-tailwind psycopg psycopg-binary python-dotenv django-environ whitenoise gunicorn httpx beautifulsoup4 lxml baml-py requests pyjwt cryptography
    echo ""
    echo "Updating dev dependencies..."
    uv add --group dev --upgrade pytest pytest-django pytest-cov ruff mypy django-stubs pre-commit
    echo ""
    echo "Syncing environment..."
    uv sync
    echo ""
    echo "Done! Package versions:"
    uv pip list | grep -E "^(django|psycopg|baml|ruff|pytest)" || true

# Clean cache and temporary files
clean:
    find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
    find . -type f -name "*.pyc" -delete 2>/dev/null || true
    find . -type d -name ".pytest_cache" -exec rm -rf {} + 2>/dev/null || true
    find . -type d -name ".mypy_cache" -exec rm -rf {} + 2>/dev/null || true
    find . -type d -name ".ruff_cache" -exec rm -rf {} + 2>/dev/null || true
    rm -rf htmlcov/ .coverage 2>/dev/null || true

# Show project status
status:
    @echo "=== Git Status ==="
    git status --short || echo "Not a git repository"
    @echo ""
    @echo "=== Python Environment ==="
    uv run python --version
    @echo ""
    @echo "=== Django Check ==="
    uv run python manage.py check --verbosity 0 && echo "Django: OK" || echo "Django: ISSUES"

# Show project overview
overview:
    @echo "=== Disneybound Planner ==="
    @echo ""
    @echo "Apps:"
    @ls -1 apps/
    @echo ""
    @echo "Key Files:"
    @echo "  - docs/OVERVIEW.md      Project dashboard"
    @echo "  - config/settings.py    Django settings"
    @echo "  - justfile              This file"
    @echo ""
    @echo "Quick Start:"
    @echo "  just dev                Start dev server"
    @echo "  just test               Run tests"
    @echo "  git push                Deploy to production"

# =============================================================================
# GIT / GITHUB
# =============================================================================

# Initialize git repository
git-init:
    git init && git add . && git commit -m "Initial commit"

# Create GitHub repository and push
gh-create:
    gh repo create disneybound-planner --private --source=. --push

# =============================================================================
# SETUP (First Time)
# =============================================================================

# Interactive setup wizard (recommended for new developers)
setup:
    ./scripts/setup.sh

# Setup with Doppler only (skip prompts)
setup-doppler:
    doppler run -- uv sync
    doppler run -- uv run python manage.py migrate
    just baml-generate
    @echo ""
    @echo "Setup complete! Run 'just dev-doppler' to start."

# Setup with .env only (skip prompts)
setup-env:
    cp .env.example .env 2>/dev/null || echo ".env already exists"
    uv sync
    @echo ""
    @echo "Edit .env with your DATABASE_URL, GOOGLE_API_KEY, and TMDB_API_KEY"
    @echo "Get TMDB API key from: https://www.themoviedb.org/settings/api"
    @echo "Then run 'just migrate' and 'just dev'"

# First-time Fly.io deployment setup
fly-setup:
    @echo "Setting up Fly.io deployment..."
    @echo ""
    @echo "1. Run: fly launch (creates app, skip database)"
    @echo "2. Get Neon connection string from neon.tech"
    @echo "3. Run: just db-url 'postgres://...'"
    @echo "4. Run: just secret SECRET_KEY \$$(just gen-secret-key)"
    @echo "5. Run: just secret GOOGLE_API_KEY your-api-key"
    @echo "6. Run: just secret TMDB_API_KEY your-tmdb-read-token"
    @echo "7. Add FLY_API_TOKEN to GitHub repo secrets"
    @echo "8. Push to main - deploys automatically!"

# =============================================================================
# DOPPLER
# =============================================================================

# Start dev server with Doppler secrets
dev-doppler:
    doppler run -- uv run python manage.py runserver

# Run any command with Doppler secrets
run-doppler *ARGS:
    doppler run -- {{ ARGS }}

# Run migrations with Doppler
migrate-doppler:
    doppler run -- uv run python manage.py migrate

# Run tests with Doppler
test-doppler:
    doppler run -- uv run python manage.py test

# Run Django shell with Doppler
shell-doppler:
    doppler run -- uv run python manage.py shell

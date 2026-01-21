#!/usr/bin/env bash
# Disneybound Planner - Interactive Setup Wizard
# This script guides developers through local environment configuration.
#
# Usage: ./scripts/setup.sh
#        just setup

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print functions
print_header() {
    echo ""
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}  Disneybound Planner Setup Wizard${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo ""
}

print_step() {
    echo -e "${BLUE}>>> $1${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}! $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

# Check if a command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# =============================================================================
# PREREQUISITE CHECKS
# =============================================================================

check_prerequisites() {
    print_step "Checking prerequisites..."
    echo ""

    local all_good=true

    # Check Python
    if command_exists python3; then
        python_version=$(python3 --version 2>&1)
        print_success "$python_version"
    else
        print_error "Python 3 not found. Install Python 3.13+ from python.org"
        all_good=false
    fi

    # Check uv
    if command_exists uv; then
        uv_version=$(uv --version 2>&1)
        print_success "uv $uv_version"
    else
        print_error "uv not found"
        echo "  Install with: curl -LsSf https://astral.sh/uv/install.sh | sh"
        all_good=false
    fi

    # Check just
    if command_exists just; then
        just_version=$(just --version 2>&1)
        print_success "$just_version"
    else
        print_warning "just not found (optional but recommended)"
        echo "  Install with: brew install just OR cargo install just"
    fi

    # Check Node.js (for Tailwind)
    if command_exists node; then
        node_version=$(node --version 2>&1)
        print_success "Node.js $node_version"
    else
        print_warning "Node.js not found (needed for Tailwind CSS)"
        echo "  Install with: brew install node OR from nodejs.org"
    fi

    if [ "$all_good" = false ]; then
        echo ""
        print_error "Please install missing prerequisites and run setup again."
        exit 1
    fi

    echo ""
}

# =============================================================================
# SECRETS MANAGEMENT
# =============================================================================

setup_secrets() {
    print_step "Secrets Management"
    echo ""
    echo "How would you like to manage secrets?"
    echo ""
    echo "  1) Doppler (recommended for teams)"
    echo "     - Centralized secrets management"
    echo "     - Environment-specific configs"
    echo "     - Access control & audit logs"
    echo ""
    echo "  2) Local .env file"
    echo "     - Simple, no external dependencies"
    echo "     - Manual management"
    echo ""

    read -p "Choice [1/2]: " choice
    echo ""

    case "$choice" in
        1)
            setup_doppler
            ;;
        2)
            setup_env_file
            ;;
        *)
            print_warning "Invalid choice, defaulting to .env file"
            setup_env_file
            ;;
    esac
}

setup_doppler() {
    print_step "Setting up Doppler..."
    echo ""

    # Check if Doppler CLI is installed
    if ! command_exists doppler; then
        echo "Doppler CLI not found. Installing..."
        echo ""

        if command_exists brew; then
            brew install dopplerhq/cli/doppler
        else
            curl -Ls --tlsv1.2 --proto "=https" --retry 3 https://cli.doppler.com/install.sh | sh
        fi

        if ! command_exists doppler; then
            print_error "Failed to install Doppler CLI"
            echo "Falling back to .env file setup..."
            setup_env_file
            return
        fi
    fi

    print_success "Doppler CLI installed"
    echo ""

    # Check if already authenticated
    if doppler me &> /dev/null; then
        print_success "Already logged in to Doppler"
    else
        echo "Please log in to Doppler..."
        echo ""
        doppler login
    fi

    echo ""

    # Configure project
    if [ -f ".doppler.yaml" ]; then
        print_success "Doppler already configured for this project"
    else
        echo "Configuring Doppler for this project..."
        echo "Select 'disneybound-planner' project and 'dev' environment"
        echo ""
        doppler setup
    fi

    echo ""

    # Check and set required secrets
    print_step "Checking required secrets in Doppler..."
    echo ""

    check_and_set_doppler_secrets

    # Mark that we're using Doppler
    USING_DOPPLER=true
    export USING_DOPPLER

    print_success "Doppler configured!"
    echo ""
}

check_and_set_doppler_secrets() {
    local missing_secrets=()

    # Check DATABASE_URL
    if doppler secrets get DATABASE_URL --plain 2>/dev/null | grep -q "^postgres"; then
        print_success "DATABASE_URL is set"
    else
        missing_secrets+=("DATABASE_URL")
    fi

    # Check GOOGLE_API_KEY
    if doppler secrets get GOOGLE_API_KEY --plain 2>/dev/null | grep -qv "^$"; then
        print_success "GOOGLE_API_KEY is set"
    else
        missing_secrets+=("GOOGLE_API_KEY")
    fi

    # Check TMDB_API_KEY
    if doppler secrets get TMDB_API_KEY --plain 2>/dev/null | grep -qv "^$"; then
        print_success "TMDB_API_KEY is set"
    else
        missing_secrets+=("TMDB_API_KEY")
    fi

    # Check SECRET_KEY
    if doppler secrets get SECRET_KEY --plain 2>/dev/null | grep -qv "^$"; then
        print_success "SECRET_KEY is set"
    else
        missing_secrets+=("SECRET_KEY")
    fi

    echo ""

    # If secrets are missing, help the user set them
    if [ ${#missing_secrets[@]} -gt 0 ]; then
        print_warning "Some required secrets are missing in Doppler"
        echo ""
        echo "Let's set them up now..."
        echo ""

        for secret in "${missing_secrets[@]}"; do
            case "$secret" in
                DATABASE_URL)
                    echo "DATABASE_URL (Neon Postgres connection string)"
                    echo "  Get one from: https://neon.tech"
                    echo "  Format: postgres://user:pass@ep-xxx.neon.tech/db?sslmode=require"
                    echo ""
                    read -p "Enter DATABASE_URL (or press Enter to skip): " value
                    if [ -n "$value" ]; then
                        doppler secrets set DATABASE_URL="$value"
                        print_success "DATABASE_URL saved to Doppler"
                    else
                        print_warning "DATABASE_URL skipped - database features won't work"
                    fi
                    ;;
                GOOGLE_API_KEY)
                    echo ""
                    echo "GOOGLE_API_KEY (Gemini API for AI features)"
                    echo "  Get one from: https://aistudio.google.com/apikey"
                    echo ""
                    read -p "Enter GOOGLE_API_KEY (or press Enter to skip): " value
                    if [ -n "$value" ]; then
                        doppler secrets set GOOGLE_API_KEY="$value"
                        print_success "GOOGLE_API_KEY saved to Doppler"
                    else
                        print_warning "GOOGLE_API_KEY skipped - AI features won't work"
                    fi
                    ;;
                TMDB_API_KEY)
                    echo ""
                    echo "TMDB_API_KEY (Character thumbnails - optional)"
                    echo "  Get a Read Access Token from: https://www.themoviedb.org/settings/api"
                    echo "  Use the 'Read Access Token' (starts with 'eyJ...')"
                    echo ""
                    read -p "Enter TMDB_API_KEY (or press Enter to skip): " value
                    if [ -n "$value" ]; then
                        doppler secrets set TMDB_API_KEY="$value"
                        print_success "TMDB_API_KEY saved to Doppler"
                    else
                        print_warning "TMDB_API_KEY skipped - character thumbnails won't load"
                    fi
                    ;;
                SECRET_KEY)
                    echo ""
                    echo "Generating Django SECRET_KEY..."
                    secret_key=$(python3 -c "import secrets; print(secrets.token_urlsafe(50))")
                    doppler secrets set SECRET_KEY="$secret_key"
                    print_success "SECRET_KEY generated and saved to Doppler"
                    ;;
            esac
        done

        echo ""
    fi
}

setup_env_file() {
    print_step "Setting up .env file..."
    echo ""

    if [ -f ".env" ]; then
        print_success ".env file already exists"
        read -p "Do you want to reconfigure it? [y/N]: " reconfigure
        if [[ ! "$reconfigure" =~ ^[Yy]$ ]]; then
            USING_DOPPLER=false
            export USING_DOPPLER
            return
        fi
    fi

    # Copy template
    if [ -f ".env.example" ]; then
        cp .env.example .env
        print_success "Created .env from template"
    else
        touch .env
        print_warning "No .env.example found, created empty .env"
    fi

    echo ""
    echo "Let's configure your secrets..."
    echo ""

    # DATABASE_URL
    echo "DATABASE_URL (Neon Postgres connection string)"
    echo "  Get one from: https://neon.tech"
    echo "  Format: postgres://user:pass@ep-xxx.neon.tech/db?sslmode=require"
    echo ""
    read -p "DATABASE_URL (or press Enter to skip): " db_url
    if [ -n "$db_url" ]; then
        if grep -q "^DATABASE_URL=" .env; then
            sed -i.bak "s|^DATABASE_URL=.*|DATABASE_URL=$db_url|" .env && rm -f .env.bak
        else
            echo "DATABASE_URL=$db_url" >> .env
        fi
        print_success "DATABASE_URL set"
    else
        print_warning "DATABASE_URL skipped - you'll need to set this before running migrations"
    fi

    echo ""

    # GOOGLE_API_KEY
    echo "GOOGLE_API_KEY (Gemini API for AI features)"
    echo "  Get one from: https://aistudio.google.com/apikey"
    echo ""
    read -p "GOOGLE_API_KEY (or press Enter to skip): " api_key
    if [ -n "$api_key" ]; then
        if grep -q "^GOOGLE_API_KEY=" .env; then
            sed -i.bak "s|^GOOGLE_API_KEY=.*|GOOGLE_API_KEY=$api_key|" .env && rm -f .env.bak
        else
            echo "GOOGLE_API_KEY=$api_key" >> .env
        fi
        print_success "GOOGLE_API_KEY set"
    else
        print_warning "GOOGLE_API_KEY skipped - AI features won't work until this is set"
    fi

    echo ""

    # TMDB_API_KEY
    echo "TMDB_API_KEY (Character thumbnails - optional)"
    echo "  Get a Read Access Token from: https://www.themoviedb.org/settings/api"
    echo "  Use the 'Read Access Token' (starts with 'eyJ...')"
    echo ""
    read -p "TMDB_API_KEY (or press Enter to skip): " tmdb_key
    if [ -n "$tmdb_key" ]; then
        if grep -q "^TMDB_API_KEY=" .env; then
            sed -i.bak "s|^TMDB_API_KEY=.*|TMDB_API_KEY=$tmdb_key|" .env && rm -f .env.bak
        else
            echo "TMDB_API_KEY=$tmdb_key" >> .env
        fi
        print_success "TMDB_API_KEY set"
    else
        print_warning "TMDB_API_KEY skipped - character thumbnails won't load"
    fi

    echo ""

    # SECRET_KEY
    echo "Generating Django SECRET_KEY..."
    secret_key=$(python3 -c "import secrets; print(secrets.token_urlsafe(50))")
    if grep -q "^SECRET_KEY=" .env; then
        # Only replace if it's still the placeholder
        if grep -q "^SECRET_KEY=your-secret-key" .env; then
            sed -i.bak "s|^SECRET_KEY=.*|SECRET_KEY=$secret_key|" .env && rm -f .env.bak
            print_success "SECRET_KEY generated"
        else
            print_success "SECRET_KEY already configured"
        fi
    else
        echo "SECRET_KEY=$secret_key" >> .env
        print_success "SECRET_KEY generated"
    fi

    USING_DOPPLER=false
    export USING_DOPPLER

    echo ""
    print_success "Environment file configured!"
    echo ""
}

# =============================================================================
# DEPENDENCIES
# =============================================================================

install_dependencies() {
    print_step "Installing dependencies..."
    echo ""

    uv sync

    print_success "Dependencies installed!"
    echo ""
}

# =============================================================================
# DATABASE
# =============================================================================

setup_database() {
    print_step "Database setup..."
    echo ""

    # Determine how to run commands based on secrets management
    # Check for .doppler.yaml as the definitive marker for Doppler usage
    if [ -f ".doppler.yaml" ] && [ "${USING_DOPPLER:-false}" = true ]; then
        # Verify Doppler has DATABASE_URL before proceeding
        if ! doppler secrets get DATABASE_URL --plain 2>/dev/null | grep -q "^postgres"; then
            print_warning "DATABASE_URL not set in Doppler"
            echo "  Run 'doppler secrets set DATABASE_URL=your-url' to configure"
            echo "  Then run 'just migrate-doppler' to complete setup"
            echo ""
            return
        fi

        echo "Testing database connection (via Doppler)..."
        if doppler run -- uv run python manage.py check --database default 2>&1 | grep -q "no issues"; then
            print_success "Database connection successful!"
            echo ""

            # Run migrations
            echo "Running migrations..."
            doppler run -- uv run python manage.py migrate
            print_success "Migrations complete!"
        else
            print_warning "Database connection failed"
            echo "  Verify your DATABASE_URL in Doppler is correct"
            echo "  You can run 'just migrate-doppler' later once fixed"
        fi
    else
        # Using .env file
        if [ ! -f ".env" ]; then
            print_warning "No .env file found"
            echo "  Run 'just setup' again or create .env manually"
            echo ""
            return
        fi

        # Check if DATABASE_URL is set (not just the placeholder)
        if grep -q "^DATABASE_URL=postgres://user:password" .env 2>/dev/null; then
            print_warning "DATABASE_URL still has placeholder value"
            echo "  Edit .env and set your Neon connection string"
            echo "  Then run 'just migrate' to complete setup"
            echo ""
            return
        fi

        echo "Testing database connection..."
        if uv run python manage.py check --database default 2>&1 | grep -q "no issues"; then
            print_success "Database connection successful!"
            echo ""

            # Run migrations
            echo "Running migrations..."
            uv run python manage.py migrate
            print_success "Migrations complete!"
        else
            print_warning "Database connection failed"
            echo "  Make sure DATABASE_URL is set correctly in .env"
            echo "  You can run 'just migrate' later once configured"
        fi
    fi

    echo ""
}

# =============================================================================
# TAILWIND CSS
# =============================================================================

setup_tailwind() {
    print_step "Tailwind CSS setup..."
    echo ""

    # Check if theme app already exists
    if [ -d "theme" ]; then
        print_success "Tailwind theme app exists"

        # Build Tailwind CSS
        echo "Building Tailwind CSS..."
        uv run python manage.py tailwind build 2>/dev/null
        print_success "Tailwind CSS built!"
    else
        print_warning "Tailwind theme app not found"
        echo ""
        echo "To set up Tailwind, run interactively:"
        echo "  uv run python manage.py tailwind init"
        echo ""
        echo "Then select:"
        echo "  - App name: theme"
        echo "  - Template: 1 (Tailwind v4 Standalone)"
        echo ""
        echo "After init, add 'theme' to INSTALLED_APPS in config/settings.py"
        echo "Then run: uv run python manage.py tailwind build"
    fi

    echo ""
}

# =============================================================================
# BAML
# =============================================================================

setup_baml() {
    print_step "BAML setup..."
    echo ""

    if [ -d "baml" ]; then
        echo "Generating BAML client..."
        uv run baml-cli generate
        print_success "BAML client generated!"
    else
        print_warning "No baml/ directory found, skipping BAML setup"
    fi

    echo ""
}

# =============================================================================
# VERIFICATION
# =============================================================================

verify_setup() {
    print_step "Running verification..."
    echo ""

    # Check for .doppler.yaml as the definitive marker for Doppler usage
    if [ -f ".doppler.yaml" ] && [ "${USING_DOPPLER:-false}" = true ]; then
        if doppler run -- uv run python manage.py check 2>&1 | grep -q "no issues"; then
            print_success "Django check passed!"
        else
            print_warning "Django check had issues - review the output above"
        fi
    else
        if uv run python manage.py check 2>&1 | grep -q "no issues"; then
            print_success "Django check passed!"
        else
            print_warning "Django check had issues - review the output above"
        fi
    fi

    echo ""
}

# =============================================================================
# COMPLETION
# =============================================================================

print_completion() {
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}  Setup Complete!${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo ""
    echo "Next steps:"
    echo ""

    if [ "${USING_DOPPLER:-false}" = true ]; then
        echo "  Start dev server:  just dev-doppler"
        echo "                     (or: doppler run -- uv run python manage.py runserver)"
    else
        echo "  Start dev server:  just dev"
    fi

    echo ""
    echo "  Run tests:         just test"
    echo "  View all commands: just"
    echo ""
    echo "Happy Disneybounding!"
    echo ""
}

# =============================================================================
# MAIN
# =============================================================================

main() {
    print_header
    check_prerequisites
    setup_secrets
    install_dependencies
    setup_tailwind
    setup_database
    setup_baml
    verify_setup
    print_completion
}

# Run if executed directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi

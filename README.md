# Disneybound Planner

Plan Disney-inspired everyday outfits for your theme park visits. "Disneybounding" is the practice of wearing regular clothes that evoke Disney characters (since adults cannot wear costumes in Disney parks).

## Features

- **Character Browser** - Browse Disney characters by category (Princesses, Villains, Pixar, Marvel, Star Wars)
- **Outfit Builder** - Create outfits with structured items (top, bottom, shoes, accessories)
- **AI Suggestions** - Get LLM-powered outfit recommendations via Gemini 2.5
- **Trip Calendar** - Assign outfits to specific days of your vacation
- **User Accounts** - Save outfit lists and manage trips

## Tech Stack

| Component | Technology | Version |
|-----------|------------|---------|
| Runtime | Python | 3.13 |
| Framework | Django | 6.0.1 |
| Database | Neon (Serverless Postgres) | - |
| Frontend | HTMX + Tailwind CSS | 2.0+ / 4.x |
| Templates | django-components | 0.144.0 |
| Auth | django-allauth | 65.14.0 |
| LLM | BAML + Gemini 2.5 | 0.217.0 |
| Compute | Fly.io | scale-to-zero |
| CI/CD | GitHub Actions | - |

## Quick Start

### Prerequisites

- Python 3.13+
- [uv](https://github.com/astral-sh/uv) package manager
- [just](https://github.com/casey/just) command runner
- Node.js (for Tailwind CSS)

### Local Setup

```bash
# Clone the repository
git clone https://github.com/yourusername/disneybound-planner.git
cd disneybound-planner

# Run the interactive setup wizard
just setup
```

The setup wizard will:
1. Check prerequisites (Python, uv, Node.js)
2. Let you choose between **Doppler** (recommended for teams) or local **.env** file
3. Guide you through configuring secrets (DATABASE_URL, GOOGLE_API_KEY)
4. Install dependencies
5. Run database migrations
6. Generate BAML client

#### Secrets Management Options

| Method | Best For | Command |
|--------|----------|---------|
| **Doppler** | Teams, centralized secrets | `just setup` then select Doppler |
| **.env file** | Solo development, quick start | `just setup` then select .env |

After setup, start the development server:

```bash
# With .env file
just dev

# With Doppler
just dev-doppler
```

Visit http://localhost:8000 to see the app.

## Deployment

This project deploys to **Fly.io** with **Neon** for the database. Push to `main` and it auto-deploys.

### First-Time Setup

```bash
# 1. Create Neon project at neon.tech, copy connection string

# 2. Launch Fly app (skip their database option)
fly launch

# 3. Set secrets
just db-url "postgres://user:pass@ep-xxx.neon.tech/db?sslmode=require"
just secret SECRET_KEY $(just gen-secret-key)
just secret GOOGLE_API_KEY your-api-key

# 4. Add FLY_API_TOKEN to GitHub repo secrets

# 5. Push to main - deploys automatically!
git push origin main
```

### Day-to-Day

```bash
just dev      # Local development
just test     # Run tests
git push      # Deploy to production
just logs     # View production logs
```

## Project Structure

```
disneybound_planner/
├── apps/                    # Django applications
│   ├── accounts/           # User authentication
│   ├── characters/         # Disney character data
│   ├── outfits/            # Outfit builder
│   ├── trips/              # Trip planning
│   ├── scraping/           # Web scraping pipelines
│   └── ai/                 # BAML/LLM integration
├── config/                  # Django settings
├── templates/               # HTML templates
│   ├── base.html           # Site-wide base
│   ├── layouts/            # Section layouts
│   └── components/         # Reusable components
├── static/css/              # Semantic Tailwind CSS
├── baml/                    # BAML schema definitions
├── docs/                    # Project documentation
├── .github/workflows/       # GitHub Actions CI/CD
├── Dockerfile               # Production container
├── fly.toml                 # Fly.io configuration
└── justfile                 # Project commands
```

## Commands

Run `just` to see all available commands:

```bash
# Setup
just setup            # Interactive setup wizard
just setup-doppler    # Setup with Doppler (skip prompts)
just setup-env        # Setup with .env file (skip prompts)

# Development
just dev              # Start Django dev server (uses .env)
just dev-doppler      # Start Django dev server (uses Doppler)
just test             # Run tests
just migrate          # Run migrations
just shell            # Django shell

# Quality
just lint             # Run linter
just format           # Format code
just check            # Run lint + tests

# Deployment
just deploy           # Deploy to Fly.io
just logs             # View production logs
just secrets          # List secrets
just ssh              # SSH into production

# Maintenance
just update-packages  # Update all packages
just clean            # Clean cache files
```

## Documentation

- [`docs/OVERVIEW.md`](docs/OVERVIEW.md) - Project dashboard and task tracking
- [`docs/knowledge/specification.md`](docs/knowledge/specification.md) - Full project specification
- [`docs/knowledge/patterns/AGENT_PLAYBOOK.md`](docs/knowledge/patterns/AGENT_PLAYBOOK.md) - Guide for coding agents

## CSS Architecture

Semantic CSS approach with Tailwind - component classes instead of utility soup:

```css
/* static/css/components.css */
@layer components {
  .btn { @apply px-4 py-2 rounded-lg font-medium transition-colors; }
  .btn-primary { @apply bg-disney-blue text-white hover:bg-disney-blue-dark; }
  .card { @apply bg-white rounded-xl shadow-sm border border-gray-100; }
}
```

```html
<div class="card">
  <button class="btn btn-primary">Save Outfit</button>
</div>
```

## Environment Variables

| Variable | Description |
|----------|-------------|
| `DEBUG` | Enable debug mode (local only) |
| `SECRET_KEY` | Django secret key |
| `DATABASE_URL` | Neon Postgres connection URL |
| `GOOGLE_API_KEY` | Gemini API key for AI features |

## Contributing

1. Check `docs/OVERVIEW.md` for active tickets
2. Follow the playbook in `docs/knowledge/patterns/AGENT_PLAYBOOK.md`
3. Run `just check` before submitting

## License

MIT License

---

**Disclaimer**: This is a fan project. Not affiliated with The Walt Disney Company.

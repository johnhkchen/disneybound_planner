# Disneybound Planner - Project Specification

> **Version**: 1.0.0
> **Last Updated**: 2026-01-20
> **Status**: Active

---

## Executive Summary

Disneybound Planner is a web application that helps users plan Disney-inspired everyday outfits for theme park visits. "Disneybounding" is the practice of wearing regular clothes that evoke Disney characters (since adults cannot wear costumes in Disney parks). The app provides character browsing, outfit building with AI suggestions, trip calendar planning, and saved wardrobe management.

---

## Business Model

### Value Proposition

1. **Outfit Inspiration**: Browse Disney characters organized by category with color palettes
2. **Smart Planning**: Build outfits with AI-powered suggestions matching character aesthetics
3. **Trip Organization**: Assign outfits to specific days of your Disney vacation
4. **Personal Wardrobe**: Save and manage outfit collections across trips

### Target Users

- Disney park enthusiasts planning vacations
- Fashion-conscious visitors wanting coordinated looks
- Families coordinating group Disneybounds
- Content creators documenting park outfits

### Revenue Model (Future)

- Freemium: Basic features free, premium for AI suggestions/unlimited saves
- Affiliate: Product links to clothing retailers
- Potential subscription for advanced planning features

---

## Service Rendered

### Core Features

| Feature | Description | Priority |
|---------|-------------|----------|
| **Character Browser** | Browse characters by category (Princesses, Villains, Pixar, Marvel, Star Wars) | P0 |
| **Outfit Builder** | Create outfits with structured items (top, bottom, shoes, accessories) | P0 |
| **AI Suggestions** | LLM-powered outfit recommendations based on character | P0 |
| **Trip Calendar** | Assign outfits to dates, simple list view | P1 |
| **User Accounts** | Save outfit lists, manage trips | P0 |
| **Scraping Pipeline** | Populate character data and shopping suggestions | P1 |

### User Flows

```
1. DISCOVERY
   Browse Categories → Select Character → View Color Palette → Start Outfit

2. CREATION
   Select Character → Add Items → Get AI Suggestions → Save Outfit

3. PLANNING
   Create Trip → Add Dates → Assign Outfits → Review Calendar

4. MANAGEMENT
   View Saved Outfits → Edit/Delete → Organize by Trip
```

### Data Model Overview

```
User
  └── Trip (many)
        └── TripDay (many)
              └── Outfit (one per day)
                    └── OutfitItem (many)
                          └── Character (reference)

Character
  └── Category (reference)
  └── ColorPalette (embedded)

OutfitItem
  └── ItemType (top/bottom/shoes/accessory)
  └── ProductLink (optional)
  └── Image (optional)
```

---

## Technology Stack

### Backend

| Component | Technology | Version | Purpose |
|-----------|------------|---------|---------|
| **Runtime** | Python | 3.13 | Latest stable Python |
| **Framework** | Django | 6.0.1 | Web framework with native partials |
| **Database** | PostgreSQL | 16 | Relational data storage |
| **DB Adapter** | psycopg | 3.3.2 | Async PostgreSQL driver |
| **Auth** | django-allauth | 65.14.0 | Authentication + social login |
| **Package Manager** | uv | latest | Fast Python package management |

### Frontend

| Component | Technology | Version | Purpose |
|-----------|------------|---------|---------|
| **Interactivity** | HTMX | 2.0+ | Dynamic UI without JavaScript |
| **Styling** | Tailwind CSS | 4.x | Utility-first CSS |
| **Templates** | django-components | 0.144.0 | Reusable template components |
| **Partials** | Django 6.0 native | - | HTMX partial rendering |

### AI / LLM

| Component | Technology | Version | Purpose |
|-----------|------------|---------|---------|
| **LLM Framework** | BAML | 0.217.0 | Structured LLM calls |
| **LLM Provider** | Gemini 2.5 | latest | Outfit suggestions, color matching |

### Infrastructure

| Component | Technology | Purpose |
|-----------|------------|---------|
| **Compute** | Fly.io | Production hosting (scale-to-zero) |
| **Database** | Neon | Serverless Postgres |
| **Secrets** | fly secrets | Secret management |
| **CI/CD** | GitHub Actions | Automated testing & deployment |
| **Web Server** | Gunicorn | Production WSGI |
| **Static Files** | WhiteNoise | Serve static in production |
| **Task Runner** | just | Project commands |

### Development Tools

| Tool | Purpose |
|------|---------|
| **Linter** | ruff |
| **Type Checker** | mypy + django-stubs |
| **Testing** | pytest + pytest-django |
| **Pre-commit** | Git hooks |

---

## Architecture

### Directory Structure

```
disneybound_planner/
├── apps/                    # Django applications
│   ├── accounts/           # User auth, profiles
│   ├── characters/         # Character models, categories
│   ├── outfits/            # Outfit builder, items
│   ├── trips/              # Trip planning, calendar
│   ├── scraping/           # Web scraping pipelines
│   └── ai/                 # BAML definitions, LLM integration
├── config/                  # Django project settings
│   ├── settings.py
│   ├── urls.py
│   └── wsgi.py
├── templates/               # Template hierarchy
│   ├── base.html           # Site-wide base
│   ├── layouts/            # Section-specific layouts
│   ├── components/         # Reusable components
│   └── partials/           # HTMX partial templates
├── static/                  # Static assets
│   ├── css/
│   │   ├── main.css       # Tailwind entry point
│   │   └── components.css # Semantic component classes
│   ├── js/
│   └── images/
├── baml/                    # BAML schema definitions
├── docs/                    # Project documentation
│   ├── OVERVIEW.md         # Project dashboard
│   ├── active/             # Current work
│   ├── archive/            # Completed work
│   └── knowledge/          # Knowledge base
├── .github/workflows/       # GitHub Actions
│   └── deploy.yml          # CI/CD pipeline
├── Dockerfile               # Production container
├── fly.toml                 # Fly.io configuration
├── justfile                 # Project commands
├── pyproject.toml          # Python project config
└── README.md               # Project readme
```

### Template Architecture

**Three-Layer Hierarchy**:
1. `base.html` - Site-wide structure (head, nav, footer)
2. `layouts/*.html` - Section layouts (outfits, trips, characters)
3. `components/*.html` - Reusable UI components

**Semantic CSS Strategy**:
- Define component classes in `static/css/components.css`
- Use `@layer components` for Tailwind integration
- Templates use semantic classes, not inline utilities

```css
/* components.css */
@layer components {
  .btn { @apply px-4 py-2 rounded-lg font-medium transition-colors; }
  .btn-primary { @apply bg-disney-blue text-white hover:bg-disney-blue-dark; }
  .card { @apply bg-white rounded-xl shadow-sm border border-gray-100; }
  .outfit-card { @apply card p-4 hover:shadow-md transition-shadow; }
}
```

### HTMX Patterns

**Inline Partials**: Define partials within main templates, render conditionally:

```html
{% partialdef outfit-card inline %}
<div id="outfit-{{ outfit.id }}" class="outfit-card">
  {{ outfit.name }}
</div>
{% endpartialdef %}
```

**Progressive Enhancement**: Full page works without JS, HTMX enhances:

```python
def outfit_list(request):
    outfits = Outfit.objects.filter(user=request.user)
    template = "outfits/list.html#outfit-list" if request.htmx else "outfits/list.html"
    return render(request, template, {"outfits": outfits})
```

---

## API Contracts

### Internal (Views)

Views return HTML (server-rendered), not JSON. HTMX requests get partial HTML.

### External (BAML/LLM)

```baml
function SuggestOutfit {
  input {
    character: Character
    user_preferences: UserPreferences
    existing_items: list<ClothingItem>
  }
  output {
    suggestions: list<OutfitSuggestion>
    reasoning: string
  }
}
```

---

## Security Considerations

1. **Authentication**: django-allauth with secure defaults
2. **CSRF**: Django's built-in protection for all forms
3. **SQL Injection**: Django ORM prevents injection
4. **XSS**: Django auto-escapes templates
5. **Secrets**: Environment variables, never in code
6. **Rate Limiting**: On scraping endpoints and AI calls

---

## Performance Targets

| Metric | Target |
|--------|--------|
| Page Load (TTFB) | < 200ms |
| LLM Response | < 5s |
| Database Queries | < 10 per page |
| Static Assets | CDN/WhiteNoise cached |

---

## Testing Strategy

1. **Unit Tests**: Models, utilities, BAML functions
2. **Integration Tests**: Views, database operations
3. **E2E Tests**: Critical user flows (future)
4. **Coverage Target**: 80%+

```bash
just test              # Run all tests
just test-cov          # With coverage report
```

---

## Deployment

| Component | Service |
|-----------|---------|
| Compute | Fly.io (scale-to-zero) |
| Database | Neon (serverless Postgres) |
| Secrets | fly secrets |
| CI/CD | GitHub Actions |

### Setup (one-time)

1. Create Neon project at neon.tech, copy connection string
2. `fly launch` (creates app, skip database)
3. `just db-url "postgres://..."` (sets DATABASE_URL)
4. `just secret SECRET_KEY $(just gen-secret-key)`
5. `just secret GOOGLE_API_KEY your-api-key`
6. Add `FLY_API_TOKEN` to GitHub repo secrets
7. Push to main — deploys automatically

### Day-to-day

- `just dev` — local development
- `just test` — run tests
- `git push` — auto-deploys via GitHub Actions
- `just logs` — view production logs

---

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2026-01-20 | Initial specification |

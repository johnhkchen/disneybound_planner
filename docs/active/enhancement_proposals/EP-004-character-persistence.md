# EP-004: Character Data Persistence & Thumbnails

> **Status**: Complete
> **Created**: 2026-01-20
> **Completed**: 2026-01-21
> **Sprint**: 2
> **Author**: Agent

---

## Summary

Cache LLM-generated character search results in the Neon database and fetch character thumbnails to reduce API costs and improve user experience with visual character cards.

## Motivation

Currently, every character search triggers a fresh LLM API call to Google Gemini. This has several drawbacks:

1. **Cost**: Each search costs money, even for previously searched characters
2. **Latency**: LLM calls take 2-5 seconds, making repeat searches unnecessarily slow
3. **No visuals**: Character results are text-only, lacking the visual appeal of character images
4. **No persistence**: Popular character data is regenerated constantly

### User Stories

> As a user, I want to see a picture of the character I searched for so I can visually confirm it's the right one.

> As a user, I want my searches to be fast when looking up popular characters that others have searched before.

> As a developer, I want to minimize LLM API costs by caching character data.

## Proposed Solution

### 1. Character Model for Persistence

Create a Django model to store character search results:

```python
class Character(models.Model):
    # Core identification
    name = models.CharField(max_length=255, db_index=True)
    movie = models.CharField(max_length=255)
    category = models.CharField(max_length=100)  # Princess, Villain, Pixar, etc.
    description = models.TextField()

    # Search metadata
    search_queries = ArrayField(models.CharField(max_length=255))  # Queries that matched this character

    # Visual assets
    thumbnail_url = models.URLField(blank=True)
    image_attribution = models.CharField(max_length=500, blank=True)

    # Color palette (JSON or separate model)
    colors = models.JSONField(default=list)  # [{hex, name, usage}, ...]

    # Timestamps
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        indexes = [
            models.Index(fields=['name']),
            GinIndex(fields=['search_queries']),  # For array search
        ]
```

### 2. Search Flow with Caching

```
User Search Query
       │
       ▼
┌─────────────────────┐
│ Normalize query     │
│ (lowercase, trim)   │
└─────────────────────┘
       │
       ▼
┌─────────────────────┐     Found?     ┌─────────────────────┐
│ Check DB cache      │────────────────►│ Return cached       │
│ (exact + fuzzy)     │      Yes        │ character           │
└─────────────────────┘                 └─────────────────────┘
       │ No
       ▼
┌─────────────────────┐
│ Call LLM API        │
│ (BAML/Gemini)       │
└─────────────────────┘
       │
       ▼
┌─────────────────────┐
│ Fetch thumbnail     │
│ (async background)  │
└─────────────────────┘
       │
       ▼
┌─────────────────────┐
│ Save to database    │
│ + return result     │
└─────────────────────┘
```

### 3. Thumbnail Sources (Priority Order)

1. **TMDB (The Movie Database)** - High quality, official images, free API tier
2. **Disney Fandom Wiki** - Comprehensive Disney character images
3. **Generated placeholder** - Color-based placeholder using character's palette

### 4. Cache Matching Strategy

- **Exact match**: Query matches `name` field (case-insensitive)
- **Query history**: Query exists in `search_queries` array
- **Fuzzy match**: Trigram similarity > 0.6 using `pg_trgm` extension

### Affected Components

- [x] `apps/characters/models.py` - Add Character model with fields
- [x] `apps/characters/views.py` - Update search to check cache first, add catalog and detail views
- [x] `apps/characters/services.py` - New file for thumbnail fetching logic
- [x] `apps/characters/migrations/` - Database migrations
- [x] `apps/characters/admin.py` - Admin registration for Character model
- [x] `templates/characters/list.html` - Character catalog with category filtering
- [x] `templates/characters/detail.html` - Character detail page
- [x] `templates/characters/partials/search_results.html` - Update to show thumbnails
- [x] `config/settings.py` - Add TMDB API key configuration
- [x] `justfile` - Add TMDB setup instructions
- [x] `scripts/setup.sh` - Add TMDB API key prompts
- [x] `.env.example` - Add TMDB_API_KEY placeholder

## Acceptance Criteria

- [x] Character searches check database before calling LLM
- [x] Cached results return instantly (database lookup)
- [x] New characters are persisted after LLM lookup
- [x] Character cards display thumbnail images when available
- [x] Search queries are tracked in `search_queries` array for cache optimization
- [x] Graceful fallback when thumbnail fetch fails (gradient placeholder)
- [x] Character catalog displays all cached characters
- [x] Category filtering on catalog page
- [x] Character detail page with full color palette
- [ ] Fuzzy matching finds characters with slight query variations (deferred to future EP)

## Technical Details

### Database Schema

```sql
CREATE TABLE characters_character (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    movie VARCHAR(255) NOT NULL,
    category VARCHAR(100) NOT NULL,
    description TEXT NOT NULL,
    search_queries TEXT[] NOT NULL DEFAULT '{}',
    thumbnail_url VARCHAR(500),
    image_attribution VARCHAR(500),
    colors JSONB NOT NULL DEFAULT '[]',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes for search performance
CREATE INDEX idx_character_name ON characters_character(LOWER(name));
CREATE INDEX idx_character_queries ON characters_character USING GIN(search_queries);

-- Enable trigram extension for fuzzy search
CREATE EXTENSION IF NOT EXISTS pg_trgm;
CREATE INDEX idx_character_name_trgm ON characters_character USING GIN(name gin_trgm_ops);
```

### Color Storage Format

```json
{
  "colors": [
    {"hex": "#FFD700", "name": "Bright Yellow", "usage": "Primary body color"},
    {"hex": "#40E0D0", "name": "Turquoise Blue", "usage": "Stripe color"},
    {"hex": "#00008B", "name": "Dark Blue", "usage": "Fin accents"}
  ]
}
```

### TMDB API Integration

```python
# apps/characters/services.py
import httpx

TMDB_API_KEY = settings.TMDB_API_KEY
TMDB_BASE_URL = "https://api.themoviedb.org/3"

async def fetch_character_thumbnail(character_name: str, movie_name: str) -> str | None:
    """Fetch character image from TMDB."""
    # Search for the movie
    # Get cast/characters
    # Find matching character
    # Return profile image URL
    ...
```

## Linked Tickets

| Ticket | Title | Status |
|--------|-------|--------|
| T-012 | Create Character model and migrations | Pending |
| T-013 | Implement cache-first search logic | Pending |
| T-014 | Add TMDB thumbnail fetching service | Pending |
| T-015 | Update search results UI with thumbnails | Pending |
| T-016 | Add fuzzy search with pg_trgm | Pending |

## Open Questions

- [ ] Should we pre-populate the database with popular characters?
- [ ] How long should cached character data be considered fresh?
- [ ] Should we allow users to suggest corrections to character data?
- [ ] Rate limiting for TMDB API (free tier limits)?
- [ ] Fallback image strategy - generated avatar or generic Disney icon?

## Alternatives Considered

### 1. Redis Cache Only
- **Pros**: Fast, simple key-value storage
- **Cons**: No fuzzy search, no persistence across restarts, additional infrastructure

### 2. Store Images Locally (S3/Cloudflare R2)
- **Pros**: Full control, no external dependencies
- **Cons**: Storage costs, copyright concerns, maintenance overhead

### 3. Wikipedia/Wikidata API
- **Pros**: Free, comprehensive
- **Cons**: Image quality varies, complex API, licensing complications

**Decision**: TMDB offers the best balance of quality, availability, and API simplicity for Disney character images.

## Notes

- TMDB free tier: 1000 requests/day, sufficient for our scale
- Neon Postgres supports `pg_trgm` extension for fuzzy search
- Consider background job (Celery/Django-Q) for thumbnail fetching to not block search
- Image URLs should be cached, not the images themselves (TMDB ToS)

---

## Changelog

| Date | Change |
|------|--------|
| 2026-01-20 | Created |
| 2026-01-21 | Implemented: Character model, cache-first search, TMDB integration, catalog browsing, detail pages |
| 2026-01-21 | Deferred fuzzy matching (pg_trgm) to future enhancement |

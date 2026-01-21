# EP-002: Character Search by Name

> **Status**: Implemented
> **Created**: 2026-01-20
> **Sprint**: 1
> **Author**: Agent

---

## Summary

Add the ability to search for Disney characters by name, enabling users to quickly find characters like "Flounder" from The Little Mermaid and view their color palettes for Disneybound outfit planning.

## Motivation

Users want to plan outfits inspired by specific Disney characters. Currently, there's no way to search for a character by name. This feature enables the core use case of the app: finding a character (e.g., Flounder), viewing their signature colors, and using those colors to plan an outfit.

### User Story

> As a Disneybound planner, I want to search for "Flounder" and see his color palette (bright yellow and blue stripes) so I can plan an outfit inspired by him for my Disney park visit.

## Proposed Solution

Implement a character search feature that:
1. Accepts a character name query
2. Uses an LLM API (Google Gemini) to identify the character and extract color information
3. Returns character details including name, source film, and color palette
4. Displays results in a user-friendly card format

### Technical Approach

1. **Search Input**: Add a search bar to the characters page with HTMX for async submission
2. **LLM Integration**: Use BAML + Google Gemini to:
   - Identify the character from the search query
   - Extract character metadata (name, film, description)
   - Generate a color palette based on the character's appearance
3. **Response Rendering**: Display character card with color swatches using existing component styles

### Architecture

```
User Input → HTMX Request → Django View → BAML/Gemini API → Character Data → Template Render
```

### Affected Components

- [x] `apps/characters/` - Add search view and URL
- [x] `baml_src/` - Define character extraction schema and SearchCharacter function
- [x] `templates/characters/` - Add search UI and results template
- [x] `templates/characters/partials/` - Add HTMX partial for search results

## Acceptance Criteria

- [x] User can enter a character name in a search field
- [x] Search returns character info including name, source film, and description
- [x] Search returns a color palette (3-5 colors) representing the character
- [x] Results display using existing card and color swatch components
- [x] Search handles unknown characters gracefully with helpful message
- [x] Works with partial/fuzzy names (e.g., "Flounder", "the fish from little mermaid")

## Test Case: Flounder

**Input**: "Flounder" or "Flounder from The Little Mermaid"

**Expected Output**:
- Name: Flounder
- Film: The Little Mermaid (1989)
- Description: Ariel's loyal tropical fish companion, known for being easily frightened but brave when it counts
- Colors:
  - Bright Yellow (#FFD700) - Primary body color
  - Turquoise Blue (#40E0D0) - Stripe color
  - Light Yellow (#FFFFE0) - Belly/accent
  - Dark Blue (#00008B) - Fin accents

## Linked Tickets

| Ticket | Title | Status |
|--------|-------|--------|
| T-004 | Create BAML character extraction function | Done |
| T-005 | Add character search view and URL | Done |
| T-006 | Build search UI with HTMX | Done |

## Open Questions

- [ ] Should we cache character results to reduce API calls?
- [ ] How do we handle characters with multiple appearances (e.g., live action vs animated)?
- [ ] Should we include reference images or just color palettes?

## Notes

- Google Gemini API key is already configured in production
- BAML is set up in the project for LLM orchestration
- Existing color swatch components in `components.css` can be reused

---

## Changelog

| Date | Change |
|------|--------|
| 2026-01-20 | Created |
| 2026-01-20 | Implemented: BAML SearchCharacter function, search view/URL, HTMX search UI |

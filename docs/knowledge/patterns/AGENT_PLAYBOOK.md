# Agent Playbook

This playbook guides coding agents through working on this project.

---

## Getting Started

### 1. Check the Dashboard

Always start by reading `docs/OVERVIEW.md` to understand:
- Current sprint and priorities
- Active Enhancement Proposals
- Available tickets

### 2. Understand the Codebase

```bash
# Quick codebase overview
just overview

# Run the development server
just dev

# Check project status
just status
```

### 3. Pick Work

Choose from active tickets in `docs/active/tickets/`. Priority order:
1. **Critical** - Security/breaking issues
2. **High** - Blocking other work
3. **Medium** - Sprint goals
4. **Low** - Nice to have

---

## Workflow

### Starting a Ticket

1. **Update ticket status** to "In Progress" in:
   - `docs/OVERVIEW.md` (dashboard table)
   - The ticket file itself

2. **Read the ticket thoroughly**:
   - Understand acceptance criteria
   - Check linked EP for context
   - Review any dependencies

3. **Plan your approach**:
   - List files to modify
   - Consider edge cases
   - Note any questions

### During Development

1. **Make incremental commits** with clear messages
2. **Update ticket work log** with progress
3. **Ask questions** if anything is unclear
4. **Run tests frequently**: `just test`
5. **Run linter**: `just lint`

### Completing a Ticket

1. **Verify all acceptance criteria** are met
2. **Run full test suite**: `just test`
3. **Update ticket status** to "Done"
4. **Update OVERVIEW.md** dashboard
5. **Document learnings** in knowledge base if applicable

---

## Creating New Work

### When to Create an Enhancement Proposal

- New feature requests
- Significant architectural changes
- Multi-ticket initiatives
- Any work spanning multiple sprints

### When to Create a Ticket

- Bug fixes
- Small improvements
- Tasks within an existing EP
- Documentation updates

### Standalone Tickets

If a ticket doesn't fit an existing EP:
1. Create a minimal EP first, OR
2. Amend it to the most relevant existing EP

**Never leave tickets unlinked to an EP.**

---

## Common Commands

```bash
# Development
just dev              # Start Django dev server
just db               # Start PostgreSQL
just shell            # Django shell
just migrate          # Run migrations
just makemigrations   # Create migrations

# Quality
just test             # Run pytest
just lint             # Run ruff linter
just format           # Format code
just typecheck        # Run mypy

# Maintenance
just update-packages  # Update all packages
just clean            # Clean cache files

# Docker
just docker-up        # Start all services
just docker-down      # Stop all services
just docker-logs      # View logs
```

---

## Code Patterns

### Template Components

Use django-components for reusable UI:

```python
# apps/components/button.py
from django_components import Component

class Button(Component):
    template_name = "components/button.html"

    def get_context_data(self, variant="primary", size="md"):
        return {"variant": variant, "size": size}
```

### HTMX Partials

Use inline partials for HTMX responses:

```html
{% load partials %}

{% partialdef outfit-card %}
<div id="outfit-{{ outfit.id }}" class="outfit-card">
  {{ outfit.name }}
</div>
{% endpartialdef %}
```

### Semantic CSS

Always use semantic classes from `static/css/components.css`:

```html
<!-- Good -->
<button class="btn btn-primary">Save</button>

<!-- Avoid -->
<button class="px-4 py-2 bg-blue-600 text-white rounded-lg">Save</button>
```

---

## Troubleshooting

### Database Issues

```bash
# Reset database
just db-reset

# Check connection
just db-check
```

### Dependency Issues

```bash
# Sync dependencies
uv sync

# Update all packages
just update-packages
```

### Test Failures

```bash
# Run specific test
just test apps/outfits/tests/test_models.py

# Run with verbose output
just test -v
```

---

## Questions?

If unclear about:
- **Requirements**: Ask the user for clarification
- **Architecture**: Check `docs/knowledge/patterns/`
- **Process**: Review this playbook
- **Specific code**: Read the relevant source files

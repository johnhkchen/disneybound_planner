# Disneybound Planner - Project Dashboard

> **Status**: Active Development
> **Sprint**: 1 (Character Search)
> **Last Updated**: 2026-01-21

---

## Quick Links

| Resource | Path |
|----------|------|
| Active Enhancement Proposals | [`docs/active/enhancement_proposals/`](./active/enhancement_proposals/) |
| Active Tickets | [`docs/active/tickets/`](./active/tickets/) |
| Knowledge Base | [`docs/knowledge/`](./knowledge/) |
| Runbook | [`docs/knowledge/runbook/`](./knowledge/runbook/) |

---

## Current Sprint: Sprint 1 - Character Search

### Enhancement Proposals

| ID | Title | Status | Tickets |
|----|-------|--------|---------|
| EP-001 | Project Foundation & Architecture | Complete | T-001, T-002, T-003 |
| EP-002 | Character Search by Name | Draft | T-004, T-005, T-006 |

### Active Tickets

| ID | Title | EP | Status | Assignee |
|----|-------|-----|--------|----------|
| T-004 | Create BAML character extraction function | EP-002 | Pending | - |
| T-005 | Add character search view and URL | EP-002 | Pending | - |
| T-006 | Build search UI with HTMX | EP-002 | Pending | - |

### Completed Tickets (Sprint 0)

| ID | Title | EP | Status |
|----|-------|-----|--------|
| T-001 | Initialize Django project with uv | EP-001 | Done |
| T-002 | Set up Fly.io + Neon deployment | EP-001 | Done |
| T-003 | Configure Tailwind semantic CSS system | EP-001 | Done |

---

## Numbering Convention

### Enhancement Proposals (EP)
- Format: `EP-XXX` where XXX is a zero-padded sequential number
- Example: `EP-001`, `EP-042`
- File naming: `EP-XXX-short-title.md`

### Tickets (T)
- Format: `T-XXX` where XXX is a zero-padded sequential number
- Example: `T-001`, `T-123`
- File naming: `T-XXX-short-title.md`
- **Must reference parent EP** in frontmatter

### Linking Convention
- Tickets always link to their parent Enhancement Proposal
- Use the `parent_ep` field in ticket frontmatter
- Standalone tickets (outside sprint) create their own EP or get amended to existing one

---

## Project Statistics

```
Enhancement Proposals: 2 active (1 complete, 1 draft), 0 archived
Tickets:              6 total (3 done, 3 pending), 0 archived
Patterns:             0 documented
Runbook Entries:      0 documented
```

## Production Deployment

| Resource | URL |
|----------|-----|
| Live Site | https://disneybound-planner-hidden-sunset-2589.fly.dev/ |
| Fly.io Dashboard | https://fly.io/apps/disneybound-planner-hidden-sunset-2589 |
| GitHub Actions | https://github.com/johnhkchen/disneybound_planner/actions |

---

## How to Use This System

### For Coding Agents

1. **Before starting work**: Check this dashboard for active tickets
2. **Pick a ticket**: Update its status to "In Progress" in both OVERVIEW.md and the ticket file
3. **Work on ticket**: Follow the acceptance criteria in the ticket
4. **Complete work**: Update status to "Done", add any learnings to knowledge base
5. **Create new work**: Draft tickets/EPs in `docs/active/`, get user approval

### For Users

1. **Request features**: Create an Enhancement Proposal in `docs/active/enhancement_proposals/`
2. **Report bugs**: Create a Ticket in `docs/active/tickets/` with EP reference
3. **Review progress**: Check this dashboard for current status

---

## Checklists

### New Enhancement Proposal Checklist
- [ ] Create file: `docs/active/enhancement_proposals/EP-XXX-title.md`
- [ ] Fill in template (see `docs/knowledge/patterns/EP_TEMPLATE.md`)
- [ ] Add entry to this dashboard
- [ ] Create linked tickets

### New Ticket Checklist
- [ ] Create file: `docs/active/tickets/T-XXX-title.md`
- [ ] Fill in template (see `docs/knowledge/patterns/TICKET_TEMPLATE.md`)
- [ ] Link to parent EP
- [ ] Add entry to this dashboard

### Archiving Checklist
- [ ] Move completed EP/Ticket to `docs/archive/`
- [ ] Update this dashboard
- [ ] Document any learnings in `docs/knowledge/`

---

## Commands Reference

Run `just` to see all available commands. Key commands:

```bash
# Development
just dev          # Start development server
just test         # Run tests
just migrate      # Run migrations
just lint         # Run linter

# Deployment
just deploy       # Deploy to Fly.io
just logs         # View production logs
just secrets      # List secrets

# Maintenance
just update-packages  # Update all packages
```

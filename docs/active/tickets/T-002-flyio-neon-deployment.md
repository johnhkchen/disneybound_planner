# T-002: Set up Fly.io + Neon Deployment

> **Status**: Done
> **Parent EP**: EP-001
> **Created**: 2026-01-20
> **Assignee**: Agent
> **Priority**: High

---

## Description

Configure production deployment using Fly.io for compute (with scale-to-zero) and Neon for serverless Postgres. Set up GitHub Actions for CI/CD.

## Acceptance Criteria

- [x] `fly.toml` created with Fly.io configuration
- [x] `Dockerfile` created for uv + production deployment
- [x] `.github/workflows/deploy.yml` created for CI/CD
- [x] `.env.example` updated with Neon connection format
- [x] `justfile` updated with deployment commands
- [x] Documentation updated (README, specification)

## Technical Notes

### Files Created/Modified

- `fly.toml` - Fly.io app configuration (scale-to-zero, SJC region)
- `Dockerfile` - Production container with uv
- `.github/workflows/deploy.yml` - GitHub Actions workflow
- `.env.example` - Updated for Neon connection string
- `justfile` - Added deploy, logs, secrets, db-url commands
- `README.md` - Updated deployment instructions
- `docs/knowledge/specification.md` - Updated deployment section

### Deployment Stack

| Component | Service |
|-----------|---------|
| Compute | Fly.io (scale-to-zero) |
| Database | Neon (serverless Postgres) |
| Secrets | fly secrets |
| CI/CD | GitHub Actions |

### Key Commands

```bash
just deploy       # Deploy to Fly.io
just logs         # View production logs
just db-url URL   # Set DATABASE_URL secret
just secret K V   # Set any secret
just fly-setup    # Show first-time setup instructions
```

## Testing

- [x] Django check passes
- [x] All files created correctly
- [ ] First deploy to Fly.io (requires manual setup)
- [ ] GitHub Actions workflow runs on push

## Notes

- Removed Docker Compose (no longer needed)
- Local development connects to Neon dev branch or local Postgres
- Push to main auto-deploys via GitHub Actions

---

## Work Log

| Date | Update |
|------|--------|
| 2026-01-20 | Created |
| 2026-01-20 | Completed - Infrastructure stack finalized |

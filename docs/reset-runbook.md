# ComfyDeploy fresh reset runbook

## Completed local codebase carry-over
Selective infra/bootstrap changes have been applied from `comfydeploy_backup` into the clean repo:

- `apps/api/Dockerfile`
- `apps/api/docker-entrypoint.sh`
- `apps/api/.env.schema`
- `apps/api/.gitignore` (allowlist for `.env.schema`)
- `apps/app/Dockerfile`
- `apps/app/vite.config.ts`
- `apps/app/Caddyfile`

## Before Dokploy changes
1. Rotate any Infisical service tokens previously exposed in notes.
2. Export Dokploy app configs for `comfydeploy-api` and `comfydeploy-web`.
3. Capture current image refs, build args, domains, mounts, and env for rollback.
4. Dump Postgres and inventory named volumes.
5. Confirm Postgres and Redis both use named volumes.

## Target Dokploy shape
- `comfydeploy-api` -> `apps/api/Dockerfile` -> `api.comfy.impactframes.ai`
- `comfydeploy-web` -> `apps/app/Dockerfile` -> `comfy.impactframes.ai`
- `comfydeploy-postgres` private only
- `comfydeploy-redis` private only
- `impactframes.ai` remains separate

## API bootstrap model
- Mount `/etc/comfydeploy/.env.infisical` read-only.
- Keep Dokploy env limited to bootstrap values and non-secret toggles.
- Provide group-scoped Infisical tokens via Dokploy env:
  - `INFISICAL_GLOBAL_TOKEN`
  - `INFISICAL_AUTH_TOKEN`
  - `INFISICAL_BILLING_TOKEN`
  - `INFISICAL_STORAGE_TOKEN`
  - `INFISICAL_DATABASE_TOKEN`
  - `INFISICAL_MODAL_TOKEN`
  - `INFISICAL_GITHUB_TOKEN`
- Optional bootstrap vars:
  - `INFISICAL_SITE_URL`
  - `INFISICAL_ENVIRONMENT`
  - `CD_POSTGRES_HOST`
  - `CD_POSTGRES_PORT`
  - `CD_POSTGRES_DB`
  - `CD_POSTGRES_USER`
  - `CD_POSTGRES_PASSWORD`
  - `NEXT_PUBLIC_CD_API_URL`
  - `NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY`

## Validation order
1. Build and deploy `comfydeploy-postgres` + `comfydeploy-redis`.
2. Build and deploy API.
3. Verify API container starts and Varlock validation passes.
4. Run DB migrations.
5. Build and deploy web.
6. Verify frontend loads with correct Clerk publishable key and API URL.
7. Test Clerk auth, uploads, Redis-backed paths, and storage credentials.
8. Rebuild Autumn plans last from clean `apps/api/autumn.config.ts`.

## Explicit non-goals
- Do not restore old billing config wholesale.
- Do not restore Dokploy DB record hacks.
- Do not reintroduce embedded secrets from notes, SQL, or old env blobs.

# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Project overview

This repository is a small orchestration layer around a Medusa.js e‑commerce stack. It:

- Manages Docker images/containers for:
  - PostgreSQL
  - Medusa backend (and admin)
  - A Next.js storefront (Dockerfile present, service wiring is minimal in this repo)
- Pulls the actual application source code from the official Medusa starter repositories into a local `github/` directory.
- Provides helper scripts for preparing the Docker build contexts and building/running containers.

There is intentionally very little application code committed here; most business logic lives in the cloned upstream repositories under `github/`.

## Architecture and layout

High-level structure (only key pieces):

- `.env`
  - Central configuration for database and Medusa backend (user, password, DB name, ports, JWT/cookie secrets, etc.).
  - Used by `docker-compose.yml`, `run.sh`, and `pre.sh`.
  - Required variables are enforced by `pre.sh` (see `REQUIRED_VARS` in that script).

- `docker-compose.yml`
  - Defines two main services:
    - `db`: PostgreSQL container built from `docker-data/postgres/Dockerfile.postgres`.
      - Uses a named volume `postgres_data` mounted at the path specified by `POSTGRES_DATA` in `.env`.
      - Healthcheck uses `pg_isready` against `POSTGRES_USER` and `POSTGRES_DB`.
    - `medusa`: Medusa backend container built from `docker-data/backend/Dockerfile.medusa`.
      - Connects to `db` via `DATABASE_URL` (`postgres://...@db:5432/...`).
      - Exposes the backend on `MEDUSA_PORT` (mapped to container port `9000`).
      - Sets `MEDUSA_ADMIN_URL`, `MEDUSA_URL`, CORS origins, and secrets via environment variables.
      - Starts with `npx medusa start`.

- `docker-data/postgres/Dockerfile.postgres`
  - Extends `postgres:16`.
  - Sets a volume for PostgreSQL data under `/docker-data/postgresql/data/`.
  - Installs `postgresql-contrib` for common extensions.

- `docker-data/backend/Dockerfile.medusa`
  - Based on `node:20`.
  - Working directory: `/app`.
  - Installs `git` and `postgresql-client` inside the container.
  - Copies the Medusa backend source from `github/medusa-starter-default/` into `/app` at build time.
  - Installs dependencies (including `@swc/core` with `--legacy-peer-deps`).
  - Exposes port `9000` and runs `npx medusa develop` by default.
  - **Implication for Warp:** backend application code is not tracked by this repo; it comes from the cloned starter in `github/medusa-starter-default`.

- `docker-data/storefront/Dockerfile.storefront`
  - Based on `node:20-slim`.
  - Working directory: `/app`.
  - Expects a `package.json` / `package-lock.json` copied into its build context.
  - Installs dependencies, copies the application code, exposes port `8000`, and runs `npm run dev`.
  - Storefront source is expected under `github/nextjs-starter-medusa` (copied via setup scripts); note that this repo’s `docker-compose.yml` currently only wires up DB and backend.

- `github/`
  - **Not committed**; paths are created and populated by `pre.sh`:
    - `github/medusa-starter-default`: Medusa backend starter (upstream repo).
    - `github/nextjs-starter-medusa`: Next.js storefront starter (upstream repo).
  - `.gitignore` intentionally excludes `github/*` and `*package.json` so upstream code and copied manifests are not tracked here.
  - When you need to understand or modify backend/storefront behavior, open files from these directories directly; treat them as separate upstream projects.

- Scripts (root):
  - `pre.sh`
    - Validates `.env` exists and that required variables are set.
    - Creates the main data/build directories under `docker-data/` and `github/`.
    - Clones or updates the Medusa backend and storefront starter repositories into `github/`.
  - `setup-medusa.sh`
    - Validates that `github/medusa-starter-default` and `github/nextjs-starter-medusa` exist and contain `package.json` files.
    - Copies `package.json` (and `package-lock.json` if present) from those upstream repos into the corresponding `docker-data/backend` and `docker-data/storefront` directories.
    - Ensures the backend/storefront Dockerfiles exist.
    - Invokes `docker compose build` to build images for the configured services.
  - `run.sh`
    - Helper script to start individual containers using pre-built images via `docker run`.
    - Usage: `./run.sh <service>` with supported services including `postgres` and `backend`.
    - Reads `.env` via `source .env` to pick up port mappings and other settings.
  - `clean.sh`
    - Intended to stop and remove Medusa-related containers and images.
    - If relying on it, double-check the commands; you can always fall back to `docker compose down` and manual `docker rm`/`docker rmi` as needed.

## Environment and configuration

- `.env` is required before running any setup or build scripts.
- `pre.sh` enforces the presence of specific variables (see `REQUIRED_VARS` in that file). Warp should:
  - Read `pre.sh` to see the current required variable list.
  - Avoid printing actual secret values from `.env` into responses.
- The database data directory path is driven by `POSTGRES_DATA` in `.env` and used as the host mount for the `postgres_data` volume.

## Common commands

> Note: All provided scripts are Bash scripts. On Windows, run them via an appropriate Bash environment (e.g., WSL, Git Bash) rather than PowerShell.

### Initial setup

From the repository root:

- Verify and populate `.env` (required before anything else). Ensure all variables listed in `REQUIRED_VARS` inside `pre.sh` are defined.
- Clone/update upstream Medusa repositories and create required directories:

  ```bash path=null start=null
  bash pre.sh backend
  ```

  The argument is currently informational (the script primarily validates `.env` and clones both backend and storefront repos).

### Build Docker images

- Prepare Docker build contexts and build images for DB and backend (and storefront when wired):

  ```bash path=null start=null
  bash setup-medusa.sh
  ```

  This script will:
  - Copy `package.json`/`package-lock.json` from the cloned `github/` repos into `docker-data/backend` and `docker-data/storefront`.
  - Run `docker compose build` for the services defined in `docker-compose.yml`.

- Rebuild images manually if you later change Dockerfiles or upstream code:

  ```bash path=null start=null
  docker compose build
  ```

### Run services

- Start the full stack defined in `docker-compose.yml` (Postgres + Medusa backend):

  ```bash path=null start=null
  docker compose up -d
  ```

- View logs (useful for debugging container startup):

  ```bash path=null start=null
  docker compose logs -f db
  docker compose logs -f medusa
  ```

- Start individual services using helper script (assumes images already built and `.env` present):

  ```bash path=null start=null
  ./run.sh postgres
  ./run.sh backend
  ```

### Stop and clean up

- Stop containers created by `docker-compose.yml`:

  ```bash path=null start=null
  docker compose down
  ```

- If you need to fully clean images/containers, either fix and use `clean.sh` or run the equivalent `docker container rm` / `docker rmi` commands explicitly.

## Working with backend and storefront code

- The actual application code is not stored in this repo; it lives in the cloned upstream projects under `github/`:
  - `github/medusa-starter-default` (backend)
  - `github/nextjs-starter-medusa` (storefront)
- To develop features, run tests, or lint code for either application, Warp should:
  - Open the corresponding directory under `github/`.
  - Read that project’s own `README.md` and `package.json` to discover the exact `npm`/`yarn` scripts for build, lint, and tests (including how to run a single test).
  - Use those project-specific commands inside the relevant `github/*` directory.

This WARP.md focuses on the orchestration layer in this repository; for detailed backend/storefront behavior, always refer to the upstream Medusa starter projects checked out under `github/`.

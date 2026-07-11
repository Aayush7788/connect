# Connect Textile Marketplace

Android-first private MVP for a Surat-first textile marketplace.

Read AGENTS.md and outputs/textile-marketplace-25-phase-build-plan.md before coding.

## Current Build Phase

The active implementation source of truth is `outputs/textile-marketplace-25-phase-build-plan.md`.

Every phase must be developed on its own branch, tested or explicitly marked as not yet testable, then merged into `main` with `--no-ff`.

## Local Setup

Use PowerShell from the repository root.

```powershell
py -3.11 -m venv .venv
.\.venv\Scripts\Activate.ps1
python -m pip install --upgrade pip setuptools wheel
python -m pip install -r backend\requirements.txt -r backend\requirements-dev.txt
```

Use `python -m pip`, not plain `pip`, so installs go into the active virtual environment.

## Environment Files

Copy the example files before running services:

```powershell
Copy-Item backend\.env.example backend\.env
Copy-Item frontend\mobile\.env.example frontend\mobile\.env
Copy-Item frontend\admin\.env.example frontend\admin\.env.local
```

Never commit real `.env` files or provider secrets.

## OpenAPI And Client Generation

```powershell
.\.venv\Scripts\Activate.ps1
python scripts\validate_openapi.py
.\scripts\generate_clients.ps1
```

The generation script installs pinned API tooling under `api\node_modules`, then generates:

- Dart `dart-dio` client package at `api\generated\mobile\connect_api_client`.
- TypeScript OpenAPI schema types at `api\generated\admin\schema.d.ts`.

The script also runs Dart `build_runner` inside the generated mobile package so generated serializers exist before the Flutter app imports the client.

`scripts\smoke_api.ps1` is available for later phases after the FastAPI health endpoint exists.

## Database Migrations

Alembic migrations live under `database\migrations`.

```powershell
.\.venv\Scripts\python.exe -m alembic -c database\alembic.ini upgrade head --sql
.\.venv\Scripts\python.exe -m alembic -c database\alembic.ini upgrade head
```

The live migration command reads `DATABASE_URL` from `backend\.env`.

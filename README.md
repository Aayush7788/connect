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

## Phase 2 Validation

```powershell
.\.venv\Scripts\Activate.ps1
python scripts\validate_openapi.py
.\scripts\generate_clients.ps1
```

`scripts\smoke_api.ps1` is available for later phases after the FastAPI health endpoint exists.

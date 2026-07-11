# Backend

FastAPI backend API/BFF.

Flutter and admin must call this backend. They must not write directly to Supabase/PostgreSQL tables.

## Setup

```powershell
cd D:\value
.\.venv\Scripts\Activate.ps1
python -m pip install -r backend\requirements.txt -r backend\requirements-dev.txt
Copy-Item backend\.env.example backend\.env
```

The backend `.env` is local-only and must not be committed.

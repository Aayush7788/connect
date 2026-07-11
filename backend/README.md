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

## Run

```powershell
cd D:\value\backend
..\.venv\Scripts\python.exe -m uvicorn app.main:app --host 127.0.0.1 --port 8000 --reload
```

Health checks:

- `GET http://127.0.0.1:8000/health`
- `GET http://127.0.0.1:8000/v1/health`

All API errors should use the shared contract envelope:

```json
{
  "error": {
    "code": "not_found",
    "message": "Not found.",
    "request_id": "req_..."
  }
}
```

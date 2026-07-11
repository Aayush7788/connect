# Database

PostgreSQL schema, Alembic migrations, seed data, RLS notes, and SQL indexes.

Keep migration files under `database/migrations` and seed data under `database/seeds`.

## Migration Rules

- Use Alembic from the repository root.
- Keep one migration per reviewed schema step.
- Use timestamped migration filenames: `YYYYMMDD_<revision>_<short_slug>.py`.
- Use lowercase plural table names and snake_case columns.
- Use UUID primary keys with `gen_random_uuid()` for main tables.
- Use text status fields with CHECK constraints instead of PostgreSQL enum types.
- Keep RLS and Supabase Data API exposure decisions explicit in later table migrations.
- Do not put real database credentials in committed files.

## Commands

Generate offline SQL for review:

```powershell
.\.venv\Scripts\python.exe -m alembic -c database\alembic.ini upgrade head --sql
```

Run migrations against the database configured in `backend\.env`:

```powershell
.\.venv\Scripts\python.exe -m alembic -c database\alembic.ini upgrade head
```

Check the current database revision:

```powershell
.\.venv\Scripts\python.exe -m alembic -c database\alembic.ini current
```

Test backend database connectivity:

```powershell
Push-Location backend
..\.venv\Scripts\python.exe -c "from app.db.session import check_database_connection; print(check_database_connection())"
Pop-Location
```

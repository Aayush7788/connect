# Textile Marketplace MVP Tech Stack Decision

Status: selected for MVP  
Date: 2026-07-10  
Scope: Android-first private MVP for the textile marketplace, with backend-proxied database access.

## Final Decision

Do not choose a heavy enterprise stack now.

Choose:

**Flutter + FastAPI + Supabase PostgreSQL/Auth/Storage + Next.js Admin + FCM**

This stack is selected for fast MVP execution while preserving the architecture rule already agreed in the system design and API contract:

**mobile/admin frontend -> backend API/BFF -> database/storage/auth providers**

The mobile app and admin dashboard must not directly write marketplace business tables.

## Exact MVP Stack

### Mobile App

- Flutter
- Dart
- Riverpod
- go_router
- Dio
- freezed / json_serializable
- Image compression
- Firebase Messaging

### Backend

- FastAPI
- Pydantic
- SQLAlchemy
- Alembic
- asyncpg or psycopg
- JWT/session middleware
- Modular monolith structure

### Database

- Supabase-managed PostgreSQL in Mumbai
- pgcrypto
- pg_trgm
- PostgreSQL full-text search indexes
- Row Level Security as defense-in-depth

### Storage

- Supabase Storage
- Public buckets for profile, workplace, work-card, and work-needed media
- Private buckets for verification documents and sensitive admin-only evidence

### Admin Dashboard

- Next.js
- TypeScript
- React Query
- Generated API client from OpenAPI

The admin dashboard should call the same backend API/BFF. It should not directly mutate marketplace database tables.

### Notifications

- Firebase Cloud Messaging

### Deployment

- Supabase Pro before real private users
- FastAPI on Render or Railway initially
- Admin dashboard on Vercel or Render

## Architecture Constraint

Supabase is infrastructure, not the public backend contract.

The public app contract remains the FastAPI backend:

1. Flutter app calls FastAPI.
2. Next.js admin dashboard calls FastAPI.
3. FastAPI validates auth, permissions, business rules, and workflow state.
4. FastAPI reads/writes Supabase PostgreSQL and Supabase Storage.
5. PostgreSQL RLS remains enabled as a second safety layer, not as the main app authorization model.

## Why This Is The MVP Choice

- Flutter fits the Android-first mobile requirement and keeps iOS possible later.
- FastAPI is fast to build with, produces clean OpenAPI contracts, and matches the already-created API contract workflow.
- PostgreSQL is the correct source of truth for profiles, work cards, work-needed posts, verification, reports, saved items, contact reveals, and search logs.
- Supabase reduces operational work for authentication, managed Postgres, storage, and early hosting infrastructure.
- Next.js admin is faster to build than a fully native admin tool and can reuse generated API types.
- FCM is the standard choice for Android push notifications.

## Deferred Until Needed

- OpenSearch / Meilisearch for search scale
- Redis for caching, rate limits, and queues
- Razorpay / Cashfree subscriptions
- iOS app
- Voice search
- Automated KYC/GST verification providers
- Chat
- Ratings
- Field-agent app

## Re-Evaluation Triggers

Revisit this decision if any of these become true:

- PostgreSQL search cannot keep p95 search latency under the product target.
- Upload processing needs background workers beyond simple API handling.
- OTP, media, or notification costs become material.
- Admin operations need workflow-heavy tooling beyond the current dashboard.
- The app moves from private MVP to a larger paid public launch.
- Multi-region India scale or 50M-user planning becomes an active engineering requirement instead of a long-term direction.

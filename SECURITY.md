# Security notes — secrets & keys

## Safe in the Flutter client

- **`SUPABASE_URL`** — public project URL.
- **`SUPABASE_ANON_KEY`** — public “anon” key; access is limited by **RLS** and Auth rules.

## Never ship in the mobile/web app

- **Database password** and **`postgresql://…` session pooler URI**
- **`service_role`** key (bypasses RLS)
- Any third-party API secrets used only on a backend

Store those in:

- Server `.env` (not in this repo), or  
- CI/CD secret stores (GitHub Actions, etc.)

## Repo files

| File | Purpose |
|------|---------|
| `assets/env/.env.example` | Template — safe to commit |
| `assets/env/.env` | Your real keys — **gitignored**; copy from `.env.example` |

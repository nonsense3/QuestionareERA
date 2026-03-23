# Environment variables (Supabase)

## What this Flutter app needs (2 values)

| Variable | Where to find it |
|----------|-------------------|
| `SUPABASE_URL` | **Dashboard → Project Settings → API → Project URL**<br>Format: `https://<project-ref>.supabase.co` (not the `postgresql://` string). |
| `SUPABASE_ANON_KEY` | **Same page → Project API keys → `anon` `public`** |

These are enough for **Supabase Auth**, **Realtime**, **Storage**, and **PostgREST** from the client.  
The **`anon`** key is designed to be public in apps; protect data with **Row Level Security (RLS)** in SQL.

## What the “Session pooler” / `postgresql://…` link is for

The **Connection string → Session pooler → URI** (e.g. `postgresql://postgres.xxx:[PASSWORD]@...pooler.supabase.com:5432/postgres`) is for:

- Your **backend** (Node, Python, etc.)
- **Prisma / Drizzle / SQL migrations**
- **Direct Postgres** access

**Do not** embed this URL or the DB password inside the Flutter app. Keep it only in a **server** `.env` or CI secrets.

## Demo mode (no Supabase while you build UI)

Add to `assets/env/.env`:

```env
DEMO_MODE=true
```

Then **restart** the app. Supabase will **not** initialize; you get the offline demo flow (name + username → home). Your `SUPABASE_URL` / `SUPABASE_ANON_KEY` can stay in the file for when you turn demo off.

To use real auth again:

```env
DEMO_MODE=false
```

Or run: `flutter run -d chrome --dart-define=DEMO_MODE=false`

---

## How to activate Supabase in this project

1. Copy the env template:
   ```powershell
   cd questioare_era
   copy assets\env\.env.example assets\env\.env
   ```
2. Edit `assets/env/.env` and set `SUPABASE_URL` and `SUPABASE_ANON_KEY`.
3. Ensure `pubspec.yaml` lists `assets/env/.env` under `flutter: assets:` (see comment there).
4. Run:
   ```powershell
   flutter pub get
   flutter run -d chrome
   ```

### Alternative: no `.env` file (CI / builds)

Use compile-time defines (same keys):

```powershell
flutter run -d chrome `
  --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co `
  --dart-define=SUPABASE_ANON_KEY=eyJ...
```

Priority: **`--dart-define` overrides** values from `.env` when both are set.

## Security checklist

- [ ] `assets/env/.env` is in `.gitignore` (never commit real secrets).
- [ ] RLS policies enabled on tables that hold user data.
- [ ] `service_role` key only on servers / CI, never in the Flutter client.
- [ ] DB password only in backend `DATABASE_URL`, not in the app.

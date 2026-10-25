# Beginner installation guide

## Before you start
- Keep your current frontend repository and all HTML/CSS/JS files unchanged.
- Have access to the Supabase project dashboard for project `pzcudjyjfohlrwkefkhb`.
- Use a computer or an Android-compatible GitHub web upload workflow. Running Node locally is optional if deploying directly to Render.

## 1. Inspect your database first
1. Open Supabase Dashboard → SQL Editor → New query.
2. Open `supabase/inspect_schema.sql` from the extracted ZIP, copy all SQL, paste it into SQL Editor and run it.
3. Save/review the result tabs. Back up the project before migrations. If columns, foreign keys, or policies differ materially, stop and reconcile rather than forcing migrations.

## 2. Apply migrations
Run `supabase/migrations/001_profiles.sql` through `011_profile_auth_trigger.sql` one at a time, in numeric order, reviewing each result. Do not run `seed.sql` expecting sample users; it intentionally creates none. Migrations are non-destructive in intent, but an existing incompatible table may still make a migration fail. Stop and inspect the error; do not drop tables or reset data.

## 3. Upload backend files
Recommended: create a separate GitHub repository named `kwachaLink-backend`. Extract `KwachaLink_Complete_Backend.zip`, open the inner `KwachaLink_Complete_Backend` folder, and upload its contents (not the ZIP and not the outer wrapper) to the new repository root. Do not upload `.env` or secrets. See `docs/GITHUB_UPLOAD.md`.

## 4. Deploy on Render
Create → Web Service → connect the backend repository. Runtime Node. Build Command `npm ci`; Start Command `npm start`; Health Check Path `/health`. Add `SUPABASE_URL`, `SUPABASE_PUBLISHABLE_KEY`, and `CORS_ORIGINS=https://msukwainno-coder.github.io`. See `docs/RENDER_DEPLOYMENT.md`.

## 5. Verify
Open `https://YOUR-RENDER-SERVICE.onrender.com/health`; expect JSON with `success: true`. Then register a test account from Supabase Auth or the existing frontend, log in, and call protected routes with its access token. Do not test sensitive workflows with real money or production users.

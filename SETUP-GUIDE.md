# RESONANCE — Supabase Migration Setup Guide

Follow these steps in order. Total time: ~15 minutes.

---

## STEP 1 — Create a Supabase Project

1. Go to **https://supabase.com** and sign up (free).
2. Click **New Project**.
3. Choose a name (e.g. `resonance-db`), set a strong database password, pick a region closest to you (Europe West for Portugal).
4. Click **Create new project** and wait ~2 minutes for it to provision.

---

## STEP 2 — Run the SQL Setup Script

1. In your Supabase dashboard, click **SQL Editor** in the left sidebar.
2. Click **New Query**.
3. Open the file `resonance-setup.sql` (delivered alongside this guide).
4. Copy the entire contents and paste it into the SQL editor.
5. Click **Run** (or press Cmd/Ctrl + Enter).
6. You should see: `Success. No rows returned.`
7. Verify the seed data: in the SQL editor run:
   ```sql
   select count(*) from speakers;
   ```
   It should return **12**.

---

## STEP 3 — Get Your API Keys

1. In the Supabase dashboard, click **Settings** (gear icon) → **API**.
2. Copy two values:
   - **Project URL** — looks like `https://abcdefghijkl.supabase.co`
   - **anon / public key** — a long JWT string starting with `eyJ...`

---

## STEP 4 — Configure the HTML File

1. Open `speaker-database.html` in any text editor.
2. Find these two lines near the top of the `<script>` section:
   ```js
   const SUPABASE_URL  = 'YOUR_SUPABASE_URL';
   const SUPABASE_ANON = 'YOUR_SUPABASE_ANON_KEY';
   ```
3. Replace the placeholder strings with your actual values:
   ```js
   const SUPABASE_URL  = 'https://abcdefghijkl.supabase.co';
   const SUPABASE_ANON = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...';
   ```
4. Save the file.

---

## STEP 5 — Create Your Admin User

1. In Supabase dashboard, click **Authentication** → **Users**.
2. Click **Add User** → **Create new user**.
3. Enter your email and a strong password.
4. Click **Create User**.

> This is the account you'll use to log into the admin panel.
> The anon key is safe to embed in the HTML — Row Level Security
> ensures only authenticated users can write to the database.

---

## STEP 6 — Host the HTML File (Optional)

The file works opened directly from your computer (via `file://`), but
for cloud access from anywhere you'll want to host it:

### Option A — Netlify (recommended, free)
1. Go to **https://netlify.com** → **Add new site** → **Deploy manually**.
2. Drag and drop the `speaker-database.html` file into the deploy area.
3. Netlify gives you a URL like `https://random-name.netlify.app`.
4. Done — accessible from any device.

### Option B — GitHub Pages
1. Create a GitHub repo, add the HTML file as `index.html`.
2. Go to Settings → Pages → Deploy from branch → main.
3. Your URL: `https://yourusername.github.io/repo-name`.

### Option C — Keep it local
Just open the file in your browser directly. It will connect to
Supabase in the cloud even when running from your local filesystem.

---

## STEP 7 — First Login

1. Open the site (or the local file).
2. You'll see the login screen. Enter the email and password you
   created in Step 5.
3. On success you'll see the gallery populated from Supabase,
   and the **Admin ⚙** link will appear in the nav.
4. Guests can click **View Archive as Guest** to browse the gallery
   without being able to edit anything.

---

## HOW IT WORKS — Architecture Summary

```
Browser (HTML file)
    │
    │  HTTPS fetch()  ←— read: no auth needed (RLS: public read)
    │  HTTPS fetch()  ←— write: requires JWT token (RLS: auth only)
    ▼
Supabase REST API (auto-generated from PostgreSQL)
    │
    ▼
PostgreSQL Database
    ├── speakers          (all speaker records)
    ├── custom_fields     (your custom field definitions)
    └── builtin_overrides (your label/section edits)
```

**Row Level Security (RLS)** is the key protection layer:
- Anyone (including the public) can **read** all three tables.
  This lets the gallery work for guests without login.
- Only authenticated users (your account) can **insert, update, delete**.
  The anon key alone cannot write anything.

**Sessions** are stored in `sessionStorage` — they persist through
page refreshes but clear when you close the browser tab, which is
the right balance for a personal admin tool.

---

## TROUBLESHOOTING

**"Invalid login credentials"**
→ Double-check email/password. Make sure you created the user in
  Authentication → Users (not just as a database user).

**Gallery loads empty after login**
→ Check that the SQL script ran successfully and `select count(*) from speakers` returns 12.
→ Open browser DevTools → Console and look for fetch errors with the Supabase URL.

**"Error: new row violates row-level security policy"**
→ You're trying to write without being logged in. Sign in first.

**CORS error in console**
→ This only happens if the file is served from a non-browser context.
  Opening it directly as a file:// URL or hosting it on any web server both work fine.

**Custom fields not showing**
→ After adding custom fields in Admin → Custom Fields, open a speaker
  to edit it — the new fields appear in the form. Existing speakers
  show custom field data in their detail page once saved.

---

## BACKUP & EXPORT

At any time you can export a full JSON backup from Admin → Export JSON.
This downloads `resonance-database.json` containing all speakers and
custom field definitions. You can re-import this file on any instance
of the app using Admin → Import JSON.

To back up directly from Supabase:
Dashboard → Database → Backups (available on Pro plan)
or run: `pg_dump` against your database connection string.

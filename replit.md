# RESONANCE — Speaker Archive

## Overview
A static single-page web application for cataloging and managing an audio speaker database. Features a public gallery view, detailed speaker specs with 3D visualization (Three.js), and an admin panel for managing data.

## Architecture
- **Type:** Static HTML/CSS/JS (no build system)
- **Backend:** Supabase (BaaS) — PostgreSQL database, REST API, Auth
- **Frontend:** Single `index.html` file with embedded CSS and JS
- **3D Rendering:** Three.js via CDN
- **Auth:** Supabase Auth with Row Level Security (RLS)

## Project Layout
```
index.html           # Entire application (HTML + CSS + JS)
resonance-setup.sql  # Database schema and seed data for Supabase
SETUP-GUIDE.md       # Instructions for Supabase setup and deployment
files.zip            # Backup/distribution package
```

## Running Locally
Served via Python's built-in HTTP server on port 5000:
```
python3 -m http.server 5000 --bind 0.0.0.0
```

## Supabase Configuration
The app requires a Supabase project. Two constants in `index.html` must be set:
- `SUPABASE_URL` — your project URL (e.g. `https://abcdefgh.supabase.co`)
- `SUPABASE_ANON` — your anon/public key (JWT starting with `eyJ...`)

See `SETUP-GUIDE.md` for full setup instructions.

## Database Tables
- `speakers` — Speaker records (with `custom_data` JSONB column)
- `custom_fields` — User-defined field definitions
- `builtin_overrides` — Label/section customizations

## Deployment
Configured as a static site deployment. The `index.html` and assets are served directly.

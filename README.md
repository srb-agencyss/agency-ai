# WingBait Production Package — v11

## Current operating flow
Public website → WingBait AI consultation → WhatsApp → Private Admin → Lead → Client → Project → Invoice → Payment → Client communication → Delivery.

## Phase 11: Supabase production connection readiness
This package is ready to connect to a real Supabase project. The browser uses a **publishable key** when available, with the legacy `anon` key supported for compatibility. A Supabase secret/service-role key must never be placed in the website.

### Supabase setup — do this once
1. Open the Supabase Dashboard and create/select the WingBait project.
2. Open **SQL Editor** and create a new query.
3. Open the supplied `supabase-schema.sql` file from this package, copy all of it, paste it into the SQL Editor, and click **Run**.
4. Open **Authentication → Users** and create the private WingBait admin user with email + password. Supabase documents this Dashboard flow under Authentication → Users. 
5. Copy the new Auth user's **UUID**.
6. Return to SQL Editor and run:
   `insert into public.admin_users (user_id) values ('PASTE-AUTH-USER-UUID-HERE');`
7. In Supabase **Connect** (or **Settings → API Keys**), copy:
   - Project URL
   - **Publishable key** (`sb_publishable_...`) if available
   - If the project only exposes the legacy key, the `anon` key also works with this package.
8. Open `supabase-config.js` and enter:
   ```js
   window.WINGBAIT_SUPABASE = {
     url: 'https://YOUR-PROJECT-REF.supabase.co',
     publishableKey: 'sb_publishable_...',
     anonKey: '',
     allowLocalFallback: false
   };
   ```
9. Save the file.
10. Do **not** paste or upload a `secret` / `service_role` key. Supabase states that secret keys bypass Row Level Security and must stay in backend-controlled environments.

### Important production rule
Set `allowLocalFallback: false` before public deployment. This prevents the old browser-only admin password fallback from being used if Supabase is accidentally misconfigured.

### What the supplied SQL does
- Creates leads, clients, projects, invoices and payments tables.
- Enables Row Level Security.
- Allows the public website to insert website AI leads only.
- Prevents public visitors from reading, updating or deleting leads.
- Restricts business data to authenticated WingBait admins.
- Adds the `admin_users` allow-list.
- Adds communication history storage.

### API-key rule
Supabase currently recommends **publishable** keys for browser applications and **secret** keys only for trusted backend components. Supabase is migrating away from the older `anon` / `service_role` naming during 2026, so use the publishable key for new setup when available.

## v10/v11 workflow hardening
- Invoices can be linked to saved clients and projects.
- Client/project selection can prefill invoice information.
- Fully paid linked invoices can move planned/confirmed projects to Confirmed.
- Cloud lead deletion is supported when authenticated.
- Admin has an explicit Sign out action.
- Communication log schema is ready for message history.
- v11 accepts the modern publishable key while retaining legacy anon-key compatibility.

## Local fallback
Local fallback remains available only for development until you set `allowLocalFallback: false`. The development fallback is not production security.

# GANGBOX — Field Time, Job-Costed (synced + time-card editing)

Every worker punches in from their own phone; managers see all of it live from any phone or
laptop. Workers can fix a forgotten clock-in/out themselves, and **every edit is logged** so
management sees exactly what changed. The **Clock** and **Cards** screens are open to the crew;
**Sites**, **Crew**, and **Reports** sit behind a manager PIN. Punches made with bad signal are
saved and upload automatically when the phone reconnects.

This is a static web app (installable to a phone home screen) plus a free Supabase database for
the shared data.

---

## One-time setup (~10 minutes)

### 1. Create the database (Supabase — free)
1. Go to supabase.com, sign up, **New project**. Pick a name and a strong database password,
   choose the region nearest you, create it (takes a minute to provision).
2. Open **SQL Editor → New query**, paste the entire contents of **`supabase-setup.sql`**, **Run**.
   - Already ran an earlier version's setup? Instead run **`supabase-migration-edits.sql`** to add just
     the new time-card audit log.
   - Optional: to start with a populated demo, also run **`supabase-sample-data.sql`**. Skip it to
     start empty and add your real crew/jobs in the app.
3. Open **Project Settings → API**. Copy the **Project URL** and the **anon public** key.

### 2. Point the app at your database
Open **`config.js`** and paste them in:
```js
window.GANGBOX_CONFIG = {
  url: "https://YOURPROJECT.supabase.co",
  anonKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6..."
};
```
Both are safe to expose — the anon key is meant for browser apps.

### 3. Put the app online (GitHub Pages — free)
1. New GitHub repo, e.g. `gangbox`.
2. Upload everything in this folder to the repo root (including your edited `config.js`).
3. **Settings → Pages → Deploy from a branch → `main` / root**, Save.
4. Live in ~1 min at `https://YOUR-USERNAME.github.io/gangbox/`.

(Netlify, Cloudflare Pages, or Vercel work the same way — just serve the folder.)

### 4. Set it up for your crew
1. Open the link, go to **Crew** or **Sites** — it asks for the **manager PIN** (starts as `1234`).
2. Change it immediately: **Reports → Change PIN**.
3. Add your real crew and job sites. Done.

---

## Daily use

- **Workers:** open the link (or the installed app), stay on **Clock**, tap their name, pick the
  job site, optionally a task, hit **CLOCK IN**. Tap **CLOCK OUT** when done. They never need the PIN.
- **Managers:** open **Reports** from any device, enter the PIN once, and review billing, hours by
  task, hours by crew, the fit matrix, the staffing read, and **Time card changes** (the audit log)
  for any date range.

### Fixing a clock-in / clock-out (and the audit trail)
Forgot to punch in or out? On the **Cards** tab (open to the crew, no PIN), tap your name to see your
recent shifts. From there you can:
- **Edit times** — correct the clock-in or clock-out on any shift, change the site or task, or close a
  shift that was left open overnight.
- **Add a missed shift** — log a shift you forgot to punch in for at all.
- **Delete** a card that shouldn't exist.

**Every change is recorded.** Management sees exactly what happened in **Reports → Time card
changes**: who, which field, the old value → the new value, how much a time moved (e.g. "Clock-out
3:00 PM → 5:30 PM (2h 30m later)"), and when the edit was made. Edited cards are flagged with an
"✎ edited" badge, and each card keeps its own change history. Originals are never overwritten in the
log — they're preserved.

Note: like clocking in, the Cards screen is open (anyone at the shared phone can edit) — the audit
log is what keeps everyone honest. The "Locking it down" option below makes this per-person if you
need it.

### Install on a phone
- **iPhone (Safari):** Share → **Add to Home Screen**.
- **Android (Chrome):** menu → **Install app**.

Everyone's app talks to the same database, so the office view always reflects what the field did.

---

## How syncing & offline work

- The header shows status: **● Synced** (green), **● Offline · N to sync** (amber, has unsent
  punches), **● No connection**, or **● Local only** (no database configured).
- A clock-in/out done offline is saved on the phone and uploaded automatically when signal returns
  — nothing is lost. (Reports need a connection to pull the latest, but show the last synced data
  offline.)
- Management views update live (and re-check every 30 seconds as a backstop).

---

## Security — please read

The field app uses Supabase's public **anon key**, so anyone who has the app's link can read and
write time data. For a small crew this is the normal trade-off (it's a punch clock, not a bank),
and the manager PIN keeps the office screens and editing out of casual reach. But the PIN is a
convenience gate, not hard security.

### Locking it down (optional, later)
If you want real accounts — each person logs in, only managers can see reports, nobody can edit
someone else's time — that's **Supabase Auth** with stricter row-level-security policies. It's a
bigger change (logins add friction for the crew), so it's worth doing only if the open model
doesn't suit you. Ask and it can be built on top of this.

---

## Files
```
index.html              the app
config.js               your Supabase URL + anon key (edit this)
supabase-setup.sql      run once to create the database
supabase-migration-edits.sql  add just the audit log to an existing project
supabase-sample-data.sql  optional demo data
service-worker.js       offline support
manifest.webmanifest, icons
```

## Run locally to test
```
python3 -m http.server 8080
```
Open http://localhost:8080. With `config.js` blank it runs in local-only mode (sample data, one
device) so you can poke at it before wiring up the database.

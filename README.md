# WingBait — Production Website

**Websites that move your business.**

This repository contains the production-ready static landing page for WingBait.

## Files

```text
wingbait/
├── index.html
├── README.md
├── .gitignore
└── assets/
    └── wingbait-logo.png
```

### `index.html`
The complete WingBait landing page. Keep this file in the **root of the GitHub repository**.

### `assets/wingbait-logo.png`
The WingBait logo used by the page and favicon. It is kept as a separate file so `index.html` stays much smaller and easier to upload/manage.

### `.gitignore`
Basic ignore rules for local development files. No build system or `node_modules` is required for this static website.

## GitHub upload

Upload the **contents of this folder** to the root of your GitHub repository — not the ZIP file itself.

The repository root should look like:

```text
index.html
README.md
.gitignore
assets/wingbait-logo.png
```

The most important rule is:

> `index.html` must be directly in the repository root.

Do not put it inside another folder such as `wingbait-github-ready/`.

## Vercel

For a normal static deployment:

1. Import the GitHub repository into Vercel.
2. Framework Preset: **Other** (or let Vercel detect it as a static site).
3. Build Command: leave empty.
4. Output Directory: leave empty.
5. Deploy.

Vercel should then serve:

```text
https://your-domain.com/
```

from the root `index.html`.

If you already have a Vercel project connected to this GitHub repository, push/commit these files to the branch that Vercel is configured to deploy.

## Important

- No Supabase configuration is required for this current public landing page.
- No `supabase-config.js`, `supabase-schema.sql`, Node.js setup, package.json, or build command is required for this static version.
- Do not add secret API keys, Supabase service-role keys, passwords, or other credentials to this repository.
- The existing visual design, spacing, typography, colors, cards, responsive layout, and section alignment have been preserved. The change here is primarily file organization: the repeated embedded logo was moved to `assets/wingbait-logo.png`.

## Website contact links

The page includes the configured WingBait WhatsApp and email contact links already present in the website.

## Deployment check

After pushing to GitHub, open the repository and confirm:

- `index.html` is visible at the top level.
- `assets/wingbait-logo.png` exists.
- The Vercel deployment is connected to the correct repository and branch.
- The deployment URL opens the homepage instead of a 404.

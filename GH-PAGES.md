Deploying to GitHub Pages (project site)

This repo is an Astro site. GitHub Pages (project pages) serves your site from a subpath like `https://username.github.io/repo-name/`. To make sure the site works correctly when deployed at a subpath we:

- Made `astro.config.mjs` respect `GITHUB_PAGES_BASE` and `GITHUB_PAGES_URL` environment variables.
- Updated components to build internal links and asset references using `Astro.site` (via `new URL(..., Astro.site).pathname`) so they respect the configured `base`.

Quick steps to build locally for GitHub Pages (Linux / macOS / WSL):

1. Build for a project pages site (replace `owner/repo` and `repo`):

```bash
# run from repo root
GITHUB_PAGES_REPO=owner/repo \
GITHUB_PAGES_BASE=/repo/ \
GITHUB_PAGES_URL=https://owner.github.io/repo/ \
pnpm run build
```

Or use the helper script:

```bash
GITHUB_PAGES_REPO=owner/repo pnpm run build:gh-pages
```

2. The finished static site will be in `dist/` ready to push to the `gh-pages` branch or to be served by GitHub Pages via the repository settings.

Notes
- If you deploy to a user/organization site (username.github.io) set `GITHUB_PAGES_BASE=/` and `GITHUB_PAGES_URL=https://username.github.io/`.
- If you use a CI/CD workflow, set the environment variables above in the job that runs `pnpm run build`.
- Assets and internal links should now respect the configured base automatically because components use `Astro.site` and `Astro.url` where appropriate.

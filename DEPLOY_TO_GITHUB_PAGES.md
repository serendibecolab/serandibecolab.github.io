# Deploy Yukina to GitHub Pages (serandibecolab.github.io)

This guide walks you through deploying your Astro site to GitHub Pages as a user page at the root domain.

## What You Need

- Repository: `https://github.com/serendibecolab/serandibecolab.github.io`
- Your local clone of this repository
- Git configured with your GitHub credentials (HTTPS or SSH)

## Option 1: Automatic Deployment (Recommended) — Using GitHub Actions

This option uses the workflow file I created (`.github/workflows/pages.yml`) to automatically build and deploy on every push to `main`.

### Steps:

1. **Commit and push the workflow file and source code:**

```fish
# From your repo root (/home/banumth/Projects/yukina)
cd /home/banumth/Projects/yukina

# Add the workflow file and all source code
git add .github/workflows/pages.yml
git add -A

# Commit
git commit -m "Add GitHub Pages deployment workflow"

# Push to your GitHub Pages repository
git push origin main
```

2. **Wait for the Actions workflow to run:**
   - Go to: `https://github.com/serendibecolab/serandibecolab.github.io/actions`
   - Watch for the "Deploy to GitHub Pages" workflow to complete (usually 1-3 minutes)
   - Once it succeeds, your site will be live at `https://serandibecolab.github.io`

3. **Verify GitHub Pages settings:**
   - Go to: `https://github.com/serendibecolab/serandibecolab.github.io/settings/pages`
   - Ensure **Source** is set to `Deploy from a branch`
   - Branch should be `main` (or whatever the workflow selected)
   - The deployment should show "Your site is live" in green

---

## Option 2: Manual Deployment — Push Built Files Directly

Use this if you want to manually build and push the generated `dist/` folder.

### Steps:

1. **Build the site for GitHub Pages:**

```fish
cd /home/banumth/Projects/yukina

# Install dependencies (if needed)
pnpm install

# Build with GitHub Pages configuration
set -x GITHUB_PAGES_REPO "serendibecolab/serandibecolab.github.io"
pnpm run build:gh-pages
```

Expected output:
```
Building with GITHUB_PAGES_BASE=/ GITHUB_PAGES_URL=https://serandibecolab.github.io
```

2. **Push the built site to GitHub:**

**Option 2a: Deploy to `main` branch (simplest for user pages):**

```fish
cd dist

# Configure git if this is a fresh clone
git config user.name "Your Name"
git config user.email "your.email@example.com"

# Initialize git and add remote (if not already done)
git init
git remote add origin https://github.com/serendibecolab/serandibecolab.github.io.git 2>/dev/null || true

# Add all files, commit, and push
git add --all
git commit -m "Deploy: $(date -u +'%Y-%m-%d %H:%M:%S UTC')"
git branch -M main
git push -u origin main

cd ..
```

**Option 2b: Deploy to `gh-pages` branch (keeps source/build separate):**

```fish
# From repo root
cd /home/banumth/Projects/yukina

# Create/update gh-pages branch with built files
git fetch origin gh-pages 2>/dev/null || true

# Use worktree for clean separation
git worktree add -b gh-pages .gh-pages-deploy 2>/dev/null || git worktree add --detach .gh-pages-deploy origin/gh-pages

# Clear and copy built files
rm -rf .gh-pages-deploy/*; or true
cp -r dist/* .gh-pages-deploy/

# Commit and push
cd .gh-pages-deploy
git config user.name "Your Name"
git config user.email "your.email@example.com"
git add --all
git commit -m "Deploy: $(date -u +'%Y-%m-%d %H:%M:%S UTC')" || echo "Nothing to commit"
git push origin gh-pages || git push -u origin gh-pages

cd ../..

# Clean up
git worktree remove .gh-pages-deploy 2>/dev/null || true
```

3. **Configure GitHub Pages:**
   - Go to: `https://github.com/serendibecolab/serandibecolab.github.io/settings/pages`
   - Set **Source** to `Deploy from a branch`
   - Select the branch you pushed to: `main` or `gh-pages`
   - Click **Save**

4. **Wait for deployment and verify:**
   - GitHub will build and deploy (usually 1-2 minutes)
   - You'll see "Your site is live" in green
   - Visit `https://serandibecolab.github.io` to confirm

---

## Option 3: One-Shot Complete Setup (All-in-One)

Combines everything into a single command sequence:

```fish
cd /home/banumth/Projects/yukina

# 1. Ensure deps are installed
pnpm install

# 2. Build
set -x GITHUB_PAGES_REPO "serendibecolab/serandibecolab.github.io"
pnpm run build:gh-pages

# 3. Commit source and workflow
git add .github/workflows/pages.yml src/ public/ astro.config.mjs package.json tsconfig.json svelte.config.js tailwind.config.mjs yukina.config.ts
git commit -m "Source: Yukina site for GitHub Pages" || true

# 4. Push source (this triggers the workflow)
git push origin main

# 5. Wait ~2 minutes for workflow to complete, then visit
echo "Workflow triggered! Check https://github.com/serendibecolab/serandibecolab.github.io/actions"
echo "Site will be live at https://serandibecolab.github.io in 1-2 minutes"
```

---

## Troubleshooting

### "404 — There isn't a GitHub Pages site here"

**Cause 1:** No content has been published to any branch yet.
- **Fix:** Run Option 1 (workflow) or Option 2 (manual) above.

**Cause 2:** GitHub Pages is not enabled in repository settings.
- **Fix:** Go to `https://github.com/serendibecolab/serandibecolab.github.io/settings/pages` and ensure:
  - Source is set to `Deploy from a branch`
  - A valid branch is selected (main or gh-pages)

**Cause 3:** Branch is empty or doesn't exist.
- **Fix:** Ensure you pushed to the correct branch. Check with:
```fish
git branch -r
# Should show: origin/main or origin/gh-pages
```

**Cause 4:** Workflow hasn't run yet or failed.
- **Fix:** Check the Actions tab: `https://github.com/serendibecolab/serandibecolab.github.io/actions`
  - If it failed, read the error logs and fix any issues

### "dist/ is not being tracked"

This is normal and expected. The `dist/` folder is built locally or by the workflow.

- If using **Option 1 (Workflow):** The workflow builds `dist/` automatically; you don't push it.
- If using **Option 2 (Manual):** You explicitly push `dist/` to the branch.

### "Build failed" or "Workflow error"

- Check the Actions logs: `https://github.com/serendibecolab/serandibecolab.github.io/actions`
- Common issues:
  - Missing pnpm or Node.js (check workflow YAML)
  - Source files not committed (commit your source code to `main`)
  - Environment variables not set (already handled in workflow)

---

## Next Steps

After your site is deployed:

1. **Verify it's live:** Visit `https://serandibecolab.github.io`
2. **Test navigation:** Click around to ensure links work
3. **Check for any errors:** Open browser developer tools (F12) and look for 404s or broken assets
4. **Set a custom domain (optional):** If you have a custom domain, add a `CNAME` file with your domain

---

## Quick Reference

| Task | Command |
|------|---------|
| Build locally | `set -x GITHUB_PAGES_REPO "serendibecolab/serendibecolab.github.io" && pnpm run build:gh-pages` |
| Push source + trigger workflow | `git add -A && git commit -m "message" && git push origin main` |
| View Actions | `https://github.com/serendibecolab/serendibecolab.github.io/actions` |
| Configure Pages | `https://github.com/serendibecolab/serendibecolab.github.io/settings/pages` |
| Live site | `https://serandibecolab.github.io` |


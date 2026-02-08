#!/usr/bin/env fish
# Deploy Yukina to GitHub Pages (serandibecolab.github.io)
# Usage: fish deploy-github-pages.fish [option]
# Options: workflow (default) | manual-main | manual-gh-pages

set option (string lower (or $argv[1] "workflow"))

set repo_url "https://github.com/serendibecolab/serandibecolab.github.io.git"
set repo_name "serandibecolab/serandibecolab.github.io"

echo "🚀 Deploying Yukina to GitHub Pages..."
echo "Repository: $repo_url"
echo ""

# Ensure we're in the repo root
if not test -f "package.json"
    echo "❌ Error: package.json not found. Please run this script from the repo root."
    exit 1
end

# Step 1: Ensure git remote is configured
if not git remote get-url origin &>/dev/null
    echo "📝 Adding remote origin..."
    git remote add origin $repo_url
else
    set current_remote (git remote get-url origin)
    if test "$current_remote" != "$repo_url"
        echo "⚠️  Remote URL mismatch. Current: $current_remote"
        echo "Updating to: $repo_url"
        git remote set-url origin $repo_url
    end
end

echo "✅ Remote configured: $repo_url"
echo ""

# Step 2: Install dependencies
if test -d "node_modules"
    echo "✅ Dependencies already installed"
else
    echo "📦 Installing dependencies..."
    pnpm install || (echo "❌ Failed to install dependencies"; exit 1)
end

echo ""

switch $option
    case "workflow"
        echo "🔧 Option: Deploy via GitHub Actions (Automatic)"
        echo ""
        echo "1. Committing source code and workflow..."
        git add .github/workflows/pages.yml
        git add -A
        git commit -m "Source: Yukina site for GitHub Pages (auto-deploy)" || echo "⚠️  Nothing new to commit"

        echo ""
        echo "2. Pushing to main branch (this triggers the workflow)..."
        git push -u origin main || (echo "❌ Push failed"; exit 1)

        echo ""
        echo "✅ Push successful!"
        echo ""
        echo "📊 Watch the workflow at:"
        echo "   https://github.com/serendibecolab/serendibecolab.github.io/actions"
        echo ""
        echo "🌐 Your site will be live at:"
        echo "   https://serandibecolab.github.io"
        echo ""
        echo "⏱️  This usually takes 1-3 minutes."

    case "manual-main"
        echo "🔧 Option: Manual Deploy to main branch"
        echo ""

        echo "1. Building site..."
        set -x GITHUB_PAGES_REPO $repo_name
        pnpm run build:gh-pages || (echo "❌ Build failed"; exit 1)

        echo ""
        echo "2. Preparing dist/ for push..."
        cd dist

        if not git rev-parse --git-dir &>/dev/null
            echo "   Initializing git in dist/..."
            git init
        end

        git remote add origin $repo_url 2>/dev/null || git remote set-url origin $repo_url
        git config user.name "Deploy Script"
        git config user.email "deploy@github.local" 2>/dev/null || true

        echo "3. Committing and pushing..."
        git add --all
        git commit -m "Deploy: built site ($(date -u +'%Y-%m-%d %H:%M:%S UTC'))" || echo "⚠️  Nothing to commit"
        git branch -M main
        git push -u origin main || (echo "❌ Push failed"; exit 1)

        cd ..

        echo ""
        echo "✅ Deployment successful!"
        echo ""
        echo "⚙️  Configure GitHub Pages at:"
        echo "   https://github.com/serendibecolab/serandibecolab.github.io/settings/pages"
        echo ""
        echo "🌐 Your site will be live at:"
        echo "   https://serandibecolab.github.io"

    case "manual-gh-pages"
        echo "🔧 Option: Manual Deploy to gh-pages branch"
        echo ""

        echo "1. Building site..."
        set -x GITHUB_PAGES_REPO $repo_name
        pnpm run build:gh-pages || (echo "❌ Build failed"; exit 1)

        echo ""
        echo "2. Creating gh-pages deployment..."

        git fetch origin gh-pages 2>/dev/null || true

        if git worktree list | grep -q "\.gh-pages-deploy"
            git worktree remove .gh-pages-deploy
        end

        git worktree add -b gh-pages .gh-pages-deploy 2>/dev/null || git worktree add --detach .gh-pages-deploy origin/gh-pages 2>/dev/null || true

        echo "3. Copying built files..."
        rm -rf .gh-pages-deploy/*
        cp -r dist/* .gh-pages-deploy/

        echo "4. Committing and pushing..."
        cd .gh-pages-deploy
        git config user.name "Deploy Script"
        git config user.email "deploy@github.local" 2>/dev/null || true
        git add --all
        git commit -m "Deploy: built site ($(date -u +'%Y-%m-%d %H:%M:%S UTC'))" || echo "⚠️  Nothing to commit"
        git push origin gh-pages || git push -u origin gh-pages || (echo "❌ Push failed"; exit 1)

        cd ..
        git worktree remove .gh-pages-deploy 2>/dev/null || true

        echo ""
        echo "✅ Deployment successful!"
        echo ""
        echo "⚙️  Configure GitHub Pages at:"
        echo "   https://github.com/serendibecolab/serandibecolab.github.io/settings/pages"
        echo "   Select branch: gh-pages"
        echo ""
        echo "🌐 Your site will be live at:"
        echo "   https://serandibecolab.github.io"

    case "*"
        echo "❌ Unknown option: $option"
        echo ""
        echo "Usage: fish deploy-github-pages.fish [option]"
        echo "Options:"
        echo "  workflow      - Deploy via GitHub Actions (recommended, automatic)"
        echo "  manual-main   - Manually build and push to main branch"
        echo "  manual-gh-pages - Manually build and push to gh-pages branch"
        exit 1
end

echo ""
echo "✨ Done!"

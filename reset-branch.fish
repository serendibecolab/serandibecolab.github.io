#!/usr/bin/env fish
# Reset git repository with fresh main branch

cd /home/banumth/Projects/yukina

echo "🔄 Resetting git repository..."
echo ""

# Check current branch
set current_branch (git rev-parse --abbrev-ref HEAD)
echo "Current branch: $current_branch"

# Create a new temporary branch to work from
echo "📝 Creating temporary branch..."
git checkout --orphan temp-main

# Stage all files
echo "📦 Staging all files..."
git add -A

# Commit with fresh history
echo "💾 Creating initial commit..."
git commit -m "Initial commit: Deploy Astro site to GitHub Pages"

# Delete the old main branch (if it exists)
echo "🗑️  Removing old main branch..."
git branch -D main 2>/dev/null || echo "No old main branch to delete"

# Rename temp-main to main
echo "✨ Renaming branch to main..."
git branch -M temp-main main

# Push to GitHub (force push to overwrite if needed)
echo "🚀 Pushing to GitHub..."
git push -u origin main --force

echo ""
echo "✅ Done!"
echo ""
echo "📊 Workflow triggered: https://github.com/serendibecolab/serandibecolab.github.io/actions"
echo "🌐 Site will be live at: https://serendibecolab.github.io"

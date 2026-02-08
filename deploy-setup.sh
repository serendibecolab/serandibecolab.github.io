#!/bin/bash
set -e

cd /home/banumth/Projects/yukina

echo "🔧 Step 1: Remove embedded git repository in dist/"
rm -rf dist/.git
echo "✅ Done"

echo ""
echo "🔧 Step 2: Remove dist from git staging"
git rm --cached dist 2>/dev/null || echo "⚠️  dist not cached (this is ok)"

echo ""
echo "🔧 Step 3: Add dist/ to .gitignore"
if grep -q "^dist/$" .gitignore 2>/dev/null; then
    echo "✅ dist/ already in .gitignore"
else
    echo "dist/" >> .gitignore
    echo "✅ Added dist/ to .gitignore"
fi

echo ""
echo "🔧 Step 4: Stage all files"
git add -A
echo "✅ Done"

echo ""
echo "🔧 Step 5: Commit changes"
git commit -m "Deploy: Use official Astro GitHub Pages workflow"
echo "✅ Done"

echo ""
echo "🔧 Step 6: Set main branch"
git branch -M main
echo "✅ Done"

echo ""
echo "🔧 Step 7: Push to GitHub"
git push -u origin main
echo "✅ Done"

echo ""
echo "🎉 All steps completed successfully!"
echo ""
echo "📊 Workflow triggered! Check https://github.com/serendibecolab/serandibecolab.github.io/actions"
echo "🌐 Your site will be live at https://serendibecolab.github.io in 1-3 minutes"

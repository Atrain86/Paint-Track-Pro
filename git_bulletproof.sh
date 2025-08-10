#!/bin/bash
# git_bulletproof.sh — Automatically saves, commits, and pushes changes to GitHub
# Usage:
#   ./git_bulletproof.sh           -> auto-commit with timestamp
#   ./git_bulletproof.sh "message" -> commit with custom message

set -e

# Step 1: Clean up possible stale Git lock files
if [ -f .git/index.lock ]; then
  echo "⚠ Removing stale Git index.lock file..."
  rm -f .git/index.lock
fi

# Step 2: Stage all changes
git add -A

# Step 3: Create commit message
if [ -n "$1" ]; then
  COMMIT_MSG="$1"
else
  COMMIT_MSG="Auto-save on $(date '+%Y-%m-%d %H:%M:%S')"
fi

# Step 4: Commit changes (ignore error if no changes to commit)
git commit -m "$COMMIT_MSG" || echo "ℹ No changes to commit."

# Step 5: Ensure we're on main/master and tracking remote
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
git branch --set-upstream-to=origin/$CURRENT_BRANCH $CURRENT_BRANCH 2>/dev/null || true

# Step 6: Pull latest changes before pushing (avoid conflicts)
git pull --rebase origin $CURRENT_BRANCH || echo "⚠ Could not rebase, continuing..."

# Step 7: Push changes
git push origin $CURRENT_BRANCH

echo "✅ Push complete!"
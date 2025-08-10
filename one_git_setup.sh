#!/usr/bin/env bash
set -e

REPO_URL="$1"   # e.g. https://github.com/USER/REPO.git
if [ -z "$REPO_URL" ]; then
  echo "Usage: bash one_git_setup.sh https://github.com/USER/REPO.git"
  exit 1
fi

echo "==> Clean any stuck git state..."
git rebase --abort 2>/dev/null || true
git cherry-pick --abort 2>/dev/null || true
git merge --abort 2>/dev/null || true
rm -rf .git/rebase-merge .git/rebase-apply
rm -f .git/index.lock .git/packed-refs.lock .git/config.lock .git/refs/remotes/origin/main.lock

echo "==> .gitignore (safe defaults)..."
cat > .gitignore <<'GI'
# Dependencies
node_modules/

# Build output
dist/
build/
.cache/
.next/
out/
.vercel/
.vite/

# Logs
*.log

# Env
.env
.env.*

# OS junk
.DS_Store

# User uploads & temp
uploads/
attached_assets/
public/uploads/
assets/uploads/
tmp/
GI

echo "==> Init git if needed; switch to main..."
[ -d .git ] || git init
git branch -M main 2>/dev/null || true

echo "==> Untrack big dirs just in case..."
git rm -r --cached node_modules dist build .cache .next out .vercel .vite uploads attached_assets public/uploads assets/uploads tmp 2>/dev/null || true

echo "==> Commit current state (if any changes)..."
git add -A
git commit -m "setup: .gitignore + clean repo" 2>/dev/null || true

echo "==> Wire remote origin..."
if git remote get-url origin >/dev/null 2>&1; then
  git remote set-url origin "$REPO_URL"
else
  git remote add origin "$REPO_URL"
fi

echo "==> Push to GitHub (auto-fix if behind)..."
set +e
git push -u origin main
PUSH_STATUS=$?
set -e
if [ $PUSH_STATUS -ne 0 ]; then
  echo "==> Non-fast-forward; pulling with rebase then pushing..."
  git pull --rebase origin main || true
  git push -u origin main || git push -u origin main --force
fi

echo "==> Install ./branch helper"
cat > branch <<'BRC'
#!/usr/bin/env bash
set -e
name="$1"
if [ -z "$name" ]; then
  echo "Usage: ./branch <new-or-existing-branch-name>"
  exit 1
fi
git rebase --abort 2>/dev/null || true
git cherry-pick --abort 2>/dev/null || true
rm -f .git/index.lock .git/packed-refs.lock .git/config.lock .git/refs/remotes/origin/main.lock
git switch -c "$name" 2>/dev/null || git switch "$name"
git add -A
git commit -m "start $name" 2>/dev/null || true
git push -u origin "$name" || true
echo "Now edit files, then run: ./save \"your message\""
BRC
chmod +x branch

echo "==> Install ./save helper"
cat > save <<'SAV'
#!/usr/bin/env bash
set -e
msg="$*"
[ -z "$msg" ] && msg="update"
git add -A
git commit -m "$msg" || true
git push
SAV
chmod +x save

echo
echo "All set!"
echo "Start a change:   ./branch popup-fix"
echo "Push your edits:  ./save \"fix popup\""

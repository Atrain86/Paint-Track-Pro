#!/usr/bin/env bash
set -e

REPO_URL="$1"  # e.g., https://github.com/USER/REPO.git
if [ -z "$REPO_URL" ]; then
  echo "Usage: bash setup_git.sh https://github.com/USER/REPO.git"
  exit 1
fi

# 0) Add/refresh a safe .gitignore
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

# Environment files
.env
.env.*

# System files
.DS_Store

# User-uploaded content
uploads/
attached_assets/
public/uploads/
assets/uploads/
tmp/
GI

# 1) Stop any stuck git ops + clear locks
git rebase --abort 2>/dev/null || true
git cherry-pick --abort 2>/dev/null || true
git merge --abort 2>/dev/null || true
rm -f .git/index.lock .git/packed-refs.lock .git/refs/remotes/origin/main.lock .git/config.lock

# 2) Init repo if missing
if [ ! -d .git ]; then
  git init
fi

# 3) Ensure main branch name
git branch -M main 2>/dev/null || true

# 4) Untrack big dirs if they were ever added
git rm -r --cached node_modules dist build .cache .next out .vercel .vite uploads attached_assets public/uploads assets/uploads tmp 2>/dev/null || true

# 5) Commit what we have (if any changes)
git add -A
git commit -m "setup: add .gitignore and clean repo" 2>/dev/null || true

# 6) Wire the remote
if git remote get-url origin >/dev/null 2>&1; then
  git remote set-url origin "$REPO_URL"
else
  git remote add origin "$REPO_URL"
fi

# 7) Push local as source of truth once (force)
git config --global push.autoSetupRemote true
git push -u origin main --force

# 8) Create helpers

# Helper: ./branch <name>  -> create/switch, prime, push
cat > branch <<'BRC'
#!/usr/bin/env bash
set -e
name="$1"
if [ -z "$name" ]; then
  echo "Usage: ./branch <new-or-existing-bra

# 0) Clean any leftover git locks (safe)
git rebase --abort 2>/dev/null || true
git cherry-pick --abort 2>/dev/null || true
rm -f .git/index.lock .git/packed-refs.lock .git/refs/remotes/origin/main.lock .git/config.lock

# 1) Install helper: ./branch  (create/switch branch and prime it)
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
rm -f .git/index.lock .git/packed-refs.lock .git/refs/remotes/origin/main.lock .git/config.lock
git switch -c "$name" 2>/dev/null || git switch "$name"
git add -A
git commit -m "start $name" 2>/dev/null || true
git push -u origin "$name" || true
echo "Now edit files, then run: ./save \"your message\""
BRC
chmod +x branch

# 2) Install helper: ./save  (add, commit, push)
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

# stop any half-finished ops and delete ALL lock files
git rebase --abort 2>/dev/null || true
git cherry-pick --abort 2>/dev/null || true
git merge --abort 2>/dev/null || true
rm -rf .git/rebase-merge .git/rebase-apply
rm -f .git/index.lock .git/packed-refs.lock .git/config.lock .git/refs/remotes/origin/main.lock

# sanity check
git status

cat > one_git_setup.sh <<'SH'
#!/usr/bin/env bash
set -e

REPO_URL="$1"   # e.g. https://github.com/USER/REPO.git
if [ -z "$REPO_URL" ]; then
  echo "Usage: bash one_git_setup.sh https://github.com/USER/REPO.git"
  exit 1
fi

echo "==> Cleaning any stuck git state..."
git rebase --abort 2>/dev/null || true
git cherry-pick --abort 2>/dev/null || true
git merge --abort 2>/dev/null || true
rm -rf .git/rebase-merge .git/rebase-apply
rm -f .git/index.lock .git/packed-refs.lock .git/config.lock .git/refs/remotes/origin/main.lock

echo "==> Ensuring a safe .gitignore..."
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

echo "==> Initializing git (if needed) and switching to main..."
[ -d .git ] || git init
git branch -M main 2>/dev/null || true

echo "==> Untracking big dirs just in case..."
git rm -r --cached node_modules dist build .cache .next out .vercel .vite uploads attached_assets public/uploads assets/uploads tmp 2>/dev/null || true

echo "==> Committing current state..."
git add -A
git commit -m "setup: .gitignore + clean repo" 2>/dev/null || true

echo "==> Wiring remote origin..."
if git remote get-url origin >/dev/null 2>&1; then
  git remote set-url origin "$REPO_URL"
else
  git remote add origin "$REPO_URL"
fi

echo "==> Pushing to GitHub (will auto-fix if behind)..."
set +e
git push -u origin main
PUSH_STATUS=$?
set -e
if [ $PUSH_STATUS -ne 0 ]; then
  echo "==> Detected non-fast-forward; pulling with rebase then pushing..."
  git pull --rebase origin main
  git push -u origin main
fi

echo "==> Installing helper: ./branch"
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

echo "==> Installing helper: ./save"
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
echo "Use:   ./branch popup-fix   # start a safe branch"
echo "Then:  ./save \"your message\"   # commit & push"

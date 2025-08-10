#!/usr/bin/env bash
set -e

# 0) Clean any stuck git ops/locks (safe)
git rebase --abort 2>/dev/null || true
git cherry-pick --abort 2>/dev/null || true
git merge --abort 2>/dev/null || true
rm -rf .git/rebase-merge .git/rebase-apply
rm -f .git/index.lock .git/packed-refs.lock .git/config.lock .git/refs/remotes/origin/main.lock

# 1) Add everything and commit (use arg as message or timestamp)
MSG="$*"
[ -z "$MSG" ] && MSG="auto: $(date -u +'%Y-%m-%d %H:%M:%S UTC')"
git add -A
git commit -m "$MSG" || true

# 2) Push (auto-handle upstream + behind-remote)
set +e
git push
PUSH_STATUS=$?
set -e

if [ $PUSH_STATUS -ne 0 ]; then
  # If no upstream yet, set it to origin/<current-branch>
  CUR=$(git rev-parse --abbrev-ref HEAD)
  git push -u origin "$CUR" || {
    # If still failing (usually behind), pull --rebase then push
    git pull --rebase origin "$CUR" || true
    git push -u origin "$CUR" || git push -u origin "$CUR" --force-with-lease
  }
fi

echo "✅ Saved & pushed successfully."
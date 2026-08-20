#!/usr/bin/env bash
# ---------------------------------------------------------------
#  Deploy the Cut Guide PWA to https://github.com/KrisJ477/CutManager
#  This folder is its own repository, deliberately separate from the
#  parent PipeGCodeGenerator repo it sits inside.
# ---------------------------------------------------------------
set -euo pipefail

cd "$(dirname "$0")"
REMOTE="https://github.com/KrisJ477/CutManager.git"
GITNAME="Kris"
GITMAIL="kris@pipegcode.local"

echo
echo "=== K&J Cut Guide - deploy ==="
echo "Folder: $(pwd)"
echo

command -v git >/dev/null || { echo "ERROR: git not found."; exit 1; }

# Check for .git in THIS folder only - rev-parse walks up and would find
# the parent repository instead.
if [ ! -d .git ]; then
  echo "Initialising a repository in this folder..."
  git init
fi

# A fresh repo inherits nothing from the parent, whose identity was set
# locally rather than globally. Without this, commit fails.
if ! git config user.email >/dev/null 2>&1; then
  echo "Setting commit identity for this repository..."
  git config user.name  "$GITNAME"
  git config user.email "$GITMAIL"
fi

if git rev-parse --verify HEAD >/dev/null 2>&1; then
  git branch -M main
else
  git checkout -B main
fi

if ! git remote get-url origin >/dev/null 2>&1; then
  git remote add origin "$REMOTE"
else
  CURRENT=$(git remote get-url origin)
  if [ "$CURRENT" != "$REMOTE" ]; then
    echo "Repointing origin from $CURRENT"
    git remote set-url origin "$REMOTE"
  fi
fi

if git ls-remote --exit-code --heads origin main >/dev/null 2>&1; then
  echo "Rebasing on origin/main..."
  git pull --rebase origin main
fi

echo "Staging files..."
git add -A

if git diff --cached --quiet; then
  echo "Nothing changed since the last deploy."
else
  git commit -m "Deploy $(date '+%Y-%m-%d %H:%M:%S')"
fi

echo "Pushing..."
git push -u origin main

echo
echo "Done. Live shortly at:"
echo "  https://krisj477.github.io/CutManager/"

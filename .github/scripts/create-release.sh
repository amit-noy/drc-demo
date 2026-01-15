#!/bin/bash
set -e

# ========================================
# Release script: commit, tag, push
# ========================================
# This script:
# 1️⃣ Reads FINAL_VERSION from package.json bump
# 2️⃣ Generates branch-aware release tag (without double suffix)
# 3️⃣ Commits package.json changes
# 4️⃣ Tags commit
# 5️⃣ Pushes commit + tag

# Required env:
# BRANCH
# FINAL_VERSION

if [ -z "$BRANCH" ]; then
  echo "[!] Missing required env var: BRANCH"
  exit 1
fi

if [ -z "$FINAL_VERSION" ]; then
  echo "[!] Missing required env var: FINAL_VERSION"
  exit 1
fi

echo "---------------------------------------------------"
echo "[1] Branch: $BRANCH"
echo "[2] Version from bump script: $FINAL_VERSION"

# -----------------------
# 2️⃣ Generate release tag safely
# -----------------------
# Strip numeric version from FINAL_VERSION (in case branch suffix already exists)
NUMERIC_VERSION=$(echo "$FINAL_VERSION" | grep -oE '^[0-9]+\.[0-9]+\.[0-9]+')

if [ "$BRANCH" = "development" ]; then
  RELEASE_TAG="v$NUMERIC_VERSION"
else
  SAFE_BRANCH=$(echo "$BRANCH" | tr '/' '-')
  RELEASE_TAG="v$NUMERIC_VERSION-$SAFE_BRANCH"
fi

echo "[3] Generated release tag: $RELEASE_TAG"
echo "RELEASE_TAG=$RELEASE_TAG" >> "$GITHUB_ENV"

# -----------------------
# 3️⃣ Commit version bump
# -----------------------
git config user.name "github-actions[bot]"
git config user.email "github-actions[bot]@users.noreply.github.com"

git add package.json package-lock.json
git commit -m "chore(release): bump version to ${FINAL_VERSION}" || {
  echo "[4] No changes to commit"
}

# -----------------------
# 4️⃣ Tag commit
# -----------------------
git tag "${RELEASE_TAG}"
echo "[5] Tagged commit with: ${RELEASE_TAG}"

# -----------------------
# 5️⃣ Push commit + tag
# -----------------------
git push origin "$BRANCH"
git push origin "${RELEASE_TAG}"
echo "[6] Pushed commit and tag to origin"
echo "---------------------------------------------------"

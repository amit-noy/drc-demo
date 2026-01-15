#!/bin/bash
set -e

# Required env:
# BRANCH

if [ -z "$BRANCH" ]; then
  echo "Missing required env var: BRANCH"
  exit 1
fi

# -----------------------
# 1️⃣ Read current version
# -----------------------
NEW_VERSION=$(node -p "require('./package.json').version")

# -----------------------
# 2️⃣ Generate release tag
# -----------------------
if [ "$BRANCH" = "development" ]; then
  RELEASE_TAG="v$NEW_VERSION"
else
  SAFE_BRANCH=$(echo "$BRANCH" | tr '/' '-')
  RELEASE_TAG="v$NEW_VERSION-$SAFE_BRANCH"
fi

echo "Generated release tag: $RELEASE_TAG"
echo "RELEASE_TAG=$RELEASE_TAG" >> "$GITHUB_ENV"

# -----------------------
# 3️⃣ Commit version bump
# -----------------------
git config user.name "github-actions[bot]"
git config user.email "github-actions[bot]@users.noreply.github.com"

git add package.json package-lock.json
git commit -m "chore(release): bump version to ${NEW_VERSION}" || {
  echo "No changes to commit"
  exit 0
}

# -----------------------
# 4️⃣ Tag commit
# -----------------------
git tag "${RELEASE_TAG}"

# -----------------------
# 5️⃣ Push commit + tag
# -----------------------
git push origin "$BRANCH"
git push origin "${RELEASE_TAG}"

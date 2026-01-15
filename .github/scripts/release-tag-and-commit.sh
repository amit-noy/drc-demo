#!/bin/bash
set -e

# Required env:
# NEW_VERSION
# BRANCH

if [ -z "$NEW_VERSION" ] || [ -z "$BRANCH" ]; then
  echo "Missing required env vars: NEW_VERSION or BRANCH"
  exit 1
fi

# -----------------------
# Generate release tag
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
# Commit version bump
# -----------------------
git config user.name "github-actions[bot]"
git config user.email "github-actions[bot]@users.noreply.github.com"

git add package.json package-lock.json
git commit -m "chore(release): bump version to ${NEW_VERSION}" || {
  echo "No changes to commit"
  exit 0
}

# -----------------------
# Tag commit
# -----------------------
git tag "${RELEASE_TAG}"

# -----------------------
# Push commit + tag
# -----------------------
git push origin "$BRANCH"
git push origin "${RELEASE_TAG}"

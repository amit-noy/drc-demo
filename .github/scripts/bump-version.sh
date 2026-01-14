#!/bin/bash
set -e

# Required env:
# INPUT_VERSION: optional (patch | minor | major | x.y.z)
# BRANCH: branch to push changes (e.g., development)

git config user.name "github-actions[bot]"
git config user.email "github-actions[bot]@users.noreply.github.com"

CURRENT_VERSION=$(node -p "require('./package.json').version")
echo "Current version: $CURRENT_VERSION"

# Bump version according to input (patch/minor/major/custom)
case "$INPUT_VERSION" in
  major|minor|patch)
    npm version "$INPUT_VERSION" --no-git-tag-version
    ;;
  "")
    npm version patch --no-git-tag-version
    ;;
  *)
    npm version "$INPUT_VERSION" --no-git-tag-version
    ;;
esac

# Get bumped version (numeric)
NEW_RAW_VERSION=$(node -p "require('./package.json').version")
echo "Bumped numeric version: $NEW_RAW_VERSION"

# Update package.json with numeric version only
jq --arg ver "$NEW_RAW_VERSION" '.version = $ver' package.json > package.tmp.json && mv package.tmp.json package.json

# Determine GitHub Release tag (v-prefixed)
if [ "$BRANCH" = "development" ]; then
  RELEASE_TAG="v$NEW_RAW_VERSION"
else
  SAFE_BRANCH=$(echo "$BRANCH" | tr '/' '-')
  RELEASE_TAG="v$NEW_RAW_VERSION-$SAFE_BRANCH"
fi

echo "GitHub Release tag: $RELEASE_TAG"
echo "RELEASE_TAG=$RELEASE_TAG" >> "$GITHUB_ENV"

# Commit updated package files
git add package.json package-lock.json
git commit -m "chore(release): bump version to $NEW_RAW_VERSION" || echo "No changes to commit"

git pull origin "$BRANCH" --rebase
git push origin "$BRANCH"

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

# Get bumped version
NEW_RAW_VERSION=$(node -p "require('./package.json').version")

# Determine suffix: only add for non-development branches
if [ "$BRANCH" = "development" ]; then
  NEW_VERSION="$NEW_RAW_VERSION"
else
  # Replace slashes in branch names with dashes (e.g., poc/something → poc-something)
  SAFE_BRANCH=$(echo "$BRANCH" | tr '/' '-')
  NEW_VERSION="$NEW_RAW_VERSION-$SAFE_BRANCH"
fi

echo "New version: $NEW_VERSION"
echo "NEW_VERSION=$NEW_VERSION" >> "$GITHUB_ENV"

# Update package.json with the final version (including branch suffix)
# This ensures the version in package.json matches NEW_VERSION
jq --arg ver "$NEW_VERSION" '.version = $ver' package.json > package.tmp.json && mv package.tmp.json package.json

git add package.json package-lock.json
git commit -m "chore(release): bump version to $NEW_VERSION" || echo "No changes to commit"

git pull origin "$BRANCH" --rebase
git push origin "$BRANCH"

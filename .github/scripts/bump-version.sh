#!/bin/bash
set -e

# Required env:
# INPUT_VERSION: patch | minor | major
# BRANCH: branch name (e.g., development)

git config user.name "github-actions[bot]"
git config user.email "github-actions[bot]@users.noreply.github.com"

CURRENT_VERSION=$(node -p "require('./package.json').version")
echo "Current version: $CURRENT_VERSION"

# Extract numeric version only (x.y.z) ignoring any suffix
BASE_VERSION=$(echo "$CURRENT_VERSION" | grep -oE '^[0-9]+\.[0-9]+\.[0-9]+')
echo "Base numeric version: $BASE_VERSION"

IFS='.' read -r MAJOR MINOR PATCH <<< "$BASE_VERSION"

# Bump version according to INPUT_VERSION
case "$INPUT_VERSION" in
  patch) PATCH=$((PATCH + 1)) ;;
  minor) MINOR=$((MINOR + 1)); PATCH=0 ;;
  major) MAJOR=$((MAJOR + 1)); MINOR=0; PATCH=0 ;;
  *)
    echo "Invalid INPUT_VERSION: $INPUT_VERSION"
    exit 1
    ;;
esac

NEW_VERSION="$MAJOR.$MINOR.$PATCH"
echo "Bumped numeric version: $NEW_VERSION"

# Add branch suffix for release tag if not development
if [ "$BRANCH" = "development" ]; then
  FINAL_VERSION="$NEW_VERSION"
else
  SAFE_BRANCH=$(echo "$BRANCH" | tr '/' '-')
  FINAL_VERSION="$NEW_VERSION-$SAFE_BRANCH"
fi

# Update package.json
jq --arg ver "$FINAL_VERSION" '.version = $ver' package.json > package.tmp.json && mv package.tmp.json package.json

# Export for workflow
echo "NEW_VERSION=$NEW_VERSION" >> "$GITHUB_ENV"
echo "FINAL_VERSION=$FINAL_VERSION" >> "$GITHUB_ENV"

echo "Version updated in package.json: $FINAL_VERSION"
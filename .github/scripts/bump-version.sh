#!/bin/bash
set -e

# Required env:
# INPUT_VERSION - optional manual version (without "v")
# BRANCH - branch to push changes (e.g., development)

git config user.name "github-actions[bot]"
git config user.email "github-actions[bot]@users.noreply.github.com"

CURRENT_VERSION=$(node -p "require('./package.json').version")

if [ -n "$INPUT_VERSION" ]; then
  RAW_VERSION="$INPUT_VERSION"
else
  IFS='.' read -r MAJOR MINOR PATCH <<< "$CURRENT_VERSION"
  PATCH=$((PATCH + 1))
  RAW_VERSION="$MAJOR.$MINOR.$PATCH"
fi

NEW_VERSION="v$RAW_VERSION"

echo "Current version: $CURRENT_VERSION"
echo "New version: $NEW_VERSION"

echo "NEW_VERSION=$NEW_VERSION" >> "$GITHUB_ENV"

# Update package.json + lockfile WITHOUT tag
npm version "$RAW_VERSION" --no-git-tag-version

git add package.json package-lock.json
git commit -m "chore(release): bump version to $NEW_VERSION" || echo "No changes to commit"

git pull origin "$BRANCH" --rebase
git push origin "$BRANCH"

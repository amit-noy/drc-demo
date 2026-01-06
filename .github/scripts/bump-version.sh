#!/bin/bash
set -e

# Required env:
# INPUT_VERSION - optional manual version
# BRANCH - branch to push changes (e.g., development)

git config user.name "github-actions"
git config user.email "github-actions@github.com"

# Get current version from package.json
CURRENT_VERSION=$(node -p "require('./package.json').version")

if [ -n "$INPUT_VERSION" ]; then
  RAW_VERSION=$INPUT_VERSION
else
  # Increment patch version manually
  IFS='.' read -r MAJOR MINOR PATCH <<< "$CURRENT_VERSION"
  PATCH=$((PATCH + 1))
  RAW_VERSION="$MAJOR.$MINOR.$PATCH"
fi

# Add 'v' prefix
NEW_VERSION="v$RAW_VERSION"

echo "Current version: $CURRENT_VERSION"
echo "New version: $NEW_VERSION"

echo "NEW_VERSION=$NEW_VERSION" >> $GITHUB_ENV

# Update package.json and package-lock.json
# Remove the 'v' before passing to npm version because npm doesn't like the 'v' in package.json
npm version "$RAW_VERSION" --no-git-tag-version

# Commit and push
git add package.json package-lock.json
git commit -m "chore(release): bump version to $NEW_VERSION" || echo "No changes to commit"
git pull origin "$BRANCH" --rebase
git push origin "$BRANCH"

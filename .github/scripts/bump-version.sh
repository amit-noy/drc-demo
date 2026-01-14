#!/bin/bash
set -e

# Required env:
# INPUT_VERSION - optional (patch | minor | major | x.y.z)
# BRANCH - branch to push changes (e.g., development)

git config user.name "github-actions[bot]"
git config user.email "github-actions[bot]@users.noreply.github.com"

CURRENT_VERSION=$(node -p "require('./package.json').version")

echo "Current version: $CURRENT_VERSION"

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

NEW_RAW_VERSION=$(node -p "require('./package.json').version")
NEW_VERSION="v$NEW_RAW_VERSION"

echo "New version: $NEW_VERSION"
echo "NEW_VERSION=$NEW_VERSION" >> "$GITHUB_ENV"

git add package.json package-lock.json
git commit -m "chore(release): bump version to $NEW_VERSION" || echo "No changes to commit"

git pull origin "$BRANCH" --rebase
git push origin "$BRANCH"

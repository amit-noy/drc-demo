#!/bin/bash
set -e

# Required env:
# INPUT_VERSION - optional manual version
# BRANCH - branch to push changes (e.g., development)

git config user.name "github-actions"
git config user.email "github-actions@github.com"

if [ -n "$INPUT_VERSION" ]; then
  NEW_VERSION=$INPUT_VERSION
else
  NEW_VERSION=$(npm version patch --no-git-tag-version)
fi

echo "NEW_VERSION=$NEW_VERSION" >> $GITHUB_ENV

# Commit and push updated package.json/package-lock.json
git add package.json package-lock.json
git commit -m "chore(release): bump version to $NEW_VERSION" || echo "No changes to commit"
git pull origin "$BRANCH" --rebase
git push origin "$BRANCH"

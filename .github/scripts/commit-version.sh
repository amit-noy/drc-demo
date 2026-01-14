#!/bin/bash
set -e

# Required env:
# NEW_VERSION
# BRANCH

git config user.name "github-actions[bot]"
git config user.email "github-actions[bot]@users.noreply.github.com"

git add package.json package-lock.json
git commit -m "chore(release): bump version to $NEW_VERSION" || echo "No changes to commit"
git pull origin "$BRANCH" --rebase
git push origin "$BRANCH"

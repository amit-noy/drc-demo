#!/bin/bash
set -e

# Required env:
# INPUT_VERSION: patch | minor | major
# BRANCH: branch name (e.g., development)

CURRENT_VERSION=$(node -p "require('./package.json').version")
echo "Current version: $CURRENT_VERSION"

# Strip branch suffix (0.3.2-feature → 0.3.2)
BASE_VERSION="${CURRENT_VERSION%%-*}"

IFS='.' read -r MAJOR MINOR PATCH <<< "$BASE_VERSION"

# Semantic version bump
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

# Update package.json
jq --arg ver "$NEW_VERSION" '.version = $ver' package.json > package.tmp.json && mv package.tmp.json package.json

# Export for workflow
echo "NEW_VERSION=$NEW_VERSION" >> "$GITHUB_ENV"

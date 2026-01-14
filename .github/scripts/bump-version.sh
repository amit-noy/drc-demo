#!/bin/bash
set -e

# Required env:
# INPUT_VERSION: (patch | minor | major)
# INPUT_TAG: optional custom tag (e.g., test-tag)
# BRANCH: branch to push changes (e.g., development)

git config user.name "github-actions[bot]"
git config user.email "github-actions[bot]@users.noreply.github.com"

CURRENT_VERSION=$(node -p "require('./package.json').version")
echo "Current version: $CURRENT_VERSION"

# Strip branch suffix if present (e.g. 0.3.2-1.10.x → 0.3.2)
BASE_VERSION="${CURRENT_VERSION%%-*}"

IFS='.' read -r MAJOR MINOR PATCH <<< "$BASE_VERSION"

if [ -n "$INPUT_TAG" ]; then
  # Custom tag → do NOT bump version
  NEW_RAW_VERSION="$BASE_VERSION"
  NEW_VERSION="$NEW_RAW_VERSION-$INPUT_TAG"
  echo "Custom tag provided, version not bumped: $NEW_VERSION"
else
  # Manual semver bump (safe with suffixes)
  case "$INPUT_VERSION" in
    patch)
      PATCH=$((PATCH + 1))
      ;;
    minor)
      MINOR=$((MINOR + 1))
      PATCH=0
      ;;
    major)
      MAJOR=$((MAJOR + 1))
      MINOR=0
      PATCH=0
      ;;
    *)
      echo "Invalid INPUT_VERSION: $INPUT_VERSION"
      exit 1
      ;;
  esac

  NEW_RAW_VERSION="$MAJOR.$MINOR.$PATCH"
  echo "Bumped numeric version: $NEW_RAW_VERSION"

  # Add branch suffix if not development
  if [ "$BRANCH" = "development" ]; then
    NEW_VERSION="$NEW_RAW_VERSION"
  else
    SAFE_BRANCH=$(echo "$BRANCH" | tr '/' '-')
    NEW_VERSION="$NEW_RAW_VERSION-$SAFE_BRANCH"
  fi

  # Update package.json
  jq --arg ver "$NEW_VERSION" '.version = $ver' package.json > package.tmp.json && mv package.tmp.json package.json

  # Commit and push
  git add package.json package-lock.json
  git commit -m "chore(release): bump version to $NEW_VERSION" || echo "No changes to commit"
  git pull origin "$BRANCH" --rebase
  git push origin "$BRANCH"
fi

# Determine GitHub Release tag
if [ -n "$INPUT_TAG" ]; then
  RELEASE_TAG="$NEW_RAW_VERSION-$INPUT_TAG"
else
  if [ "$BRANCH" = "development" ]; then
    RELEASE_TAG="v$NEW_RAW_VERSION"
  else
    SAFE_BRANCH=$(echo "$BRANCH" | tr '/' '-')
    RELEASE_TAG="v$NEW_RAW_VERSION-$SAFE_BRANCH"
  fi
fi

echo "Final RELEASE_TAG: $RELEASE_TAG"
echo "NEW_VERSION=$NEW_VERSION" >> "$GITHUB_ENV"
echo "RELEASE_TAG=$RELEASE_TAG" >> "$GITHUB_ENV"

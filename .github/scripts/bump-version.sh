#!/bin/bash
set -e

# Required env:
# INPUT_VERSION: optional (patch | minor | major | x.y.z)
# INPUT_TAG: optional custom tag (e.g., test-tag)
# BRANCH: branch to push changes (e.g., development)

git config user.name "github-actions[bot]"
git config user.email "github-actions[bot]@users.noreply.github.com"

CURRENT_VERSION=$(node -p "require('./package.json').version")
echo "Current version: $CURRENT_VERSION"

if [ -n "$INPUT_TAG" ]; then
  # Custom tag provided → don't bump version
  NEW_RAW_VERSION="$CURRENT_VERSION"
  NEW_VERSION="$NEW_RAW_VERSION-$INPUT_TAG"
  echo "Custom tag provided, version not bumped: $NEW_VERSION"
else
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

  # Get bumped numeric version
  NEW_RAW_VERSION=$(node -p "require('./package.json').version")
  echo "Bumped numeric version: $NEW_RAW_VERSION"

  # Add branch suffix if not development
  if [ "$BRANCH" = "development" ]; then
    NEW_VERSION="$NEW_RAW_VERSION"
  else
    SAFE_BRANCH=$(echo "$BRANCH" | tr '/' '-')
    NEW_VERSION="$NEW_RAW_VERSION-$SAFE_BRANCH"
  fi

  # Update package.json with final version
  jq --arg ver "$NEW_VERSION" '.version = $ver' package.json > package.tmp.json && mv package.tmp.json package.json

  # Commit changes
  git add package.json package-lock.json
  git commit -m "chore(release): bump version to $NEW_VERSION" || echo "No changes to commit"
  git pull origin "$BRANCH" --rebase
  git push origin "$BRANCH"
fi

# Determine GitHub Release tag (v-prefixed)
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

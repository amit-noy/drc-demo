#!/bin/bash
set -e

# ========================================
# Bump version script with branch suffix
# ========================================
# This script:
# Reads current version from package.json
# Extracts numeric version only
# Bumps patch, minor, or major
# Adds branch suffix if not development
# Updates package.json
# Exports NEW_VERSION and FINAL_VERSION for workflow

# Required env:
# INPUT_VERSION: patch | minor | major
# BRANCH: branch name (e.g., development)

git config user.name "github-actions[bot]"
git config user.email "github-actions[bot]@users.noreply.github.com"

echo "---------------------------------------------------"
echo "[1] Current branch: $BRANCH"
CURRENT_VERSION=$(node -p "require('./package.json').version")
echo "[2] Current version in package.json: $CURRENT_VERSION"

# -----------------------
# Extract numeric version only
# -----------------------
BASE_VERSION=$(echo "$CURRENT_VERSION" | grep -oE '^[0-9]+\.[0-9]+\.[0-9]+')
echo "[3] Base numeric version: $BASE_VERSION"

IFS='.' read -r MAJOR MINOR PATCH <<< "$BASE_VERSION"

# -----------------------
# Bump numeric version
# -----------------------
case "$INPUT_VERSION" in
  patch)
    PATCH=$((PATCH + 1))
    echo "[4] Bumping PATCH → $PATCH"
    ;;
  minor)
    MINOR=$((MINOR + 1))
    PATCH=0
    echo "[4] Bumping MINOR → $MINOR and resetting PATCH → $PATCH"
    ;;
  major)
    MAJOR=$((MAJOR + 1))
    MINOR=0
    PATCH=0
    echo "[4] Bumping MAJOR → $MAJOR and resetting MINOR/PATCH → $MINOR/$PATCH"
    ;;
  *)
    echo "[!] Invalid INPUT_VERSION: $INPUT_VERSION"
    exit 1
    ;;
esac

NEW_VERSION="$MAJOR.$MINOR.$PATCH"
echo "[5] Numeric version after bump: $NEW_VERSION"

# -----------------------
# Add branch suffix if not development
# -----------------------
if [ "$BRANCH" = "development" ]; then
  FINAL_VERSION="$NEW_VERSION"
else
  SAFE_BRANCH=$(echo "$BRANCH" | tr '/' '-')
  FINAL_VERSION="$NEW_VERSION-$SAFE_BRANCH"
fi
echo "[6] Final version to write to package.json: $FINAL_VERSION"

# -----------------------
# Update package.json
# -----------------------
jq --arg ver "$FINAL_VERSION" '.version = $ver' package.json > package.tmp.json && mv package.tmp.json package.json
echo "[7] package.json updated with version $FINAL_VERSION"

# -----------------------
# Export versions for workflow
# -----------------------
echo "FINAL_VERSION=$FINAL_VERSION" >> "$GITHUB_ENV"

echo "[8] Version bump complete ✅"
echo "---------------------------------------------------"

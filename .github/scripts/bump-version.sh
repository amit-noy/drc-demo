#!/bin/bash
set -e

# ============================
# Bump package version script
# ============================
# This script:
# 1. Reads the current version from package.json
# 2. Extracts numeric version only (x.y.z), ignoring any branch suffix
# 3. Bumps the version according to INPUT_VERSION (patch, minor, major)
# 4. Resets PATCH/MINOR when appropriate
# 5. Updates package.json safely
# 6. Exports NEW_VERSION for use in the release script
# 7. Logs all steps for clarity

# Required env:
# INPUT_VERSION: patch | minor | major

echo "---------------------------------------------------"
echo "Bumping package version (type: $INPUT_VERSION)"
echo "---------------------------------------------------"

# -----------------------
# Read current version
# -----------------------
CURRENT_VERSION=$(node -p "require('./package.json').version")
echo "[1] Current package.json version: $CURRENT_VERSION"

# -----------------------
# Extract numeric part only
# -----------------------
# Example: "1.2.3-feature" → "1.2.3"
NUMERIC_VERSION=$(echo "$CURRENT_VERSION" | grep -oE '^[0-9]+\.[0-9]+\.[0-9]+')
echo "[2] Base numeric version extracted: $NUMERIC_VERSION"

IFS='.' read -r MAJOR MINOR PATCH <<< "$NUMERIC_VERSION"
echo "[2a] Parsed: MAJOR=$MAJOR, MINOR=$MINOR, PATCH=$PATCH"

# -----------------------
# Semantic version bump
# -----------------------
case "$INPUT_VERSION" in
  patch)
    PATCH=$((PATCH + 1))
    echo "[3] Bumping PATCH → $PATCH"
    ;;
  minor)
    MINOR=$((MINOR + 1))
    PATCH=0
    echo "[3] Bumping MINOR → $MINOR and resetting PATCH → $PATCH"
    ;;
  major)
    MAJOR=$((MAJOR + 1))
    MINOR=0
    PATCH=0
    echo "[3] Bumping MAJOR → $MAJOR and resetting MINOR/PATCH → $MINOR/$PATCH"
    ;;
  *)
    echo "[!] Invalid INPUT_VERSION: $INPUT_VERSION"
    exit 1
    ;;
esac

NEW_VERSION="$MAJOR.$MINOR.$PATCH"
echo "[4] New numeric version: $NEW_VERSION"

# -----------------------
# Update package.json
# -----------------------
echo "[5] Updating package.json with new version $NEW_VERSION"
jq --arg ver "$NEW_VERSION" '.version = $ver' package.json > package.tmp.json && mv package.tmp.json package.json

# -----------------------
# Export NEW_VERSION for workflow
# -----------------------
echo "[6] Exporting NEW_VERSION for workflow / release script"
echo "NEW_VERSION=$NEW_VERSION" >> "$GITHUB_ENV"

# -----------------------
# Final log
# -----------------------
echo "[7] Version bump complete ✅"
echo "[7a] package.json now has version: $NEW_VERSION"
echo "---------------------------------------------------"

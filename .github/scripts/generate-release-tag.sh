#!/bin/bash
set -e

# Required env:
# NEW_VERSION: from bump-version.sh
# BRANCH: branch name

if [ "$BRANCH" = "development" ]; then
  RELEASE_TAG="v$NEW_VERSION"
else
  SAFE_BRANCH=$(echo "$BRANCH" | tr '/' '-')
  RELEASE_TAG="v$NEW_VERSION-$SAFE_BRANCH"
fi

echo "Generated release tag: $RELEASE_TAG"
echo "RELEASE_TAG=$RELEASE_TAG" >> "$GITHUB_ENV"

#!/bin/bash
set -e

# Required env:
# GH_TOKEN - GitHub personal access token
# NEW_VERSION - new version string, e.g., 1.3.0

# Normalize repo URL from package.json
REPO_URL=$(node -p "require('./package.json').repository.url")
if [[ "$REPO_URL" == git://* ]]; then
  REPO_URL=${REPO_URL#git://}
  REPO_URL=${REPO_URL%.git}
  REPO_URL="https://$REPO_URL"
else
  REPO_URL=${REPO_URL#git@github.com:}
  REPO_URL=${REPO_URL#https://github.com/}
  REPO_URL=${REPO_URL%.git}
  REPO_URL="https://github.com/$REPO_URL"
fi

# Get last tag (or empty if none)
LAST_TAG=$(git describe --tags --abbrev=0 HEAD 2>/dev/null || echo "")
if [ -z "$LAST_TAG" ]; then
  echo "No previous tags found. Using all commits."
  LAST_TAG_DATE=""
else
  LAST_TAG_DATE=$(git log -1 --format=%cI $LAST_TAG)
fi

# Fetch merged PRs since last tag
PRS=$(gh pr list --repo $REPO_URL \
      --state merged \
      --base development \
      --json number,title,author,url,mergedAt \
      --limit 100)

# Filter PRs merged after last tag date (if any)
if [ -n "$LAST_TAG_DATE" ]; then
  PRS=$(echo "$PRS" | jq --arg DATE "$LAST_TAG_DATE" '[.[] | select(.mergedAt > $DATE)]')
fi

# Build release notes with actual newlines
NOTES="## What's Changed
"

if [ $(echo "$PRS" | jq 'length') -eq 0 ]; then
  NOTES+="* No merged PRs since last release
"
else
  for row in $(echo "$PRS" | jq -r '.[] | @base64'); do
    _jq() { echo "$row" | base64 --decode | jq -r "$1"; }
    TITLE=$(_jq '.title')
    NUMBER=$(_jq '.number')
    USER=$(_jq '.author.login')
    # Replace URL with #(PR number)
    NOTES+="* $TITLE by @$USER #$NUMBER
  "
  done
fi

NOTES+="
**Full Changelog**: $REPO_URL/compare/$LAST_TAG...$NEW_VERSION
"

# Export release notes safely to GITHUB_ENV
echo "RELEASE_NOTES<<EOF" >> $GITHUB_ENV
echo "$NOTES" >> $GITHUB_ENV
echo "EOF" >> $GITHUB_ENV

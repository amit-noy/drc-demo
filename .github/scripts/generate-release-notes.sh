#!/bin/bash
set -e

# Required env:
# GH_TOKEN - GitHub personal access token
# NEW_VERSION - new version string, e.g., 1.3.0

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

LAST_TAG=$(git describe --tags --abbrev=0 HEAD 2>/dev/null || echo "")
if [ -z "$LAST_TAG" ]; then
  LAST_COMMIT=""
else
  LAST_COMMIT=$(git rev-list -n 1 $LAST_TAG)
fi

PRS=$(gh pr list --repo $REPO_URL \
      --state merged \
      --base development \
      --json number,title,author,url,mergedAt \
      --limit 100)

if [ -n "$LAST_COMMIT" ]; then
  PRS=$(echo "$PRS" | jq --arg LAST "$LAST_COMMIT" '[.[] | select(.mergedAt > $LAST)]')
fi

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
    URL=$(_jq '.url')
    NOTES+="* $TITLE by @$USER in $URL
"
  done
fi

NOTES+="
**Full Changelog**: $REPO_URL/compare/$LAST_TAG...$NEW_VERSION
"

echo "RELEASE_NOTES<<EOF" >> $GITHUB_ENV
echo "$NOTES" >> $GITHUB_ENV
echo "EOF" >> $GITHUB_ENV

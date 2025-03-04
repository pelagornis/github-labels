#!/bin/bash

set -e

ORG_NAME="pelagornis"
GH_TOKEN="${GH_TOKEN}" 
API_URL="https://api.github.com"

REPOS=$(curl -s -H "Authorization: Bearer $GH_TOKEN" \
              -H "Accept: application/vnd.github+json" \
              "$API_URL/orgs/$ORG_NAME/repos?per_page=100" | jq -r '.[].name')

for REPO in $REPOS; do
  echo "Syncing labels for repository: $REPO"
  
  npx github-label-sync --access-token "$GH_TOKEN" --labels script/labels.json "$ORG_NAME"/"$REPO"

  echo "Labels synchronized for $REPO"
done

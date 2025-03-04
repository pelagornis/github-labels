#!/bin/bash

set -e

ORG_NAME="pelagornis"
GH_TOKEN="${GH_TOKEN}" 
API_URL="https://api.github.com"
LABELS_FILE="./labels.json"

if [ -z "$GH_TOKEN" ]; then
  echo "Error: GH_TOKEN is not set."
  exit 1
fi

REPOS=$(curl -s -H "Authorization: Bearer $GH_TOKEN" \
              -H "Accept: application/vnd.github+json" \
              "$API_URL/orgs/$ORG_NAME/repos?per_page=100" | jq -r '.[].name')

for REPO in $REPOS; do
  echo "Syncing labels for repository: $REPO"
  
  npx github-label-sync --access-token "$GH_TOKEN" --labels "$LABELS_FILE" "$ORG_NAME/$REPO"

  echo "Labels synchronized for $REPO"
done

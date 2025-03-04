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

LABELS=$(jq -c '.[]' "$LABELS_FILE")

REPOS=$(curl -s -H "Authorization: Bearer $GH_TOKEN" \
              -H "Accept: application/vnd.github+json" \
              "$API_URL/orgs/$ORG_NAME/repos?per_page=100" | jq -r '.[].name')

for REPO in $REPOS; do
  echo "Syncing labels for repository: $REPO"
  
  for LABEL in $LABELS; do
    LABEL_NAME=$(echo $LABEL | jq -r '.name')
    LABEL_COLOR=$(echo $LABEL | jq -r '.color')
    LABEL_DESC=$(echo $LABEL | jq -r '.description')
    
    echo "Adding label '$LABEL_NAME' to repository: $REPO"
    
    curl -X POST -H "Authorization: Bearer $GH_TOKEN" \
         -H "Accept: application/vnd.github+json" \
         -d "{\"name\": \"$LABEL_NAME\", \"color\": \"$LABEL_COLOR\", \"description\": \"$LABEL_DESC\"}" \
         "$API_URL/repos/$ORG_NAME/$REPO/labels"
  done

  echo "Labels synchronized for $REPO"
done

#!/bin/bash

set -e

ORG_NAME="pelagornis"
GH_TOKEN=${GH_TOKEN} 
API_URL="https://api.github.com"
LABELS_FILE="labels.json"

LABELS=$(cat labels.json)

echo "🔍 Fetching repositories for organization: $ORG_NAME..."
REPOS=$(curl -s -H "Authorization: token $GH_TOKEN" \
              -H "Accept: application/vnd.github+json" \
              "$API_URL/orgs/$ORG_NAME/repos?per_page=100" | jq -r '.[].name')

echo "📦 Found repositories: $REPOS"

for REPO in $REPOS; do
  echo "🚀 Processing repository: $REPO"

  # Fetch existing labels
  echo "🗑️ Deleting existing labels from $REPO..."
  EXISTING_LABELS=$(curl -s -H "Authorization: token $GH_TOKEN" \
                           -H "Accept: application/vnd.github+json" \
                           "$API_URL/repos/$ORG_NAME/$REPO/labels" | jq -r '.[].name')

  echo "$EXISTING_LABELS" | while read -r LABEL; do
    LABEL_ENCODED=$(echo -n "$LABEL" | jq -sRr @uri)
    RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" \
      -X DELETE "$API_URL/repos/$ORG_NAME/$REPO/labels/$LABEL_ENCODED" \
      -H "Authorization: token $GH_TOKEN" \
      -H "Accept: application/vnd.github+json")
    
    if [[ "$RESPONSE" == "204" ]]; then
      echo "✅ Deleted label '$LABEL' from $REPO"
    else
      echo "❌ Failed to delete label '$LABEL' from $REPO (HTTP $RESPONSE)"
    fi
  done

  # Add new labels
  echo "🆕 Adding new labels to $REPO..."
  echo "$LABELS" | jq -c '.[]' | while read -r label; do
    NAME=$(echo $label | jq -r '.name')
    COLOR=$(echo $label | jq -r '.color')
    DESCRIPTION=$(echo $label | jq -r '.description')

    RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" \
      -X POST "$API_URL/repos/$ORG_NAME/$REPO/labels" \
      -H "Authorization: token $GH_TOKEN" \
      -H "Accept: application/vnd.github+json" \
      -d "{\"name\": \"$NAME\", \"color\": \"$COLOR\", \"description\": \"$DESCRIPTION\"}")

    if [[ "$RESPONSE" == "201" ]]; then
      echo "✅ Label '$NAME' added to $REPO"
    else
      echo "❌ Failed to add label '$NAME' to $REPO (HTTP $RESPONSE)"
    fi
  done

done

echo "🎉 Labels replaced successfully in all repositories!"
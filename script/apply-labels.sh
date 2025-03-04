#!/bin/bash

set -e

ORG_NAME="pelagornis"
GH_TOKEN="${GH_TOKEN}"
API_URL="https://api.github.com"

echo "🔍 Fetching repositories for organization: $ORG_NAME..."
REPOS=$(curl -s -H "Authorization: token $GH_TOKEN" \
              -H "Accept: application/vnd.github+json" \
              "$API_URL/orgs/$ORG_NAME/repos?per_page=100" | jq -r '.[].name')

echo "📦 Found repositories: $REPOS"

LABELS=$(cat labels.json)

for REPO in $REPOS; do
  echo "🚀 Processing repository: $REPO"

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
    elif [[ "$RESPONSE" == "422" ]]; then
      echo "⚠️ Label '$NAME' already exists in $REPO"
    else
      echo "❌ Failed to add label '$NAME' to $REPO (HTTP $RESPONSE)"
    fi
  done
done

echo "🎉 Labels applied to all repositories!"

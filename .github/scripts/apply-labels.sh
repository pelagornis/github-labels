#!/bin/bash

set -e

ORG_NAME="pelagornis"
GH_TOKEN=${GH_TOKEN}
API_URL="https://api.github.com"
LABELS_FILE="labels.json"

REPO_NAME=$1

if [[ -z "$REPO_NAME" ]]; then
  echo "❌ No repository name provided!"
  exit 1
fi

echo "🚀 Processing new repository: $REPO_NAME"

# Fetch existing labels
echo "🗑️ Deleting existing labels from $REPO_NAME..."
EXISTING_LABELS=$(curl -s -H "Authorization: token $GH_TOKEN" \
                         -H "Accept: application/vnd.github+json" \
                         "$API_URL/repos/$ORG_NAME/$REPO_NAME/labels" | jq -r '.[].name')

echo "$EXISTING_LABELS" | while read -r LABEL; do
  LABEL_ENCODED=$(echo -n "$LABEL" | jq -sRr @uri)
  RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" \
    -X DELETE "$API_URL/repos/$ORG_NAME/$REPO_NAME/labels/$LABEL_ENCODED" \
    -H "Authorization: token $GH_TOKEN" \
    -H "Accept: application/vnd.github+json")

  if [[ "$RESPONSE" == "204" ]]; then
    echo "✅ Deleted label '$LABEL' from $REPO_NAME"
  else
    echo "❌ Failed to delete label '$LABEL' from $REPO_NAME (HTTP $RESPONSE)"
  fi
done

# Add new labels
echo "🆕 Adding new labels to $REPO_NAME..."
LABELS=$(cat labels.json)
echo "$LABELS" | jq -c '.[]' | while read -r label; do
  NAME=$(echo $label | jq -r '.name')
  COLOR=$(echo $label | jq -r '.color')
  DESCRIPTION=$(echo $label | jq -r '.description')

  RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" \
    -X POST "$API_URL/repos/$ORG_NAME/$REPO_NAME/labels" \
    -H "Authorization: token $GH_TOKEN" \
    -H "Accept: application/vnd.github+json" \
    -d "{\"name\": \"$NAME\", \"color\": \"$COLOR\", \"description\": \"$DESCRIPTION\"}")

  if [[ "$RESPONSE" == "201" ]]; then
    echo "✅ Label '$NAME' added to $REPO_NAME"
  else
    echo "❌ Failed to add label '$NAME' to $REPO_NAME (HTTP $RESPONSE)"
  fi
done

echo "🎉 Labels applied successfully to $REPO_NAME!"

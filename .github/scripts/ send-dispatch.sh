#!/bin/bash

set -e

GH_TOKEN=${GH_TOKEN}
ORG_NAME="pelagornis"
REPO_NAME=$1

if [[ -z "$REPO_NAME" ]]; then
  echo "❌ No repository name provided!"
  exit 1
fi

echo "🚀 Sending repository dispatch event for $REPO_NAME"

curl -X POST "https://api.github.com/repos/$ORG_NAME/github-labels/dispatches" \
     -H "Accept: application/vnd.github+json" \
     -H "Authorization: token $GH_TOKEN" \
     --data "{\"event_type\": \"new-repository\", \"client_payload\": {\"repository\": \"$REPO_NAME\"}}"

echo "✅ Webhook event sent for $REPO_NAME"

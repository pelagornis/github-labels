#!/bin/bash

ORG_NAME="pelagornis"
LABELS_FILE="labels.json"

REPOS=$(gh repo list $ORG_NAME --limit 1000 --json name --jq '.[].name')

for REPO in $REPOS; do
  echo "Processing: $REPO"
  
  EXISTING_LABELS=$(gh label list -R $ORG_NAME/$REPO --json name --jq '.[].name')
  for LABEL in $EXISTING_LABELS; do
    gh label delete "$LABEL" -R $ORG_NAME/$REPO --yes
  done

  jq -c '.[]' $LABELS_FILE | while read -r label; do
    NAME=$(echo $label | jq -r '.name')
    COLOR=$(echo $label | jq -r '.color')
    DESCRIPTION=$(echo $label | jq -r '.description')

    gh label create "$NAME" --color "$COLOR" --description "$DESCRIPTION" -R $ORG_NAME/$REPO || echo "Failed to create $NAME"
  done
done

echo "Labels applied successfully!"

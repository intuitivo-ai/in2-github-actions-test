#!/bin/bash
set -e

REPO="${GITHUB_REPOSITORY}"
#PR_NUMBER=$(jq -r .number "$GITHUB_EVENT_PATH")
echo $PR_NUMBER

echo "context"
echo $GITHUB_EVENT
echo "PR_NUMBER: $PR_NUMBER"
BASE_BRANCH=$(gh pr view "$PR_NUMBER" --repo "$REPO" --json baseRefName -q .baseRefName)
HEAD_BRANCH=$(gh pr view "$PR_NUMBER" --repo "$REPO" --json headRefName -q .headRefName)
echo "Actualizando branch '$HEAD_BRANCH' con los últimos cambios de '$BASE_BRANCH'..."

gh pr update-branch $PR_NUMBER --repo "$GITHUB_REPOSITORY"

echo "Branch '$HEAD_BRANCH' actualizado exitosamente con los últimos cambios de '$BASE_BRANCH'."

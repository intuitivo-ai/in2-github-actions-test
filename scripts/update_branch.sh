#!/bin/bash
set -e

#REPO="${GITHUB_REPOSITORY}"
#GITHUB_TOKEN="${GITHUB_TOKEN}"

#PR_NUMBER=$(jq -r .number "$GITHUB_EVENT_PATH")
#echo "PR_NUMBER: $PR_NUMBER"
#BASE_BRANCH=$(gh pr view "$PR_NUMBER" --repo "$REPO" --json baseRefName -q .baseRefName)
#HEAD_BRANCH=$(gh pr view "$PR_NUMBER" --repo "$REPO" --json headRefName -q .headRefName)
#echo "BASE_BRANCH: $BASE_BRANCH"
#echo "HEAD_BRANCH: $HEAD_BRANCH"
#
#echo "Actualizando branch '$HEAD_BRANCH' con los últimos cambios de '$BASE_BRANCH'..."

gh repo set-default "$GITHUB_REPOSITORY"
#git fetch origin "$BASE_BRANCH"
gh pr checkout $PR_NUMBER
#git checkout "$HEAD_BRANCH"
gh pr update-branch $PR_NUMBER

#git merge "origin/$BASE_BRANCH" --no-edit

#git push origin "$HEAD_BRANCH"

echo "Branch '$HEAD_BRANCH' actualizado exitosamente con los últimos cambios de '$BASE_BRANCH'."

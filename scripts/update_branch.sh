#!/bin/bash
set -e

REPO="${GITHUB_REPOSITORY}"
PR_NUMBER="${PR_NUMBER}"
GITHUB_TOKEN="${GITHUB_TOKEN}"
echo $REPO
echo $PR_NUMBER

BASE_BRANCH=$(gh pr view "$PR_NUMBER" --repo "$REPO" --json baseRefName -q .baseRefName)
HEAD_BRANCH=$(gh pr view "$PR_NUMBER" --repo "$REPO" --json headRefName -q .headRefName)
echo $BASE_BRANCH
echo $HEAD_BRANCH

echo "Actualizando branch '$HEAD_BRANCH' con los últimos cambios de '$BASE_BRANCH'..."

git fetch origin "$BASE_BRANCH"
git checkout "$HEAD_BRANCH"
git merge "origin/$BASE_BRANCH" --no-edit

git push origin "$HEAD_BRANCH"

echo "Branch '$HEAD_BRANCH' actualizado exitosamente con los últimos cambios de '$BASE_BRANCH'."

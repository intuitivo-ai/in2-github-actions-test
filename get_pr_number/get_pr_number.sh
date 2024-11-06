#!/usr/bin/env bash
set -e

echo "Getting PR number..."
branch_name=${GITHUB_REF#refs/heads/}
echo "Branch name: $branch_name"
pr_number=$(curl -s -H "Authorization: token $GITHUB_TOKEN " \
  -H "Accept: application/vnd.github.v3+json" \
  "https://api.github.com/repos/$GITHUB_REPOSITORY/pulls?head=$GITHUB_REPOSITORY_OWNER:$GITHUB_HEAD_REF" | jq '.[0].number // 0')
echo {"pr_number":$pr_number}
echo pr_number=$pr_number >> $GITHUB_OUTPUT
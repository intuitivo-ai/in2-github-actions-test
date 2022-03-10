#!/bin/sh -l
set -euxo pipefail

ORG="$GITHUB_REPOSITORY_OWNER"
REPOSITORY=$(echo "${GITHUB_REPOSITORY}" | sed "s|${ORG}/||g")
echo "::set-output name=COMMIT_ID::${GITHUB_SHA}"
echo "::set-output name=REPOSITORY::${REPOSITORY}"

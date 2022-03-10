#!/bin/sh -l
set -euxo pipefail

COMMIT_ID="${GITHUB_SHA}"
ORG="${GITHUB_REPOSITORY_OWNER}"

REPOSITORY=$(echo "${GITHUB_REPOSITORY}" | sed "s|${ORG}/||g")

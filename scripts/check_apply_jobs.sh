#!/usr/bin/env bash
set -e

curl -s -o results.json \
    -L \
    -H "Authorization: Bearer $GITHUB_TOKEN" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    https://api.github.com/repos/${GITHUB_REPOSITORY}/actions/runs/${GITHUB_RUN_ID}/jobs

conclusions=$(jq '.jobs[] | select(.name | contains("Production") and endswith("Apply")) | .conclusion' results.json)
apply_result=$(jq '.jobs[] | select(.name | contains("Production") and endswith("Apply")) | "\(.name): \(.conclusion)"' results.json)

if [[ "${conclusions[@]}" =~ '"success"' ]]; then
    conclusion="true"
else
    echo -e "Jobs are missing from the previous terraform apply step. Re-try workflow to complete all deployments before creating release note.\n$apply_result"
    exit 1
fi

echo "apply=$conclusion" >> "$GITHUB_OUTPUT"
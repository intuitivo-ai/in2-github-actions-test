#!/usr/bin/env bash
set -e

curl -o release_notes.json \
-L \
-X POST \
-H "Authorization: Bearer $GITHUB_TOKEN" \
-H "X-GitHub-Api-Version: 2022-11-28" \
https://api.github.com/repos/${GITHUB_REPOSITORY}/releases/generate-notes \
-d '{"tag_name":"release/'"$GITHUB_RUN_NUMBER"'"}'

jq -r '.body' release_notes.json > body_content.md

echo "release_notes=$(pwd)/body_content.md" >> "$GITHUB_OUTPUT"
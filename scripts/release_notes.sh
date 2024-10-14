#!/usr/bin/env bash
set -e

latest_release_tag=$(gh release view --json tagName --jq '.tagName')
if [ -z "$latest_release_tag" ]; then
  echo "No se pudo obtener el último release."
  exit 1
fi
echo "Último release: $latest_release_tag"

gh release create \
  release/$GITHUB_RUN_NUMBER \
  -t v$GITHUB_RUN_NUMBER.$GITHUB_RUN_ATTEMPT \
  --generate-notes \
  --notes-start-tag $latest_release_tag #--prerelease
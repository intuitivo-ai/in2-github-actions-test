#!/usr/bin/env bash

echo "$0 $*"
new="$1/1/$2"
echo "${new}"
git tag "${new}"
git tag
git_refs_url=$(jq .repository.git_refs_url "$GITHUB_EVENT_PATH" | tr -d '"' | sed 's/{\/sha}//g')
echo "${git_refs_url}"
git_refs_response=$(
  curl -s -X POST "${git_refs_url}" \
    -H "Authorization: Bearer $GITHUB_TOKEN" \
    -d @- <<EOF
{
  "ref": "refs/tags/$new",
  "sha": "$GITHUB_SHA"
}
EOF
)
echo "${git_refs_response}"
git_ref_posted=$(echo "${git_refs_response}" | jq .ref | tr -d '"')
echo "${git_ref_posted}"

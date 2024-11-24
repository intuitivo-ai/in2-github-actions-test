#!/bin/env bash
set -e
DIR=$(dirname $0)
source $DIR/functions.sh

ORG="$GITHUB_REPOSITORY_OWNER"
REPOSITORY=$(echo "$GITHUB_REPOSITORY" | sed "s|$ORG/||g")

CONFIG_JSON=$(aws ssm get-parameter --name "$PARAMETER_NAME" --query "Parameter.Value" --output text)

read_global_config() {
  echo "$CONFIG_JSON" | jq -r '.global_config'
}

read_repo_config() {
  local repo_name=$1
  local repo_config

  # We check if the 'repos' key exists in the json and if the repo is in the array or if it is an empty array
  repo_config=$(echo "$CONFIG_JSON" | jq -r --arg repo_name "$repo_name" '
    if .repos | length > 0 then 
      (.repos[] | select(.repo_name == $repo_name)) 
    else 
      {} 
    end
  ')

  # If repo_config is empty or null, then return an empty json structure, otherwise the repo configuration
  [[ -z "$repo_config" ]] || [[ "$repo_config" == "null" ]] && echo "{}" || echo "$repo_config"
}

merge_configs() {
  local repo_name=$1
  local global_config
  local repo_config
  
  global_config=$(read_global_config)
  repo_config=$(read_repo_config "$repo_name")

  # repo_config overrides global_config
  jq -n \
    --argjson global "$global_config" \
    --argjson repo "$repo_config" \
    '$global * $repo'
}

merged_config=$(merge_configs "$REPOSITORY")

skip_all_vulns=$(jq -r '.skip_all_vulns' <<< "$merged_config")
skip_critical_vulns=$(jq -r '.skip_critical_vulns' <<< "$merged_config")
skip_high_vulns=$(jq -r '.skip_high_vulns' <<< "$merged_config")
skip_medium_vulns=$(jq -r '.skip_medium_vulns' <<< "$merged_config")
vulns_to_skip=$(jq -r '.vulns_to_skip | join(" ")' <<< "$merged_config")

DEBUG="true"
for variable in skip_all_vulns \
                skip_critical_vulns \
                skip_high_vulns \
                skip_medium_vulns \
                vulns_to_skip; do
  update_github_output "$variable" "${!variable}"
done

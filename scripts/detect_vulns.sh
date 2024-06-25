#!/bin/env bash
set -e
DIR=$(dirname $0)
source $DIR/functions.sh

# Read the vulnerability lists from environment variables and convert them into arrays
read -r -a critical_vulnerabilities <<< "${LIST_VULNS_CRITICAL}"
read -r -a high_vulnerabilities <<< "${LIST_VULNS_HIGH}"
read -r -a medium_vulnerabilities <<< "${LIST_VULNS_MEDIUM}"
read -r -a vulns_to_skip <<< "${VULNS_TO_SKIP}"

flag_critical=true
flag_high=true
flag_medium=true

# Helper function to remove an element from an array
remove_element() {
  local target="$1"
  local -a arr=("${!2}")
  for i in "${!arr[@]}"; do
    if [[ ${arr[i]} == "$target" ]]; then
      unset 'arr[i]'
      break
    fi
  done
  eval "$2=(\"\${arr[@]}\")"
}

# Iterates the found vulnerabilities to check if something should be skipped.
# If it finds a match, then it removes the CVE from the <severity>_vulnerabilities array
# so then we can check if there are still vulnerabilities or not.

for vuln in "${!critical_vulnerabilities[@]}"; do
  if [[ " ${vulns_to_skip[*]} " =~ " ${critical_vulnerabilities[vuln]} " ]]; then
    remove_element "${critical_vulnerabilities[vuln]}" critical_vulnerabilities
  fi
done


for vuln in "${!high_vulnerabilities[@]}"; do
  if [[ " ${vulns_to_skip[*]} " =~ " ${high_vulnerabilities[vuln]} " ]]; then
    remove_element "${high_vulnerabilities[vuln]}" high_vulnerabilities
  fi
done


for vuln in "${!medium_vulnerabilities[@]}"; do
  if [[ " ${vulns_to_skip[*]} " =~ " ${medium_vulnerabilities[vuln]} " ]]; then
    remove_element "${medium_vulnerabilities[vuln]}" medium_vulnerabilities
  fi
done

# Based on the configuration and if there are still vulnerabilities, we change the flag value
if [[ $SKIP_ALL_VULNS == "true" || $SKIP_CRITICAL_VULNS == "true" || ${#critical_vulnerabilities[@]} -eq 0 ]]; then
    flag_critical=false
fi

if [[ $SKIP_ALL_VULNS == "true" || $SKIP_HIGH_VULNS == "true" || ${#high_vulnerabilities[@]} -eq 0 ]]; then
    flag_high=false
fi

if [[ $SKIP_ALL_VULNS == "true" || $SKIP_MEDIUM_VULNS == "true" || ${#medium_vulnerabilities[@]} -eq 0 ]]; then
    flag_medium=false
fi


update_github_output "detected_critical_vulns" "$flag_critical"
update_github_output "detected_high_vulns"     "$flag_high"
update_github_output "detected_medium_vulns"   "$flag_medium"

# Output for testing
echo "Flag for critical vulnerabilities: $flag_critical"
echo "Critical vulnerabilities remaining: ${critical_vulnerabilities[*]}"
echo "Flag for high vulnerabilities: $flag_high"
echo "High vulnerabilities remaining: ${high_vulnerabilities[*]}"
echo "Flag for medium vulnerabilities: $flag_medium"
echo "Medium vulnerabilities remaining: ${medium_vulnerabilities[*]}"

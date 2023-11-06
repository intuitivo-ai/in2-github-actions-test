#!/bin/env bash
set -e

ORG="$GITHUB_REPOSITORY_OWNER"
REPOSITORY=$(echo "$GITHUB_REPOSITORY" | sed "s|$ORG/||g")
EXIT_CODE=1
RETRIES=0
IMAGE_INFO="--repository-name $REPOSITORY --image-id imageTag=$GITHUB_SHA"

until [ $EXIT_CODE -eq 0 ] || [ $RETRIES -eq 2 ]
do
    aws ecr wait image-scan-complete $IMAGE_INFO
    EXIT_CODE=$?
    if [ $EXIT_CODE -ne 0 ]; then
        ((RETRIES++))
    fi
done

FULL_SCAN_FINDINGS=$(aws ecr describe-image-scan-findings $IMAGE_INFO)
SCAN_FINDINGS=$(echo "$FULL_SCAN_FINDINGS" | jq '.imageScanFindings.findingSeverityCounts')

echo "Vulnerabilities Report"

for severity in CRITICAL HIGH MEDIUM; do
    count=$(echo "$SCAN_FINDINGS" | jq ".$severity // 0")
    echo "$severity: $count"
    echo "vulnerability_$severity=$count" >> "$GITHUB_OUTPUT"

    readarray -t cve_array < <(echo "$FULL_SCAN_FINDINGS" | jq -r --arg SEVERITY "$severity" '.imageScanFindings.findings[] | select(.severity==$SEVERITY) | .name')
    echo "List of $severity vulnerabilities:"
    for cve in "${cve_array[@]}"; do
        echo "$cve"
    done
    echo

    cve_list=$(IFS=$' '; echo "${cve_array[*]}")
    echo "list_vulns_$severity=$cve_list" >> "$GITHUB_OUTPUT"
done

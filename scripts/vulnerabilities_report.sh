#!/bin/env bash
# -*- coding: utf-8 -*-
export LANG=en_US.UTF-8
set -e
DIR=$(dirname $0)
source $DIR/functions.sh

ORG="$GITHUB_REPOSITORY_OWNER"
REPOSITORY=$(echo "$GITHUB_REPOSITORY" | sed "s|$ORG/||g")
EXIT_CODE=1
RETRIES=0
IMAGE_INFO="--repository-name $REPOSITORY --image-id imageTag=$GITHUB_SHA"

if [ "$GITHUB_EVENT_NAME" == "pull_request" ]; then
    BASE_REF=$(jq -r '.pull_request.head.sha' $GITHUB_EVENT_PATH)
    IMAGE_INFO="--repository-name $REPOSITORY --image-id imageTag=$BASE_REF"
fi

# if scanning = basic
SCAN_STATUS=$(aws ecr describe-images --query 'imageDetails[0].imageScanStatus.status' $IMAGE_INFO --output text)

if [ "$SCAN_STATUS" = "COMPLETE" ]; then
    FULL_SCAN_FINDINGS=$(aws ecr describe-image-scan-findings $IMAGE_INFO)
elif [ "$SCAN_STATUS" = "IN_PROGRESS" ]; then
    until [ $EXIT_CODE -eq 0 ] || [ $RETRIES -eq 2 ]
    do
        aws ecr wait image-scan-complete $IMAGE_INFO
        EXIT_CODE=$?
        if [ $EXIT_CODE -ne 0 ]; then
            ((RETRIES++))
        fi
    done

    FULL_SCAN_FINDINGS=$(aws ecr describe-image-scan-findings $IMAGE_INFO)
else
    echo "Unexpected scan status: $SCAN_STATUS" # if the result is null, then the scan type is probably other than basic
    exit 1
fi

SCAN_FINDINGS=$(echo "$FULL_SCAN_FINDINGS" | jq '.imageScanFindings.findingSeverityCounts')

report="# Vulnerabilities Report\n"
for severity in CRITICAL HIGH MEDIUM; do
    count=$(echo "$SCAN_FINDINGS" | jq ".$severity // 0")
    report="$report \n## $severity: $count\n"
    update_github_output "vulnerability_$severity" "$count"
    export "count_$severity"=$count

    readarray -t cve_array < <(echo "$FULL_SCAN_FINDINGS" | jq -r --arg SEVERITY "$severity" '.imageScanFindings.findings[] | select(.severity==$SEVERITY) | .name')

    if [ $severity == "MEDIUM" ]; then
        report="$report \n <details> \n\n"
        for cve in "${cve_array[@]}"; do report="$report $cve\n"; done
        report="$report \n </details> \n"
    else
        for cve in "${cve_array[@]}"; do report="$report $cve\n"; done
    fi

    cve_list=$(IFS=$' '; echo "${cve_array[*]}")
    update_github_output "list_vulns_$severity" "$cve_list"
done
echo -e "$report"

if [ "$count_CRITICAL" -eq 0 ] && [ "$count_HIGH" -eq 0 ] && [ "$count_MEDIUM" -eq 0 ]; then
    update_github_output "ecr_report" "# Your Code is Free from Ecr-Vulnerabilities \n![LINK HERE](https://media.tenor.com/IZbebTRMJY8AAAAd/donny-azoff.gif)"
else
    update_github_output "ecr_report" "$report"
fi
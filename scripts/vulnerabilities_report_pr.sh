#!/bin/env bash
set -e

ORG="$GITHUB_REPOSITORY_OWNER"
REPOSITORY=$(echo "$GITHUB_REPOSITORY" | sed "s|$ORG/||g")
EXIT_CODE=1
RETRIES=0

if [ "$GITHUB_EVENT_NAME" == "pull_request" ]; then
    BASE_REF=$(jq -r .after $GITHUB_EVENT_PATH)
fi

if [ "$GITHUB_EVENT_NAME" == "push" ]; then
    IMAGE_INFO="--repository-name $REPOSITORY --image-id imageTag=$GITHUB_SHA"
else
    IMAGE_INFO="--repository-name $REPOSITORY --image-id imageTag=$BASE_REF"
fi


until [ $EXIT_CODE -eq 0 ] || [ $RETRIES -eq 2 ]
do
    aws ecr wait image-scan-complete $IMAGE_INFO
    EXIT_CODE=$?
    if [ $EXIT_CODE -ne 0 ]; then
        ((RETRIES++))
    fi
done

SCAN_FINDINGS=$(aws ecr describe-image-scan-findings $IMAGE_INFO | jq '.imageScanFindings.findingSeverityCounts')

report=""
for severity in CRITICAL HIGH MEDIUM; do
    count=$(echo "$SCAN_FINDINGS" | jq ".$severity // 0")
    report="$report \n$severity: $count"
done

echo -e "Vulnerabilities Report: \n$report"
echo "ecr_report=Vulnerabilities Report: \n$report" >> "$GITHUB_OUTPUT"
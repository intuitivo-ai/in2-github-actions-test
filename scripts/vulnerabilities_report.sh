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

if [ $EXIT_CODE -eq 0 ]; then
    SCAN_FINDINGS=$(aws ecr describe-image-scan-findings $IMAGE_INFO | jq '.imageScanFindings.findingSeverityCounts')

    echo "Vulnerabilities Report"

    for severity in CRITICAL HIGH MEDIUM; do
        count=$(echo "$SCAN_FINDINGS" | jq ".$severity // 0")
        echo "$severity: $count"
    done

else
    echo "No se pudo completar el análisis de vulnerabilidades en el tiempo esperado"
fi

#!/usr/bin/env bash
set -e
DIR=$(dirname $0)
source $DIR/functions.sh

case $ENVIRONMENT in
development)
    echo "Account ID for the development environment: 714024795585"
    account_id=714024795585
    ;;
devops-sandbox)
    echo "Account ID for the devops-sandbox environment: 038036402334"
    account_id=038036402334
    ;;
production)
    echo "Account ID for the production environment: 696239074566"
    account_id=696239074566
    ;;
showroom)
    echo "Account ID for the showroom environment: 753623204763"
    account_id=753623204763
    ;;
staging)
    echo "Account ID for the staging environment: 596234539184"
    account_id=596234539184
    ;;
*)
    echo "Error: The environment '$ENVIRONMENT' is not recognized."
    exit 1
    ;;
esac

update_github_output "ACCOUNT_ID" "$account_id"
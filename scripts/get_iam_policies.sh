#!/usr/bin/env bash
set -e
DIR=$(dirname $0)
source $DIR/functions.sh >/dev/null

get_tf_modules() {
    local repos
    local tf_path="$1"
    local environment="$2"
    local account_id="$3"
    local arn_list
    default_arns=(
        "arn:aws:iam::$account_id:policy/modules/$environment-github-allow-access-to-alarms-RW"
        "arn:aws:iam::$account_id:policy/modules/$environment-github-allow-access-to-iot-RW"
        "arn:aws:iam::$account_id:policy/modules/$environment-github-allow-access-to-terraform-default-RW"
    )
    excluded_modules=(
        "cw-dashboard"
        "efs"
        "iam-policy"
        "iam-role"
        "sns"
    )

    while IFS= read -r repo; do
        module_name=$(echo "$repo" | sed 's/\.git$//' | sed 's/\?ref=.*$//')
        if [[ ! " ${excluded_modules[*]} " =~ ${module_name} ]]; then
            repos+=("$module_name")
        fi
    done < <(find . -name "*.tf" | while read -r file; do
        grep -Eo 'git@github.com:intuitivo-ai/in2-terraform-module-[^"]+' "$file" | sed 's/git@github.com:intuitivo-ai\/in2-terraform-module-//' || true # el true es para que no rompa por el set -e
    done | sort -u)

    declare -A additional_modules
    additional_modules["alb"]="aws-cloudfront"
    additional_modules["db-aurora"]="lambda-function"
    additional_modules["s3"]="aws-cloudfront"

    for base_module in "${!additional_modules[@]}"; do
        if [[ " ${repos[*]} " == *" $base_module "* ]]; then
            for additional_module in ${additional_modules[$base_module]}; do
                repos+=("$additional_module")
            done
        fi
    done

    mapfile -t repos < <(printf "%s\n" "${repos[@]}" | sort -u)

    for arn in "${default_arns[@]}"; do
        arn_list+="$arn, "
    done
    if [[ ${#repos[@]} -gt 0 ]]; then
        for module_name in "${repos[@]}"; do
            if [[ -n "$module_name" ]]; then
                arn="arn:aws:iam::$account_id:policy/modules/$environment-github-allow-access-to-$module_name-RW"
                arn_list+="$arn, "
            fi
        done
    fi

    arn_list=${arn_list%, }
    echo "Identified policies to attach:"
    echo "$arn_list"
    update_github_output "aws_policies" "$arn_list"
}

tf_path="$1"
environment="$2"
account_id="$3"
get_tf_modules "$tf_path" "$environment" "$account_id"

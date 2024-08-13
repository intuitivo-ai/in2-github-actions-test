#!/usr/bin/env bash
set -e

infracost diff --path "$1/$1" --project-name "$VAR_FILE"
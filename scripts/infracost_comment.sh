#!/usr/bin/env bash
set -e

infracost generate config --template-path=infracost.yml.tmpl --out-file=infracost.yml
cat infracost.yml
infracost breakdown --config-file=infracost.yml --format=table
infracost breakdown --config-file=infracost.yml --format=json --out-file=report.json
#!/usr/bin/env bash
set +e
terraform refresh -var-file=$VAR_FILE.tfvars -input=false -target data.aws_caller_identity.aws >release.lock 2>&1
set -e

echo "---- ----"
cat release.lock
echo "---- ----"

terraform force-unlock -force $(cat release.lock | grep ID | grep -v StatusCode | cut -d':' -f2)

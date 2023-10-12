#!/usr/bin/env bash
set +e
terraform refresh -input=false >release.lock 2>&1
set -e

echo "---- ----"
cat release.lock
echo "---- ----"

terraform force-unlock -force $(cat release.lock | grep ID | grep -v StatusCode | cut -d':' -f2)

#!/usr/bin/env bash
set +e
terraform refresh -input=false > release.lock
set -e

echo "---- ----"
cat release.lock
echo "---- ----"

terraform force-unlock -force $(cat release.lock | grep ID | cut -d':' -f2)

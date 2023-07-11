#!/usr/bin/env bash
set -e

ls | grep -v / > list.txt

FILE_DEPENDENCIES=""
IGNORE="-x '*terraform*' -x '*.terraform*' -x '*.git*'"

for script in $(ls *py) $(echo */ | sed 's|/||g'); do
  NAME=$(echo $script | sed 's/.py//g')
  zip -rv $NAME.zip $script $FILE_DEPENDENCIES $IGNORE
done
ls -l *.zip
ls *zip | grep -v / >> list.txt
echo -e ".github\n.git\n.gitignore\n.dockerignore" >> list.txt
cat list.txt

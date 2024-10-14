#!/usr/bin/env bash
set -e
DIR=$(dirname $0)
source $DIR/functions.sh

cd $DIR
echo "Install requirements"
sudo yum-config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo
sudo yum install gh -y

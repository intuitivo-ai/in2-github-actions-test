#!/usr/bin/env bash
set -e

x=$1
case $x in
"run")
  echo "Run migrations"
  ;;
"rollback")
  echo "Run migrations rollback"
  ;;
*)
  exit 1
  ;;
esac

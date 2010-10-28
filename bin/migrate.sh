#!/bin/sh

TARGET=$1

if [ "." == $TARGET. ] ; then
  echo "Usage: migrate.sh <target>"
  exit 1
fi

pg_dump steamcannon_production -U steamcannon | psql -h $TARGET steamcannon_production -U steamcannon

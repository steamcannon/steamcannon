#!/bin/sh

TARGET=$1

if [ "." == $TARGET. ] ; then
  echo "Usage: migrate.sh <target>"
  exit 1
fi

su postgres -c 'pg_dump steamcannon_production'  | psql -h $TARGET steamcannon_production -U steamcannon

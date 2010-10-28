#!/bin/sh

TARGET=$1

if [ "." == $TARGET. ] ; then
  echo "Usage: migrate.sh <target>"
  exit 1
fi

su postgres -c 'pg_dump -c steamcannon_production'  | psql -h $TARGET steamcannon_production -U steamcannon

if [ $? -eq 0 ] ; then
    echo "Data has been moved to $TARGET"
    echo "Now you need to ssh to $TARGET and execute the following commands."
    echo -e "\t# cd /opt/steamcannon"
    echo -e "\t# RAILS_ENV=production /opt/jruby/bin/jruby -S rake db:migrate"
    echo -e "\t# RAILS_ENV=production /opt/jruby/bin/jruby -S rake db:seed"
else
    echo "Unable to migrate. Sorry!"
fi

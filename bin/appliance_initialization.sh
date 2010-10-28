#!/bin/sh

SU_CMD=`which su`

STEAMCANNON_CONFIG="/opt/steamcannon/config/steamcannon.yml"
if [ ! -e $STEAMCANNON_CONFIG ] ; then
  echo "Creating steamcannon configuration file"
  cp $STEAMCANNON_CONFIG.example $STEAMCANNON_CONFIG
  /bin/sed -i s/'^#deltacloud_url'/'deltacloud_url'/g $STEAMCANNON_CONFIG
  /bin/sed -i s/'^#certificate_password'/'certificate_password'/g $STEAMCANNON_CONFIG
fi

STEAMCANNON_DEPLOYMENT="/opt/jboss-as/server/all/deploy/steamcannon-rails.yml"
if [ ! -e $STEAMCANNON_DEPLOYMENT ] ; then
  echo "Creating steamcannon deployment file."
  echo -e '---\napplication:\n  RAILS_ROOT: /opt/steamcannon\n  RAILS_ENV: production\nweb:\n  context: /\n' > $STEAMCANNON_DEPLOYMENT
fi

STEAMCANNON_USER=`echo '\du' | $SU_CMD postgres -c psql | grep steamcannon | cut -d' ' -f2`
if [ $STEAMCANNON_USER. != 'steamcannon.' ] ; then
  echo "Creating steamcannon database user"
  $SU_CMD postgres -c "/usr/bin/createuser -SDR steamcannon"
  echo "ALTER USER steamcannon WITH PASSWORD 'steamcannon';" | $SU_CMD postgres -c /usr/bin/psql
fi

STEAMCANNON_DB=`echo '\l' | $SU_CMD postgres -c psql | grep steamcannon_production | cut -d' ' -f2`
if [ $STEAMCANNON_DB. != 'steamcannon_production.' ] ; then
  echo "Creating steamcannon database"
  $SU_CMD postgres -c "/usr/bin/createdb steamcannon_production -O steamcannon"
  echo "GRANT ALL ON DATABASE steamcannon_production TO steamcannon" | $SU_CMD postgres -c /usr/bin/psql
fi

STEAMCANNON_SCHEMA=`echo '\dt' | $SU_CMD postgres -c 'psql steamcannon_production' | grep schema_migrations | cut -d' ' -f4`
if [ $STEAMCANNON_SCHEMA. != 'schema_migrations.' ] ; then
  echo "Initializing and seeding database schema"
  cd /opt/steamcannon
  export RAILS_ENV=production
  $SU_CMD jboss-as6 -c '/opt/jruby/bin/jruby -S rake db:setup'
fi

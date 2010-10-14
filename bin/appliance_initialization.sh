#!/bin/sh

echo "Creating deployment and configuration files"
cp /opt/steamcannon/config/steamcannon.yml.example /opt/steamcannon/config/steamcannon.yml
/bin/sed -i s/'^#deltacloud_url'/'deltacloud_url'/g /opt/steamcannon/config/steamcannon.yml
/bin/sed -i s/'^#certificate_password'/'certificate_password'/g /opt/steamcannon/config/steamcannon.yml
echo -e '---\napplication:\n  RAILS_ROOT: /opt/steamcannon\n  RAILS_ENV: production\nweb:\n  context: /\n' > /opt/jboss-as/server/default/deploy/steamcannon-rails.yml

echo "Creating steamcannon user and production database"
/bin/su postgres -c "/usr/bin/createuser -SDR steamcannon" 
/bin/su postgres -c "/usr/bin/createdb steamcannon_production -O steamcannon"
echo "ALTER USER steamcannon WITH PASSWORD 'steamcannon';" | /bin/su postgres -c /usr/bin/psql
echo "GRANT ALL ON DATABASE steamcannon_production TO steamcannon" | /bin/su postgres -c /usr/bin/psql

echo "Initializing and seeding database schema"
cd /opt/steamcannon
export RAILS_ENV=production
/opt/jruby/bin/jruby -S rake db:setup


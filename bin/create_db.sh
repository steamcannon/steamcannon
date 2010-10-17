#!/bin/sh

echo "Creating steamcannon databases"
echo "CREATE DATABASE steamcannon_dev" | psql 
echo "CREATE DATABASE steamcannon_test" | psql 
echo "CREATE DATABASE steamcannon_production" | psql 

echo "Creating steamcannon user"
echo "CREATE USER steamcannon WITH PASSWORD 'steamcannon'" | psql

echo "Granting steamcannon user all privs on databases"
echo "GRANT ALL ON DATABASE steamcannon_dev TO steamcannon" | psql
echo "GRANT ALL ON DATABASE steamcannon_test TO steamcannon" | psql
echo "GRANT ALL ON DATABASE steamcannon_production TO steamcannon" | psql

echo "Now you need to run 'rake db:setup'"
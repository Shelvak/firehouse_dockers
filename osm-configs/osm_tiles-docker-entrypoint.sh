#!/bin/bash

# replace the password if OSM_DB_PASS is set
#if [ -z ${OSM_DB_PASS} ]; then
#  echo 'WARNING: OSM_DB_PASS is not set'
#else
#  echo 'Replacing the password with OSM_DB_PASS value'
#  sed -i "s/name=\"dbname\"><\!\[CDATA\[\(\[\|\)\(\w\+-\?\w\+\)\]/name=\"dbname\"><\!\[CDATA\[\1${OSM_DB_NAME}\]/g" /opt/osm-bright-master/OSMBright/OSMBright.xml
#  sed -i "s/name=\"host\"><\!\[CDATA\[\(\[\|\)\(\w\+-\?\w\+\)\]/name=\"host\"><\!\[CDATA\[\1${OSM_DB_HOST}\]/g" /opt/osm-bright-master/OSMBright/OSMBright.xml
#  sed -i "s/name=\"user\"><\!\[CDATA\[\(\[\|\)\(\w\+-\?\w\+\)\]/name=\"user\"><\!\[CDATA\[\1${OSM_DB_USER}\]/g" /opt/osm-bright-master/OSMBright/OSMBright.xml
#  sed -i "s/name=\"password\"><\!\[CDATA\[\(\[\|\)\(\w\+-\?\w\+\)\]/name=\"password\"><\!\[CDATA\[\1${OSM_DB_PASS}\]/g" /opt/osm-bright-master/OSMBright/OSMBright.xml
#fi

# run the provided command
echo "Running $@"
exec "$@"

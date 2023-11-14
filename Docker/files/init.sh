#!/bin/bash


PG_CONFIG="/etc/postgresql-common/pg_service.conf"
QGIS_USER=1000
MAPPROXY_USER=1000

init() {
  cp /files/pg_service.conf "${PG_CONFIG}"  
}

initPostgresConf() {
  if [ -f "${PG_CONFIG}" ]; then
    echo "Changing db name, user, password in ${PG_CONFIG}.."
    sed -i 's/dbname=.*/dbname='"${POSTGRES_DB}"'/' "${PG_CONFIG}"
    sed -i 's/user=.*/user='"${POSTGRES_USER}"'/' "${PG_CONFIG}"
    sed -i 's/password=.*/password='"${POSTGRES_PASSWORD}"'/' "${PG_CONFIG}"
  else
    echo "Did not find postgres service config ${PG_CONFIG}."
  fi
}

initQGIS() {
   cp /files/*.qgs /qgis-data
   chown -R ${QGIS_USER} /qgis-data
}

initMapproxy() {
  chown -R ${MAPPROXY_USER} /mapproxy-data
}

init
initPostgresConf
initQGIS
initMapproxy

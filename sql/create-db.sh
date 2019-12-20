#!/bin/sh

. $(readlink -f $(dirname $0))/db_settings.sh

createdb -U $DB_USER -p $DB_PORT -h $DB_HOST $DB_NAME

psql -U $DB_USER -h $DB_HOST -p $DB_PORT -d $DB_NAME  << _EOF_
CREATE EXTENSION postgis;
CREATE ROLE hazardusers NOLOGIN NOINHERIT;
CREATE ROLE hazardviewer NOLOGIN INHERIT;
CREATE ROLE hazardcontrib NOLOGIN INHERIT;
GRANT hazardusers TO hazardviewer;
GRANT hazardviewer TO hazardcontrib;
_EOF_

echo "$0: Don't forget to set passwords for hazardviewer and hazardcontrib" >&2

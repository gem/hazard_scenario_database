#!/bin/bash

sudo psql -U postgres << _EOF_
CREATE DATABASE hazard;
\connect hazard
CREATE EXTENSION postgis;
CREATE ROLE hazardviewer NOLOGIN NOINHERIT;
CREATE ROLE hazardcontrib NOLOGIN INHERIT;
GRANT hazardviewer TO hazardcontrib;
_EOF_

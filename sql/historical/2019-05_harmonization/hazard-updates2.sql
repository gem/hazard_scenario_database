--
-- Hazard Database Schema Updates
-- Intended to store event sets for both deterministic and probabilistic 
-- analyses
--

--
-- NOTE please execute commands in common.sql and hazard-updates.sql before 
-- executing this file
--

-- Usual settings copied from pg_dump output
SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;
SET default_with_oids = false;

SET search_path = hazard, pg_catalog, public;


ALTER TYPE cf_common.hazard_enum
    ADD VALUE IF NOT EXISTS 'Wildfire'
    BEFORE 'Multi-hazard';

ALTER TYPE cf_common.hazard_enum
    ADD VALUE IF NOT EXISTS 'Extreme Temperature'
    BEFORE 'Multi-hazard';


START TRANSACTION;

--
-- No direct way to renam enums via ALTER (until PG v10)
--
UPDATE pg_catalog.pg_enum
    SET enumlabel = 'Strong Wind'
    WHERE enumtypid = 'cf_common.hazard_enum'::regtype::oid
    AND enumlabel = 'Wind'
    RETURNING enumlabel;

UPDATE pg_catalog.pg_enum
    SET enumlabel = 'Coastal Flood'
    WHERE enumtypid = 'cf_common.hazard_enum'::regtype::oid
    AND enumlabel = 'Storm Surge'
    RETURNING enumlabel;

UPDATE pg_catalog.pg_enum
    SET enumlabel = 'Volcanic'
    WHERE enumtypid = 'cf_common.hazard_enum'::regtype::oid
    AND enumlabel = 'Volcanic Ash'
    RETURNING enumlabel;

COMMIT

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

START TRANSACTION;

ALTER TABLE hazard.event_set ALTER COLUMN hazard_type TYPE VARCHAR;
UPDATE hazard.event_set SET hazard_type='TS' WHERE hazard_type='Tsunami';
UPDATE hazard.event_set SET hazard_type='VO' WHERE hazard_type='Volcanic';
UPDATE hazard.event_set SET hazard_type='EQ' WHERE hazard_type='Earthquake';

ALTER TABLE hazard.event ALTER COLUMN trigger_hazard_type TYPE VARCHAR;
UPDATE hazard.event SET trigger_hazard_type='EQ' 
	WHERE trigger_hazard_type='Earthquake';

--
-- Remove hazard_enum type, replace with table
--
DROP TYPE IF EXISTS cf_common.hazard_enum;

--
-- List of valid hazard types with Think Hazard! codes
-- See http://thinkhazard.org
--
CREATE TABLE IF NOT EXISTS cf_common.hazard_type (
    code    VARCHAR         PRIMARY KEY,
    name    VARCHAR         NOT NULL
);
COMMENT ON TABLE cf_common.hazard_type IS
    'Valid Hazard types';

DELETE FROM cf_common.hazard_type;
COPY cf_common.hazard_type (code,name)
    FROM STDIN
    WITH (FORMAT csv);
EQ,Earthquake
TS,Tsunami
VO,Volcanic
CF,Coastal Flood
FL,Flood
LS,Landslide
WI,Strong Wind
ET,Extreme Temperature
DR,Drought
WF,Wildfire
MH,Multi-Hazard
\.

--
-- Add constraints - hazard types must be in cf_common.hazard_type
--
ALTER TABLE hazard.event ADD CONSTRAINT valid_hazard_trigger_type
	FOREIGN KEY (trigger_hazard_type) REFERENCES cf_common.hazard_type(code);

ALTER TABLE hazard.event_set ADD CONSTRAINT valid_hazard_type
	FOREIGN KEY (hazard_type) REFERENCES cf_common.hazard_type(code);

COMMIT

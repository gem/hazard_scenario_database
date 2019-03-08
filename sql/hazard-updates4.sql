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

--
-- Process Type by hazard type
--
CREATE TABLE IF NOT EXISTS cf_common.process_type (                              
    code    		VARCHAR	PRIMARY KEY,
    hazard_code		VARCHAR	NOT NULL REFERENCES cf_common.hazard_type(code), 
    name    		VARCHAR NOT NULL
);                                                                              
COMMENT ON TABLE cf_common.hazard_type IS
	'Valid Process types by Hazard type';
                                                                                
DELETE FROM cf_common.process_type;                                              
COPY cf_common.process_type (code,hazard_code,name)
    FROM STDIN                                                                  
    WITH (FORMAT csv);                                                          
QLI,EQ,Liquefaction
QGM,EQ,Ground Motion
Q1R,EQ,Primary Rupture
Q2R,EQ,Secondary Rupture
QFF,EQ,Fire Following
TSI,TS,Tsunami
VAF,VO,Ashfall
VLH,VO,Lahar
VPF,VO,Pyroclastic Flow
VBL,VO,Ballistics
VLV,VO,Lava
VFH,VO,Proximal hazards
FSS,CF,Storm Surge
FES,CF,Extreme Sea Level
FCF,CF,Coastal Flood
FFF,FL,Fluvial Flood
FPF,FL,Pluvial Flood
LAV,LS,Snow Avalanche
LSL,LS,Landslide (general)
LRF,LS,landslide rock fall
LDF,LS,landslide debris flow
TCY,WI,Tropical cyclone
ETC,WI,Extratropical cyclone
TOR,WI,Tornado
EHT,ET,Extreme heat
ECD,ET,Extreme cold
DTS,DR,Socio-economic Drought
DTM,DR,Meteorological Drought
DTH,DR,Hydrological Drought
DTA,DR,Agricultural Drought
WFI,WF,Wildfire
\.

--
-- Replace process_type enum with VARCHAR + constraint
--
ALTER TABLE hazard.footprint_set ALTER COLUMN process_type TYPE VARCHAR; 
ALTER TABLE hazard.footprint_set ADD CONSTRAINT valid_process_type
	FOREIGN KEY (process_type) REFERENCES cf_common.process_type(code);

ALTER TABLE hazard.event ALTER COLUMN trigger_process_type TYPE VARCHAR;
ALTER TABLE hazard.event ADD CONSTRAINT valid_trigger_process_type
	FOREIGN KEY (trigger_process_type) REFERENCES cf_common.process_type(code);
DROP TYPE IF EXISTS hazard.process_type;


COMMIT

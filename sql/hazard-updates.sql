--
-- Hazard Database Schema Updates
-- Intended to store event sets for both deterministic and probabilistic 
-- analyses
--

--
-- NOTE please execute commands in common.sql before executing this file
--

--
-- Use transaction to prevent partial execution
--
START TRANSACTION;

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

-----------------------------------------------------------------------------
-- Add boolean field is_prob - TRUE for probabilistic, FALSE for deterministic
ALTER TABLE hazard.event_set ADD COLUMN is_prob BOOLEAN NOT NULL DEFAULT FALSE;

--
-- Enumerated type for hazard calculaton method
--
CREATE TYPE hazard.calc_method_enum AS ENUM (
	'INF',					-- Inferred
	'SIM',					-- Simulation
	'OBS'					-- Observed
);                                                                              
COMMENT ON TYPE hazard.calc_method_enum IS 'Hazard Calculation Methods';

    --  Earthquake: ground-motion               QGM                             
    --              primary surface rupture     Q1R                             
    --              secondary surface rupture   Q2R                             
    --              liquefaction                QLI                             
    --                                                                          
    --  Flood:      water depth                 FWD                             
    --                                                                          
    --  Landslide:  rock fall                   LRF                             
    --              debris flow                 LDF                             
    --                                                                          
    --  Storm Surge:                                                            
    --              inundation                  SIN                             
    --                                                                          
    --  Volcaninc Eruption:                                                     
    --              ash fall                    VAF                             


--
-- Enumerated type for hazard process type
--
CREATE TYPE hazard.process_type_enum AS ENUM (
	'DRT' 					-- Drought
	'FWD',					-- Flood Water Depth
	'LDF',					-- Landslide Debris Flow
	'LRF',					-- Landslide Rock Fall
	'QGM',					-- Earthquake Ground Motion
	'Q1R',					-- Earthquake primary surface Rupture
	'Q2R',					-- Earthquake secondary surface Rupture
	'QLI',					-- Earthquake Liquefaction
	'SIN',					-- Storm Surge Inundation
	'TSI',					-- Tsunami 
	'VAF'					-- Volcaninc Ash Fall
);                                                                              
COMMENT ON TYPE hazard.process_type_enum IS 'Hazard process type';


--
-- Contribution metadata
--
CREATE TABLE contribution (
	id					SERIAL PRIMARY KEY,
	event_set_id		INTEGER NOT NULL 
							REFERENCES event_set(id) ON DELETE CASCADE,
	model_source		VARCHAR NOT NULL,
	model_date			DATE NOT NULL,
	notes				TEXT,
	license_id			INTEGER NOT NULL
							REFERENCES cf_common.license(id),
	version				VARCHAR,
	purpose				TEXT
);
COMMENT ON TABLE contribution                                                  
    IS 'Meta-data for contributed model, license, source etc.';                                
-- Index for FOREIGN KEY                                                        
CREATE INDEX ON contribution USING btree(event_set_id);

--
-- Convert hazard.event_set.hazard_type from VARCHAR to enum
--
UPDATE hazard.event_set SET hazard_type='Earthquake' WHERE hazard_type='EQK';
UPDATE hazard.event_set SET hazard_type='Tsunami' WHERE hazard_type='TSU';
UPDATE hazard.event_set SET hazard_type='Volcanic Ash' WHERE hazard_type='VOL';
ALTER TABLE hazard.event_set 
	ALTER COLUMN hazard_type TYPE cf_common.hazard_enum
		USING hazard_type::cf_common.hazard_enum;
--
-- Convert hazard.event.trigger_hazard_type from VARCHAR to enum
--
UPDATE hazard.event SET trigger_hazard_type='Earthquake' 
	WHERE trigger_hazard_type='EQK';
ALTER TABLE hazard.event 
	ALTER COLUMN trigger_hazard_type TYPE cf_common.hazard_enum
		USING trigger_hazard_type::cf_common.hazard_enum;

--
-- Convert hazard.event.calculation_method from VARCHAR to enum
--
ALTER TABLE hazard.event 
	ALTER COLUMN calculation_method TYPE hazard.calc_method_enum
		USING calculation_method::hazard.calc_method_enum;

--
-- Process type -> enum
--
UPDATE hazard.footprint_set SET process_type='QGM' WHERE process_type='e-gm';
UPDATE hazard.footprint_set SET process_type='VAF' WHERE process_type='v-tl';
ALTER TABLE hazard.footprint_set 
	ALTER COLUMN process_type TYPE process_type_enum
		USING process_type::process_type_enum;
ALTER TABLE hazard.event 
	ALTER COLUMN trigger_process_type TYPE process_type_enum
		USING trigger_process_type::process_type_enum;

--
-- Using an enum/lookup for IMT is problematic due to parametric types such 
-- as SA(0.3). At least unify case for PGA, MMI, PGV. 
--
UPDATE hazard.footprint_set SET imt='PGA' WHERE imt='pga';
UPDATE hazard.footprint_set SET imt='PGV' WHERE imt='pgv';
UPDATE hazard.footprint_set SET imt='MMI' WHERE imt='mmi';


--
-- Commit changes to DB - 
-- NOTE this should be the last command in this file
--
COMMIT;

-- Magic Vim comment to use 4 space tabs 
-- vim: set ts=4:sw=4                                                           

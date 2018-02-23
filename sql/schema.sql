--
-- SQL Schema for Hazard Scenario Database
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

--
-- Use the "hazard" schema to hold all hazard scenario information
--
CREATE SCHEMA IF NOT EXISTS hazard;

--
-- Replace "hazardcontrib" with the appropriate owner
--
ALTER SCHEMA hazard OWNER TO hazardcontrib;

SET search_path = hazard, pg_catalog, public;

-- If you want to use a tablespace, configure it here
-- SET default_tablespace = hazard_ts;

--
-- DROP tables and related indices
--
DROP TABLE IF EXISTS footprint_data CASCADE;
DROP TABLE IF EXISTS footprint_set CASCADE;
DROP TABLE IF EXISTS footprint CASCADE;
DROP TABLE IF EXISTS event_set CASCADE;
DROP TABLE IF EXISTS event CASCADE;

--
-- Collection of one or more events
--
CREATE TABLE event_set (
	id						SERIAL PRIMARY KEY,

	-- Bounding box of investigated area (Polygon in WGS84)
	the_geom		        GEOMETRY(Polygon,4326) NOT NULL,

	-- The name of the geographic area covered by the present scenario hazard
	-- analysis. Can be used by a geocoder (e.g. geopy). The user can provide
	-- a comma-separated list of place names.
	geographic_area_name	VARCHAR NOT NULL,
    creation_date			DATE NOT NULL,

    -- TODO consider using a lookup table OR enumerated type
    -- Valid hazards are:
    --  Drought             DRT
    --  Earthquake          EQK
    --  Flood               FLD
    --  Lanslide            LND
    --  Storm Surge         STS
    --  Tsunami             TSU
    --  Volcanic eruption   VOL
    --
    hazard_type				VARCHAR NOT NULL,
	time_start				TIMESTAMP,
	time_end				TIMESTAMP,
    time_duration			INTERVAL,
    description				TEXT,
    bibliography			TEXT
);
-- Geospatial index for bounding box geometry
CREATE INDEX ON event_set USING GIST(the_geom);
COMMENT ON TABLE event_set IS 'Collection of one or more events';
ALTER TABLE event_set OWNER TO hazardcontrib;


--
-- A single event, member of an event set
--
CREATE TABLE event (
	id	SERIAL	PRIMARY KEY,
	event_set_id			INTEGER REFERENCES event_set(id) 
                                ON DELETE CASCADE,

    -- Consider using a lookup or enumerated type
    -- Valid methods are:
    --  Observed            OBS
    --  Inferred            INF
    --  Simulated           SIM
	calculation_method		VARCHAR NOT NULL, 

	-- TODO Check this type both for dimension and float/double
	frequency				DOUBLE PRECISION, -- TODO check ARRAY,
	occurrence_probability	DOUBLE PRECISION, -- TODO check ARRAY,
	occurrence_time_start	TIMESTAMP,
	occurrence_time_end		TIMESTAMP,
	occurrence_time_span	INTERVAL,
	trigger_hazard_type		VARCHAR,
	trigger_process_type	VARCHAR,
	
	-- TODO think about cycle avoidance mechanisms
    -- trigger_event_id <> id
    -- more complex mutual cycles possible with A->B->A...
	trigger_event_id		INTEGER REFERENCES event(id),
	description				TEXT
);
COMMENT ON TABLE event IS 'A single event, member of an event set';
ALTER TABLE event OWNER TO hazardcontrib;

--
-- A homogeneous set of footprints associated with an event
--
CREATE TABLE footprint_set (
	id						SERIAL PRIMARY KEY,
	event_id				INTEGER NOT NULL REFERENCES event(id)
                                ON DELETE CASCADE,

    -- TODO Consider use of a lookup table or enumerated type
    -- Valid process types
    --  Drought                                 DRT
    --
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
	process_type			VARCHAR NOT NULL,
    -- NOTE parameterised intensity types such as SA(0.2) are difficult
    -- to check with a simple lookup/enumerated type.
    --
	imt						VARCHAR NOT NULL, 

	-- Typology of uncertainty used for this specific set of footprints. 
	-- Some potential options:
	-- 	Eventset        this FootprintSet will contain many Footprints
    --  Equiprobable    this FootprintSet will contain 1 Footprint
	-- 	Normal
	-- 	Lognormal
	data_uncertainty		VARCHAR
);
COMMENT ON TABLE footprint_set 
    IS 'A homogeneous set of footprints associated with an event';
ALTER TABLE footprint_set OWNER TO hazardcontrib;

--
-- A single footprint or "intensity field" - a realization of an event
--
-- The uncertainty of a particular event is captured either by the 
-- construction of many footprints or by a single footprint which 
-- contains also information about uncertainty
--
CREATE TABLE footprint (
	id						SERIAL PRIMARY KEY,
	footprint_set_id		INTEGER NOT NULL 
                                REFERENCES footprint_set(id)
                                ON DELETE CASCADE,

    -- TODO consider moving into columns in footprint_data
	uncertainty_2nd_moment	DOUBLE PRECISION ARRAY,

	-- TODO consider cycle check constraints
	trigger_footprint_id	INTEGER REFERENCES footprint(id)
);
COMMENT ON TABLE footprint 
    IS 'A single footprint or intensity field, a realization of an event';
ALTER TABLE footprint OWNER TO hazardcontrib;

--
-- A single point in a footprint: point location and intensity value
-- Note that we cannot assume the points are on a regular fixed-space grid, 
-- so rasters are not a viable solution
--
CREATE TABLE footprint_data (
	id					SERIAL PRIMARY KEY,
	footprint_id		INTEGER NOT NULL REFERENCES footprint(id)
                            ON DELETE CASCADE,
	the_geom			GEOMETRY(Point, 4326) NOT NULL,

    -- NOTE that "value" is a reserved word in some SQL dialects
    -- TODO consider space optimization techniques for cases where the
    -- same locations are used for all footprints in a given set e.g.
    -- by using intensity arrays, json maps or multiple columns
	intensity			DOUBLE PRECISION NOT NULL
);
-- Geospatial index on foorprint geometry points
CREATE INDEX ON footprint_data USING GIST(the_geom);
-- We need to be able to search quickly by footprint id
CREATE INDEX ON footprint_data(footprint_id);
COMMENT ON TABLE footprint_data 
    IS 'A single point in a footprint: point location and intensity value';
ALTER TABLE footprint_data OWNER TO hazardcontrib;


-- vim: set ts=4:sw=4

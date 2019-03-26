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
-- Remove unwanted process types following discussion with Stuart
--
DELETE FROM cf_common.process_type WHERE code='QFF';
DELETE FROM cf_common.process_type WHERE code='FES';
DELETE FROM cf_common.process_type WHERE code='LRF';
DELETE FROM cf_common.process_type WHERE code='LDF';

INSERT INTO cf_common.hazard_type VALUES ('CS','Convective Storm');
UPDATE cf_common.process_type SET hazard_code = 'CS' WHERE name ='Tornado';

COMMIT

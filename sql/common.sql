--
-- Common elements for all Challenge Fund Database Schemas
-- Hazard enumeration (copied from MOVER)
-- License table
--
START TRANSACTION;

CREATE SCHEMA IF NOT EXISTS cf_common;
COMMENT ON SCHEMA cf_common IS 
	'Common elements for all Challenge Fund Database Schemas';

--
-- No longer need Enumerated type for supported hazards (aka perils)
--
--
DROP TYPE IF EXISTS cf_common.hazard_enum;

--
-- List of valid hazard types with Think Hazard! codes
-- See http://thinkhazard.org/
--
CREATE TABLE IF NOT EXISTS cf_common.hazard_type (
	code	VARCHAR 		PRIMARY KEY,
	name	VARCHAR			NOT NULL
);
COMMENT ON TABLE cf_common.hazard_type IS 'Valid Hazard types';

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
-- Supported licenses
--
CREATE TABLE IF NOT EXISTS cf_common.license (
	id		SERIAL	PRIMARY KEY,
	code	VARCHAR NOT NULL,
	name	VARCHAR	NOT NULL,
	notes	TEXT,
	url		VARCHAR NOT NULL
);
COMMENT ON TABLE cf_common.license IS
	'List of supported licenses';

DELETE FROM cf_common.license;
COPY cf_common.license (code,name,notes,url)
	FROM STDIN
	WITH (FORMAT csv);
CC0,Creative Commons CCZero (CC0),Dedicate to the Public Domain (all rights waived),https://creativecommons.org/publicdomain/zero/1.0/
PDDL,Open Data Commons Public Domain Dedication and Licence (PDDL),Dedicate to the Public Domain (all rights waived),https://opendatacommons.org/licenses/pddl/index.html
CC-BY-4.0,Creative Commons Attribution 4.0 (CC-BY-4.0),,https://creativecommons.org/licenses/by/4.0/
ODC-BY,Open Data Commons Attribution License(ODC-BY),Attribution for data(bases),https://opendatacommons.org/licenses/by/summary/
CC-BY-SA-4.0,Creative Commons Attribution Share-Alike 4.0 (CC-BY-SA-4.0),,http://creativecommons.org/licenses/by-sa/4.0/
ODbL,Open Data Commons Open Database License (ODbL),Attribution-ShareAlike for data(bases),https://opendatacommons.org/licenses/odbl/summary/
\.

COMMIT;

-- Magic Vim comment to use 4 space tabs                                        
-- vim: set ts=4:sw=4                                                           

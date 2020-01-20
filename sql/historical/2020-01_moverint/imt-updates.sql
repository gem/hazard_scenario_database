START TRANSACTION;

-- Convert flood depth intensity values from mm to m
-- NOTE - there are about 10M matching values in the SWIO datasets 
-- so this might take a while

UPDATE hazard.footprint_data d SET intensity=intensity/1000 
  FROM hazard.footprint_set fs, hazard.footprint f
 WHERE f.id=d.footprint_id AND 
	   fs.id=f.footprint_set_id AND 
	   fs.imt = 'Depth mm'; 
-- It is important that this update happens only if the previous worked
UPDATE hazard.hazard.footprint_set SET imt='d_fl:m' WHERE imt='Depth mm';



-- Update IMT codes using table agreed with UCL & GFDRR
UPDATE hazard.footprint_set SET imt='PGA:g' WHERE imt = 'PGA';
UPDATE hazard.footprint_set SET imt='PGV:g' WHERE imt = 'PGV';
UPDATE hazard.footprint_set SET imt='MMI:-' WHERE imt = 'MMI';
UPDATE hazard.footprint_set SET imt='SA(3.0):g' WHERE imt = 'SA(3.0)';
UPDATE hazard.footprint_set SET imt='SA(1.0):g' WHERE imt = 'SA(1.0)';
UPDATE hazard.footprint_set SET imt='SA(0.3):g' WHERE imt = 'SA(0.3)';
UPDATE hazard.footprint_set SET imt='SA(0.2):g' WHERE imt = 'SA(0.2)';
UPDATE hazard.footprint_set SET imt='SA(0.1):g' WHERE imt = 'SA(0.1)';
UPDATE hazard.footprint_set SET imt='v_wi(10m):km/h' WHERE imt = '10-min sustained wind (kph)';
UPDATE hazard.footprint_set SET imt='v_wi(1m):km/h' WHERE imt = '1-min sustained wind (kph)';
UPDATE hazard.footprint_set SET imt='v_wi(3s):km/h' WHERE imt = '3-sec sustained wind (kph)';
UPDATE hazard.footprint_set SET imt='L_af:kg/m2' WHERE imt = 'tephra_load';

-- This update would unify IMT for both storm surge and pluvial flood
-- UPDATE hazard.footprint_set SET imt='d:m' WHERE imt = 'Depth m';
-- If we need to distinguish, then we need more complex update
-- UPDATE hazard.footprint_set fs SET imt='d_fl:m' FROM ... WHERE es.hazard_type='FL' AND ... AND imt = 'Depth m';
-- UPDATE hazard.footprint_set SET imt='d_ss:m' WHERE imt = 'Depth m';


-- TODO CREATE TABLE cf_common.imt.code
-- TODO populate from googls sheet
-- TODO add constraint  hazard.footprint_set REFERENCES cf_common.imt.code

COMMIT;

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
UPDATE hazard.hazard.footprint_set SET imt='d_fpf:m' 
 WHERE process_type='FPF' AND imt='Depth mm';
UPDATE hazard.hazard.footprint_set SET imt='d_fff:m' 
 WHERE process_type='FFF' AND imt='Depth mm';
-- Fix intermediate update - we were using d:fl_m before distinguishing
UPDATE hazard.hazard.footprint_set SET imt='d_fpf:m' 
 WHERE process_type='FPF' AND imt='d_fl:m';

-- Update other IMT codes using table agreed with UCL & GFDRR

UPDATE hazard.footprint_set SET imt='PGA:g' WHERE imt = 'PGA';
UPDATE hazard.footprint_set SET imt='PGV:g' WHERE imt = 'PGV';
UPDATE hazard.footprint_set SET imt='MMI:-' WHERE imt = 'MMI';
UPDATE hazard.footprint_set SET imt='SA(3.0):g' WHERE imt = 'SA(3.0)';
UPDATE hazard.footprint_set SET imt='SA(1.0):g' WHERE imt = 'SA(1.0)';
UPDATE hazard.footprint_set SET imt='SA(0.3):g' WHERE imt = 'SA(0.3)';
UPDATE hazard.footprint_set SET imt='SA(0.2):g' WHERE imt = 'SA(0.2)';
UPDATE hazard.footprint_set SET imt='SA(0.1):g' WHERE imt = 'SA(0.1)';

UPDATE hazard.footprint_set SET imt='v_tcy(10m):km/h' 
 WHERE process_type='TCY' AND imt = '10-min sustained wind (kph)';
UPDATE hazard.footprint_set SET imt='v_tcy(1m):km/h' 
 WHERE process_type='TCY' AND imt = '1-min sustained wind (kph)';
UPDATE hazard.footprint_set SET imt='v_tcy(3s):km/h' 
 WHERE process_type='TCY' AND imt = '3-sec sustained wind (kph)';

UPDATE hazard.footprint_set SET imt='v_etc(10m):km/h' 
 WHERE process_type='ETC' AND imt = '10-min sustained wind (kph)';
UPDATE hazard.footprint_set SET imt='v_etc(1m):km/h' 
 WHERE process_type='ETC' AND imt = '1-min sustained wind (kph)';
UPDATE hazard.footprint_set SET imt='v_etc(3s):km/h' 
 WHERE process_type='ETC' AND imt = '3-sec sustained wind (kph)';

UPDATE hazard.footprint_set SET imt='L_vaf:kg/m2' WHERE imt = 'tephra_load';

UPDATE hazard.footprint_set SET imt='Rh_tsi:m' 
 WHERE process_type='TSI' AND imt='height';

UPDATE hazard.footprint_set SET imt='d_fss:m' 
 WHERE process_type='FSS' AND imt = 'Depth m';


COMMIT;

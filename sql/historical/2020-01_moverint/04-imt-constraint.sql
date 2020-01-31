START TRANSACTION;

-- Fix erronous PGV:g values
UPDATE hazard.footprint_set SET imt='PGV:m/s' WHERE imt = 'PGV:g'; 

-- Check IMTs are present in common IMT table
ALTER TABLE hazard.footprint_set 
  ADD CONSTRAINT valid_imt FOREIGN KEY(imt) REFERENCES cf_common.imt(im_code);

COMMIT; 

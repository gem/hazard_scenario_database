START TRANSACTION;

--
-- Minor license code changes to align with respective websites
--
UPDATE cf_common.license SET code = 'ODC-By' WHERE code='ODC-BY';
UPDATE cf_common.license SET code = 'CC BY 4.0' WHERE code='CC-BY-4.0';
UPDATE cf_common.license SET code = 'CC BY-SA 4.0' WHERE code='CC-BY-SA-4.0';

ALTER TABLE cf_common.license ADD CONSTRAINT unique_code UNIQUE(code);

ALTER TABLE hazard.contribution 
  ADD COLUMN license_code VARCHAR REFERENCES cf_common.license(code);

UPDATE hazard.contribution c
   SET license_code=l.code
  FROM cf_common.license l 
 WHERE c.license_id=l.id;

ALTER TABLE hazard.contribution ALTER COLUMN license_code SET NOT NULL;
ALTER TABLE hazard.contribution DROP COLUMN license_id;

ALTER TABLE cf_common.license DROP COLUMN id;

COMMIT;

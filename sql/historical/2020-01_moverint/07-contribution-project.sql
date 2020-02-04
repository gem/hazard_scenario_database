START TRANSACTION;

-- Add a project field
ALTER TABLE hazard.contribution ADD COLUMN IF NOT EXISTS project VARCHAR;
UPDATE hazard.contribution SET project = 'SWIO RAFI' 
 WHERE model_source LIKE '%SWIO%';

-- Add a contributed_at timestamp (with time zone)
ALTER TABLE hazard.contribution ADD COLUMN IF NOT EXISTS 
	contributed_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT NOW();
UPDATE hazard.contribution SET contributed_at = '2019-04-01 00:00:00+0' 
 WHERE model_source LIKE '%SWIO%';

COMMIT;

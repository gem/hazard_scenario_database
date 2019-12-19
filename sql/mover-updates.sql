-- SQL statements to be applied to the CF hazard database 

-- Add a project field
ALTER TABLE hazard.contribution ADD COLUMN IF NOT EXISTS project VARCHAR;
-- All hazard contributions with id<=90 come from the SWIO RAFI project
UPDATE hazard.contribution SET project = 'SWIO RAFI' 
  WHERE model_source LIKE '%SWIO RAFI%';

-- Add a contributed_at timestamp (with time zone)
ALTER TABLE hazard.contribution ADD COLUMN IF NOT EXISTS 
	contributed_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT NOW();
UPDATE hazard.contribution SET contributed_at = '2019-04-01 00:00:00+0' 
  WHERE project='SWIO RAFI';

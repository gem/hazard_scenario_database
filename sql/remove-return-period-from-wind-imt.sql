UPDATE hazard.footprint_set 
	SET imt=regexp_replace(imt, ' [0-9]+yr$','') 
	WHERE imt ILIKE '%wind%yr';

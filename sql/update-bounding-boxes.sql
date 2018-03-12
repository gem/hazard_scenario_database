WITH bb AS (
	SELECT 
			e.event_set_id AS id, 
  			ST_SetSRID(st_extent(the_geom),4326) AS the_geom 
	  FROM hazard.footprint_data fd 
	  JOIN hazard.footprint fp ON fp.id=fd.footprint_id 
	  JOIN hazard.footprint_set fs ON fs.id=fp.footprint_set_id 
	  JOIN hazard.event e ON e.id=fs.event_id 
     GROUP BY e.event_set_id
)
UPDATE hazard.event_set es SET the_geom=bb.the_geom FROM bb WHERE es.id=bb.id;

SELECT 
  fd.the_geom, 
  min(intensity) AS min_pga,
  percentile_cont(0.16) WITHIN GROUP (order by intensity)  AS pc16 ,
  avg(intensity) AS u_pga,
  percentile_cont(0.50) WITHIN GROUP (order by intensity)  AS pc50,
  percentile_cont(0.84) WITHIN GROUP (order by intensity)  AS pc84 ,
  max(intensity) AS max_pga,
  stddev(intensity) / avg(intensity) AS norm_std
  FROM hazard.footprint_data fd 
  JOIN hazard.footprint fp ON fp.id=fd.footprint_id
  JOIN hazard.footprint_set fs ON fs.id=fp.footprint_set_id
  JOIN hazard.event ev ON ev.id=fs.event_id
 WHERE 
  fs.imt ILIKE 'PGA:g'
   AND 
  ev.event_set_id=7
 GROUP BY fd.the_geom

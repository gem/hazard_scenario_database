SELECT fd.*, fs.process_type, fs.imt, e.frequency, e.occurrence_probability, e.description
 FROM hazard.footprint_data fd
 JOIN hazard.footprint fp ON fd.footprint_id=fp.id
 JOIN hazard.footprint_set fs ON fp.footprint_set_id=fs.id
 JOIN hazard.event e ON fs.event_id = e.id
 JOIN hazard.event_set es ON es.id=e.event_set_id
WHERE  
 fs.process_type ='TCY' AND 
 e.frequency=1/10.0 AND 
 fs.imt='v_tcy(1m):km/h'

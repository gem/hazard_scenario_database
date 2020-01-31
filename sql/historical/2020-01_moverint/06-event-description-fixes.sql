UPDATE hazard.event 
   SET description = regexp_replace(description,'MDG (.*)','ZAN \1','g') 
 WHERE event_set_id IN (103,104) ;
UPDATE hazard.event 
   SET description = regexp_replace(description,'MDG (.*)','COM \1','g') 
 WHERE event_set_id = 84;
UPDATE hazard.event 
   SET description = regexp_replace(description,'MDG (.*)','MUS \1','g') 
 WHERE event_set_id = 93;


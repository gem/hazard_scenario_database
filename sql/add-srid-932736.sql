--
-- If your PostGIS installation does not already have support for UTM 36S
-- execute the SQL INSERT command below.  Take from: 
-- http://spatialreference.org/ref/epsg/wgs-84-utm-zone-36s/
--
INSERT INTO spatial_ref_sys (srid, auth_name, auth_srid, proj4text, srtext) 
VALUES ( 
	932736, 'epsg', 32736, 
	'+proj=utm +zone=36 +south +ellps=WGS84 +datum=WGS84 +units=m +no_defs ', 
	'PROJCS["WGS 84 / UTM zone 36S",GEOGCS["WGS 84",DATUM["WGS_1984",SPHEROID["WGS 84",6378137,298.257223563,AUTHORITY["EPSG","7030"]],AUTHORITY["EPSG","6326"]],PRIMEM["Greenwich",0,AUTHORITY["EPSG","8901"]],UNIT["degree",0.01745329251994328,AUTHORITY["EPSG","9122"]],AUTHORITY["EPSG","4326"]],UNIT["metre",1,AUTHORITY["EPSG","9001"]],PROJECTION["Transverse_Mercator"],PARAMETER["latitude_of_origin",0],PARAMETER["central_meridian",33],PARAMETER["scale_factor",0.9996],PARAMETER["false_easting",500000],PARAMETER["false_northing",10000000],AUTHORITY["EPSG","32736"],AXIS["Easting",EAST],AXIS["Northing",NORTH]]'
);

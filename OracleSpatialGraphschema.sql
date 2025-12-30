-- Oracle Spatial Schema
CREATE TABLE locations (
  location_id VARCHAR2(50) PRIMARY KEY,
  name VARCHAR2(255),
  geometry SDO_GEOMETRY
);

INSERT INTO user_sdo_geom_metadata VALUES (
  'LOCATIONS', 'GEOMETRY',
  SDO_DIM_ARRAY(
    SDO_DIM_ELEMENT('Longitude', -180, 180, 0.005),
    SDO_DIM_ELEMENT('Latitude', -90, 90, 0.005)
  ), 4326
);

CREATE INDEX locations_sidx ON locations(geometry)
  INDEXTYPE IS MDSYS.SPATIAL_INDEX;
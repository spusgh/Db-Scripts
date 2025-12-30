-- SpatiaLite Schema
SELECT InitSpatialMetadata(1);

CREATE TABLE locations (
  location_id TEXT PRIMARY KEY,
  name TEXT
);

SELECT AddGeometryColumn('locations', 'geometry', 4326, 'POINT', 'XY');
SELECT CreateSpatialIndex('locations', 'geometry');
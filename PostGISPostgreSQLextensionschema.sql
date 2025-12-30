-- PostGIS Schema
CREATE EXTENSION IF NOT EXISTS postgis;

CREATE TABLE locations (
  location_id VARCHAR(50) PRIMARY KEY,
  name VARCHAR(255),
  geometry GEOMETRY(Point, 4326)
);

CREATE INDEX locations_gist_idx 
  ON locations USING GIST(geometry);
-- ============================================================================
-- GOOGLE BIGQUERY GIS SCHEMA DEFINITION
-- Geospatial Database Schema for Location Intelligence
-- CRS: WGS84 (EPSG:4326)
-- BigQuery Standard SQL with GEOGRAPHY type
-- ============================================================================

-- Create dataset
CREATE SCHEMA IF NOT EXISTS `geospatial_db`
OPTIONS(
  location="US",
  description="Geospatial database for location intelligence workloads"
);

-- ============================================================================
-- TABLE: locations
-- Purpose: Store point-based geographic entities
-- Partitioning: By created_at (monthly)
-- Clustering: By city, country, location_type
-- ============================================================================

CREATE OR REPLACE TABLE `geospatial_db.locations` (
  location_id STRING NOT NULL,
  name STRING NOT NULL,
  location_type STRING NOT NULL,
  geometry GEOGRAPHY NOT NULL,  -- Native GEOGRAPHY type (POINT)
  address STRING,
  city STRING,
  country STRING,
  postal_code STRING,
  elevation_m FLOAT64,
  created_at TIMESTAMP NOT NULL,
  updated_at TIMESTAMP NOT NULL,
  attributes JSON
)
PARTITION BY DATE(created_at)
CLUSTER BY city, country, location_type
OPTIONS(
  description="Point-based geographic entities (POIs, sensors, facilities)",
  require_partition_filter=false
);

-- Add computed columns for common operations
ALTER TABLE `geospatial_db.locations`
ADD COLUMN IF NOT EXISTS longitude FLOAT64 AS (ST_X(geometry)),
ADD COLUMN IF NOT EXISTS latitude FLOAT64 AS (ST_Y(geometry)),
ADD COLUMN IF NOT EXISTS geohash STRING AS (ST_GEOHASH(geometry, 8));

-- ============================================================================
-- TABLE: regions
-- Purpose: Administrative boundaries and service areas
-- Partitioning: By created_at (yearly)
-- Clustering: By admin_level, region_type
-- ============================================================================

CREATE OR REPLACE TABLE `geospatial_db.regions` (
  region_id STRING NOT NULL,
  name STRING NOT NULL,
  region_type STRING NOT NULL,
  geometry GEOGRAPHY NOT NULL,  -- POLYGON or MULTIPOLYGON
  parent_region_id STRING,
  population INT64,
  admin_level INT64,
  iso_code STRING,
  created_at TIMESTAMP NOT NULL,
  updated_at TIMESTAMP NOT NULL,
  attributes JSON
)
PARTITION BY DATE_TRUNC(created_at, YEAR)
CLUSTER BY admin_level, region_type
OPTIONS(
  description="Administrative boundaries, service areas, coverage zones"
);

-- Add computed columns
ALTER TABLE `geospatial_db.regions`
ADD COLUMN IF NOT EXISTS area_sq_km FLOAT64 AS (ST_AREA(geometry) / 1000000),
ADD COLUMN IF NOT EXISTS perimeter_km FLOAT64 AS (ST_PERIMETER(geometry) / 1000),
ADD COLUMN IF NOT EXISTS centroid GEOGRAPHY AS (ST_CENTROID(geometry)),
ADD COLUMN IF NOT EXISTS centroid_geohash STRING AS (ST_GEOHASH(ST_CENTROID(geometry), 8));

-- ============================================================================
-- TABLE: boundaries
-- Purpose: Linear geographic features (roads, rivers, borders, pipelines)
-- Clustering: By boundary_type, classification
-- ============================================================================

CREATE OR REPLACE TABLE `geospatial_db.boundaries` (
  boundary_id STRING NOT NULL,
  name STRING NOT NULL,
  boundary_type STRING NOT NULL,
  geometry GEOGRAPHY NOT NULL,  -- LINESTRING or MULTILINESTRING
  start_location_id STRING,
  end_location_id STRING,
  classification STRING,
  surface_type STRING,
  width_m FLOAT64,
  created_at TIMESTAMP NOT NULL,
  updated_at TIMESTAMP NOT NULL,
  attributes JSON
)
CLUSTER BY boundary_type, classification
OPTIONS(
  description="Linear geographic features (roads, rivers, borders, pipelines)"
);

-- Add computed columns
ALTER TABLE `geospatial_db.boundaries`
ADD COLUMN IF NOT EXISTS length_km FLOAT64 AS (ST_LENGTH(geometry) / 1000),
ADD COLUMN IF NOT EXISTS bbox GEOGRAPHY AS (ST_ENVELOPE(geometry));

-- ============================================================================
-- TABLE: routes
-- Purpose: Planned or historical paths
-- Partitioning: By start_time (daily)
-- Clustering: By route_type, status
-- ============================================================================

CREATE OR REPLACE TABLE `geospatial_db.routes` (
  route_id STRING NOT NULL,
  name STRING NOT NULL,
  route_type STRING NOT NULL,
  geometry GEOGRAPHY NOT NULL,  -- LINESTRING
  start_time TIMESTAMP NOT NULL,
  end_time TIMESTAMP,
  vehicle_id STRING,
  driver_id STRING,
  waypoints ARRAY<GEOGRAPHY>,  -- Array of POINT geometries
  status STRING NOT NULL,
  created_at TIMESTAMP NOT NULL,
  updated_at TIMESTAMP NOT NULL,
  attributes JSON
)
PARTITION BY DATE(start_time)
CLUSTER BY route_type, status
OPTIONS(
  description="Planned or historical paths (delivery routes, flight paths)",
  partition_expiration_days=180
);

-- Add computed columns
ALTER TABLE `geospatial_db.routes`
ADD COLUMN IF NOT EXISTS distance_km FLOAT64 AS (ST_LENGTH(geometry) / 1000),
ADD COLUMN IF NOT EXISTS duration_seconds INT64 AS (TIMESTAMP_DIFF(end_time, start_time, SECOND));

-- ============================================================================
-- TABLE: events
-- Purpose: Time-stamped geographic events
-- Partitioning: By event_time (hourly for high volume)
-- Clustering: By event_type, severity
-- ============================================================================

CREATE OR REPLACE TABLE `geospatial_db.events` (
  event_id STRING NOT NULL,
  event_type STRING NOT NULL,
  geometry GEOGRAPHY NOT NULL,  -- POINT
  event_time TIMESTAMP NOT NULL,
  severity STRING,
  location_id STRING,
  asset_id STRING,
  source STRING NOT NULL,
  value FLOAT64,
  unit STRING,
  description STRING,
  created_at TIMESTAMP NOT NULL,
  attributes JSON
)
PARTITION BY TIMESTAMP_TRUNC(event_time, HOUR)
CLUSTER BY event_type, severity
OPTIONS(
  description="Time-stamped geographic events (accidents, sensor readings, transactions)",
  partition_expiration_days=90
);

-- Add computed columns
ALTER TABLE `geospatial_db.events`
ADD COLUMN IF NOT EXISTS longitude FLOAT64 AS (ST_X(geometry)),
ADD COLUMN IF NOT EXISTS latitude FLOAT64 AS (ST_Y(geometry)),
ADD COLUMN IF NOT EXISTS geohash STRING AS (ST_GEOHASH(geometry, 10));

-- ============================================================================
-- TABLE: assets
-- Purpose: Track vehicles, drones, ships, IoT devices
-- Partitioning: By last_updated (daily)
-- Clustering: By asset_type, status
-- ============================================================================

CREATE OR REPLACE TABLE `geospatial_db.assets` (
  asset_id STRING NOT NULL,
  asset_name STRING NOT NULL,
  asset_type STRING NOT NULL,
  current_geometry GEOGRAPHY NOT NULL,  -- Current POINT location
  last_updated TIMESTAMP NOT NULL,
  speed_kmh FLOAT64,
  heading_degrees FLOAT64,
  altitude_m FLOAT64,
  status STRING NOT NULL,
  owner_id STRING,
  trajectory GEOGRAPHY,  -- Recent LINESTRING path
  geofence_id STRING,
  battery_level FLOAT64,
  created_at TIMESTAMP NOT NULL,
  attributes JSON
)
PARTITION BY DATE(last_updated)
CLUSTER BY asset_type, status
OPTIONS(
  description="Moving and static assets with current location and trajectory"
);

-- Add computed columns
ALTER TABLE `geospatial_db.assets`
ADD COLUMN IF NOT EXISTS current_longitude FLOAT64 AS (ST_X(current_geometry)),
ADD COLUMN IF NOT EXISTS current_latitude FLOAT64 AS (ST_Y(current_geometry)),
ADD COLUMN IF NOT EXISTS current_geohash STRING AS (ST_GEOHASH(current_geometry, 10));

-- ============================================================================
-- TABLE: asset_history
-- Purpose: Historical positions for trajectory analysis
-- Partitioning: By recorded_at (daily)
-- Clustering: By asset_id
-- ============================================================================

CREATE OR REPLACE TABLE `geospatial_db.asset_history` (
  history_id STRING NOT NULL,
  asset_id STRING NOT NULL,
  geometry GEOGRAPHY NOT NULL,  -- Historical POINT
  recorded_at TIMESTAMP NOT NULL,
  speed_kmh FLOAT64,
  heading_degrees FLOAT64,
  altitude_m FLOAT64,
  accuracy_m FLOAT64,
  source STRING,
  attributes JSON
)
PARTITION BY DATE(recorded_at)
CLUSTER BY asset_id
OPTIONS(
  description="Historical positions for trajectory reconstruction and analysis",
  partition_expiration_days=180
);

-- Add computed columns
ALTER TABLE `geospatial_db.asset_history`
ADD COLUMN IF NOT EXISTS longitude FLOAT64 AS (ST_X(geometry)),
ADD COLUMN IF NOT EXISTS latitude FLOAT64 AS (ST_Y(geometry)),
ADD COLUMN IF NOT EXISTS geohash STRING AS (ST_GEOHASH(geometry, 10));

-- ============================================================================
-- TABLE: geofences
-- Purpose: Virtual boundaries for alerting and zone management
-- Clustering: By active, geofence_type
-- ============================================================================

CREATE OR REPLACE TABLE `geospatial_db.geofences` (
  geofence_id STRING NOT NULL,
  name STRING NOT NULL,
  geometry GEOGRAPHY NOT NULL,  -- POLYGON or MULTIPOLYGON
  geofence_type STRING NOT NULL,
  active BOOL NOT NULL DEFAULT true,
  trigger_on_enter BOOL DEFAULT false,
  trigger_on_exit BOOL DEFAULT false,
  buffer_m FLOAT64 DEFAULT 0,
  valid_from TIMESTAMP NOT NULL,
  valid_until TIMESTAMP,
  owner_id STRING,
  created_at TIMESTAMP NOT NULL,
  attributes JSON
)
CLUSTER BY active, geofence_type
OPTIONS(
  description="Virtual boundaries for geofencing and zone monitoring"
);

-- Add computed columns
ALTER TABLE `geospatial_db.geofences`
ADD COLUMN IF NOT EXISTS centroid GEOGRAPHY AS (ST_CENTROID(geometry)),
ADD COLUMN IF NOT EXISTS area_sq_km FLOAT64 AS (ST_AREA(geometry) / 1000000);

-- ============================================================================
-- TABLE: raster_metadata
-- Purpose: Reference external raster data
-- Partitioning: By acquisition_date (monthly)
-- Clustering: By raster_type, source
-- ============================================================================

CREATE OR REPLACE TABLE `geospatial_db.raster_metadata` (
  raster_id STRING NOT NULL,
  name STRING NOT NULL,
  raster_type STRING NOT NULL,
  bounds GEOGRAPHY NOT NULL,  -- Bounding box POLYGON
  resolution_m FLOAT64 NOT NULL,
  bands INT64 NOT NULL,
  crs STRING NOT NULL,
  file_path STRING NOT NULL,
  file_size_mb FLOAT64,
  acquisition_date TIMESTAMP,
  source STRING NOT NULL,
  created_at TIMESTAMP NOT NULL,
  attributes JSON
)
PARTITION BY DATE_TRUNC(acquisition_date, MONTH)
CLUSTER BY raster_type, source
OPTIONS(
  description="Metadata catalog for external raster datasets"
);

-- Add computed columns
ALTER TABLE `geospatial_db.raster_metadata`
ADD COLUMN IF NOT EXISTS centroid GEOGRAPHY AS (ST_CENTROID(bounds)),
ADD COLUMN IF NOT EXISTS area_sq_km FLOAT64 AS (ST_AREA(bounds) / 1000000);

-- ============================================================================
-- MATERIALIZED VIEWS FOR COMMON QUERIES
-- ============================================================================

-- Active assets by type
CREATE MATERIALIZED VIEW `geospatial_db.mv_active_assets`
PARTITION BY DATE(last_updated)
CLUSTER BY asset_type
AS
SELECT 
  asset_id,
  asset_name,
  asset_type,
  current_geometry,
  last_updated,
  status,
  current_geohash
FROM `geospatial_db.assets`
WHERE status = 'active'
  AND last_updated >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 24 HOUR);

-- Recent high-severity events
CREATE MATERIALIZED VIEW `geospatial_db.mv_critical_events`
PARTITION BY DATE(event_time)
CLUSTER BY event_type
AS
SELECT 
  event_id,
  event_type,
  geometry,
  event_time,
  severity,
  source,
  description
FROM `geospatial_db.events`
WHERE severity IN ('high', 'critical')
  AND event_time >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 7 DAY);

-- Active geofences
CREATE MATERIALIZED VIEW `geospatial_db.mv_active_geofences`
CLUSTER BY geofence_type
AS
SELECT 
  geofence_id,
  name,
  geometry,
  geofence_type,
  trigger_on_enter,
  trigger_on_exit,
  valid_from,
  valid_until
FROM `geospatial_db.geofences`
WHERE active = true
  AND valid_from <= CURRENT_TIMESTAMP()
  AND (valid_until IS NULL OR valid_until >= CURRENT_TIMESTAMP());

-- ============================================================================
-- USER-DEFINED FUNCTIONS (UDFs)
-- ============================================================================

-- Calculate distance between two GEOGRAPHY points in kilometers
CREATE OR REPLACE FUNCTION `geospatial_db.distance_km`(
  geo1 GEOGRAPHY, 
  geo2 GEOGRAPHY
) RETURNS FLOAT64
AS (
  ST_DISTANCE(geo1, geo2) / 1000
);

-- Check if point is within polygon with buffer
CREATE OR REPLACE FUNCTION `geospatial_db.within_buffer`(
  point GEOGRAPHY,
  polygon GEOGRAPHY,
  buffer_meters FLOAT64
) RETURNS BOOL
AS (
  ST_DWITHIN(point, polygon, buffer_meters)
);

-- Convert GEOGRAPHY to GeoJSON string
CREATE OR REPLACE FUNCTION `geospatial_db.to_geojson`(
  geo GEOGRAPHY
) RETURNS STRING
AS (
  ST_ASGEOJSON(geo)
);

-- Get H3 cell ID at resolution 9
CREATE OR REPLACE FUNCTION `geospatial_db.h3_index`(
  geo GEOGRAPHY,
  resolution INT64
) RETURNS STRING
LANGUAGE js
OPTIONS (
  description="Convert GEOGRAPHY point to H3 hexagon index"
)
AS r"""
  // H3 library would be loaded here
  // This is a placeholder - actual implementation requires H3 JS library
  const lat = geo.coordinates[1];
  const lon = geo.coordinates[0];
  return `h3_${lat}_${lon}_${resolution}`;
""";

-- ============================================================================
-- SEARCH INDEXES FOR FULL-TEXT SEARCH
-- ============================================================================

-- Create search index on location names
CREATE SEARCH INDEX `idx_location_search` 
ON `geospatial_db.locations`(name, address, city)
OPTIONS(
  analyzer='STANDARD'
);

-- ============================================================================
-- ROW-LEVEL SECURITY POLICIES (Example)
-- ============================================================================

-- Example: Restrict access to assets by owner
-- CREATE ROW ACCESS POLICY asset_owner_policy
-- ON `geospatial_db.assets`
-- GRANT TO ('user:owner@example.com')
-- FILTER USING (owner_id = SESSION_USER());

-- ============================================================================
-- SCHEDULED QUERIES FOR MAINTENANCE
-- ============================================================================

-- Example: Daily cleanup of old events (configure in BigQuery UI)
-- DELETE FROM `geospatial_db.events`
-- WHERE event_time < TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 90 DAY);

-- ============================================================================
-- PERFORMANCE OPTIMIZATION NOTES
-- ============================================================================

-- 1. PARTITIONING:
--    - Time-series tables partitioned by timestamp (hourly/daily)
--    - Reduces scan costs by filtering partitions
--    - Set partition_expiration_days for automatic cleanup

-- 2. CLUSTERING:
--    - Group related data within partitions
--    - Improves query performance for filtered/aggregated queries
--    - Max 4 clustering columns, order matters

-- 3. GEOGRAPHY BEST PRACTICES:
--    - Use ST_DWITHIN instead of ST_DISTANCE for proximity queries
--    - Prefer ST_INTERSECTS over ST_CONTAINS for polygon queries
--    - Use bounding box filters before precise spatial operations

-- 4. MATERIALIZED VIEWS:
--    - Pre-compute expensive spatial joins
--    - Auto-refresh when base tables change
--    - Significant cost savings for repeated queries

-- 5. CACHING:
--    - BigQuery caches query results for 24 hours
--    - Use BI Engine for sub-second dashboard queries
--    - Enable query result caching in project settings

-- ============================================================================
-- EXAMPLE SPATIAL QUERIES
-- ============================================================================

-- Find locations within 5km of a point
/*
SELECT location_id, name, 
       ST_DISTANCE(geometry, ST_GEOGPOINT(-74.006, 40.7128)) / 1000 AS distance_km
FROM `geospatial_db.locations`
WHERE ST_DWITHIN(geometry, ST_GEOGPOINT(-74.006, 40.7128), 5000)
ORDER BY distance_km;
*/

-- Point-in-polygon query (which region contains a point)
/*
SELECT r.region_id, r.name, r.region_type
FROM `geospatial_db.regions` r
WHERE ST_CONTAINS(r.geometry, ST_GEOGPOINT(-74.006, 40.7128));
*/

-- Spatial join (assets within geofences)
/*
SELECT a.asset_id, a.asset_name, g.geofence_id, g.name AS geofence_name
FROM `geospatial_db.assets` a
JOIN `geospatial_db.geofences` g
  ON ST_CONTAINS(g.geometry, a.current_geometry)
WHERE g.active = true
  AND a.last_updated >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 1 HOUR);
*/

-- Heatmap aggregation (event density by geohash)
/*
SELECT 
  ST_GEOHASH(geometry, 6) AS geohash_6,
  COUNT(*) AS event_count,
  ST_CENTROID(ST_UNION_AGG(geometry)) AS center
FROM `geospatial_db.events`
WHERE event_time >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 24 HOUR)
GROUP BY geohash_6
HAVING event_count > 10
ORDER BY event_count DESC;
*/

-- Trajectory reconstruction
/*
SELECT 
  asset_id,
  ST_MAKELINE(ARRAY_AGG(geometry ORDER BY recorded_at)) AS trajectory,
  MIN(recorded_at) AS start_time,
  MAX(recorded_at) AS end_time,
  SUM(ST_DISTANCE(
    geometry, 
    LAG(geometry) OVER (PARTITION BY asset_id ORDER BY recorded_at)
  )) / 1000 AS total_distance_km
FROM `geospatial_db.asset_history`
WHERE recorded_at >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 1 DAY)
GROUP BY asset_id;
*/

-- ============================================================================
-- DATA EXPORT/IMPORT
-- ============================================================================

-- Export to GCS in GeoJSON format
/*
EXPORT DATA OPTIONS(
  uri='gs://your-bucket/geospatial_export/*.geojson',
  format='JSON',
  overwrite=true
) AS
SELECT 
  location_id,
  name,
  ST_ASGEOJSON(geometry) AS geometry,
  city,
  country
FROM `geospatial_db.locations`;
*/

-- Import from GCS
/*
LOAD DATA INTO `geospatial_db.locations`
FROM FILES (
  format = 'JSON',
  uris = ['gs://your-bucket/locations/*.json']
);
*/

-- ============================================================================
-- END OF DDL
-- ============================================================================
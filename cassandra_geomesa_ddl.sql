-- ============================================================================
-- CASSANDRA + GEOMESA COMPLETE SCHEMA
-- Production-Ready Geospatial Database Schema
-- Version: 1.0.0
-- CRS: WGS84 (EPSG:4326)
-- Cassandra: 4.0+
-- GeoMesa: 5.0+
-- ============================================================================

-- ============================================================================
-- KEYSPACE CREATION
-- ============================================================================

CREATE KEYSPACE IF NOT EXISTS geospatial_db
WITH replication = {
  'class': 'NetworkTopologyStrategy',
  'datacenter1': 3,
  'datacenter2': 2  -- Optional: for multi-DC deployment
}
AND durable_writes = true;

USE geospatial_db;

-- ============================================================================
-- CONFIGURATION NOTES
-- ============================================================================
-- For GeoMesa integration, you must also:
-- 1. Install GeoMesa Cassandra distribution
-- 2. Create SimpleFeatureTypes using GeoMesa CLI or API
-- 3. Configure spatial indices (see GeoMesa configuration section below)
--
-- GeoMesa CLI example:
-- geomesa-cassandra create-schema \
--   --contact-point localhost:9042 \
--   --keyspace geospatial_db \
--   --catalog geospatial_catalog \
--   --feature-name locations \
--   --spec "location_id:UUID:index=true,*geometry:Point:srid=4326,name:String,..."
-- ============================================================================

-- ============================================================================
-- TABLE: locations
-- Purpose: Point-based geographic entities (POIs, sensors, facilities)
-- Geometry: POINT
-- Index Strategy: GeoHash-8, Z-order curve
-- Expected Volume: 10M-100M records
-- ============================================================================

CREATE TABLE IF NOT EXISTS locations (
    -- Primary Key
    location_id uuid PRIMARY KEY,
    
    -- Core Attributes
    name varchar,
    location_type varchar,
    
    -- Geometry Fields
    geometry_wkb blob,              -- WKB encoded POINT geometry (primary storage)
    geometry_wkt text,              -- WKT for human readability (optional)
    longitude double,               -- Extracted X coordinate for queries
    latitude double,                -- Extracted Y coordinate for queries
    geohash varchar,                -- Precomputed GeoHash for spatial indexing
    
    -- Address Components
    address varchar,
    city varchar,
    state_province varchar,
    country varchar,
    postal_code varchar,
    
    -- Additional Attributes
    elevation_m double,
    phone varchar,
    email varchar,
    website varchar,
    
    -- Temporal Fields
    created_at timestamp,
    updated_at timestamp,
    
    -- Flexible Metadata
    attributes map<text, text>,     -- JSON-like key-value pairs
    tags set<text>                  -- Tags for categorization
) WITH 
    -- Performance Optimization
    bloom_filter_fp_chance = 0.01
    AND caching = {
        'keys': 'ALL',
        'rows_per_partition': 'ALL'
    }
    AND compression = {
        'class': 'LZ4Compressor',
        'chunk_length_in_kb': 64
    }
    AND compaction = {
        'class': 'LeveledCompactionStrategy',
        'sstable_size_in_mb': 160
    }
    AND gc_grace_seconds = 864000
    AND comment = 'Point-based geographic entities';

-- Secondary Indexes
CREATE INDEX IF NOT EXISTS idx_locations_city ON locations(city);
CREATE INDEX IF NOT EXISTS idx_locations_country ON locations(country);
CREATE INDEX IF NOT EXISTS idx_locations_type ON locations(location_type);
CREATE INDEX IF NOT EXISTS idx_locations_geohash ON locations(geohash);
CREATE INDEX IF NOT EXISTS idx_locations_postal_code ON locations(postal_code);

-- Materialized View: Locations by GeoHash for spatial queries
CREATE MATERIALIZED VIEW IF NOT EXISTS locations_by_geohash AS
    SELECT location_id, name, location_type, geometry_wkb, longitude, latitude, 
           geohash, city, country, created_at
    FROM locations
    WHERE geohash IS NOT NULL 
      AND location_id IS NOT NULL
    PRIMARY KEY (geohash, location_id)
    WITH CLUSTERING ORDER BY (location_id ASC)
    AND bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
    AND compression = {'class': 'LZ4Compressor'};

-- Materialized View: Locations by City
CREATE MATERIALIZED VIEW IF NOT EXISTS locations_by_city AS
    SELECT location_id, name, location_type, city, country, 
           longitude, latitude, created_at
    FROM locations
    WHERE city IS NOT NULL 
      AND location_id IS NOT NULL
    PRIMARY KEY (city, location_type, location_id)
    WITH CLUSTERING ORDER BY (location_type ASC, location_id ASC);

-- ============================================================================
-- TABLE: regions
-- Purpose: Administrative boundaries, service areas, coverage zones
-- Geometry: POLYGON, MULTIPOLYGON
-- Index Strategy: XZ2/XZ3 hierarchical
-- Expected Volume: 100K-1M records
-- ============================================================================

CREATE TABLE IF NOT EXISTS regions (
    -- Primary Key
    region_id uuid PRIMARY KEY,
    
    -- Core Attributes
    name varchar,
    region_type varchar,            -- admin_boundary, service_area, coverage_zone
    
    -- Geometry Fields
    geometry_wkb blob,              -- WKB encoded POLYGON/MULTIPOLYGON
    geometry_wkt text,              -- WKT representation
    
    -- Hierarchical Structure
    parent_region_id uuid,          -- For nested regions (e.g., state → country)
    hierarchy_level int,            -- 0=root, 1=continent, 2=country, 3=state, etc.
    
    -- Computed Geometry Properties
    area_sq_km double,              -- Area in square kilometers
    perimeter_km double,            -- Perimeter in kilometers
    centroid_lon double,            -- Centroid longitude
    centroid_lat double,            -- Centroid latitude
    centroid_geohash varchar,       -- Centroid GeoHash for indexing
    bbox_min_lon double,            -- Bounding box minimum longitude
    bbox_min_lat double,            -- Bounding box minimum latitude
    bbox_max_lon double,            -- Bounding box maximum longitude
    bbox_max_lat double,            -- Bounding box maximum latitude
    
    -- Administrative Attributes
    population bigint,
    admin_level int,                -- Administrative level (1-10)
    iso_code varchar,               -- ISO 3166 country/region code
    
    -- Temporal Fields
    created_at timestamp,
    updated_at timestamp,
    effective_date date,            -- When boundary became effective
    expiry_date date,               -- When boundary expires (if applicable)
    
    -- Metadata
    attributes map<text, text>,
    tags set<text>
) WITH 
    compression = {'class': 'LZ4Compressor'}
    AND compaction = {
        'class': 'LeveledCompactionStrategy',
        'sstable_size_in_mb': 320
    }
    AND comment = 'Administrative boundaries and service areas';

-- Secondary Indexes
CREATE INDEX IF NOT EXISTS idx_regions_type ON regions(region_type);
CREATE INDEX IF NOT EXISTS idx_regions_admin_level ON regions(admin_level);
CREATE INDEX IF NOT EXISTS idx_regions_iso_code ON regions(iso_code);
CREATE INDEX IF NOT EXISTS idx_regions_parent ON regions(parent_region_id);
CREATE INDEX IF NOT EXISTS idx_regions_centroid_geohash ON regions(centroid_geohash);

-- Materialized View: Regions by Type and Admin Level
CREATE MATERIALIZED VIEW IF NOT EXISTS regions_by_type AS
    SELECT region_id, name, region_type, admin_level, iso_code, 
           centroid_lon, centroid_lat, area_sq_km, parent_region_id
    FROM regions
    WHERE region_type IS NOT NULL 
      AND admin_level IS NOT NULL 
      AND region_id IS NOT NULL
    PRIMARY KEY ((region_type), admin_level, region_id)
    WITH CLUSTERING ORDER BY (admin_level ASC, region_id ASC);

-- Materialized View: Regions by Parent (Hierarchical Navigation)
CREATE MATERIALIZED VIEW IF NOT EXISTS regions_by_parent AS
    SELECT region_id, name, region_type, parent_region_id, 
           admin_level, created_at
    FROM regions
    WHERE parent_region_id IS NOT NULL 
      AND region_id IS NOT NULL
    PRIMARY KEY (parent_region_id, region_id)
    WITH CLUSTERING ORDER BY (region_id ASC);

-- ============================================================================
-- TABLE: boundaries
-- Purpose: Linear geographic features (roads, rivers, borders, pipelines)
-- Geometry: LINESTRING, MULTILINESTRING
-- Index Strategy: GeoHash on bounding box
-- Expected Volume: 1M-10M records
-- ============================================================================

CREATE TABLE IF NOT EXISTS boundaries (
    -- Primary Key
    boundary_id uuid PRIMARY KEY,
    
    -- Core Attributes
    name varchar,
    boundary_type varchar,          -- road, river, border, pipeline, transmission_line
    
    -- Geometry Fields
    geometry_wkb blob,              -- WKB encoded LINESTRING/MULTILINESTRING
    geometry_wkt text,
    
    -- Computed Properties
    length_km double,               -- Length in kilometers
    
    -- Endpoints
    start_location_id uuid,         -- Reference to locations table
    end_location_id uuid,           -- Reference to locations table
    start_lon double,
    start_lat double,
    end_lon double,
    end_lat double,
    
    -- Bounding Box (for spatial indexing)
    bbox_min_lon double,
    bbox_min_lat double,
    bbox_max_lon double,
    bbox_max_lat double,
    bbox_geohash varchar,
    
    -- Type-Specific Attributes
    classification varchar,         -- For roads: highway, interstate, local
    surface_type varchar,           -- paved, unpaved, gravel
    width_m double,                 -- Width in meters
    lanes int,                      -- Number of lanes (for roads)
    speed_limit_kmh int,            -- Speed limit (for roads)
    capacity double,                -- Flow capacity (for pipelines/rivers)
    
    -- Temporal Fields
    created_at timestamp,
    updated_at timestamp,
    construction_date date,
    
    -- Metadata
    attributes map<text, text>,
    tags set<text>
) WITH 
    compression = {'class': 'LZ4Compressor'}
    AND compaction = {
        'class': 'SizeTieredCompactionStrategy'
    }
    AND comment = 'Linear geographic features';

-- Secondary Indexes
CREATE INDEX IF NOT EXISTS idx_boundaries_type ON boundaries(boundary_type);
CREATE INDEX IF NOT EXISTS idx_boundaries_classification ON boundaries(classification);
CREATE INDEX IF NOT EXISTS idx_boundaries_bbox_geohash ON boundaries(bbox_geohash);

-- ============================================================================
-- TABLE: routes
-- Purpose: Planned or historical paths (delivery routes, flight paths)
-- Geometry: LINESTRING
-- Index Strategy: Temporal + spatial composite
-- Partitioning: By route_type for better distribution
-- Expected Volume: 10M-100M records
-- ============================================================================

CREATE TABLE IF NOT EXISTS routes (
    -- Composite Primary Key
    route_type varchar,             -- Partition key: delivery, flight, maritime, rail
    start_time timestamp,           -- Clustering key 1
    route_id uuid,                  -- Clustering key 2
    
    -- Core Attributes
    name varchar,
    
    -- Geometry Fields
    geometry_wkb blob,              -- WKB encoded LINESTRING
    geometry_wkt text,
    
    -- Temporal Fields
    end_time timestamp,
    
    -- Computed Properties
    distance_km double,
    duration_seconds int,
    avg_speed_kmh double,
    
    -- Associated Entities
    vehicle_id uuid,                -- Asset performing the route
    driver_id uuid,
    operator_id uuid,
    
    -- Waypoints
    waypoints_wkb list<blob>,       -- List of WKB encoded POINTs
    waypoint_count int,
    
    -- Route Status
    status varchar,                 -- planned, in_progress, completed, cancelled
    completion_percentage int,
    
    -- Cost/Performance Metrics
    fuel_consumed_liters double,
    distance_to_planned_km double,  -- Deviation from planned route
    delays_minutes int,
    
    -- Temporal Fields
    created_at timestamp,
    updated_at timestamp,
    
    -- Metadata
    attributes map<text, text>,
    tags set<text>,
    
    PRIMARY KEY ((route_type), start_time, route_id)
) WITH CLUSTERING ORDER BY (start_time DESC, route_id ASC)
    AND compression = {'class': 'LZ4Compressor'}
    AND compaction = {
        'class': 'TimeWindowCompactionStrategy',
        'compaction_window_size': 1,
        'compaction_window_unit': 'DAYS'
    }
    AND default_time_to_live = 15552000  -- 180 days
    AND comment = 'Planned and historical routes';

-- Secondary Indexes
CREATE INDEX IF NOT EXISTS idx_routes_vehicle ON routes(vehicle_id);
CREATE INDEX IF NOT EXISTS idx_routes_status ON routes(status);
CREATE INDEX IF NOT EXISTS idx_routes_driver ON routes(driver_id);

-- ============================================================================
-- TABLE: events
-- Purpose: Time-stamped geographic events (accidents, sensor readings, alerts)
-- Geometry: POINT
-- Index Strategy: Temporal-first with spatial secondary
-- Partitioning: By date for time-series workloads
-- Expected Volume: 100M-1B+ records (high volume)
-- ============================================================================

CREATE TABLE IF NOT EXISTS events (
    -- Composite Primary Key
    event_date date,                -- Partition key (YYYYMMDD)
    event_time timestamp,           -- Clustering key 1
    event_id uuid,                  -- Clustering key 2
    
    -- Core Attributes
    event_type varchar,             -- accident, sensor_reading, alert, transaction
    
    -- Geometry Fields
    geometry_wkb blob,              -- WKB encoded POINT
    longitude double,
    latitude double,
    geohash varchar,
    
    -- Event Severity/Priority
    severity varchar,               -- low, medium, high, critical
    priority int,                   -- 1-5
    
    -- Associated Entities
    location_id uuid,               -- Reference to locations
    asset_id uuid,                  -- Reference to assets
    region_id uuid,                 -- Reference to regions
    
    -- Event Details
    source varchar,                 -- Data source/sensor ID
    value double,                   -- Numeric measurement
    unit varchar,                   -- Measurement unit
    description varchar,
    
    -- Status
    status varchar,                 -- open, acknowledged, resolved, closed
    resolved_at timestamp,
    resolved_by varchar,
    
    -- Temporal Fields
    created_at timestamp,
    
    -- Metadata
    attributes map<text, text>,
    tags set<text>,
    
    PRIMARY KEY ((event_date), event_time, event_id)
) WITH CLUSTERING ORDER BY (event_time DESC, event_id ASC)
    AND compression = {'class': 'LZ4Compressor'}
    AND compaction = {
        'class': 'TimeWindowCompactionStrategy',
        'compaction_window_size': 1,
        'compaction_window_unit': 'DAYS'
    }
    AND default_time_to_live = 7776000  -- 90 days
    AND comment = 'Time-stamped geospatial events';

-- Secondary Indexes
CREATE INDEX IF NOT EXISTS idx_events_type ON events(event_type);
CREATE INDEX IF NOT EXISTS idx_events_severity ON events(severity);
CREATE INDEX IF NOT EXISTS idx_events_asset ON events(asset_id);
CREATE INDEX IF NOT EXISTS idx_events_geohash ON events(geohash);
CREATE INDEX IF NOT EXISTS idx_events_status ON events(status);

-- Materialized View: Recent Critical Events
CREATE MATERIALIZED VIEW IF NOT EXISTS events_critical AS
    SELECT event_date, event_time, event_id, event_type, severity,
           longitude, latitude, geohash, description, status
    FROM events
    WHERE event_date IS NOT NULL 
      AND event_time IS NOT NULL 
      AND event_id IS NOT NULL
      AND severity IS NOT NULL
    PRIMARY KEY ((severity), event_date, event_time, event_id)
    WITH CLUSTERING ORDER BY (event_date DESC, event_time DESC, event_id ASC);

-- ============================================================================
-- TABLE: assets
-- Purpose: Track vehicles, drones, ships, IoT devices (current state)
-- Geometry: POINT (current location)
-- Index Strategy: Temporal + spatial for moving objects
-- Expected Volume: 100K-10M records
-- ============================================================================

CREATE TABLE IF NOT EXISTS assets (
    -- Primary Key
    asset_id uuid PRIMARY KEY,
    
    -- Core Attributes
    asset_name varchar,
    asset_type varchar,             -- vehicle, drone, ship, sensor, device
    
    -- Current Location (POINT)
    current_geometry_wkb blob,      -- Current position
    current_lon double,
    current_lat double,
    current_geohash varchar,
    
    -- Temporal
    last_updated timestamp,         -- Last position update
    
    -- Motion State
    speed_kmh double,               -- Current speed
    heading_degrees double,         -- Direction (0-360)
    altitude_m double,              -- Altitude/elevation
    
    -- Operational Status
    status varchar,                 -- active, inactive, maintenance, offline
    
    -- Ownership
    owner_id uuid,
    operator_id uuid,
    organization varchar,
    
    -- Recent Trajectory (optional, for visualization)
    trajectory_wkb blob,            -- WKB LINESTRING of recent positions
    trajectory_point_count int,
    
    -- Geofencing
    geofence_id uuid,               -- Current geofence
    geofence_status varchar,        -- inside, outside, boundary
    
    -- Device Info
    device_model varchar,
    firmware_version varchar,
    battery_level double,           -- 0-100%
    signal_strength int,            -- -120 to 0 dBm
    
    -- Temporal Fields
    created_at timestamp,           -- Asset registration time
    last_maintenance timestamp,
    next_maintenance timestamp,
    
    -- Metadata
    attributes map<text, text>,
    tags set<text>,
    
    -- Statistics
    total_distance_km double,
    total_operating_hours double
) WITH 
    compression = {'class': 'LZ4Compressor'}
    AND compaction = {
        'class': 'LeveledCompactionStrategy'
    }
    AND comment = 'Moving and static assets (current state)';

-- Secondary Indexes
CREATE INDEX IF NOT EXISTS idx_assets_type ON assets(asset_type);
CREATE INDEX IF NOT EXISTS idx_assets_status ON assets(status);
CREATE INDEX IF NOT EXISTS idx_assets_owner ON assets(owner_id);
CREATE INDEX IF NOT EXISTS idx_assets_geohash ON assets(current_geohash);
CREATE INDEX IF NOT EXISTS idx_assets_geofence ON assets(geofence_id);

-- Materialized View: Active Assets by Type
CREATE MATERIALIZED VIEW IF NOT EXISTS assets_by_type_updated AS
    SELECT asset_id, asset_name, asset_type, current_lon, current_lat,
           current_geohash, last_updated, status, speed_kmh, heading_degrees
    FROM assets
    WHERE asset_type IS NOT NULL 
      AND last_updated IS NOT NULL 
      AND asset_id IS NOT NULL
    PRIMARY KEY ((asset_type), last_updated, asset_id)
    WITH CLUSTERING ORDER BY (last_updated DESC, asset_id ASC);

-- ============================================================================
-- TABLE: asset_history
-- Purpose: Historical positions for trajectory analysis
-- Geometry: POINT
-- Index Strategy: Composite (asset_id + recorded_at)
-- Partitioning: By asset_id and time_bucket
-- Expected Volume: 1B+ records (very high volume)
-- ============================================================================

CREATE TABLE IF NOT EXISTS asset_history (
    -- Composite Primary Key
    asset_id uuid,                  -- Partition key
    time_bucket date,               -- Partition key (for time bucketing)
    recorded_at timestamp,          -- Clustering key 1
    history_id uuid,                -- Clustering key 2
    
    -- Geometry Fields
    geometry_wkb blob,              -- WKB encoded POINT
    longitude double,
    latitude double,
    geohash varchar,
    
    -- Motion State
    speed_kmh double,
    heading_degrees double,
    altitude_m double,
    
    -- Accuracy
    accuracy_m double,              -- GPS accuracy in meters
    hdop double,                    -- Horizontal dilution of precision
    satellite_count int,
    
    -- Data Source
    source varchar,                 -- GPS, cellular, wifi, manual
    source_device_id varchar,
    
    -- Context
    activity varchar,               -- driving, stationary, walking
    
    -- Metadata
    attributes map<text, text>,
    
    PRIMARY KEY ((asset_id, time_bucket), recorded_at, history_id)
) WITH CLUSTERING ORDER BY (recorded_at DESC, history_id ASC)
    AND compression = {'class': 'LZ4Compressor'}
    AND compaction = {
        'class': 'TimeWindowCompactionStrategy',
        'compaction_window_size': 1,
        'compaction_window_unit': 'DAYS'
    }
    AND default_time_to_live = 15552000  -- 180 days
    AND comment = 'Historical asset positions for trajectory analysis';

-- Secondary Index
CREATE INDEX IF NOT EXISTS idx_asset_history_geohash ON asset_history(geohash);

-- ============================================================================
-- TABLE: geofences
-- Purpose: Virtual boundaries for alerting and zone management
-- Geometry: POLYGON, MULTIPOLYGON
-- Index Strategy: XZ3 for polygon queries
-- Expected Volume: 10K-100K records
-- ============================================================================

CREATE TABLE IF NOT EXISTS geofences (
    -- Primary Key
    geofence_id uuid PRIMARY KEY,
    
    -- Core Attributes
    name varchar,
    description text,
    
    -- Geometry Fields
    geometry_wkb blob,              -- WKB encoded POLYGON/MULTIPOLYGON
    geometry_wkt text,
    
    -- Geofence Type
    geofence_type varchar,          -- restricted, monitored, safe_zone, custom
    
    -- Trigger Configuration
    active boolean,
    trigger_on_enter boolean,
    trigger_on_exit boolean,
    trigger_on_dwell boolean,
    dwell_time_seconds int,
    
    -- Buffer Zone
    buffer_m double,                -- Buffer distance in meters
    
    -- Temporal Validity
    valid_from timestamp,
    valid_until timestamp,
    
    -- Ownership
    owner_id uuid,
    organization varchar,
    
    -- Computed Properties
    area_sq_km double,
    perimeter_km double,
    centroid_lon double,
    centroid_lat double,
    centroid_geohash varchar,
    
    -- Alert Configuration
    alert_email set<text>,
    alert_sms set<text>,
    alert_webhook varchar,
    
    -- Temporal Fields
    created_at timestamp,
    updated_at timestamp,
    
    -- Metadata
    attributes map<text, text>,
    tags set<text>,
    
    -- Statistics
    entry_count counter,            -- Counter for entries
    exit_count counter              -- Counter for exits
) WITH 
    compression = {'class': 'LZ4Compressor'}
    AND compaction = {
        'class': 'LeveledCompactionStrategy'
    }
    AND comment = 'Virtual boundaries for geofencing';

-- Secondary Indexes
CREATE INDEX IF NOT EXISTS idx_geofences_type ON geofences(geofence_type);
CREATE INDEX IF NOT EXISTS idx_geofences_active ON geofences(active);
CREATE INDEX IF NOT EXISTS idx_geofences_owner ON geofences(owner_id);
CREATE INDEX IF NOT EXISTS idx_geofences_centroid_geohash ON geofences(centroid_geohash);

-- Materialized View: Active Geofences
CREATE MATERIALIZED VIEW IF NOT EXISTS geofences_active AS
    SELECT geofence_id, name, geofence_type, geometry_wkb,
           centroid_lon, centroid_lat, trigger_on_enter, trigger_on_exit,
           valid_from, valid_until
    FROM geofences
    WHERE active IS NOT NULL 
      AND geofence_id IS NOT NULL 
      AND active = true
    PRIMARY KEY (active, geofence_id);

-- ============================================================================
-- TABLE: raster_metadata
-- Purpose: Catalog for external raster data (satellite imagery, elevation)
-- Geometry: POLYGON (bounding box)
-- Expected Volume: 10K-100K records
-- ============================================================================

CREATE TABLE IF NOT EXISTS raster_metadata (
    -- Primary Key
    raster_id uuid PRIMARY KEY,
    
    -- Core Attributes
    name varchar,
    description text,
    raster_type varchar,            -- imagery, dem, landcover, temperature
    
    -- Spatial Extent
    bounds_wkb blob,                -- WKB encoded POLYGON (bounding box)
    bounds_wkt text,
    centroid_lon double,
    centroid_lat double,
    centroid_geohash varchar,
    
    -- Raster Properties
    resolution_m double,            -- Spatial resolution in meters
    pixel_width int,
    pixel_height int,
    bands int,                      -- Number of spectral bands
    bit_depth int,
    
    -- Coordinate System
    crs varchar,                    -- e.g., EPSG:4326, EPSG:3857
    
    -- File Storage
    file_path varchar,              -- S3, GCS, HDFS path
    file_format varchar,            -- GeoTIFF, HDF5, NetCDF
    file_size_mb double,
    compression varchar,
    
    -- Temporal Information
    acquisition_date timestamp,
    processing_date timestamp,
    
    -- Data Source
    source varchar,                 -- Landsat, Sentinel, SRTM
    provider varchar,
    license varchar,
    
    -- Quality Metrics
    cloud_cover_percentage double,
    data_quality_score double,
    
    -- Temporal Fields
    created_at timestamp,
    updated_at timestamp,
    
    -- Metadata
    attributes map<text, text>,
    tags set<text>
) WITH 
    compression = {'class': 'LZ4Compressor'}
    AND compaction = {
        'class': 'LeveledCompactionStrategy'
    }
    AND comment = 'Catalog for external raster datasets';

-- Secondary Indexes
CREATE INDEX IF NOT EXISTS idx_raster_type ON raster_metadata(raster_type);
CREATE INDEX IF NOT EXISTS idx_raster_source ON raster_metadata(source);
CREATE INDEX IF NOT EXISTS idx_raster_centroid_geohash ON raster_metadata(centroid_geohash);

-- ============================================================================
-- LOOKUP TABLES
-- ============================================================================

-- Location Types Lookup
CREATE TABLE IF NOT EXISTS location_types (
    type_code varchar PRIMARY KEY,
    type_name varchar,
    category varchar,
    icon_url varchar,
    description text
);

-- Event Types Lookup
CREATE TABLE IF NOT EXISTS event_types (
    type_code varchar PRIMARY KEY,
    type_name varchar,
    category varchar,
    default_severity varchar,
    retention_days int
);

-- ============================================================================
-- GEOMESA CONFIGURATION
-- ============================================================================

-- After creating tables in Cassandra, configure GeoMesa SimpleFeatureTypes:
--
-- 1. LOCATIONS (XZ2 index for points):
-- geomesa-cassandra create-schema \
--   --contact-point localhost:9042 \
--   --keyspace geospatial_db \
--   --catalog geospatial_catalog \
--   --feature-name locations \
--   --spec "location_id:UUID:index=true,\
--           *geometry:Point:srid=4326,\
--           name:String:index=true,\
--           location_type:String:index=true,\
--           city:String:index=true,\
--           country:String:index=true,\
--           elevation_m:Double,\
--           created_at:Date:index=true"
--
-- 2. REGIONS (XZ2 index for polygons):
-- geomesa-cassandra create-schema \
--   --contact-point localhost:9042 \
--   --keyspace geospatial_db \
--   --catalog geospatial_catalog \
--   --feature-name regions \
--   --spec "region_id:UUID:index=true,\
--           *geometry:MultiPolygon:srid=4326,\
--           name:String:index=true,\
--           region_type:String:index=true,\
--           admin_level:Integer:index=true,\
--           area_sq_km:Double"
--
-- 3. EVENTS (XZ3 index for spatio-temporal):
-- geomesa-cassandra create-schema \
--   --contact-point localhost:9042 \
--   --keyspace geospatial_db \
--   --catalog geospatial_catalog \
--   --feature-name events \
--   --spec "event_id:UUID:index=true,\
--           *geometry:Point:srid=4326,\
--           event_type:String:index=true,\
--           event_time:Date:index=true,\
--           severity:String:index=true"
--
-- Configure geomesa-site.xml:
-- <property>
--   <name>geomesa.indices.enabled</name>
--   <value>id,z2,z3,xz2,xz3,attr</value>
-- </property>
-- <property>
--   <name>geomesa.xz2.resolution.bits</name>
--   <value>40</value>
-- </property>

-- ============================================================================
-- EXAMPLE QUERIES
-- ============================================================================

-- Query locations by city
-- SELECT * FROM locations WHERE city = 'New York' ALLOW FILTERING;

-- Query locations by geohash prefix (spatial)
-- SELECT * FROM locations_by_geohash 
-- WHERE geohash >= 'dr5ru' AND geohash < 'dr5rv';

-- Query events for a specific date
-- SELECT * FROM events 
-- WHERE event_date = '2025-01-15'
-- ORDER BY event_time DESC
-- LIMIT 100;

-- Query asset history for a specific asset
-- SELECT * FROM asset_history 
-- WHERE asset_id = ? AND time_bucket = '2025-01-15'
-- ORDER BY recorded_at DESC 
-- LIMIT 1000;

-- Query active assets by type
-- SELECT * FROM assets_by_type_updated
-- WHERE asset_type = 'vehicle'
-- ORDER BY last_updated DESC
-- LIMIT 50;

-- Find routes for today
-- SELECT * FROM routes
-- WHERE route_type = 'delivery'
--   AND start_time >= '2025-01-15 00:00:00'
--   AND start_time < '2025-01-16 00:00:00';

-- ============================================================================
-- MAINTENANCE OPERATIONS
-- ============================================================================

-- Repair table
-- nodetool repair geospatial_db locations

-- Compact table
-- nodetool compact geospatial_db locations

-- View table statistics
-- nodetool tablestats geospatial_db.locations

-- Clear cache
-- nodetool clearsnapshot geospatial_db

-- ============================================================================
-- END OF SCHEMA
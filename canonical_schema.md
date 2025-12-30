# Canonical Geospatial Schema Definition

## Overview
This schema supports location intelligence across distributed geospatial databases. All geometries use **WGS84 (EPSG:4326)** coordinate reference system.

---

## Entity 1: LOCATIONS

**Purpose**: Store point-based geographic entities (POIs, sensors, facilities)

### Fields

| Field | Type | Description | Constraints |
|-------|------|-------------|-------------|
| location_id | UUID | Primary key | NOT NULL, UNIQUE |
| name | String(255) | Location name | NOT NULL |
| location_type | String(50) | Category (POI, sensor, facility) | NOT NULL |
| geometry | POINT | Geographic coordinates | NOT NULL |
| address | String(500) | Full address | NULLABLE |
| city | String(100) | City name | INDEXED |
| country | String(100) | Country name | INDEXED |
| postal_code | String(20) | ZIP/postal code | INDEXED |
| elevation_m | Double | Elevation in meters | NULLABLE |
| created_at | Timestamp | Record creation time | NOT NULL |
| updated_at | Timestamp | Last update time | NOT NULL |
| attributes | JSON/Map | Custom metadata | NULLABLE |

**Geometry Type**: POINT  
**Storage Format**: WKB (binary), WKT (text), GeoJSON (interchange)  
**Indexing Strategy**: GeoHash (precision 8-12), Z-order curve  
**Typical Use Cases**: Store locations, nearest-neighbor search, radius queries

---

## Entity 2: REGIONS

**Purpose**: Administrative boundaries, service areas, coverage zones

### Fields

| Field | Type | Description | Constraints |
|-------|------|-------------|-------------|
| region_id | UUID | Primary key | NOT NULL, UNIQUE |
| name | String(255) | Region name | NOT NULL |
| region_type | String(50) | Type (admin, service, coverage) | NOT NULL |
| geometry | POLYGON/MULTIPOLYGON | Boundary geometry | NOT NULL |
| parent_region_id | UUID | Hierarchical parent | NULLABLE, FK |
| area_sq_km | Double | Area in square kilometers | COMPUTED |
| perimeter_km | Double | Perimeter in kilometers | COMPUTED |
| centroid | POINT | Geometric center | COMPUTED |
| population | Integer | Population count | NULLABLE |
| admin_level | Integer | Administrative level (1-10) | NULLABLE |
| iso_code | String(10) | ISO country/region code | INDEXED |
| created_at | Timestamp | Record creation time | NOT NULL |
| updated_at | Timestamp | Last update time | NOT NULL |
| attributes | JSON/Map | Custom metadata | NULLABLE |

**Geometry Type**: POLYGON, MULTIPOLYGON  
**Storage Format**: WKB, EWKB (with SRID)  
**Indexing Strategy**: XZ2/XZ3 (hierarchical), S2 cells  
**Typical Use Cases**: Point-in-polygon queries, spatial joins, containment tests

---

## Entity 3: BOUNDARIES

**Purpose**: Linear geographic features (roads, rivers, borders, pipelines)

### Fields

| Field | Type | Description | Constraints |
|-------|------|-------------|-------------|
| boundary_id | UUID | Primary key | NOT NULL, UNIQUE |
| name | String(255) | Boundary name | NOT NULL |
| boundary_type | String(50) | Type (road, river, border, pipeline) | NOT NULL |
| geometry | LINESTRING/MULTILINESTRING | Linear geometry | NOT NULL |
| length_km | Double | Length in kilometers | COMPUTED |
| start_location_id | UUID | Start point reference | NULLABLE, FK |
| end_location_id | UUID | End point reference | NULLABLE, FK |
| classification | String(50) | Classification (highway, interstate) | INDEXED |
| surface_type | String(50) | Surface material | NULLABLE |
| width_m | Double | Width in meters | NULLABLE |
| created_at | Timestamp | Record creation time | NOT NULL |
| updated_at | Timestamp | Last update time | NOT NULL |
| attributes | JSON/Map | Custom metadata | NULLABLE |

**Geometry Type**: LINESTRING, MULTILINESTRING  
**Storage Format**: WKB, WKT  
**Indexing Strategy**: GeoHash (bounding box), XZ2  
**Typical Use Cases**: Routing, network analysis, proximity to linear features

---

## Entity 4: ROUTES

**Purpose**: Planned or historical paths (delivery routes, flight paths, trajectories)

### Fields

| Field | Type | Description | Constraints |
|-------|------|-------------|-------------|
| route_id | UUID | Primary key | NOT NULL, UNIQUE |
| name | String(255) | Route name | NOT NULL |
| route_type | String(50) | Type (delivery, flight, trajectory) | NOT NULL |
| geometry | LINESTRING | Route path | NOT NULL |
| start_time | Timestamp | Planned/actual start time | NOT NULL |
| end_time | Timestamp | Planned/actual end time | NULLABLE |
| distance_km | Double | Total distance | COMPUTED |
| duration_seconds | Integer | Travel duration | COMPUTED |
| vehicle_id | UUID | Associated vehicle/asset | NULLABLE, FK |
| driver_id | UUID | Associated driver | NULLABLE, FK |
| waypoints | Array<POINT> | Intermediate stops | NULLABLE |
| status | String(20) | Status (planned, active, completed) | NOT NULL |
| created_at | Timestamp | Record creation time | NOT NULL |
| updated_at | Timestamp | Last update time | NOT NULL |
| attributes | JSON/Map | Custom metadata | NULLABLE |

**Geometry Type**: LINESTRING  
**Storage Format**: WKB, GeoJSON  
**Indexing Strategy**: Temporal + spatial composite (time-series optimized)  
**Typical Use Cases**: Route optimization, historical path analysis, ETA calculation

---

## Entity 5: EVENTS (Spatio-Temporal)

**Purpose**: Time-stamped geographic events (accidents, sensor readings, transactions)

### Fields

| Field | Type | Description | Constraints |
|-------|------|-------------|-------------|
| event_id | UUID | Primary key | NOT NULL, UNIQUE |
| event_type | String(50) | Event category | NOT NULL, INDEXED |
| geometry | POINT | Event location | NOT NULL |
| event_time | Timestamp | Event occurrence time | NOT NULL, INDEXED |
| severity | String(20) | Severity (low, medium, high, critical) | INDEXED |
| location_id | UUID | Associated location | NULLABLE, FK |
| asset_id | UUID | Associated asset | NULLABLE, FK |
| source | String(100) | Data source | NOT NULL |
| value | Double | Numeric measurement | NULLABLE |
| unit | String(20) | Measurement unit | NULLABLE |
| description | String(1000) | Event description | NULLABLE |
| created_at | Timestamp | Record creation time | NOT NULL |
| attributes | JSON/Map | Custom metadata | NULLABLE |

**Geometry Type**: POINT  
**Storage Format**: WKB  
**Indexing Strategy**: Temporal-first with spatial secondary (time-series databases)  
**Partitioning**: By event_time (daily/hourly)  
**Typical Use Cases**: Real-time event detection, temporal analysis, anomaly detection

---

## Entity 6: ASSETS (Moving + Static)

**Purpose**: Track vehicles, drones, ships, IoT devices with location history

### Fields

| Field | Type | Description | Constraints |
|-------|------|-------------|-------------|
| asset_id | UUID | Primary key | NOT NULL, UNIQUE |
| asset_name | String(255) | Asset identifier | NOT NULL |
| asset_type | String(50) | Type (vehicle, drone, ship, sensor) | NOT NULL, INDEXED |
| current_geometry | POINT | Current location | NOT NULL |
| last_updated | Timestamp | Last position update | NOT NULL, INDEXED |
| speed_kmh | Double | Current speed (km/h) | NULLABLE |
| heading_degrees | Double | Direction (0-360) | NULLABLE |
| altitude_m | Double | Altitude in meters | NULLABLE |
| status | String(20) | Operational status | NOT NULL |
| owner_id | UUID | Owner/operator ID | INDEXED |
| trajectory | LINESTRING | Recent path (last N positions) | NULLABLE |
| geofence_id | UUID | Current geofence | NULLABLE, FK |
| battery_level | Double | Battery percentage (0-100) | NULLABLE |
| created_at | Timestamp | Asset registration time | NOT NULL |
| attributes | JSON/Map | Custom metadata | NULLABLE |

**Geometry Type**: POINT (current), LINESTRING (trajectory)  
**Storage Format**: WKB  
**Indexing Strategy**: Temporal + spatial, optimized for moving objects  
**Partitioning**: By last_updated (time-series)  
**Typical Use Cases**: Fleet tracking, asset monitoring, predictive maintenance

---

## Entity 7: ASSET_HISTORY (Trajectory Tracking)

**Purpose**: Historical positions for trajectory analysis

### Fields

| Field | Type | Description | Constraints |
|-------|------|-------------|-------------|
| history_id | UUID | Primary key | NOT NULL, UNIQUE |
| asset_id | UUID | Foreign key to ASSETS | NOT NULL, INDEXED |
| geometry | POINT | Historical position | NOT NULL |
| recorded_at | Timestamp | Position timestamp | NOT NULL, INDEXED |
| speed_kmh | Double | Speed at time | NULLABLE |
| heading_degrees | Double | Heading at time | NULLABLE |
| altitude_m | Double | Altitude at time | NULLABLE |
| accuracy_m | Double | GPS accuracy in meters | NULLABLE |
| source | String(50) | Data source (GPS, cellular, wifi) | NULLABLE |
| attributes | JSON/Map | Custom metadata | NULLABLE |

**Geometry Type**: POINT  
**Storage Format**: WKB  
**Indexing Strategy**: Composite (asset_id + recorded_at), spatial index  
**Partitioning**: By recorded_at (hourly/daily)  
**Typical Use Cases**: Trajectory reconstruction, movement pattern analysis

---

## Entity 8: GEOFENCES

**Purpose**: Virtual boundaries for alerting and zone management

### Fields

| Field | Type | Description | Constraints |
|-------|------|-------------|-------------|
| geofence_id | UUID | Primary key | NOT NULL, UNIQUE |
| name | String(255) | Geofence name | NOT NULL |
| geometry | POLYGON/MULTIPOLYGON | Boundary | NOT NULL |
| geofence_type | String(50) | Type (restricted, monitored, safe) | NOT NULL |
| active | Boolean | Active status | NOT NULL, DEFAULT true |
| trigger_on_enter | Boolean | Alert on entry | DEFAULT false |
| trigger_on_exit | Boolean | Alert on exit | DEFAULT false |
| buffer_m | Double | Buffer zone in meters | DEFAULT 0 |
| valid_from | Timestamp | Activation time | NOT NULL |
| valid_until | Timestamp | Expiration time | NULLABLE |
| owner_id | UUID | Owner ID | INDEXED |
| created_at | Timestamp | Creation time | NOT NULL |
| attributes | JSON/Map | Custom metadata | NULLABLE |

**Geometry Type**: POLYGON, MULTIPOLYGON  
**Storage Format**: WKB  
**Indexing Strategy**: XZ3 (for polygon queries)  
**Typical Use Cases**: Geofence violation detection, zone monitoring

---

## Entity 9: RASTER_METADATA

**Purpose**: Reference external raster data (satellite imagery, elevation models)

### Fields

| Field | Type | Description | Constraints |
|-------|------|-------------|-------------|
| raster_id | UUID | Primary key | NOT NULL, UNIQUE |
| name | String(255) | Raster dataset name | NOT NULL |
| raster_type | String(50) | Type (imagery, DEM, landcover) | NOT NULL |
| bounds | POLYGON | Bounding box | NOT NULL |
| centroid | POINT | Center point | COMPUTED |
| resolution_m | Double | Spatial resolution (meters) | NOT NULL |
| bands | Integer | Number of bands | NOT NULL |
| crs | String(50) | Coordinate reference system | NOT NULL |
| file_path | String(1000) | Storage location (S3, GCS, HDFS) | NOT NULL |
| file_size_mb | Double | File size | NULLABLE |
| acquisition_date | Timestamp | Data capture date | NULLABLE |
| source | String(100) | Data provider | NOT NULL |
| created_at | Timestamp | Metadata creation time | NOT NULL |
| attributes | JSON/Map | Custom metadata | NULLABLE |

**Geometry Type**: POLYGON (bounds), POINT (centroid)  
**Storage Format**: WKB (bounds only, raster stored externally)  
**Indexing Strategy**: Spatial index on bounds  
**Typical Use Cases**: Raster catalog, imagery search, tile serving

---

## Spatial Indexing Strategy Summary

| Entity | Primary Index | Secondary Index | Partitioning |
|--------|---------------|-----------------|--------------|
| LOCATIONS | GeoHash-8 | Z-order | By city/country |
| REGIONS | XZ2/XZ3 | Hilbert curve | By admin_level |
| BOUNDARIES | GeoHash-10 (bbox) | Linear referencing | By type |
| ROUTES | Temporal + GeoHash | XZ2 | By start_time (daily) |
| EVENTS | Temporal-first | Spatial secondary | By event_time (hourly) |
| ASSETS | Temporal + Spatial | H3/S2 cells | By last_updated |
| ASSET_HISTORY | Composite (asset_id, time) | Spatial | By recorded_at (hourly) |
| GEOFENCES | XZ3 | S2 covering | By active status |
| RASTER_METADATA | Spatial (bounds) | None | By raster_type |

---

## H3, S2, and GeoHash Compatibility

All entities support hierarchical spatial indexing:

- **H3 Hexagons**: Resolutions 0-15 for uniform tessellation
- **S2 Cells**: Levels 0-30 for adaptive quadtree indexing
- **GeoHash**: 1-12 character precision for legacy compatibility

Conversion functions available in all engines for cross-system interoperability.

---

## CRS and Datum Information

- **Primary CRS**: WGS84 (EPSG:4326)
- **Storage Format**: Longitude, Latitude (X, Y)
- **Elevation Reference**: EGM96 geoid (where applicable)
- **Supported Transforms**: Web Mercator (EPSG:3857) for visualization

---

## Storage Format Standards

- **Binary**: WKB (Well-Known Binary), EWKB (Extended WKB with SRID)
- **Text**: WKT (Well-Known Text), EWKT (Extended WKT)
- **Interchange**: GeoJSON (RFC 7946), GML, KML
- **Compression**: GZIP for text formats, native compression for binary

---

This canonical schema provides a foundation for implementing location intelligence across all three database engines while maintaining semantic consistency and interoperability.
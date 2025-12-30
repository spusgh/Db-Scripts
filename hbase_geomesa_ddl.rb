# ============================================================================
# HBASE + GEOMESA COMPLETE SCHEMA
# Production-Ready Geospatial Database Schema
# Version: 1.0.0
# CRS: WGS84 (EPSG:4326)
# HBase: 2.4+
# GeoMesa: 5.0+
# ============================================================================
# 
# USAGE:
# 1. Start HBase shell: hbase shell
# 2. Execute this file: load '/path/to/hbase_geomesa_schema.rb'
# 3. Or copy-paste commands directly into HBase shell
#
# For GeoMesa integration:
# geomesa-hbase create-schema \
#   --zookeeper localhost:2181 \
#   --catalog geospatial_db \
#   --feature-name locations \
#   --spec "location_id:UUID:index=true,*geometry:Point:srid=4326,..."
# ============================================================================

# ============================================================================
# NAMESPACE CREATION
# ============================================================================

puts "Creating namespace: geospatial_db"
create_namespace 'geospatial_db', {'DESCRIPTION' => 'Geospatial database for location intelligence'}

# ============================================================================
# CONFIGURATION CONSTANTS
# ============================================================================

# Compression types: NONE, SNAPPY, LZO, LZ4, ZSTD
COMPRESSION = 'SNAPPY'

# Data block encoding: NONE, PREFIX, DIFF, FAST_DIFF, PREFIX_TREE
DATA_BLOCK_ENCODING = 'FAST_DIFF'

# Bloom filter types: NONE, ROW, ROWCOL
BLOOMFILTER = 'ROW'

# Cache settings
IN_MEMORY = 'false'  # Set to 'true' for frequently accessed small tables

# Replication
REPLICATION_SCOPE = 0  # 0=disabled, 1=enabled

# ============================================================================
# TABLE: locations
# Purpose: Point-based geographic entities (POIs, sensors, facilities)
# Row Key: location_id (UUID as String)
# Expected Volume: 10M-100M records
# ============================================================================

puts "\nCreating table: geospatial_db:locations"

create 'geospatial_db:locations',
  {
    NAME => 'attrs',
    VERSIONS => 1,
    COMPRESSION => COMPRESSION,
    DATA_BLOCK_ENCODING => DATA_BLOCK_ENCODING,
    BLOOMFILTER => BLOOMFILTER,
    IN_MEMORY => IN_MEMORY,
    TTL => 2147483647  # Max value (no expiration)
  },
  {
    NAME => 'geo',
    VERSIONS => 1,
    COMPRESSION => COMPRESSION,
    DATA_BLOCK_ENCODING => DATA_BLOCK_ENCODING,
    BLOOMFILTER => BLOOMFILTER
  },
  {
    NAME => 'meta',
    VERSIONS => 1,
    COMPRESSION => COMPRESSION,
    BLOOMFILTER => BLOOMFILTER
  }

# Column Qualifiers (documentation):
# attrs:name                 - Location name (String)
# attrs:location_type        - Type category (String)
# attrs:address              - Full address (String)
# attrs:city                 - City name (String)
# attrs:state_province       - State/Province (String)
# attrs:country              - Country name (String)
# attrs:postal_code          - ZIP/Postal code (String)
# attrs:elevation_m          - Elevation in meters (Double)
# attrs:phone                - Phone number (String)
# geo:geometry_wkb           - WKB encoded POINT (Bytes)
# geo:longitude              - Longitude coordinate (Double)
# geo:latitude               - Latitude coordinate (Double)
# geo:geohash                - Precomputed GeoHash (String)
# meta:created_at            - Creation timestamp (Long)
# meta:updated_at            - Update timestamp (Long)
# meta:attributes_json       - JSON metadata (String)

alter 'geospatial_db:locations',
  MAX_FILESIZE => '10737418240',           # 10GB
  MEMSTORE_FLUSHSIZE => '134217728',       # 128MB
  REGION_MEMSTORE_REPLICATION => 'true'

# ============================================================================
# TABLE: locations_spatial_index
# Purpose: GeoMesa spatial index for locations (XZ2)
# Row Key: [geohash_prefix][location_id]
# Managed by GeoMesa - created automatically
# ============================================================================

puts "Creating spatial index: geospatial_db:locations_spatial_index"

create 'geospatial_db:locations_spatial_index',
  {
    NAME => 'idx',
    VERSIONS => 1,
    COMPRESSION => COMPRESSION,
    IN_MEMORY => 'true',  # Keep spatial index in memory for performance
    BLOOMFILTER => BLOOMFILTER
  }

# ============================================================================
# TABLE: locations_by_city
# Purpose: Secondary index for city-based queries
# Row Key: [city][location_id]
# ============================================================================

puts "Creating secondary index: geospatial_db:locations_by_city"

create 'geospatial_db:locations_by_city',
  {
    NAME => 'ref',
    VERSIONS => 1,
    COMPRESSION => COMPRESSION,
    BLOOMFILTER => BLOOMFILTER
  }

# Column Qualifiers:
# ref:location_id            - Reference to main table (String)

# ============================================================================
# TABLE: regions
# Purpose: Administrative boundaries, service areas, coverage zones
# Row Key: region_id (UUID as String)
# Expected Volume: 100K-1M records
# ============================================================================

puts "\nCreating table: geospatial_db:regions"

create 'geospatial_db:regions',
  {
    NAME => 'attrs',
    VERSIONS => 1,
    COMPRESSION => COMPRESSION,
    BLOOMFILTER => BLOOMFILTER
  },
  {
    NAME => 'geo',
    VERSIONS => 1,
    COMPRESSION => COMPRESSION,
    DATA_BLOCK_ENCODING => DATA_BLOCK_ENCODING
  },
  {
    NAME => 'hierarchy',
    VERSIONS => 1,
    COMPRESSION => COMPRESSION
  },
  {
    NAME => 'meta',
    VERSIONS => 1,
    COMPRESSION => COMPRESSION
  }

# Column Qualifiers:
# attrs:name                 - Region name (String)
# attrs:region_type          - Type (admin_boundary, service_area, etc.)
# attrs:area_sq_km           - Area in square kilometers (Double)
# attrs:perimeter_km         - Perimeter in kilometers (Double)
# attrs:population           - Population count (Long)
# attrs:admin_level          - Administrative level 1-10 (Integer)
# attrs:iso_code             - ISO country/region code (String)
# geo:geometry_wkb           - WKB encoded POLYGON/MULTIPOLYGON (Bytes)
# geo:centroid_lon           - Centroid longitude (Double)
# geo:centroid_lat           - Centroid latitude (Double)
# geo:centroid_geohash       - Centroid GeoHash (String)
# geo:bbox_min_lon           - Bounding box min longitude (Double)
# geo:bbox_min_lat           - Bounding box min latitude (Double)
# geo:bbox_max_lon           - Bounding box max longitude (Double)
# geo:bbox_max_lat           - Bounding box max latitude (Double)
# hierarchy:parent_region_id - Parent region UUID (String)
# hierarchy:hierarchy_level  - Hierarchy level (Integer)
# meta:created_at            - Creation timestamp (Long)
# meta:updated_at            - Update timestamp (Long)
# meta:attributes_json       - JSON metadata (String)

alter 'geospatial_db:regions',
  MAX_FILESIZE => '21474836480'  # 20GB for large polygons

# ============================================================================
# TABLE: regions_spatial_index
# Purpose: XZ2 hierarchical index for polygons
# ============================================================================

puts "Creating spatial index: geospatial_db:regions_spatial_index"

create 'geospatial_db:regions_spatial_index',
  {
    NAME => 'idx',
    VERSIONS => 1,
    COMPRESSION => COMPRESSION,
    BLOOMFILTER => BLOOMFILTER
  }

# ============================================================================
# TABLE: boundaries
# Purpose: Linear geographic features (roads, rivers, borders)
# Row Key: boundary_id (UUID as String)
# Expected Volume: 1M-10M records
# ============================================================================

puts "\nCreating table: geospatial_db:boundaries"

create 'geospatial_db:boundaries',
  {
    NAME => 'attrs',
    VERSIONS => 1,
    COMPRESSION => COMPRESSION,
    BLOOMFILTER => BLOOMFILTER
  },
  {
    NAME => 'geo',
    VERSIONS => 1,
    COMPRESSION => COMPRESSION,
    DATA_BLOCK_ENCODING => DATA_BLOCK_ENCODING
  },
  {
    NAME => 'props',
    VERSIONS => 1,
    COMPRESSION => COMPRESSION
  },
  {
    NAME => 'meta',
    VERSIONS => 1,
    COMPRESSION => COMPRESSION
  }

# Column Qualifiers:
# attrs:name                 - Boundary name (String)
# attrs:boundary_type        - Type (road, river, border, pipeline)
# attrs:classification       - Classification (highway, interstate, local)
# attrs:surface_type         - Surface material (String)
# attrs:width_m              - Width in meters (Double)
# geo:geometry_wkb           - WKB encoded LINESTRING/MULTILINESTRING (Bytes)
# geo:length_km              - Length in kilometers (Double)
# geo:bbox_min_lon           - Bounding box coordinates (Double)
# geo:bbox_min_lat           - (Double)
# geo:bbox_max_lon           - (Double)
# geo:bbox_max_lat           - (Double)
# geo:bbox_geohash           - Bounding box GeoHash (String)
# props:start_location_id    - Start point reference (String)
# props:end_location_id      - End point reference (String)
# props:lanes                - Number of lanes (Integer)
# props:speed_limit_kmh      - Speed limit (Integer)
# meta:created_at            - Creation timestamp (Long)
# meta:updated_at            - Update timestamp (Long)
# meta:attributes_json       - JSON metadata (String)

# ============================================================================
# TABLE: routes
# Purpose: Planned or historical paths
# Row Key: [route_type][start_time_reversed][route_id]
# Composite key for time-series queries (latest first)
# Expected Volume: 10M-100M records
# ============================================================================

puts "\nCreating table: geospatial_db:routes"

create 'geospatial_db:routes',
  {
    NAME => 'attrs',
    VERSIONS => 1,
    COMPRESSION => COMPRESSION,
    BLOOMFILTER => BLOOMFILTER,
    TTL => 15552000  # 180 days in seconds
  },
  {
    NAME => 'geo',
    VERSIONS => 1,
    COMPRESSION => COMPRESSION,
    DATA_BLOCK_ENCODING => DATA_BLOCK_ENCODING,
    TTL => 15552000
  },
  {
    NAME => 'perf',
    VERSIONS => 1,
    COMPRESSION => COMPRESSION,
    TTL => 15552000
  },
  {
    NAME => 'meta',
    VERSIONS => 1,
    COMPRESSION => COMPRESSION,
    TTL => 15552000
  }

# Row Key Format: 
# [route_type:10 chars][Long.MAX_VALUE - start_time_millis:20 digits][route_id:36 chars]
# Example: "delivery  09223372036854775807550e8400-e29b-41d4-a716-446655440000"
# This allows latest-first scans within each route_type

# Column Qualifiers:
# attrs:name                 - Route name (String)
# attrs:status               - Status (planned, in_progress, completed)
# attrs:vehicle_id           - Associated vehicle UUID (String)
# attrs:driver_id            - Driver UUID (String)
# geo:geometry_wkb           - WKB encoded LINESTRING (Bytes)
# geo:waypoints_json         - JSON array of waypoints (String)
# perf:distance_km           - Total distance (Double)
# perf:duration_seconds      - Duration (Integer)
# perf:avg_speed_kmh         - Average speed (Double)
# perf:fuel_consumed_liters  - Fuel consumption (Double)
# perf:delays_minutes        - Total delays (Integer)
# meta:start_time            - Start timestamp (Long)
# meta:end_time              - End timestamp (Long)
# meta:created_at            - Creation timestamp (Long)
# meta:attributes_json       - JSON metadata (String)

alter 'geospatial_db:routes',
  MAX_FILESIZE => '10737418240'  # 10GB

# ============================================================================
# TABLE: events
# Purpose: Time-stamped geographic events (high volume)
# Row Key: [event_type_hash:2][date:8][timestamp_reversed:20][event_id:36]
# Salted for write distribution across regions
# Expected Volume: 100M-1B+ records
# ============================================================================

puts "\nCreating table: geospatial_db:events"

# Pre-split table into 16 regions (hex digits 0-f) for write distribution
splits = ['10', '20', '30', '40', '50', '60', '70', '80', '90', 
          'a0', 'b0', 'c0', 'd0', 'e0', 'f0']

create 'geospatial_db:events',
  {
    NAME => 'attrs',
    VERSIONS => 1,
    COMPRESSION => COMPRESSION,
    BLOOMFILTER => BLOOMFILTER,
    TTL => 7776000  # 90 days
  },
  {
    NAME => 'geo',
    VERSIONS => 1,
    COMPRESSION => COMPRESSION,
    DATA_BLOCK_ENCODING => DATA_BLOCK_ENCODING,
    IN_MEMORY => 'true',  # Keep recent events in memory
    TTL => 7776000
  },
  {
    NAME => 'details',
    VERSIONS => 1,
    COMPRESSION => COMPRESSION,
    TTL => 7776000
  },
  {
    NAME => 'meta',
    VERSIONS => 1,
    COMPRESSION => COMPRESSION,
    TTL => 7776000
  },
  SPLITS => splits

# Row Key Format:
# [hash(event_type)%16:2][YYYYMMDD:8][Long.MAX_VALUE-timestamp:20][event_id:36]
# Example: "0520250115092233720368547758075event-uuid-here"
# Salt prefix distributes writes across 16 regions

# Column Qualifiers:
# attrs:event_type           - Event category (String)
# attrs:severity             - Severity level (String)
# attrs:priority             - Priority 1-5 (Integer)
# attrs:status               - Status (open, acknowledged, resolved)
# geo:geometry_wkb           - WKB encoded POINT (Bytes)
# geo:longitude              - Longitude (Double)
# geo:latitude               - Latitude (Double)
# geo:geohash                - GeoHash (String)
# details:location_id        - Associated location (String)
# details:asset_id           - Associated asset (String)
# details:source             - Data source (String)
# details:value              - Numeric measurement (Double)
# details:unit               - Measurement unit (String)
# details:description        - Event description (String)
# meta:event_time            - Event timestamp (Long)
# meta:created_at            - Creation timestamp (Long)
# meta:resolved_at           - Resolution timestamp (Long)
# meta:attributes_json       - JSON metadata (String)

alter 'geospatial_db:events',
  REGION_MEMSTORE_REPLICATION => 'true'  # Replicate memstore for durability

# ============================================================================
# TABLE: events_spatial_index
# Purpose: Spatial index for event queries
# ============================================================================

puts "Creating spatial index: geospatial_db:events_spatial_index"

create 'geospatial_db:events_spatial_index',
  {
    NAME => 'idx',
    VERSIONS => 1,
    COMPRESSION => COMPRESSION,
    IN_MEMORY => 'true',
    BLOOMFILTER => BLOOMFILTER
  }

# ============================================================================
# TABLE: assets
# Purpose: Track moving and static assets (current state)
# Row Key: asset_id (UUID as String)
# Expected Volume: 100K-10M records
# ============================================================================

puts "\nCreating table: geospatial_db:assets"

create 'geospatial_db:assets',
  {
    NAME => 'attrs',
    VERSIONS => 1,
    COMPRESSION => COMPRESSION,
    BLOOMFILTER => BLOOMFILTER
  },
  {
    NAME => 'geo',
    VERSIONS => 1,
    COMPRESSION => COMPRESSION,
    DATA_BLOCK_ENCODING => DATA_BLOCK_ENCODING,
    IN_MEMORY => 'true'  # Keep current asset locations in memory
  },
  {
    NAME => 'state',
    VERSIONS => 1,
    COMPRESSION => COMPRESSION
  },
  {
    NAME => 'device',
    VERSIONS => 1,
    COMPRESSION => COMPRESSION
  },
  {
    NAME => 'meta',
    VERSIONS => 1,
    COMPRESSION => COMPRESSION
  }

# Column Qualifiers:
# attrs:asset_name           - Asset identifier (String)
# attrs:asset_type           - Type (vehicle, drone, ship, sensor)
# attrs:status               - Operational status (String)
# attrs:owner_id             - Owner UUID (String)
# attrs:organization         - Organization name (String)
# geo:current_geometry_wkb   - Current position WKB (Bytes)
# geo:current_lon            - Current longitude (Double)
# geo:current_lat            - Current latitude (Double)
# geo:current_geohash        - Current GeoHash (String)
# geo:trajectory_wkb         - Recent path WKB LINESTRING (Bytes)
# state:last_updated         - Last position update (Long)
# state:speed_kmh            - Current speed (Double)
# state:heading_degrees      - Direction 0-360 (Double)
# state:altitude_m           - Altitude in meters (Double)
# state:geofence_id          - Current geofence UUID (String)
# device:device_model        - Device model (String)
# device:firmware_version    - Firmware version (String)
# device:battery_level       - Battery 0-100% (Double)
# device:signal_strength     - Signal strength dBm (Integer)
# meta:created_at            - Asset registration (Long)
# meta:attributes_json       - JSON metadata (String)

alter 'geospatial_db:assets',
  REGION_MEMSTORE_REPLICATION => 'true'

# ============================================================================
# TABLE: assets_by_type
# Purpose: Secondary index for querying assets by type
# Row Key: [asset_type][last_updated_reversed][asset_id]
# ============================================================================

puts "Creating secondary index: geospatial_db:assets_by_type"

create 'geospatial_db:assets_by_type',
  {
    NAME => 'ref',
    VERSIONS => 1,
    COMPRESSION => COMPRESSION,
    BLOOMFILTER => BLOOMFILTER
  }

# Column Qualifiers:
# ref:asset_id               - Reference to main table (String)

# ============================================================================
# TABLE: assets_spatial_index
# Purpose: Spatial index for current asset locations
# ============================================================================

puts "Creating spatial index: geospatial_db:assets_spatial_index"

create 'geospatial_db:assets_spatial_index',
  {
    NAME => 'idx',
    VERSIONS => 1,
    COMPRESSION => COMPRESSION,
    IN_MEMORY => 'true',
    BLOOMFILTER => BLOOMFILTER
  }

# ============================================================================
# TABLE: asset_history
# Purpose: Historical positions for trajectory analysis (very high volume)
# Row Key: [asset_id][time_bucket:YYYYMMDD][timestamp_reversed][history_id]
# Optimized for sequential scans of asset trajectories
# Expected Volume: 1B+ records
# ============================================================================

puts "\nCreating table: geospatial_db:asset_history"

create 'geospatial_db:asset_history',
  {
    NAME => 'pos',
    VERSIONS => 1,
    COMPRESSION => COMPRESSION,
    DATA_BLOCK_ENCODING => DATA_BLOCK_ENCODING,
    TTL => 15552000  # 180 days
  },
  {
    NAME => 'state',
    VERSIONS => 1,
    COMPRESSION => COMPRESSION,
    TTL => 15552000
  },
  {
    NAME => 'meta',
    VERSIONS => 1,
    COMPRESSION => COMPRESSION,
    TTL => 15552000
  }

# Row Key Format:
# [asset_id:36][YYYYMMDD:8][Long.MAX_VALUE-timestamp:20][history_id:36]
# Example: "550e8400-e29b-41d4-a716-44665544000020250115092233720368547758071234-5678..."
# This allows efficient range scans for a specific asset's history

# Column Qualifiers:
# pos:geometry_wkb           - WKB encoded POINT (Bytes)
# pos:longitude              - Longitude (Double)
# pos:latitude               - Latitude (Double)
# pos:geohash                - GeoHash (String)
# state:speed_kmh            - Speed at time (Double)
# state:heading_degrees      - Heading at time (Double)
# state:altitude_m           - Altitude at time (Double)
# state:accuracy_m           - GPS accuracy (Double)
# state:activity             - Activity type (String)
# meta:recorded_at           - Position timestamp (Long)
# meta:source                - Data source (String)
# meta:source_device_id      - Source device (String)
# meta:attributes_json       - JSON metadata (String)

alter 'geospatial_db:asset_history',
  MAX_FILESIZE => '10737418240'  # 10GB

# ============================================================================
# TABLE: asset_history_spatial_index
# Purpose: Spatial queries on historical positions
# ============================================================================

puts "Creating spatial index: geospatial_db:asset_history_spatial_index"

create 'geospatial_db:asset_history_spatial_index',
  {
    NAME => 'idx',
    VERSIONS => 1,
    COMPRESSION => COMPRESSION,
    BLOOMFILTER => BLOOMFILTER
  }

# ============================================================================
# TABLE: geofences
# Purpose: Virtual boundaries for alerting
# Row Key: geofence_id (UUID as String)
# Expected Volume: 10K-100K records
# ============================================================================

puts "\nCreating table: geospatial_db:geofences"

create 'geospatial_db:geofences',
  {
    NAME => 'attrs',
    VERSIONS => 1,
    COMPRESSION => COMPRESSION,
    BLOOMFILTER => BLOOMFILTER
  },
  {
    NAME => 'geo',
    VERSIONS => 1,
    COMPRESSION => COMPRESSION,
    DATA_BLOCK_ENCODING => DATA_BLOCK_ENCODING
  },
  {
    NAME => 'config',
    VERSIONS => 1,
    COMPRESSION => COMPRESSION
  },
  {
    NAME => 'alerts',
    VERSIONS => 1,
    COMPRESSION => COMPRESSION
  },
  {
    NAME => 'meta',
    VERSIONS => 1,
    COMPRESSION => COMPRESSION
  }

# Column Qualifiers:
# attrs:name                 - Geofence name (String)
# attrs:description          - Description (String)
# attrs:geofence_type        - Type (restricted, monitored, safe_zone)
# attrs:owner_id             - Owner UUID (String)
# geo:geometry_wkb           - WKB encoded POLYGON/MULTIPOLYGON (Bytes)
# geo:area_sq_km             - Area in square kilometers (Double)
# geo:centroid_lon           - Centroid longitude (Double)
# geo:centroid_lat           - Centroid latitude (Double)
# geo:centroid_geohash       - Centroid GeoHash (String)
# geo:s2_covering_json       - JSON array of S2 cell IDs (String)
# config:active              - Active status (Boolean)
# config:trigger_on_enter    - Trigger on entry (Boolean)
# config:trigger_on_exit     - Trigger on exit (Boolean)
# config:buffer_m            - Buffer in meters (Double)
# config:valid_from          - Validity start (Long)
# config:valid_until         - Validity end (Long)
# alerts:alert_email_json    - JSON array of emails (String)
# alerts:alert_webhook       - Webhook URL (String)
# meta:created_at            - Creation timestamp (Long)
# meta:updated_at            - Update timestamp (Long)
# meta:attributes_json       - JSON metadata (String)

# ============================================================================
# TABLE: geofences_spatial_index
# Purpose: S2 covering index for polygon containment queries
# ============================================================================

puts "Creating spatial index: geospatial_db:geofences_spatial_index"

create 'geospatial_db:geofences_spatial_index',
  {
    NAME => 'idx',
    VERSIONS => 1,
    COMPRESSION => COMPRESSION,
    IN_MEMORY => 'true',  # Keep geofence index in memory
    BLOOMFILTER => BLOOMFILTER
  }

# ============================================================================
# TABLE: geofences_by_status
# Purpose: Secondary index for active geofences
# Row Key: [active:1][geofence_id:36]
# ============================================================================

puts "Creating secondary index: geospatial_db:geofences_by_status"

create 'geospatial_db:geofences_by_status',
  {
    NAME => 'ref',
    VERSIONS => 1,
    COMPRESSION => COMPRESSION,
    IN_MEMORY => 'true',
    BLOOMFILTER => BLOOMFILTER
  }

# Column Qualifiers:
# ref:geofence_id            - Reference to main table (String)

# ============================================================================
# TABLE: raster_metadata
# Purpose: Reference external raster data (satellite imagery, elevation)
# Row Key: raster_id (UUID as String)
# Expected Volume: 10K-100K records
# ============================================================================

puts "\nCreating table: geospatial_db:raster_metadata"

create 'geospatial_db:raster_metadata',
  {
    NAME => 'attrs',
    VERSIONS => 1,
    COMPRESSION => COMPRESSION,
    BLOOMFILTER => BLOOMFILTER
  },
  {
    NAME => 'geo',
    VERSIONS => 1,
    COMPRESSION => COMPRESSION,
    DATA_BLOCK_ENCODING => DATA_BLOCK_ENCODING
  },
  {
    NAME => 'raster',
    VERSIONS => 1,
    COMPRESSION => COMPRESSION
  },
  {
    NAME => 'meta',
    VERSIONS => 1,
    COMPRESSION => COMPRESSION
  }

# Column Qualifiers:
# attrs:name                 - Raster dataset name (String)
# attrs:description          - Description (String)
# attrs:raster_type          - Type (imagery, dem, landcover, temperature)
# attrs:source               - Data provider (String)
# geo:bounds_wkb             - Bounding box WKB POLYGON (Bytes)
# geo:centroid_lon           - Centroid longitude (Double)
# geo:centroid_lat           - Centroid latitude (Double)
# geo:centroid_geohash       - Centroid GeoHash (String)
# raster:resolution_m        - Spatial resolution (Double)
# raster:pixel_width         - Width in pixels (Integer)
# raster:pixel_height        - Height in pixels (Integer)
# raster:bands               - Number of bands (Integer)
# raster:bit_depth           - Bit depth (Integer)
# raster:crs                 - Coordinate system (String)
# raster:file_path           - Storage location (String)
# raster:file_format         - File format (String)
# raster:file_size_mb        - File size (Double)
# meta:acquisition_date      - Data capture date (Long)
# meta:processing_date       - Processing date (Long)
# meta:created_at            - Creation timestamp (Long)
# meta:attributes_json       - JSON metadata (String)

# ============================================================================
# TABLE: raster_metadata_spatial_index
# Purpose: Spatial queries on raster bounding boxes
# ============================================================================

puts "Creating spatial index: geospatial_db:raster_metadata_spatial_index"

create 'geospatial_db:raster_metadata_spatial_index',
  {
    NAME => 'idx',
    VERSIONS => 1,
    COMPRESSION => COMPRESSION,
    BLOOMFILTER => BLOOMFILTER
  }

# ============================================================================
# SUMMARY
# ============================================================================

puts "\n" + "="*80
puts "Schema creation complete!"
puts "="*80
puts "\nCreated tables:"
puts "  - geospatial_db:locations (+ spatial_index, by_city)"
puts "  - geospatial_db:regions (+ spatial_index)"
puts "  - geospatial_db:boundaries"
puts "  - geospatial_db:routes"
puts "  - geospatial_db:events (+ spatial_index, pre-split 16 regions)"
puts "  - geospatial_db:assets (+ spatial_index, by_type)"
puts "  - geospatial_db:asset_history (+ spatial_index)"
puts "  - geospatial_db:geofences (+ spatial_index, by_status)"
puts "  - geospatial_db:raster_metadata (+ spatial_index)"
puts "\n" + "="*80

# ============================================================================
# NEXT STEPS - GEOMESA INTEGRATION
# ============================================================================

puts "\nNEXT STEPS - GeoMesa Integration:"
puts "="*80
puts "\n1. Install GeoMesa HBase distribution"
puts "\n2. Create GeoMesa SimpleFeatureTypes using CLI:"
puts "\ngeomesa-hbase create-schema \\"
puts "  --zookeeper localhost:2181 \\"
puts "  --catalog geospatial_db \\"
puts "  --feature-name locations \\"
puts "  --spec 'location_id:UUID:index=true,*geometry:Point:srid=4326,name:String,location_type:String:index=true,city:String:index=true,created_at:Date:index=true'"
puts "\n3. Configure geomesa-site.xml:"
puts "<property>"
puts "  <n>geomesa.hbase.coprocessor.path</n>"
puts "  <value>hdfs:///hbase/lib/geomesa-hbase-distributed-runtime.jar</value>"
puts "</property>"
puts "\n4. Enable coprocessors on spatial tables:"
puts "disable 'geospatial_db:locations_spatial_index'"
puts "alter 'geospatial_db:locations_spatial_index', METHOD => 'table_att', 'coprocessor'=>'hdfs:///hbase/lib/geomesa.jar'"
puts "enable 'geospatial_db:locations_spatial_index'"
puts "\n" + "="*80
puts "Schema ready for production use!"
puts "="*80
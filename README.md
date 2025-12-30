# Databases

---

## Data Lake / Storage Engines (database‑like)

### Azure Data Lake Storage (ADLS)


### Apache Hadoop (HDFS)

---

## Distributed SQL / MPP Databases

### Apache Hive
<li><a href="./hive_XYZFinancialSecurities_schema.sql"> XYZ Financials Hive Database </a></li>

### Apache Impala
<li><a href="./impala_XYZFinancialSecurities_schema.sql"> XYZ Financials Impala Database </a></li>

### Azure Synapse (SQL Pools)
<li><a href="./azure_synapse_XYZFinancialSecurities_schema.sql"> XYZ Financials Azure Synapse (SQL Pools) Database </a></li>

### PrestoDB (federated SQL query engine, often used as a DB layer)
<li><a href="./presto_XYZFinancialSecurities_schema.sql"> XYZ Financials PrestoDB Database </a></li>

### Snowflake
<li><a href="./snowflake_XYZFinancialSecurities_schema.sql"> XYZ Financials Snowflake Database </a></li>


---

## Event/Stream Systems 
That Are Not Databases (but often mistaken as such). These are NOT databases, but many teams incorrectly categorize them as data stores:

### Apache Kafka
<li><a href="./apache_kafka_topics.yaml"> XYZ Financials Apache Kafka Database </a></li>

### Apache Flink
<li><a href="./apache_flink_XYZFinancialSecurities_DBsetup.sql"> XYZ Financials Apache Flink Database </a></li>

### Apache Spark
<li><a href="./apache_spark_XYZ_Financials_Securities_DBsetup.py"> XYZ Financials Apache Spark Database </a></li>

### Apache Storm
<li><a href="./apache_storm_topologies.java"> XYZ Financials Apache Storm Database </a></li>

---

## Geospatial Databases
(optimized for spatial indexing, GIS workloads, and location intelligence)

### Cassandra with GeoMesa
<li><a href="./cassandra_geomesa_ddl.sql"> Cassandra  GeoMesa </a></li>

### Google BigQuery GIS (SQL + geospatial functions)
<li><a href="./bigqueryGISddl.sql"> BigQuery GIS </a></li>

### HBase with GeoMesa
<li><a href="./hbase_geomesa_ddl.rb"> HBase GeoMesa </a></li>

### MongoDB (native geospatial indexing)
<li><a href="./MongoDBnative2dspheregeospatialindexingschema.js"> MongoDB 2d sphere </a></li>

### Oracle Spatial & Graph
<li><a href="./OracleSpatialGraphschema.sql"> Oracle Spatial & Graph </a></li>

### PostGIS (PostgreSQL extension)
<li><a href="./PostGISPostgreSQLextensionschema.sql"> PostGIS </a></li>

### Spatialite (SQLite geospatial extension)
<li><a href="./SpatiaLiteSQLitegeospatialextschema.sql"> SQLite geospatial </a></li>


---
## NoSQL Databases

### Amazon DynamoDB
<li><a href="./dynamodb_XYZFinancialSecurities_schema.js"> XYZ Financials DynamoDB Database </a></li>

### Azure CosmosDB
<li><a href="./cosmosdb_XYZFinancialSecurities_schema.js"> XYZ Financials CosmosDB Database </a></li>

### Cassandra
<li><a href="./cassandra_XYZFinancialSecurities_schema.sql"> XYZ Financials Cassandra Database </a></li>

### HBase
<li><a href="./hbase_XYZFinancialsSecurities_schema.py"> XYZ Financials HBase Database </a></li>

### MongoDB Atlas
<li><a href="https://github.com/spusgh/Db-Scripts/blob/main/XYZFinancialssecuritiesMongoDB/"> XYZ Financials MongoDB Database </a></li>
<li><a href="https://github.com/spusgh/Db-Scripts/blob/main/XYZFinancialssecuritiesMongoDB/database/mongodb_XYZFinancialSecurities_schema.js"> XYZ Financials MongoDB Database Schema </a></li>


---


## Relational Databases (RDBMS)

### Azure SQL
<li><a href="./azure_sql_XYZFinancialSecurities_schema.sql"> XYZ Financials Azure SQL Database </a></li>

### MySQL
<li><a href="./mysql_XYZFinancialSecurities_schema.sql"> XYZ Financials MySQL Database </a></li>

### MS SQL BI (SQL Server ecosystem)
<li><a href="./mssql_bi_XYZFinancialSecurities_schema.sql"> XYZ Financials MS SQL BI Database </a></li>

### MS SQL Server
<li><a href="https://github.com/spusgh/Db-Scripts/blob/main/CreditDatabase/CreditDB_Schema.sql"> Credit Database Schema Scripts </a></li>
<li><a href="https://github.com/spusgh/Db-Scripts/blob/main/MediaEntDatabase/MediaEntDB.sql"> Media Entertain DB Schema Scripts </a></li>
<li><a href="https://github.com/spusgh/Db-Scripts/blob/main/XYZFinancialssecurities/XYZ_Financials_Securities_Schema_AllObjects.sql"> XYZ Financials Securities Schema DB Schema Scripts </a></li>

### Oracle Database
<li><a href="./oracle_XYZFinancialSecurities_schema.sql"> XYZ Financials Oracle Database </a></li>

### PostgreSQL
<li><a href="./postgresql_XYZFinancialSecurities_schema.sql"> XYZ Financials PostgreSQL Database </a></li>


---

## <li><a href="./vector_db_overview.md">Vector Databases</a></li>
(these are optimized for embeddings, semantic search, RAG, and agentic AI)

### ChromaDB
<li><a href="./chromadb_XYZFinancialsSecurities_schema.py"> XYZ Financials ChromaDB Database </a></li>

### Elasticsearch (supports vector search; hybrid search engine + DB)
<li><a href="./elasticsearch_XYZFinancialsSecurities_schema.json"> XYZ Financials Elasticsearch Database </a></li>

### Milvus
<li><a href="milvus_XYZFinancialsSecurities_schema.py"> XYZ Financials Milvus Database </a></li>

### Pinecone
<li><a href="./pinecone_XYZFinancialsSecurities_schema.py"> XYZ Financials Pinecone Database </a></li>

### Qdrant
<li><a href="./qdrant_XYZFinancialsSecurities_schema.py"> XYZ Financials Qdrant Database </a></li>

### Redis Vector (Redis with vector search module)
<li><a href="./redis_vector_XYZFinancialsSecurities_schema.py"> XYZ Financials Redis Database </a></li>

### Weaviate
<li><a href="./weaviate_XYZFinancialsSecurities_schema.py"> XYZ Financials Weaviate Database </a></li>


---


---



# Data Models
## Diagramming and charting tool
### Mermaid ER Diagrams
#### Geospatial Databases

``` mermaid
erDiagram
    LOCATIONS ||--o{ EVENTS : "occurs_at"
    LOCATIONS ||--o{ BOUNDARIES : "connected_to"
    REGIONS ||--o{ LOCATIONS : "contains"
    REGIONS ||--o{ REGIONS : "parent_of"
    ASSETS ||--o{ ASSET_HISTORY : "tracks"
    ASSETS ||--o{ ROUTES : "follows"
    ASSETS ||--o{ EVENTS : "generates"
    GEOFENCES ||--o{ ASSETS : "monitors"
    RASTER_METADATA ||--o{ REGIONS : "overlaps"

    LOCATIONS {
        uuid location_id PK
        string name
        string location_type
        geography geometry "POINT"
        string address
        string city
        string country
        string postal_code
        double elevation_m
        timestamp created_at
        timestamp updated_at
        json attributes
    }

    REGIONS {
        uuid region_id PK
        string name
        string region_type
        geography geometry "POLYGON/MULTIPOLYGON"
        uuid parent_region_id FK
        double area_sq_km
        double perimeter_km
        geography centroid
        integer population
        integer admin_level
        string iso_code
        timestamp created_at
        timestamp updated_at
        json attributes
    }

    BOUNDARIES {
        uuid boundary_id PK
        string name
        string boundary_type
        geography geometry "LINESTRING/MULTILINESTRING"
        double length_km
        uuid start_location_id FK
        uuid end_location_id FK
        string classification
        string surface_type
        double width_m
        timestamp created_at
        timestamp updated_at
        json attributes
    }

    ROUTES {
        uuid route_id PK
        string name
        string route_type
        geography geometry "LINESTRING"
        timestamp start_time
        timestamp end_time
        double distance_km
        integer duration_seconds
        uuid vehicle_id FK
        uuid driver_id
        array waypoints "POINT[]"
        string status
        timestamp created_at
        timestamp updated_at
        json attributes
    }

    EVENTS {
        uuid event_id PK
        string event_type
        geography geometry "POINT"
        timestamp event_time
        string severity
        uuid location_id FK
        uuid asset_id FK
        string source
        double value
        string unit
        string description
        timestamp created_at
        json attributes
    }

    ASSETS {
        uuid asset_id PK
        string asset_name
        string asset_type
        geography current_geometry "POINT"
        timestamp last_updated
        double speed_kmh
        double heading_degrees
        double altitude_m
        string status
        uuid owner_id
        geography trajectory "LINESTRING"
        uuid geofence_id FK
        double battery_level
        timestamp created_at
        json attributes
    }

    ASSET_HISTORY {
        uuid history_id PK
        uuid asset_id FK
        geography geometry "POINT"
        timestamp recorded_at
        double speed_kmh
        double heading_degrees
        double altitude_m
        double accuracy_m
        string source
        json attributes
    }

    GEOFENCES {
        uuid geofence_id PK
        string name
        geography geometry "POLYGON/MULTIPOLYGON"
        string geofence_type
        boolean active
        boolean trigger_on_enter
        boolean trigger_on_exit
        double buffer_m
        timestamp valid_from
        timestamp valid_until
        uuid owner_id
        timestamp created_at
        json attributes
    }

    RASTER_METADATA {
        uuid raster_id PK
        string name
        string raster_type
        geography bounds "POLYGON"
        geography centroid "POINT"
        double resolution_m
        integer bands
        string crs
        string file_path
        double file_size_mb
        timestamp acquisition_date
        string source
        timestamp created_at
        json attributes
    }

```
#### XYZ Financials Securities Data Model

<li><a href="https://github.com/spusgh/Db-Scripts/tree/main/DbModels"> MS Power Platform Loan Ecosystem </a></li>




## ⚠️ Disclaimer

This repository is intended for demonstration, architecture reference, and internal collaboration only. All content—including code, documentation, diagrams, and configuration—is proprietary to Shaila Patel.

Unauthorized copying, reuse, or redistribution of any part of this repository is strictly prohibited. If you wish to reference or adapt any material, please contact the repository owner for written permission.

This is not an open-source project and is not licensed for public or commercial use.

By accessing this repository, you agree to respect the intellectual property rights of the owner and to use the content solely for its intended purpose within authorized contexts.

---
<br/>


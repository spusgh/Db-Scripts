// MongoDB Geospatial Schema DDL
use geospatial_platform;

db.createCollection("locations");
db.locations.createIndex({ geometry: "2dsphere" });
db.locations.createIndex({ location_id: 1 }, { unique: true });

db.createCollection("regions");
db.regions.createIndex({ geometry: "2dsphere" });

db.createCollection("events");
db.events.createIndex({ geometry: "2dsphere" });
db.events.createIndex({ timestamp: -1 });

print("MongoDB schema created");
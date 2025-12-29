
"""
Redis Vector Search Schema for XYZ Financials Securities
=========================================================
File: redis_vector_schema.py

Redis Vector is best for: Low-latency applications, real-time search, caching
- Sub-millisecond response times
- Hybrid data structure + vector search
- Great for session data + recommendations
- Redis Stack required (includes RediSearch + RedisJSON)
"""

import redis
from redis.commands.search.field import TextField, NumericField, TagField, VectorField
from redis.commands.search.indexDefinition import IndexDefinition, IndexType
from redis.commands.search.query import Query
import numpy as np
from sentence_transformers import SentenceTransformer
import json

# =============================================
# CONFIGURATION
# =============================================

# Connect to Redis
redis_client = redis.Redis(
    host='localhost',
    port=6379,
    decode_responses=False  # Important for vector search
)

# Initialize embedding model
encoder = SentenceTransformer('all-MiniLM-L6-v2')  # 384 dimensions

# Vector dimensions
VECTOR_DIM = 384

# =============================================
# INDEX DEFINITIONS
# =============================================

def create_customer_index():
    """Create index for customer vectors"""
    schema = (
        TextField("$.fullName", as_name="fullName"),
        TextField("$.email", as_name="email"),
        TextField("$.profileText", as_name="profileText"),
        NumericField("$.customerId", as_name="customerId"),
        NumericField("$.creditScore", as_name="creditScore"),
        NumericField("$.annualIncome", as_name="annualIncome"),
        TagField("$.state", as_name="state"),
        TagField("$.city", as_name="city"),
        TagField("$.employmentStatus", as_name="employmentStatus"),
        VectorField(
            "$.embedding",
            "FLAT",  # or "HNSW" for large datasets
            {
                "TYPE": "FLOAT32",
                "DIM": VECTOR_DIM,
                "DISTANCE_METRIC": "COSINE"
            },
            as_name="embedding"
        )
    )
    
    try:
        redis_client.ft("idx:customers").create_index(
            fields=schema,
            definition=IndexDefinition(
                prefix=["customer:"],
                index_type=IndexType.JSON
            )
        )
        print("Customer index created successfully")
    except Exception as e:
        print(f"Customer index error: {e}")

def create_loan_index():
    """Create index for loan vectors"""
    schema = (
        TextField("$.loanDescription", as_name="loanDescription"),
        NumericField("$.loanId", as_name="loanId"),
        NumericField("$.customerId", as_name="customerId"),
        NumericField("$.loanAmount", as_name="loanAmount"),
        NumericField("$.interestRate", as_name="interestRate"),
        NumericField("$.remainingBalance", as_name="remainingBalance"),
        NumericField("$.ltv", as_name="ltv"),
        NumericField("$.dti", as_name="dti"),
        TagField("$.status", as_name="status"),
        TagField("$.productType", as_name="productType"),
        TagField("$.propertyState", as_name="propertyState"),
        TextField("$.originationDate", as_name="originationDate"),
        VectorField(
            "$.embedding",
            "HNSW",  # HNSW for better performance with large datasets
            {
                "TYPE": "FLOAT32",
                "DIM": VECTOR_DIM,
                "DISTANCE_METRIC": "COSINE",
                "M": 16,  # Number of connections per layer
                "EF_CONSTRUCTION": 200  # Size of dynamic candidate list
            },
            as_name="embedding"
        )
    )
    
    try:
        redis_client.ft("idx:loans").create_index(
            fields=schema,
            definition=IndexDefinition(
                prefix=["loan:"],
                index_type=IndexType.JSON
            )
        )
        print("Loan index created successfully")
    except Exception as e:
        print(f"Loan index error: {e}")

def create_application_index():
    """Create index for application vectors"""
    schema = (
        TextField("$.applicationNarrative", as_name="applicationNarrative"),
        NumericField("$.applicationId", as_name="applicationId"),
        NumericField("$.customerId", as_name="customerId"),
        NumericField("$.officerId", as_name="officerId"),
        NumericField("$.loanAmount", as_name="loanAmount"),
        NumericField("$.creditScore", as_name="creditScore"),
        NumericField("$.ltv", as_name="ltv"),
        NumericField("$.dti", as_name="dti"),
        TagField("$.status", as_name="status"),
        TagField("$.loanPurpose", as_name="loanPurpose"),
        TagField("$.riskClassification", as_name="riskClassification"),
        TextField("$.applicationDate", as_name="applicationDate"),
        VectorField(
            "$.embedding",
            "HNSW",
            {
                "TYPE": "FLOAT32",
                "DIM": VECTOR_DIM,
                "DISTANCE_METRIC": "COSINE",
                "M": 16,
                "EF_CONSTRUCTION": 200
            },
            as_name="embedding"
        )
    )
    
    try:
        redis_client.ft("idx:applications").create_index(
            fields=schema,
            definition=IndexDefinition(
                prefix=["application:"],
                index_type=IndexType.JSON
            )
        )
        print("Application index created successfully")
    except Exception as e:
        print(f"Application index error: {e}")

def create_property_index():
    """Create index for property vectors"""
    schema = (
        TextField("$.address", as_name="address"),
        TextField("$.propertyDescription", as_name="propertyDescription"),
        NumericField("$.propertyId", as_name="propertyId"),
        NumericField("$.currentValue", as_name="currentValue"),
        NumericField("$.squareFeet", as_name="squareFeet"),
        NumericField("$.bedrooms", as_name="bedrooms"),
        NumericField("$.bathrooms", as_name="bathrooms"),
        NumericField("$.yearBuilt", as_name="yearBuilt"),
        NumericField("$.latitude", as_name="latitude"),
        NumericField("$.longitude", as_name="longitude"),
        TagField("$.city", as_name="city"),
        TagField("$.state", as_name="state"),
        TagField("$.zipCode", as_name="zipCode"),
        TagField("$.propertyType", as_name="propertyType"),
        TagField("$.floodZone", as_name="floodZone"),
        VectorField(
            "$.embedding",
            "HNSW",
            {
                "TYPE": "FLOAT32",
                "DIM": VECTOR_DIM,
                "DISTANCE_METRIC": "COSINE",
                "M": 16,
                "EF_CONSTRUCTION": 200
            },
            as_name="embedding"
        )
    )
    
    try:
        redis_client.ft("idx:properties").create_index(
            fields=schema,
            definition=IndexDefinition(
                prefix=["property:"],
                index_type=IndexType.JSON
            )
        )
        print("Property index created successfully")
    except Exception as e:
        print(f"Property index error: {e}")

def create_document_index():
    """Create index for document vectors"""
    schema = (
        TextField("$.fileName", as_name="fileName"),
        TextField("$.extractedText", as_name="extractedText"),
        NumericField("$.documentId", as_name="documentId"),
        NumericField("$.applicationId", as_name="applicationId"),
        TagField("$.documentType", as_name="documentType"),
        TagField("$.approvalStatus", as_name="approvalStatus"),
        TextField("$.uploadDate", as_name="uploadDate"),
        VectorField(
            "$.embedding",
            "HNSW",
            {
                "TYPE": "FLOAT32",
                "DIM": VECTOR_DIM,
                "DISTANCE_METRIC": "COSINE",
                "M": 16,
                "EF_CONSTRUCTION": 200
            },
            as_name="embedding"
        )
    )
    
    try:
        redis_client.ft("idx:documents").create_index(
            fields=schema,
            definition=IndexDefinition(
                prefix=["document:"],
                index_type=IndexType.JSON
            )
        )
        print("Document index created successfully")
    except Exception as e:
        print(f"Document index error: {e}")

def create_default_index():
    """Create index for default case vectors"""
    schema = (
        TextField("$.defaultNarrative", as_name="defaultNarrative"),
        NumericField("$.defaultId", as_name="defaultId"),
        NumericField("$.loanId", as_name="loanId"),
        NumericField("$.lossAmount", as_name="lossAmount"),
        TagField("$.stage", as_name="stage"),
        TagField("$.reasonCode", as_name="reasonCode"),
        TagField("$.resolutionType", as_name="resolutionType"),
        TextField("$.defaultDate", as_name="defaultDate"),
        VectorField(
            "$.embedding",
            "HNSW",
            {
                "TYPE": "FLOAT32",
                "DIM": VECTOR_DIM,
                "DISTANCE_METRIC": "COSINE",
                "M": 16,
                "EF_CONSTRUCTION": 200
            },
            as_name="embedding"
        )
    )
    
    try:
        redis_client.ft("idx:defaults").create_index(
            fields=schema,
            definition=IndexDefinition(
                prefix=["default:"],
                index_type=IndexType.JSON
            )
        )
        print("Default index created successfully")
    except Exception as e:
        print(f"Default index error: {e}")

def create_all_indexes():
    """Create all Redis indexes"""
    create_customer_index()
    create_loan_index()
    create_application_index()
    create_property_index()
    create_document_index()
    create_default_index()

# =============================================
# DATA INGESTION
# =============================================

def ingest_customer(customer_data):
    """Ingest customer into Redis"""
    profile_text = f"""
    {customer_data['firstName']} {customer_data['lastName']}, 
    Credit Score: {customer_data.get('creditScore', 0)}, 
    Income: ${customer_data.get('annualIncome', 0)}, 
    Employment: {customer_data.get('employmentStatus', '')} at {customer_data.get('employer', '')}, 
    Location: {customer_data.get('city', '')}, {customer_data.get('state', '')}
    """
    
    embedding = encoder.encode(profile_text).astype(np.float32).tobytes()
    
    customer_json = {
        "customerId": customer_data['customerId'],
        "fullName": f"{customer_data['firstName']} {customer_data['lastName']}",
        "email": customer_data.get('email', ''),
        "phone": customer_data.get('phone', ''),
        "creditScore": customer_data.get('creditScore', 0),
        "annualIncome": float(customer_data.get('annualIncome', 0)),
        "employmentStatus": customer_data.get('employmentStatus', ''),
        "city": customer_data.get('city', ''),
        "state": customer_data.get('state', ''),
        "profileText": profile_text.strip(),
        "embedding": embedding.decode('latin1')  # Store as string
    }
    
    redis_client.json().set(
        f"customer:{customer_data['customerId']}", 
        "$", 
        customer_json
    )

def ingest_loan(loan_data):
    """Ingest loan into Redis"""
    loan_text = f"""
    Loan ${loan_data['loanAmount']} at {loan_data['interestRate']}% 
    for {loan_data['term']} months, {loan_data.get('propertyType', '')} 
    in {loan_data.get('propertyCity', '')}, {loan_data.get('propertyState', '')}, 
    Status: {loan_data['status']}
    """
    
    embedding = encoder.encode(loan_text).astype(np.float32).tobytes()
    
    loan_json = {
        "loanId": loan_data['loanId'],
        "customerId": loan_data['customerId'],
        "propertyId": loan_data['propertyId'],
        "loanAmount": float(loan_data['loanAmount']),
        "interestRate": float(loan_data['interestRate']),
        "remainingBalance": float(loan_data['remainingBalance']),
        "status": loan_data['status'],
        "productType": loan_data.get('productType', ''),
        "propertyState": loan_data.get('propertyState', ''),
        "originationDate": str(loan_data['originationDate']),
        "ltv": float(loan_data.get('ltv', 0)),
        "dti": float(loan_data.get('dti', 0)),
        "loanDescription": loan_text.strip(),
        "embedding": embedding.decode('latin1')
    }
    
    redis_client.json().set(
        f"loan:{loan_data['loanId']}", 
        "$", 
        loan_json
    )

# =============================================
# QUERY FUNCTIONS
# =============================================

def vector_search(index_name, query_text, k=10, filters=None):
    """Perform vector search with optional filters"""
    # Generate query embedding
    query_embedding = encoder.encode(query_text).astype(np.float32).tobytes()
    
    # Build query
    base_query = f"*=>[KNN {k} @embedding $vec AS score]"
    
    # Add filters if provided
    if filters:
        filter_parts = []
        for field, value in filters.items():
            if isinstance(value, str):
                filter_parts.append(f"@{field}:{{{value}}}")
            elif isinstance(value, dict):
                if '$gte' in value:
                    filter_parts.append(f"@{field}:[{value['$gte']} +inf]")
                if '$lte' in value:
                    filter_parts.append(f"@{field}:[-inf {value['$lte']}]")
        
        if filter_parts:
            base_query = f"({'  '.join(filter_parts)})=>[KNN {k} @embedding $vec AS score]"
    
    query = (
        Query(base_query)
        .return_fields("$", "score")
        .sort_by("score")
        .dialect(2)
    )
    
    # Execute search
    results = redis_client.ft(index_name).search(
        query,
        query_params={"vec": query_embedding}
    )
    
    return results

def search_similar_customers(query_text, k=10):
    """Search for similar customers"""
    return vector_search("idx:customers", query_text, k)

def search_loans_with_filters(query_text, status=None, min_amount=None, state=None):
    """Search loans with filters"""
    filters = {}
    
    if status:
        filters['status'] = status
    
    if min_amount:
        filters['loanAmount'] = {'$gte': min_amount}
    
    if state:
        filters['propertyState'] = state
    
    return vector_search("idx:loans", query_text, k=10, filters=filters)

def search_high_risk_applications():
    """Search for high-risk applications"""
    return vector_search(
        "idx:applications",
        "high risk default potential financial hardship",
        k=20,
        filters={'riskClassification': 'High'}
    )

def hybrid_search_loans(text_query, vector_query):
    """Hybrid search combining full-text and vector search"""
    # Full-text search
    text_results = redis_client.ft("idx:loans").search(
        Query(f"@loanDescription:{text_query}")
    )
    
    # Vector search
    vector_results = vector_search("idx:loans", vector_query, k=10)
    
    # Combine results (simple merge, could be more sophisticated)
    combined_ids = set()
    combined_results = []
    
    for doc in text_results.docs:
        combined_ids.add(doc.id)
        combined_results.append(doc)
    
    for doc in vector_results.docs:
        if doc.id not in combined_ids:
            combined_results.append(doc)
    
    return combined_results

# =============================================
# RANGE QUERIES (NUMERIC FILTERS)
# =============================================

def find_customers_by_credit_range(min_score, max_score):
    """Find customers within credit score range"""
    query = Query(f"@creditScore:[{min_score} {max_score}]").return_fields("$")
    results = redis_client.ft("idx:customers").search(query)
    return results

def find_loans_by_amount_range(min_amount, max_amount):
    """Find loans within amount range"""
    query = Query(f"@loanAmount:[{min_amount} {max_amount}]").return_fields("$")
    results = redis_client.ft("idx:loans").search(query)
    return results

# =============================================
# GEO QUERIES
# =============================================

def find_properties_near_location(lat, lon, radius_km=50):
    """Find properties near a geographic location"""
    # Note: Redis doesn't have built-in geo search for arbitrary fields
    # This would require a custom implementation or using Redis GEO commands separately
    
    # For now, we'll do a simple range query
    lat_range = radius_km / 111  # Approximate km to degrees
    lon_range = radius_km / (111 * np.cos(np.radians(lat)))
    
    query = Query(
        f"@latitude:[{lat - lat_range} {lat + lat_range}] "
        f"@longitude:[{lon - lon_range} {lon + lon_range}]"
    ).return_fields("$")
    
    results = redis_client.ft("idx:properties").search(query)
    return results

# =============================================
# AGGREGATIONS
# =============================================

def aggregate_loans_by_status():
    """Aggregate loans by status"""
    from redis.commands.search.aggregation import AggregateRequest, reducers
    
    request = AggregateRequest("*").group_by(
        "@status",
        reducers.count().alias("count"),
        reducers.sum("@loanAmount").alias("totalAmount"),
        reducers.avg("@interestRate").alias("avgRate")
    )
    
    results = redis_client.ft("idx:loans").aggregate(request)
    return results

# =============================================
# BATCH OPERATIONS
# =============================================

def batch_ingest_customers(customers_list):
    """Batch ingest multiple customers"""
    pipe = redis_client.pipeline()
    
    for customer in customers_list:
        profile_text = f"{customer['firstName']} {customer['lastName']}, Credit: {customer.get('creditScore', 0)}"
        embedding = encoder.encode(profile_text).astype(np.float32).tobytes()
        
        customer_json = {
            "customerId": customer['customerId'],
            "fullName": f"{customer['firstName']} {customer['lastName']}",
            "creditScore": customer.get('creditScore', 0),
            "state": customer.get('state', ''),
            "profileText": profile_text,
            "embedding": embedding.decode('latin1')
        }
        
        pipe.json().set(f"customer:{customer['customerId']}", "$", customer_json)
    
    pipe.execute()

# =============================================
# UTILITY FUNCTIONS
# =============================================

def get_index_info(index_name):
    """Get information about an index"""
    return redis_client.ft(index_name).info()

def delete_index(index_name):
    """Delete an index"""
    redis_client.ft(index_name).dropindex(delete_documents=False)

def delete_all_data(prefix):
    """Delete all data with a prefix"""
    for key in redis_client.scan_iter(f"{prefix}*"):
        redis_client.delete(key)

# =============================================
# MAIN EXECUTION
# =============================================

if __name__ == "__main__":
    # Create all indexes
    create_all_indexes()
    print("Redis Vector indexes created successfully!")
    
    # Print index info
    for index in ["idx:customers", "idx:loans", "idx:applications", "idx:properties"]:
        try:
            info = get_index_info(index)
            print(f"\n{index} info:")
            print(f"  Num docs: {info['num_docs']}")
            print(f"  Num terms: {info['num_terms']}")
        except Exception as e:
            print(f"Error getting info for {index}: {e}")
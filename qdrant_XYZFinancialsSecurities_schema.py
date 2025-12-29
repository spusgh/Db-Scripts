
"""
Qdrant Vector Database Schema for XYZ Financials Securities
Save as: qdrant_schema.py
"""

from qdrant_client import QdrantClient
from qdrant_client.models import (
    Distance, VectorParams, PayloadSchemaType,
    PointStruct, Filter, FieldCondition, Range
)

# ============================================================
# COLLECTION CONFIGURATIONS
# ============================================================

# COLLECTION: customers
customers_collection_config = {
    "collection_name": "xyz_customers",
    "vectors_config": VectorParams(
        size=768,
        distance=Distance.COSINE
    ),
    "optimizers_config": {
        "default_segment_number": 2,
        "indexing_threshold": 10000
    },
    "hnsw_config": {
        "m": 16,
        "ef_construct": 100,
        "full_scan_threshold": 10000
    }
}

customers_payload_schema = {
    "customer_id": PayloadSchemaType.INTEGER,
    "full_name": PayloadSchemaType.KEYWORD,
    "first_name": PayloadSchemaType.TEXT,
    "last_name": PayloadSchemaType.TEXT,
    "email": PayloadSchemaType.KEYWORD,
    "phone": PayloadSchemaType.KEYWORD,
    "annual_income": PayloadSchemaType.FLOAT,
    "employment_status": PayloadSchemaType.KEYWORD,
    "employer": PayloadSchemaType.TEXT,
    "years_employed": PayloadSchemaType.INTEGER,
    "credit_score": PayloadSchemaType.INTEGER,
    "created_date": PayloadSchemaType.DATETIME,
    "last_updated_date": PayloadSchemaType.DATETIME,
    "customer_profile_text": PayloadSchemaType.TEXT,
    "record_type": PayloadSchemaType.KEYWORD
}

customers_indexed_fields = [
    "customer_id", "credit_score", "employment_status", 
    "annual_income", "created_date"
]


# COLLECTION: loans
loans_collection_config = {
    "collection_name": "xyz_loans",
    "vectors_config": VectorParams(
        size=768,
        distance=Distance.COSINE
    ),
    "optimizers_config": {
        "default_segment_number": 2,
        "indexing_threshold": 10000
    },
    "hnsw_config": {
        "m": 16,
        "ef_construct": 100,
        "full_scan_threshold": 10000
    }
}

loans_payload_schema = {
    "loan_id": PayloadSchemaType.INTEGER,
    "application_id": PayloadSchemaType.INTEGER,
    "customer_id": PayloadSchemaType.INTEGER,
    "property_id": PayloadSchemaType.INTEGER,
    "product_id": PayloadSchemaType.INTEGER,
    "loan_amount": PayloadSchemaType.FLOAT,
    "interest_rate": PayloadSchemaType.FLOAT,
    "term": PayloadSchemaType.INTEGER,
    "origination_date": PayloadSchemaType.DATETIME,
    "maturity_date": PayloadSchemaType.DATETIME,
    "monthly_payment": PayloadSchemaType.FLOAT,
    "remaining_balance": PayloadSchemaType.FLOAT,
    "status": PayloadSchemaType.KEYWORD,
    "escrow_required": PayloadSchemaType.BOOL,
    "pmi_required": PayloadSchemaType.BOOL,
    "pmi_amount": PayloadSchemaType.FLOAT,
    "next_payment_date": PayloadSchemaType.DATETIME,
    "payment_frequency": PayloadSchemaType.KEYWORD,
    "security_id": PayloadSchemaType.INTEGER,
    "loan_summary_text": PayloadSchemaType.TEXT,
    "record_type": PayloadSchemaType.KEYWORD
}

loans_indexed_fields = [
    "loan_id", "customer_id", "status", "origination_date",
    "loan_amount", "interest_rate", "remaining_balance"
]


# COLLECTION: properties
properties_collection_config = {
    "collection_name": "xyz_properties",
    "vectors_config": VectorParams(
        size=768,
        distance=Distance.COSINE
    ),
    "optimizers_config": {
        "default_segment_number": 2,
        "indexing_threshold": 10000
    },
    "hnsw_config": {
        "m": 16,
        "ef_construct": 100,
        "full_scan_threshold": 10000
    }
}

properties_payload_schema = {
    "property_id": PayloadSchemaType.INTEGER,
    "address_full": PayloadSchemaType.TEXT,
    "address_line1": PayloadSchemaType.TEXT,
    "city": PayloadSchemaType.KEYWORD,
    "state": PayloadSchemaType.KEYWORD,
    "zip_code": PayloadSchemaType.KEYWORD,
    "country": PayloadSchemaType.KEYWORD,
    "property_type": PayloadSchemaType.KEYWORD,
    "year_built": PayloadSchemaType.INTEGER,
    "square_feet": PayloadSchemaType.INTEGER,
    "bedrooms": PayloadSchemaType.INTEGER,
    "bathrooms": PayloadSchemaType.FLOAT,
    "purchase_price": PayloadSchemaType.FLOAT,
    "current_value": PayloadSchemaType.FLOAT,
    "last_appraisal_date": PayloadSchemaType.DATETIME,
    "last_appraisal_value": PayloadSchemaType.FLOAT,
    "tax_assessment_value": PayloadSchemaType.FLOAT,
    "annual_tax_amount": PayloadSchemaType.FLOAT,
    "hoa_fees": PayloadSchemaType.FLOAT,
    "flood_zone": PayloadSchemaType.KEYWORD,
    "property_tax_id": PayloadSchemaType.KEYWORD,
    "latitude": PayloadSchemaType.FLOAT,
    "longitude": PayloadSchemaType.FLOAT,
    "property_description_text": PayloadSchemaType.TEXT,
    "record_type": PayloadSchemaType.KEYWORD
}

properties_indexed_fields = [
    "property_id", "property_type", "state", "city",
    "zip_code", "flood_zone", "current_value"
]


# COLLECTION: securities
securities_collection_config = {
    "collection_name": "xyz_securities",
    "vectors_config": VectorParams(
        size=768,
        distance=Distance.COSINE
    ),
    "optimizers_config": {
        "default_segment_number": 2,
        "indexing_threshold": 10000
    },
    "hnsw_config": {
        "m": 16,
        "ef_construct": 100,
        "full_scan_threshold": 10000
    }
}

securities_payload_schema = {
    "security_id": PayloadSchemaType.INTEGER,
    "security_name": PayloadSchemaType.TEXT,
    "security_type": PayloadSchemaType.KEYWORD,
    "cusip": PayloadSchemaType.KEYWORD,
    "issue_date": PayloadSchemaType.DATETIME,
    "maturity_date": PayloadSchemaType.DATETIME,
    "coupon_rate": PayloadSchemaType.FLOAT,
    "face_value": PayloadSchemaType.FLOAT,
    "current_balance": PayloadSchemaType.FLOAT,
    "issuer": PayloadSchemaType.KEYWORD,
    "rating": PayloadSchemaType.KEYWORD,
    "status": PayloadSchemaType.KEYWORD,
    "last_trade_date": PayloadSchemaType.DATETIME,
    "last_trade_price": PayloadSchemaType.FLOAT,
    "security_description_text": PayloadSchemaType.TEXT,
    "record_type": PayloadSchemaType.KEYWORD
}

securities_indexed_fields = [
    "security_id", "security_type", "cusip",
    "issuer", "rating", "status"
]


# COLLECTION: applications
applications_collection_config = {
    "collection_name": "xyz_applications",
    "vectors_config": VectorParams(
        size=768,
        distance=Distance.COSINE
    ),
    "optimizers_config": {
        "default_segment_number": 2,
        "indexing_threshold": 10000
    },
    "hnsw_config": {
        "m": 16,
        "ef_construct": 100,
        "full_scan_threshold": 10000
    }
}

applications_payload_schema = {
    "application_id": PayloadSchemaType.INTEGER,
    "customer_id": PayloadSchemaType.INTEGER,
    "product_id": PayloadSchemaType.INTEGER,
    "officer_id": PayloadSchemaType.INTEGER,
    "application_date": PayloadSchemaType.DATETIME,
    "loan_amount": PayloadSchemaType.FLOAT,
    "loan_purpose": PayloadSchemaType.KEYWORD,
    "status": PayloadSchemaType.KEYWORD,
    "closing_date": PayloadSchemaType.DATETIME,
    "application_fee": PayloadSchemaType.FLOAT,
    "dti": PayloadSchemaType.FLOAT,
    "property_value": PayloadSchemaType.FLOAT,
    "ltv": PayloadSchemaType.FLOAT,
    "rate_offered": PayloadSchemaType.FLOAT,
    "term_offered": PayloadSchemaType.INTEGER,
    "denial_reason": PayloadSchemaType.TEXT,
    "application_summary_text": PayloadSchemaType.TEXT,
    "record_type": PayloadSchemaType.KEYWORD
}

applications_indexed_fields = [
    "application_id", "customer_id", "status",
    "loan_purpose", "application_date", "officer_id"
]


# COLLECTION: documents
documents_collection_config = {
    "collection_name": "xyz_documents",
    "vectors_config": VectorParams(
        size=768,
        distance=Distance.COSINE
    ),
    "optimizers_config": {
        "default_segment_number": 2,
        "indexing_threshold": 10000
    },
    "hnsw_config": {
        "m": 16,
        "ef_construct": 100,
        "full_scan_threshold": 10000
    }
}

documents_payload_schema = {
    "document_id": PayloadSchemaType.INTEGER,
    "application_id": PayloadSchemaType.INTEGER,
    "document_type": PayloadSchemaType.KEYWORD,
    "file_name": PayloadSchemaType.TEXT,
    "upload_date": PayloadSchemaType.DATETIME,
    "required_flag": PayloadSchemaType.BOOL,
    "received_flag": PayloadSchemaType.BOOL,
    "approval_status": PayloadSchemaType.KEYWORD,
    "approval_date": PayloadSchemaType.DATETIME,
    "approved_by": PayloadSchemaType.KEYWORD,
    "notes": PayloadSchemaType.TEXT,
    "document_text_content": PayloadSchemaType.TEXT,
    "record_type": PayloadSchemaType.KEYWORD
}

documents_indexed_fields = [
    "document_id", "application_id", "document_type",
    "approval_status", "upload_date"
]


# COLLECTION: payments
payments_collection_config = {
    "collection_name": "xyz_payments",
    "vectors_config": VectorParams(
        size=384,
        distance=Distance.COSINE
    ),
    "optimizers_config": {
        "default_segment_number": 2,
        "indexing_threshold": 10000
    },
    "hnsw_config": {
        "m": 16,
        "ef_construct": 100,
        "full_scan_threshold": 10000
    }
}

payments_payload_schema = {
    "payment_id": PayloadSchemaType.INTEGER,
    "loan_id": PayloadSchemaType.INTEGER,
    "payment_date": PayloadSchemaType.DATETIME,
    "payment_amount": PayloadSchemaType.FLOAT,
    "principal_amount": PayloadSchemaType.FLOAT,
    "interest_amount": PayloadSchemaType.FLOAT,
    "escrow_amount": PayloadSchemaType.FLOAT,
    "late_fee_amount": PayloadSchemaType.FLOAT,
    "payment_method": PayloadSchemaType.KEYWORD,
    "transaction_id": PayloadSchemaType.KEYWORD,
    "payment_status": PayloadSchemaType.KEYWORD,
    "processed_date": PayloadSchemaType.DATETIME,
    "payment_pattern_text": PayloadSchemaType.TEXT,
    "record_type": PayloadSchemaType.KEYWORD
}

payments_indexed_fields = [
    "payment_id", "loan_id", "payment_status",
    "payment_method", "payment_date"
]


# ============================================================
# HELPER FUNCTIONS
# ============================================================

def create_all_collections(host: str = "localhost", port: int = 6333):
    """
    Create all Qdrant collections with indexes
    
    Args:
        host: Qdrant server host
        port: Qdrant server port
    """
    client = QdrantClient(host=host, port=port)
    
    collections = [
        (customers_collection_config, customers_payload_schema, customers_indexed_fields),
        (loans_collection_config, loans_payload_schema, loans_indexed_fields),
        (properties_collection_config, properties_payload_schema, properties_indexed_fields),
        (securities_collection_config, securities_payload_schema, securities_indexed_fields),
        (applications_collection_config, applications_payload_schema, applications_indexed_fields),
        (documents_collection_config, documents_payload_schema, documents_indexed_fields),
        (payments_collection_config, payments_payload_schema, payments_indexed_fields)
    ]
    
    for config, payload_schema, indexed_fields in collections:
        try:
            # Create collection
            client.create_collection(
                collection_name=config["collection_name"],
                vectors_config=config["vectors_config"]
            )
            print(f"✓ Created collection: {config['collection_name']}")
            
            # Create payload indexes
            for field in indexed_fields:
                client.create_payload_index(
                    collection_name=config["collection_name"],
                    field_name=field,
                    field_schema=payload_schema[field]
                )
            print(f"  ✓ Created {len(indexed_fields)} payload indexes")
            
        except Exception as e:
            print(f"✗ Error creating collection {config['collection_name']}: {str(e)}")


def upsert_customer_example(host: str = "localhost", port: int = 6333):
    """
    Example: Upsert a customer record
    """
    client = QdrantClient(host=host, port=port)
    
    # Example embedding (replace with actual embeddings)
    embedding = [0.1] * 768
    
    client.upsert(
        collection_name="xyz_customers",
        points=[
            PointStruct(
                id=1000,
                vector=embedding,
                payload={
                    "customer_id": 1000,
                    "full_name": "John Doe",
                    "first_name": "John",
                    "last_name": "Doe",
                    "email": "john.doe@example.com",
                    "phone": "555-1234",
                    "annual_income": 85000.0,
                    "employment_status": "Employed",
                    "employer": "Tech Corp",
                    "years_employed": 5,
                    "credit_score": 750,
                    "created_date": "2023-01-15T10:00:00Z",
                    "last_updated_date": "2025-12-27T10:00:00Z",
                    "customer_profile_text": "John Doe, employed software engineer with excellent credit",
                    "record_type": "customer"
                }
            )
        ]
    )
    print("✓ Customer record upserted successfully")


def search_customers_example(host: str = "localhost", port: int = 6333):
    """
    Example: Search customers with filters
    """
    client = QdrantClient(host=host, port=port)
    
    # Example query embedding
    query_embedding = [0.1] * 768
    
    search_result = client.search(
        collection_name="xyz_customers",
        query_vector=query_embedding,
        query_filter=Filter(
            must=[
                FieldCondition(
                    key="credit_score",
                    range=Range(gte=700)
                ),
                FieldCondition(
                    key="employment_status",
                    match={"value": "Employed"}
                )
            ]
        ),
        limit=10
    )
    
    print(f"Found {len(search_result)} matching customers:")
    for result in search_result:
        print(f"  - {result.payload.get('full_name')} (score: {result.score})")
    
    return search_result


def upsert_loan_example(host: str = "localhost", port: int = 6333):
    """
    Example: Upsert a loan record
    """
    client = QdrantClient(host=host, port=port)
    
    embedding = [0.1] * 768
    
    client.upsert(
        collection_name="xyz_loans",
        points=[
            PointStruct(
                id=100000,
                vector=embedding,
                payload={
                    "loan_id": 100000,
                    "application_id": 10000,
                    "customer_id": 1000,
                    "property_id": 1,
                    "product_id": 1,
                    "loan_amount": 350000.0,
                    "interest_rate": 3.75,
                    "term": 360,
                    "origination_date": "2023-06-15T00:00:00Z",
                    "maturity_date": "2053-06-15T00:00:00Z",
                    "monthly_payment": 1620.91,
                    "remaining_balance": 345000.0,
                    "status": "Active",
                    "escrow_required": True,
                    "pmi_required": False,
                    "pmi_amount": 0.0,
                    "next_payment_date": "2026-01-01T00:00:00Z",
                    "payment_frequency": "Monthly",
                    "security_id": 1,
                    "loan_summary_text": "30-year fixed rate mortgage for single family home",
                    "record_type": "loan"
                }
            )
        ]
    )
    print("✓ Loan record upserted successfully")


def scroll_all_customers_example(host: str = "localhost", port: int = 6333):
    """
    Example: Scroll through all customers
    """
    client = QdrantClient(host=host, port=port)
    
    offset = None
    all_customers = []
    
    while True:
        result = client.scroll(
            collection_name="xyz_customers",
            limit=100,
            offset=offset
        )
        
        all_customers.extend(result[0])
        
        if result[1] is None:
            break
        
        offset = result[1]
    
    print(f"Retrieved {len(all_customers)} total customers")
    return all_customers


def get_collection_info(host: str = "localhost", port: int = 6333):
    """
    Get information about all collections
    """
    client = QdrantClient(host=host, port=port)
    
    collections = client.get_collections()
    
    print("\nQdrant Collections:")
    print("-" * 60)
    for collection in collections.collections:
        info = client.get_collection(collection.name)
        print(f"\n{collection.name}:")
        print(f"  Vector size: {info.config.params.vectors.size}")
        print(f"  Points count: {info.points_count}")
        print(f"  Indexed payload fields: {len(info.payload_schema) if info.payload_schema else 0}")


# ============================================================
# MAIN EXECUTION
# ============================================================

if __name__ == "__main__":
    HOST = "localhost"
    PORT = 6333
    
    # Uncomment to use:
    # create_all_collections(HOST, PORT)
    # upsert_customer_example(HOST, PORT)
    # search_customers_example(HOST, PORT)
    # upsert_loan_example(HOST, PORT)
    # get_collection_info(HOST, PORT)
    
    print("Qdrant schema configuration loaded successfully!")
    print("\nAvailable collections:")
    print("  - xyz_customers")
    print("  - xyz_loans")
    print("  - xyz_properties")
    print("  - xyz_securities")
    print("  - xyz_applications")
    print("  - xyz_documents")
    print("  - xyz_payments")

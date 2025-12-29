
"""
Milvus Vector Database Schema for XYZ Financials Securities
Save as: milvus_schema.py
"""

from pymilvus import CollectionSchema, FieldSchema, DataType, connections, Collection

# ============================================================
# COLLECTION: Customers
# ============================================================
customers_fields = [
    FieldSchema(name="customer_id", dtype=DataType.INT64, is_primary=True, auto_id=False),
    FieldSchema(name="full_name", dtype=DataType.VARCHAR, max_length=200),
    FieldSchema(name="first_name", dtype=DataType.VARCHAR, max_length=100),
    FieldSchema(name="last_name", dtype=DataType.VARCHAR, max_length=100),
    FieldSchema(name="ssn_encrypted", dtype=DataType.VARCHAR, max_length=256),
    FieldSchema(name="email", dtype=DataType.VARCHAR, max_length=200),
    FieldSchema(name="phone", dtype=DataType.VARCHAR, max_length=50),
    FieldSchema(name="annual_income", dtype=DataType.DOUBLE),
    FieldSchema(name="employment_status", dtype=DataType.VARCHAR, max_length=100),
    FieldSchema(name="employer", dtype=DataType.VARCHAR, max_length=200),
    FieldSchema(name="years_employed", dtype=DataType.INT32),
    FieldSchema(name="credit_score", dtype=DataType.INT32),
    FieldSchema(name="created_date", dtype=DataType.INT64),  # Unix timestamp
    FieldSchema(name="last_updated_date", dtype=DataType.INT64),
    FieldSchema(name="customer_profile_text", dtype=DataType.VARCHAR, max_length=5000),
    FieldSchema(name="customer_embedding", dtype=DataType.FLOAT_VECTOR, dim=768)
]

customers_schema = CollectionSchema(
    fields=customers_fields,
    description="Customer profiles with embeddings",
    enable_dynamic_field=True
)

customers_index_params = {
    "metric_type": "COSINE",
    "index_type": "IVF_FLAT",
    "params": {"nlist": 1024}
}


# ============================================================
# COLLECTION: Loans
# ============================================================
loans_fields = [
    FieldSchema(name="loan_id", dtype=DataType.INT64, is_primary=True, auto_id=False),
    FieldSchema(name="application_id", dtype=DataType.INT64),
    FieldSchema(name="customer_id", dtype=DataType.INT64),
    FieldSchema(name="property_id", dtype=DataType.INT64),
    FieldSchema(name="product_id", dtype=DataType.INT64),
    FieldSchema(name="loan_amount", dtype=DataType.DOUBLE),
    FieldSchema(name="interest_rate", dtype=DataType.DOUBLE),
    FieldSchema(name="term", dtype=DataType.INT32),
    FieldSchema(name="origination_date", dtype=DataType.INT64),
    FieldSchema(name="maturity_date", dtype=DataType.INT64),
    FieldSchema(name="monthly_payment", dtype=DataType.DOUBLE),
    FieldSchema(name="remaining_balance", dtype=DataType.DOUBLE),
    FieldSchema(name="status", dtype=DataType.VARCHAR, max_length=50),
    FieldSchema(name="escrow_required", dtype=DataType.BOOL),
    FieldSchema(name="pmi_required", dtype=DataType.BOOL),
    FieldSchema(name="pmi_amount", dtype=DataType.DOUBLE),
    FieldSchema(name="next_payment_date", dtype=DataType.INT64),
    FieldSchema(name="payment_frequency", dtype=DataType.VARCHAR, max_length=50),
    FieldSchema(name="security_id", dtype=DataType.INT64),
    FieldSchema(name="loan_summary_text", dtype=DataType.VARCHAR, max_length=5000),
    FieldSchema(name="loan_embedding", dtype=DataType.FLOAT_VECTOR, dim=768)
]

loans_schema = CollectionSchema(
    fields=loans_fields,
    description="Loan records with embeddings",
    enable_dynamic_field=True
)

loans_index_params = {
    "metric_type": "COSINE",
    "index_type": "IVF_FLAT",
    "params": {"nlist": 1024}
}


# ============================================================
# COLLECTION: Properties
# ============================================================
properties_fields = [
    FieldSchema(name="property_id", dtype=DataType.INT64, is_primary=True, auto_id=False),
    FieldSchema(name="address_full", dtype=DataType.VARCHAR, max_length=500),
    FieldSchema(name="address_line1", dtype=DataType.VARCHAR, max_length=200),
    FieldSchema(name="city", dtype=DataType.VARCHAR, max_length=100),
    FieldSchema(name="state", dtype=DataType.VARCHAR, max_length=10),
    FieldSchema(name="zip_code", dtype=DataType.VARCHAR, max_length=20),
    FieldSchema(name="country", dtype=DataType.VARCHAR, max_length=100),
    FieldSchema(name="property_type", dtype=DataType.VARCHAR, max_length=100),
    FieldSchema(name="year_built", dtype=DataType.INT32),
    FieldSchema(name="square_feet", dtype=DataType.INT32),
    FieldSchema(name="bedrooms", dtype=DataType.INT32),
    FieldSchema(name="bathrooms", dtype=DataType.FLOAT),
    FieldSchema(name="purchase_price", dtype=DataType.DOUBLE),
    FieldSchema(name="current_value", dtype=DataType.DOUBLE),
    FieldSchema(name="last_appraisal_value", dtype=DataType.DOUBLE),
    FieldSchema(name="tax_assessment_value", dtype=DataType.DOUBLE),
    FieldSchema(name="annual_tax_amount", dtype=DataType.DOUBLE),
    FieldSchema(name="hoa_fees", dtype=DataType.DOUBLE),
    FieldSchema(name="flood_zone", dtype=DataType.VARCHAR, max_length=20),
    FieldSchema(name="latitude", dtype=DataType.DOUBLE),
    FieldSchema(name="longitude", dtype=DataType.DOUBLE),
    FieldSchema(name="property_description_text", dtype=DataType.VARCHAR, max_length=5000),
    FieldSchema(name="property_embedding", dtype=DataType.FLOAT_VECTOR, dim=768)
]

properties_schema = CollectionSchema(
    fields=properties_fields,
    description="Property details with embeddings",
    enable_dynamic_field=True
)

properties_index_params = {
    "metric_type": "COSINE",
    "index_type": "IVF_FLAT",
    "params": {"nlist": 1024}
}


# ============================================================
# COLLECTION: Securities
# ============================================================
securities_fields = [
    FieldSchema(name="security_id", dtype=DataType.INT64, is_primary=True, auto_id=False),
    FieldSchema(name="security_name", dtype=DataType.VARCHAR, max_length=200),
    FieldSchema(name="security_type", dtype=DataType.VARCHAR, max_length=100),
    FieldSchema(name="cusip", dtype=DataType.VARCHAR, max_length=20),
    FieldSchema(name="issue_date", dtype=DataType.INT64),
    FieldSchema(name="maturity_date", dtype=DataType.INT64),
    FieldSchema(name="coupon_rate", dtype=DataType.DOUBLE),
    FieldSchema(name="face_value", dtype=DataType.DOUBLE),
    FieldSchema(name="current_balance", dtype=DataType.DOUBLE),
    FieldSchema(name="issuer", dtype=DataType.VARCHAR, max_length=200),
    FieldSchema(name="rating", dtype=DataType.VARCHAR, max_length=20),
    FieldSchema(name="status", dtype=DataType.VARCHAR, max_length=50),
    FieldSchema(name="last_trade_date", dtype=DataType.INT64),
    FieldSchema(name="last_trade_price", dtype=DataType.DOUBLE),
    FieldSchema(name="security_description_text", dtype=DataType.VARCHAR, max_length=5000),
    FieldSchema(name="security_embedding", dtype=DataType.FLOAT_VECTOR, dim=768)
]

securities_schema = CollectionSchema(
    fields=securities_fields,
    description="Securities with embeddings",
    enable_dynamic_field=True
)

securities_index_params = {
    "metric_type": "COSINE",
    "index_type": "IVF_FLAT",
    "params": {"nlist": 1024}
}


# ============================================================
# COLLECTION: Applications
# ============================================================
applications_fields = [
    FieldSchema(name="application_id", dtype=DataType.INT64, is_primary=True, auto_id=False),
    FieldSchema(name="customer_id", dtype=DataType.INT64),
    FieldSchema(name="product_id", dtype=DataType.INT64),
    FieldSchema(name="officer_id", dtype=DataType.INT64),
    FieldSchema(name="application_date", dtype=DataType.INT64),
    FieldSchema(name="loan_amount", dtype=DataType.DOUBLE),
    FieldSchema(name="loan_purpose", dtype=DataType.VARCHAR, max_length=100),
    FieldSchema(name="status", dtype=DataType.VARCHAR, max_length=100),
    FieldSchema(name="closing_date", dtype=DataType.INT64),
    FieldSchema(name="application_fee", dtype=DataType.DOUBLE),
    FieldSchema(name="dti", dtype=DataType.DOUBLE),
    FieldSchema(name="property_value", dtype=DataType.DOUBLE),
    FieldSchema(name="ltv", dtype=DataType.DOUBLE),
    FieldSchema(name="rate_offered", dtype=DataType.DOUBLE),
    FieldSchema(name="term_offered", dtype=DataType.INT32),
    FieldSchema(name="denial_reason", dtype=DataType.VARCHAR, max_length=500),
    FieldSchema(name="application_summary_text", dtype=DataType.VARCHAR, max_length=5000),
    FieldSchema(name="application_embedding", dtype=DataType.FLOAT_VECTOR, dim=768)
]

applications_schema = CollectionSchema(
    fields=applications_fields,
    description="Loan applications with embeddings",
    enable_dynamic_field=True
)

applications_index_params = {
    "metric_type": "COSINE",
    "index_type": "IVF_FLAT",
    "params": {"nlist": 1024}
}


# ============================================================
# COLLECTION: Documents
# ============================================================
documents_fields = [
    FieldSchema(name="document_id", dtype=DataType.INT64, is_primary=True, auto_id=False),
    FieldSchema(name="application_id", dtype=DataType.INT64),
    FieldSchema(name="document_type", dtype=DataType.VARCHAR, max_length=200),
    FieldSchema(name="file_name", dtype=DataType.VARCHAR, max_length=500),
    FieldSchema(name="upload_date", dtype=DataType.INT64),
    FieldSchema(name="required_flag", dtype=DataType.BOOL),
    FieldSchema(name="received_flag", dtype=DataType.BOOL),
    FieldSchema(name="approval_status", dtype=DataType.VARCHAR, max_length=50),
    FieldSchema(name="approval_date", dtype=DataType.INT64),
    FieldSchema(name="approved_by", dtype=DataType.VARCHAR, max_length=200),
    FieldSchema(name="notes", dtype=DataType.VARCHAR, max_length=2000),
    FieldSchema(name="document_text_content", dtype=DataType.VARCHAR, max_length=10000),
    FieldSchema(name="document_content_embedding", dtype=DataType.FLOAT_VECTOR, dim=768)
]

documents_schema = CollectionSchema(
    fields=documents_fields,
    description="Document registry with content embeddings",
    enable_dynamic_field=True
)

documents_index_params = {
    "metric_type": "COSINE",
    "index_type": "IVF_FLAT",
    "params": {"nlist": 1024}
}


# ============================================================
# COLLECTION: Payments
# ============================================================
payments_fields = [
    FieldSchema(name="payment_id", dtype=DataType.INT64, is_primary=True, auto_id=False),
    FieldSchema(name="loan_id", dtype=DataType.INT64),
    FieldSchema(name="payment_date", dtype=DataType.INT64),
    FieldSchema(name="payment_amount", dtype=DataType.DOUBLE),
    FieldSchema(name="principal_amount", dtype=DataType.DOUBLE),
    FieldSchema(name="interest_amount", dtype=DataType.DOUBLE),
    FieldSchema(name="escrow_amount", dtype=DataType.DOUBLE),
    FieldSchema(name="late_fee_amount", dtype=DataType.DOUBLE),
    FieldSchema(name="payment_method", dtype=DataType.VARCHAR, max_length=100),
    FieldSchema(name="transaction_id", dtype=DataType.VARCHAR, max_length=200),
    FieldSchema(name="payment_status", dtype=DataType.VARCHAR, max_length=50),
    FieldSchema(name="processed_date", dtype=DataType.INT64),
    FieldSchema(name="payment_pattern_text", dtype=DataType.VARCHAR, max_length=2000),
    FieldSchema(name="payment_embedding", dtype=DataType.FLOAT_VECTOR, dim=384)
]

payments_schema = CollectionSchema(
    fields=payments_fields,
    description="Payment records with pattern embeddings",
    enable_dynamic_field=True
)

payments_index_params = {
    "metric_type": "COSINE",
    "index_type": "IVF_FLAT",
    "params": {"nlist": 512}
}


# ============================================================
# USAGE EXAMPLE
# ============================================================
def create_milvus_collections():
    """
    Example function to create all collections in Milvus
    """
    # Connect to Milvus
    connections.connect("default", host="localhost", port="19530")
    
    # Create collections
    customers_collection = Collection(
        name="customers",
        schema=customers_schema,
        using='default',
        shards_num=2
    )
    
    loans_collection = Collection(
        name="loans",
        schema=loans_schema,
        using='default',
        shards_num=2
    )
    
    properties_collection = Collection(
        name="properties",
        schema=properties_schema,
        using='default',
        shards_num=2
    )
    
    securities_collection = Collection(
        name="securities",
        schema=securities_schema,
        using='default',
        shards_num=2
    )
    
    applications_collection = Collection(
        name="applications",
        schema=applications_schema,
        using='default',
        shards_num=2
    )
    
    documents_collection = Collection(
        name="documents",
        schema=documents_schema,
        using='default',
        shards_num=2
    )
    
    payments_collection = Collection(
        name="payments",
        schema=payments_schema,
        using='default',
        shards_num=2
    )
    
    # Create indexes
    customers_collection.create_index(
        field_name="customer_embedding",
        index_params=customers_index_params
    )
    
    loans_collection.create_index(
        field_name="loan_embedding",
        index_params=loans_index_params
    )
    
    properties_collection.create_index(
        field_name="property_embedding",
        index_params=properties_index_params
    )
    
    securities_collection.create_index(
        field_name="security_embedding",
        index_params=securities_index_params
    )
    
    applications_collection.create_index(
        field_name="application_embedding",
        index_params=applications_index_params
    )
    
    documents_collection.create_index(
        field_name="document_content_embedding",
        index_params=documents_index_params
    )
    
    payments_collection.create_index(
        field_name="payment_embedding",
        index_params=payments_index_params
    )
    
    # Load collections into memory
    customers_collection.load()
    loans_collection.load()
    properties_collection.load()
    securities_collection.load()
    applications_collection.load()
    documents_collection.load()
    payments_collection.load()
    
    print("All collections created and loaded successfully!")
    
    return {
        "customers": customers_collection,
        "loans": loans_collection,
        "properties": properties_collection,
        "securities": securities_collection,
        "applications": applications_collection,
        "documents": documents_collection,
        "payments": payments_collection
    }


if __name__ == "__main__":
    # Uncomment to create collections
    # collections = create_milvus_collections()
    pass

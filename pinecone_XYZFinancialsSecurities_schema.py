"""
Pinecone Vector Database Schema for XYZ Financials Securities
Save as: pinecone_schema.py
"""

import pinecone
from typing import Dict, List

# ============================================================
# INDEX CONFIGURATIONS
# ============================================================

# INDEX: customers
customers_index_config = {
    "name": "xyz-customers",
    "dimension": 768,
    "metric": "cosine",
    "pod_type": "p1.x1",
    "pods": 1,
    "replicas": 1,
    "metadata_config": {
        "indexed": [
            "customer_id",
            "credit_score",
            "employment_status",
            "annual_income_range",
            "created_year",
            "state"
        ]
    }
}

customers_metadata_schema = {
    "customer_id": "int",
    "full_name": "string",
    "first_name": "string",
    "last_name": "string",
    "email": "string",
    "phone": "string",
    "annual_income": "float",
    "annual_income_range": "string",
    "employment_status": "string",
    "employer": "string",
    "years_employed": "int",
    "credit_score": "int",
    "credit_score_range": "string",
    "created_date": "string",
    "created_year": "int",
    "last_updated_date": "string",
    "state": "string",
    "customer_profile_text": "string",
    "record_type": "string"
}


# INDEX: loans
loans_index_config = {
    "name": "xyz-loans",
    "dimension": 768,
    "metric": "cosine",
    "pod_type": "p1.x1",
    "pods": 1,
    "replicas": 1,
    "metadata_config": {
        "indexed": [
            "loan_id",
            "customer_id",
            "status",
            "origination_year",
            "loan_amount_range",
            "interest_rate_range",
            "property_state"
        ]
    }
}

loans_metadata_schema = {
    "loan_id": "int",
    "application_id": "int",
    "customer_id": "int",
    "property_id": "int",
    "product_id": "int",
    "loan_amount": "float",
    "loan_amount_range": "string",
    "interest_rate": "float",
    "interest_rate_range": "string",
    "term": "int",
    "origination_date": "string",
    "origination_year": "int",
    "maturity_date": "string",
    "monthly_payment": "float",
    "remaining_balance": "float",
    "status": "string",
    "escrow_required": "bool",
    "pmi_required": "bool",
    "pmi_amount": "float",
    "next_payment_date": "string",
    "payment_frequency": "string",
    "security_id": "int",
    "property_state": "string",
    "property_zip": "string",
    "loan_summary_text": "string",
    "record_type": "string"
}


# INDEX: properties
properties_index_config = {
    "name": "xyz-properties",
    "dimension": 768,
    "metric": "cosine",
    "pod_type": "p1.x1",
    "pods": 1,
    "replicas": 1,
    "metadata_config": {
        "indexed": [
            "property_id",
            "property_type",
            "state",
            "city",
            "zip_code",
            "flood_zone",
            "value_range"
        ]
    }
}

properties_metadata_schema = {
    "property_id": "int",
    "address_full": "string",
    "address_line1": "string",
    "city": "string",
    "state": "string",
    "zip_code": "string",
    "country": "string",
    "property_type": "string",
    "year_built": "int",
    "square_feet": "int",
    "bedrooms": "int",
    "bathrooms": "float",
    "purchase_price": "float",
    "current_value": "float",
    "value_range": "string",
    "last_appraisal_date": "string",
    "last_appraisal_value": "float",
    "tax_assessment_value": "float",
    "annual_tax_amount": "float",
    "hoa_fees": "float",
    "flood_zone": "string",
    "property_tax_id": "string",
    "latitude": "float",
    "longitude": "float",
    "property_description_text": "string",
    "record_type": "string"
}


# INDEX: securities
securities_index_config = {
    "name": "xyz-securities",
    "dimension": 768,
    "metric": "cosine",
    "pod_type": "p1.x1",
    "pods": 1,
    "replicas": 1,
    "metadata_config": {
        "indexed": [
            "security_id",
            "security_type",
            "cusip",
            "rating",
            "status",
            "issuer"
        ]
    }
}

securities_metadata_schema = {
    "security_id": "int",
    "security_name": "string",
    "security_type": "string",
    "cusip": "string",
    "issue_date": "string",
    "maturity_date": "string",
    "coupon_rate": "float",
    "face_value": "float",
    "current_balance": "float",
    "issuer": "string",
    "rating": "string",
    "status": "string",
    "last_trade_date": "string",
    "last_trade_price": "float",
    "security_description_text": "string",
    "record_type": "string"
}


# INDEX: applications
applications_index_config = {
    "name": "xyz-applications",
    "dimension": 768,
    "metric": "cosine",
    "pod_type": "p1.x1",
    "pods": 1,
    "replicas": 1,
    "metadata_config": {
        "indexed": [
            "application_id",
            "customer_id",
            "status",
            "loan_purpose",
            "application_year",
            "officer_id"
        ]
    }
}

applications_metadata_schema = {
    "application_id": "int",
    "customer_id": "int",
    "product_id": "int",
    "officer_id": "int",
    "application_date": "string",
    "application_year": "int",
    "loan_amount": "float",
    "loan_purpose": "string",
    "status": "string",
    "closing_date": "string",
    "application_fee": "float",
    "dti": "float",
    "property_value": "float",
    "ltv": "float",
    "rate_offered": "float",
    "term_offered": "int",
    "denial_reason": "string",
    "application_summary_text": "string",
    "record_type": "string"
}


# INDEX: documents
documents_index_config = {
    "name": "xyz-documents",
    "dimension": 768,
    "metric": "cosine",
    "pod_type": "p1.x1",
    "pods": 1,
    "replicas": 1,
    "metadata_config": {
        "indexed": [
            "document_id",
            "application_id",
            "document_type",
            "approval_status",
            "upload_year"
        ]
    }
}

documents_metadata_schema = {
    "document_id": "int",
    "application_id": "int",
    "document_type": "string",
    "file_name": "string",
    "upload_date": "string",
    "upload_year": "int",
    "required_flag": "bool",
    "received_flag": "bool",
    "approval_status": "string",
    "approval_date": "string",
    "approved_by": "string",
    "notes": "string",
    "document_text_content": "string",
    "record_type": "string"
}


# INDEX: payments
payments_index_config = {
    "name": "xyz-payments",
    "dimension": 384,
    "metric": "cosine",
    "pod_type": "p1.x1",
    "pods": 1,
    "replicas": 1,
    "metadata_config": {
        "indexed": [
            "payment_id",
            "loan_id",
            "payment_status",
            "payment_method",
            "payment_year"
        ]
    }
}

payments_metadata_schema = {
    "payment_id": "int",
    "loan_id": "int",
    "payment_date": "string",
    "payment_year": "int",
    "payment_amount": "float",
    "principal_amount": "float",
    "interest_amount": "float",
    "escrow_amount": "float",
    "late_fee_amount": "float",
    "payment_method": "string",
    "transaction_id": "string",
    "payment_status": "string",
    "processed_date": "string",
    "payment_pattern_text": "string",
    "record_type": "string"
}


# ============================================================
# HELPER FUNCTIONS
# ============================================================

def create_all_indexes(api_key: str, environment: str):
    """
    Create all Pinecone indexes
    
    Args:
        api_key: Your Pinecone API key
        environment: Your Pinecone environment (e.g., 'us-west1-gcp')
    """
    pinecone.init(api_key=api_key, environment=environment)
    
    indexes_to_create = [
        customers_index_config,
        loans_index_config,
        properties_index_config,
        securities_index_config,
        applications_index_config,
        documents_index_config,
        payments_index_config
    ]
    
    for index_config in indexes_to_create:
        try:
            pinecone.create_index(
                name=index_config["name"],
                dimension=index_config["dimension"],
                metric=index_config["metric"],
                pod_type=index_config["pod_type"],
                metadata_config=index_config.get("metadata_config")
            )
            print(f"✓ Created index: {index_config['name']}")
        except Exception as e:
            print(f"✗ Error creating index {index_config['name']}: {str(e)}")


def upsert_customer_example(api_key: str, environment: str):
    """
    Example: Upsert a customer record
    """
    pinecone.init(api_key=api_key, environment=environment)
    customers_index = pinecone.Index("xyz-customers")
    
    # Example embedding (replace with actual embeddings)
    embedding = [0.1] * 768
    
    customers_index.upsert(
        vectors=[
            {
                "id": "customer_1000",
                "values": embedding,
                "metadata": {
                    "customer_id": 1000,
                    "full_name": "John Doe",
                    "first_name": "John",
                    "last_name": "Doe",
                    "email": "john.doe@example.com",
                    "phone": "555-1234",
                    "annual_income": 85000.00,
                    "annual_income_range": "50k-100k",
                    "employment_status": "Employed",
                    "employer": "Tech Corp",
                    "years_employed": 5,
                    "credit_score": 750,
                    "credit_score_range": "700-800",
                    "created_date": "2023-01-15",
                    "created_year": 2023,
                    "customer_profile_text": "John Doe, employed software engineer...",
                    "record_type": "customer"
                }
            }
        ]
    )
    print("✓ Customer record upserted successfully")


def query_customers_example(api_key: str, environment: str):
    """
    Example: Query customers with filters
    """
    pinecone.init(api_key=api_key, environment=environment)
    customers_index = pinecone.Index("xyz-customers")
    
    # Example query embedding
    query_embedding = [0.1] * 768
    
    results = customers_index.query(
        vector=query_embedding,
        top_k=10,
        filter={
            "credit_score": {"$gte": 700},
            "employment_status": {"$eq": "Employed"}
        },
        include_metadata=True
    )
    
    print(f"Found {len(results.matches)} matching customers")
    for match in results.matches:
        print(f"  - {match.metadata.get('full_name')} (score: {match.score})")
    
    return results


def upsert_loan_example(api_key: str, environment: str):
    """
    Example: Upsert a loan record
    """
    pinecone.init(api_key=api_key, environment=environment)
    loans_index = pinecone.Index("xyz-loans")
    
    embedding = [0.1] * 768
    
    loans_index.upsert(
        vectors=[
            {
                "id": "loan_100000",
                "values": embedding,
                "metadata": {
                    "loan_id": 100000,
                    "customer_id": 1000,
                    "property_id": 1,
                    "loan_amount": 350000.00,
                    "loan_amount_range": "250k-500k",
                    "interest_rate": 3.75,
                    "interest_rate_range": "3.0-4.0",
                    "term": 360,
                    "origination_date": "2023-06-15",
                    "origination_year": 2023,
                    "maturity_date": "2053-06-15",
                    "monthly_payment": 1620.91,
                    "remaining_balance": 345000.00,
                    "status": "Active",
                    "escrow_required": True,
                    "pmi_required": False,
                    "property_state": "CA",
                    "property_zip": "90210",
                    "loan_summary_text": "30-year fixed rate mortgage...",
                    "record_type": "loan"
                }
            }
        ]
    )
    print("✓ Loan record upserted successfully")


# ============================================================
# MAIN EXECUTION
# ============================================================

if __name__ == "__main__":
    # Configuration
    API_KEY = "your-pinecone-api-key"
    ENVIRONMENT = "us-west1-gcp"
    
    # Uncomment to use:
    # create_all_indexes(API_KEY, ENVIRONMENT)
    # upsert_customer_example(API_KEY, ENVIRONMENT)
    # query_customers_example(API_KEY, ENVIRONMENT)
    # upsert_loan_example(API_KEY, ENVIRONMENT)
    
    print("Pinecone schema configuration loaded successfully!")
    print("\nAvailable indexes:")
    print("  - xyz-customers")
    print("  - xyz-loans")
    print("  - xyz-properties")
    print("  - xyz-securities")
    print("  - xyz-applications")
    print("  - xyz-documents")
    print("  - xyz-payments")

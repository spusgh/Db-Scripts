"""
ChromaDB Schema for XYZ Financials Securities
==============================================
File: chromadb_schema.py

ChromaDB is best for: Development, prototyping, embedded applications
- Simple Python-first API
- No external dependencies
- Good for small to medium datasets (< 1M vectors)
- Persistent storage with DuckDB backend
"""

import chromadb
from chromadb.config import Settings
from chromadb.utils import embedding_functions
from datetime import datetime
import numpy as np

# =============================================
# CONFIGURATION
# =============================================

# Initialize ChromaDB with persistent storage
chroma_client = chromadb.PersistentClient(
    path="./xyz_financials_chroma_db",
    settings=Settings(
        anonymized_telemetry=False,
        allow_reset=True
    )
)

# Configure embedding function
# Options: default, sentence-transformers, openai, cohere, huggingface
embedding_function = embedding_functions.SentenceTransformerEmbeddingFunction(
    model_name="all-MiniLM-L6-v2"  # 384 dimensions, fast
    # Alternative: "paraphrase-MiniLM-L6-v2" for better semantic understanding
)

# =============================================
# COLLECTION DEFINITIONS
# =============================================

def create_all_collections():
    """Create all ChromaDB collections for the financial system"""
    
    # 1. CUSTOMERS COLLECTION
    customers = chroma_client.get_or_create_collection(
        name="customers",
        embedding_function=embedding_function,
        metadata={
            "description": "Customer profiles with financial and demographic data",
            "hnsw:space": "cosine",
            "hnsw:construction_ef": 100,
            "hnsw:search_ef": 100
        }
    )
    
    # 2. LOANS COLLECTION
    loans = chroma_client.get_or_create_collection(
        name="loans",
        embedding_function=embedding_function,
        metadata={
            "description": "Mortgage loan records with terms and status",
            "hnsw:space": "cosine"
        }
    )
    
    # 3. APPLICATIONS COLLECTION
    applications = chroma_client.get_or_create_collection(
        name="applications",
        embedding_function=embedding_function,
        metadata={
            "description": "Loan applications with risk assessments",
            "hnsw:space": "cosine"
        }
    )
    
    # 4. PROPERTIES COLLECTION
    properties = chroma_client.get_or_create_collection(
        name="properties",
        embedding_function=embedding_function,
        metadata={
            "description": "Property details and characteristics",
            "hnsw:space": "cosine"
        }
    )
    
    # 5. DOCUMENTS COLLECTION
    documents = chroma_client.get_or_create_collection(
        name="documents",
        embedding_function=embedding_function,
        metadata={
            "description": "Application documents and extracted content",
            "hnsw:space": "cosine"
        }
    )
    
    # 6. RISK ASSESSMENTS COLLECTION
    risk_assessments = chroma_client.get_or_create_collection(
        name="risk_assessments",
        embedding_function=embedding_function,
        metadata={
            "description": "Risk assessment narratives and recommendations",
            "hnsw:space": "cosine"
        }
    )
    
    # 7. DEFAULTS COLLECTION
    defaults = chroma_client.get_or_create_collection(
        name="defaults",
        embedding_function=embedding_function,
        metadata={
            "description": "Default and foreclosure case histories",
            "hnsw:space": "cosine"
        }
    )
    
    # 8. LOAN MODIFICATIONS COLLECTION
    modifications = chroma_client.get_or_create_collection(
        name="loan_modifications",
        embedding_function=embedding_function,
        metadata={
            "description": "Loan term modification records",
            "hnsw:space": "cosine"
        }
    )
    
    return {
        "customers": customers,
        "loans": loans,
        "applications": applications,
        "properties": properties,
        "documents": documents,
        "risk_assessments": risk_assessments,
        "defaults": defaults,
        "modifications": modifications
    }

# =============================================
# TEXT GENERATION FUNCTIONS
# =============================================

def generate_customer_text(customer_data):
    """Generate rich text representation of customer for embedding"""
    age = datetime.now().year - customer_data.get('dateOfBirth', datetime.now()).year if customer_data.get('dateOfBirth') else 'Unknown'
    
    return f"""
Customer Profile: {customer_data['firstName']} {customer_data['lastName']}
Age: {age} years old
Credit Score: {customer_data.get('creditScore', 'N/A')}
Annual Income: ${customer_data.get('annualIncome', 0):,.2f}
Employment: {customer_data.get('employmentStatus', 'Unknown')} at {customer_data.get('employer', 'N/A')}
Years Employed: {customer_data.get('yearsEmployed', 0)} years
Location: {customer_data.get('city', '')}, {customer_data.get('state', '')}
Email: {customer_data.get('email', '')}
Phone: {customer_data.get('phone', '')}
    """.strip()

def generate_loan_text(loan_data):
    """Generate rich text representation of loan for embedding"""
    return f"""
Mortgage Loan #{loan_data['loanId']}
Loan Amount: ${loan_data['loanAmount']:,.2f}
Interest Rate: {loan_data['interestRate']}% APR
Term: {loan_data['term']} months ({loan_data['term']//12} years)
Monthly Payment: ${loan_data['monthlyPayment']:,.2f}
Remaining Balance: ${loan_data['remainingBalance']:,.2f}
Loan Status: {loan_data['status']}
Product Type: {loan_data.get('productType', 'Conventional')}
Property Type: {loan_data.get('propertyType', 'Single Family')}
Property Location: {loan_data.get('propertyCity', '')}, {loan_data.get('propertyState', '')}
Origination Date: {loan_data['originationDate']}
Loan-to-Value Ratio: {loan_data.get('ltv', 0)}%
Debt-to-Income Ratio: {loan_data.get('dti', 0)}%
Escrow Required: {'Yes' if loan_data.get('escrowRequired') else 'No'}
PMI Required: {'Yes' if loan_data.get('pmiRequired') else 'No'}
    """.strip()

def generate_application_text(app_data):
    """Generate rich text representation of application for embedding"""
    return f"""
Loan Application #{app_data['applicationId']}
Customer ID: {app_data['customerId']}
Application Date: {app_data['applicationDate']}
Requested Amount: ${app_data['loanAmount']:,.2f}
Loan Purpose: {app_data['loanPurpose']}
Application Status: {app_data['status']}
Property Value: ${app_data.get('propertyValue', 0):,.2f}
Credit Score: {app_data.get('creditScore', 'N/A')}
Debt-to-Income: {app_data.get('dti', 0)}%
Loan-to-Value: {app_data.get('ltv', 0)}%
Risk Classification: {app_data.get('riskClassification', 'Not Assessed')}
Risk Notes: {app_data.get('riskNotes', '')}
Loan Officer ID: {app_data['officerId']}
Rate Offered: {app_data.get('rateOffered', 0)}%
Term Offered: {app_data.get('termOffered', 0)} months
Denial Reason: {app_data.get('denialReason', 'N/A')}
    """.strip()

def generate_property_text(prop_data):
    """Generate rich text representation of property for embedding"""
    return f"""
Property #{prop_data['propertyId']}
Address: {prop_data['addressLine1']}
{prop_data.get('addressLine2', '')}
City: {prop_data['city']}, State: {prop_data['state']} {prop_data['zipCode']}
Property Type: {prop_data['propertyType']}
Year Built: {prop_data.get('yearBuilt', 'Unknown')}
Square Feet: {prop_data.get('squareFeet', 0):,}
Bedrooms: {prop_data.get('bedrooms', 0)}
Bathrooms: {prop_data.get('bathrooms', 0)}
Purchase Price: ${prop_data.get('purchasePrice', 0):,.2f}
Current Value: ${prop_data.get('currentValue', 0):,.2f}
Last Appraisal: ${prop_data.get('lastAppraisalValue', 0):,.2f} on {prop_data.get('lastAppraisalDate', 'N/A')}
Annual Taxes: ${prop_data.get('annualTaxAmount', 0):,.2f}
HOA Fees: ${prop_data.get('hoaFees', 0):,.2f}
Flood Zone: {prop_data.get('floodZone', 'X')}
Coordinates: {prop_data.get('latitude', 0)}, {prop_data.get('longitude', 0)}
    """.strip()

def generate_default_text(default_data):
    """Generate rich text representation of default case"""
    return f"""
Default Case #{default_data['defaultId']}
Loan ID: {default_data['loanId']}
Default Date: {default_data['defaultDate']}
Current Stage: {default_data['stage']}
Reason Code: {default_data.get('reasonCode', 'Unknown')}
Resolution Type: {default_data.get('resolutionType', 'Pending')}
Resolution Date: {default_data.get('resolutionDate', 'Ongoing')}
Loss Amount: ${default_data.get('lossAmount', 0):,.2f}
Collection Agency: {default_data.get('collectionAgency', 'None')}
Legal Filing Date: {default_data.get('legalFilingDate', 'N/A')}
Legal Case Number: {default_data.get('legalCaseNumber', 'N/A')}
Notes: {default_data.get('notes', '')}
    """.strip()

# =============================================
# DATA INGESTION FUNCTIONS
# =============================================

def ingest_customer(customer_data):
    """Ingest customer into ChromaDB"""
    collection = chroma_client.get_collection("customers")
    
    text = generate_customer_text(customer_data)
    
    collection.add(
        documents=[text],
        metadatas=[{
            "customerId": customer_data['customerId'],
            "fullName": f"{customer_data['firstName']} {customer_data['lastName']}",
            "email": customer_data.get('email', ''),
            "phone": customer_data.get('phone', ''),
            "creditScore": customer_data.get('creditScore', 0),
            "annualIncome": float(customer_data.get('annualIncome', 0)),
            "employmentStatus": customer_data.get('employmentStatus', ''),
            "city": customer_data.get('city', ''),
            "state": customer_data.get('state', ''),
            "createdDate": customer_data.get('createdDate', datetime.now().isoformat())
        }],
        ids=[f"customer_{customer_data['customerId']}"]
    )

def ingest_loan(loan_data):
    """Ingest loan into ChromaDB"""
    collection = chroma_client.get_collection("loans")
    
    text = generate_loan_text(loan_data)
    
    collection.add(
        documents=[text],
        metadatas=[{
            "loanId": loan_data['loanId'],
            "customerId": loan_data['customerId'],
            "propertyId": loan_data['propertyId'],
            "loanAmount": float(loan_data['loanAmount']),
            "interestRate": float(loan_data['interestRate']),
            "remainingBalance": float(loan_data['remainingBalance']),
            "status": loan_data['status'],
            "originationDate": loan_data['originationDate'].isoformat() if hasattr(loan_data['originationDate'], 'isoformat') else str(loan_data['originationDate']),
            "productType": loan_data.get('productType', ''),
            "propertyState": loan_data.get('propertyState', ''),
            "ltv": float(loan_data.get('ltv', 0)),
            "dti": float(loan_data.get('dti', 0))
        }],
        ids=[f"loan_{loan_data['loanId']}"]
    )

def ingest_application(app_data):
    """Ingest application into ChromaDB"""
    collection = chroma_client.get_collection("applications")
    
    text = generate_application_text(app_data)
    
    collection.add(
        documents=[text],
        metadatas=[{
            "applicationId": app_data['applicationId'],
            "customerId": app_data['customerId'],
            "officerId": app_data['officerId'],
            "loanAmount": float(app_data['loanAmount']),
            "loanPurpose": app_data['loanPurpose'],
            "status": app_data['status'],
            "applicationDate": app_data['applicationDate'].isoformat() if hasattr(app_data['applicationDate'], 'isoformat') else str(app_data['applicationDate']),
            "creditScore": app_data.get('creditScore', 0),
            "riskClassification": app_data.get('riskClassification', ''),
            "ltv": float(app_data.get('ltv', 0)),
            "dti": float(app_data.get('dti', 0))
        }],
        ids=[f"application_{app_data['applicationId']}"]
    )

def ingest_property(prop_data):
    """Ingest property into ChromaDB"""
    collection = chroma_client.get_collection("properties")
    
    text = generate_property_text(prop_data)
    
    collection.add(
        documents=[text],
        metadatas=[{
            "propertyId": prop_data['propertyId'],
            "city": prop_data['city'],
            "state": prop_data['state'],
            "zipCode": prop_data['zipCode'],
            "propertyType": prop_data['propertyType'],
            "squareFeet": prop_data.get('squareFeet', 0),
            "bedrooms": prop_data.get('bedrooms', 0),
            "currentValue": float(prop_data.get('currentValue', 0)),
            "latitude": float(prop_data.get('latitude', 0)),
            "longitude": float(prop_data.get('longitude', 0))
        }],
        ids=[f"property_{prop_data['propertyId']}"]
    )

def ingest_default(default_data):
    """Ingest default case into ChromaDB"""
    collection = chroma_client.get_collection("defaults")
    
    text = generate_default_text(default_data)
    
    collection.add(
        documents=[text],
        metadatas=[{
            "defaultId": default_data['defaultId'],
            "loanId": default_data['loanId'],
            "defaultDate": default_data['defaultDate'].isoformat() if hasattr(default_data['defaultDate'], 'isoformat') else str(default_data['defaultDate']),
            "stage": default_data['stage'],
            "reasonCode": default_data.get('reasonCode', ''),
            "resolutionType": default_data.get('resolutionType', ''),
            "lossAmount": float(default_data.get('lossAmount', 0))
        }],
        ids=[f"default_{default_data['defaultId']}"]
    )

# =============================================
# QUERY FUNCTIONS
# =============================================

def search_similar_customers(query_text, n_results=10, where_filter=None):
    """Search for similar customers"""
    collection = chroma_client.get_collection("customers")
    
    results = collection.query(
        query_texts=[query_text],
        n_results=n_results,
        where=where_filter
    )
    
    return results

def search_loans(query_text, n_results=10, where_filter=None):
    """Search loans with optional filters"""
    collection = chroma_client.get_collection("loans")
    
    results = collection.query(
        query_texts=[query_text],
        n_results=n_results,
        where=where_filter
    )
    
    return results

def find_similar_applications(application_id, n_results=5):
    """Find applications similar to a given application"""
    collection = chroma_client.get_collection("applications")
    
    # Get the application
    app = collection.get(ids=[f"application_{application_id}"])
    
    if not app['documents']:
        return None
    
    # Search using the application's document
    results = collection.query(
        query_texts=app['documents'],
        n_results=n_results + 1  # +1 to exclude itself
    )
    
    # Filter out the query application itself
    filtered_results = {
        'ids': [results['ids'][0][i] for i in range(len(results['ids'][0])) 
                if results['ids'][0][i] != f"application_{application_id}"],
        'documents': [results['documents'][0][i] for i in range(len(results['documents'][0])) 
                     if results['ids'][0][i] != f"application_{application_id}"],
        'metadatas': [results['metadatas'][0][i] for i in range(len(results['metadatas'][0])) 
                     if results['ids'][0][i] != f"application_{application_id}"],
        'distances': [results['distances'][0][i] for i in range(len(results['distances'][0])) 
                     if results['ids'][0][i] != f"application_{application_id}"]
    }
    
    return filtered_results

# =============================================
# FILTER EXAMPLES
# =============================================

def search_high_value_loans():
    """Search for high-value loans"""
    return search_loans(
        query_text="high value conventional mortgage",
        n_results=20,
        where_filter={
            "$and": [
                {"loanAmount": {"$gte": 500000}},
                {"status": {"$eq": "Active"}}
            ]
        }
    )

def search_high_risk_applications():
    """Search for high-risk applications"""
    collection = chroma_client.get_collection("applications")
    
    results = collection.query(
        query_texts=["high risk default potential financial hardship"],
        n_results=20,
        where={
            "riskClassification": {"$eq": "High"}
        }
    )
    
    return results

def search_properties_by_location(state, min_value=None):
    """Search properties in a specific state"""
    where_filter = {"state": {"$eq": state}}
    
    if min_value:
        where_filter = {
            "$and": [
                {"state": {"$eq": state}},
                {"currentValue": {"$gte": min_value}}
            ]
        }
    
    collection = chroma_client.get_collection("properties")
    
    results = collection.query(
        query_texts=["residential property"],
        n_results=50,
        where=where_filter
    )
    
    return results

# =============================================
# BATCH OPERATIONS
# =============================================

def batch_ingest_customers(customers_list):
    """Batch ingest multiple customers"""
    collection = chroma_client.get_collection("customers")
    
    documents = []
    metadatas = []
    ids = []
    
    for customer in customers_list:
        documents.append(generate_customer_text(customer))
        metadatas.append({
            "customerId": customer['customerId'],
            "fullName": f"{customer['firstName']} {customer['lastName']}",
            "creditScore": customer.get('creditScore', 0),
            "state": customer.get('state', '')
        })
        ids.append(f"customer_{customer['customerId']}")
    
    collection.add(
        documents=documents,
        metadatas=metadatas,
        ids=ids
    )

# =============================================
# UTILITY FUNCTIONS
# =============================================

def get_collection_stats(collection_name):
    """Get statistics for a collection"""
    collection = chroma_client.get_collection(collection_name)
    return {
        "name": collection_name,
        "count": collection.count(),
        "metadata": collection.metadata
    }

def delete_collection(collection_name):
    """Delete a collection"""
    chroma_client.delete_collection(collection_name)

def reset_database():
    """Reset entire database - USE WITH CAUTION"""
    chroma_client.reset()

# =============================================
# MAIN EXECUTION
# =============================================

if __name__ == "__main__":
    # Create all collections
    collections = create_all_collections()
    print("ChromaDB collections created successfully!")
    
    # Print collection stats
    for name in collections.keys():
        stats = get_collection_stats(name)
        print(f"{stats['name']}: {stats['count']} documents")
    
    # Example usage
    # search_results = search_high_value_loans()
    # print(f"Found {len(search_results['ids'][0])} high-value loans")
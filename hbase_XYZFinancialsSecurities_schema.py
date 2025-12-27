"""
HBase Schema for XYZ Financials Securities
Save as: hbase_schema.py

HBase is a column-oriented NoSQL database. This schema defines:
- Table structures with column families
- Row key designs for optimal query performance
- Python code using happybase library
"""

import happybase
import json
from datetime import datetime
from typing import Dict, List, Optional

# ============================================================
# TABLE: customers
# ============================================================
CUSTOMERS_TABLE = {
    "name": "customers",
    "column_families": {
        "personal": {
            "max_versions": 5,
            "compression": "SNAPPY",
            "bloom_filter": "ROW"
        },
        "employment": {
            "max_versions": 3,
            "compression": "SNAPPY",
            "bloom_filter": "ROW"
        },
        "financial": {
            "max_versions": 10,
            "compression": "SNAPPY",
            "bloom_filter": "ROW"
        },
        "metadata": {
            "max_versions": 1,
            "compression": "SNAPPY",
            "bloom_filter": "ROW"
        }
    },
    "row_key_format": "CUST_{customer_id:010d}",  # e.g., CUST_0000001000
    "columns": {
        "personal:first_name": "string",
        "personal:last_name": "string",
        "personal:full_name": "string",
        "personal:ssn_encrypted": "string",
        "personal:date_of_birth": "date",
        "personal:email": "string",
        "personal:phone": "string",
        "employment:status": "string",
        "employment:employer": "string",
        "employment:years_employed": "int",
        "financial:annual_income": "double",
        "financial:credit_score": "int",
        "financial:credit_score_history": "json",  # Array of historical scores
        "metadata:created_date": "timestamp",
        "metadata:last_updated_date": "timestamp",
        "metadata:record_type": "string"
    }
}

# ============================================================
# TABLE: loans
# ============================================================
LOANS_TABLE = {
    "name": "loans",
    "column_families": {
        "loan_info": {
            "max_versions": 5,
            "compression": "SNAPPY",
            "bloom_filter": "ROW"
        },
        "financial": {
            "max_versions": 10,
            "compression": "SNAPPY",
            "bloom_filter": "ROW"
        },
        "payment": {
            "max_versions": 3,
            "compression": "SNAPPY",
            "bloom_filter": "ROW"
        },
        "references": {
            "max_versions": 1,
            "compression": "SNAPPY",
            "bloom_filter": "ROW"
        },
        "metadata": {
            "max_versions": 1,
            "compression": "SNAPPY",
            "bloom_filter": "ROW"
        }
    },
    "row_key_format": "LOAN_{loan_id:010d}",  # e.g., LOAN_0000100000
    "columns": {
        "loan_info:application_id": "int",
        "loan_info:loan_amount": "double",
        "loan_info:interest_rate": "double",
        "loan_info:term": "int",
        "loan_info:origination_date": "date",
        "loan_info:maturity_date": "date",
        "loan_info:status": "string",
        "financial:monthly_payment": "double",
        "financial:remaining_balance": "double",
        "financial:escrow_required": "boolean",
        "financial:pmi_required": "boolean",
        "financial:pmi_amount": "double",
        "payment:first_payment_date": "date",
        "payment:next_payment_date": "date",
        "payment:payment_frequency": "string",
        "references:customer_id": "int",
        "references:property_id": "int",
        "references:product_id": "int",
        "references:security_id": "int",
        "metadata:last_updated_date": "timestamp",
        "metadata:record_type": "string"
    }
}

# ============================================================
# TABLE: properties
# ============================================================
PROPERTIES_TABLE = {
    "name": "properties",
    "column_families": {
        "address": {
            "max_versions": 3,
            "compression": "SNAPPY",
            "bloom_filter": "ROW"
        },
        "details": {
            "max_versions": 5,
            "compression": "SNAPPY",
            "bloom_filter": "ROW"
        },
        "valuation": {
            "max_versions": 10,
            "compression": "SNAPPY",
            "bloom_filter": "ROW"
        },
        "tax": {
            "max_versions": 5,
            "compression": "SNAPPY",
            "bloom_filter": "ROW"
        },
        "location": {
            "max_versions": 1,
            "compression": "SNAPPY",
            "bloom_filter": "ROW"
        },
        "metadata": {
            "max_versions": 1,
            "compression": "SNAPPY",
            "bloom_filter": "ROW"
        }
    },
    "row_key_format": "PROP_{property_id:010d}",  # e.g., PROP_0000000001
    "columns": {
        "address:line1": "string",
        "address:line2": "string",
        "address:city": "string",
        "address:state": "string",
        "address:zip_code": "string",
        "address:country": "string",
        "address:full_address": "string",
        "details:property_type": "string",
        "details:year_built": "int",
        "details:square_feet": "int",
        "details:bedrooms": "int",
        "details:bathrooms": "float",
        "valuation:purchase_price": "double",
        "valuation:current_value": "double",
        "valuation:last_appraisal_date": "date",
        "valuation:last_appraisal_value": "double",
        "valuation:value_history": "json",
        "tax:assessment_value": "double",
        "tax:annual_tax_amount": "double",
        "tax:hoa_fees": "double",
        "tax:property_tax_id": "string",
        "location:flood_zone": "string",
        "location:latitude": "double",
        "location:longitude": "double",
        "metadata:record_type": "string"
    }
}

# ============================================================
# TABLE: securities
# ============================================================
SECURITIES_TABLE = {
    "name": "securities",
    "column_families": {
        "security_info": {
            "max_versions": 3,
            "compression": "SNAPPY",
            "bloom_filter": "ROW"
        },
        "financial": {
            "max_versions": 10,
            "compression": "SNAPPY",
            "bloom_filter": "ROW"
        },
        "trading": {
            "max_versions": 20,
            "compression": "SNAPPY",
            "bloom_filter": "ROW"
        },
        "metadata": {
            "max_versions": 1,
            "compression": "SNAPPY",
            "bloom_filter": "ROW"
        }
    },
    "row_key_format": "SEC_{security_id:010d}",  # e.g., SEC_0000000001
    "columns": {
        "security_info:name": "string",
        "security_info:type": "string",
        "security_info:cusip": "string",
        "security_info:issuer": "string",
        "security_info:rating": "string",
        "security_info:status": "string",
        "financial:issue_date": "date",
        "financial:maturity_date": "date",
        "financial:coupon_rate": "double",
        "financial:face_value": "double",
        "financial:current_balance": "double",
        "trading:last_trade_date": "date",
        "trading:last_trade_price": "double",
        "trading:price_history": "json",
        "metadata:record_type": "string"
    }
}

# ============================================================
# TABLE: applications
# ============================================================
APPLICATIONS_TABLE = {
    "name": "applications",
    "column_families": {
        "application_info": {
            "max_versions": 5,
            "compression": "SNAPPY",
            "bloom_filter": "ROW"
        },
        "financial": {
            "max_versions": 3,
            "compression": "SNAPPY",
            "bloom_filter": "ROW"
        },
        "references": {
            "max_versions": 1,
            "compression": "SNAPPY",
            "bloom_filter": "ROW"
        },
        "metadata": {
            "max_versions": 1,
            "compression": "SNAPPY",
            "bloom_filter": "ROW"
        }
    },
    "row_key_format": "APP_{application_id:010d}",  # e.g., APP_0000010000
    "columns": {
        "application_info:application_date": "timestamp",
        "application_info:loan_purpose": "string",
        "application_info:status": "string",
        "application_info:closing_date": "date",
        "application_info:denial_reason": "string",
        "financial:loan_amount": "double",
        "financial:application_fee": "double",
        "financial:dti": "double",
        "financial:property_value": "double",
        "financial:ltv": "double",
        "financial:rate_offered": "double",
        "financial:term_offered": "int",
        "references:customer_id": "int",
        "references:product_id": "int",
        "references:officer_id": "int",
        "metadata:record_type": "string"
    }
}

# ============================================================
# TABLE: documents
# ============================================================
DOCUMENTS_TABLE = {
    "name": "documents",
    "column_families": {
        "document_info": {
            "max_versions": 3,
            "compression": "SNAPPY",
            "bloom_filter": "ROW"
        },
        "approval": {
            "max_versions": 5,
            "compression": "SNAPPY",
            "bloom_filter": "ROW"
        },
        "metadata": {
            "max_versions": 1,
            "compression": "SNAPPY",
            "bloom_filter": "ROW"
        }
    },
    "row_key_format": "DOC_{application_id:010d}_{document_id:010d}",  # e.g., DOC_0000010000_0000000001
    "columns": {
        "document_info:application_id": "int",
        "document_info:document_type": "string",
        "document_info:file_name": "string",
        "document_info:file_location": "string",
        "document_info:upload_date": "timestamp",
        "document_info:required_flag": "boolean",
        "document_info:received_flag": "boolean",
        "approval:status": "string",
        "approval:date": "timestamp",
        "approval:approved_by": "string",
        "approval:notes": "string",
        "metadata:record_type": "string"
    }
}

# ============================================================
# TABLE: payments
# ============================================================
PAYMENTS_TABLE = {
    "name": "payments",
    "column_families": {
        "payment_info": {
            "max_versions": 1,
            "compression": "SNAPPY",
            "bloom_filter": "ROW"
        },
        "amounts": {
            "max_versions": 1,
            "compression": "SNAPPY",
            "bloom_filter": "ROW"
        },
        "transaction": {
            "max_versions": 1,
            "compression": "SNAPPY",
            "bloom_filter": "ROW"
        }
    },
    "row_key_format": "PAY_{loan_id:010d}_{payment_date}_{payment_id:010d}",  # e.g., PAY_0000100000_20250101_0000000001
    "columns": {
        "payment_info:loan_id": "int",
        "payment_info:payment_date": "date",
        "payment_info:payment_method": "string",
        "payment_info:payment_status": "string",
        "amounts:payment_amount": "double",
        "amounts:principal_amount": "double",
        "amounts:interest_amount": "double",
        "amounts:escrow_amount": "double",
        "amounts:late_fee_amount": "double",
        "transaction:transaction_id": "string",
        "transaction:processed_date": "timestamp"
    }
}

# ============================================================
# SECONDARY INDEX TABLES (for common queries)
# ============================================================

# Index table for customer lookups by email
CUSTOMER_EMAIL_INDEX_TABLE = {
    "name": "idx_customer_email",
    "column_families": {
        "ref": {
            "max_versions": 1,
            "compression": "SNAPPY",
            "bloom_filter": "ROW"
        }
    },
    "row_key_format": "{email}",
    "columns": {
        "ref:customer_id": "int"
    }
}

# Index table for customer lookups by SSN
CUSTOMER_SSN_INDEX_TABLE = {
    "name": "idx_customer_ssn",
    "column_families": {
        "ref": {
            "max_versions": 1,
            "compression": "SNAPPY",
            "bloom_filter": "ROW"
        }
    },
    "row_key_format": "{ssn_encrypted}",
    "columns": {
        "ref:customer_id": "int"
    }
}

# Index table for loans by customer
LOANS_BY_CUSTOMER_INDEX_TABLE = {
    "name": "idx_loans_by_customer",
    "column_families": {
        "loans": {
            "max_versions": 1,
            "compression": "SNAPPY",
            "bloom_filter": "ROW"
        }
    },
    "row_key_format": "CUST_{customer_id:010d}_{loan_id:010d}",
    "columns": {
        "loans:loan_id": "int",
        "loans:status": "string",
        "loans:origination_date": "date"
    }
}

# Index table for loans by status
LOANS_BY_STATUS_INDEX_TABLE = {
    "name": "idx_loans_by_status",
    "column_families": {
        "loan": {
            "max_versions": 1,
            "compression": "SNAPPY",
            "bloom_filter": "ROW"
        }
    },
    "row_key_format": "{status}_{origination_date}_{loan_id:010d}",
    "columns": {
        "loan:loan_id": "int",
        "loan:customer_id": "int"
    }
}

# Index table for properties by location
PROPERTIES_BY_LOCATION_INDEX_TABLE = {
    "name": "idx_properties_by_location",
    "column_families": {
        "property": {
            "max_versions": 1,
            "compression": "SNAPPY",
            "bloom_filter": "ROW"
        }
    },
    "row_key_format": "{state}_{city}_{zip_code}_{property_id:010d}",
    "columns": {
        "property:property_id": "int",
        "property:property_type": "string"
    }
}


# ============================================================
# HELPER FUNCTIONS
# ============================================================

def create_all_tables(host: str = 'localhost', port: int = 9090):
    """
    Create all HBase tables with column families
    
    Args:
        host: HBase Thrift server host
        port: HBase Thrift server port
    """
    connection = happybase.Connection(host=host, port=port)
    
    all_tables = [
        CUSTOMERS_TABLE,
        LOANS_TABLE,
        PROPERTIES_TABLE,
        SECURITIES_TABLE,
        APPLICATIONS_TABLE,
        DOCUMENTS_TABLE,
        PAYMENTS_TABLE,
        CUSTOMER_EMAIL_INDEX_TABLE,
        CUSTOMER_SSN_INDEX_TABLE,
        LOANS_BY_CUSTOMER_INDEX_TABLE,
        LOANS_BY_STATUS_INDEX_TABLE,
        PROPERTIES_BY_LOCATION_INDEX_TABLE
    ]
    
    for table_def in all_tables:
        table_name = table_def["name"]
        
        # Prepare column families dict
        families = {}
        for cf_name, cf_config in table_def["column_families"].items():
            families[cf_name] = {
                'max_versions': cf_config.get('max_versions', 1),
                'compression': cf_config.get('compression', 'NONE'),
                'bloom_filter_type': cf_config.get('bloom_filter', 'NONE')
            }
        
        try:
            # Create table
            connection.create_table(table_name, families)
            print(f"✓ Created table: {table_name}")
        except Exception as e:
            print(f"✗ Error creating table {table_name}: {str(e)}")
    
    connection.close()


def insert_customer_example(host: str = 'localhost', port: int = 9090):
    """
    Example: Insert a customer record
    """
    connection = happybase.Connection(host=host, port=port)
    table = connection.table('customers')
    
    customer_id = 1000
    row_key = f"CUST_{customer_id:010d}".encode()
    
    data = {
        b'personal:first_name': b'John',
        b'personal:last_name': b'Doe',
        b'personal:full_name': b'John Doe',
        b'personal:email': b'john.doe@example.com',
        b'personal:phone': b'555-1234',
        b'personal:date_of_birth': b'1985-05-15',
        b'employment:status': b'Employed',
        b'employment:employer': b'Tech Corp',
        b'employment:years_employed': b'5',
        b'financial:annual_income': b'85000.00',
        b'financial:credit_score': b'750',
        b'metadata:created_date': str(int(datetime.now().timestamp())).encode(),
        b'metadata:last_updated_date': str(int(datetime.now().timestamp())).encode(),
        b'metadata:record_type': b'customer'
    }
    
    table.put(row_key, data)
    print(f"✓ Inserted customer: {row_key.decode()}")
    
    # Also insert into email index
    email_index_table = connection.table('idx_customer_email')
    email_index_table.put(
        b'john.doe@example.com',
        {b'ref:customer_id': str(customer_id).encode()}
    )
    
    connection.close()


def get_customer_by_id(customer_id: int, host: str = 'localhost', port: int = 9090):
    """
    Example: Retrieve a customer by ID
    """
    connection = happybase.Connection(host=host, port=port)
    table = connection.table('customers')
    
    row_key = f"CUST_{customer_id:010d}".encode()
    row = table.row(row_key)
    
    if row:
        print(f"Found customer: {customer_id}")
        for key, value in row.items():
            print(f"  {key.decode()}: {value.decode()}")
    else:
        print(f"Customer {customer_id} not found")
    
    connection.close()
    return row


def get_customer_by_email(email: str, host: str = 'localhost', port: int = 9090):
    """
    Example: Retrieve a customer by email using index
    """
    connection = happybase.Connection(host=host, port=port)
    
    # First, look up customer_id in index
    email_index_table = connection.table('idx_customer_email')
    index_row = email_index_table.row(email.encode())
    
    if not index_row:
        print(f"No customer found with email: {email}")
        connection.close()
        return None
    
    customer_id = int(index_row[b'ref:customer_id'].decode())
    
    # Then get full customer record
    customers_table = connection.table('customers')
    row_key = f"CUST_{customer_id:010d}".encode()
    customer_row = customers_table.row(row_key)
    
    connection.close()
    return customer_row


def insert_loan_example(host: str = 'localhost', port: int = 9090):
    """
    Example: Insert a loan record
    """
    connection = happybase.Connection(host=host, port=port)
    table = connection.table('loans')
    
    loan_id = 100000
    customer_id = 1000
    row_key = f"LOAN_{loan_id:010d}".encode()
    
    data = {
        b'loan_info:application_id': b'10000',
        b'loan_info:loan_amount': b'350000.00',
        b'loan_info:interest_rate': b'3.75',
        b'loan_info:term': b'360',
        b'loan_info:origination_date': b'2023-06-15',
        b'loan_info:maturity_date': b'2053-06-15',
        b'loan_info:status': b'Active',
        b'financial:monthly_payment': b'1620.91',
        b'financial:remaining_balance': b'345000.00',
        b'financial:escrow_required': b'true',
        b'financial:pmi_required': b'false',
        b'payment:payment_frequency': b'Monthly',
        b'references:customer_id': str(customer_id).encode(),
        b'references:property_id': b'1',
        b'references:product_id': b'1',
        b'metadata:last_updated_date': str(int(datetime.now().timestamp())).encode(),
        b'metadata:record_type': b'loan'
    }
    
    table.put(row_key, data)
    print(f"✓ Inserted loan: {row_key.decode()}")
    
    # Also insert into customer loans index
    loans_by_customer_table = connection.table('idx_loans_by_customer')
    index_row_key = f"CUST_{customer_id:010d}_{loan_id:010d}".encode()
    loans_by_customer_table.put(
        index_row_key,
        {
            b'loans:loan_id': str(loan_id).encode(),
            b'loans:status': b'Active',
            b'loans:origination_date': b'2023-06-15'
        }
    )
    
    connection.close()


def get_loans_by_customer(customer_id: int, host: str = 'localhost', port: int = 9090):
    """
    Example: Get all loans for a customer using index
    """
    connection = happybase.Connection(host=host, port=port)
    table = connection.table('idx_loans_by_customer')
    
    row_prefix = f"CUST_{customer_id:010d}_".encode()
    
    loans = []
    for key, data in table.scan(row_prefix=row_prefix):
        loan_id = int(data[b'loans:loan_id'].decode())
        loans.append({
            'loan_id': loan_id,
            'status': data[b'loans:status'].decode(),
            'origination_date': data[b'loans:origination_date'].decode()
        })
    
    print(f"Found {len(loans)} loans for customer {customer_id}")
    for loan in loans:
        print(f"  Loan ID: {loan['loan_id']}, Status: {loan['status']}")
    
    connection.close()
    return loans


def scan_table_example(table_name: str, limit: int = 10, host: str = 'localhost', port: int = 9090):
    """
    Example: Scan a table with limit
    """
    connection = happybase.Connection(host=host, port=port)
    table = connection.table(table_name)
    
    print(f"\nScanning table: {table_name} (limit: {limit})")
    print("-" * 80)
    
    count = 0
    for key, data in table.scan(limit=limit):
        print(f"\nRow: {key.decode()}")
        for col, val in data.items():
            print(f"  {col.decode()}: {val.decode()}")
        count += 1
    
    print(f"\nScanned {count} rows")
    connection.close()


# ============================================================
# MAIN EXECUTION
# ============================================================

if __name__ == "__main__":
    HOST = 'localhost'
    PORT = 9090
    
    print("HBase Schema for XYZ Financials Securities")
    print("=" * 80)
    
    # Uncomment to use:
    # create_all_tables(HOST, PORT)
    # insert_customer_example(HOST, PORT)
    # get_customer_by_id(1000, HOST, PORT)
    # get_customer_by_email('john.doe@example.com', HOST, PORT)
    # insert_loan_example(HOST, PORT)
    # get_loans_by_customer(1000, HOST, PORT)
    # scan_table_example('customers', limit=5, HOST, PORT)
    
    print("\nAvailable tables:")
    print("  Main Tables:")
    print("    - customers")
    print("    - loans")
    print("    - properties")
    print("    - securities")
    print("    - applications")
    print("    - documents")
    print("    - payments")
    print("\n  Index Tables:")
    print("    - idx_customer_email")
    print("    - idx_customer_ssn")
    print("    - idx_loans_by_customer")
    print("    - idx_loans_by_status")
    print("    - idx_properties_by_location")

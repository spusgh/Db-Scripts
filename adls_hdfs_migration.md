# XYZ Financials Securities - ADLS & HDFS Migration Guide

## 1. Azure Data Lake Storage (ADLS) Gen2 Structure

### Container Hierarchy

```
xyz-financials-securities/
├── raw/                          # Bronze Layer - Raw ingested data
│   ├── customers/
│   │   ├── year=2025/
│   │   │   ├── month=01/
│   │   │   │   └── customers_20250101.parquet
│   │   │   └── month=02/
│   │   └── year=2024/
│   ├── loans/
│   ├── applications/
│   ├── payments/
│   ├── property_details/
│   ├── securities/
│   ├── mortgage_products/
│   ├── loan_officers/
│   ├── defaults_foreclosures/
│   ├── servicing_rights/
│   ├── escrow_accounts/
│   ├── escrow_transactions/
│   ├── customer_addresses/
│   ├── documents_registry/
│   ├── loan_term_modifications/
│   ├── risk_assessments/
│   ├── capital_market_data/
│   ├── finra_fi/
│   ├── interest_type/
│   ├── product_subtype/
│   └── audit_log/
│
├── processed/                    # Silver Layer - Cleaned, validated data
│   ├── customers/
│   ├── loans/
│   ├── payments/
│   └── [other entities]/
│
├── curated/                      # Gold Layer - Business-ready aggregates
│   ├── loan_portfolio_overview/
│   ├── delinquent_loans/
│   ├── customer_portfolio/
│   ├── escrow_analysis/
│   ├── loan_officer_performance/
│   └── analytics/
│       ├── monthly_origination_summary/
│       ├── risk_metrics/
│       └── portfolio_performance/
│
├── metadata/                     # Schema definitions and metadata
│   ├── schemas/
│   │   ├── customers.avsc
│   │   ├── loans.avsc
│   │   └── [other schemas].avsc
│   └── data_dictionary.json
│
├── reference/                    # Reference/lookup data
│   ├── mortgage_products/
│   ├── interest_type/
│   └── product_subtype/
│
└── archive/                      # Historical snapshots
    └── year=2024/
        └── month=12/
```

## 2. HDFS Directory Structure

```
/user/xyz_financials/
├── warehouse/
│   ├── raw_db/                   # External tables pointing to ADLS raw
│   ├── processed_db/             # Managed tables for processed data
│   └── curated_db/               # Analytical views and aggregates
│
├── staging/                      # Temporary processing area
│   ├── incremental_loads/
│   └── transformation_temp/
│
├── applications/                 # Application-specific data
│   ├── spark_jobs/
│   ├── workflows/
│   └── notebooks/
│
└── checkpoints/                  # Streaming checkpoints
    ├── payment_stream/
    └── application_stream/
```

## 3. Data Lake Zones (Medallion Architecture)

### Bronze Zone (Raw Data)
- **Format**: Parquet (compressed with Snappy)
- **Partitioning**: By ingestion date (year/month/day)
- **Schema**: Schema-on-read with flexible structure
- **Retention**: 7 years for compliance

### Silver Zone (Processed Data)
- **Format**: Delta Lake tables
- **Partitioning**: Business-relevant columns (e.g., OriginationDate, Status)
- **Features**: 
  - ACID transactions
  - Time travel
  - Schema enforcement
  - Data quality checks applied

### Gold Zone (Curated Data)
- **Format**: Delta Lake tables or Parquet
- **Purpose**: Aggregated, business-ready datasets
- **Optimized for**: Analytics, reporting, ML models

## 4. Hive Metastore Table Definitions

### Bronze Layer - External Tables

```sql
-- Customers Table
CREATE EXTERNAL TABLE raw_db.customers (
    CustomerID INT,
    FirstName STRING,
    LastName STRING,
    SSN STRING,
    DateOfBirth DATE,
    Email STRING,
    Phone STRING,
    AnnualIncome DECIMAL(15,2),
    EmploymentStatus STRING,
    Employer STRING,
    YearsEmployed INT,
    CreditScore INT,
    CreatedDate TIMESTAMP,
    LastUpdatedDate TIMESTAMP
)
PARTITIONED BY (year INT, month INT)
STORED AS PARQUET
LOCATION 'abfss://xyz-financials-securities@<storage-account>.dfs.core.windows.net/raw/customers/';

-- Loans Table
CREATE EXTERNAL TABLE raw_db.loans (
    LoanID INT,
    ApplicationID INT,
    CustomerID INT,
    PropertyID INT,
    ProductID INT,
    LoanAmount DECIMAL(15,2),
    InterestRate DECIMAL(5,3),
    Term INT,
    OriginationDate DATE,
    MaturityDate DATE,
    MonthlyPayment DECIMAL(12,2),
    RemainingBalance DECIMAL(15,2),
    Status STRING,
    EscrowRequired BOOLEAN,
    PMIRequired BOOLEAN,
    PMIAmount DECIMAL(10,2),
    FirstPaymentDate DATE,
    NextPaymentDate DATE,
    PaymentFrequency STRING,
    SecurityID INT,
    LastUpdatedDate DATE
)
PARTITIONED BY (year INT, month INT)
STORED AS PARQUET
LOCATION 'abfss://xyz-financials-securities@<storage-account>.dfs.core.windows.net/raw/loans/';

-- Payments Table
CREATE EXTERNAL TABLE raw_db.payments (
    PaymentID INT,
    LoanID INT,
    PaymentDate DATE,
    PaymentAmount DECIMAL(12,2),
    PrincipalAmount DECIMAL(12,2),
    InterestAmount DECIMAL(12,2),
    EscrowAmount DECIMAL(12,2),
    LateFeeAmount DECIMAL(10,2),
    PaymentMethod STRING,
    TransactionID STRING,
    PaymentStatus STRING,
    ProcessedDate TIMESTAMP
)
PARTITIONED BY (year INT, month INT)
STORED AS PARQUET
LOCATION 'abfss://xyz-financials-securities@<storage-account>.dfs.core.windows.net/raw/payments/';
```

### Silver Layer - Delta Tables

```sql
-- Processed Customers
CREATE TABLE processed_db.customers (
    CustomerID INT,
    FirstName STRING,
    LastName STRING,
    SSN_Hash STRING,                    -- Hashed for security
    DateOfBirth DATE,
    Email STRING,
    Phone STRING,
    AnnualIncome DECIMAL(15,2),
    EmploymentStatus STRING,
    Employer STRING,
    YearsEmployed INT,
    CreditScore INT,
    CreatedDate TIMESTAMP,
    LastUpdatedDate TIMESTAMP,
    DataQualityScore DECIMAL(3,2),      -- Added for data quality
    IsActive BOOLEAN,
    _processing_timestamp TIMESTAMP,
    _source_file STRING
)
USING DELTA
PARTITIONED BY (IsActive)
LOCATION 'abfss://xyz-financials-securities@<storage-account>.dfs.core.windows.net/processed/customers/';

-- Processed Loans with SCD Type 2
CREATE TABLE processed_db.loans (
    LoanID INT,
    ApplicationID INT,
    CustomerID INT,
    PropertyID INT,
    ProductID INT,
    LoanAmount DECIMAL(15,2),
    InterestRate DECIMAL(5,3),
    Term INT,
    OriginationDate DATE,
    MaturityDate DATE,
    MonthlyPayment DECIMAL(12,2),
    RemainingBalance DECIMAL(15,2),
    Status STRING,
    EscrowRequired BOOLEAN,
    PMIRequired BOOLEAN,
    PMIAmount DECIMAL(10,2),
    FirstPaymentDate DATE,
    NextPaymentDate DATE,
    PaymentFrequency STRING,
    SecurityID INT,
    LastUpdatedDate DATE,
    -- SCD Type 2 columns
    EffectiveStartDate TIMESTAMP,
    EffectiveEndDate TIMESTAMP,
    IsCurrent BOOLEAN,
    _processing_timestamp TIMESTAMP
)
USING DELTA
PARTITIONED BY (IsCurrent, year INT, month INT)
LOCATION 'abfss://xyz-financials-securities@<storage-account>.dfs.core.windows.net/processed/loans/';
```

### Gold Layer - Analytical Views

```sql
-- Loan Portfolio Overview
CREATE TABLE curated_db.loan_portfolio_overview (
    LoanID INT,
    CustomerName STRING,
    PropertyAddress STRING,
    OriginationDate DATE,
    MaturityDate DATE,
    LoanAmount DECIMAL(15,2),
    RemainingBalance DECIMAL(15,2),
    InterestRate DECIMAL(5,3),
    MonthlyPayment DECIMAL(12,2),
    Status STRING,
    ProductName STRING,
    ProductType STRING,
    SecurityName STRING,
    ServicerName STRING,
    CurrentStatus STRING,
    LoanAge INT,
    PaymentCount INT,
    TotalPaid DECIMAL(15,2),
    snapshot_date DATE
)
USING DELTA
PARTITIONED BY (snapshot_date)
LOCATION 'abfss://xyz-financials-securities@<storage-account>.dfs.core.windows.net/curated/loan_portfolio_overview/';

-- Delinquent Loans
CREATE TABLE curated_db.delinquent_loans (
    LoanID INT,
    CustomerName STRING,
    ContactPhone STRING,
    ContactEmail STRING,
    PropertyAddress STRING,
    OriginationDate DATE,
    RemainingBalance DECIMAL(15,2),
    MonthlyPayment DECIMAL(12,2),
    NextPaymentDate DATE,
    DefaultDate DATE,
    Stage STRING,
    DaysPastDue INT,
    DelinquencyBucket STRING,
    RiskScore DECIMAL(5,2),
    snapshot_date DATE
)
USING DELTA
PARTITIONED BY (DelinquencyBucket, snapshot_date)
LOCATION 'abfss://xyz-financials-securities@<storage-account>.dfs.core.windows.net/curated/delinquent_loans/';
```

## 5. Data Migration Strategy

### Phase 1: Initial Load (Full Load)

```python
# Example PySpark script for initial load
from pyspark.sql import SparkSession
from pyspark.sql.functions import *

spark = SparkSession.builder \
    .appName("XYZ_Initial_Load") \
    .config("spark.sql.extensions", "io.delta.sql.DeltaSparkSessionExtension") \
    .config("spark.sql.catalog.spark_catalog", "org.apache.spark.sql.delta.catalog.DeltaCatalog") \
    .getOrCreate()

# Read from SQL Server
jdbc_url = "jdbc:sqlserver://<server>:1433;database=XYZ_Financials_Securities"
connection_properties = {
    "user": "<username>",
    "password": "<password>",
    "driver": "com.microsoft.sqlserver.jdbc.SQLServerDriver"
}

# Load Customers
customers_df = spark.read.jdbc(
    url=jdbc_url,
    table="dbo.Customers",
    properties=connection_properties
)

# Add metadata columns
customers_df = customers_df \
    .withColumn("_ingestion_timestamp", current_timestamp()) \
    .withColumn("year", year(col("CreatedDate"))) \
    .withColumn("month", month(col("CreatedDate")))

# Write to Bronze layer (Parquet)
customers_df.write \
    .mode("overwrite") \
    .partitionBy("year", "month") \
    .parquet("abfss://xyz-financials-securities@<storage>.dfs.core.windows.net/raw/customers/")

# Process to Silver layer (Delta)
processed_customers = customers_df \
    .withColumn("SSN_Hash", sha2(col("SSN"), 256)) \
    .drop("SSN") \
    .withColumn("DataQualityScore", lit(1.0)) \
    .withColumn("IsActive", lit(True)) \
    .withColumn("_processing_timestamp", current_timestamp())

processed_customers.write \
    .format("delta") \
    .mode("overwrite") \
    .partitionBy("IsActive") \
    .save("abfss://xyz-financials-securities@<storage>.dfs.core.windows.net/processed/customers/")
```

### Phase 2: Incremental Load (CDC)

```python
# Change Data Capture using Watermark
from delta.tables import DeltaTable

# Read incremental data from source
incremental_df = spark.read.jdbc(
    url=jdbc_url,
    table="(SELECT * FROM dbo.Customers WHERE LastUpdatedDate > ?) AS customers",
    properties=connection_properties,
    predicates=["LastUpdatedDate > '2025-01-01'"]
)

# Get Delta table
delta_table = DeltaTable.forPath(spark, 
    "abfss://xyz-financials-securities@<storage>.dfs.core.windows.net/processed/customers/")

# Upsert (Merge)
delta_table.alias("target") \
    .merge(
        incremental_df.alias("source"),
        "target.CustomerID = source.CustomerID"
    ) \
    .whenMatchedUpdateAll() \
    .whenNotMatchedInsertAll() \
    .execute()
```

## 6. Implementing Functions and Procedures

### Spark UDFs for Business Logic

```python
from pyspark.sql.functions import udf
from pyspark.sql.types import DecimalType, IntegerType, BooleanType

# fn_CalculateCurrentBalance
@udf(returnType=DecimalType(18,2))
def calculate_current_balance(loan_id, as_of_date=None):
    # Implementation using Spark SQL queries
    pass

# fn_CalculateInterestForPeriod
@udf(returnType=DecimalType(12,2))
def calculate_interest_for_period(principal, annual_rate, days):
    return round(principal * (annual_rate / 100) * days / 365, 2)

# fn_GetCustomerDTI
@udf(returnType=DecimalType(5,2))
def get_customer_dti(customer_id):
    # Calculate DTI from loan and customer data
    pass

# fn_IsPropertyInFloodZone
@udf(returnType=BooleanType())
def is_property_in_flood_zone(flood_zone):
    high_risk_zones = ['A', 'AE', 'AH', 'AO', 'V', 'VE']
    return flood_zone in high_risk_zones

# Register UDFs
spark.udf.register("calculate_interest_for_period", calculate_interest_for_period)
spark.udf.register("is_property_in_flood_zone", is_property_in_flood_zone)
```

### Spark Procedures (Notebooks)

```python
# sp_ProcessLoanPayment - Databricks Notebook
def process_loan_payment(loan_id, payment_amount, payment_date, payment_method, transaction_id=None):
    from delta.tables import DeltaTable
    from datetime import datetime
    
    # Read loan details
    loan_df = spark.sql(f"""
        SELECT * FROM processed_db.loans 
        WHERE LoanID = {loan_id} AND IsCurrent = true
    """)
    
    if loan_df.count() == 0:
        raise Exception("Loan not found")
    
    loan = loan_df.first()
    
    # Calculate payment breakdown
    monthly_rate = (loan.InterestRate / 100) / 12
    interest_amount = round(loan.RemainingBalance * monthly_rate, 2)
    principal_amount = payment_amount - interest_amount
    
    # Update loan
    loans_delta = DeltaTable.forName(spark, "processed_db.loans")
    
    loans_delta.update(
        condition=f"LoanID = {loan_id} AND IsCurrent = true",
        set={
            "RemainingBalance": "RemainingBalance - " + str(principal_amount),
            "NextPaymentDate": f"date_add(NextPaymentDate, 30)",
            "LastUpdatedDate": f"current_date()",
            "_processing_timestamp": "current_timestamp()"
        }
    )
    
    # Insert payment record
    payment_data = [(
        loan_id,
        payment_date,
        payment_amount,
        principal_amount,
        interest_amount,
        0.0,  # escrow
        0.0,  # late fee
        payment_method,
        transaction_id,
        "Processed",
        datetime.now()
    )]
    
    payment_df = spark.createDataFrame(payment_data, schema="""
        LoanID INT, PaymentDate DATE, PaymentAmount DECIMAL(12,2),
        PrincipalAmount DECIMAL(12,2), InterestAmount DECIMAL(12,2),
        EscrowAmount DECIMAL(12,2), LateFeeAmount DECIMAL(10,2),
        PaymentMethod STRING, TransactionID STRING,
        PaymentStatus STRING, ProcessedDate TIMESTAMP
    """)
    
    payment_df.write \
        .format("delta") \
        .mode("append") \
        .saveAsTable("processed_db.payments")

# Usage
process_loan_payment(
    loan_id=100001,
    payment_amount=1500.00,
    payment_date='2025-01-15',
    payment_method='ACH'
)
```

## 7. Access Control & Security

### Azure RBAC Roles

```yaml
# Storage Account Access
Roles:
  - Storage Blob Data Owner: Data engineering team
  - Storage Blob Data Contributor: ETL service principals
  - Storage Blob Data Reader: Analytics team, BI tools

# Azure Key Vault
Secrets:
  - jdbc-connection-string
  - sql-username
  - sql-password
  - storage-account-key
```

### Data Lake ACLs

```bash
# Set ACLs on ADLS Gen2
az storage fs access set \
  --acl "user::rwx,group::r-x,other::---" \
  --path /raw/customers \
  --file-system xyz-financials-securities \
  --account-name <storage-account>

# Column-level encryption for PII
# Use Delta Lake column encryption or Azure Purview
```

## 8. Data Quality & Governance

### Great Expectations Validation

```python
import great_expectations as ge

# Validate customers data
customers_ge = ge.read_csv("customers.csv")

customers_ge.expect_column_values_to_not_be_null("CustomerID")
customers_ge.expect_column_values_to_be_unique("CustomerID")
customers_ge.expect_column_values_to_match_regex("Email", r"^[\w\.-]+@[\w\.-]+\.\w+$")
customers_ge.expect_column_values_to_be_between("CreditScore", 300, 850)

# Save expectation suite
customers_ge.save_expectation_suite("customers_expectations.json")
```

### Azure Purview Integration

```python
# Register assets in Purview
from azure.purview.catalog import PurviewCatalogClient
from azure.identity import DefaultAzureCredential

credential = DefaultAzureCredential()
client = PurviewCatalogClient(
    endpoint="https://<purview-account>.purview.azure.com",
    credential=credential
)

# Create entity for customers table
entity = {
    "typeName": "azure_datalake_gen2_path",
    "attributes": {
        "name": "customers",
        "qualifiedName": "abfss://xyz-financials-securities@<storage>.dfs.core.windows.net/raw/customers",
        "path": "/raw/customers",
        "description": "Customer master data"
    },
    "classifications": [
        {"typeName": "MICROSOFT.PERSONAL.IDENTIFIABLE_INFORMATION"}
    ]
}

client.entity.create_or_update(entity=entity)
```

## 9. Performance Optimization

### Z-Ordering for Delta Tables

```sql
-- Optimize frequently queried columns
OPTIMIZE processed_db.loans
ZORDER BY (CustomerID, Status, OriginationDate);

OPTIMIZE processed_db.payments
ZORDER BY (LoanID, PaymentDate);
```

### Caching Strategy

```python
# Cache frequently accessed reference data
mortgage_products = spark.table("processed_db.mortgage_products")
mortgage_products.cache()
mortgage_products.count()  # Materialize cache
```

## 10. Monitoring & Observability

### Delta Lake Metrics

```python
from delta.tables import DeltaTable

# Check table history
loans_delta = DeltaTable.forPath(spark, 
    "abfss://xyz-financials-securities@<storage>.dfs.core.windows.net/processed/loans/")

loans_delta.history().show()

# Describe detail
loans_delta.detail().show()

# Vacuum old files (7 day retention)
loans_delta.vacuum(168)  # hours
```

### Azure Monitor Integration

```python
# Log metrics to Azure Monitor
from azure.monitor.opentelemetry.exporter import AzureMonitorTraceExporter
from opentelemetry import trace

exporter = AzureMonitorTraceExporter.from_connection_string(
    "<connection-string>"
)

tracer = trace.get_tracer(__name__)

with tracer.start_as_current_span("load_customers"):
    # ETL operations
    pass
```

## 11. Disaster Recovery

```yaml
# Geo-redundant storage configuration
StorageAccount:
  Replication: GRS  # Geo-redundant storage
  
# Backup strategy
Backup:
  DeltaLakeTables:
    - Schedule: Daily
    - Retention: 30 days
    - Location: Secondary region
    
  Metadata:
    - Hive Metastore: Backed up to Azure SQL
    - Schemas: Version controlled in Git
```

## 12. Migration Checklist

- [ ] Provision ADLS Gen2 storage account
- [ ] Set up Azure Data Factory for orchestration
- [ ] Configure Databricks or Synapse Spark pools
- [ ] Create Hive metastore (Azure SQL Database)
- [ ] Implement Bronze layer external tables
- [ ] Develop ETL pipelines for Silver layer
- [ ] Create Gold layer analytical views
- [ ] Migrate stored procedures to Spark notebooks
- [ ] Implement security and access controls
- [ ] Set up monitoring and alerting
- [ ] Configure backup and disaster recovery
- [ ] Perform UAT with sample datasets
- [ ] Execute full data migration
- [ ] Validate data integrity
- [ ] Decommission SQL Server (after validation period)

## 13. Technology Stack

- **Storage**: Azure Data Lake Storage Gen2
- **Compute**: Azure Databricks / Azure Synapse Spark
- **Orchestration**: Azure Data Factory
- **Catalog**: Hive Metastore (Azure SQL Database)
- **Format**: Delta Lake, Parquet
- **Security**: Azure Key Vault, Azure AD
- **Governance**: Azure Purview
- **Monitoring**: Azure Monitor, Log Analytics
- **BI**: Power BI, Azure Synapse Analytics

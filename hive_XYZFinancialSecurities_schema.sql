
-- Apache Hive Schema for XYZ_Financials_Securities
-- Note: Hive doesn't support many RDBMS features like foreign keys, constraints, sequences
-- This schema focuses on table structures optimized for Hive

CREATE DATABASE IF NOT EXISTS xyz_financials_securities;
USE xyz_financials_securities;

-- Customers Table
CREATE TABLE IF NOT EXISTS customers (
    customer_id INT,
    first_name STRING,
    last_name STRING,
    ssn STRING,
    date_of_birth DATE,
    email STRING,
    phone STRING,
    annual_income DECIMAL(15,2),
    employment_status STRING,
    employer STRING,
    years_employed INT,
    credit_score INT,
    created_date TIMESTAMP,
    last_updated_date TIMESTAMP
)
STORED AS PARQUET
TBLPROPERTIES ('parquet.compression'='SNAPPY');

-- Mortgage Products Table
CREATE TABLE IF NOT EXISTS mortgage_products (
    product_id INT,
    product_name STRING,
    product_type STRING,
    term INT,
    base_interest_rate DECIMAL(5,3),
    min_credit_score INT,
    max_ltv DECIMAL(5,2),
    min_loan_amount DECIMAL(15,2),
    max_loan_amount DECIMAL(15,2),
    origination_fee DECIMAL(5,2),
    is_active BOOLEAN
)
STORED AS PARQUET
TBLPROPERTIES ('parquet.compression'='SNAPPY');

-- Property Details Table
CREATE TABLE IF NOT EXISTS property_details (
    property_id INT,
    address_line1 STRING,
    address_line2 STRING,
    city STRING,
    state STRING,
    zip_code STRING,
    country STRING,
    property_type STRING,
    year_built INT,
    square_feet INT,
    bedrooms INT,
    bathrooms DECIMAL(3,1),
    purchase_price DECIMAL(15,2),
    current_value DECIMAL(15,2),
    last_appraisal_date DATE,
    last_appraisal_value DECIMAL(15,2),
    tax_assessment_value DECIMAL(15,2),
    annual_tax_amount DECIMAL(10,2),
    hoa_fees DECIMAL(10,2),
    flood_zone STRING,
    property_tax_id STRING,
    latitude DECIMAL(9,6),
    longitude DECIMAL(9,6)
)
PARTITIONED BY (state STRING)
STORED AS PARQUET
TBLPROPERTIES ('parquet.compression'='SNAPPY');

-- Loan Officers Table
CREATE TABLE IF NOT EXISTS loan_officers (
    officer_id INT,
    first_name STRING,
    last_name STRING,
    email STRING,
    phone STRING,
    branch_id INT,
    hire_date DATE,
    commission_rate DECIMAL(5,2),
    status STRING
)
STORED AS PARQUET
TBLPROPERTIES ('parquet.compression'='SNAPPY');

-- Applications Table
CREATE TABLE IF NOT EXISTS applications (
    application_id INT,
    customer_id INT,
    product_id INT,
    officer_id INT,
    application_date TIMESTAMP,
    loan_amount DECIMAL(15,2),
    loan_purpose STRING,
    status STRING,
    closing_date DATE,
    application_fee DECIMAL(10,2),
    dti DECIMAL(5,2),
    property_value DECIMAL(15,2),
    ltv DECIMAL(5,2),
    rate_offered DECIMAL(5,3),
    term_offered INT,
    denial_reason STRING
)
PARTITIONED BY (application_year INT, application_month INT)
STORED AS PARQUET
TBLPROPERTIES ('parquet.compression'='SNAPPY');

-- Securities Table
CREATE TABLE IF NOT EXISTS securities (
    security_id INT,
    security_name STRING,
    security_type STRING,
    cusip STRING,
    issue_date DATE,
    maturity_date DATE,
    coupon_rate DECIMAL(5,3),
    face_value DECIMAL(15,2),
    current_balance DECIMAL(15,2),
    issuer STRING,
    rating STRING,
    status STRING,
    last_trade_date DATE,
    last_trade_price DECIMAL(10,3)
)
STORED AS PARQUET
TBLPROPERTIES ('parquet.compression'='SNAPPY');

-- Loans Table
CREATE TABLE IF NOT EXISTS loans (
    loan_id INT,
    application_id INT,
    customer_id INT,
    property_id INT,
    product_id INT,
    loan_amount DECIMAL(15,2),
    interest_rate DECIMAL(5,3),
    term INT,
    origination_date DATE,
    maturity_date DATE,
    monthly_payment DECIMAL(12,2),
    remaining_balance DECIMAL(15,2),
    status STRING,
    escrow_required BOOLEAN,
    pmi_required BOOLEAN,
    pmi_amount DECIMAL(10,2),
    first_payment_date DATE,
    next_payment_date DATE,
    payment_frequency STRING,
    security_id INT,
    last_updated_date DATE
)
PARTITIONED BY (origination_year INT, status STRING)
STORED AS PARQUET
TBLPROPERTIES ('parquet.compression'='SNAPPY');

-- Payments Table
CREATE TABLE IF NOT EXISTS payments (
    payment_id INT,
    loan_id INT,
    payment_date DATE,
    payment_amount DECIMAL(12,2),
    principal_amount DECIMAL(12,2),
    interest_amount DECIMAL(12,2),
    escrow_amount DECIMAL(12,2),
    late_fee_amount DECIMAL(10,2),
    payment_method STRING,
    transaction_id STRING,
    payment_status STRING,
    processed_date TIMESTAMP
)
PARTITIONED BY (payment_year INT, payment_month INT)
STORED AS PARQUET
TBLPROPERTIES ('parquet.compression'='SNAPPY');

-- Escrow Accounts Table
CREATE TABLE IF NOT EXISTS escrow_accounts (
    escrow_id INT,
    loan_id INT,
    current_balance DECIMAL(12,2),
    property_tax_amount DECIMAL(12,2),
    property_insurance_amount DECIMAL(12,2),
    pmi_amount DECIMAL(12,2),
    cushion_amount DECIMAL(12,2),
    last_analysis_date DATE,
    next_analysis_date DATE,
    monthly_contribution DECIMAL(12,2),
    shortage_amount DECIMAL(12,2)
)
STORED AS PARQUET
TBLPROPERTIES ('parquet.compression'='SNAPPY');

-- Escrow Transactions Table
CREATE TABLE IF NOT EXISTS escrow_transactions (
    transaction_id INT,
    escrow_id INT,
    transaction_date DATE,
    transaction_type STRING,
    amount DECIMAL(12,2),
    description STRING,
    reference STRING
)
PARTITIONED BY (transaction_year INT)
STORED AS PARQUET
TBLPROPERTIES ('parquet.compression'='SNAPPY');

-- Defaults and Foreclosures Table
CREATE TABLE IF NOT EXISTS defaults_foreclosures (
    default_id INT,
    loan_id INT,
    default_date DATE,
    stage STRING,
    reason_code STRING,
    resolution_type STRING,
    resolution_date DATE,
    loss_amount DECIMAL(15,2),
    collection_agency STRING,
    legal_filing_date DATE,
    legal_case_number STRING,
    notes STRING
)
STORED AS PARQUET
TBLPROPERTIES ('parquet.compression'='SNAPPY');

-- Servicing Rights Table
CREATE TABLE IF NOT EXISTS servicing_rights (
    servicing_id INT,
    loan_id INT,
    servicer_name STRING,
    servicer_id INT,
    transfer_date DATE,
    msr_value DECIMAL(15,2),
    servicing_fee DECIMAL(5,3),
    subservicer_name STRING,
    transfer_reason STRING
)
STORED AS PARQUET
TBLPROPERTIES ('parquet.compression'='SNAPPY');

-- Customer Addresses Table
CREATE TABLE IF NOT EXISTS customer_addresses (
    address_id INT,
    customer_id INT,
    address_type STRING,
    address_line1 STRING,
    address_line2 STRING,
    city STRING,
    state STRING,
    zip_code STRING,
    country STRING,
    start_date DATE,
    end_date DATE
)
STORED AS PARQUET
TBLPROPERTIES ('parquet.compression'='SNAPPY');

-- Documents Registry Table
CREATE TABLE IF NOT EXISTS documents_registry (
    document_id INT,
    application_id INT,
    document_type STRING,
    file_name STRING,
    file_location STRING,
    upload_date TIMESTAMP,
    required_flag BOOLEAN,
    received_flag BOOLEAN,
    approval_status STRING,
    approval_date TIMESTAMP,
    approved_by STRING,
    notes STRING
)
STORED AS PARQUET
TBLPROPERTIES ('parquet.compression'='SNAPPY');

-- Risk Assessments Table
CREATE TABLE IF NOT EXISTS risk_assessments (
    assessment_id INT,
    customer_id INT,
    application_id INT,
    assessment_date TIMESTAMP,
    credit_score INT,
    dti DECIMAL(5,2),
    ltv DECIMAL(5,2),
    fico_score_source STRING,
    risk_classification STRING,
    recommended_action STRING,
    notes STRING
)
STORED AS PARQUET
TBLPROPERTIES ('parquet.compression'='SNAPPY');

-- Loan Term Modifications Table
CREATE TABLE IF NOT EXISTS loan_term_modifications (
    modification_id INT,
    loan_id INT,
    modification_date DATE,
    modification_type STRING,
    previous_interest_rate DECIMAL(5,3),
    new_interest_rate DECIMAL(5,3),
    previous_term INT,
    new_term INT,
    previous_payment DECIMAL(12,2),
    new_payment DECIMAL(12,2),
    modification_fee DECIMAL(10,2),
    required_documents STRING,
    approval_status STRING,
    approved_by STRING,
    notes STRING
)
STORED AS PARQUET
TBLPROPERTIES ('parquet.compression'='SNAPPY');

-- Capital Market Data Table
CREATE TABLE IF NOT EXISTS capital_market_data (
    market_data_id INT,
    data_date DATE,
    data_source STRING,
    treasury_10y DECIMAL(5,3),
    fed_funds_rate DECIMAL(5,3),
    libor_3m DECIMAL(5,3),
    sofr DECIMAL(5,3),
    mbs_30y_rate DECIMAL(5,3),
    fannie_30y_rate DECIMAL(5,3),
    freddie_30y_rate DECIMAL(5,3),
    effective_date_start DATE,
    effective_date_end DATE
)
STORED AS PARQUET
TBLPROPERTIES ('parquet.compression'='SNAPPY');

-- Audit Log Table
CREATE TABLE IF NOT EXISTS audit_log (
    log_id INT,
    entity_type STRING,
    entity_id INT,
    action_type STRING,
    action_datetime TIMESTAMP,
    user_id STRING,
    old_values STRING,
    new_values STRING,
    ip_address STRING,
    application_name STRING
)
PARTITIONED BY (log_year INT, log_month INT)
STORED AS PARQUET
TBLPROPERTIES ('parquet.compression'='SNAPPY');

-- FINRA Fixed Income Table
CREATE TABLE IF NOT EXISTS finra_fi (
    symbol STRING,
    issuer_name STRING,
    coupon_type STRING,
    coupon_rate DOUBLE,
    maturity_date DATE,
    deal_id STRING,
    tranche_id STRING,
    issue_description STRING,
    interest_type STRING,
    i44a BOOLEAN,
    cusip STRING,
    sub_prod_type STRING,
    prod_subtype STRING,
    prod_type STRING,
    issuing_agency STRING,
    convertible STRING
)
STORED AS PARQUET
TBLPROPERTIES ('parquet.compression'='SNAPPY');

-- Interest Type Reference Table
CREATE TABLE IF NOT EXISTS interest_type (
    itid INT,
    interest_type_id STRING,
    interest_type_desc STRING
)
STORED AS PARQUET
TBLPROPERTIES ('parquet.compression'='SNAPPY');

-- Product Subtype Reference Table
CREATE TABLE IF NOT EXISTS product_subtype (
    ptid INT,
    prod_type STRING,
    prod_subtype STRING,
    pst_desc STRING
)
STORED AS PARQUET
TBLPROPERTIES ('parquet.compression'='SNAPPY');
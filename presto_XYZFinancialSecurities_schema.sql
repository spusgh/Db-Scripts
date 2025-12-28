-- =============================================
-- PrestoDB Complete Schema for XYZ_Financials_Securities
-- Federated SQL Query Engine
-- Compatible with Presto 0.280+
-- Using Hive Connector with Parquet format
-- =============================================

-- Create schema in Hive metastore
CREATE SCHEMA IF NOT EXISTS hive.xyz_financials_securities
WITH (location = 's3://your-bucket/xyz_financials_securities/');

USE hive.xyz_financials_securities;

-- =============================================
-- CORE DIMENSION TABLES
-- =============================================

-- Customers Table
CREATE TABLE IF NOT EXISTS customers (
    customer_id INTEGER,
    first_name VARCHAR,
    last_name VARCHAR,
    ssn VARCHAR(11),
    date_of_birth DATE,
    email VARCHAR,
    phone VARCHAR(20),
    annual_income DECIMAL(15,2),
    employment_status VARCHAR(50),
    employer VARCHAR(100),
    years_employed INTEGER,
    credit_score INTEGER,
    created_date TIMESTAMP,
    last_updated_date TIMESTAMP
)
WITH (
    format = 'PARQUET',
    parquet_compression = 'SNAPPY',
    external_location = 's3://your-bucket/xyz_financials_securities/customers/'
);

-- Mortgage Products Table
CREATE TABLE IF NOT EXISTS mortgage_products (
    product_id INTEGER,
    product_name VARCHAR(100),
    product_type VARCHAR(50),
    term INTEGER,
    base_interest_rate DECIMAL(5,3),
    min_credit_score INTEGER,
    max_ltv DECIMAL(5,2),
    min_loan_amount DECIMAL(15,2),
    max_loan_amount DECIMAL(15,2),
    origination_fee DECIMAL(5,2),
    is_active BOOLEAN
)
WITH (
    format = 'PARQUET',
    parquet_compression = 'SNAPPY',
    external_location = 's3://your-bucket/xyz_financials_securities/mortgage_products/'
);

-- Property Details Table (Partitioned by State)
CREATE TABLE IF NOT EXISTS property_details (
    property_id INTEGER,
    address_line1 VARCHAR(100),
    address_line2 VARCHAR(100),
    city VARCHAR(50),
    zip_code VARCHAR(10),
    country VARCHAR(50),
    property_type VARCHAR(50),
    year_built INTEGER,
    square_feet INTEGER,
    bedrooms INTEGER,
    bathrooms DECIMAL(3,1),
    purchase_price DECIMAL(15,2),
    current_value DECIMAL(15,2),
    last_appraisal_date DATE,
    last_appraisal_value DECIMAL(15,2),
    tax_assessment_value DECIMAL(15,2),
    annual_tax_amount DECIMAL(10,2),
    hoa_fees DECIMAL(10,2),
    flood_zone VARCHAR(10),
    property_tax_id VARCHAR(50),
    latitude DECIMAL(9,6),
    longitude DECIMAL(9,6),
    state VARCHAR(2)
)
WITH (
    format = 'PARQUET',
    partitioned_by = ARRAY['state'],
    parquet_compression = 'SNAPPY',
    external_location = 's3://your-bucket/xyz_financials_securities/property_details/'
);

-- Loan Officers Table
CREATE TABLE IF NOT EXISTS loan_officers (
    officer_id INTEGER,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100),
    phone VARCHAR(20),
    branch_id INTEGER,
    hire_date DATE,
    commission_rate DECIMAL(5,2),
    status VARCHAR(20)
)
WITH (
    format = 'PARQUET',
    parquet_compression = 'SNAPPY',
    external_location = 's3://your-bucket/xyz_financials_securities/loan_officers/'
);

-- =============================================
-- FACT TABLES
-- =============================================

-- Applications Table (Partitioned by Year and Month)
CREATE TABLE IF NOT EXISTS applications (
    application_id INTEGER,
    customer_id INTEGER,
    product_id INTEGER,
    officer_id INTEGER,
    application_date TIMESTAMP,
    loan_amount DECIMAL(15,2),
    loan_purpose VARCHAR(50),
    status VARCHAR(50),
    closing_date DATE,
    application_fee DECIMAL(10,2),
    dti DECIMAL(5,2),
    property_value DECIMAL(15,2),
    ltv DECIMAL(5,2),
    rate_offered DECIMAL(5,3),
    term_offered INTEGER,
    denial_reason VARCHAR(255),
    application_year INTEGER,
    application_month INTEGER
)
WITH (
    format = 'PARQUET',
    partitioned_by = ARRAY['application_year', 'application_month'],
    parquet_compression = 'SNAPPY',
    external_location = 's3://your-bucket/xyz_financials_securities/applications/'
);

-- Securities Table
CREATE TABLE IF NOT EXISTS securities (
    security_id INTEGER,
    security_name VARCHAR(100),
    security_type VARCHAR(50),
    cusip VARCHAR(9),
    issue_date DATE,
    maturity_date DATE,
    coupon_rate DECIMAL(5,3),
    face_value DECIMAL(15,2),
    current_balance DECIMAL(15,2),
    issuer VARCHAR(100),
    rating VARCHAR(10),
    status VARCHAR(20),
    last_trade_date DATE,
    last_trade_price DECIMAL(10,3)
)
WITH (
    format = 'PARQUET',
    parquet_compression = 'SNAPPY',
    external_location = 's3://your-bucket/xyz_financials_securities/securities/'
);

-- Loans Table (Partitioned by Year and Status)
CREATE TABLE IF NOT EXISTS loans (
    loan_id INTEGER,
    application_id INTEGER,
    customer_id INTEGER,
    property_id INTEGER,
    product_id INTEGER,
    loan_amount DECIMAL(15,2),
    interest_rate DECIMAL(5,3),
    term INTEGER,
    origination_date DATE,
    maturity_date DATE,
    monthly_payment DECIMAL(12,2),
    remaining_balance DECIMAL(15,2),
    escrow_required BOOLEAN,
    pmi_required BOOLEAN,
    pmi_amount DECIMAL(10,2),
    first_payment_date DATE,
    next_payment_date DATE,
    payment_frequency VARCHAR(20),
    security_id INTEGER,
    last_updated_date DATE,
    origination_year INTEGER,
    status VARCHAR(20)
)
WITH (
    format = 'PARQUET',
    partitioned_by = ARRAY['origination_year', 'status'],
    parquet_compression = 'SNAPPY',
    external_location = 's3://your-bucket/xyz_financials_securities/loans/'
);

-- Payments Table (Partitioned by Year and Month)
CREATE TABLE IF NOT EXISTS payments (
    payment_id INTEGER,
    loan_id INTEGER,
    payment_date DATE,
    payment_amount DECIMAL(12,2),
    principal_amount DECIMAL(12,2),
    interest_amount DECIMAL(12,2),
    escrow_amount DECIMAL(12,2),
    late_fee_amount DECIMAL(10,2),
    payment_method VARCHAR(50),
    transaction_id VARCHAR(100),
    payment_status VARCHAR(20),
    processed_date TIMESTAMP,
    payment_year INTEGER,
    payment_month INTEGER
)
WITH (
    format = 'PARQUET',
    partitioned_by = ARRAY['payment_year', 'payment_month'],
    parquet_compression = 'SNAPPY',
    external_location = 's3://your-bucket/xyz_financials_securities/payments/',
    bucketed_by = ARRAY['loan_id'],
    bucket_count = 50
);

-- =============================================
-- SUPPORTING TABLES
-- =============================================

-- Escrow Accounts Table
CREATE TABLE IF NOT EXISTS escrow_accounts (
    escrow_id INTEGER,
    loan_id INTEGER,
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
WITH (
    format = 'PARQUET',
    parquet_compression = 'SNAPPY',
    external_location = 's3://your-bucket/xyz_financials_securities/escrow_accounts/'
);

-- Escrow Transactions Table (Partitioned by Year)
CREATE TABLE IF NOT EXISTS escrow_transactions (
    transaction_id INTEGER,
    escrow_id INTEGER,
    transaction_date DATE,
    transaction_type VARCHAR(50),
    amount DECIMAL(12,2),
    description VARCHAR(255),
    reference VARCHAR(100),
    transaction_year INTEGER
)
WITH (
    format = 'PARQUET',
    partitioned_by = ARRAY['transaction_year'],
    parquet_compression = 'SNAPPY',
    external_location = 's3://your-bucket/xyz_financials_securities/escrow_transactions/'
);

-- Defaults and Foreclosures Table
CREATE TABLE IF NOT EXISTS defaults_foreclosures (
    default_id INTEGER,
    loan_id INTEGER,
    default_date DATE,
    stage VARCHAR(50),
    reason_code VARCHAR(50),
    resolution_type VARCHAR(50),
    resolution_date DATE,
    loss_amount DECIMAL(15,2),
    collection_agency VARCHAR(100),
    legal_filing_date DATE,
    legal_case_number VARCHAR(50),
    notes VARCHAR
)
WITH (
    format = 'PARQUET',
    parquet_compression = 'SNAPPY',
    external_location = 's3://your-bucket/xyz_financials_securities/defaults_foreclosures/'
);

-- Servicing Rights Table
CREATE TABLE IF NOT EXISTS servicing_rights (
    servicing_id INTEGER,
    loan_id INTEGER,
    servicer_name VARCHAR(100),
    servicer_id INTEGER,
    transfer_date DATE,
    msr_value DECIMAL(15,2),
    servicing_fee DECIMAL(5,3),
    subservicer_name VARCHAR(100),
    transfer_reason VARCHAR(100)
)
WITH (
    format = 'PARQUET',
    parquet_compression = 'SNAPPY',
    external_location = 's3://your-bucket/xyz_financials_securities/servicing_rights/'
);

-- Customer Addresses Table
CREATE TABLE IF NOT EXISTS customer_addresses (
    address_id INTEGER,
    customer_id INTEGER,
    address_type VARCHAR(20),
    address_line1 VARCHAR(100),
    address_line2 VARCHAR(100),
    city VARCHAR(50),
    state VARCHAR(2),
    zip_code VARCHAR(10),
    country VARCHAR(50),
    start_date DATE,
    end_date DATE
)
WITH (
    format = 'PARQUET',
    parquet_compression = 'SNAPPY',
    external_location = 's3://your-bucket/xyz_financials_securities/customer_addresses/'
);

-- Documents Registry Table
CREATE TABLE IF NOT EXISTS documents_registry (
    document_id INTEGER,
    application_id INTEGER,
    document_type VARCHAR(100),
    file_name VARCHAR(255),
    file_location VARCHAR(255),
    upload_date TIMESTAMP,
    required_flag BOOLEAN,
    received_flag BOOLEAN,
    approval_status VARCHAR(20),
    approval_date TIMESTAMP,
    approved_by VARCHAR(100),
    notes VARCHAR
)
WITH (
    format = 'PARQUET',
    parquet_compression = 'SNAPPY',
    external_location = 's3://your-bucket/xyz_financials_securities/documents_registry/'
);

-- Risk Assessments Table
CREATE TABLE IF NOT EXISTS risk_assessments (
    assessment_id INTEGER,
    customer_id INTEGER,
    application_id INTEGER,
    assessment_date TIMESTAMP,
    credit_score INTEGER,
    dti DECIMAL(5,2),
    ltv DECIMAL(5,2),
    fico_score_source VARCHAR(50),
    risk_classification VARCHAR(20),
    recommended_action VARCHAR(50),
    notes VARCHAR
)
WITH (
    format = 'PARQUET',
    parquet_compression = 'SNAPPY',
    external_location = 's3://your-bucket/xyz_financials_securities/risk_assessments/'
);

-- Loan Term Modifications Table
CREATE TABLE IF NOT EXISTS loan_term_modifications (
    modification_id INTEGER,
    loan_id INTEGER,
    modification_date DATE,
    modification_type VARCHAR(50),
    previous_interest_rate DECIMAL(5,3),
    new_interest_rate DECIMAL(5,3),
    previous_term INTEGER,
    new_term INTEGER,
    previous_payment DECIMAL(12,2),
    new_payment DECIMAL(12,2),
    modification_fee DECIMAL(10,2),
    required_documents VARCHAR,
    approval_status VARCHAR(20),
    approved_by VARCHAR(100),
    notes VARCHAR
)
WITH (
    format = 'PARQUET',
    parquet_compression = 'SNAPPY',
    external_location = 's3://your-bucket/xyz_financials_securities/loan_term_modifications/'
);

-- Capital Market Data Table
CREATE TABLE IF NOT EXISTS capital_market_data (
    market_data_id INTEGER,
    data_date DATE,
    data_source VARCHAR(100),
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
WITH (
    format = 'PARQUET',
    parquet_compression = 'SNAPPY',
    external_location = 's3://your-bucket/xyz_financials_securities/capital_market_data/'
);

-- Audit Log Table (Partitioned by Year and Month)
CREATE TABLE IF NOT EXISTS audit_log (
    log_id BIGINT,
    entity_type VARCHAR(50),
    entity_id INTEGER,
    action_type VARCHAR(20),
    action_datetime TIMESTAMP,
    user_id VARCHAR(50),
    old_values VARCHAR,
    new_values VARCHAR,
    ip_address VARCHAR(50),
    application_name VARCHAR(100),
    log_year INTEGER,
    log_month INTEGER
)
WITH (
    format = 'PARQUET',
    partitioned_by = ARRAY['log_year', 'log_month'],
    parquet_compression = 'SNAPPY',
    external_location = 's3://your-bucket/xyz_financials_securities/audit_log/'
);

-- =============================================
-- REFERENCE TABLES
-- =============================================

-- FINRA Fixed Income Table
CREATE TABLE IF NOT EXISTS finra_fi (
    symbol VARCHAR(50),
    issuer_name VARCHAR(150),
    coupon_type VARCHAR(50),
    coupon_rate DOUBLE,
    maturity_date DATE,
    deal_id VARCHAR(50),
    tranche_id VARCHAR(50),
    issue_description VARCHAR(250),
    interest_type VARCHAR(50),
    i44a BOOLEAN,
    cusip VARCHAR(50),
    sub_prod_type VARCHAR(50),
    prod_subtype VARCHAR(50),
    prod_type VARCHAR(50),
    issuing_agency VARCHAR(100),
    convertible VARCHAR(1)
)
WITH (
    format = 'PARQUET',
    parquet_compression = 'SNAPPY',
    external_location = 's3://your-bucket/xyz_financials_securities/finra_fi/'
);

-- Interest Type Reference Table
CREATE TABLE IF NOT EXISTS interest_type (
    itid INTEGER,
    interest_type_id VARCHAR(10),
    interest_type_desc VARCHAR(50)
)
WITH (
    format = 'PARQUET',
    parquet_compression = 'SNAPPY',
    external_location = 's3://your-bucket/xyz_financials_securities/interest_type/'
);

-- Product Subtype Reference Table
CREATE TABLE IF NOT EXISTS product_subtype (
    ptid INTEGER,
    prod_type VARCHAR(50),
    prod_subtype VARCHAR(50),
    pst_desc VARCHAR(100)
)
WITH (
    format = 'PARQUET',
    parquet_compression = 'SNAPPY',
    external_location = 's3://your-bucket/xyz_financials_securities/product_subtype/'
);

-- =============================================
-- ANALYTICAL VIEWS
-- =============================================

-- Loan Portfolio Overview View
CREATE OR REPLACE VIEW vw_loan_portfolio_overview AS
SELECT 
    l.loan_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    p.address_line1 || ', ' || p.city || ', ' || p.state || ' ' || p.zip_code AS property_address,
    l.origination_date,
    l.maturity_date,
    l.loan_amount,
    l.remaining_balance,
    l.interest_rate,
    l.monthly_payment,
    l.status,
    mp.product_name,
    mp.product_type,
    s.security_name,
    sr.servicer_name
FROM loans l
JOIN customers c ON l.customer_id = c.customer_id
JOIN property_details p ON l.property_id = p.property_id
JOIN mortgage_products mp ON l.product_id = mp.product_id
LEFT JOIN securities s ON l.security_id = s.security_id
LEFT JOIN servicing_rights sr ON l.loan_id = sr.loan_id;

-- Delinquent Loans View
CREATE OR REPLACE VIEW vw_delinquent_loans AS
SELECT 
    l.loan_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    c.phone,
    c.email,
    p.address_line1 || ', ' || p.city || ', ' || p.state || ' ' || p.zip_code AS property_address,
    l.origination_date,
    l.remaining_balance,
    l.monthly_payment,
    l.next_payment_date,
    df.default_date,
    df.stage,
    date_diff('day', l.next_payment_date, current_date) AS days_past_due,
    CASE 
        WHEN date_diff('day', l.next_payment_date, current_date) BETWEEN 1 AND 30 THEN '1-30 Days'
        WHEN date_diff('day', l.next_payment_date, current_date) BETWEEN 31 AND 60 THEN '31-60 Days'
        WHEN date_diff('day', l.next_payment_date, current_date) BETWEEN 61 AND 90 THEN '61-90 Days'
        WHEN date_diff('day', l.next_payment_date, current_date) > 90 THEN '90+ Days'
        ELSE 'Current'
    END AS delinquency_bucket
FROM loans l
JOIN customers c ON l.customer_id = c.customer_id
JOIN property_details p ON l.property_id = p.property_id
LEFT JOIN defaults_foreclosures df ON l.loan_id = df.loan_id AND df.resolution_date IS NULL
WHERE l.next_payment_date < current_date AND l.status = 'Active';

-- Customer Portfolio View
CREATE OR REPLACE VIEW vw_customer_portfolio AS
SELECT 
    c.customer_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    c.email,
    c.phone,
    c.credit_score,
    COUNT(l.loan_id) AS active_loan_count,
    SUM(l.loan_amount) AS total_loan_amount,
    SUM(l.remaining_balance) AS total_remaining_balance,
    MAX(l.origination_date) AS most_recent_loan_date
FROM customers c
LEFT JOIN loans l ON c.customer_id = l.customer_id AND l.status = 'Active'
GROUP BY c.customer_id, c.first_name, c.last_name, c.email, c.phone, c.credit_score;

-- Loan Officer Performance View
CREATE OR REPLACE VIEW vw_loan_officer_performance AS
SELECT 
    lo.officer_id,
    lo.first_name || ' ' || lo.last_name AS officer_name,
    COUNT(a.application_id) AS total_applications,
    SUM(CASE WHEN a.status = 'Approved' THEN 1 ELSE 0 END) AS approved_applications,
    SUM(CASE WHEN a.status = 'Denied' THEN 1 ELSE 0 END) AS denied_applications,
    CAST(SUM(CASE WHEN a.status = 'Approved' THEN 1 ELSE 0 END) AS DOUBLE) / 
        NULLIF(COUNT(a.application_id), 0) * 100 AS approval_rate,
    SUM(l.loan_amount) AS total_loan_amount,
    AVG(date_diff('day', a.application_date, a.closing_date)) AS avg_days_to_close
FROM loan_officers lo
LEFT JOIN applications a ON lo.officer_id = a.officer_id
LEFT JOIN loans l ON a.application_id = l.application_id AND a.status = 'Approved'
GROUP BY lo.officer_id, lo.first_name, lo.last_name;

-- Payment Analysis View
CREATE OR REPLACE VIEW vw_payment_analysis AS
SELECT 
    year(p.payment_date) AS payment_year,
    month(p.payment_date) AS payment_month,
    l.status AS loan_status,
    COUNT(p.payment_id) AS payment_count,
    SUM(p.payment_amount) AS total_payments,
    SUM(p.principal_amount) AS total_principal,
    SUM(p.interest_amount) AS total_interest,
    SUM(p.escrow_amount) AS total_escrow,
    SUM(p.late_fee_amount) AS total_late_fees,
    AVG(p.payment_amount) AS avg_payment_amount
FROM payments p
JOIN loans l ON p.loan_id = l.loan_id
GROUP BY year(p.payment_date), month(p.payment_date), l.status;

-- Loan Aging Analysis
CREATE OR REPLACE VIEW vw_loan_aging_analysis AS
SELECT 
    year(l.origination_date) AS origination_year,
    quarter(l.origination_date) AS origination_quarter,
    l.status,
    mp.product_type,
    p.state,
    COUNT(l.loan_id) AS loan_count,
    SUM(l.loan_amount) AS total_loan_amount,
    SUM(l.remaining_balance) AS total_remaining_balance,
    AVG(l.interest_rate) AS avg_interest_rate,
    AVG(date_diff('month', l.origination_date, current_date)) AS avg_age_months
FROM loans l
JOIN mortgage_products mp ON l.product_id = mp.product_id
JOIN property_details p ON l.property_id = p.property_id
GROUP BY year(l.origination_date), quarter(l.origination_date), l.status, mp.product_type, p.state;

-- =============================================
-- QUERY OPTIMIZATION HINTS
-- =============================================

-- Use these session properties for better performance:
-- SET SESSION query_max_memory_per_node = '2GB';
-- SET SESSION join_distribution_type = 'AUTOMATIC';
-- SET SESSION optimize_hash_generation = true;
-- SET SESSION push_aggregation_through_join = true;
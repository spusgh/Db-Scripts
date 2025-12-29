
-- =============================================
-- Apache Impala Complete Schema for XYZ_Financials_Securities
-- Compatible with Impala 3.x+
-- Optimized for analytical queries with partitioning
-- =============================================

CREATE DATABASE IF NOT EXISTS xyz_financials_securities
COMMENT 'Financial Securities and Mortgage Lending Database';

USE xyz_financials_securities;

-- =============================================
-- CORE TABLES
-- =============================================

-- Customers Table
CREATE TABLE customers (
    customer_id INT,
    first_name STRING,
    last_name STRING,
    ssn STRING,
    date_of_birth TIMESTAMP,
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

COMPUTE STATS customers;

-- Mortgage Products Table
CREATE TABLE mortgage_products (
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

COMPUTE STATS mortgage_products;

-- Property Details Table (Partitioned by State)
CREATE TABLE property_details (
    property_id INT,
    address_line1 STRING,
    address_line2 STRING,
    city STRING,
    zip_code STRING,
    country STRING,
    property_type STRING,
    year_built INT,
    square_feet INT,
    bedrooms INT,
    bathrooms DECIMAL(3,1),
    purchase_price DECIMAL(15,2),
    current_value DECIMAL(15,2),
    last_appraisal_date TIMESTAMP,
    last_appraisal_value DECIMAL(15,2),
    tax_assessment_value DECIMAL(15,2),
    annual_tax_amount DECIMAL(10,2),
    hoa_fees DECIMAL(10,2),
    flood_zone STRING,
    property_tax_id STRING,
    latitude DECIMAL(9,6),
    longitude DECIMAL(9,6),
    state STRING
)
PARTITIONED BY (state STRING)
STORED AS PARQUET
TBLPROPERTIES ('parquet.compression'='SNAPPY');

-- Loan Officers Table
CREATE TABLE loan_officers (
    officer_id INT,
    first_name STRING,
    last_name STRING,
    email STRING,
    phone STRING,
    branch_id INT,
    hire_date TIMESTAMP,
    commission_rate DECIMAL(5,2),
    status STRING
)
STORED AS PARQUET
TBLPROPERTIES ('parquet.compression'='SNAPPY');

COMPUTE STATS loan_officers;

-- Applications Table (Partitioned by Year and Month)
CREATE TABLE applications (
    application_id INT,
    customer_id INT,
    product_id INT,
    officer_id INT,
    application_date TIMESTAMP,
    loan_amount DECIMAL(15,2),
    loan_purpose STRING,
    status STRING,
    closing_date TIMESTAMP,
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
CREATE TABLE securities (
    security_id INT,
    security_name STRING,
    security_type STRING,
    cusip STRING,
    issue_date TIMESTAMP,
    maturity_date TIMESTAMP,
    coupon_rate DECIMAL(5,3),
    face_value DECIMAL(15,2),
    current_balance DECIMAL(15,2),
    issuer STRING,
    rating STRING,
    status STRING,
    last_trade_date TIMESTAMP,
    last_trade_price DECIMAL(10,3)
)
STORED AS PARQUET
TBLPROPERTIES ('parquet.compression'='SNAPPY');

COMPUTE STATS securities;

-- Loans Table (Partitioned by Year and Status)
CREATE TABLE loans (
    loan_id INT,
    application_id INT,
    customer_id INT,
    property_id INT,
    product_id INT,
    loan_amount DECIMAL(15,2),
    interest_rate DECIMAL(5,3),
    term INT,
    origination_date TIMESTAMP,
    maturity_date TIMESTAMP,
    monthly_payment DECIMAL(12,2),
    remaining_balance DECIMAL(15,2),
    escrow_required BOOLEAN,
    pmi_required BOOLEAN,
    pmi_amount DECIMAL(10,2),
    first_payment_date TIMESTAMP,
    next_payment_date TIMESTAMP,
    payment_frequency STRING,
    security_id INT,
    last_updated_date TIMESTAMP
)
PARTITIONED BY (origination_year INT, status STRING)
STORED AS PARQUET
TBLPROPERTIES ('parquet.compression'='SNAPPY');

-- Payments Table (Partitioned by Year and Month)
CREATE TABLE payments (
    payment_id INT,
    loan_id INT,
    payment_date TIMESTAMP,
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
CREATE TABLE escrow_accounts (
    escrow_id INT,
    loan_id INT,
    current_balance DECIMAL(12,2),
    property_tax_amount DECIMAL(12,2),
    property_insurance_amount DECIMAL(12,2),
    pmi_amount DECIMAL(12,2),
    cushion_amount DECIMAL(12,2),
    last_analysis_date TIMESTAMP,
    next_analysis_date TIMESTAMP,
    monthly_contribution DECIMAL(12,2),
    shortage_amount DECIMAL(12,2)
)
STORED AS PARQUET
TBLPROPERTIES ('parquet.compression'='SNAPPY');

COMPUTE STATS escrow_accounts;

-- Escrow Transactions Table (Partitioned by Year)
CREATE TABLE escrow_transactions (
    transaction_id INT,
    escrow_id INT,
    transaction_date TIMESTAMP,
    transaction_type STRING,
    amount DECIMAL(12,2),
    description STRING,
    reference STRING
)
PARTITIONED BY (transaction_year INT)
STORED AS PARQUET
TBLPROPERTIES ('parquet.compression'='SNAPPY');

-- Defaults and Foreclosures Table
CREATE TABLE defaults_foreclosures (
    default_id INT,
    loan_id INT,
    default_date TIMESTAMP,
    stage STRING,
    reason_code STRING,
    resolution_type STRING,
    resolution_date TIMESTAMP,
    loss_amount DECIMAL(15,2),
    collection_agency STRING,
    legal_filing_date TIMESTAMP,
    legal_case_number STRING,
    notes STRING
)
STORED AS PARQUET
TBLPROPERTIES ('parquet.compression'='SNAPPY');

COMPUTE STATS defaults_foreclosures;

-- Servicing Rights Table
CREATE TABLE servicing_rights (
    servicing_id INT,
    loan_id INT,
    servicer_name STRING,
    servicer_id INT,
    transfer_date TIMESTAMP,
    msr_value DECIMAL(15,2),
    servicing_fee DECIMAL(5,3),
    subservicer_name STRING,
    transfer_reason STRING
)
STORED AS PARQUET
TBLPROPERTIES ('parquet.compression'='SNAPPY');

COMPUTE STATS servicing_rights;

-- Customer Addresses Table
CREATE TABLE customer_addresses (
    address_id INT,
    customer_id INT,
    address_type STRING,
    address_line1 STRING,
    address_line2 STRING,
    city STRING,
    state STRING,
    zip_code STRING,
    country STRING,
    start_date TIMESTAMP,
    end_date TIMESTAMP
)
STORED AS PARQUET
TBLPROPERTIES ('parquet.compression'='SNAPPY');

COMPUTE STATS customer_addresses;

-- Documents Registry Table
CREATE TABLE documents_registry (
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

COMPUTE STATS documents_registry;

-- Risk Assessments Table
CREATE TABLE risk_assessments (
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

COMPUTE STATS risk_assessments;

-- Loan Term Modifications Table
CREATE TABLE loan_term_modifications (
    modification_id INT,
    loan_id INT,
    modification_date TIMESTAMP,
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

COMPUTE STATS loan_term_modifications;

-- Capital Market Data Table
CREATE TABLE capital_market_data (
    market_data_id INT,
    data_date TIMESTAMP,
    data_source STRING,
    treasury_10y DECIMAL(5,3),
    fed_funds_rate DECIMAL(5,3),
    libor_3m DECIMAL(5,3),
    sofr DECIMAL(5,3),
    mbs_30y_rate DECIMAL(5,3),
    fannie_30y_rate DECIMAL(5,3),
    freddie_30y_rate DECIMAL(5,3),
    effective_date_start TIMESTAMP,
    effective_date_end TIMESTAMP
)
STORED AS PARQUET
TBLPROPERTIES ('parquet.compression'='SNAPPY');

COMPUTE STATS capital_market_data;

-- Audit Log Table (Partitioned by Year and Month)
CREATE TABLE audit_log (
    log_id BIGINT,
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
CREATE TABLE finra_fi (
    symbol STRING,
    issuer_name STRING,
    coupon_type STRING,
    coupon_rate DOUBLE,
    maturity_date TIMESTAMP,
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

COMPUTE STATS finra_fi;

-- Interest Type Reference Table
CREATE TABLE interest_type (
    itid INT,
    interest_type_id STRING,
    interest_type_desc STRING
)
STORED AS PARQUET
TBLPROPERTIES ('parquet.compression'='SNAPPY');

-- Product Subtype Reference Table
CREATE TABLE product_subtype (
    ptid INT,
    prod_type STRING,
    prod_subtype STRING,
    pst_desc STRING
)
STORED AS PARQUET
TBLPROPERTIES ('parquet.compression'='SNAPPY');

-- =============================================
-- ANALYTICAL VIEWS
-- =============================================

-- Loan Portfolio Overview
CREATE VIEW vw_loan_portfolio_overview AS
SELECT 
    l.loan_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    CONCAT(p.address_line1, ', ', p.city, ', ', p.state, ' ', p.zip_code) AS property_address,
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
CREATE VIEW vw_delinquent_loans AS
SELECT 
    l.loan_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    c.phone,
    c.email,
    CONCAT(p.address_line1, ', ', p.city, ', ', p.state, ' ', p.zip_code) AS property_address,
    l.origination_date,
    l.remaining_balance,
    l.monthly_payment,
    l.next_payment_date,
    df.default_date,
    df.stage,
    DATEDIFF(CAST(now() AS TIMESTAMP), l.next_payment_date) AS days_past_due,
    CASE 
        WHEN DATEDIFF(CAST(now() AS TIMESTAMP), l.next_payment_date) BETWEEN 1 AND 30 THEN '1-30 Days'
        WHEN DATEDIFF(CAST(now() AS TIMESTAMP), l.next_payment_date) BETWEEN 31 AND 60 THEN '31-60 Days'
        WHEN DATEDIFF(CAST(now() AS TIMESTAMP), l.next_payment_date) BETWEEN 61 AND 90 THEN '61-90 Days'
        WHEN DATEDIFF(CAST(now() AS TIMESTAMP), l.next_payment_date) > 90 THEN '90+ Days'
        ELSE 'Current'
    END AS delinquency_bucket
FROM loans l
JOIN customers c ON l.customer_id = c.customer_id
JOIN property_details p ON l.property_id = p.property_id
LEFT JOIN defaults_foreclosures df ON l.loan_id = df.loan_id AND df.resolution_date IS NULL
WHERE l.next_payment_date < CAST(now() AS TIMESTAMP) AND l.status = 'Active';

-- Customer Portfolio View
CREATE VIEW vw_customer_portfolio AS
SELECT 
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
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
CREATE VIEW vw_loan_officer_performance AS
SELECT 
    lo.officer_id,
    CONCAT(lo.first_name, ' ', lo.last_name) AS officer_name,
    COUNT(a.application_id) AS total_applications,
    SUM(CASE WHEN a.status = 'Approved' THEN 1 ELSE 0 END) AS approved_applications,
    SUM(CASE WHEN a.status = 'Denied' THEN 1 ELSE 0 END) AS denied_applications,
    CAST(SUM(CASE WHEN a.status = 'Approved' THEN 1 ELSE 0 END) AS DOUBLE) / 
        NULLIF(COUNT(a.application_id), 0) * 100 AS approval_rate,
    SUM(l.loan_amount) AS total_loan_amount,
    AVG(DATEDIFF(a.closing_date, a.application_date)) AS avg_days_to_close
FROM loan_officers lo
LEFT JOIN applications a ON lo.officer_id = a.officer_id
LEFT JOIN loans l ON a.application_id = l.application_id AND a.status = 'Approved'
GROUP BY lo.officer_id, lo.first_name, lo.last_name;

-- Payment History Analysis View
CREATE VIEW vw_payment_analysis AS
SELECT 
    YEAR(p.payment_date) AS payment_year,
    MONTH(p.payment_date) AS payment_month,
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
GROUP BY YEAR(p.payment_date), MONTH(p.payment_date), l.status;

-- =============================================
-- PERFORMANCE OPTIMIZATION
-- =============================================

-- Compute statistics for all tables
COMPUTE STATS customers;
COMPUTE STATS mortgage_products;
COMPUTE STATS loan_officers;
COMPUTE STATS securities;
COMPUTE STATS escrow_accounts;
COMPUTE STATS defaults_foreclosures;
COMPUTE STATS servicing_rights;
COMPUTE STATS customer_addresses;
COMPUTE STATS documents_registry;
COMPUTE STATS risk_assessments;
COMPUTE STATS loan_term_modifications;
COMPUTE STATS capital_market_data;
COMPUTE STATS finra_fi;
COMPUTE STATS interest_type;
COMPUTE STATS product_subtype;

-- Note: For partitioned tables, compute stats after data is loaded:
-- COMPUTE INCREMENTAL STATS property_details;
-- COMPUTE INCREMENTAL STATS applications;
-- COMPUTE INCREMENTAL STATS loans;
-- COMPUTE INCREMENTAL STATS payments;
-- COMPUTE INCREMENTAL STATS escrow_transactions;
-- COMPUTE INCREMENTAL STATS audit_log;
-- =============================================
-- Apache Cassandra Schema Design for XYZ Financials Securities
-- =============================================
-- Cassandra is optimized for write-heavy workloads and high availability
-- Design principle: Query-first design with data denormalization
-- =============================================

-- Create Keyspace
CREATE KEYSPACE IF NOT EXISTS xyz_financials
WITH replication = {
  'class': 'NetworkTopologyStrategy',
  'datacenter1': 3,
  'datacenter2': 2
}
AND durable_writes = true;

USE xyz_financials;

-- =============================================
-- CUSTOMERS
-- =============================================

-- Primary customer table (by customer_id)
CREATE TABLE customers_by_id (
    customer_id INT,
    first_name TEXT,
    last_name TEXT,
    ssn TEXT,
    date_of_birth DATE,
    email TEXT,
    phone TEXT,
    annual_income DECIMAL,
    employment_status TEXT,
    employer TEXT,
    years_employed INT,
    credit_score INT,
    created_date TIMESTAMP,
    last_updated_date TIMESTAMP,
    PRIMARY KEY (customer_id)
);

-- Customers by email (for email lookup)
CREATE TABLE customers_by_email (
    email TEXT,
    customer_id INT,
    first_name TEXT,
    last_name TEXT,
    credit_score INT,
    PRIMARY KEY (email)
);

-- Customers by SSN (for SSN lookup)
CREATE TABLE customers_by_ssn (
    ssn TEXT,
    customer_id INT,
    first_name TEXT,
    last_name TEXT,
    email TEXT,
    PRIMARY KEY (ssn)
);

-- Customer addresses
CREATE TABLE customer_addresses (
    customer_id INT,
    address_type TEXT,
    address_line1 TEXT,
    address_line2 TEXT,
    city TEXT,
    state TEXT,
    zip_code TEXT,
    country TEXT,
    start_date DATE,
    end_date DATE,
    PRIMARY KEY (customer_id, address_type)
);

-- Customer metrics (aggregated data)
CREATE TABLE customer_metrics (
    customer_id INT,
    metric_date DATE,
    active_loan_count INT,
    total_loan_amount DECIMAL,
    total_remaining_balance DECIMAL,
    current_dti DECIMAL,
    PRIMARY KEY (customer_id, metric_date)
) WITH CLUSTERING ORDER BY (metric_date DESC);

-- =============================================
-- LOANS
-- =============================================

-- Loans by loan_id (primary table)
CREATE TABLE loans_by_id (
    loan_id INT,
    application_id INT,
    customer_id INT,
    property_id INT,
    product_id INT,
    loan_amount DECIMAL,
    interest_rate DECIMAL,
    term INT,
    origination_date DATE,
    maturity_date DATE,
    monthly_payment DECIMAL,
    remaining_balance DECIMAL,
    status TEXT,
    escrow_required BOOLEAN,
    pmi_required BOOLEAN,
    pmi_amount DECIMAL,
    first_payment_date DATE,
    next_payment_date DATE,
    payment_frequency TEXT,
    security_id INT,
    last_updated_date TIMESTAMP,
    PRIMARY KEY (loan_id)
);

-- Loans by customer (for customer portfolio queries)
CREATE TABLE loans_by_customer (
    customer_id INT,
    origination_date DATE,
    loan_id INT,
    loan_amount DECIMAL,
    remaining_balance DECIMAL,
    interest_rate DECIMAL,
    status TEXT,
    monthly_payment DECIMAL,
    next_payment_date DATE,
    PRIMARY KEY (customer_id, origination_date, loan_id)
) WITH CLUSTERING ORDER BY (origination_date DESC, loan_id DESC);

-- Loans by status (for portfolio management)
CREATE TABLE loans_by_status (
    status TEXT,
    next_payment_date DATE,
    loan_id INT,
    customer_id INT,
    remaining_balance DECIMAL,
    monthly_payment DECIMAL,
    PRIMARY KEY (status, next_payment_date, loan_id)
) WITH CLUSTERING ORDER BY (next_payment_date ASC, loan_id ASC);

-- Delinquent loans (specialized table for collections)
CREATE TABLE delinquent_loans (
    delinquency_bucket TEXT, -- '1-30', '31-60', '61-90', '90+'
    next_payment_date DATE,
    loan_id INT,
    customer_id INT,
    customer_name TEXT,
    customer_phone TEXT,
    customer_email TEXT,
    remaining_balance DECIMAL,
    monthly_payment DECIMAL,
    days_past_due INT,
    PRIMARY KEY (delinquency_bucket, next_payment_date, loan_id)
) WITH CLUSTERING ORDER BY (next_payment_date ASC, loan_id ASC);

-- Loans by security (for MBS pool management)
CREATE TABLE loans_by_security (
    security_id INT,
    loan_id INT,
    customer_id INT,
    origination_date DATE,
    loan_amount DECIMAL,
    remaining_balance DECIMAL,
    interest_rate DECIMAL,
    status TEXT,
    PRIMARY KEY (security_id, loan_id)
);

-- =============================================
-- PAYMENTS
-- =============================================

-- Payments by loan (time-series data)
CREATE TABLE payments_by_loan (
    loan_id INT,
    payment_date DATE,
    payment_id INT,
    payment_amount DECIMAL,
    principal_amount DECIMAL,
    interest_amount DECIMAL,
    escrow_amount DECIMAL,
    late_fee_amount DECIMAL,
    payment_method TEXT,
    transaction_id TEXT,
    payment_status TEXT,
    processed_date TIMESTAMP,
    PRIMARY KEY (loan_id, payment_date, payment_id)
) WITH CLUSTERING ORDER BY (payment_date DESC, payment_id DESC);

-- Payments by customer (for customer history)
CREATE TABLE payments_by_customer (
    customer_id INT,
    payment_date DATE,
    loan_id INT,
    payment_id INT,
    payment_amount DECIMAL,
    principal_amount DECIMAL,
    interest_amount DECIMAL,
    payment_status TEXT,
    PRIMARY KEY (customer_id, payment_date, loan_id)
) WITH CLUSTERING ORDER BY (payment_date DESC);

-- Payments by date (for daily reconciliation)
CREATE TABLE payments_by_date (
    payment_date DATE,
    payment_hour INT, -- Bucketing by hour for scalability
    payment_id INT,
    loan_id INT,
    customer_id INT,
    payment_amount DECIMAL,
    payment_method TEXT,
    transaction_id TEXT,
    payment_status TEXT,
    PRIMARY KEY (payment_date, payment_hour, payment_id)
) WITH CLUSTERING ORDER BY (payment_hour DESC, payment_id DESC);

-- =============================================
-- APPLICATIONS
-- =============================================

-- Applications by application_id
CREATE TABLE applications_by_id (
    application_id INT,
    customer_id INT,
    product_id INT,
    officer_id INT,
    application_date TIMESTAMP,
    loan_amount DECIMAL,
    loan_purpose TEXT,
    status TEXT,
    closing_date DATE,
    application_fee DECIMAL,
    dti DECIMAL,
    property_value DECIMAL,
    ltv DECIMAL,
    rate_offered DECIMAL,
    term_offered INT,
    denial_reason TEXT,
    PRIMARY KEY (application_id)
);

-- Applications by customer
CREATE TABLE applications_by_customer (
    customer_id INT,
    application_date TIMESTAMP,
    application_id INT,
    loan_amount DECIMAL,
    status TEXT,
    officer_id INT,
    PRIMARY KEY (customer_id, application_date, application_id)
) WITH CLUSTERING ORDER BY (application_date DESC, application_id DESC);

-- Applications by loan officer
CREATE TABLE applications_by_officer (
    officer_id INT,
    application_date TIMESTAMP,
    application_id INT,
    customer_id INT,
    loan_amount DECIMAL,
    status TEXT,
    closing_date DATE,
    PRIMARY KEY (officer_id, application_date, application_id)
) WITH CLUSTERING ORDER BY (application_date DESC, application_id DESC);

-- Applications by status
CREATE TABLE applications_by_status (
    status TEXT,
    application_date TIMESTAMP,
    application_id INT,
    customer_id INT,
    officer_id INT,
    loan_amount DECIMAL,
    PRIMARY KEY (status, application_date, application_id)
) WITH CLUSTERING ORDER BY (application_date DESC);

-- =============================================
-- PROPERTIES
-- =============================================

-- Properties by property_id
CREATE TABLE properties_by_id (
    property_id INT,
    address_line1 TEXT,
    address_line2 TEXT,
    city TEXT,
    state TEXT,
    zip_code TEXT,
    country TEXT,
    property_type TEXT,
    year_built INT,
    square_feet INT,
    bedrooms INT,
    bathrooms DECIMAL,
    purchase_price DECIMAL,
    current_value DECIMAL,
    last_appraisal_date DATE,
    last_appraisal_value DECIMAL,
    tax_assessment_value DECIMAL,
    annual_tax_amount DECIMAL,
    hoa_fees DECIMAL,
    flood_zone TEXT,
    property_tax_id TEXT,
    latitude DECIMAL,
    longitude DECIMAL,
    PRIMARY KEY (property_id)
);

-- Properties by location (for geographic queries)
CREATE TABLE properties_by_location (
    state TEXT,
    city TEXT,
    zip_code TEXT,
    property_id INT,
    address_line1 TEXT,
    property_type TEXT,
    current_value DECIMAL,
    PRIMARY KEY ((state, city), zip_code, property_id)
) WITH CLUSTERING ORDER BY (zip_code ASC, property_id ASC);

-- =============================================
-- SECURITIES
-- =============================================

-- Securities by security_id
CREATE TABLE securities_by_id (
    security_id INT,
    security_name TEXT,
    security_type TEXT,
    cusip TEXT,
    issue_date DATE,
    maturity_date DATE,
    coupon_rate DECIMAL,
    face_value DECIMAL,
    current_balance DECIMAL,
    issuer TEXT,
    rating TEXT,
    status TEXT,
    last_trade_date DATE,
    last_trade_price DECIMAL,
    PRIMARY KEY (security_id)
);

-- Securities by CUSIP
CREATE TABLE securities_by_cusip (
    cusip TEXT,
    security_id INT,
    security_name TEXT,
    security_type TEXT,
    current_balance DECIMAL,
    status TEXT,
    PRIMARY KEY (cusip)
);

-- Securities by type
CREATE TABLE securities_by_type (
    security_type TEXT,
    issue_date DATE,
    security_id INT,
    security_name TEXT,
    current_balance DECIMAL,
    status TEXT,
    rating TEXT,
    PRIMARY KEY (security_type, issue_date, security_id)
) WITH CLUSTERING ORDER BY (issue_date DESC);

-- =============================================
-- MORTGAGE PRODUCTS
-- =============================================

CREATE TABLE mortgage_products (
    product_id INT,
    product_name TEXT,
    product_type TEXT,
    term INT,
    base_interest_rate DECIMAL,
    min_credit_score INT,
    max_ltv DECIMAL,
    min_loan_amount DECIMAL,
    max_loan_amount DECIMAL,
    origination_fee DECIMAL,
    is_active BOOLEAN,
    PRIMARY KEY (product_id)
);

-- Products by type
CREATE TABLE mortgage_products_by_type (
    product_type TEXT,
    product_id INT,
    product_name TEXT,
    term INT,
    base_interest_rate DECIMAL,
    is_active BOOLEAN,
    PRIMARY KEY (product_type, product_id)
);

-- =============================================
-- LOAN OFFICERS
-- =============================================

CREATE TABLE loan_officers (
    officer_id INT,
    first_name TEXT,
    last_name TEXT,
    email TEXT,
    phone TEXT,
    branch_id INT,
    hire_date DATE,
    commission_rate DECIMAL,
    status TEXT,
    PRIMARY KEY (officer_id)
);

-- Loan officer performance (aggregated metrics)
CREATE TABLE loan_officer_performance (
    officer_id INT,
    period_start DATE,
    period_end DATE,
    total_applications INT,
    approved_applications INT,
    denied_applications INT,
    approval_rate DECIMAL,
    total_loan_amount DECIMAL,
    total_commission DECIMAL,
    avg_days_to_close DECIMAL,
    last_calculated TIMESTAMP,
    PRIMARY KEY (officer_id, period_start)
) WITH CLUSTERING ORDER BY (period_start DESC);

-- =============================================
-- ESCROW ACCOUNTS
-- =============================================

-- Escrow by loan
CREATE TABLE escrow_accounts (
    loan_id INT,
    current_balance DECIMAL,
    property_tax_amount DECIMAL,
    property_insurance_amount DECIMAL,
    pmi_amount DECIMAL,
    cushion_amount DECIMAL,
    monthly_contribution DECIMAL,
    shortage_amount DECIMAL,
    last_analysis_date DATE,
    next_analysis_date DATE,
    PRIMARY KEY (loan_id)
);

-- Escrow transactions (time-series)
CREATE TABLE escrow_transactions (
    loan_id INT,
    transaction_date DATE,
    transaction_id INT,
    transaction_type TEXT,
    amount DECIMAL,
    description TEXT,
    reference TEXT,
    PRIMARY KEY (loan_id, transaction_date, transaction_id)
) WITH CLUSTERING ORDER BY (transaction_date DESC, transaction_id DESC);

-- =============================================
-- DEFAULTS AND FORECLOSURES
-- =============================================

CREATE TABLE defaults_foreclosures (
    loan_id INT,
    default_date DATE,
    default_id INT,
    stage TEXT,
    reason_code TEXT,
    resolution_type TEXT,
    resolution_date DATE,
    loss_amount DECIMAL,
    collection_agency TEXT,
    legal_filing_date DATE,
    legal_case_number TEXT,
    notes TEXT,
    PRIMARY KEY (loan_id, default_date)
) WITH CLUSTERING ORDER BY (default_date DESC);

-- =============================================
-- SERVICING RIGHTS
-- =============================================

CREATE TABLE servicing_rights (
    loan_id INT,
    transfer_date DATE,
    servicing_id INT,
    servicer_name TEXT,
    servicer_id INT,
    msr_value DECIMAL,
    servicing_fee DECIMAL,
    subservicer_name TEXT,
    transfer_reason TEXT,
    PRIMARY KEY (loan_id, transfer_date)
) WITH CLUSTERING ORDER BY (transfer_date DESC);

-- =============================================
-- LOAN MODIFICATIONS
-- =============================================

CREATE TABLE loan_modifications (
    loan_id INT,
    modification_date DATE,
    modification_id INT,
    modification_type TEXT,
    previous_interest_rate DECIMAL,
    new_interest_rate DECIMAL,
    previous_term INT,
    new_term INT,
    previous_payment DECIMAL,
    new_payment DECIMAL,
    modification_fee DECIMAL,
    approval_status TEXT,
    approved_by TEXT,
    notes TEXT,
    PRIMARY KEY (loan_id, modification_date)
) WITH CLUSTERING ORDER BY (modification_date DESC);

-- =============================================
-- CAPITAL MARKET DATA (Time-series)
-- =============================================

CREATE TABLE capital_market_data (
    data_date DATE,
    data_source TEXT,
    treasury_10y DECIMAL,
    fed_funds_rate DECIMAL,
    libor_3m DECIMAL,
    sofr DECIMAL,
    mbs_30y_rate DECIMAL,
    fannie_30y_rate DECIMAL,
    freddie_30y_rate DECIMAL,
    effective_date_start DATE,
    effective_date_end DATE,
    PRIMARY KEY (data_date, data_source)
) WITH CLUSTERING ORDER BY (data_source ASC);

-- =============================================
-- AUDIT LOG
-- =============================================

CREATE TABLE audit_log (
    entity_type TEXT,
    entity_id INT,
    action_datetime TIMESTAMP,
    log_id INT,
    action_type TEXT,
    user_id TEXT,
    old_values TEXT, -- JSON string
    new_values TEXT, -- JSON string
    ip_address TEXT,
    application_name TEXT,
    PRIMARY KEY ((entity_type, entity_id), action_datetime, log_id)
) WITH CLUSTERING ORDER BY (action_datetime DESC, log_id DESC);

-- Audit by user
CREATE TABLE audit_log_by_user (
    user_id TEXT,
    action_datetime TIMESTAMP,
    log_id INT,
    entity_type TEXT,
    entity_id INT,
    action_type TEXT,
    PRIMARY KEY (user_id, action_datetime, log_id)
) WITH CLUSTERING ORDER BY (action_datetime DESC);

-- =============================================
-- MATERIALIZED VIEWS (Cassandra 3.0+)
-- =============================================

-- Active loans view
CREATE MATERIALIZED VIEW loans_active AS
    SELECT loan_id, customer_id, remaining_balance, status, next_payment_date
    FROM loans_by_id
    WHERE status IS NOT NULL 
      AND loan_id IS NOT NULL
      AND status = 'Active'
    PRIMARY KEY (status, loan_id)
    WITH CLUSTERING ORDER BY (loan_id ASC);

-- =============================================
-- SAMPLE QUERIES
-- =============================================

-- Get customer loans
-- SELECT * FROM loans_by_customer WHERE customer_id = 1234;

-- Get delinquent loans in 30-60 day bucket
-- SELECT * FROM delinquent_loans WHERE delinquency_bucket = '31-60';

-- Get loan payment history
-- SELECT * FROM payments_by_loan WHERE loan_id = 100000 LIMIT 12;

-- Get loan officer applications for date range
-- SELECT * FROM applications_by_officer 
-- WHERE officer_id = 5 
-- AND application_date >= '2024-01-01' 
-- AND application_date < '2024-12-31';

-- Get properties in a city
-- SELECT * FROM properties_by_location 
-- WHERE state = 'IL' AND city = 'Springfield';

-- =============================================
-- NOTES
-- =============================================
-- 1. Use appropriate consistency levels (LOCAL_QUORUM for writes, LOCAL_ONE for reads)
-- 2. Monitor partition sizes - large partitions can cause hotspots
-- 3. Use time-bucketing for high-volume time-series data
-- 4. Consider using Cassandra's TTL feature for temporary/audit data
-- 5. Use batch statements carefully - only for same partition writes
-- 6. Denormalization is essential - same data in multiple tables is normal
-- 7. Design tables based on query patterns, not normalization rules
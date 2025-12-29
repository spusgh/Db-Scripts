
-- =============================================
-- Apache Flink SQL Database Setup
-- XYZ_Financials_Securities Migration
-- =============================================
-- This file contains Flink SQL DDL statements to create
-- tables, views, and catalogs for streaming data processing
-- =============================================

-- =============================================
-- PART 1: CATALOG AND DATABASE SETUP
-- =============================================

-- Create catalog for financial data
CREATE CATALOG financials_catalog WITH (
    'type' = 'generic_in_memory'
);

USE CATALOG financials_catalog;

-- Create database
CREATE DATABASE IF NOT EXISTS xyz_financials;
USE xyz_financials;

-- =============================================
-- PART 2: KAFKA SOURCE TABLES
-- =============================================

-- Customers Table (Changelog Stream from Kafka)
CREATE TABLE customers (
    customer_id INT,
    first_name STRING,
    last_name STRING,
    ssn STRING,
    date_of_birth DATE,
    email STRING,
    phone STRING,
    annual_income DECIMAL(15, 2),
    employment_status STRING,
    employer STRING,
    years_employed INT,
    credit_score INT,
    created_date TIMESTAMP(3),
    last_updated_date TIMESTAMP(3),
    PRIMARY KEY (customer_id) NOT ENFORCED
) WITH (
    'connector' = 'upsert-kafka',
    'topic' = 'customers',
    'properties.bootstrap.servers' = 'localhost:9092',
    'properties.group.id' = 'flink-customers-consumer',
    'key.format' = 'json',
    'value.format' = 'json'
);

-- Loan Applications Table
CREATE TABLE applications (
    application_id INT,
    customer_id INT,
    product_id INT,
    officer_id INT,
    application_date TIMESTAMP(3),
    loan_amount DECIMAL(15, 2),
    loan_purpose STRING,
    status STRING,
    closing_date DATE,
    application_fee DECIMAL(10, 2),
    dti DECIMAL(5, 2),
    property_value DECIMAL(15, 2),
    ltv DECIMAL(5, 2),
    rate_offered DECIMAL(5, 3),
    term_offered INT,
    denial_reason STRING,
    WATERMARK FOR application_date AS application_date - INTERVAL '5' MINUTE,
    PRIMARY KEY (application_id) NOT ENFORCED
) WITH (
    'connector' = 'upsert-kafka',
    'topic' = 'loan-applications',
    'properties.bootstrap.servers' = 'localhost:9092',
    'properties.group.id' = 'flink-applications-consumer',
    'key.format' = 'json',
    'value.format' = 'json'
);

-- Loans Table
CREATE TABLE loans (
    loan_id INT,
    application_id INT,
    customer_id INT,
    property_id INT,
    product_id INT,
    loan_amount DECIMAL(15, 2),
    interest_rate DECIMAL(5, 3),
    term INT,
    origination_date DATE,
    maturity_date DATE,
    monthly_payment DECIMAL(12, 2),
    remaining_balance DECIMAL(15, 2),
    status STRING,
    escrow_required BOOLEAN,
    pmi_required BOOLEAN,
    pmi_amount DECIMAL(10, 2),
    first_payment_date DATE,
    next_payment_date DATE,
    payment_frequency STRING,
    security_id INT,
    last_updated_date DATE,
    PRIMARY KEY (loan_id) NOT ENFORCED
) WITH (
    'connector' = 'upsert-kafka',
    'topic' = 'loans',
    'properties.bootstrap.servers' = 'localhost:9092',
    'properties.group.id' = 'flink-loans-consumer',
    'key.format' = 'json',
    'value.format' = 'json'
);

-- Payments Table (High Volume Stream)
CREATE TABLE payments (
    payment_id INT,
    loan_id INT,
    payment_date TIMESTAMP(3),
    payment_amount DECIMAL(12, 2),
    principal_amount DECIMAL(12, 2),
    interest_amount DECIMAL(12, 2),
    escrow_amount DECIMAL(12, 2),
    late_fee_amount DECIMAL(10, 2),
    payment_method STRING,
    transaction_id STRING,
    payment_status STRING,
    processed_date TIMESTAMP(3),
    WATERMARK FOR payment_date AS payment_date - INTERVAL '10' MINUTE
) WITH (
    'connector' = 'kafka',
    'topic' = 'payments',
    'properties.bootstrap.servers' = 'localhost:9092',
    'properties.group.id' = 'flink-payments-consumer',
    'scan.startup.mode' = 'latest-offset',
    'format' = 'json',
    'json.fail-on-missing-field' = 'false',
    'json.ignore-parse-errors' = 'true'
);

-- Property Details Table
CREATE TABLE property_details (
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
    bathrooms DECIMAL(3, 1),
    purchase_price DECIMAL(15, 2),
    current_value DECIMAL(15, 2),
    last_appraisal_date DATE,
    last_appraisal_value DECIMAL(15, 2),
    tax_assessment_value DECIMAL(15, 2),
    annual_tax_amount DECIMAL(10, 2),
    hoa_fees DECIMAL(10, 2),
    flood_zone STRING,
    property_tax_id STRING,
    latitude DECIMAL(9, 6),
    longitude DECIMAL(9, 6),
    PRIMARY KEY (property_id) NOT ENFORCED
) WITH (
    'connector' = 'upsert-kafka',
    'topic' = 'properties',
    'properties.bootstrap.servers' = 'localhost:9092',
    'properties.group.id' = 'flink-properties-consumer',
    'key.format' = 'json',
    'value.format' = 'json'
);

-- Mortgage Products Table
CREATE TABLE mortgage_products (
    product_id INT,
    product_name STRING,
    product_type STRING,
    term INT,
    base_interest_rate DECIMAL(5, 3),
    min_credit_score INT,
    max_ltv DECIMAL(5, 2),
    min_loan_amount DECIMAL(15, 2),
    max_loan_amount DECIMAL(15, 2),
    origination_fee DECIMAL(5, 2),
    is_active BOOLEAN,
    PRIMARY KEY (product_id) NOT ENFORCED
) WITH (
    'connector' = 'upsert-kafka',
    'topic' = 'mortgage-products',
    'properties.bootstrap.servers' = 'localhost:9092',
    'properties.group.id' = 'flink-products-consumer',
    'key.format' = 'json',
    'value.format' = 'json'
);

-- Loan Officers Table
CREATE TABLE loan_officers (
    officer_id INT,
    first_name STRING,
    last_name STRING,
    email STRING,
    phone STRING,
    branch_id INT,
    hire_date DATE,
    commission_rate DECIMAL(5, 2),
    status STRING,
    PRIMARY KEY (officer_id) NOT ENFORCED
) WITH (
    'connector' = 'upsert-kafka',
    'topic' = 'loan-officers',
    'properties.bootstrap.servers' = 'localhost:9092',
    'properties.group.id' = 'flink-officers-consumer',
    'key.format' = 'json',
    'value.format' = 'json'
);

-- Escrow Accounts Table
CREATE TABLE escrow_accounts (
    escrow_id INT,
    loan_id INT,
    current_balance DECIMAL(12, 2),
    property_tax_amount DECIMAL(12, 2),
    property_insurance_amount DECIMAL(12, 2),
    pmi_amount DECIMAL(12, 2),
    cushion_amount DECIMAL(12, 2),
    last_analysis_date DATE,
    next_analysis_date DATE,
    monthly_contribution DECIMAL(12, 2),
    shortage_amount DECIMAL(12, 2),
    PRIMARY KEY (escrow_id) NOT ENFORCED
) WITH (
    'connector' = 'upsert-kafka',
    'topic' = 'escrow-accounts',
    'properties.bootstrap.servers' = 'localhost:9092',
    'properties.group.id' = 'flink-escrow-consumer',
    'key.format' = 'json',
    'value.format' = 'json'
);

-- Escrow Transactions Table
CREATE TABLE escrow_transactions (
    transaction_id INT,
    escrow_id INT,
    transaction_date TIMESTAMP(3),
    transaction_type STRING,
    amount DECIMAL(12, 2),
    description STRING,
    reference STRING,
    WATERMARK FOR transaction_date AS transaction_date - INTERVAL '5' MINUTE
) WITH (
    'connector' = 'kafka',
    'topic' = 'escrow-transactions',
    'properties.bootstrap.servers' = 'localhost:9092',
    'properties.group.id' = 'flink-escrow-txn-consumer',
    'scan.startup.mode' = 'latest-offset',
    'format' = 'json'
);

-- Securities Table
CREATE TABLE securities (
    security_id INT,
    security_name STRING,
    security_type STRING,
    cusip STRING,
    issue_date DATE,
    maturity_date DATE,
    coupon_rate DECIMAL(5, 3),
    face_value DECIMAL(15, 2),
    current_balance DECIMAL(15, 2),
    issuer STRING,
    rating STRING,
    status STRING,
    last_trade_date DATE,
    last_trade_price DECIMAL(10, 3),
    PRIMARY KEY (security_id) NOT ENFORCED
) WITH (
    'connector' = 'upsert-kafka',
    'topic' = 'securities',
    'properties.bootstrap.servers' = 'localhost:9092',
    'properties.group.id' = 'flink-securities-consumer',
    'key.format' = 'json',
    'value.format' = 'json'
);

-- Defaults and Foreclosures Table
CREATE TABLE defaults_foreclosures (
    default_id INT,
    loan_id INT,
    default_date DATE,
    stage STRING,
    reason_code STRING,
    resolution_type STRING,
    resolution_date DATE,
    loss_amount DECIMAL(15, 2),
    collection_agency STRING,
    legal_filing_date DATE,
    legal_case_number STRING,
    notes STRING,
    PRIMARY KEY (default_id) NOT ENFORCED
) WITH (
    'connector' = 'upsert-kafka',
    'topic' = 'defaults-foreclosures',
    'properties.bootstrap.servers' = 'localhost:9092',
    'properties.group.id' = 'flink-defaults-consumer',
    'key.format' = 'json',
    'value.format' = 'json'
);

-- Servicing Rights Table
CREATE TABLE servicing_rights (
    servicing_id INT,
    loan_id INT,
    servicer_name STRING,
    servicer_id INT,
    transfer_date DATE,
    msr_value DECIMAL(15, 2),
    servicing_fee DECIMAL(5, 3),
    subservicer_name STRING,
    transfer_reason STRING,
    PRIMARY KEY (servicing_id) NOT ENFORCED
) WITH (
    'connector' = 'upsert-kafka',
    'topic' = 'servicing-rights',
    'properties.bootstrap.servers' = 'localhost:9092',
    'properties.group.id' = 'flink-servicing-consumer',
    'key.format' = 'json',
    'value.format' = 'json'
);

-- Loan Term Modifications Table
CREATE TABLE loan_term_modifications (
    modification_id INT,
    loan_id INT,
    modification_date DATE,
    modification_type STRING,
    previous_interest_rate DECIMAL(5, 3),
    new_interest_rate DECIMAL(5, 3),
    previous_term INT,
    new_term INT,
    previous_payment DECIMAL(12, 2),
    new_payment DECIMAL(12, 2),
    modification_fee DECIMAL(10, 2),
    required_documents STRING,
    approval_status STRING,
    approved_by STRING,
    notes STRING,
    PRIMARY KEY (modification_id) NOT ENFORCED
) WITH (
    'connector' = 'upsert-kafka',
    'topic' = 'loan-modifications',
    'properties.bootstrap.servers' = 'localhost:9092',
    'properties.group.id' = 'flink-modifications-consumer',
    'key.format' = 'json',
    'value.format' = 'json'
);

-- Risk Assessments Table
CREATE TABLE risk_assessments (
    assessment_id INT,
    customer_id INT,
    application_id INT,
    assessment_date TIMESTAMP(3),
    credit_score INT,
    dti DECIMAL(5, 2),
    ltv DECIMAL(5, 2),
    fico_score_source STRING,
    risk_classification STRING,
    recommended_action STRING,
    notes STRING,
    WATERMARK FOR assessment_date AS assessment_date - INTERVAL '5' MINUTE
) WITH (
    'connector' = 'kafka',
    'topic' = 'risk-assessments',
    'properties.bootstrap.servers' = 'localhost:9092',
    'properties.group.id' = 'flink-risk-consumer',
    'scan.startup.mode' = 'latest-offset',
    'format' = 'json'
);

-- Capital Market Data Table
CREATE TABLE capital_market_data (
    market_data_id INT,
    data_date DATE,
    data_source STRING,
    treasury_10y DECIMAL(5, 3),
    fed_funds_rate DECIMAL(5, 3),
    libor_3m DECIMAL(5, 3),
    sofr DECIMAL(5, 3),
    mbs_30y_rate DECIMAL(5, 3),
    fannie_30y_rate DECIMAL(5, 3),
    freddie_30y_rate DECIMAL(5, 3),
    effective_date_start DATE,
    effective_date_end DATE,
    PRIMARY KEY (market_data_id) NOT ENFORCED
) WITH (
    'connector' = 'upsert-kafka',
    'topic' = 'capital-market-data',
    'properties.bootstrap.servers' = 'localhost:9092',
    'properties.group.id' = 'flink-market-consumer',
    'key.format' = 'json',
    'value.format' = 'json'
);

-- =============================================
-- PART 3: DERIVED TABLES (SINK TABLES)
-- =============================================

-- Delinquency Alerts Sink Table
CREATE TABLE delinquency_alerts (
    loan_id INT,
    customer_id INT,
    days_past_due INT,
    delinquency_bucket STRING,
    alert_timestamp TIMESTAMP(3),
    outstanding_balance DECIMAL(15, 2),
    customer_name STRING,
    property_address STRING
) WITH (
    'connector' = 'kafka',
    'topic' = 'delinquency-alerts',
    'properties.bootstrap.servers' = 'localhost:9092',
    'format' = 'json'
);

-- Portfolio Metrics Sink Table
CREATE TABLE portfolio_metrics (
    metric_id STRING,
    metric_timestamp TIMESTAMP(3),
    total_active_loans INT,
    total_loan_amount DECIMAL(18, 2),
    total_outstanding_balance DECIMAL(18, 2),
    average_interest_rate DECIMAL(5, 3),
    delinquency_rate DECIMAL(5, 2),
    total_payments_today DECIMAL(18, 2),
    payment_count_today INT
) WITH (
    'connector' = 'kafka',
    'topic' = 'portfolio-metrics',
    'properties.bootstrap.servers' = 'localhost:9092',
    'format' = 'json'
);

-- Loan Payment Metrics Sink Table
CREATE TABLE loan_payment_metrics (
    loan_id INT,
    window_start TIMESTAMP(3),
    window_end TIMESTAMP(3),
    payment_count BIGINT,
    total_principal_paid DECIMAL(18, 2),
    total_interest_paid DECIMAL(18, 2),
    total_amount_paid DECIMAL(18, 2)
) WITH (
    'connector' = 'kafka',
    'topic' = 'loan-payment-metrics',
    'properties.bootstrap.servers' = 'localhost:9092',
    'format' = 'json'
);

-- =============================================
-- PART 4: VIEWS (Replicating SQL Server Views)
-- =============================================

-- View: Loan Portfolio Overview
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
    CASE 
        WHEN l.remaining_balance = 0 THEN 'Paid Off'
        WHEN l.status = 'Active' THEN 'Active'
        ELSE l.status
    END AS current_status
FROM loans l
INNER JOIN customers c ON l.customer_id = c.customer_id
INNER JOIN property_details p ON l.property_id = p.property_id
INNER JOIN mortgage_products mp ON l.product_id = mp.product_id
LEFT JOIN securities s ON l.security_id = s.security_id;

-- View: Delinquent Loans (Real-time calculation)
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
    TIMESTAMPDIFF(DAY, CAST(l.next_payment_date AS TIMESTAMP), CURRENT_TIMESTAMP) AS days_past_due,
    CASE 
        WHEN TIMESTAMPDIFF(DAY, CAST(l.next_payment_date AS TIMESTAMP), CURRENT_TIMESTAMP) BETWEEN 1 AND 30 THEN '1-30 Days'
        WHEN TIMESTAMPDIFF(DAY, CAST(l.next_payment_date AS TIMESTAMP), CURRENT_TIMESTAMP) BETWEEN 31 AND 60 THEN '31-60 Days'
        WHEN TIMESTAMPDIFF(DAY, CAST(l.next_payment_date AS TIMESTAMP), CURRENT_TIMESTAMP) BETWEEN 61 AND 90 THEN '61-90 Days'
        WHEN TIMESTAMPDIFF(DAY, CAST(l.next_payment_date AS TIMESTAMP), CURRENT_TIMESTAMP) > 90 THEN '90+ Days'
        ELSE 'Current'
    END AS delinquency_bucket
FROM loans l
INNER JOIN customers c ON l.customer_id = c.customer_id
INNER JOIN property_details p ON l.property_id = p.property_id
WHERE CAST(l.next_payment_date AS TIMESTAMP) < CURRENT_TIMESTAMP 
  AND l.status = 'Active';

-- View: Customer Portfolio
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

-- View: Escrow Analysis
CREATE VIEW vw_escrow_analysis AS
SELECT 
    e.escrow_id,
    l.loan_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    CONCAT(p.address_line1, ', ', p.city, ', ', p.state, ' ', p.zip_code) AS property_address,
    e.current_balance,
    e.property_tax_amount,
    e.property_insurance_amount,
    e.pmi_amount,
    e.monthly_contribution,
    e.last_analysis_date,
    e.next_analysis_date,
    e.shortage_amount,
    e.cushion_amount,
    p.annual_tax_amount
FROM escrow_accounts e
INNER JOIN loans l ON e.loan_id = l.loan_id
INNER JOIN customers c ON l.customer_id = c.customer_id
INNER JOIN property_details p ON l.property_id = p.property_id;

-- =============================================
-- PART 5: CONTINUOUS QUERIES (INSERT INTO)
-- =============================================

-- Continuous Query: Generate Delinquency Alerts
INSERT INTO delinquency_alerts
SELECT 
    l.loan_id,
    l.customer_id,
    TIMESTAMPDIFF(DAY, CAST(l.next_payment_date AS TIMESTAMP), CURRENT_TIMESTAMP) AS days_past_due,
    CASE 
        WHEN TIMESTAMPDIFF(DAY, CAST(l.next_payment_date AS TIMESTAMP), CURRENT_TIMESTAMP) > 90 THEN '90+ Days'
        WHEN TIMESTAMPDIFF(DAY, CAST(l.next_payment_date AS TIMESTAMP), CURRENT_TIMESTAMP) > 60 THEN '61-90 Days'
        WHEN TIMESTAMPDIFF(DAY, CAST(l.next_payment_date AS TIMESTAMP), CURRENT_TIMESTAMP) > 30 THEN '31-60 Days'
        ELSE '1-30 Days'
    END AS delinquency_bucket,
    CURRENT_TIMESTAMP AS alert_timestamp,
    l.remaining_balance AS outstanding_balance,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    CONCAT(p.address_line1, ', ', p.city, ', ', p.state) AS property_address
FROM loans l
INNER JOIN customers c ON l.customer_id = c.customer_id
INNER JOIN property_details p ON l.property_id = p.property_id
WHERE CAST(l.next_payment_date AS TIMESTAMP) < CURRENT_TIMESTAMP 
  AND l.status = 'Active'
  AND TIMESTAMPDIFF(DAY, CAST(l.next_payment_date AS TIMESTAMP), CURRENT_TIMESTAMP) > 0;

-- Continuous Query: Calculate Loan Payment Metrics (Tumbling Window)
INSERT INTO loan_payment_metrics
SELECT 
    loan_id,
    TUMBLE_START(payment_date, INTERVAL '1' DAY) AS window_start,
    TUMBLE_END(payment_date, INTERVAL '1' DAY) AS window_end,
    COUNT(*) AS payment_count,
    SUM(principal_amount) AS total_principal_paid,
    SUM(interest_amount) AS total_interest_paid,
    SUM(payment_amount) AS total_amount_paid
FROM payments
WHERE payment_status = 'Processed'
GROUP BY loan_id, TUMBLE(payment_date, INTERVAL '1' DAY);

-- =============================================
-- PART 6: USER-DEFINED FUNCTIONS (UDFs)
-- =============================================

-- Note: Flink SQL UDFs need to be registered via Java/Scala code
-- Below are SQL equivalents where possible

-- Function: Calculate Current Balance
-- This would be a scalar UDF in Java, but can be approximated with a subquery

-- Function: Calculate Interest for Period
-- CREATE FUNCTION fn_calculate_interest AS 'com.xyz.flink.udf.CalculateInterest';

-- Function: Calculate Loan Age in Months
-- Can be done inline with TIMESTAMPDIFF

-- Function: Get Customer DTI
-- Can be calculated with joins and aggregations in queries

-- Function: Is Property in Flood Zone
-- Can be done with CASE statement on flood_zone field

-- =============================================
-- PART 7: MATERIALIZED VIEWS (STATE QUERIES)
-- =============================================

-- These queries maintain state and can be queried

-- Daily Payment Summary
CREATE VIEW daily_payment_summary AS
SELECT 
    CAST(payment_date AS DATE) AS payment_day,
    COUNT(*) AS payment_count,
    SUM(payment_amount) AS total_amount,
    SUM(principal_amount) AS total_principal,
    SUM(interest_amount) AS total_interest,
    AVG(payment_amount) AS avg_payment
FROM payments
WHERE payment_status = 'Processed'
GROUP BY CAST(payment_date AS DATE);

-- Loan Status Distribution
CREATE VIEW loan_status_distribution AS
SELECT 
    status,
    COUNT(*) AS loan_count,
    SUM(loan_amount) AS total_amount,
    AVG(interest_rate) AS avg_rate
FROM loans
GROUP BY status;

-- =============================================
-- END OF FLINK SQL SETUP
-- =============================================

-- To execute this file in Flink SQL Client:
-- 1. Start Flink cluster
-- 2. Start Kafka cluster
-- 3. Run: sql-client.sh -f flink_complete_setup.sql

-- For programmatic execution, use Flink Table API:
-- TableEnvironment tableEnv = TableEnvironment.create(settings);
-- tableEnv.executeSql(sqlContent);
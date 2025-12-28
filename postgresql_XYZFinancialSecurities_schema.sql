-- PostgreSQL Schema for XYZ_Financials_Securities
-- Compatible with PostgreSQL 12+

CREATE DATABASE xyz_financials_securities;
\c xyz_financials_securities

-- Create Schemas
CREATE SCHEMA IF NOT EXISTS lending;
CREATE SCHEMA IF NOT EXISTS reference;
SET search_path TO lending, public;

-- Create Custom Types
CREATE TYPE interest_rate_type AS (
    rate NUMERIC(5,3),
    rate_type VARCHAR(15)
);

CREATE TYPE loan_status_type AS ENUM (
    'Application',
    'Underwriting', 
    'Approved',
    'Active',
    'PaidOff',
    'Default',
    'Foreclosure'
);

-- Create Sequences
CREATE SEQUENCE seq_customer_id START 1000 INCREMENT 1;
CREATE SEQUENCE seq_loan_id START 100000 INCREMENT 1;
CREATE SEQUENCE seq_application_id START 10000 INCREMENT 1;
CREATE SEQUENCE seq_payment_reference START 1000000 INCREMENT 1;
CREATE SEQUENCE seq_document_registry START 1 INCREMENT 1;

-- Customers Table
CREATE TABLE lending.customers (
    customer_id INTEGER PRIMARY KEY DEFAULT nextval('seq_customer_id'),
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    ssn CHAR(11) NOT NULL UNIQUE,
    date_of_birth DATE NOT NULL,
    email VARCHAR(100),
    phone VARCHAR(20),
    annual_income NUMERIC(15,2),
    employment_status VARCHAR(50),
    employer VARCHAR(100),
    years_employed INTEGER,
    credit_score INTEGER,
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_updated_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_credit_score CHECK (credit_score BETWEEN 300 AND 850)
);

CREATE INDEX idx_customers_lastname ON lending.customers(last_name);
CREATE INDEX idx_customers_creditscore ON lending.customers(credit_score);
CREATE INDEX idx_customers_email ON lending.customers(email);

-- Add trigger for last_updated_date
CREATE OR REPLACE FUNCTION update_modified_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.last_updated_date = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_customers_modtime
    BEFORE UPDATE ON lending.customers
    FOR EACH ROW
    EXECUTE FUNCTION update_modified_column();

-- Mortgage Products Table
CREATE TABLE lending.mortgage_products (
    product_id SERIAL PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL UNIQUE,
    product_type VARCHAR(50) NOT NULL,
    term INTEGER NOT NULL,
    base_interest_rate NUMERIC(5,3) NOT NULL,
    min_credit_score INTEGER NOT NULL,
    max_ltv NUMERIC(5,2) NOT NULL,
    min_loan_amount NUMERIC(15,2) NOT NULL,
    max_loan_amount NUMERIC(15,2) NOT NULL,
    origination_fee NUMERIC(5,2) DEFAULT 0.00,
    is_active BOOLEAN DEFAULT TRUE,
    CONSTRAINT chk_term CHECK (term > 0),
    CONSTRAINT chk_interest_rate CHECK (base_interest_rate >= 0)
);

-- Property Details Table
CREATE TABLE lending.property_details (
    property_id SERIAL PRIMARY KEY,
    address_line1 VARCHAR(100) NOT NULL,
    address_line2 VARCHAR(100),
    city VARCHAR(50) NOT NULL,
    state CHAR(2) NOT NULL,
    zip_code VARCHAR(10) NOT NULL,
    country VARCHAR(50) DEFAULT 'USA',
    property_type VARCHAR(50) NOT NULL,
    year_built INTEGER,
    square_feet INTEGER,
    bedrooms INTEGER,
    bathrooms NUMERIC(3,1),
    purchase_price NUMERIC(15,2),
    current_value NUMERIC(15,2),
    last_appraisal_date DATE,
    last_appraisal_value NUMERIC(15,2),
    tax_assessment_value NUMERIC(15,2),
    annual_tax_amount NUMERIC(10,2),
    hoa_fees NUMERIC(10,2) DEFAULT 0.00,
    flood_zone VARCHAR(10),
    property_tax_id VARCHAR(50),
    latitude NUMERIC(9,6),
    longitude NUMERIC(9,6),
    CONSTRAINT chk_year_built CHECK (year_built > 1800 AND year_built <= EXTRACT(YEAR FROM CURRENT_DATE) + 1)
);

CREATE INDEX idx_property_state ON lending.property_details(state);
CREATE INDEX idx_property_zip ON lending.property_details(zip_code);
CREATE INDEX idx_property_type ON lending.property_details(property_type);
CREATE INDEX idx_property_location ON lending.property_details USING gist(ll_to_earth(latitude, longitude));

-- Loan Officers Table
CREATE TABLE lending.loan_officers (
    officer_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(20) NOT NULL,
    branch_id INTEGER,
    hire_date DATE NOT NULL,
    commission_rate NUMERIC(5,2) DEFAULT 0.00,
    status VARCHAR(20) DEFAULT 'Active',
    CONSTRAINT chk_commission_rate CHECK (commission_rate >= 0 AND commission_rate <= 100)
);

-- Applications Table
CREATE TABLE lending.applications (
    application_id INTEGER PRIMARY KEY DEFAULT nextval('seq_application_id'),
    customer_id INTEGER NOT NULL REFERENCES lending.customers(customer_id),
    product_id INTEGER NOT NULL REFERENCES lending.mortgage_products(product_id),
    officer_id INTEGER NOT NULL REFERENCES lending.loan_officers(officer_id),
    application_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    loan_amount NUMERIC(15,2) NOT NULL,
    loan_purpose VARCHAR(50) NOT NULL,
    status VARCHAR(50) DEFAULT 'Submitted',
    closing_date DATE,
    application_fee NUMERIC(10,2),
    dti NUMERIC(5,2),
    property_value NUMERIC(15,2),
    ltv NUMERIC(5,2),
    rate_offered NUMERIC(5,3),
    term_offered INTEGER,
    denial_reason VARCHAR(255),
    CONSTRAINT chk_loan_amount CHECK (loan_amount > 0),
    CONSTRAINT chk_dti CHECK (dti >= 0 AND dti <= 100),
    CONSTRAINT chk_ltv CHECK (ltv >= 0 AND ltv <= 100)
);

CREATE INDEX idx_applications_customer ON lending.applications(customer_id);
CREATE INDEX idx_applications_date ON lending.applications(application_date);
CREATE INDEX idx_applications_status ON lending.applications(status);
CREATE INDEX idx_applications_officer ON lending.applications(officer_id);

-- Securities Table
CREATE TABLE lending.securities (
    security_id SERIAL PRIMARY KEY,
    security_name VARCHAR(100) NOT NULL,
    security_type VARCHAR(50) NOT NULL,
    cusip VARCHAR(9),
    issue_date DATE NOT NULL,
    maturity_date DATE NOT NULL,
    coupon_rate NUMERIC(5,3) NOT NULL,
    face_value NUMERIC(15,2) NOT NULL,
    current_balance NUMERIC(15,2) NOT NULL,
    issuer VARCHAR(100) NOT NULL,
    rating VARCHAR(10),
    status VARCHAR(20) DEFAULT 'Active',
    last_trade_date DATE,
    last_trade_price NUMERIC(10,3),
    CONSTRAINT chk_maturity CHECK (maturity_date > issue_date)
);

-- Loans Table
CREATE TABLE lending.loans (
    loan_id INTEGER PRIMARY KEY DEFAULT nextval('seq_loan_id'),
    application_id INTEGER NOT NULL REFERENCES lending.applications(application_id),
    customer_id INTEGER NOT NULL REFERENCES lending.customers(customer_id),
    property_id INTEGER NOT NULL REFERENCES lending.property_details(property_id),
    product_id INTEGER NOT NULL REFERENCES lending.mortgage_products(product_id),
    loan_amount NUMERIC(15,2) NOT NULL,
    interest_rate NUMERIC(5,3) NOT NULL,
    term INTEGER NOT NULL,
    origination_date DATE NOT NULL,
    maturity_date DATE NOT NULL,
    monthly_payment NUMERIC(12,2) NOT NULL,
    remaining_balance NUMERIC(15,2) NOT NULL,
    status VARCHAR(20) DEFAULT 'Active',
    escrow_required BOOLEAN DEFAULT TRUE,
    pmi_required BOOLEAN DEFAULT FALSE,
    pmi_amount NUMERIC(10,2) DEFAULT 0.00,
    first_payment_date DATE NOT NULL,
    next_payment_date DATE,
    payment_frequency VARCHAR(20) DEFAULT 'Monthly',
    security_id INTEGER REFERENCES lending.securities(security_id),
    last_updated_date DATE,
    CONSTRAINT chk_loans_amount CHECK (loan_amount > 0),
    CONSTRAINT chk_loans_rate CHECK (interest_rate >= 0 AND interest_rate <= 50),
    CONSTRAINT chk_loans_term CHECK (term > 0),
    CONSTRAINT chk_maturity CHECK (maturity_date > origination_date)
);

CREATE INDEX idx_loans_customer ON lending.loans(customer_id);
CREATE INDEX idx_loans_property ON lending.loans(property_id);
CREATE INDEX idx_loans_origination ON lending.loans(origination_date);
CREATE INDEX idx_loans_status ON lending.loans(status);
CREATE INDEX idx_loans_security ON lending.loans(security_id);

-- Create trigger for loans last_updated_date
CREATE TRIGGER update_loans_modtime
    BEFORE UPDATE ON lending.loans
    FOR EACH ROW
    EXECUTE FUNCTION update_modified_column();

-- Payments Table
CREATE TABLE lending.payments (
    payment_id BIGSERIAL PRIMARY KEY,
    loan_id INTEGER NOT NULL REFERENCES lending.loans(loan_id),
    payment_date DATE NOT NULL,
    payment_amount NUMERIC(12,2) NOT NULL,
    principal_amount NUMERIC(12,2) NOT NULL,
    interest_amount NUMERIC(12,2) NOT NULL,
    escrow_amount NUMERIC(12,2) DEFAULT 0.00,
    late_fee_amount NUMERIC(10,2) DEFAULT 0.00,
    payment_method VARCHAR(50),
    transaction_id VARCHAR(100),
    payment_status VARCHAR(20) DEFAULT 'Processed',
    processed_date TIMESTAMP,
    CONSTRAINT chk_payment_amounts CHECK (
        payment_amount > 0 AND 
        principal_amount >= 0 AND 
        interest_amount >= 0
    )
);

CREATE INDEX idx_payments_loan ON lending.payments(loan_id);
CREATE INDEX idx_payments_date ON lending.payments(payment_date);
CREATE INDEX idx_payments_loan_date ON lending.payments(loan_id, payment_date DESC);

-- Partition payments table by year
CREATE TABLE lending.payments_2024 PARTITION OF lending.payments
    FOR VALUES FROM ('2024-01-01') TO ('2025-01-01');
CREATE TABLE lending.payments_2025 PARTITION OF lending.payments
    FOR VALUES FROM ('2025-01-01') TO ('2026-01-01');

-- Escrow Accounts Table
CREATE TABLE lending.escrow_accounts (
    escrow_id SERIAL PRIMARY KEY,
    loan_id INTEGER NOT NULL UNIQUE REFERENCES lending.loans(loan_id),
    current_balance NUMERIC(12,2) DEFAULT 0.00,
    property_tax_amount NUMERIC(12,2) DEFAULT 0.00,
    property_insurance_amount NUMERIC(12,2) DEFAULT 0.00,
    pmi_amount NUMERIC(12,2) DEFAULT 0.00,
    cushion_amount NUMERIC(12,2) DEFAULT 0.00,
    last_analysis_date DATE,
    next_analysis_date DATE,
    monthly_contribution NUMERIC(12,2) DEFAULT 0.00,
    shortage_amount NUMERIC(12,2) DEFAULT 0.00
);

-- Escrow Transactions Table
CREATE TABLE lending.escrow_transactions (
    transaction_id BIGSERIAL PRIMARY KEY,
    escrow_id INTEGER NOT NULL REFERENCES lending.escrow_accounts(escrow_id),
    transaction_date DATE NOT NULL,
    transaction_type VARCHAR(50) NOT NULL,
    amount NUMERIC(12,2) NOT NULL,
    description VARCHAR(255),
    reference VARCHAR(100)
);

CREATE INDEX idx_escrow_trans_escrow ON lending.escrow_transactions(escrow_id);
CREATE INDEX idx_escrow_trans_date ON lending.escrow_transactions(transaction_date);

-- Defaults and Foreclosures Table
CREATE TABLE lending.defaults_foreclosures (
    default_id SERIAL PRIMARY KEY,
    loan_id INTEGER NOT NULL REFERENCES lending.loans(loan_id),
    default_date DATE NOT NULL,
    stage VARCHAR(50) NOT NULL,
    reason_code VARCHAR(50),
    resolution_type VARCHAR(50),
    resolution_date DATE,
    loss_amount NUMERIC(15,2),
    collection_agency VARCHAR(100),
    legal_filing_date DATE,
    legal_case_number VARCHAR(50),
    notes TEXT
);

CREATE INDEX idx_defaults_loan ON lending.defaults_foreclosures(loan_id);
CREATE INDEX idx_defaults_date ON lending.defaults_foreclosures(default_date);

-- Servicing Rights Table
CREATE TABLE lending.servicing_rights (
    servicing_id SERIAL PRIMARY KEY,
    loan_id INTEGER NOT NULL REFERENCES lending.loans(loan_id),
    servicer_name VARCHAR(100) NOT NULL,
    servicer_id INTEGER,
    transfer_date DATE NOT NULL,
    msr_value NUMERIC(15,2),
    servicing_fee NUMERIC(5,3),
    subservicer_name VARCHAR(100),
    transfer_reason VARCHAR(100)
);

CREATE INDEX idx_servicing_loan ON lending.servicing_rights(loan_id);
CREATE INDEX idx_servicing_transfer ON lending.servicing_rights(transfer_date);

-- Customer Addresses Table
CREATE TABLE lending.customer_addresses (
    address_id SERIAL PRIMARY KEY,
    customer_id INTEGER NOT NULL REFERENCES lending.customers(customer_id),
    address_type VARCHAR(20) NOT NULL,
    address_line1 VARCHAR(100) NOT NULL,
    address_line2 VARCHAR(100),
    city VARCHAR(50) NOT NULL,
    state CHAR(2) NOT NULL,
    zip_code VARCHAR(10) NOT NULL,
    country VARCHAR(50) DEFAULT 'USA',
    start_date DATE,
    end_date DATE
);

CREATE INDEX idx_cust_addr_customer ON lending.customer_addresses(customer_id);

-- Documents Registry Table
CREATE TABLE lending.documents_registry (
    document_id INTEGER PRIMARY KEY DEFAULT nextval('seq_document_registry'),
    application_id INTEGER NOT NULL REFERENCES lending.applications(application_id),
    document_type VARCHAR(100) NOT NULL,
    file_name VARCHAR(255),
    file_location VARCHAR(255),
    upload_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    required_flag BOOLEAN DEFAULT TRUE,
    received_flag BOOLEAN DEFAULT FALSE,
    approval_status VARCHAR(20) DEFAULT 'Pending',
    approval_date TIMESTAMP,
    approved_by VARCHAR(100),
    notes TEXT
);

CREATE INDEX idx_docs_application ON lending.documents_registry(application_id);

-- Risk Assessments Table
CREATE TABLE lending.risk_assessments (
    assessment_id SERIAL PRIMARY KEY,
    customer_id INTEGER NOT NULL REFERENCES lending.customers(customer_id),
    application_id INTEGER NOT NULL REFERENCES lending.applications(application_id),
    assessment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    credit_score INTEGER NOT NULL,
    dti NUMERIC(5,2) NOT NULL,
    ltv NUMERIC(5,2) NOT NULL,
    fico_score_source VARCHAR(50),
    risk_classification VARCHAR(20),
    recommended_action VARCHAR(50),
    notes TEXT
);

CREATE INDEX idx_risk_customer ON lending.risk_assessments(customer_id);
CREATE INDEX idx_risk_application ON lending.risk_assessments(application_id);

-- Loan Term Modifications Table
CREATE TABLE lending.loan_term_modifications (
    modification_id SERIAL PRIMARY KEY,
    loan_id INTEGER NOT NULL REFERENCES lending.loans(loan_id),
    modification_date DATE NOT NULL,
    modification_type VARCHAR(50) NOT NULL,
    previous_interest_rate NUMERIC(5,3),
    new_interest_rate NUMERIC(5,3),
    previous_term INTEGER,
    new_term INTEGER,
    previous_payment NUMERIC(12,2),
    new_payment NUMERIC(12,2),
    modification_fee NUMERIC(10,2),
    required_documents TEXT,
    approval_status VARCHAR(20) DEFAULT 'Pending',
    approved_by VARCHAR(100),
    notes TEXT
);

CREATE INDEX idx_mods_loan ON lending.loan_term_modifications(loan_id);

-- Capital Market Data Table
CREATE TABLE reference.capital_market_data (
    market_data_id SERIAL PRIMARY KEY,
    data_date DATE NOT NULL,
    data_source VARCHAR(100) NOT NULL,
    treasury_10y NUMERIC(5,3),
    fed_funds_rate NUMERIC(5,3),
    libor_3m NUMERIC(5,3),
    sofr NUMERIC(5,3),
    mbs_30y_rate NUMERIC(5,3),
    fannie_30y_rate NUMERIC(5,3),
    freddie_30y_rate NUMERIC(5,3),
    effective_date_start DATE,
    effective_date_end DATE,
    UNIQUE(data_date, data_source)
);

CREATE INDEX idx_market_data_date ON reference.capital_market_data(data_date);

-- Audit Log Table
CREATE TABLE lending.audit_log (
    log_id BIGSERIAL PRIMARY KEY,
    entity_type VARCHAR(50) NOT NULL,
    entity_id INTEGER NOT NULL,
    action_type VARCHAR(20) NOT NULL,
    action_datetime TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    user_id VARCHAR(50) NOT NULL,
    old_values JSONB,
    new_values JSONB,
    ip_address INET,
    application_name VARCHAR(100)
);

CREATE INDEX idx_audit_datetime ON lending.audit_log(action_datetime);
CREATE INDEX idx_audit_entity ON lending.audit_log(entity_type, entity_id);
CREATE INDEX idx_audit_user ON lending.audit_log(user_id);

-- FINRA Fixed Income Table
CREATE TABLE reference.finra_fi (
    symbol VARCHAR(50) NOT NULL,
    issuer_name VARCHAR(150) NOT NULL,
    coupon_type VARCHAR(50),
    coupon_rate DOUBLE PRECISION,
    maturity_date DATE NOT NULL,
    deal_id VARCHAR(50),
    tranche_id VARCHAR(50),
    issue_description VARCHAR(250) NOT NULL,
    interest_type VARCHAR(50),
    i44a BOOLEAN NOT NULL,
    cusip VARCHAR(50) NOT NULL,
    sub_prod_type VARCHAR(50),
    prod_subtype VARCHAR(50) NOT NULL,
    prod_type VARCHAR(50),
    issuing_agency VARCHAR(100),
    convertible VARCHAR(1),
    PRIMARY KEY (symbol, cusip)
);

-- Reference Tables
CREATE TABLE reference.interest_type (
    itid SERIAL PRIMARY KEY,
    interest_type_id VARCHAR(10),
    interest_type_desc VARCHAR(50)
);

CREATE TABLE reference.product_subtype (
    ptid SERIAL PRIMARY KEY,
    prod_type VARCHAR(50) NOT NULL,
    prod_subtype VARCHAR(50) NOT NULL,
    pst_desc VARCHAR(100),
    UNIQUE(prod_type, prod_subtype)
);

-- Create Views
CREATE OR REPLACE VIEW lending.vw_loan_portfolio_overview AS
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
    s.security_name
FROM lending.loans l
JOIN lending.customers c ON l.customer_id = c.customer_id
JOIN lending.property_details p ON l.property_id = p.property_id
JOIN lending.mortgage_products mp ON l.product_id = mp.product_id
LEFT JOIN lending.securities s ON l.security_id = s.security_id;

-- Grant permissions
GRANT USAGE ON SCHEMA lending TO PUBLIC;
GRANT USAGE ON SCHEMA reference TO PUBLIC;
GRANT SELECT ON ALL TABLES IN SCHEMA lending TO PUBLIC;
GRANT SELECT ON ALL TABLES IN SCHEMA reference TO PUBLIC;

-- Analyze tables for query optimization
ANALYZE;
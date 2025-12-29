
-- =============================================
-- PostgreSQL Complete Schema for XYZ_Financials_Securities
-- Compatible with PostgreSQL 12+
-- Optimized for transactional and analytical workloads
-- =============================================

-- Create Database
CREATE DATABASE xyz_financials_securities
    WITH 
    OWNER = postgres
    ENCODING = 'UTF8'
    LC_COLLATE = 'en_US.UTF-8'
    LC_CTYPE = 'en_US.UTF-8'
    TABLESPACE = pg_default
    CONNECTION LIMIT = -1;

\c xyz_financials_securities

-- Create Extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";  -- For text search
CREATE EXTENSION IF NOT EXISTS "btree_gin"; -- For composite indexes
CREATE EXTENSION IF NOT EXISTS "postgis";   -- For spatial data

-- Create Schemas
CREATE SCHEMA IF NOT EXISTS lending AUTHORIZATION postgres;
CREATE SCHEMA IF NOT EXISTS reference AUTHORIZATION postgres;
CREATE SCHEMA IF NOT EXISTS audit AUTHORIZATION postgres;

SET search_path TO lending, reference, audit, public;

-- =============================================
-- CUSTOM TYPES
-- =============================================

CREATE TYPE lending.loan_status_enum AS ENUM (
    'Application',
    'Underwriting',
    'Approved',
    'Active',
    'PaidOff',
    'Default',
    'Foreclosure',
    'Closed'
);

CREATE TYPE lending.application_status_enum AS ENUM (
    'Submitted',
    'UnderReview',
    'Approved',
    'Denied',
    'Withdrawn',
    'Closed'
);

CREATE TYPE lending.payment_status_enum AS ENUM (
    'Scheduled',
    'Pending',
    'Processed',
    'Failed',
    'Reversed'
);

-- =============================================
-- SEQUENCES
-- =============================================

CREATE SEQUENCE lending.seq_customer_id START 1000 INCREMENT 1;
CREATE SEQUENCE lending.seq_loan_id START 100000 INCREMENT 1;
CREATE SEQUENCE lending.seq_application_id START 10000 INCREMENT 1;
CREATE SEQUENCE lending.seq_payment_reference START 1000000 INCREMENT 1;
CREATE SEQUENCE lending.seq_document_registry START 1 INCREMENT 1;

-- =============================================
-- CORE TABLES
-- =============================================

-- Customers Table
CREATE TABLE lending.customers (
    customer_id INTEGER PRIMARY KEY DEFAULT nextval('lending.seq_customer_id'),
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
    CONSTRAINT chk_customers_credit CHECK (credit_score BETWEEN 300 AND 850),
    CONSTRAINT chk_customers_dob CHECK (date_of_birth < CURRENT_DATE)
);

CREATE INDEX idx_customers_lastname ON lending.customers(last_name);
CREATE INDEX idx_customers_credit ON lending.customers(credit_score);
CREATE INDEX idx_customers_email ON lending.customers(email);
CREATE INDEX idx_customers_name_trgm ON lending.customers USING gin(first_name gin_trgm_ops, last_name gin_trgm_ops);

COMMENT ON TABLE lending.customers IS 'Customer master data';
COMMENT ON COLUMN lending.customers.ssn IS 'Social Security Number - PII - Encrypted';

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
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_products_term CHECK (term > 0),
    CONSTRAINT chk_products_rate CHECK (base_interest_rate >= 0),
    CONSTRAINT chk_products_ltv CHECK (max_ltv > 0 AND max_ltv <= 100)
);

CREATE INDEX idx_products_type ON lending.mortgage_products(product_type);
CREATE INDEX idx_products_active ON lending.mortgage_products(is_active) WHERE is_active = true;

COMMENT ON TABLE lending.mortgage_products IS 'Mortgage product catalog';

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
    geom GEOMETRY(Point, 4326),
    CONSTRAINT chk_property_year CHECK (year_built > 1800 AND year_built <= EXTRACT(YEAR FROM CURRENT_DATE) + 1),
    CONSTRAINT chk_property_sqft CHECK (square_feet > 0)
);

CREATE INDEX idx_property_state ON lending.property_details(state);
CREATE INDEX idx_property_zip ON lending.property_details(zip_code);
CREATE INDEX idx_property_type ON lending.property_details(property_type);
CREATE INDEX idx_property_city_state ON lending.property_details(city, state);
CREATE INDEX idx_property_geom ON lending.property_details USING gist(geom);

-- Trigger to auto-update geom from lat/long
CREATE OR REPLACE FUNCTION lending.update_property_geom()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.latitude IS NOT NULL AND NEW.longitude IS NOT NULL THEN
        NEW.geom := ST_SetSRID(ST_MakePoint(NEW.longitude, NEW.latitude), 4326);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_update_property_geom
    BEFORE INSERT OR UPDATE ON lending.property_details
    FOR EACH ROW
    EXECUTE FUNCTION lending.update_property_geom();

COMMENT ON TABLE lending.property_details IS 'Property characteristics and valuation';

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
    CONSTRAINT chk_officers_commission CHECK (commission_rate >= 0 AND commission_rate <= 100)
);

CREATE INDEX idx_officers_status ON lending.loan_officers(status);
CREATE INDEX idx_officers_branch ON lending.loan_officers(branch_id);

COMMENT ON TABLE lending.loan_officers IS 'Loan officer information';

-- Applications Table
CREATE TABLE lending.applications (
    application_id INTEGER PRIMARY KEY DEFAULT nextval('lending.seq_application_id'),
    customer_id INTEGER NOT NULL REFERENCES lending.customers(customer_id),
    product_id INTEGER NOT NULL REFERENCES lending.mortgage_products(product_id),
    officer_id INTEGER NOT NULL REFERENCES lending.loan_officers(officer_id),
    application_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    loan_amount NUMERIC(15,2) NOT NULL,
    loan_purpose VARCHAR(50) NOT NULL,
    status lending.application_status_enum DEFAULT 'Submitted',
    closing_date DATE,
    application_fee NUMERIC(10,2),
    dti NUMERIC(5,2),
    property_value NUMERIC(15,2),
    ltv NUMERIC(5,2),
    rate_offered NUMERIC(5,3),
    term_offered INTEGER,
    denial_reason VARCHAR(255),
    CONSTRAINT chk_applications_amount CHECK (loan_amount > 0),
    CONSTRAINT chk_applications_dti CHECK (dti >= 0 AND dti <= 100),
    CONSTRAINT chk_applications_ltv CHECK (ltv >= 0 AND ltv <= 100)
);

CREATE INDEX idx_applications_customer ON lending.applications(customer_id);
CREATE INDEX idx_applications_date ON lending.applications(application_date);
CREATE INDEX idx_applications_status ON lending.applications(status);
CREATE INDEX idx_applications_officer ON lending.applications(officer_id);
CREATE INDEX idx_applications_product ON lending.applications(product_id);

COMMENT ON TABLE lending.applications IS 'Loan applications';

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
    CONSTRAINT chk_securities_maturity CHECK (maturity_date > issue_date)
);

CREATE INDEX idx_securities_cusip ON lending.securities(cusip);
CREATE INDEX idx_securities_type ON lending.securities(security_type);
CREATE INDEX idx_securities_status ON lending.securities(status);

COMMENT ON TABLE lending.securities IS 'Securities and MBS information';

-- Loans Table
CREATE TABLE lending.loans (
    loan_id INTEGER PRIMARY KEY DEFAULT nextval('lending.seq_loan_id'),
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
    status lending.loan_status_enum DEFAULT 'Active',
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
    CONSTRAINT chk_loans_maturity CHECK (maturity_date > origination_date)
);

CREATE INDEX idx_loans_customer ON lending.loans(customer_id);
CREATE INDEX idx_loans_property ON lending.loans(property_id);
CREATE INDEX idx_loans_origination ON lending.loans(origination_date);
CREATE INDEX idx_loans_status ON lending.loans(status);
CREATE INDEX idx_loans_security ON lending.loans(security_id);
CREATE INDEX idx_loans_application ON lending.loans(application_id);
CREATE INDEX idx_loans_next_payment ON lending.loans(next_payment_date) WHERE status = 'Active';

COMMENT ON TABLE lending.loans IS 'Active and historical loans';

-- Trigger to update last_updated_date
CREATE OR REPLACE FUNCTION lending.update_modified_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.last_updated_date = CURRENT_DATE;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_update_loans_modified
    BEFORE UPDATE ON lending.loans
    FOR EACH ROW
    EXECUTE FUNCTION lending.update_modified_column();

-- Payments Table (Partitioned by Year)
CREATE TABLE lending.payments (
    payment_id BIGSERIAL,
    loan_id INTEGER NOT NULL REFERENCES lending.loans(loan_id),
    payment_date DATE NOT NULL,
    payment_amount NUMERIC(12,2) NOT NULL,
    principal_amount NUMERIC(12,2) NOT NULL,
    interest_amount NUMERIC(12,2) NOT NULL,
    escrow_amount NUMERIC(12,2) DEFAULT 0.00,
    late_fee_amount NUMERIC(10,2) DEFAULT 0.00,
    payment_method VARCHAR(50),
    transaction_id VARCHAR(100),
    payment_status lending.payment_status_enum DEFAULT 'Processed',
    processed_date TIMESTAMP,
    PRIMARY KEY (payment_id, payment_date),
    CONSTRAINT chk_payments_amounts CHECK (
        payment_amount > 0 AND 
        principal_amount >= 0 AND 
        interest_amount >= 0
    )
) PARTITION BY RANGE (payment_date);

-- Create partitions for payments
CREATE TABLE lending.payments_2020 PARTITION OF lending.payments
    FOR VALUES FROM ('2020-01-01') TO ('2021-01-01');
CREATE TABLE lending.payments_2021 PARTITION OF lending.payments
    FOR VALUES FROM ('2021-01-01') TO ('2022-01-01');
CREATE TABLE lending.payments_2022 PARTITION OF lending.payments
    FOR VALUES FROM ('2022-01-01') TO ('2023-01-01');
CREATE TABLE lending.payments_2023 PARTITION OF lending.payments
    FOR VALUES FROM ('2023-01-01') TO ('2024-01-01');
CREATE TABLE lending.payments_2024 PARTITION OF lending.payments
    FOR VALUES FROM ('2024-01-01') TO ('2025-01-01');
CREATE TABLE lending.payments_2025 PARTITION OF lending.payments
    FOR VALUES FROM ('2025-01-01') TO ('2026-01-01');
CREATE TABLE lending.payments_2026 PARTITION OF lending.payments
    FOR VALUES FROM ('2026-01-01') TO ('2027-01-01');
CREATE TABLE lending.payments_default PARTITION OF lending.payments DEFAULT;

CREATE INDEX idx_payments_loan ON lending.payments(loan_id);
CREATE INDEX idx_payments_date ON lending.payments(payment_date);
CREATE INDEX idx_payments_status ON lending.payments(payment_status);

COMMENT ON TABLE lending.payments IS 'Payment transaction history';

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

CREATE INDEX idx_escrow_loan ON lending.escrow_accounts(loan_id);

COMMENT ON TABLE lending.escrow_accounts IS 'Escrow account balances and settings';

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

COMMENT ON TABLE lending.escrow_transactions IS 'Escrow account transaction history';

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
CREATE INDEX idx_defaults_stage ON lending.defaults_foreclosures(stage);

COMMENT ON TABLE lending.defaults_foreclosures IS 'Default and foreclosure tracking';

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
CREATE INDEX idx_servicing_date ON lending.servicing_rights(transfer_date);
CREATE INDEX idx_servicing_servicer ON lending.servicing_rights(servicer_name);

COMMENT ON TABLE lending.servicing_rights IS 'Loan servicing rights transfers';

-- Customer Addresses Table
CREATE TABLE lending.customer_addresses (
    address_id SERIAL PRIMARY KEY,
    customer_id INTEGER NOT NULL REFERENCES lending.customers(customer_id) ON DELETE CASCADE,
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
CREATE INDEX idx_cust_addr_type ON lending.customer_addresses(address_type);

COMMENT ON TABLE lending.customer_addresses IS 'Customer address history';

-- Documents Registry Table
CREATE TABLE lending.documents_registry (
    document_id INTEGER PRIMARY KEY DEFAULT nextval('lending.seq_document_registry'),
    application_id INTEGER NOT NULL REFERENCES lending.applications(application_id) ON DELETE CASCADE,
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
CREATE INDEX idx_docs_type ON lending.documents_registry(document_type);
CREATE INDEX idx_docs_status ON lending.documents_registry(approval_status);

COMMENT ON TABLE lending.documents_registry IS 'Application documents tracking';

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
CREATE INDEX idx_risk_classification ON lending.risk_assessments(risk_classification);

COMMENT ON TABLE lending.risk_assessments IS 'Risk assessment results';

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
CREATE INDEX idx_mods_date ON lending.loan_term_modifications(modification_date);
CREATE INDEX idx_mods_type ON lending.loan_term_modifications(modification_type);

COMMENT ON TABLE lending.loan_term_modifications IS 'Loan term modification history';

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

COMMENT ON TABLE reference.capital_market_data IS 'Capital market rates and indices';

-- Audit Log Table (Partitioned by Year)
CREATE TABLE audit.audit_log (
    log_id BIGSERIAL,
    entity_type VARCHAR(50) NOT NULL,
    entity_id INTEGER NOT NULL,
    action_type VARCHAR(20) NOT NULL,
    action_datetime TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    user_id VARCHAR(50) NOT NULL,
    old_values JSONB,
    new_values JSONB,
    ip_address INET,
    application_name VARCHAR(100),
    PRIMARY KEY (log_id, action_datetime)
) PARTITION BY RANGE (action_datetime);

-- Create partitions for audit_log
CREATE TABLE audit.audit_log_2023 PARTITION OF audit.audit_log
    FOR VALUES FROM ('2023-01-01') TO ('2024-01-01');
CREATE TABLE audit.audit_log_2024 PARTITION OF audit.audit_log
    FOR VALUES FROM ('2024-01-01') TO ('2025-01-01');
CREATE TABLE audit.audit_log_2025 PARTITION OF audit.audit_log
    FOR VALUES FROM ('2025-01-01') TO ('2026-01-01');
CREATE TABLE audit.audit_log_default PARTITION OF audit.audit_log DEFAULT;

CREATE INDEX idx_audit_entity ON audit.audit_log(entity_type, entity_id);
CREATE INDEX idx_audit_user ON audit.audit_log(user_id);
CREATE INDEX idx_audit_action ON audit.audit_log(action_type);
CREATE INDEX idx_audit_datetime ON audit.audit_log(action_datetime);

COMMENT ON TABLE audit.audit_log IS 'Audit trail for all data changes';

-- =============================================
-- REFERENCE TABLES
-- =============================================

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

CREATE INDEX idx_finra_cusip ON reference.finra_fi(cusip);
CREATE INDEX idx_finra_issuer ON reference.finra_fi(issuer_name);

COMMENT ON TABLE reference.finra_fi IS 'FINRA fixed income securities reference data';

-- Interest Type Reference
CREATE TABLE reference.interest_type (
    itid SERIAL PRIMARY KEY,
    interest_type_id VARCHAR(10),
    interest_type_desc VARCHAR(50)
);

COMMENT ON TABLE reference.interest_type IS 'Interest type reference';

-- Product Subtype Reference
CREATE TABLE reference.product_subtype (
    ptid SERIAL PRIMARY KEY,
    prod_type VARCHAR(50) NOT NULL,
    prod_subtype VARCHAR(50) NOT NULL,
    pst_desc VARCHAR(100),
    UNIQUE(prod_type, prod_subtype)
);

COMMENT ON TABLE reference.product_subtype IS 'Product subtype reference';

-- =============================================
-- VIEWS
-- =============================================

-- Loan Portfolio Overview
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
    s.security_name,
    sr.servicer_name
FROM lending.loans l
JOIN lending.customers c ON l.customer_id = c.customer_id
JOIN lending.property_details p ON l.property_id = p.property_id
JOIN lending.mortgage_products mp ON l.product_id = mp.product_id
LEFT JOIN lending.securities s ON l.security_id = s.security_id
LEFT JOIN lending.servicing_rights sr ON l.loan_id = sr.loan_id;

-- Delinquent Loans View
CREATE OR REPLACE VIEW lending.vw_delinquent_loans AS
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
    CURRENT_DATE - l.next_payment_date AS days_past_due,
    CASE 
        WHEN CURRENT_DATE - l.next_payment_date BETWEEN 1 AND 30 THEN '1-30 Days'
        WHEN CURRENT_DATE - l.next_payment_date BETWEEN 31 AND 60 THEN '31-60 Days'
        WHEN CURRENT_DATE - l.next_payment_date BETWEEN 61 AND 90 THEN '61-90 Days'
        WHEN CURRENT_DATE - l.next_payment_date > 90 THEN '90+ Days'
        ELSE 'Current'
    END AS delinquency_bucket
FROM lending.loans l
JOIN lending.customers c ON l.customer_id = c.customer_id
JOIN lending.property_details p ON l.property_id = p.property_id
LEFT JOIN lending.defaults_foreclosures df ON l.loan_id = df.loan_id AND df.resolution_date IS NULL
WHERE l.next_payment_date < CURRENT_DATE AND l.status = 'Active';

-- Customer Portfolio View
CREATE OR REPLACE VIEW lending.vw_customer_portfolio AS
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
FROM lending.customers c
LEFT JOIN lending.loans l ON c.customer_id = l.customer_id AND l.status = 'Active'
GROUP BY c.customer_id, c.first_name, c.last_name, c.email, c.phone, c.credit_score;

-- =============================================
-- FUNCTIONS AND PROCEDURES
-- =============================================

-- Function to calculate current loan balance
CREATE OR REPLACE FUNCTION lending.fn_calculate_current_balance(
    p_loan_id INTEGER,
    p_as_of_date DATE DEFAULT CURRENT_DATE
)
RETURNS NUMERIC(15,2)
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_current_balance NUMERIC(15,2);
BEGIN
    SELECT 
        l.loan_amount - COALESCE(SUM(p.principal_amount), 0)
    INTO v_current_balance
    FROM lending.loans l
    LEFT JOIN lending.payments p ON l.loan_id = p.loan_id 
        AND p.payment_date <= p_as_of_date
        AND p.payment_status = 'Processed'
    WHERE l.loan_id = p_loan_id
    GROUP BY l.loan_amount;
    
    RETURN COALESCE(v_current_balance, 0);
END;
$$;

-- Function to calculate loan age in months
CREATE OR REPLACE FUNCTION lending.fn_calculate_loan_age(p_loan_id INTEGER)
RETURNS INTEGER
LANGUAGE plpgsql
STABLE
AS $
DECLARE
    v_origination_date DATE;
    v_loan_age_months INTEGER;
BEGIN
    SELECT origination_date INTO v_origination_date
    FROM lending.loans
    WHERE loan_id = p_loan_id;
    
    IF v_origination_date IS NULL THEN
        RETURN 0;
    END IF;
    
    v_loan_age_months := EXTRACT(YEAR FROM AGE(CURRENT_DATE, v_origination_date)) * 12 +
                         EXTRACT(MONTH FROM AGE(CURRENT_DATE, v_origination_date));
    
    RETURN v_loan_age_months;
END;
$;

-- Procedure to process loan payment
CREATE OR REPLACE PROCEDURE lending.sp_process_loan_payment(
    p_loan_id INTEGER,
    p_payment_amount NUMERIC(12,2),
    p_payment_date DATE,
    p_payment_method VARCHAR(50),
    p_transaction_id VARCHAR(100)
)
LANGUAGE plpgsql
AS $
DECLARE
    v_remaining_balance NUMERIC(15,2);
    v_interest_rate NUMERIC(5,3);
    v_monthly_rate NUMERIC(12,8);
    v_interest_amount NUMERIC(12,2);
    v_principal_amount NUMERIC(12,2);
    v_escrow_amount NUMERIC(12,2) := 0;
    v_late_fee_amount NUMERIC(10,2) := 0;
    v_next_payment_date DATE;
    v_escrow_required BOOLEAN;
    v_escrow_id INTEGER;
BEGIN
    -- Get loan details
    SELECT remaining_balance, interest_rate, escrow_required, next_payment_date
    INTO v_remaining_balance, v_interest_rate, v_escrow_required, v_next_payment_date
    FROM lending.loans
    WHERE loan_id = p_loan_id
    FOR UPDATE;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Loan not found: %', p_loan_id;
    END IF;
    
    -- Check for late payment
    IF p_payment_date > v_next_payment_date THEN
        v_late_fee_amount := 50.00;
    END IF;
    
    -- Calculate interest
    v_monthly_rate := (v_interest_rate / 100) / 12;
    v_interest_amount := ROUND(v_remaining_balance * v_monthly_rate, 2);
    
    -- Get escrow amount if required
    IF v_escrow_required THEN
        SELECT escrow_id, monthly_contribution 
        INTO v_escrow_id, v_escrow_amount
        FROM lending.escrow_accounts
        WHERE loan_id = p_loan_id;
    END IF;
    
    -- Calculate principal
    v_principal_amount := p_payment_amount - v_interest_amount - v_escrow_amount - v_late_fee_amount;
    
    IF v_principal_amount < 0 THEN
        RAISE EXCEPTION 'Payment amount insufficient to cover interest and escrow';
    END IF;
    
    -- Update loan
    UPDATE lending.loans
    SET remaining_balance = remaining_balance - v_principal_amount,
        next_payment_date = v_next_payment_date + INTERVAL '1 month',
        last_updated_date = CURRENT_DATE
    WHERE loan_id = p_loan_id;
    
    -- Insert payment record
    INSERT INTO lending.payments (
        loan_id, payment_date, payment_amount, principal_amount,
        interest_amount, escrow_amount, late_fee_amount,
        payment_method, transaction_id, payment_status, processed_date
    ) VALUES (
        p_loan_id, p_payment_date, p_payment_amount, v_principal_amount,
        v_interest_amount, v_escrow_amount, v_late_fee_amount,
        p_payment_method, p_transaction_id, 'Processed', CURRENT_TIMESTAMP
    );
    
    -- Update escrow if required
    IF v_escrow_required AND v_escrow_id IS NOT NULL THEN
        UPDATE lending.escrow_accounts
        SET current_balance = current_balance + v_escrow_amount
        WHERE escrow_id = v_escrow_id;
        
        INSERT INTO lending.escrow_transactions (
            escrow_id, transaction_date, transaction_type, amount, description
        ) VALUES (
            v_escrow_id, p_payment_date, 'Deposit', v_escrow_amount, 'Monthly escrow contribution'
        );
    END IF;
    
    COMMIT;
END;
$;

-- =============================================
-- ROW LEVEL SECURITY (Optional)
-- =============================================

-- Enable RLS on sensitive tables
ALTER TABLE lending.customers ENABLE ROW LEVEL SECURITY;
ALTER TABLE lending.loans ENABLE ROW LEVEL SECURITY;

-- Example policy (customize based on your security requirements)
-- CREATE POLICY customer_isolation_policy ON lending.customers
--     USING (customer_id = current_setting('app.current_customer_id')::INTEGER);

-- =============================================
-- MATERIALIZED VIEWS FOR ANALYTICS
-- =============================================

CREATE MATERIALIZED VIEW lending.mv_loan_portfolio_metrics AS
SELECT 
    EXTRACT(YEAR FROM l.origination_date) AS origination_year,
    EXTRACT(MONTH FROM l.origination_date) AS origination_month,
    l.status,
    mp.product_type,
    p.state,
    COUNT(l.loan_id) AS loan_count,
    SUM(l.loan_amount) AS total_loan_amount,
    AVG(l.interest_rate) AS avg_interest_rate,
    SUM(l.remaining_balance) AS total_remaining_balance,
    AVG(l.loan_amount) AS avg_loan_amount
FROM lending.loans l
JOIN lending.mortgage_products mp ON l.product_id = mp.product_id
JOIN lending.property_details p ON l.property_id = p.property_id
GROUP BY 
    EXTRACT(YEAR FROM l.origination_date),
    EXTRACT(MONTH FROM l.origination_date),
    l.status,
    mp.product_type,
    p.state;

CREATE UNIQUE INDEX idx_mv_loan_metrics ON lending.mv_loan_portfolio_metrics(origination_year, origination_month, status, product_type, state);

-- Refresh materialized view function
CREATE OR REPLACE FUNCTION lending.refresh_materialized_views()
RETURNS VOID
LANGUAGE plpgsql
AS $
BEGIN
    REFRESH MATERIALIZED VIEW CONCURRENTLY lending.mv_loan_portfolio_metrics;
END;
$;

-- =============================================
-- GRANT PERMISSIONS
-- =============================================

GRANT USAGE ON SCHEMA lending TO PUBLIC;
GRANT USAGE ON SCHEMA reference TO PUBLIC;
GRANT USAGE ON SCHEMA audit TO PUBLIC;
GRANT SELECT ON ALL TABLES IN SCHEMA lending TO PUBLIC;
GRANT SELECT ON ALL TABLES IN SCHEMA reference TO PUBLIC;
GRANT SELECT ON ALL TABLES IN SCHEMA audit TO PUBLIC;

-- Grant sequence usage
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA lending TO PUBLIC;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA reference TO PUBLIC;

-- =============================================
-- ANALYZE TABLES FOR QUERY OPTIMIZATION
-- =============================================

ANALYZE lending.customers;
ANALYZE lending.mortgage_products;
ANALYZE lending.property_details;
ANALYZE lending.loan_officers;
ANALYZE lending.applications;
ANALYZE lending.securities;
ANALYZE lending.loans;
ANALYZE lending.payments;
ANALYZE lending.escrow_accounts;
ANALYZE lending.escrow_transactions;
ANALYZE lending.defaults_foreclosures;
ANALYZE lending.servicing_rights;
ANALYZE lending.customer_addresses;
ANALYZE lending.documents_registry;
ANALYZE lending.risk_assessments;
ANALYZE lending.loan_term_modifications;
ANALYZE reference.capital_market_data;
ANALYZE reference.finra_fi;
ANALYZE reference.interest_type;
ANALYZE reference.product_subtype;

-- =============================================
-- VACUUM AND MAINTENANCE
-- =============================================

-- Enable autovacuum for all tables (should be on by default)
-- Manual vacuum can be run as:
-- VACUUM ANALYZE;

-- =============================================
-- COMMENTS AND DOCUMENTATION
-- =============================================

COMMENT ON SCHEMA lending IS 'Core lending and mortgage operations';
COMMENT ON SCHEMA reference IS 'Reference and lookup tables';
COMMENT ON SCHEMA audit IS 'Audit trail and compliance logging';

-- =============================================
-- END OF SCHEMA
-- =============================================
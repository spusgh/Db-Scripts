-- =============================================
-- Oracle Database Complete Schema for XYZ_Financials_Securities
-- Compatible with Oracle 12c+
-- Optimized for enterprise transactional and analytical workloads
-- =============================================

-- Create Tablespaces
CREATE TABLESPACE xyz_financials_data
    DATAFILE '/u01/app/oracle/oradata/orcl/xyz_financials_data01.dbf'
    SIZE 2G
    AUTOEXTEND ON NEXT 256M
    MAXSIZE UNLIMITED
    EXTENT MANAGEMENT LOCAL
    SEGMENT SPACE MANAGEMENT AUTO;

CREATE TABLESPACE xyz_financials_index
    DATAFILE '/u01/app/oracle/oradata/orcl/xyz_financials_index01.dbf'
    SIZE 1G
    AUTOEXTEND ON NEXT 128M
    MAXSIZE UNLIMITED
    EXTENT MANAGEMENT LOCAL
    SEGMENT SPACE MANAGEMENT AUTO;

CREATE TABLESPACE xyz_financials_lob
    DATAFILE '/u01/app/oracle/oradata/orcl/xyz_financials_lob01.dbf'
    SIZE 512M
    AUTOEXTEND ON NEXT 128M
    MAXSIZE UNLIMITED
    EXTENT MANAGEMENT LOCAL
    SEGMENT SPACE MANAGEMENT AUTO;

-- Create Sequences
CREATE SEQUENCE seq_customer_id 
    START WITH 1000 
    INCREMENT BY 1 
    NOCACHE 
    NOCYCLE;

CREATE SEQUENCE seq_loan_id 
    START WITH 100000 
    INCREMENT BY 1 
    CACHE 50 
    NOCYCLE;

CREATE SEQUENCE seq_application_id 
    START WITH 10000 
    INCREMENT BY 1 
    CACHE 50 
    NOCYCLE;

CREATE SEQUENCE seq_payment_id 
    START WITH 1 
    INCREMENT BY 1 
    CACHE 100 
    NOCYCLE;

CREATE SEQUENCE seq_document_id 
    START WITH 1 
    INCREMENT BY 1 
    CACHE 25 
    NOCYCLE;

-- =============================================
-- CORE TABLES
-- =============================================

-- Customers Table
CREATE TABLE customers (
    customer_id NUMBER(10) DEFAULT seq_customer_id.NEXTVAL NOT NULL,
    first_name VARCHAR2(50) NOT NULL,
    last_name VARCHAR2(50) NOT NULL,
    ssn CHAR(11) NOT NULL,
    date_of_birth DATE NOT NULL,
    email VARCHAR2(100),
    phone VARCHAR2(20),
    annual_income NUMBER(15,2),
    employment_status VARCHAR2(50),
    employer VARCHAR2(100),
    years_employed NUMBER(3),
    credit_score NUMBER(3),
    created_date TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,
    last_updated_date TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,
    CONSTRAINT pk_customers PRIMARY KEY (customer_id) 
        USING INDEX TABLESPACE xyz_financials_index,
    CONSTRAINT uk_customers_ssn UNIQUE (ssn) 
        USING INDEX TABLESPACE xyz_financials_index,
    CONSTRAINT chk_customers_credit CHECK (credit_score BETWEEN 300 AND 850)
) TABLESPACE xyz_financials_data;

CREATE INDEX idx_customers_lastname ON customers(last_name) 
    TABLESPACE xyz_financials_index;
CREATE INDEX idx_customers_credit ON customers(credit_score) 
    TABLESPACE xyz_financials_index;
CREATE INDEX idx_customers_email ON customers(email) 
    TABLESPACE xyz_financials_index;

COMMENT ON TABLE customers IS 'Customer master data';
COMMENT ON COLUMN customers.ssn IS 'Social Security Number - PII';

-- Mortgage Products Table
CREATE TABLE mortgage_products (
    product_id NUMBER(10) GENERATED ALWAYS AS IDENTITY,
    product_name VARCHAR2(100) NOT NULL,
    product_type VARCHAR2(50) NOT NULL,
    term NUMBER(3) NOT NULL,
    base_interest_rate NUMBER(5,3) NOT NULL,
    min_credit_score NUMBER(3) NOT NULL,
    max_ltv NUMBER(5,2) NOT NULL,
    min_loan_amount NUMBER(15,2) NOT NULL,
    max_loan_amount NUMBER(15,2) NOT NULL,
    origination_fee NUMBER(5,2) DEFAULT 0,
    is_active NUMBER(1) DEFAULT 1,
    CONSTRAINT pk_mortgage_products PRIMARY KEY (product_id) 
        USING INDEX TABLESPACE xyz_financials_index,
    CONSTRAINT uk_mortgage_products_name UNIQUE (product_name) 
        USING INDEX TABLESPACE xyz_financials_index,
    CONSTRAINT chk_products_active CHECK (is_active IN (0,1)),
    CONSTRAINT chk_products_term CHECK (term > 0),
    CONSTRAINT chk_products_rate CHECK (base_interest_rate >= 0)
) TABLESPACE xyz_financials_data;

CREATE INDEX idx_products_type ON mortgage_products(product_type) 
    TABLESPACE xyz_financials_index;

COMMENT ON TABLE mortgage_products IS 'Mortgage product catalog';

-- Property Details Table
CREATE TABLE property_details (
    property_id NUMBER(10) GENERATED ALWAYS AS IDENTITY,
    address_line1 VARCHAR2(100) NOT NULL,
    address_line2 VARCHAR2(100),
    city VARCHAR2(50) NOT NULL,
    state CHAR(2) NOT NULL,
    zip_code VARCHAR2(10) NOT NULL,
    country VARCHAR2(50) DEFAULT 'USA',
    property_type VARCHAR2(50) NOT NULL,
    year_built NUMBER(4),
    square_feet NUMBER(6),
    bedrooms NUMBER(2),
    bathrooms NUMBER(3,1),
    purchase_price NUMBER(15,2),
    current_value NUMBER(15,2),
    last_appraisal_date DATE,
    last_appraisal_value NUMBER(15,2),
    tax_assessment_value NUMBER(15,2),
    annual_tax_amount NUMBER(10,2),
    hoa_fees NUMBER(10,2) DEFAULT 0,
    flood_zone VARCHAR2(10),
    property_tax_id VARCHAR2(50),
    latitude NUMBER(9,6),
    longitude NUMBER(9,6),
    CONSTRAINT pk_property_details PRIMARY KEY (property_id) 
        USING INDEX TABLESPACE xyz_financials_index,
    CONSTRAINT chk_property_year CHECK (year_built > 1800 AND year_built <= EXTRACT(YEAR FROM SYSDATE) + 1)
) TABLESPACE xyz_financials_data;

CREATE INDEX idx_property_state ON property_details(state) 
    TABLESPACE xyz_financials_index;
CREATE INDEX idx_property_zip ON property_details(zip_code) 
    TABLESPACE xyz_financials_index;
CREATE INDEX idx_property_type ON property_details(property_type) 
    TABLESPACE xyz_financials_index;

COMMENT ON TABLE property_details IS 'Property characteristics and valuation';

-- Loan Officers Table
CREATE TABLE loan_officers (
    officer_id NUMBER(10) GENERATED ALWAYS AS IDENTITY,
    first_name VARCHAR2(50) NOT NULL,
    last_name VARCHAR2(50) NOT NULL,
    email VARCHAR2(100) NOT NULL,
    phone VARCHAR2(20) NOT NULL,
    branch_id NUMBER(10),
    hire_date DATE NOT NULL,
    commission_rate NUMBER(5,2) DEFAULT 0,
    status VARCHAR2(20) DEFAULT 'Active',
    CONSTRAINT pk_loan_officers PRIMARY KEY (officer_id) 
        USING INDEX TABLESPACE xyz_financials_index,
    CONSTRAINT uk_loan_officers_email UNIQUE (email) 
        USING INDEX TABLESPACE xyz_financials_index,
    CONSTRAINT chk_officers_commission CHECK (commission_rate >= 0 AND commission_rate <= 100)
) TABLESPACE xyz_financials_data;

CREATE INDEX idx_officers_status ON loan_officers(status) 
    TABLESPACE xyz_financials_index;

COMMENT ON TABLE loan_officers IS 'Loan officer information';

-- Applications Table
CREATE TABLE applications (
    application_id NUMBER(10) DEFAULT seq_application_id.NEXTVAL NOT NULL,
    customer_id NUMBER(10) NOT NULL,
    product_id NUMBER(10) NOT NULL,
    officer_id NUMBER(10) NOT NULL,
    application_date TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,
    loan_amount NUMBER(15,2) NOT NULL,
    loan_purpose VARCHAR2(50) NOT NULL,
    status VARCHAR2(50) DEFAULT 'Submitted',
    closing_date DATE,
    application_fee NUMBER(10,2),
    dti NUMBER(5,2),
    property_value NUMBER(15,2),
    ltv NUMBER(5,2),
    rate_offered NUMBER(5,3),
    term_offered NUMBER(3),
    denial_reason VARCHAR2(255),
    CONSTRAINT pk_applications PRIMARY KEY (application_id) 
        USING INDEX TABLESPACE xyz_financials_index,
    CONSTRAINT fk_applications_customers FOREIGN KEY (customer_id) 
        REFERENCES customers(customer_id),
    CONSTRAINT fk_applications_products FOREIGN KEY (product_id) 
        REFERENCES mortgage_products(product_id),
    CONSTRAINT fk_applications_officers FOREIGN KEY (officer_id) 
        REFERENCES loan_officers(officer_id),
    CONSTRAINT chk_applications_amount CHECK (loan_amount > 0),
    CONSTRAINT chk_applications_dti CHECK (dti >= 0 AND dti <= 100),
    CONSTRAINT chk_applications_ltv CHECK (ltv >= 0 AND ltv <= 100)
) TABLESPACE xyz_financials_data;

CREATE INDEX idx_applications_customer ON applications(customer_id) 
    TABLESPACE xyz_financials_index;
CREATE INDEX idx_applications_date ON applications(application_date) 
    TABLESPACE xyz_financials_index;
CREATE INDEX idx_applications_status ON applications(status) 
    TABLESPACE xyz_financials_index;

COMMENT ON TABLE applications IS 'Loan applications';

-- Securities Table
CREATE TABLE securities (
    security_id NUMBER(10) GENERATED ALWAYS AS IDENTITY,
    security_name VARCHAR2(100) NOT NULL,
    security_type VARCHAR2(50) NOT NULL,
    cusip VARCHAR2(9),
    issue_date DATE NOT NULL,
    maturity_date DATE NOT NULL,
    coupon_rate NUMBER(5,3) NOT NULL,
    face_value NUMBER(15,2) NOT NULL,
    current_balance NUMBER(15,2) NOT NULL,
    issuer VARCHAR2(100) NOT NULL,
    rating VARCHAR2(10),
    status VARCHAR2(20) DEFAULT 'Active',
    last_trade_date DATE,
    last_trade_price NUMBER(10,3),
    CONSTRAINT pk_securities PRIMARY KEY (security_id) 
        USING INDEX TABLESPACE xyz_financials_index,
    CONSTRAINT chk_securities_maturity CHECK (maturity_date > issue_date)
) TABLESPACE xyz_financials_data;

CREATE INDEX idx_securities_cusip ON securities(cusip) 
    TABLESPACE xyz_financials_index;
CREATE INDEX idx_securities_type ON securities(security_type) 
    TABLESPACE xyz_financials_index;

COMMENT ON TABLE securities IS 'Securities and MBS information';

-- Loans Table
CREATE TABLE loans (
    loan_id NUMBER(10) DEFAULT seq_loan_id.NEXTVAL NOT NULL,
    application_id NUMBER(10) NOT NULL,
    customer_id NUMBER(10) NOT NULL,
    property_id NUMBER(10) NOT NULL,
    product_id NUMBER(10) NOT NULL,
    loan_amount NUMBER(15,2) NOT NULL,
    interest_rate NUMBER(5,3) NOT NULL,
    term NUMBER(3) NOT NULL,
    origination_date DATE NOT NULL,
    maturity_date DATE NOT NULL,
    monthly_payment NUMBER(12,2) NOT NULL,
    remaining_balance NUMBER(15,2) NOT NULL,
    status VARCHAR2(20) DEFAULT 'Active',
    escrow_required NUMBER(1) DEFAULT 1,
    pmi_required NUMBER(1) DEFAULT 0,
    pmi_amount NUMBER(10,2) DEFAULT 0,
    first_payment_date DATE NOT NULL,
    next_payment_date DATE,
    payment_frequency VARCHAR2(20) DEFAULT 'Monthly',
    security_id NUMBER(10),
    last_updated_date DATE,
    CONSTRAINT pk_loans PRIMARY KEY (loan_id) 
        USING INDEX TABLESPACE xyz_financials_index,
    CONSTRAINT fk_loans_applications FOREIGN KEY (application_id) 
        REFERENCES applications(application_id),
    CONSTRAINT fk_loans_customers FOREIGN KEY (customer_id) 
        REFERENCES customers(customer_id),
    CONSTRAINT fk_loans_properties FOREIGN KEY (property_id) 
        REFERENCES property_details(property_id),
    CONSTRAINT fk_loans_products FOREIGN KEY (product_id) 
        REFERENCES mortgage_products(product_id),
    CONSTRAINT fk_loans_securities FOREIGN KEY (security_id) 
        REFERENCES securities(security_id),
    CONSTRAINT chk_loans_amount CHECK (loan_amount > 0),
    CONSTRAINT chk_loans_rate CHECK (interest_rate >= 0 AND interest_rate <= 50),
    CONSTRAINT chk_loans_term CHECK (term > 0),
    CONSTRAINT chk_loans_escrow CHECK (escrow_required IN (0,1)),
    CONSTRAINT chk_loans_pmi CHECK (pmi_required IN (0,1)),
    CONSTRAINT chk_loans_maturity CHECK (maturity_date > origination_date)
) TABLESPACE xyz_financials_data;

CREATE INDEX idx_loans_customer ON loans(customer_id) 
    TABLESPACE xyz_financials_index;
CREATE INDEX idx_loans_property ON loans(property_id) 
    TABLESPACE xyz_financials_index;
CREATE INDEX idx_loans_origination ON loans(origination_date) 
    TABLESPACE xyz_financials_index;
CREATE INDEX idx_loans_status ON loans(status) 
    TABLESPACE xyz_financials_index;
CREATE INDEX idx_loans_security ON loans(security_id) 
    TABLESPACE xyz_financials_index;

COMMENT ON TABLE loans IS 'Active and historical loans';

-- Payments Table (Partitioned by Year)
CREATE TABLE payments (
    payment_id NUMBER(10) DEFAULT seq_payment_id.NEXTVAL NOT NULL,
    loan_id NUMBER(10) NOT NULL,
    payment_date DATE NOT NULL,
    payment_amount NUMBER(12,2) NOT NULL,
    principal_amount NUMBER(12,2) NOT NULL,
    interest_amount NUMBER(12,2) NOT NULL,
    escrow_amount NUMBER(12,2) DEFAULT 0,
    late_fee_amount NUMBER(10,2) DEFAULT 0,
    payment_method VARCHAR2(50),
    transaction_id VARCHAR2(100),
    payment_status VARCHAR2(20) DEFAULT 'Processed',
    processed_date TIMESTAMP,
    CONSTRAINT pk_payments PRIMARY KEY (payment_id, payment_date) 
        USING INDEX TABLESPACE xyz_financials_index,
    CONSTRAINT fk_payments_loans FOREIGN KEY (loan_id) 
        REFERENCES loans(loan_id),
    CONSTRAINT chk_payments_amounts CHECK (
        payment_amount > 0 AND 
        principal_amount >= 0 AND 
        interest_amount >= 0
    )
) TABLESPACE xyz_financials_data
PARTITION BY RANGE (payment_date) (
    PARTITION p2020 VALUES LESS THAN (TO_DATE('2021-01-01', 'YYYY-MM-DD')),
    PARTITION p2021 VALUES LESS THAN (TO_DATE('2022-01-01', 'YYYY-MM-DD')),
    PARTITION p2022 VALUES LESS THAN (TO_DATE('2023-01-01', 'YYYY-MM-DD')),
    PARTITION p2023 VALUES LESS THAN (TO_DATE('2024-01-01', 'YYYY-MM-DD')),
    PARTITION p2024 VALUES LESS THAN (TO_DATE('2025-01-01', 'YYYY-MM-DD')),
    PARTITION p2025 VALUES LESS THAN (TO_DATE('2026-01-01', 'YYYY-MM-DD')),
    PARTITION p_future VALUES LESS THAN (MAXVALUE)
);

CREATE INDEX idx_payments_loan ON payments(loan_id) 
    LOCAL TABLESPACE xyz_financials_index;
CREATE INDEX idx_payments_status ON payments(payment_status) 
    LOCAL TABLESPACE xyz_financials_index;

COMMENT ON TABLE payments IS 'Payment transaction history';

-- Escrow Accounts Table
CREATE TABLE escrow_accounts (
    escrow_id NUMBER(10) GENERATED ALWAYS AS IDENTITY,
    loan_id NUMBER(10) NOT NULL,
    current_balance NUMBER(12,2) DEFAULT 0,
    property_tax_amount NUMBER(12,2) DEFAULT 0,
    property_insurance_amount NUMBER(12,2) DEFAULT 0,
    pmi_amount NUMBER(12,2) DEFAULT 0,
    cushion_amount NUMBER(12,2) DEFAULT 0,
    last_analysis_date DATE,
    next_analysis_date DATE,
    monthly_contribution NUMBER(12,2) DEFAULT 0,
    shortage_amount NUMBER(12,2) DEFAULT 0,
    CONSTRAINT pk_escrow_accounts PRIMARY KEY (escrow_id) 
        USING INDEX TABLESPACE xyz_financials_index,
    CONSTRAINT uk_escrow_loan UNIQUE (loan_id) 
        USING INDEX TABLESPACE xyz_financials_index,
    CONSTRAINT fk_escrow_loans FOREIGN KEY (loan_id) 
        REFERENCES loans(loan_id)
) TABLESPACE xyz_financials_data;

COMMENT ON TABLE escrow_accounts IS 'Escrow account balances';

-- Escrow Transactions Table
CREATE TABLE escrow_transactions (
    transaction_id NUMBER(10) GENERATED ALWAYS AS IDENTITY,
    escrow_id NUMBER(10) NOT NULL,
    transaction_date DATE NOT NULL,
    transaction_type VARCHAR2(50) NOT NULL,
    amount NUMBER(12,2) NOT NULL,
    description VARCHAR2(255),
    reference VARCHAR2(100),
    CONSTRAINT pk_escrow_transactions PRIMARY KEY (transaction_id) 
        USING INDEX TABLESPACE xyz_financials_index,
    CONSTRAINT fk_escrow_trans_escrow FOREIGN KEY (escrow_id) 
        REFERENCES escrow_accounts(escrow_id)
) TABLESPACE xyz_financials_data;

CREATE INDEX idx_escrow_trans_escrow ON escrow_transactions(escrow_id) 
    TABLESPACE xyz_financials_index;
CREATE INDEX idx_escrow_trans_date ON escrow_transactions(transaction_date) 
    TABLESPACE xyz_financials_index;

-- Defaults and Foreclosures Table
CREATE TABLE defaults_foreclosures (
    default_id NUMBER(10) GENERATED ALWAYS AS IDENTITY,
    loan_id NUMBER(10) NOT NULL,
    default_date DATE NOT NULL,
    stage VARCHAR2(50) NOT NULL,
    reason_code VARCHAR2(50),
    resolution_type VARCHAR2(50),
    resolution_date DATE,
    loss_amount NUMBER(15,2),
    collection_agency VARCHAR2(100),
    legal_filing_date DATE,
    legal_case_number VARCHAR2(50),
    notes CLOB,
    CONSTRAINT pk_defaults_foreclosures PRIMARY KEY (default_id) 
        USING INDEX TABLESPACE xyz_financials_index,
    CONSTRAINT fk_defaults_loans FOREIGN KEY (loan_id) 
        REFERENCES loans(loan_id)
) TABLESPACE xyz_financials_data
LOB (notes) STORE AS SECUREFILE (TABLESPACE xyz_financials_lob);

CREATE INDEX idx_defaults_loan ON defaults_foreclosures(loan_id) 
    TABLESPACE xyz_financials_index;
CREATE INDEX idx_defaults_date ON defaults_foreclosures(default_date) 
    TABLESPACE xyz_financials_index;

-- Servicing Rights Table
CREATE TABLE servicing_rights (
    servicing_id NUMBER(10) GENERATED ALWAYS AS IDENTITY,
    loan_id NUMBER(10) NOT NULL,
    servicer_name VARCHAR2(100) NOT NULL,
    servicer_id NUMBER(10),
    transfer_date DATE NOT NULL,
    msr_value NUMBER(15,2),
    servicing_fee NUMBER(5,3),
    subservicer_name VARCHAR2(100),
    transfer_reason VARCHAR2(100),
    CONSTRAINT pk_servicing_rights PRIMARY KEY (servicing_id) 
        USING INDEX TABLESPACE xyz_financials_index,
    CONSTRAINT fk_servicing_loans FOREIGN KEY (loan_id) 
        REFERENCES loans(loan_id)
) TABLESPACE xyz_financials_data;

CREATE INDEX idx_servicing_loan ON servicing_rights(loan_id) 
    TABLESPACE xyz_financials_index;

-- Customer Addresses Table
CREATE TABLE customer_addresses (
    address_id NUMBER(10) GENERATED ALWAYS AS IDENTITY,
    customer_id NUMBER(10) NOT NULL,
    address_type VARCHAR2(20) NOT NULL,
    address_line1 VARCHAR2(100) NOT NULL,
    address_line2 VARCHAR2(100),
    city VARCHAR2(50) NOT NULL,
    state CHAR(2) NOT NULL,
    zip_code VARCHAR2(10) NOT NULL,
    country VARCHAR2(50) DEFAULT 'USA',
    start_date DATE,
    end_date DATE,
    CONSTRAINT pk_customer_addresses PRIMARY KEY (address_id) 
        USING INDEX TABLESPACE xyz_financials_index,
    CONSTRAINT fk_cust_addr_customers FOREIGN KEY (customer_id) 
        REFERENCES customers(customer_id) ON DELETE CASCADE
) TABLESPACE xyz_financials_data;

CREATE INDEX idx_cust_addr_customer ON customer_addresses(customer_id) 
    TABLESPACE xyz_financials_index;

-- Documents Registry Table
CREATE TABLE documents_registry (
    document_id NUMBER(10) DEFAULT seq_document_id.NEXTVAL NOT NULL,
    application_id NUMBER(10) NOT NULL,
    document_type VARCHAR2(100) NOT NULL,
    file_name VARCHAR2(255),
    file_location VARCHAR2(255),
    upload_date TIMESTAMP DEFAULT SYSTIMESTAMP,
    required_flag NUMBER(1) DEFAULT 1,
    received_flag NUMBER(1) DEFAULT 0,
    approval_status VARCHAR2(20) DEFAULT 'Pending',
    approval_date TIMESTAMP,
    approved_by VARCHAR2(100),
    notes CLOB,
    CONSTRAINT pk_documents_registry PRIMARY KEY (document_id) 
        USING INDEX TABLESPACE xyz_financials_index,
    CONSTRAINT fk_docs_applications FOREIGN KEY (application_id) 
        REFERENCES applications(application_id) ON DELETE CASCADE,
    CONSTRAINT chk_docs_required CHECK (required_flag IN (0,1)),
    CONSTRAINT chk_docs_received CHECK (received_flag IN (0,1))
) TABLESPACE xyz_financials_data
LOB (notes) STORE AS SECUREFILE (TABLESPACE xyz_financials_lob);

CREATE INDEX idx_docs_application ON documents_registry(application_id) 
    TABLESPACE xyz_financials_index;

-- Risk Assessments Table
CREATE TABLE risk_assessments (
    assessment_id NUMBER(10) GENERATED ALWAYS AS IDENTITY,
    customer_id NUMBER(10) NOT NULL,
    application_id NUMBER(10) NOT NULL,
    assessment_date TIMESTAMP DEFAULT SYSTIMESTAMP,
    credit_score NUMBER(3) NOT NULL,
    dti NUMBER(5,2) NOT NULL,
    ltv NUMBER(5,2) NOT NULL,
    fico_score_source VARCHAR2(50),
    risk_classification VARCHAR2(20),
    recommended_action VARCHAR2(50),
    notes CLOB,
    CONSTRAINT pk_risk_assessments PRIMARY KEY (assessment_id) 
        USING INDEX TABLESPACE xyz_financials_index,
    CONSTRAINT fk_risk_customers FOREIGN KEY (customer_id) 
        REFERENCES customers(customer_id),
    CONSTRAINT fk_risk_applications FOREIGN KEY (application_id) 
        REFERENCES applications(application_id)
) TABLESPACE xyz_financials_data
LOB (notes) STORE AS SECUREFILE (TABLESPACE xyz_financials_lob);

CREATE INDEX idx_risk_customer ON risk_assessments(customer_id) 
    TABLESPACE xyz_financials_index;
CREATE INDEX idx_risk_application ON risk_assessments(application_id) 
    TABLESPACE xyz_financials_index;

-- Loan Term Modifications Table
CREATE TABLE loan_term_modifications (
    modification_id NUMBER(10) GENERATED ALWAYS AS IDENTITY,
    loan_id NUMBER(10) NOT NULL,
    modification_date DATE NOT NULL,
    modification_type VARCHAR2(50) NOT NULL,
    previous_interest_rate NUMBER(5,3),
    new_interest_rate NUMBER(5,3),
    previous_term NUMBER(3),
    new_term NUMBER(3),
    previous_payment NUMBER(12,2),
    new_payment NUMBER(12,2),
    modification_fee NUMBER(10,2),
    required_documents CLOB,
    approval_status VARCHAR2(20) DEFAULT 'Pending',
    approved_by VARCHAR2(100),
    notes CLOB,
    CONSTRAINT pk_loan_term_modifications PRIMARY KEY (modification_id) 
        USING INDEX TABLESPACE xyz_financials_index,
    CONSTRAINT fk_mods_loans FOREIGN KEY (loan_id) 
        REFERENCES loans(loan_id)
) TABLESPACE xyz_financials_data
LOB (required_documents, notes) STORE AS SECUREFILE (TABLESPACE xyz_financials_lob);

CREATE INDEX idx_mods_loan ON loan_term_modifications(loan_id) 
    TABLESPACE xyz_financials_index;

-- Capital Market Data Table
CREATE TABLE capital_market_data (
    market_data_id NUMBER(10) GENERATED ALWAYS AS IDENTITY,
    data_date DATE NOT NULL,
    data_source VARCHAR2(100) NOT NULL,
    treasury_10y NUMBER(5,3),
    fed_funds_rate NUMBER(5,3),
    libor_3m NUMBER(5,3),
    sofr NUMBER(5,3),
    mbs_30y_rate NUMBER(5,3),
    fannie_30y_rate NUMBER(5,3),
    freddie_30y_rate NUMBER(5,3),
    effective_date_start DATE,
    effective_date_end DATE,
    CONSTRAINT pk_capital_market_data PRIMARY KEY (market_data_id) 
        USING INDEX TABLESPACE xyz_financials_index,
    CONSTRAINT uk_market_data UNIQUE (data_date, data_source) 
        USING INDEX TABLESPACE xyz_financials_index
) TABLESPACE xyz_financials_data;

CREATE INDEX idx_market_data_date ON capital_market_data(data_date) 
    TABLESPACE xyz_financials_index;

-- Audit Log Table (Partitioned by Year)
CREATE TABLE audit_log (
    log_id NUMBER(19) GENERATED ALWAYS AS IDENTITY,
    entity_type VARCHAR2(50) NOT NULL,
    entity_id NUMBER(10) NOT NULL,
    action_type VARCHAR2(20) NOT NULL,
    action_datetime TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,
    user_id VARCHAR2(50) NOT NULL,
    old_values CLOB,
    new_values CLOB,
    ip_address VARCHAR2(50),
    application_name VARCHAR2(100),
    CONSTRAINT pk_audit_log PRIMARY KEY (log_id, action_datetime) 
        USING INDEX LOCAL TABLESPACE xyz_financials_index
) TABLESPACE xyz_financials_data
LOB (old_values, new_values) STORE AS SECUREFILE (TABLESPACE xyz_financials_lob)
PARTITION BY RANGE (action_datetime) INTERVAL (NUMTOYMINTERVAL(1, 'YEAR')) (
    PARTITION p2023 VALUES LESS THAN (TO_TIMESTAMP('2024-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'))
);

CREATE INDEX idx_audit_entity ON audit_log(entity_type, entity_id) 
    LOCAL TABLESPACE xyz_financials_index;
CREATE INDEX idx_audit_user ON audit_log(user_id) 
    LOCAL TABLESPACE xyz_financials_index;

-- =============================================
-- REFERENCE TABLES
-- =============================================

-- FINRA Fixed Income Table
CREATE TABLE finra_fi (
    symbol VARCHAR2(50) NOT NULL,
    issuer_name VARCHAR2(150) NOT NULL,
    coupon_type VARCHAR2(50),
    coupon_rate BINARY_DOUBLE,
    maturity_date DATE NOT NULL,
    deal_id VARCHAR2(50),
    tranche_id VARCHAR2(50),
    issue_description VARCHAR2(250) NOT NULL,
    interest_type VARCHAR2(50),
    i44a NUMBER(1) NOT NULL,
    cusip VARCHAR2(50) NOT NULL,
    sub_prod_type VARCHAR2(50),
    prod_subtype VARCHAR2(50) NOT NULL,
    prod_type VARCHAR2(50),
    issuing_agency VARCHAR2(100),
    convertible VARCHAR2(1),
    CONSTRAINT pk_finra_fi PRIMARY KEY (symbol, cusip) 
        USING INDEX TABLESPACE xyz_financials_index,
    CONSTRAINT chk_finra_i44a CHECK (i44a IN (0,1))
) TABLESPACE xyz_financials_data;

CREATE INDEX idx_finra_cusip ON finra_fi(cusip) 
    TABLESPACE xyz_financials_index;

-- Interest Type Reference
CREATE TABLE interest_type (
    itid NUMBER(10) GENERATED ALWAYS AS IDENTITY,
    interest_type_id VARCHAR2(10),
    interest_type_desc VARCHAR2(50),
    CONSTRAINT pk_interest_type PRIMARY KEY (itid) 
        USING INDEX TABLESPACE xyz_financials_index
) TABLESPACE xyz_financials_data;

-- Product Subtype Reference
CREATE TABLE product_subtype (
    ptid NUMBER(10) GENERATED ALWAYS AS IDENTITY,
    prod_type VARCHAR2(50) NOT NULL,
    prod_subtype VARCHAR2(50) NOT NULL,
    pst_desc VARCHAR2(100),
    CONSTRAINT pk_product_subtype PRIMARY KEY (ptid) 
        USING INDEX TABLESPACE xyz_financials_index,
    CONSTRAINT uk_product_subtype UNIQUE (prod_type, prod_subtype) 
        USING INDEX TABLESPACE xyz_financials_index
) TABLESPACE xyz_financials_data;

-- =============================================
-- VIEWS
-- =============================================

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

-- =============================================
-- GATHER STATISTICS
-- =============================================

BEGIN
    DBMS_STATS.GATHER_SCHEMA_STATS(
        ownname => USER,
        estimate_percent => DBMS_STATS.AUTO_SAMPLE_SIZE,
        method_opt => 'FOR ALL COLUMNS SIZE AUTO',
        cascade => TRUE,
        degree => 4
    );
END;
/
-- =============================================
-- MySQL Complete Schema for XYZ_Financials_Securities
-- Compatible with MySQL 8.0+
-- Optimized for transactional and analytical workloads
-- =============================================

CREATE DATABASE IF NOT EXISTS xyz_financials_securities
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

USE xyz_financials_securities;

-- =============================================
-- CORE TABLES
-- =============================================

-- Customers Table
CREATE TABLE customers (
    customer_id INT AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    ssn CHAR(11) NOT NULL,
    date_of_birth DATE NOT NULL,
    email VARCHAR(100),
    phone VARCHAR(20),
    annual_income DECIMAL(15,2),
    employment_status VARCHAR(50),
    employer VARCHAR(100),
    years_employed INT,
    credit_score INT,
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_updated_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (customer_id),
    UNIQUE KEY uk_customers_ssn (ssn),
    INDEX idx_customers_lastname (last_name),
    INDEX idx_customers_creditscore (credit_score),
    INDEX idx_customers_email (email),
    CONSTRAINT chk_credit_score CHECK (credit_score BETWEEN 300 AND 850)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Customer master data table';

-- Mortgage Products Table
CREATE TABLE mortgage_products (
    product_id INT AUTO_INCREMENT,
    product_name VARCHAR(100) NOT NULL,
    product_type VARCHAR(50) NOT NULL,
    term INT NOT NULL,
    base_interest_rate DECIMAL(5,3) NOT NULL,
    min_credit_score INT NOT NULL,
    max_ltv DECIMAL(5,2) NOT NULL,
    min_loan_amount DECIMAL(15,2) NOT NULL,
    max_loan_amount DECIMAL(15,2) NOT NULL,
    origination_fee DECIMAL(5,2) DEFAULT 0.00,
    is_active BOOLEAN DEFAULT TRUE,
    PRIMARY KEY (product_id),
    UNIQUE KEY uk_mortgage_products_name (product_name),
    INDEX idx_products_type (product_type),
    INDEX idx_products_active (is_active),
    CONSTRAINT chk_product_term CHECK (term > 0),
    CONSTRAINT chk_product_rate CHECK (base_interest_rate >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Mortgage product catalog';

-- Property Details Table
CREATE TABLE property_details (
    property_id INT AUTO_INCREMENT,
    address_line1 VARCHAR(100) NOT NULL,
    address_line2 VARCHAR(100),
    city VARCHAR(50) NOT NULL,
    state CHAR(2) NOT NULL,
    zip_code VARCHAR(10) NOT NULL,
    country VARCHAR(50) DEFAULT 'USA',
    property_type VARCHAR(50) NOT NULL,
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
    hoa_fees DECIMAL(10,2) DEFAULT 0.00,
    flood_zone VARCHAR(10),
    property_tax_id VARCHAR(50),
    latitude DECIMAL(9,6),
    longitude DECIMAL(9,6),
    PRIMARY KEY (property_id),
    INDEX idx_property_state (state),
    INDEX idx_property_zipcode (zip_code),
    INDEX idx_property_type (property_type),
    INDEX idx_property_city_state (city, state),
    SPATIAL INDEX idx_property_location (POINT(latitude, longitude)),
    CONSTRAINT chk_year_built CHECK (year_built > 1800 AND year_built <= YEAR(CURDATE()) + 1)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Property details and characteristics';

-- Loan Officers Table
CREATE TABLE loan_officers (
    officer_id INT AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    branch_id INT,
    hire_date DATE NOT NULL,
    commission_rate DECIMAL(5,2) DEFAULT 0.00,
    status VARCHAR(20) DEFAULT 'Active',
    PRIMARY KEY (officer_id),
    UNIQUE KEY uk_loan_officers_email (email),
    INDEX idx_officers_status (status),
    INDEX idx_officers_branch (branch_id),
    CONSTRAINT chk_commission_rate CHECK (commission_rate >= 0 AND commission_rate <= 100)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Loan officer information';

-- Applications Table
CREATE TABLE applications (
    application_id INT AUTO_INCREMENT,
    customer_id INT NOT NULL,
    product_id INT NOT NULL,
    officer_id INT NOT NULL,
    application_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    loan_amount DECIMAL(15,2) NOT NULL,
    loan_purpose VARCHAR(50) NOT NULL,
    status VARCHAR(50) DEFAULT 'Submitted',
    closing_date DATE,
    application_fee DECIMAL(10,2),
    dti DECIMAL(5,2),
    property_value DECIMAL(15,2),
    ltv DECIMAL(5,2),
    rate_offered DECIMAL(5,3),
    term_offered INT,
    denial_reason VARCHAR(255),
    PRIMARY KEY (application_id),
    INDEX idx_applications_customerid (customer_id),
    INDEX idx_applications_date (application_date),
    INDEX idx_applications_status (status),
    INDEX idx_applications_officerid (officer_id),
    INDEX idx_applications_productid (product_id),
    CONSTRAINT fk_applications_customers FOREIGN KEY (customer_id) 
        REFERENCES customers(customer_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_applications_products FOREIGN KEY (product_id) 
        REFERENCES mortgage_products(product_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_applications_officers FOREIGN KEY (officer_id) 
        REFERENCES loan_officers(officer_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_loan_amount CHECK (loan_amount > 0),
    CONSTRAINT chk_dti CHECK (dti >= 0 AND dti <= 100),
    CONSTRAINT chk_ltv CHECK (ltv >= 0 AND ltv <= 100)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Loan applications';

-- Securities Table
CREATE TABLE securities (
    security_id INT AUTO_INCREMENT,
    security_name VARCHAR(100) NOT NULL,
    security_type VARCHAR(50) NOT NULL,
    cusip VARCHAR(9),
    issue_date DATE NOT NULL,
    maturity_date DATE NOT NULL,
    coupon_rate DECIMAL(5,3) NOT NULL,
    face_value DECIMAL(15,2) NOT NULL,
    current_balance DECIMAL(15,2) NOT NULL,
    issuer VARCHAR(100) NOT NULL,
    rating VARCHAR(10),
    status VARCHAR(20) DEFAULT 'Active',
    last_trade_date DATE,
    last_trade_price DECIMAL(10,3),
    PRIMARY KEY (security_id),
    INDEX idx_securities_cusip (cusip),
    INDEX idx_securities_type (security_type),
    INDEX idx_securities_status (status),
    CONSTRAINT chk_maturity CHECK (maturity_date > issue_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Securities and MBS information';

-- Loans Table
CREATE TABLE loans (
    loan_id INT AUTO_INCREMENT,
    application_id INT NOT NULL,
    customer_id INT NOT NULL,
    property_id INT NOT NULL,
    product_id INT NOT NULL,
    loan_amount DECIMAL(15,2) NOT NULL,
    interest_rate DECIMAL(5,3) NOT NULL,
    term INT NOT NULL,
    origination_date DATE NOT NULL,
    maturity_date DATE NOT NULL,
    monthly_payment DECIMAL(12,2) NOT NULL,
    remaining_balance DECIMAL(15,2) NOT NULL,
    status VARCHAR(20) DEFAULT 'Active',
    escrow_required BOOLEAN DEFAULT TRUE,
    pmi_required BOOLEAN DEFAULT FALSE,
    pmi_amount DECIMAL(10,2) DEFAULT 0.00,
    first_payment_date DATE NOT NULL,
    next_payment_date DATE,
    payment_frequency VARCHAR(20) DEFAULT 'Monthly',
    security_id INT,
    last_updated_date DATE,
    PRIMARY KEY (loan_id),
    INDEX idx_loans_customerid (customer_id),
    INDEX idx_loans_propertyid (property_id),
    INDEX idx_loans_originationdate (origination_date),
    INDEX idx_loans_status (status),
    INDEX idx_loans_securityid (security_id),
    INDEX idx_loans_applicationid (application_id),
    CONSTRAINT fk_loans_applications FOREIGN KEY (application_id) 
        REFERENCES applications(application_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_loans_customers FOREIGN KEY (customer_id) 
        REFERENCES customers(customer_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_loans_properties FOREIGN KEY (property_id) 
        REFERENCES property_details(property_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_loans_products FOREIGN KEY (product_id) 
        REFERENCES mortgage_products(product_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_loans_securities FOREIGN KEY (security_id) 
        REFERENCES securities(security_id) ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT chk_loans_amount CHECK (loan_amount > 0),
    CONSTRAINT chk_loans_rate CHECK (interest_rate >= 0 AND interest_rate <= 50),
    CONSTRAINT chk_loans_term CHECK (term > 0),
    CONSTRAINT chk_loans_maturity CHECK (maturity_date > origination_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Active and historical loans';

-- Payments Table
CREATE TABLE payments (
    payment_id INT AUTO_INCREMENT,
    loan_id INT NOT NULL,
    payment_date DATE NOT NULL,
    payment_amount DECIMAL(12,2) NOT NULL,
    principal_amount DECIMAL(12,2) NOT NULL,
    interest_amount DECIMAL(12,2) NOT NULL,
    escrow_amount DECIMAL(12,2) DEFAULT 0.00,
    late_fee_amount DECIMAL(10,2) DEFAULT 0.00,
    payment_method VARCHAR(50),
    transaction_id VARCHAR(100),
    payment_status VARCHAR(20) DEFAULT 'Processed',
    processed_date TIMESTAMP,
    PRIMARY KEY (payment_id),
    INDEX idx_payments_loanid (loan_id),
    INDEX idx_payments_date (payment_date),
    INDEX idx_payments_loanid_date (loan_id, payment_date DESC),
    INDEX idx_payments_status (payment_status),
    CONSTRAINT fk_payments_loans FOREIGN KEY (loan_id) 
        REFERENCES loans(loan_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_payments_amounts CHECK (
        payment_amount > 0 AND 
        principal_amount >= 0 AND 
        interest_amount >= 0
    )
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Payment transactions history'
PARTITION BY RANGE (YEAR(payment_date)) (
    PARTITION p2020 VALUES LESS THAN (2021),
    PARTITION p2021 VALUES LESS THAN (2022),
    PARTITION p2022 VALUES LESS THAN (2023),
    PARTITION p2023 VALUES LESS THAN (2024),
    PARTITION p2024 VALUES LESS THAN (2025),
    PARTITION p2025 VALUES LESS THAN (2026),
    PARTITION p_future VALUES LESS THAN MAXVALUE
);

-- Escrow Accounts Table
CREATE TABLE escrow_accounts (
    escrow_id INT AUTO_INCREMENT,
    loan_id INT NOT NULL,
    current_balance DECIMAL(12,2) DEFAULT 0.00,
    property_tax_amount DECIMAL(12,2) DEFAULT 0.00,
    property_insurance_amount DECIMAL(12,2) DEFAULT 0.00,
    pmi_amount DECIMAL(12,2) DEFAULT 0.00,
    cushion_amount DECIMAL(12,2) DEFAULT 0.00,
    last_analysis_date DATE,
    next_analysis_date DATE,
    monthly_contribution DECIMAL(12,2) DEFAULT 0.00,
    shortage_amount DECIMAL(12,2) DEFAULT 0.00,
    PRIMARY KEY (escrow_id),
    UNIQUE KEY uk_escrow_loanid (loan_id),
    CONSTRAINT fk_escrow_loans FOREIGN KEY (loan_id) 
        REFERENCES loans(loan_id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Escrow account balances and settings';

-- Escrow Transactions Table
CREATE TABLE escrow_transactions (
    transaction_id INT AUTO_INCREMENT,
    escrow_id INT NOT NULL,
    transaction_date DATE NOT NULL,
    transaction_type VARCHAR(50) NOT NULL,
    amount DECIMAL(12,2) NOT NULL,
    description VARCHAR(255),
    reference VARCHAR(100),
    PRIMARY KEY (transaction_id),
    INDEX idx_escrow_trans_escrowid (escrow_id),
    INDEX idx_escrow_trans_date (transaction_date),
    CONSTRAINT fk_escrow_trans_escrow FOREIGN KEY (escrow_id) 
        REFERENCES escrow_accounts(escrow_id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Escrow account transaction history';

-- Defaults and Foreclosures Table
CREATE TABLE defaults_foreclosures (
    default_id INT AUTO_INCREMENT,
    loan_id INT NOT NULL,
    default_date DATE NOT NULL,
    stage VARCHAR(50) NOT NULL,
    reason_code VARCHAR(50),
    resolution_type VARCHAR(50),
    resolution_date DATE,
    loss_amount DECIMAL(15,2),
    collection_agency VARCHAR(100),
    legal_filing_date DATE,
    legal_case_number VARCHAR(50),
    notes TEXT,
    PRIMARY KEY (default_id),
    INDEX idx_defaults_loanid (loan_id),
    INDEX idx_defaults_date (default_date),
    INDEX idx_defaults_stage (stage),
    CONSTRAINT fk_defaults_loans FOREIGN KEY (loan_id) 
        REFERENCES loans(loan_id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Default and foreclosure tracking';

-- Servicing Rights Table
CREATE TABLE servicing_rights (
    servicing_id INT AUTO_INCREMENT,
    loan_id INT NOT NULL,
    servicer_name VARCHAR(100) NOT NULL,
    servicer_id INT,
    transfer_date DATE NOT NULL,
    msr_value DECIMAL(15,2),
    servicing_fee DECIMAL(5,3),
    subservicer_name VARCHAR(100),
    transfer_reason VARCHAR(100),
    PRIMARY KEY (servicing_id),
    INDEX idx_servicing_loanid (loan_id),
    INDEX idx_servicing_transfer_date (transfer_date),
    INDEX idx_servicing_servicer (servicer_name),
    CONSTRAINT fk_servicing_loans FOREIGN KEY (loan_id) 
        REFERENCES loans(loan_id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Loan servicing rights transfers';

-- Customer Addresses Table
CREATE TABLE customer_addresses (
    address_id INT AUTO_INCREMENT,
    customer_id INT NOT NULL,
    address_type VARCHAR(20) NOT NULL,
    address_line1 VARCHAR(100) NOT NULL,
    address_line2 VARCHAR(100),
    city VARCHAR(50) NOT NULL,
    state CHAR(2) NOT NULL,
    zip_code VARCHAR(10) NOT NULL,
    country VARCHAR(50) DEFAULT 'USA',
    start_date DATE,
    end_date DATE,
    PRIMARY KEY (address_id),
    INDEX idx_cust_addr_customerid (customer_id),
    INDEX idx_cust_addr_type (address_type),
    CONSTRAINT fk_cust_addr_customers FOREIGN KEY (customer_id) 
        REFERENCES customers(customer_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Customer address history';

-- Documents Registry Table
CREATE TABLE documents_registry (
    document_id INT AUTO_INCREMENT,
    application_id INT NOT NULL,
    document_type VARCHAR(100) NOT NULL,
    file_name VARCHAR(255),
    file_location VARCHAR(255),
    upload_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    required_flag BOOLEAN DEFAULT TRUE,
    received_flag BOOLEAN DEFAULT FALSE,
    approval_status VARCHAR(20) DEFAULT 'Pending',
    approval_date TIMESTAMP,
    approved_by VARCHAR(100),
    notes TEXT,
    PRIMARY KEY (document_id),
    INDEX idx_docs_applicationid (application_id),
    INDEX idx_docs_type (document_type),
    INDEX idx_docs_status (approval_status),
    CONSTRAINT fk_docs_applications FOREIGN KEY (application_id) 
        REFERENCES applications(application_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Application documents tracking';

-- Risk Assessments Table
CREATE TABLE risk_assessments (
    assessment_id INT AUTO_INCREMENT,
    customer_id INT NOT NULL,
    application_id INT NOT NULL,
    assessment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    credit_score INT NOT NULL,
    dti DECIMAL(5,2) NOT NULL,
    ltv DECIMAL(5,2) NOT NULL,
    fico_score_source VARCHAR(50),
    risk_classification VARCHAR(20),
    recommended_action VARCHAR(50),
    notes TEXT,
    PRIMARY KEY (assessment_id),
    INDEX idx_risk_customerid (customer_id),
    INDEX idx_risk_applicationid (application_id),
    INDEX idx_risk_classification (risk_classification),
    CONSTRAINT fk_risk_customers FOREIGN KEY (customer_id) 
        REFERENCES customers(customer_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_risk_applications FOREIGN KEY (application_id) 
        REFERENCES applications(application_id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Risk assessment results';

-- Loan Term Modifications Table
CREATE TABLE loan_term_modifications (
    modification_id INT AUTO_INCREMENT,
    loan_id INT NOT NULL,
    modification_date DATE NOT NULL,
    modification_type VARCHAR(50) NOT NULL,
    previous_interest_rate DECIMAL(5,3),
    new_interest_rate DECIMAL(5,3),
    previous_term INT,
    new_term INT,
    previous_payment DECIMAL(12,2),
    new_payment DECIMAL(12,2),
    modification_fee DECIMAL(10,2),
    required_documents TEXT,
    approval_status VARCHAR(20) DEFAULT 'Pending',
    approved_by VARCHAR(100),
    notes TEXT,
    PRIMARY KEY (modification_id),
    INDEX idx_mods_loanid (loan_id),
    INDEX idx_mods_date (modification_date),
    INDEX idx_mods_type (modification_type),
    CONSTRAINT fk_mods_loans FOREIGN KEY (loan_id) 
        REFERENCES loans(loan_id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Loan term modification history';

-- Capital Market Data Table
CREATE TABLE capital_market_data (
    market_data_id INT AUTO_INCREMENT,
    data_date DATE NOT NULL,
    data_source VARCHAR(100) NOT NULL,
    treasury_10y DECIMAL(5,3),
    fed_funds_rate DECIMAL(5,3),
    libor_3m DECIMAL(5,3),
    sofr DECIMAL(5,3),
    mbs_30y_rate DECIMAL(5,3),
    fannie_30y_rate DECIMAL(5,3),
    freddie_30y_rate DECIMAL(5,3),
    effective_date_start DATE,
    effective_date_end DATE,
    PRIMARY KEY (market_data_id),
    UNIQUE KEY uk_market_data_date_source (data_date, data_source),
    INDEX idx_market_data_date (data_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Capital market rates and indices';

-- Audit Log Table
CREATE TABLE audit_log (
    log_id BIGINT AUTO_INCREMENT,
    entity_type VARCHAR(50) NOT NULL,
    entity_id INT NOT NULL,
    action_type VARCHAR(20) NOT NULL,
    action_datetime TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    user_id VARCHAR(50) NOT NULL,
    old_values JSON,
    new_values JSON,
    ip_address VARCHAR(50),
    application_name VARCHAR(100),
    PRIMARY KEY (log_id),
    INDEX idx_audit_datetime (action_datetime),
    INDEX idx_audit_entity (entity_type, entity_id),
    INDEX idx_audit_user (user_id),
    INDEX idx_audit_action (action_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Audit trail for all data changes'
PARTITION BY RANGE (YEAR(action_datetime)) (
    PARTITION p2023 VALUES LESS THAN (2024),
    PARTITION p2024 VALUES LESS THAN (2025),
    PARTITION p2025 VALUES LESS THAN (2026),
    PARTITION p_future VALUES LESS THAN MAXVALUE
);

-- =============================================
-- REFERENCE TABLES
-- =============================================

-- FINRA Fixed Income Table
CREATE TABLE finra_fi (
    symbol VARCHAR(50) NOT NULL,
    issuer_name VARCHAR(150) NOT NULL,
    coupon_type VARCHAR(50),
    coupon_rate DOUBLE,
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
    PRIMARY KEY (symbol, cusip),
    INDEX idx_finra_cusip (cusip),
    INDEX idx_finra_issuer (issuer_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='FINRA fixed income securities reference data';

-- Interest Type Reference Table
CREATE TABLE interest_type (
    itid INT AUTO_INCREMENT,
    interest_type_id VARCHAR(10),
    interest_type_desc VARCHAR(50),
    PRIMARY KEY (itid)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Interest type reference';

-- Product Subtype Reference Table
CREATE TABLE product_subtype (
    ptid INT AUTO_INCREMENT,
    prod_type VARCHAR(50) NOT NULL,
    prod_subtype VARCHAR(50) NOT NULL,
    pst_desc VARCHAR(100),
    PRIMARY KEY (ptid),
    UNIQUE KEY uk_product_subtype (prod_type, prod_subtype)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Product subtype reference';

-- =============================================
-- VIEWS
-- =============================================

-- Loan Portfolio Overview
CREATE OR REPLACE VIEW vw_loan_portfolio_overview AS
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
CREATE OR REPLACE VIEW vw_delinquent_loans AS
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
    DATEDIFF(CURDATE(), l.next_payment_date) AS days_past_due,
    CASE 
        WHEN DATEDIFF(CURDATE(), l.next_payment_date) BETWEEN 1 AND 30 THEN '1-30 Days'
        WHEN DATEDIFF(CURDATE(), l.next_payment_date) BETWEEN 31 AND 60 THEN '31-60 Days'
        WHEN DATEDIFF(CURDATE(), l.next_payment_date) BETWEEN 61 AND 90 THEN '61-90 Days'
        WHEN DATEDIFF(CURDATE(), l.next_payment_date) > 90 THEN '90+ Days'
        ELSE 'Current'
    END AS delinquency_bucket
FROM loans l
JOIN customers c ON l.customer_id = c.customer_id
JOIN property_details p ON l.property_id = p.property_id
LEFT JOIN defaults_foreclosures df ON l.loan_id = df.loan_id AND df.resolution_date IS NULL
WHERE l.next_payment_date < CURDATE() AND l.status = 'Active';

-- Customer Portfolio View
CREATE OR REPLACE VIEW vw_customer_portfolio AS
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
CREATE OR REPLACE VIEW vw_loan_officer_performance AS
SELECT 
    lo.officer_id,
    CONCAT(lo.first_name, ' ', lo.last_name) AS officer_name,
    COUNT(a.application_id) AS total_applications,
    SUM(CASE WHEN a.status = 'Approved' THEN 1 ELSE 0 END) AS approved_applications,
    SUM(CASE WHEN a.status = 'Denied' THEN 1 ELSE 0 END) AS denied_applications,
    CAST(SUM(CASE WHEN a.status = 'Approved' THEN 1 ELSE 0 END) / 
        NULLIF(COUNT(a.application_id), 0) * 100 AS DECIMAL(5,2)) AS approval_rate,
    SUM(l.loan_amount) AS total_loan_amount,
    AVG(DATEDIFF(a.closing_date, a.application_date)) AS avg_days_to_close
FROM loan_officers lo
LEFT JOIN applications a ON lo.officer_id = a.officer_id
LEFT JOIN loans l ON a.application_id = l.application_id AND a.status = 'Approved'
GROUP BY lo.officer_id, lo.first_name, lo.last_name;

-- Payment Analysis View
CREATE OR REPLACE VIEW vw_payment_analysis AS
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
-- STORED PROCEDURES AND FUNCTIONS
-- =============================================

DELIMITER //

-- Function to calculate current loan balance
CREATE FUNCTION fn_calculate_current_balance(
    p_loan_id INT,
    p_as_of_date DATE
)
RETURNS DECIMAL(15,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_current_balance DECIMAL(15,2);
    DECLARE v_calculation_date DATE;
    
    SET v_calculation_date = IFNULL(p_as_of_date, CURDATE());
    
    SELECT 
        l.loan_amount - IFNULL(SUM(p.principal_amount), 0)
    INTO v_current_balance
    FROM loans l
    LEFT JOIN payments p ON l.loan_id = p.loan_id 
        AND p.payment_date <= v_calculation_date
        AND p.payment_status = 'Processed'
    WHERE l.loan_id = p_loan_id
    GROUP BY l.loan_amount;
    
    RETURN IFNULL(v_current_balance, 0);
END//

-- Function to calculate loan age in months
CREATE FUNCTION fn_calculate_loan_age(p_loan_id INT)
RETURNS INT
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_origination_date DATE;
    DECLARE v_loan_age_months INT;
    
    SELECT origination_date INTO v_origination_date
    FROM loans
    WHERE loan_id = p_loan_id;
    
    IF v_origination_date IS NULL THEN
        RETURN 0;
    END IF;
    
    SET v_loan_age_months = TIMESTAMPDIFF(MONTH, v_origination_date, CURDATE());
    
    RETURN v_loan_age_months;
END//

-- Procedure to process loan payment
CREATE PROCEDURE sp_process_loan_payment(
    IN p_loan_id INT,
    IN p_payment_amount DECIMAL(12,2),
    IN p_payment_date DATE,
    IN p_payment_method VARCHAR(50),
    IN p_transaction_id VARCHAR(100)
)
BEGIN
    DECLARE v_remaining_balance DECIMAL(15,2);
    DECLARE v_interest_rate DECIMAL(5,3);
    DECLARE v_monthly_rate DECIMAL(12,8);
    DECLARE v_interest_amount DECIMAL(12,2);
    DECLARE v_principal_amount DECIMAL(12,2);
    DECLARE v_escrow_amount DECIMAL(12,2) DEFAULT 0;
    DECLARE v_late_fee_amount DECIMAL(10,2) DEFAULT 0;
    DECLARE v_next_payment_date DATE;
    DECLARE v_escrow_required BOOLEAN;
    DECLARE v_escrow_id INT;
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    
    START TRANSACTION;
    
    -- Get loan details
    SELECT remaining_balance, interest_rate, escrow_required, next_payment_date
    INTO v_remaining_balance, v_interest_rate, v_escrow_required, v_next_payment_date
    FROM loans
    WHERE loan_id = p_loan_id
    FOR UPDATE;
    
    -- Check for late payment
    IF p_payment_date > v_next_payment_date THEN
        SET v_late_fee_amount = 50.00;
    END IF;
    
    -- Calculate interest
    SET v_monthly_rate = (v_interest_rate / 100) / 12;
    SET v_interest_amount = ROUND(v_remaining_balance * v_monthly_rate, 2);
    
    -- Get escrow amount if required
    IF v_escrow_required THEN
        SELECT escrow_id, monthly_contribution 
        INTO v_escrow_id, v_escrow_amount
        FROM escrow_accounts
        WHERE loan_id = p_loan_id;
    END IF;
    
    -- Calculate principal
    SET v_principal_amount = p_payment_amount - v_interest_amount - v_escrow_amount - v_late_fee_amount;
    
    -- Update loan
    UPDATE loans
    SET remaining_balance = remaining_balance - v_principal_amount,
        next_payment_date = DATE_ADD(v_next_payment_date, INTERVAL 1 MONTH),
        last_updated_date = CURDATE()
    WHERE loan_id = p_loan_id;
    
    -- Insert payment record
    INSERT INTO payments (
        loan_id, payment_date, payment_amount, principal_amount,
        interest_amount, escrow_amount, late_fee_amount,
        payment_method, transaction_id, payment_status, processed_date
    ) VALUES (
        p_loan_id, p_payment_date, p_payment_amount, v_principal_amount,
        v_interest_amount, v_escrow_amount, v_late_fee_amount,
        p_payment_method, p_transaction_id, 'Processed', NOW()
    );
    
    -- Update escrow if required
    IF v_escrow_required AND v_escrow_id IS NOT NULL THEN
        UPDATE escrow_accounts
        SET current_balance = current_balance + v_escrow_amount
        WHERE escrow_id = v_escrow_id;
        
        INSERT INTO escrow_transactions (
            escrow_id, transaction_date, transaction_type, amount, description
        ) VALUES (
            v_escrow_id, p_payment_date, 'Deposit', v_escrow_amount, 'Monthly escrow contribution'
        );
    END IF;
    
    COMMIT;
END//

DELIMITER ;

-- =============================================
-- ANALYZE TABLES FOR QUERY OPTIMIZATION
-- =============================================

ANALYZE TABLE customers;
ANALYZE TABLE mortgage_products;
ANALYZE TABLE property_details;
ANALYZE TABLE loan_officers;
ANALYZE TABLE applications;
ANALYZE TABLE securities;
ANALYZE TABLE loans;
ANALYZE TABLE payments;
ANALYZE TABLE escrow_accounts;
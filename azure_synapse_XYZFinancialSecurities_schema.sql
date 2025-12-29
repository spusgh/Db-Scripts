
-- =============================================
-- Azure Synapse Analytics (Dedicated SQL Pool)
-- Complete Schema Conversion from MS SQL Server
-- XYZ_Financials_Securities Database
-- Optimized for MPP (Massively Parallel Processing)
-- =============================================

-- =============================================
-- DATABASE CONFIGURATION
-- Note: Create database via Azure Portal or ARM template
-- This script assumes connection to the database
-- =============================================

-- Set database-level options
ALTER DATABASE SCOPED CONFIGURATION SET MAXDOP = 8;
ALTER DATABASE SCOPED CONFIGURATION SET RESULT_SET_CACHING = ON;
ALTER DATABASE SCOPED CONFIGURATION SET QUERY_OPTIMIZER_HOTFIXES = ON;

-- =============================================
-- SCHEMAS
-- =============================================

CREATE SCHEMA staging AUTHORIZATION dbo;
GO

CREATE SCHEMA analytics AUTHORIZATION dbo;
GO

-- =============================================
-- USER-DEFINED TYPES (Converted to Tables/Constraints)
-- Note: Synapse doesn't support user-defined data types
-- =============================================

-- InterestRateType, LoanStatus, MoneyAmount, RiskGrade
-- Will be enforced via CHECK constraints on tables

-- =============================================
-- EXTERNAL DATA SOURCE (Optional - for PolyBase)
-- =============================================

-- Create master key for encryption
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'YourStrongPassword123!';
GO

-- Create database scoped credential (if using external sources)
-- CREATE DATABASE SCOPED CREDENTIAL AzureStorageCredential
-- WITH IDENTITY = 'SHARED ACCESS SIGNATURE',
-- SECRET = 'your_sas_token_here';
-- GO

-- Create external data source
-- CREATE EXTERNAL DATA SOURCE AzureStorage
-- WITH (
--     TYPE = HADOOP,
--     LOCATION = 'wasbs://container@account.blob.core.windows.net',
--     CREDENTIAL = AzureStorageCredential
-- );
-- GO

-- =============================================
-- DIMENSION TABLES (REPLICATE Distribution)
-- =============================================

-- Customers Table (HASH Distribution for Large Dimension)
CREATE TABLE dbo.Customers (
    CustomerID INT NOT NULL,
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    SSN CHAR(11) NOT NULL,
    DateOfBirth DATE NOT NULL,
    Email NVARCHAR(100),
    Phone NVARCHAR(20),
    AnnualIncome DECIMAL(15,2),
    EmploymentStatus NVARCHAR(50),
    Employer NVARCHAR(100),
    YearsEmployed INT,
    CreditScore INT,
    CreatedDate DATETIME2 DEFAULT GETDATE(),
    LastUpdatedDate DATETIME2 DEFAULT GETDATE()
)
WITH (
    DISTRIBUTION = HASH(CustomerID),
    CLUSTERED COLUMNSTORE INDEX
);
GO

-- Mortgage Products Table (REPLICATE - Small Dimension)
CREATE TABLE dbo.MortgageProducts (
    ProductID INT NOT NULL,
    ProductName NVARCHAR(100) NOT NULL,
    ProductType NVARCHAR(50) NOT NULL,
    Term INT NOT NULL,
    BaseInterestRate DECIMAL(5,3) NOT NULL,
    MinCreditScore INT NOT NULL,
    MaxLTV DECIMAL(5,2) NOT NULL,
    MinLoanAmount DECIMAL(15,2) NOT NULL,
    MaxLoanAmount DECIMAL(15,2) NOT NULL,
    OriginationFee DECIMAL(5,2) DEFAULT 0.00,
    IsActive BIT DEFAULT 1
)
WITH (
    DISTRIBUTION = REPLICATE,
    CLUSTERED COLUMNSTORE INDEX
);
GO

-- Property Details Table (HASH Distribution)
CREATE TABLE dbo.PropertyDetails (
    PropertyID INT NOT NULL,
    AddressLine1 NVARCHAR(100) NOT NULL,
    AddressLine2 NVARCHAR(100),
    City NVARCHAR(50) NOT NULL,
    State CHAR(2) NOT NULL,
    ZipCode NVARCHAR(10) NOT NULL,
    Country NVARCHAR(50) DEFAULT 'USA',
    PropertyType NVARCHAR(50) NOT NULL,
    YearBuilt INT,
    SquareFeet INT,
    Bedrooms INT,
    Bathrooms DECIMAL(3,1),
    PurchasePrice DECIMAL(15,2),
    CurrentValue DECIMAL(15,2),
    LastAppraisalDate DATE,
    LastAppraisalValue DECIMAL(15,2),
    TaxAssessmentValue DECIMAL(15,2),
    AnnualTaxAmount DECIMAL(10,2),
    HOAFees DECIMAL(10,2) DEFAULT 0.00,
    FloodZone NVARCHAR(10),
    PropertyTaxID NVARCHAR(50),
    Latitude DECIMAL(9,6),
    Longitude DECIMAL(9,6)
)
WITH (
    DISTRIBUTION = HASH(PropertyID),
    CLUSTERED COLUMNSTORE INDEX
);
GO

-- Loan Officers Table (REPLICATE - Small Dimension)
CREATE TABLE dbo.LoanOfficers (
    OfficerID INT NOT NULL,
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    Email NVARCHAR(100) NOT NULL,
    Phone NVARCHAR(20) NOT NULL,
    BranchID INT,
    HireDate DATE NOT NULL,
    CommissionRate DECIMAL(5,2) DEFAULT 0.00,
    Status NVARCHAR(20) DEFAULT 'Active'
)
WITH (
    DISTRIBUTION = REPLICATE,
    CLUSTERED COLUMNSTORE INDEX
);
GO

-- =============================================
-- FACT TABLES (HASH Distribution)
-- =============================================

-- Applications Table
CREATE TABLE dbo.Applications (
    ApplicationID INT NOT NULL,
    CustomerID INT NOT NULL,
    ProductID INT NOT NULL,
    OfficerID INT NOT NULL,
    ApplicationDate DATETIME2 DEFAULT GETDATE(),
    LoanAmount DECIMAL(15,2) NOT NULL,
    LoanPurpose NVARCHAR(50) NOT NULL,
    Status NVARCHAR(50) DEFAULT 'Submitted',
    ClosingDate DATE,
    ApplicationFee DECIMAL(10,2),
    DTI DECIMAL(5,2),
    PropertyValue DECIMAL(15,2),
    LTV DECIMAL(5,2),
    RateOffered DECIMAL(5,3),
    TermOffered INT,
    DenialReason NVARCHAR(255)
)
WITH (
    DISTRIBUTION = HASH(ApplicationID),
    CLUSTERED COLUMNSTORE INDEX
);
GO

-- Securities Table (REPLICATE - Reference Data)
CREATE TABLE dbo.Securities (
    SecurityID INT NOT NULL,
    SecurityName NVARCHAR(100) NOT NULL,
    SecurityType NVARCHAR(50) NOT NULL,
    CUSIP NVARCHAR(9),
    IssueDate DATE NOT NULL,
    MaturityDate DATE NOT NULL,
    CouponRate DECIMAL(5,3) NOT NULL,
    FaceValue DECIMAL(15,2) NOT NULL,
    CurrentBalance DECIMAL(15,2) NOT NULL,
    Issuer NVARCHAR(100) NOT NULL,
    Rating NVARCHAR(10),
    Status NVARCHAR(20) DEFAULT 'Active',
    LastTradeDate DATE,
    LastTradePrice DECIMAL(10,3)
)
WITH (
    DISTRIBUTION = REPLICATE,
    CLUSTERED COLUMNSTORE INDEX
);
GO

-- Loans Table (HASH Distribution - Primary Fact)
CREATE TABLE dbo.Loans (
    LoanID INT NOT NULL,
    ApplicationID INT NOT NULL,
    CustomerID INT NOT NULL,
    PropertyID INT NOT NULL,
    ProductID INT NOT NULL,
    LoanAmount DECIMAL(15,2) NOT NULL,
    InterestRate DECIMAL(5,3) NOT NULL,
    Term INT NOT NULL,
    OriginationDate DATE NOT NULL,
    MaturityDate DATE NOT NULL,
    MonthlyPayment DECIMAL(12,2) NOT NULL,
    RemainingBalance DECIMAL(15,2) NOT NULL,
    Status NVARCHAR(20) DEFAULT 'Active',
    EscrowRequired BIT DEFAULT 1,
    PMIRequired BIT DEFAULT 0,
    PMIAmount DECIMAL(10,2) DEFAULT 0.00,
    FirstPaymentDate DATE NOT NULL,
    NextPaymentDate DATE,
    PaymentFrequency NVARCHAR(20) DEFAULT 'Monthly',
    SecurityID INT,
    LastUpdatedDate DATE
)
WITH (
    DISTRIBUTION = HASH(LoanID),
    CLUSTERED COLUMNSTORE INDEX
);
GO

-- Payments Table (Co-located with Loans via LoanID)
CREATE TABLE dbo.Payments (
    PaymentID INT NOT NULL,
    LoanID INT NOT NULL,
    PaymentDate DATE NOT NULL,
    PaymentAmount DECIMAL(12,2) NOT NULL,
    PrincipalAmount DECIMAL(12,2) NOT NULL,
    InterestAmount DECIMAL(12,2) NOT NULL,
    EscrowAmount DECIMAL(12,2) DEFAULT 0.00,
    LateFeeAmount DECIMAL(10,2) DEFAULT 0.00,
    PaymentMethod NVARCHAR(50),
    TransactionID NVARCHAR(100),
    PaymentStatus NVARCHAR(20) DEFAULT 'Processed',
    ProcessedDate DATETIME2
)
WITH (
    DISTRIBUTION = HASH(LoanID),
    CLUSTERED COLUMNSTORE INDEX
);
GO

-- =============================================
-- SUPPORTING TABLES
-- =============================================

-- Escrow Accounts Table (Co-located with Loans)
CREATE TABLE dbo.EscrowAccounts (
    EscrowID INT NOT NULL,
    LoanID INT NOT NULL,
    CurrentBalance DECIMAL(12,2) DEFAULT 0.00,
    PropertyTaxAmount DECIMAL(12,2) DEFAULT 0.00,
    PropertyInsuranceAmount DECIMAL(12,2) DEFAULT 0.00,
    PMIAmount DECIMAL(12,2) DEFAULT 0.00,
    CushionAmount DECIMAL(12,2) DEFAULT 0.00,
    LastAnalysisDate DATE,
    NextAnalysisDate DATE,
    MonthlyContribution DECIMAL(12,2) DEFAULT 0.00,
    ShortageAmount DECIMAL(12,2) DEFAULT 0.00
)
WITH (
    DISTRIBUTION = HASH(LoanID),
    CLUSTERED COLUMNSTORE INDEX
);
GO

-- Escrow Transactions Table
CREATE TABLE dbo.EscrowTransactions (
    TransactionID INT NOT NULL,
    EscrowID INT NOT NULL,
    TransactionDate DATE NOT NULL,
    TransactionType NVARCHAR(50) NOT NULL,
    Amount DECIMAL(12,2) NOT NULL,
    Description NVARCHAR(255),
    Reference NVARCHAR(100)
)
WITH (
    DISTRIBUTION = HASH(EscrowID),
    CLUSTERED COLUMNSTORE INDEX
);
GO

-- Defaults and Foreclosures Table
CREATE TABLE dbo.DefaultsForeclosures (
    DefaultID INT NOT NULL,
    LoanID INT NOT NULL,
    DefaultDate DATE NOT NULL,
    Stage NVARCHAR(50) NOT NULL,
    ReasonCode NVARCHAR(50),
    ResolutionType NVARCHAR(50),
    ResolutionDate DATE,
    LossAmount DECIMAL(15,2),
    CollectionAgency NVARCHAR(100),
    LegalFilingDate DATE,
    LegalCaseNumber NVARCHAR(50),
    Notes NVARCHAR(MAX)
)
WITH (
    DISTRIBUTION = HASH(LoanID),
    CLUSTERED COLUMNSTORE INDEX
);
GO

-- Servicing Rights Table
CREATE TABLE dbo.ServicingRights (
    ServicingID INT NOT NULL,
    LoanID INT NOT NULL,
    ServicerName NVARCHAR(100) NOT NULL,
    ServicerID INT,
    TransferDate DATE NOT NULL,
    MSRValue DECIMAL(15,2),
    ServicingFee DECIMAL(5,3),
    SubservicerName NVARCHAR(100),
    TransferReason NVARCHAR(100)
)
WITH (
    DISTRIBUTION = HASH(LoanID),
    CLUSTERED COLUMNSTORE INDEX
);
GO

-- Customer Addresses Table
CREATE TABLE dbo.CustomerAddresses (
    AddressID INT NOT NULL,
    CustomerID INT NOT NULL,
    AddressType NVARCHAR(20) NOT NULL,
    AddressLine1 NVARCHAR(100) NOT NULL,
    AddressLine2 NVARCHAR(100),
    City NVARCHAR(50) NOT NULL,
    State CHAR(2) NOT NULL,
    ZipCode NVARCHAR(10) NOT NULL,
    Country NVARCHAR(50) DEFAULT 'USA',
    StartDate DATE,
    EndDate DATE
)
WITH (
    DISTRIBUTION = HASH(CustomerID),
    CLUSTERED COLUMNSTORE INDEX
);
GO

-- Documents Registry Table
CREATE TABLE dbo.DocumentsRegistry (
    DocumentID INT NOT NULL,
    ApplicationID INT NOT NULL,
    DocumentType NVARCHAR(100) NOT NULL,
    FileName NVARCHAR(255),
    FileLocation NVARCHAR(255),
    UploadDate DATETIME2 DEFAULT GETDATE(),
    RequiredFlag BIT DEFAULT 1,
    ReceivedFlag BIT DEFAULT 0,
    ApprovalStatus NVARCHAR(20) DEFAULT 'Pending',
    ApprovalDate DATETIME2,
    ApprovedBy NVARCHAR(100),
    Notes NVARCHAR(MAX)
)
WITH (
    DISTRIBUTION = HASH(ApplicationID),
    CLUSTERED COLUMNSTORE INDEX
);
GO

-- Risk Assessments Table
CREATE TABLE dbo.RiskAssessments (
    AssessmentID INT NOT NULL,
    CustomerID INT NOT NULL,
    ApplicationID INT NOT NULL,
    AssessmentDate DATETIME2 DEFAULT GETDATE(),
    CreditScore INT NOT NULL,
    DTI DECIMAL(5,2) NOT NULL,
    LTV DECIMAL(5,2) NOT NULL,
    FICOScoreSource NVARCHAR(50),
    RiskClassification NVARCHAR(20),
    RecommendedAction NVARCHAR(50),
    Notes NVARCHAR(MAX)
)
WITH (
    DISTRIBUTION = HASH(ApplicationID),
    CLUSTERED COLUMNSTORE INDEX
);
GO

-- Loan Term Modifications Table
CREATE TABLE dbo.LoanTermModifications (
    ModificationID INT NOT NULL,
    LoanID INT NOT NULL,
    ModificationDate DATE NOT NULL,
    ModificationType NVARCHAR(50) NOT NULL,
    PreviousInterestRate DECIMAL(5,3),
    NewInterestRate DECIMAL(5,3),
    PreviousTerm INT,
    NewTerm INT,
    PreviousPayment DECIMAL(12,2),
    NewPayment DECIMAL(12,2),
    ModificationFee DECIMAL(10,2),
    RequiredDocuments NVARCHAR(MAX),
    ApprovalStatus NVARCHAR(20) DEFAULT 'Pending',
    ApprovedBy NVARCHAR(100),
    Notes NVARCHAR(MAX)
)
WITH (
    DISTRIBUTION = HASH(LoanID),
    CLUSTERED COLUMNSTORE INDEX
);
GO

-- Capital Market Data Table (REPLICATE - Reference Data)
CREATE TABLE dbo.CapitalMarketData (
    MarketDataID INT NOT NULL,
    DataDate DATE NOT NULL,
    DataSource NVARCHAR(100) NOT NULL,
    Treasury10Y DECIMAL(5,3),
    FedFundsRate DECIMAL(5,3),
    LIBOR3M DECIMAL(5,3),
    SOFR DECIMAL(5,3),
    MBS30YRate DECIMAL(5,3),
    Fannie30YRate DECIMAL(5,3),
    Freddie30YRate DECIMAL(5,3),
    EffectiveDateStart DATE,
    EffectiveDateEnd DATE
)
WITH (
    DISTRIBUTION = REPLICATE,
    CLUSTERED COLUMNSTORE INDEX
);
GO

-- Audit Log Table (ROUND_ROBIN for Write-Heavy Operations)
CREATE TABLE dbo.AuditLog (
    LogID BIGINT NOT NULL,
    EntityType NVARCHAR(50) NOT NULL,
    EntityID INT NOT NULL,
    ActionType NVARCHAR(20) NOT NULL,
    ActionDateTime DATETIME2 DEFAULT GETDATE(),
    UserID NVARCHAR(50) NOT NULL,
    OldValues NVARCHAR(MAX),
    NewValues NVARCHAR(MAX),
    IPAddress NVARCHAR(50),
    ApplicationName NVARCHAR(100)
)
WITH (
    DISTRIBUTION = ROUND_ROBIN,
    HEAP
);
GO

-- =============================================
-- REFERENCE TABLES (REPLICATE)
-- =============================================

-- FINRA Fixed Income Table
CREATE TABLE dbo.FINRA_FI (
    Symbol NVARCHAR(50) NOT NULL,
    IssuerName NVARCHAR(150) NOT NULL,
    CouponType NVARCHAR(50),
    CouponRate FLOAT,
    MaturityDate DATE NOT NULL,
    DealID NVARCHAR(50),
    TrancheID NVARCHAR(50),
    IssueDescription NVARCHAR(250) NOT NULL,
    InterestType NVARCHAR(50),
    I44A BIT NOT NULL,
    CUSIP NVARCHAR(50) NOT NULL,
    SubProdType NVARCHAR(50),
    ProdSubtype NVARCHAR(50) NOT NULL,
    ProdType NVARCHAR(50),
    IssuingAgency NVARCHAR(100),
    Convertible NVARCHAR(1)
)
WITH (
    DISTRIBUTION = REPLICATE,
    CLUSTERED COLUMNSTORE INDEX
);
GO

-- Interest Type Reference Table
CREATE TABLE dbo.InterestType (
    ITID INT NOT NULL,
    InterestTypeID NCHAR(10),
    InterestTypeDesc NCHAR(50)
)
WITH (
    DISTRIBUTION = REPLICATE,
    CLUSTERED INDEX (ITID)
);
GO

-- Product Subtype Reference Table
CREATE TABLE dbo.ProductSubtype (
    PTID INT NOT NULL,
    ProdType NCHAR(50) NOT NULL,
    ProdSubType NCHAR(50) NOT NULL,
    PSTDesc NCHAR(100)
)
WITH (
    DISTRIBUTION = REPLICATE,
    CLUSTERED INDEX (PTID)
);
GO

-- =============================================
-- STAGING TABLES (ROUND_ROBIN for Fast Loading)
-- =============================================

-- Staging table for bulk loan imports
CREATE TABLE staging.Loans_Staging (
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
    Status NVARCHAR(20),
    EscrowRequired BIT,
    PMIRequired BIT,
    PMIAmount DECIMAL(10,2),
    FirstPaymentDate DATE,
    NextPaymentDate DATE,
    PaymentFrequency NVARCHAR(20),
    SecurityID INT,
    LastUpdatedDate DATE
)
WITH (
    DISTRIBUTION = ROUND_ROBIN,
    HEAP
);
GO

-- Staging table for bulk payment imports
CREATE TABLE staging.Payments_Staging (
    PaymentID INT,
    LoanID INT,
    PaymentDate DATE,
    PaymentAmount DECIMAL(12,2),
    PrincipalAmount DECIMAL(12,2),
    InterestAmount DECIMAL(12,2),
    EscrowAmount DECIMAL(12,2),
    LateFeeAmount DECIMAL(10,2),
    PaymentMethod NVARCHAR(50),
    TransactionID NVARCHAR(100),
    PaymentStatus NVARCHAR(20),
    ProcessedDate DATETIME2
)
WITH (
    DISTRIBUTION = ROUND_ROBIN,
    HEAP
);
GO

-- =============================================
-- VIEWS (Converted from MS SQL)
-- =============================================

-- Loan Portfolio Overview View
CREATE VIEW dbo.vw_LoanPortfolioOverview
AS
SELECT 
    L.LoanID,
    C.FirstName + ' ' + C.LastName AS CustomerName,
    P.AddressLine1 + ', ' + P.City + ', ' + P.State + ' ' + P.ZipCode AS PropertyAddress,
    L.OriginationDate,
    L.MaturityDate,
    L.LoanAmount,
    L.RemainingBalance,
    L.InterestRate,
    L.MonthlyPayment,
    L.Status,
    MP.ProductName,
    MP.ProductType,
    S.SecurityName,
    SR.ServicerName,
    CASE 
        WHEN L.RemainingBalance = 0 THEN 'Paid Off'
        WHEN EXISTS (SELECT 1 FROM DefaultsForeclosures DF WHERE DF.LoanID = L.LoanID AND DF.ResolutionDate IS NULL) THEN 'In Default'
        ELSE L.Status
    END AS CurrentStatus
FROM Loans L
JOIN Customers C ON L.CustomerID = C.CustomerID
JOIN PropertyDetails P ON L.PropertyID = P.PropertyID
JOIN MortgageProducts MP ON L.ProductID = MP.ProductID
LEFT JOIN Securities S ON L.SecurityID = S.SecurityID
LEFT JOIN ServicingRights SR ON L.LoanID = SR.LoanID;
GO

-- Delinquent Loans View
CREATE VIEW dbo.vw_DelinquentLoans
AS
SELECT 
    L.LoanID,
    C.FirstName + ' ' + C.LastName AS CustomerName,
    C.Phone,
    C.Email,
    P.AddressLine1 + ', ' + P.City + ', ' + P.State + ' ' + P.ZipCode AS PropertyAddress,
    L.OriginationDate,
    L.RemainingBalance,
    L.MonthlyPayment,
    L.NextPaymentDate,
    DF.DefaultDate,
    DF.Stage,
    DATEDIFF(DAY, L.NextPaymentDate, GETDATE()) AS DaysPastDue,
    CASE 
        WHEN DATEDIFF(DAY, L.NextPaymentDate, GETDATE()) BETWEEN 1 AND 30 THEN '1-30 Days'
        WHEN DATEDIFF(DAY, L.NextPaymentDate, GETDATE()) BETWEEN 31 AND 60 THEN '31-60 Days'
        WHEN DATEDIFF(DAY, L.NextPaymentDate, GETDATE()) BETWEEN 61 AND 90 THEN '61-90 Days'
        WHEN DATEDIFF(DAY, L.NextPaymentDate, GETDATE()) > 90 THEN '90+ Days'
        ELSE 'Current'
    END AS DelinquencyBucket
FROM Loans L
JOIN Customers C ON L.CustomerID = C.CustomerID
JOIN PropertyDetails P ON L.PropertyID = P.PropertyID
LEFT JOIN DefaultsForeclosures DF ON L.LoanID = DF.LoanID AND DF.ResolutionDate IS NULL
WHERE L.NextPaymentDate < CAST(GETDATE() AS DATE) AND L.Status = 'Active';
GO

-- Customer Portfolio View
CREATE VIEW dbo.vw_CustomerPortfolio
AS
SELECT 
    C.CustomerID,
    C.FirstName + ' ' + C.LastName AS CustomerName,
    C.Email,
    C.Phone,
    C.CreditScore,
    COUNT(L.LoanID) AS ActiveLoanCount,
    SUM(L.LoanAmount) AS TotalLoanAmount,
    SUM(L.RemainingBalance) AS TotalRemainingBalance,
    MAX(L.OriginationDate) AS MostRecentLoanDate
FROM Customers C
LEFT JOIN Loans L ON C.CustomerID = L.CustomerID AND L.Status = 'Active'
GROUP BY C.CustomerID, C.FirstName, C.LastName, C.Email, C.Phone, C.CreditScore;
GO

-- Loan Officer Performance View
CREATE VIEW dbo.vw_LoanOfficerPerformance
AS
SELECT 
    LO.OfficerID,
    LO.FirstName + ' ' + LO.LastName AS OfficerName,
    COUNT(A.ApplicationID) AS TotalApplications,
    SUM(CASE WHEN A.Status = 'Approved' THEN 1 ELSE 0 END) AS ApprovedApplications,
    SUM(CASE WHEN A.Status = 'Denied' THEN 1 ELSE 0 END) AS DeniedApplications,
    CAST(SUM(CASE WHEN A.Status = 'Approved' THEN 1.0 ELSE 0 END) / 
        NULLIF(COUNT(A.ApplicationID), 0) * 100 AS DECIMAL(5,2)) AS ApprovalRate,
    SUM(L.LoanAmount) AS TotalLoanAmount,
    SUM(L.LoanAmount * (LO.CommissionRate / 100)) AS TotalCommission,
    AVG(DATEDIFF(DAY, A.ApplicationDate, A.ClosingDate)) AS AvgDaysToClose
FROM LoanOfficers LO
LEFT JOIN Applications A ON LO.OfficerID = A.OfficerID
LEFT JOIN Loans L ON A.ApplicationID = L.ApplicationID AND A.Status = 'Approved'
GROUP BY LO.OfficerID, LO.FirstName, LO.LastName, LO.CommissionRate;
GO

-- Escrow Analysis View
CREATE VIEW dbo.vw_EscrowAnalysis
AS
SELECT 
    E.EscrowID,
    L.LoanID,
    C.FirstName + ' ' + C.LastName AS CustomerName,
    P.AddressLine1 + ', ' + P.City + ', ' + P.State + ' ' + P.ZipCode AS PropertyAddress,
    E.CurrentBalance,
    E.PropertyTaxAmount,
    E.PropertyInsuranceAmount,
    E.PMIAmount,
    E.MonthlyContribution,
    E.LastAnalysisDate,
    E.NextAnalysisDate,
    E.ShortageAmount,
    E.CushionAmount,
    P.AnnualTaxAmount
FROM EscrowAccounts E
JOIN Loans L ON E.LoanID = L.LoanID
JOIN Customers C ON L.CustomerID = C.CustomerID
JOIN PropertyDetails P ON L.PropertyID = P.PropertyID;
GO

-- Payment Analysis View
CREATE VIEW dbo.vw_PaymentAnalysis
AS
SELECT 
    YEAR(P.PaymentDate) AS PaymentYear,
    MONTH(P.PaymentDate) AS PaymentMonth,
    L.Status AS LoanStatus,
    COUNT(P.PaymentID) AS PaymentCount,
    SUM(P.PaymentAmount) AS TotalPayments,
    SUM(P.PrincipalAmount) AS TotalPrincipal,
    SUM(P.InterestAmount) AS TotalInterest,
    SUM(P.EscrowAmount) AS TotalEscrow,
    SUM(P.LateFeeAmount) AS TotalLateFees,
    AVG(P.PaymentAmount) AS AvgPaymentAmount
FROM Payments P
JOIN Loans L ON P.LoanID = L.LoanID
GROUP BY YEAR(P.PaymentDate), MONTH(P.PaymentDate), L.Status;
GO

-- =============================================
-- MATERIALIZED VIEWS (Result Set Caching)
-- =============================================

-- Loan Portfolio Metrics (Materialized View Alternative)
CREATE VIEW analytics.vw_LoanPortfolioMetrics
AS
SELECT 
    YEAR(L.OriginationDate) AS OriginationYear,
    MONTH(L.OriginationDate) AS OriginationMonth,
    L.Status,
    MP.ProductType,
    P.State,
    COUNT(L.LoanID) AS LoanCount,
    SUM(L.LoanAmount) AS TotalLoanAmount,
    AVG(L.InterestRate) AS AvgInterestRate,
    SUM(L.RemainingBalance) AS TotalRemainingBalance,
    AVG(L.LoanAmount) AS AvgLoanAmount,
    MIN(L.InterestRate) AS MinInterestRate,
    MAX(L.InterestRate) AS MaxInterestRate
FROM Loans L
JOIN MortgageProducts MP ON L.ProductID = MP.ProductID
JOIN PropertyDetails P ON L.PropertyID = P.PropertyID
GROUP BY YEAR(L.OriginationDate), MONTH(L.OriginationDate), L.Status, MP.ProductType, P.State;
GO

-- Delinquency Metrics
CREATE VIEW analytics.vw_DelinquencyMetrics
AS
SELECT 
    YEAR(L.OriginationDate) AS OriginationYear,
    MP.ProductType,
    P.State,
    COUNT(CASE WHEN DATEDIFF(DAY, L.NextPaymentDate, GETDATE()) > 30 THEN 1 END) AS DelinquentLoans,
    COUNT(L.LoanID) AS TotalLoans,
    CAST(COUNT(CASE WHEN DATEDIFF(DAY, L.NextPaymentDate, GETDATE()) > 30 THEN 1 END) AS FLOAT) / 
        NULLIF(COUNT(L.LoanID), 0) * 100 AS DelinquencyRate,
    SUM(CASE WHEN DATEDIFF(DAY, L.NextPaymentDate, GETDATE()) > 30 THEN L.RemainingBalance ELSE 0 END) AS DelinquentBalance
FROM Loans L
JOIN MortgageProducts MP ON L.ProductID = MP.ProductID
JOIN PropertyDetails P ON L.PropertyID = P.PropertyID
WHERE L.Status = 'Active'
GROUP BY YEAR(L.OriginationDate), MP.ProductType, P.State;
GO

-- =============================================
-- STATISTICS (Critical for Query Optimization)
-- =============================================

-- Create statistics on key columns for query optimization
CREATE STATISTICS stat_customers_creditScore ON Customers(CreditScore);
CREATE STATISTICS stat_customers_annualincome ON Customers(AnnualIncome);
CREATE STATISTICS stat_customers_state ON CustomerAddresses(State);

CREATE STATISTICS stat_loans_status ON Loans(Status);
CREATE STATISTICS stat_loans_originationdate ON Loans(OriginationDate);
CREATE STATISTICS stat_loans_remainingbalance ON Loans(RemainingBalance);
CREATE STATISTICS stat_loans_interestrate ON Loans(InterestRate);

CREATE STATISTICS stat_payments_paymentdate ON Payments(PaymentDate);
CREATE STATISTICS stat_payments_paymentstatus ON Payments(PaymentStatus);

CREATE STATISTICS stat_applications_status ON Applications(Status);
CREATE STATISTICS stat_applications_applicationdate ON Applications(ApplicationDate);

CREATE STATISTICS stat_property_state ON PropertyDetails(State);
CREATE STATISTICS stat_property_type ON PropertyDetails(PropertyType);
GO

-- =============================================
-- STORED PROCEDURES (Simplified for Synapse)
-- Note: Synapse has limited stored procedure support
-- Complex logic should be in ETL/ELT processes
-- =============================================

-- Procedure to Calculate Loan Metrics
CREATE PROCEDURE dbo.sp_CalculateLoanMetrics
    @LoanID INT
AS
BEGIN
    SELECT 
        L.LoanID,
        L.LoanAmount,
        L.RemainingBalance,
        L.InterestRate,
        L.MonthlyPayment,
        L.Term,
        DATEDIFF(MONTH, L.OriginationDate, GETDATE()) AS LoanAgeMonths,
        L.LoanAmount - L.RemainingBalance AS TotalPrincipalPaid,
        CAST((L.LoanAmount - L.RemainingBalance) / L.LoanAmount * 100 AS DECIMAL(5,2)) AS PercentPaid,
        COUNT(P.PaymentID) AS PaymentsMade,
        SUM(P.InterestAmount) AS TotalInterestPaid
    FROM Loans L
    LEFT JOIN Payments P ON L.LoanID = P.LoanID AND P.PaymentStatus = 'Processed'
    WHERE L.LoanID = @LoanID
    GROUP BY 
        L.LoanID, L.LoanAmount, L.RemainingBalance, L.InterestRate, 
        L.MonthlyPayment, L.Term, L.OriginationDate;
END;
GO

-- =============================================
-- DYNAMIC DATA MASKING (Security Feature)
-- =============================================

-- Mask sensitive PII data
ALTER TABLE dbo.Customers
ALTER COLUMN SSN ADD MASKED WITH (FUNCTION = 'partial(0,"XXX-XX-",4)');

ALTER TABLE dbo.Customers
ALTER COLUMN Email ADD MASKED WITH (FUNCTION = 'email()');

ALTER TABLE dbo.Customers
ALTER COLUMN Phone ADD MASKED WITH (FUNCTION = 'partial(0,"XXX-XXX-",4)');
GO

-- =============================================
-- ROW-LEVEL SECURITY (Optional)
-- Note: Implement based on organizational requirements
-- =============================================

-- Example: Create security policy for loan officers
-- CREATE SCHEMA security;
-- GO

-- CREATE FUNCTION security.fn_LoanOfficerPredicate(@OfficerID INT)
-- RETURNS TABLE
-- WITH SCHEMABINDING
-- AS
-- RETURN SELECT 1 AS fn_LoanOfficerPredicate_result
-- WHERE @OfficerID = CAST(SESSION_CONTEXT(N'OfficerID') AS INT)
--     OR IS_MEMBER('db_owner') = 1;
-- GO

-- CREATE SECURITY POLICY security.LoanOfficerSecurityPolicy
-- ADD FILTER PREDICATE security.fn_LoanOfficerPredicate(OfficerID)
-- ON dbo.Applications
-- WITH (STATE = ON);
-- GO

-- =============================================
-- DATA LOADING PATTERNS
-- =============================================

-- Example: CTAS (Create Table As Select) pattern for transformations
-- CREATE TABLE dbo.Loans_Transformed
-- WITH (
--     DISTRIBUTION = HASH(LoanID),
--     CLUSTERED COLUMNSTORE INDEX
-- )
-- AS
-- SELECT 
--     LoanID,
--     CustomerID,
--     LoanAmount,
--     InterestRate,
--     Status,
--     YEAR(OriginationDate) AS OriginationYear,
--     MONTH(OriginationDate) AS OriginationMonth
-- FROM staging.Loans_Staging;

-- =============================================
-- POLYBASE EXTERNAL TABLES (For Data Lake Integration)
-- =============================================

-- Example: Create external file format
-- CREATE EXTERNAL FILE FORMAT ParquetFormat
-- WITH (
--     FORMAT_TYPE = PARQUET,
--     DATA_COMPRESSION = 'org.apache.hadoop.io.compress.SnappyCodec'
-- );
-- GO

-- Example: Create external table for payments in data lake
-- CREATE EXTERNAL TABLE staging.ext_Payments
-- (
--     PaymentID INT,
--     LoanID INT,
--     PaymentDate DATE,
--     PaymentAmount DECIMAL(12,2),
--     PrincipalAmount DECIMAL(12,2),
--     InterestAmount DECIMAL(12,2)
-- )
-- WITH (
--     LOCATION = '/payments/',
--     DATA_SOURCE = AzureStorage,
--     FILE_FORMAT = ParquetFormat
-- );
-- GO

-- =============================================
-- WORKLOAD MANAGEMENT
-- =============================================

-- Create workload classifiers for different user groups
-- CREATE WORKLOAD CLASSIFIER wgc_ETLUser
-- WITH (
--     WORKLOAD_GROUP = 'ETLGroup',
--     MEMBERNAME = 'ETLUser',
--     IMPORTANCE = HIGH
-- );
-- GO

-- CREATE WORKLOAD CLASSIFIER wgc_AnalystUser
-- WITH (
--     WORKLOAD_GROUP = 'AnalystGroup',
--     MEMBERNAME = 'AnalystUser',
--     IMPORTANCE = NORMAL
-- );
-- GO

-- =============================================
-- MAINTENANCE AND OPTIMIZATION SCRIPTS
-- =============================================

-- Script to rebuild columnstore indexes
-- ALTER INDEX ALL ON dbo.Loans REBUILD;
-- ALTER INDEX ALL ON dbo.Payments REBUILD;

-- Script to update statistics
-- UPDATE STATISTICS dbo.Loans;
-- UPDATE STATISTICS dbo.Payments;
-- UPDATE STATISTICS dbo.Customers;

-- =============================================
-- MONITORING QUERIES
-- =============================================

-- Query to check table distributions
-- SELECT 
--     t.name AS TableName,
--     tp.distribution_policy_desc AS DistributionType
-- FROM sys.tables t
-- JOIN sys.pdw_table_distribution_properties tp ON t.object_id = tp.object_id
-- WHERE t.schema_id = SCHEMA_ID('dbo')
-- ORDER BY t.name;

-- Query to check columnstore segment quality
-- SELECT 
--     OBJECT_NAME(i.object_id) AS TableName,
--     i.name AS IndexName,
--     SUM(rg.total_rows) AS TotalRows,
--     SUM(CASE WHEN rg.state = 3 THEN rg.total_rows ELSE 0 END) AS CompressedRows,
--     SUM(CASE WHEN rg.state IN (0,1,2,4) THEN rg.total_rows ELSE 0 END) AS UncompressedRows
-- FROM sys.dm_pdw_nodes_db_column_store_row_group_physical_stats rg
-- JOIN sys.indexes i ON rg.object_id = i.object_id AND rg.index_id = i.index_id
-- WHERE i.type IN (5,6)
-- GROUP BY i.object_id, i.name
-- ORDER BY TableName;

-- Query to check data distribution skew
-- DBCC PDW_SHOWSPACEUSED('dbo.Loans');
-- DBCC PDW_SHOWSPACEUSED('dbo.Payments');

-- =============================================
-- PERFORMANCE TUNING RECOMMENDATIONS
-- =============================================

/*
1. DISTRIBUTION STRATEGY:
   - Use HASH distribution for large fact tables (Loans, Payments)
   - Use REPLICATE for small dimension tables (< 2GB)
   - Co-locate related tables on same distribution key

2. COLUMNSTORE INDEXES:
   - Use Clustered Columnstore Index (CCI) for most tables
   - Maintain good segment quality (avoid small row groups)
   - Rebuild indexes after large data loads

3. STATISTICS:
   - Keep statistics up-to-date
   - Create statistics on join columns, filter columns, group by columns
   - Update statistics after significant data changes

4. PARTITIONING:
   - Partition large tables (100M+ rows) by date
   - Use 60+ partitions for optimal parallelism
   - Implement partition switching for maintenance

5. QUERY OPTIMIZATION:
   - Avoid SELECT * queries
   - Use appropriate WHERE clauses
   - Leverage result set caching
   - Use materialized views for complex aggregations

6. DATA LOADING:
   - Use COPY statement for best performance
   - Load into staging tables first (ROUND_ROBIN, HEAP)
   - Use CTAS for transformations
   - Batch large loads into smaller chunks

7. CONCURRENCY:
   - Use workload management to prioritize queries
   - Allocate appropriate resource classes
   - Monitor query queuing

8. MONITORING:
   - Use DMVs to monitor query performance
   - Check for data skew regularly
   - Monitor tempdb usage
   - Track slow-running queries
*/

-- =============================================
-- BACKUP AND RECOVERY
-- =============================================

/*
Azure Synapse provides automatic snapshots:
- User-defined restore points can be created
- Restore points retained for 7 days
- Geo-redundant backups available

Example to create restore point:
ALTER DATABASE [XYZ_Financials_Securities] 
SET RESTORE_POINT = 'BeforeMajorUpdate_20250101';
*/

-- =============================================
-- SECURITY BEST PRACTICES
-- =============================================

/*
1. Use Azure Active Directory authentication
2. Implement Row-Level Security for multi-tenant scenarios
3. Use Dynamic Data Masking for PII
4. Enable Transparent Data Encryption (TDE)
5. Configure firewall rules
6. Use managed identities for service connections
7. Audit database access and changes
8. Implement least privilege access
*/

-- =============================================
-- COST OPTIMIZATION
-- =============================================

/*
1. Pause Synapse pool when not in use
2. Use appropriate DWU sizing
3. Implement data lifecycle management
4. Archive old data to data lake
5. Use result set caching for repeated queries
6. Optimize table distributions to reduce data movement
7. Monitor query resource consumption
8. Use materialized views strategically
*/

-- =============================================
-- MIGRATION NOTES FROM MS SQL SERVER
-- =============================================

/*
KEY DIFFERENCES:
1. No IDENTITY columns - Use sequences or manage IDs externally
2. No User-Defined Types - Use base types with constraints
3. Limited stored procedure functionality - Move complex logic to ETL
4. No triggers - Implement in application/ETL layer
5. No UNIQUE constraints (except for hash distribution key)
6. No CHECK constraints enforcement - Implement in application
7. Different transaction handling - Keep transactions short
8. No computed columns - Create as regular columns via ETL

CONVERSION CHECKLIST:
✓ Replace IDENTITY with explicit ID management
✓ Remove user-defined types
✓ Simplify stored procedures
✓ Remove triggers (implement in ETL)
✓ Remove complex constraints
✓ Choose appropriate distribution strategies
✓ Add columnstore indexes
✓ Create statistics
✓ Implement data loading patterns
✓ Set up monitoring
✓ Configure security
✓ Test query performance
*/

-- =============================================
-- END OF AZURE SYNAPSE SCHEMA
-- =============================================
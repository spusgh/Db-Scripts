
-- MS SQL Server Business Intelligence / Data Warehouse Schema
-- Star Schema design optimized for analytics and reporting
-- For XYZ_Financials_Securities

CREATE DATABASE [XYZ_Financials_DW];
GO

USE [XYZ_Financials_DW];
GO

-- Enable ColumnStore for analytics workload
ALTER DATABASE [XYZ_Financials_DW] SET COMPATIBILITY_LEVEL = 160;
GO

-- =============================================
-- DIMENSION TABLES
-- =============================================

-- Dim Customer
CREATE TABLE [dbo].[DimCustomer] (
    [CustomerKey] INT IDENTITY(1,1) NOT NULL,
    [CustomerID] INT NOT NULL,
    [FirstName] NVARCHAR(50) NOT NULL,
    [LastName] NVARCHAR(50) NOT NULL,
    [FullName] AS ([FirstName] + ' ' + [LastName]) PERSISTED,
    [SSN] CHAR(11),
    [DateOfBirth] DATE,
    [Age] AS (DATEDIFF(YEAR, [DateOfBirth], GETDATE())) PERSISTED,
    [AgeGroup] AS (
        CASE 
            WHEN DATEDIFF(YEAR, [DateOfBirth], GETDATE()) < 30 THEN 'Under 30'
            WHEN DATEDIFF(YEAR, [DateOfBirth], GETDATE()) BETWEEN 30 AND 39 THEN '30-39'
            WHEN DATEDIFF(YEAR, [DateOfBirth], GETDATE()) BETWEEN 40 AND 49 THEN '40-49'
            WHEN DATEDIFF(YEAR, [DateOfBirth], GETDATE()) BETWEEN 50 AND 59 THEN '50-59'
            ELSE '60+'
        END
    ) PERSISTED,
    [Email] NVARCHAR(100),
    [Phone] NVARCHAR(20),
    [AnnualIncome] DECIMAL(15,2),
    [IncomeRange] AS (
        CASE 
            WHEN [AnnualIncome] < 50000 THEN 'Under 50K'
            WHEN [AnnualIncome] BETWEEN 50000 AND 99999 THEN '50K-100K'
            WHEN [AnnualIncome] BETWEEN 100000 AND 149999 THEN '100K-150K'
            WHEN [AnnualIncome] BETWEEN 150000 AND 199999 THEN '150K-200K'
            ELSE '200K+'
        END
    ) PERSISTED,
    [EmploymentStatus] NVARCHAR(50),
    [Employer] NVARCHAR(100),
    [YearsEmployed] INT,
    [CreditScore] INT,
    [CreditScoreRange] AS (
        CASE 
            WHEN [CreditScore] < 580 THEN 'Poor (< 580)'
            WHEN [CreditScore] BETWEEN 580 AND 669 THEN 'Fair (580-669)'
            WHEN [CreditScore] BETWEEN 670 AND 739 THEN 'Good (670-739)'
            WHEN [CreditScore] BETWEEN 740 AND 799 THEN 'Very Good (740-799)'
            WHEN [CreditScore] >= 800 THEN 'Excellent (800+)'
            ELSE 'Unknown'
        END
    ) PERSISTED,
    -- SCD Type 2 fields
    [EffectiveDate] DATE NOT NULL DEFAULT GETDATE(),
    [EndDate] DATE,
    [IsCurrent] BIT NOT NULL DEFAULT 1,
    -- Metadata
    [SourceSystem] NVARCHAR(50) DEFAULT 'OLTP',
    [CreatedDate] DATETIME2 DEFAULT GETDATE(),
    [ModifiedDate] DATETIME2 DEFAULT GETDATE(),
    CONSTRAINT [PK_DimCustomer] PRIMARY KEY CLUSTERED ([CustomerKey]),
    INDEX [IX_DimCustomer_CustomerID] NONCLUSTERED ([CustomerID])
);
GO

-- Dim Product
CREATE TABLE [dbo].[DimProduct] (
    [ProductKey] INT IDENTITY(1,1) NOT NULL,
    [ProductID] INT NOT NULL,
    [ProductName] NVARCHAR(100) NOT NULL,
    [ProductType] NVARCHAR(50) NOT NULL,
    [Term] INT NOT NULL,
    [TermDescription] AS (CAST([Term] AS NVARCHAR(10)) + ' Year Fixed') PERSISTED,
    [BaseInterestRate] DECIMAL(5,3),
    [MinCreditScore] INT,
    [MaxLTV] DECIMAL(5,2),
    [MinLoanAmount] DECIMAL(15,2),
    [MaxLoanAmount] DECIMAL(15,2),
    [OriginationFee] DECIMAL(5,2),
    [IsActive] BIT,
    -- Metadata
    [EffectiveDate] DATE NOT NULL DEFAULT GETDATE(),
    [EndDate] DATE,
    [IsCurrent] BIT NOT NULL DEFAULT 1,
    [SourceSystem] NVARCHAR(50) DEFAULT 'OLTP',
    [CreatedDate] DATETIME2 DEFAULT GETDATE(),
    CONSTRAINT [PK_DimProduct] PRIMARY KEY CLUSTERED ([ProductKey]),
    INDEX [IX_DimProduct_ProductID] NONCLUSTERED ([ProductID])
);
GO

-- Dim Property
CREATE TABLE [dbo].[DimProperty] (
    [PropertyKey] INT IDENTITY(1,1) NOT NULL,
    [PropertyID] INT NOT NULL,
    [AddressLine1] NVARCHAR(100),
    [City] NVARCHAR(50),
    [State] CHAR(2),
    [ZipCode] NVARCHAR(10),
    [FullAddress] AS ([AddressLine1] + ', ' + [City] + ', ' + [State] + ' ' + [ZipCode]) PERSISTED,
    [PropertyType] NVARCHAR(50),
    [YearBuilt] INT,
    [PropertyAge] AS (YEAR(GETDATE()) - [YearBuilt]) PERSISTED,
    [SquareFeet] INT,
    [Bedrooms] INT,
    [Bathrooms] DECIMAL(3,1),
    [CurrentValue] DECIMAL(15,2),
    [ValuePerSqFt] AS ([CurrentValue] / NULLIF([SquareFeet], 0)) PERSISTED,
    [FloodZone] NVARCHAR(10),
    [IsInFloodZone] AS (
        CASE WHEN [FloodZone] IN ('A', 'AE', 'AH', 'AO', 'V', 'VE') THEN 1 ELSE 0 END
    ) PERSISTED,
    [Latitude] DECIMAL(9,6),
    [Longitude] DECIMAL(9,6),
    -- Metadata
    [EffectiveDate] DATE NOT NULL DEFAULT GETDATE(),
    [EndDate] DATE,
    [IsCurrent] BIT NOT NULL DEFAULT 1,
    [SourceSystem] NVARCHAR(50) DEFAULT 'OLTP',
    [CreatedDate] DATETIME2 DEFAULT GETDATE(),
    CONSTRAINT [PK_DimProperty] PRIMARY KEY CLUSTERED ([PropertyKey]),
    INDEX [IX_DimProperty_PropertyID] NONCLUSTERED ([PropertyID]),
    INDEX [IX_DimProperty_State] NONCLUSTERED ([State])
);
GO

-- Dim Loan Officer
CREATE TABLE [dbo].[DimLoanOfficer] (
    [OfficerKey] INT IDENTITY(1,1) NOT NULL,
    [OfficerID] INT NOT NULL,
    [FirstName] NVARCHAR(50),
    [LastName] NVARCHAR(50),
    [FullName] AS ([FirstName] + ' ' + [LastName]) PERSISTED,
    [Email] NVARCHAR(100),
    [BranchID] INT,
    [HireDate] DATE,
    [YearsOfService] AS (DATEDIFF(YEAR, [HireDate], GETDATE())) PERSISTED,
    [CommissionRate] DECIMAL(5,2),
    [Status] NVARCHAR(20),
    -- Metadata
    [EffectiveDate] DATE NOT NULL DEFAULT GETDATE(),
    [EndDate] DATE,
    [IsCurrent] BIT NOT NULL DEFAULT 1,
    [SourceSystem] NVARCHAR(50) DEFAULT 'OLTP',
    [CreatedDate] DATETIME2 DEFAULT GETDATE(),
    CONSTRAINT [PK_DimLoanOfficer] PRIMARY KEY CLUSTERED ([OfficerKey]),
    INDEX [IX_DimLoanOfficer_OfficerID] NONCLUSTERED ([OfficerID])
);
GO

-- Dim Date (standard date dimension)
CREATE TABLE [dbo].[DimDate] (
    [DateKey] INT NOT NULL,
    [Date] DATE NOT NULL,
    [Day] TINYINT NOT NULL,
    [DayOfWeek] TINYINT NOT NULL,
    [DayName] NVARCHAR(10) NOT NULL,
    [DayOfYear] SMALLINT NOT NULL,
    [WeekOfYear] TINYINT NOT NULL,
    [Month] TINYINT NOT NULL,
    [MonthName] NVARCHAR(10) NOT NULL,
    [MonthYear] NVARCHAR(7) NOT NULL,
    [Quarter] TINYINT NOT NULL,
    [QuarterName] NVARCHAR(2) NOT NULL,
    [Year] SMALLINT NOT NULL,
    [IsWeekend] BIT NOT NULL,
    [IsHoliday] BIT NOT NULL,
    [FiscalYear] SMALLINT NOT NULL,
    [FiscalQuarter] TINYINT NOT NULL,
    CONSTRAINT [PK_DimDate] PRIMARY KEY CLUSTERED ([DateKey])
);
GO

-- Populate DimDate (example for 10 years)
DECLARE @StartDate DATE = '2015-01-01';
DECLARE @EndDate DATE = '2035-12-31';

WITH DateSequence AS (
    SELECT @StartDate AS [Date]
    UNION ALL
    SELECT DATEADD(DAY, 1, [Date])
    FROM DateSequence
    WHERE DATEADD(DAY, 1, [Date]) <= @EndDate
)
INSERT INTO [dbo].[DimDate] (
    [DateKey], [Date], [Day], [DayOfWeek], [DayName], [DayOfYear],
    [WeekOfYear], [Month], [MonthName], [MonthYear], [Quarter], 
    [QuarterName], [Year], [IsWeekend], [IsHoliday], [FiscalYear], [FiscalQuarter]
)
SELECT 
    CAST(FORMAT([Date], 'yyyyMMdd') AS INT),
    [Date],
    DAY([Date]),
    DATEPART(WEEKDAY, [Date]),
    DATENAME(WEEKDAY, [Date]),
    DATEPART(DAYOFYEAR, [Date]),
    DATEPART(WEEK, [Date]),
    MONTH([Date]),
    DATENAME(MONTH, [Date]),
    FORMAT([Date], 'yyyy-MM'),
    DATEPART(QUARTER, [Date]),
    'Q' + CAST(DATEPART(QUARTER, [Date]) AS NVARCHAR(1)),
    YEAR([Date]),
    CASE WHEN DATEPART(WEEKDAY, [Date]) IN (1, 7) THEN 1 ELSE 0 END,
    0, -- Holiday flag (can be updated based on business rules)
    CASE WHEN MONTH([Date]) >= 10 THEN YEAR([Date]) + 1 ELSE YEAR([Date]) END,
    CASE WHEN MONTH([Date]) >= 10 THEN DATEPART(QUARTER, DATEADD(MONTH, -9, [Date])) 
         ELSE DATEPART(QUARTER, DATEADD(MONTH, 3, [Date])) END
FROM DateSequence
OPTION (MAXRECURSION 0);
GO

-- =============================================
-- FACT TABLES
-- =============================================

-- Fact Loan
CREATE TABLE [dbo].[FactLoan] (
    [LoanKey] BIGINT IDENTITY(1,1) NOT NULL,
    [LoanID] INT NOT NULL,
    -- Dimension Keys
    [CustomerKey] INT NOT NULL,
    [ProductKey] INT NOT NULL,
    [PropertyKey] INT NOT NULL,
    [OfficerKey] INT NOT NULL,
    [OriginationDateKey] INT NOT NULL,
    [MaturityDateKey] INT NOT NULL,
    [FirstPaymentDateKey] INT NOT NULL,
    -- Measures
    [LoanAmount] DECIMAL(15,2) NOT NULL,
    [InterestRate] DECIMAL(5,3) NOT NULL,
    [Term] INT NOT NULL,
    [MonthlyPayment] DECIMAL(12,2) NOT NULL,
    [RemainingBalance] DECIMAL(15,2) NOT NULL,
    [OriginalLTV] DECIMAL(5,2),
    [CurrentLTV] AS ([RemainingBalance] / NULLIF([PropertyCurrentValue], 0) * 100) PERSISTED,
    [PropertyCurrentValue] DECIMAL(15,2),
    [TotalInterestPaid] DECIMAL(15,2),
    [TotalPrincipalPaid] AS ([LoanAmount] - [RemainingBalance]) PERSISTED,
    [PaymentsMade] INT DEFAULT 0,
    [PaymentsRemaining] AS ([Term] - [PaymentsMade]) PERSISTED,
    [DaysPastDue] INT DEFAULT 0,
    [Status] NVARCHAR(20),
    [EscrowRequired] BIT,
    [PMIRequired] BIT,
    [PMIAmount] DECIMAL(10,2),
    -- Calculated Metrics
    [PercentPaid] AS (([LoanAmount] - [RemainingBalance]) / NULLIF([LoanAmount], 0) * 100) PERSISTED,
    [LoanAgeMonths] AS (DATEDIFF(MONTH, [OriginationDateKey], GETDATE())) PERSISTED,
    -- Risk Indicators
    [IsDelinquent] AS (CASE WHEN [DaysPastDue] > 30 THEN 1 ELSE 0 END) PERSISTED,
    [DelinquencyBucket] AS (
        CASE 
            WHEN [DaysPastDue] = 0 THEN 'Current'
            WHEN [DaysPastDue] BETWEEN 1 AND 30 THEN '1-30 Days'
            WHEN [DaysPastDue] BETWEEN 31 AND 60 THEN '31-60 Days'
            WHEN [DaysPastDue] BETWEEN 61 AND 90 THEN '61-90 Days'
            WHEN [DaysPastDue] > 90 THEN '90+ Days'
        END
    ) PERSISTED,
    -- Metadata
    [SourceSystem] NVARCHAR(50) DEFAULT 'OLTP',
    [CreatedDate] DATETIME2 DEFAULT GETDATE(),
    [ModifiedDate] DATETIME2 DEFAULT GETDATE(),
    CONSTRAINT [PK_FactLoan] PRIMARY KEY CLUSTERED ([LoanKey]),
    CONSTRAINT [FK_FactLoan_DimCustomer] FOREIGN KEY ([CustomerKey]) REFERENCES [dbo].[DimCustomer]([CustomerKey]),
    CONSTRAINT [FK_FactLoan_DimProduct] FOREIGN KEY ([ProductKey]) REFERENCES [dbo].[DimProduct]([ProductKey]),
    CONSTRAINT [FK_FactLoan_DimProperty] FOREIGN KEY ([PropertyKey]) REFERENCES [dbo].[DimProperty]([PropertyKey]),
    CONSTRAINT [FK_FactLoan_DimLoanOfficer] FOREIGN KEY ([OfficerKey]) REFERENCES [dbo].[DimLoanOfficer]([OfficerKey]),
    CONSTRAINT [FK_FactLoan_DimDate_Origination] FOREIGN KEY ([OriginationDateKey]) REFERENCES [dbo].[DimDate]([DateKey])
);

CREATE NONCLUSTERED INDEX [IX_FactLoan_CustomerKey] ON [dbo].[FactLoan]([CustomerKey]);
CREATE NONCLUSTERED INDEX [IX_FactLoan_OriginationDate] ON [dbo].[FactLoan]([OriginationDateKey]);
CREATE NONCLUSTERED INDEX [IX_FactLoan_Status] ON [dbo].[FactLoan]([Status]);
GO

-- Fact Payment (Transaction Fact)
CREATE TABLE [dbo].[FactPayment] (
    [PaymentKey] BIGINT IDENTITY(1,1) NOT NULL,
    [PaymentID] INT NOT NULL,
    [LoanID] INT NOT NULL,
    -- Dimension Keys
    [LoanKey] BIGINT NOT NULL,
    [PaymentDateKey] INT NOT NULL,
    [ProcessedDateKey] INT,
    -- Measures
    [PaymentAmount] DECIMAL(12,2) NOT NULL,
    [PrincipalAmount] DECIMAL(12,2) NOT NULL,
    [InterestAmount] DECIMAL(12,2) NOT NULL,
    [EscrowAmount] DECIMAL(12,2),
    [LateFeeAmount] DECIMAL(10,2),
    [TotalAmount] AS ([PaymentAmount] + [LateFeeAmount]) PERSISTED,
    -- Attributes
    [PaymentMethod] NVARCHAR(50),
    [PaymentStatus] NVARCHAR(20),
    [IsLatePayment] AS (CASE WHEN [LateFeeAmount] > 0 THEN 1 ELSE 0 END) PERSISTED,
    -- Metadata
    [SourceSystem] NVARCHAR(50) DEFAULT 'OLTP',
    [CreatedDate] DATETIME2 DEFAULT GETDATE(),
    CONSTRAINT [PK_FactPayment] PRIMARY KEY CLUSTERED ([PaymentKey]),
    CONSTRAINT [FK_FactPayment_FactLoan] FOREIGN KEY ([LoanKey]) REFERENCES [dbo].[FactLoan]([LoanKey]),
    CONSTRAINT [FK_FactPayment_DimDate_Payment] FOREIGN KEY ([PaymentDateKey]) REFERENCES [dbo].[DimDate]([DateKey])
);

CREATE NONCLUSTERED COLUMNSTORE INDEX [NCCI_FactPayment] ON [dbo].[FactPayment]
(
    [PaymentDateKey], [LoanKey], [PaymentAmount], [PrincipalAmount], 
    [InterestAmount], [PaymentStatus]
);
GO

-- Fact Application (Accumulating Snapshot)
CREATE TABLE [dbo].[FactApplication] (
    [ApplicationKey] BIGINT IDENTITY(1,1) NOT NULL,
    [ApplicationID] INT NOT NULL,
    -- Dimension Keys
    [CustomerKey] INT NOT NULL,
    [ProductKey] INT NOT NULL,
    [OfficerKey] INT NOT NULL,
    [ApplicationDateKey] INT NOT NULL,
    [ApprovalDateKey] INT,
    [ClosingDateKey] INT,
    [FirstPaymentDateKey] INT,
    -- Measures
    [LoanAmount] DECIMAL(15,2) NOT NULL,
    [PropertyValue] DECIMAL(15,2),
    [DTI] DECIMAL(5,2),
    [LTV] DECIMAL(5,2),
    [CreditScore] INT,
    [ApplicationFee] DECIMAL(10,2),
    -- Duration Metrics (in days)
    [DaysToApproval] AS (DATEDIFF(DAY, [ApplicationDateKey], [ApprovalDateKey])),
    [DaysToClosing] AS (DATEDIFF(DAY, [ApplicationDateKey], [ClosingDateKey])),
    [DaysApprovalToClosing] AS (DATEDIFF(DAY, [ApprovalDateKey], [ClosingDateKey])),
    -- Status
    [Status] NVARCHAR(50),
    [IsApproved] AS (CASE WHEN [Status] = 'Approved' THEN 1 ELSE 0 END) PERSISTED,
    [IsDenied] AS (CASE WHEN [Status] = 'Denied' THEN 1 ELSE 0 END) PERSISTED,
    [DenialReason] NVARCHAR(255),
    -- Metadata
    [SourceSystem] NVARCHAR(50) DEFAULT 'OLTP',
    [CreatedDate] DATETIME2 DEFAULT GETDATE(),
    [ModifiedDate] DATETIME2 DEFAULT GETDATE(),
    CONSTRAINT [PK_FactApplication] PRIMARY KEY CLUSTERED ([ApplicationKey]),
    CONSTRAINT [FK_FactApplication_DimCustomer] FOREIGN KEY ([CustomerKey]) REFERENCES [dbo].[DimCustomer]([CustomerKey]),
    CONSTRAINT [FK_FactApplication_DimProduct] FOREIGN KEY ([ProductKey]) REFERENCES [dbo].[DimProduct]([ProductKey]),
    CONSTRAINT [FK_FactApplication_DimLoanOfficer] FOREIGN KEY ([OfficerKey]) REFERENCES [dbo].[DimLoanOfficer]([OfficerKey]),
    CONSTRAINT [FK_FactApplication_DimDate_Application] FOREIGN KEY ([ApplicationDateKey]) REFERENCES [dbo].[DimDate]([DateKey])
);

CREATE NONCLUSTERED INDEX [IX_FactApplication_Status] ON [dbo].[FactApplication]([Status]);
CREATE NONCLUSTERED INDEX [IX_FactApplication_ApplicationDate] ON [dbo].[FactApplication]([ApplicationDateKey]);
GO

-- =============================================
-- ANALYTICAL VIEWS
-- =============================================

-- Loan Portfolio Summary View
CREATE VIEW [dbo].[vw_LoanPortfolioAnalysis] AS
SELECT 
    d.Year,
    d.Quarter,
    d.MonthYear,
    c.FullName AS CustomerName,
    c.AgeGroup,
    c.IncomeRange,
    c.CreditScoreRange,
    p.State,
    p.PropertyType,
    pr.ProductName,
    pr.ProductType,
    o.FullName AS LoanOfficerName,
    l.Status,
    l.DelinquencyBucket,
    COUNT(l.LoanKey) AS LoanCount,
    SUM(l.LoanAmount) AS TotalLoanAmount,
    AVG(l.LoanAmount) AS AvgLoanAmount,
    SUM(l.RemainingBalance) AS TotalRemainingBalance,
    AVG(l.InterestRate) AS AvgInterestRate,
    AVG(l.OriginalLTV) AS AvgLTV,
    SUM(CASE WHEN l.IsDelinquent = 1 THEN 1 ELSE 0 END) AS DelinquentLoans,
    SUM(l.TotalInterestPaid) AS TotalInterestRevenue
FROM [dbo].[FactLoan] l
JOIN [dbo].[DimCustomer] c ON l.CustomerKey = c.CustomerKey
JOIN [dbo].[DimProduct] pr ON l.ProductKey = pr.ProductKey
JOIN [dbo].[DimProperty] p ON l.PropertyKey = p.PropertyKey
JOIN [dbo].[DimLoanOfficer] o ON l.OfficerKey = o.OfficerKey
JOIN [dbo].[DimDate] d ON l.OriginationDateKey = d.DateKey
WHERE c.IsCurrent = 1 
    AND pr.IsCurrent = 1 
    AND p.IsCurrent = 1 
    AND o.IsCurrent = 1
GROUP BY 
    d.Year, d.Quarter, d.MonthYear, c.FullName, c.AgeGroup, c.IncomeRange, 
    c.CreditScoreRange, p.State, p.PropertyType, pr.ProductName, pr.ProductType, 
    o.FullName, l.Status, l.DelinquencyBucket;
GO

-- Payment Analysis View
CREATE VIEW [dbo].[vw_PaymentAnalysis] AS
SELECT 
    d.Year,
    d.MonthYear,
    l.Status AS LoanStatus,
    COUNT(p.PaymentKey) AS PaymentCount,
    SUM(p.PaymentAmount) AS TotalPaymentAmount,
    SUM(p.PrincipalAmount) AS TotalPrincipalAmount,
    SUM(p.InterestAmount) AS TotalInterestAmount,
    SUM(p.EscrowAmount) AS TotalEscrowAmount,
    SUM(p.LateFeeAmount) AS TotalLateFees,
    AVG(p.PaymentAmount) AS AvgPaymentAmount,
    SUM(CASE WHEN p.IsLatePayment = 1 THEN 1 ELSE 0 END) AS LatePaymentCount,
    CAST(SUM(CASE WHEN p.IsLatePayment = 1 THEN 1 ELSE 0 END) AS FLOAT) / 
        NULLIF(COUNT(p.PaymentKey), 0) * 100 AS LatePaymentRate
FROM [dbo].[FactPayment] p
JOIN [dbo].[DimDate] d ON p.PaymentDateKey = d.DateKey
JOIN [dbo].[FactLoan] l ON p.LoanKey = l.LoanKey
GROUP BY d.Year, d.MonthYear, l.Status;
GO

-- Application Funnel View
CREATE VIEW [dbo].[vw_ApplicationFunnel] AS
SELECT 
    d.Year,
    d.MonthYear,
    o.FullName AS LoanOfficerName,
    COUNT(a.ApplicationKey) AS TotalApplications,
    SUM(a.IsApproved) AS ApprovedApplications,
    SUM(a.IsDenied) AS DeniedApplications,
    CAST(SUM(a.IsApproved) AS FLOAT) / NULLIF(COUNT(a.ApplicationKey), 0) * 100 AS ApprovalRate,
    AVG(a.DaysToApproval) AS AvgDaysToApproval,
    AVG(a.DaysToClosing) AS AvgDaysToClosing,
    SUM(a.LoanAmount) AS TotalLoanVolume,
    AVG(a.DTI) AS AvgDTI,
    AVG(a.LTV) AS AvgLTV,
    AVG(a.CreditScore) AS AvgCreditScore
FROM [dbo].[FactApplication] a
JOIN [dbo].[DimDate] d ON a.ApplicationDateKey = d.DateKey
JOIN [dbo].[DimLoanOfficer] o ON a.OfficerKey = o.OfficerKey
WHERE o.IsCurrent = 1
GROUP BY d.Year, d.MonthYear, o.FullName;
GO

-- Create ColumnStore indexes on Fact tables for analytics
CREATE NONCLUSTERED COLUMNSTORE INDEX [NCCI_FactLoan] ON [dbo].[FactLoan]
(
    [CustomerKey], [ProductKey], [PropertyKey], [OfficerKey], [OriginationDateKey],
    [LoanAmount], [InterestRate], [RemainingBalance], [Status], [DaysPastDue]
);
GO

CREATE NONCLUSTERED COLUMNSTORE INDEX [NCCI_FactApplication] ON [dbo].[FactApplication]
(
    [CustomerKey], [ProductKey], [OfficerKey], [ApplicationDateKey],
    [LoanAmount], [Status], [DTI], [LTV], [CreditScore]
);
GO
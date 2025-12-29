
-- Azure SQL Database Schema for XYZ_Financials_Securities
-- Identical syntax to SQL Server but with Azure-specific optimizations

CREATE DATABASE [XYZ_Financials_Securities];
GO

USE [XYZ_Financials_Securities];
GO

-- Enable Query Store for performance insights
ALTER DATABASE [XYZ_Financials_Securities] SET QUERY_STORE = ON;
GO

-- Create Database Roles
CREATE ROLE [Role_Underwriter];
CREATE ROLE [Role_LoanOfficer];
CREATE ROLE [Role_CustomerService];
CREATE ROLE [Role_Compliance];
GO

-- Create User-Defined Types
CREATE TYPE [dbo].[InterestRateType] FROM VARCHAR(15) NOT NULL;
CREATE TYPE [dbo].[LoanStatus] FROM VARCHAR(20) NOT NULL;
CREATE TYPE [dbo].[MoneyAmount] FROM DECIMAL(18, 2) NOT NULL;
CREATE TYPE [dbo].[RiskGrade] FROM CHAR(2) NOT NULL;
GO

-- Create Sequences
CREATE SEQUENCE [dbo].[seq_DocumentRegistry]
    AS BIGINT
    START WITH 1
    INCREMENT BY 1
    MINVALUE 1
    MAXVALUE 2147483647
    CACHE 25;
GO

CREATE SEQUENCE [dbo].[seq_LoanNumber]
    AS BIGINT
    START WITH 100000
    INCREMENT BY 1
    MINVALUE 100000
    MAXVALUE 999999999
    CACHE 50;
GO

CREATE SEQUENCE [dbo].[seq_PaymentReference]
    AS BIGINT
    START WITH 1000000
    INCREMENT BY 1
    MINVALUE 1000000
    MAXVALUE 9999999999
    CACHE 100;
GO

-- Customers Table
CREATE TABLE [dbo].[Customers] (
    [CustomerID] INT IDENTITY(1000,1) NOT NULL,
    [FirstName] NVARCHAR(50) NOT NULL,
    [LastName] NVARCHAR(50) NOT NULL,
    [SSN] CHAR(11) NOT NULL,
    [DateOfBirth] DATE NOT NULL,
    [Email] NVARCHAR(100),
    [Phone] NVARCHAR(20),
    [AnnualIncome] DECIMAL(15,2),
    [EmploymentStatus] NVARCHAR(50),
    [Employer] NVARCHAR(100),
    [YearsEmployed] INT,
    [CreditScore] INT,
    [CreatedDate] DATETIME2 DEFAULT GETDATE(),
    [LastUpdatedDate] DATETIME2 DEFAULT GETDATE(),
    CONSTRAINT [PK_Customers] PRIMARY KEY CLUSTERED ([CustomerID]),
    CONSTRAINT [UQ_Customers_SSN] UNIQUE ([SSN])
);
GO

CREATE NONCLUSTERED INDEX [IX_Customers_LastName] ON [dbo].[Customers]([LastName]);
CREATE NONCLUSTERED INDEX [IX_Customers_CreditScore] ON [dbo].[Customers]([CreditScore]);
GO

-- Mortgage Products Table
CREATE TABLE [dbo].[MortgageProducts] (
    [ProductID] INT IDENTITY(1,1) NOT NULL,
    [ProductName] NVARCHAR(100) NOT NULL,
    [ProductType] NVARCHAR(50) NOT NULL,
    [Term] INT NOT NULL,
    [BaseInterestRate] DECIMAL(5,3) NOT NULL,
    [MinCreditScore] INT NOT NULL,
    [MaxLTV] DECIMAL(5,2) NOT NULL,
    [MinLoanAmount] DECIMAL(15,2) NOT NULL,
    [MaxLoanAmount] DECIMAL(15,2) NOT NULL,
    [OriginationFee] DECIMAL(5,2) DEFAULT 0,
    [IsActive] BIT DEFAULT 1,
    CONSTRAINT [PK_MortgageProducts] PRIMARY KEY CLUSTERED ([ProductID]),
    CONSTRAINT [UQ_MortgageProducts_ProductName] UNIQUE ([ProductName])
);
GO

-- Property Details Table
CREATE TABLE [dbo].[PropertyDetails] (
    [PropertyID] INT IDENTITY(1,1) NOT NULL,
    [AddressLine1] NVARCHAR(100) NOT NULL,
    [AddressLine2] NVARCHAR(100),
    [City] NVARCHAR(50) NOT NULL,
    [State] CHAR(2) NOT NULL,
    [ZipCode] NVARCHAR(10) NOT NULL,
    [Country] NVARCHAR(50) DEFAULT 'USA',
    [PropertyType] NVARCHAR(50) NOT NULL,
    [YearBuilt] INT,
    [SquareFeet] INT,
    [Bedrooms] INT,
    [Bathrooms] DECIMAL(3,1),
    [PurchasePrice] DECIMAL(15,2),
    [CurrentValue] DECIMAL(15,2),
    [LastAppraisalDate] DATE,
    [LastAppraisalValue] DECIMAL(15,2),
    [TaxAssessmentValue] DECIMAL(15,2),
    [AnnualTaxAmount] DECIMAL(10,2),
    [HOAFees] DECIMAL(10,2) DEFAULT 0,
    [FloodZone] NVARCHAR(10),
    [PropertyTaxID] NVARCHAR(50),
    [Latitude] DECIMAL(9,6),
    [Longitude] DECIMAL(9,6),
    CONSTRAINT [PK_PropertyDetails] PRIMARY KEY CLUSTERED ([PropertyID])
);
GO

CREATE NONCLUSTERED INDEX [IX_PropertyDetails_State] ON [dbo].[PropertyDetails]([State]);
CREATE NONCLUSTERED INDEX [IX_PropertyDetails_ZipCode] ON [dbo].[PropertyDetails]([ZipCode]);
CREATE NONCLUSTERED INDEX [IX_PropertyDetails_PropertyType] ON [dbo].[PropertyDetails]([PropertyType]);
GO

-- Loan Officers Table
CREATE TABLE [dbo].[LoanOfficers] (
    [OfficerID] INT IDENTITY(1,1) NOT NULL,
    [FirstName] NVARCHAR(50) NOT NULL,
    [LastName] NVARCHAR(50) NOT NULL,
    [Email] NVARCHAR(100) NOT NULL,
    [Phone] NVARCHAR(20) NOT NULL,
    [BranchID] INT,
    [HireDate] DATE NOT NULL,
    [CommissionRate] DECIMAL(5,2) DEFAULT 0,
    [Status] NVARCHAR(20) DEFAULT 'Active',
    CONSTRAINT [PK_LoanOfficers] PRIMARY KEY CLUSTERED ([OfficerID]),
    CONSTRAINT [UQ_LoanOfficers_Email] UNIQUE ([Email])
);
GO

-- Applications Table
CREATE TABLE [dbo].[Applications] (
    [ApplicationID] INT IDENTITY(10000,1) NOT NULL,
    [CustomerID] INT NOT NULL,
    [ProductID] INT NOT NULL,
    [OfficerID] INT NOT NULL,
    [ApplicationDate] DATETIME2 DEFAULT GETDATE(),
    [LoanAmount] DECIMAL(15,2) NOT NULL,
    [LoanPurpose] NVARCHAR(50) NOT NULL,
    [Status] NVARCHAR(50) DEFAULT 'Submitted',
    [ClosingDate] DATE,
    [ApplicationFee] DECIMAL(10,2),
    [DTI] DECIMAL(5,2),
    [PropertyValue] DECIMAL(15,2),
    [LTV] DECIMAL(5,2),
    [RateOffered] DECIMAL(5,3),
    [TermOffered] INT,
    [DenialReason] NVARCHAR(255),
    CONSTRAINT [PK_Applications] PRIMARY KEY CLUSTERED ([ApplicationID]),
    CONSTRAINT [FK_Applications_Customers] FOREIGN KEY ([CustomerID]) REFERENCES [dbo].[Customers]([CustomerID]),
    CONSTRAINT [FK_Applications_MortgageProducts] FOREIGN KEY ([ProductID]) REFERENCES [dbo].[MortgageProducts]([ProductID]),
    CONSTRAINT [FK_Applications_LoanOfficers] FOREIGN KEY ([OfficerID]) REFERENCES [dbo].[LoanOfficers]([OfficerID])
);
GO

CREATE NONCLUSTERED INDEX [IX_Applications_CustomerID] ON [dbo].[Applications]([CustomerID]);
CREATE NONCLUSTERED INDEX [IX_Applications_ApplicationDate] ON [dbo].[Applications]([ApplicationDate]);
CREATE NONCLUSTERED INDEX [IX_Applications_Status] ON [dbo].[Applications]([Status]);
GO

-- Securities Table
CREATE TABLE [dbo].[Securities] (
    [SecurityID] INT IDENTITY(1,1) NOT NULL,
    [SecurityName] NVARCHAR(100) NOT NULL,
    [SecurityType] NVARCHAR(50) NOT NULL,
    [CUSIP] NVARCHAR(9),
    [IssueDate] DATE NOT NULL,
    [MaturityDate] DATE NOT NULL,
    [CouponRate] DECIMAL(5,3) NOT NULL,
    [FaceValue] DECIMAL(15,2) NOT NULL,
    [CurrentBalance] DECIMAL(15,2) NOT NULL,
    [Issuer] NVARCHAR(100) NOT NULL,
    [Rating] NVARCHAR(10),
    [Status] NVARCHAR(20) DEFAULT 'Active',
    [LastTradeDate] DATE,
    [LastTradePrice] DECIMAL(10,3),
    CONSTRAINT [PK_Securities] PRIMARY KEY CLUSTERED ([SecurityID])
);
GO

-- Loans Table
CREATE TABLE [dbo].[Loans] (
    [LoanID] INT IDENTITY(100000,1) NOT NULL,
    [ApplicationID] INT NOT NULL,
    [CustomerID] INT NOT NULL,
    [PropertyID] INT NOT NULL,
    [ProductID] INT NOT NULL,
    [LoanAmount] DECIMAL(15,2) NOT NULL,
    [InterestRate] DECIMAL(5,3) NOT NULL,
    [Term] INT NOT NULL,
    [OriginationDate] DATE NOT NULL,
    [MaturityDate] DATE NOT NULL,
    [MonthlyPayment] DECIMAL(12,2) NOT NULL,
    [RemainingBalance] DECIMAL(15,2) NOT NULL,
    [Status] NVARCHAR(20) DEFAULT 'Active',
    [EscrowRequired] BIT DEFAULT 1,
    [PMIRequired] BIT DEFAULT 0,
    [PMIAmount] DECIMAL(10,2) DEFAULT 0,
    [FirstPaymentDate] DATE NOT NULL,
    [NextPaymentDate] DATE,
    [PaymentFrequency] NVARCHAR(20) DEFAULT 'Monthly',
    [SecurityID] INT,
    [LastUpdatedDate] DATE,
    CONSTRAINT [PK_Loans] PRIMARY KEY CLUSTERED ([LoanID]),
    CONSTRAINT [FK_Loans_Applications] FOREIGN KEY ([ApplicationID]) REFERENCES [dbo].[Applications]([ApplicationID]),
    CONSTRAINT [FK_Loans_Customers] FOREIGN KEY ([CustomerID]) REFERENCES [dbo].[Customers]([CustomerID]),
    CONSTRAINT [FK_Loans_PropertyDetails] FOREIGN KEY ([PropertyID]) REFERENCES [dbo].[PropertyDetails]([PropertyID]),
    CONSTRAINT [FK_Loans_MortgageProducts] FOREIGN KEY ([ProductID]) REFERENCES [dbo].[MortgageProducts]([ProductID]),
    CONSTRAINT [FK_Loans_Securities] FOREIGN KEY ([SecurityID]) REFERENCES [dbo].[Securities]([SecurityID]),
    CONSTRAINT [CK_Loans_LoanAmount_Positive] CHECK ([LoanAmount] > 0),
    CONSTRAINT [CK_Loans_InterestRate_Range] CHECK ([InterestRate] >= 0 AND [InterestRate] <= 50)
);
GO

CREATE NONCLUSTERED INDEX [IX_Loans_CustomerID] ON [dbo].[Loans]([CustomerID]);
CREATE NONCLUSTERED INDEX [IX_Loans_PropertyID] ON [dbo].[Loans]([PropertyID]);
CREATE NONCLUSTERED INDEX [IX_Loans_OriginationDate] ON [dbo].[Loans]([OriginationDate]);
CREATE NONCLUSTERED INDEX [IX_Loans_Status] ON [dbo].[Loans]([Status]);
CREATE NONCLUSTERED INDEX [IX_Loans_SecurityID] ON [dbo].[Loans]([SecurityID]);
GO

-- Payments Table
CREATE TABLE [dbo].[Payments] (
    [PaymentID] INT IDENTITY(1,1) NOT NULL,
    [LoanID] INT NOT NULL,
    [PaymentDate] DATE NOT NULL,
    [PaymentAmount] DECIMAL(12,2) NOT NULL,
    [PrincipalAmount] DECIMAL(12,2) NOT NULL,
    [InterestAmount] DECIMAL(12,2) NOT NULL,
    [EscrowAmount] DECIMAL(12,2) DEFAULT 0,
    [LateFeeAmount] DECIMAL(10,2) DEFAULT 0,
    [PaymentMethod] NVARCHAR(50),
    [TransactionID] NVARCHAR(100),
    [PaymentStatus] NVARCHAR(20) DEFAULT 'Processed',
    [ProcessedDate] DATETIME2,
    CONSTRAINT [PK_Payments] PRIMARY KEY CLUSTERED ([PaymentID]),
    CONSTRAINT [FK_Payments_Loans] FOREIGN KEY ([LoanID]) REFERENCES [dbo].[Loans]([LoanID]),
    CONSTRAINT [CK_Payments_Amount_Valid] CHECK ([PaymentAmount] > 0 AND [PrincipalAmount] >= 0 AND [InterestAmount] >= 0)
);
GO

CREATE NONCLUSTERED INDEX [IX_Payments_LoanID] ON [dbo].[Payments]([LoanID]);
CREATE NONCLUSTERED INDEX [IX_Payments_PaymentDate] ON [dbo].[Payments]([PaymentDate]);
CREATE NONCLUSTERED INDEX [IX_Payments_LoanID_Date] ON [dbo].[Payments]([LoanID], [PaymentDate] DESC) 
    INCLUDE ([PaymentAmount], [PrincipalAmount], [InterestAmount]);
GO

-- Remaining tables follow same pattern as SQL Server...
-- (Escrow, Defaults, Servicing Rights, Customer Addresses, Documents, Risk, Modifications, etc.)

-- Enable automatic tuning features in Azure SQL
ALTER DATABASE [XYZ_Financials_Securities] SET AUTOMATIC_TUNING (FORCE_LAST_GOOD_PLAN = ON);
ALTER DATABASE [XYZ_Financials_Securities] SET AUTOMATIC_TUNING (CREATE_INDEX = ON);
ALTER DATABASE [XYZ_Financials_Securities] SET AUTOMATIC_TUNING (DROP_INDEX = ON);
GO

-- Enable Temporal Tables for audit (Azure SQL feature)
ALTER TABLE [dbo].[Customers] ADD 
    [ValidFrom] DATETIME2 GENERATED ALWAYS AS ROW START HIDDEN DEFAULT SYSUTCDATETIME(),
    [ValidTo] DATETIME2 GENERATED ALWAYS AS ROW END HIDDEN DEFAULT CONVERT(DATETIME2, '9999-12-31 23:59:59.9999999'),
    PERIOD FOR SYSTEM_TIME ([ValidFrom], [ValidTo]);
GO

ALTER TABLE [dbo].[Customers] SET (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.CustomersHistory));
GO
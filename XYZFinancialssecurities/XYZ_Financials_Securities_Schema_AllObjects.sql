USE [master]
GO
/****** Object:  Database [XYZ_Financials_Securities]    Script Date: 12/27/2025 11:23:13 AM ******/
CREATE DATABASE [XYZ_Financials_Securities]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'XYZ_Financials_Securities', FILENAME = N'D:\AppsInstalledOnCSharedBinaries\MSSQLServer2022\MSSQL16.MSSQLSERVER2022\MSSQL\DATA\XYZ_Financials_Securities.mdf' , SIZE = 73728KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'XYZ_Financials_Securities_log', FILENAME = N'D:\AppsInstalledOnCSharedBinaries\MSSQLServer2022\MSSQL16.MSSQLSERVER2022\MSSQL\DATA\XYZ_Financials_Securities_log.ldf' , SIZE = 8192KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
 WITH CATALOG_COLLATION = DATABASE_DEFAULT, LEDGER = OFF
GO
ALTER DATABASE [XYZ_Financials_Securities] SET COMPATIBILITY_LEVEL = 160
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [XYZ_Financials_Securities].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [XYZ_Financials_Securities] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [XYZ_Financials_Securities] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [XYZ_Financials_Securities] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [XYZ_Financials_Securities] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [XYZ_Financials_Securities] SET ARITHABORT OFF 
GO
ALTER DATABASE [XYZ_Financials_Securities] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [XYZ_Financials_Securities] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [XYZ_Financials_Securities] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [XYZ_Financials_Securities] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [XYZ_Financials_Securities] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [XYZ_Financials_Securities] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [XYZ_Financials_Securities] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [XYZ_Financials_Securities] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [XYZ_Financials_Securities] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [XYZ_Financials_Securities] SET  DISABLE_BROKER 
GO
ALTER DATABASE [XYZ_Financials_Securities] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [XYZ_Financials_Securities] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [XYZ_Financials_Securities] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [XYZ_Financials_Securities] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [XYZ_Financials_Securities] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [XYZ_Financials_Securities] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [XYZ_Financials_Securities] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [XYZ_Financials_Securities] SET RECOVERY FULL 
GO
ALTER DATABASE [XYZ_Financials_Securities] SET  MULTI_USER 
GO
ALTER DATABASE [XYZ_Financials_Securities] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [XYZ_Financials_Securities] SET DB_CHAINING OFF 
GO
ALTER DATABASE [XYZ_Financials_Securities] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [XYZ_Financials_Securities] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [XYZ_Financials_Securities] SET DELAYED_DURABILITY = DISABLED 
GO
ALTER DATABASE [XYZ_Financials_Securities] SET ACCELERATED_DATABASE_RECOVERY = OFF  
GO
EXEC sys.sp_db_vardecimal_storage_format N'XYZ_Financials_Securities', N'ON'
GO
ALTER DATABASE [XYZ_Financials_Securities] SET QUERY_STORE = ON
GO
ALTER DATABASE [XYZ_Financials_Securities] SET QUERY_STORE (OPERATION_MODE = READ_WRITE, CLEANUP_POLICY = (STALE_QUERY_THRESHOLD_DAYS = 30), DATA_FLUSH_INTERVAL_SECONDS = 900, INTERVAL_LENGTH_MINUTES = 60, MAX_STORAGE_SIZE_MB = 1000, QUERY_CAPTURE_MODE = AUTO, SIZE_BASED_CLEANUP_MODE = AUTO, MAX_PLANS_PER_QUERY = 200, WAIT_STATS_CAPTURE_MODE = ON)
GO
USE [XYZ_Financials_Securities]
GO
/****** Object:  DatabaseRole [Role_Underwriter]    Script Date: 12/27/2025 11:23:13 AM ******/
CREATE ROLE [Role_Underwriter]
GO
/****** Object:  DatabaseRole [Role_LoanOfficer]    Script Date: 12/27/2025 11:23:13 AM ******/
CREATE ROLE [Role_LoanOfficer]
GO
/****** Object:  DatabaseRole [Role_CustomerService]    Script Date: 12/27/2025 11:23:13 AM ******/
CREATE ROLE [Role_CustomerService]
GO
/****** Object:  DatabaseRole [Role_Compliance]    Script Date: 12/27/2025 11:23:13 AM ******/
CREATE ROLE [Role_Compliance]
GO
/****** Object:  UserDefinedDataType [dbo].[InterestRateType]    Script Date: 12/27/2025 11:23:13 AM ******/
CREATE TYPE [dbo].[InterestRateType] FROM [varchar](15) NOT NULL
GO
/****** Object:  UserDefinedDataType [dbo].[LoanStatus]    Script Date: 12/27/2025 11:23:13 AM ******/
CREATE TYPE [dbo].[LoanStatus] FROM [varchar](20) NOT NULL
GO
/****** Object:  UserDefinedDataType [dbo].[MoneyAmount]    Script Date: 12/27/2025 11:23:13 AM ******/
CREATE TYPE [dbo].[MoneyAmount] FROM [decimal](18, 2) NOT NULL
GO
/****** Object:  UserDefinedDataType [dbo].[RiskGrade]    Script Date: 12/27/2025 11:23:13 AM ******/
CREATE TYPE [dbo].[RiskGrade] FROM [char](2) NOT NULL
GO
USE [XYZ_Financials_Securities]
GO
/****** Object:  Sequence [dbo].[seq_DocumentRegistry]    Script Date: 12/27/2025 11:23:14 AM ******/
CREATE SEQUENCE [dbo].[seq_DocumentRegistry] 
 AS [bigint]
 START WITH 1
 INCREMENT BY 1
 MINVALUE 1
 MAXVALUE 2147483647
 CACHE  25 
GO
USE [XYZ_Financials_Securities]
GO
/****** Object:  Sequence [dbo].[seq_LoanNumber]    Script Date: 12/27/2025 11:23:14 AM ******/
CREATE SEQUENCE [dbo].[seq_LoanNumber] 
 AS [bigint]
 START WITH 100000
 INCREMENT BY 1
 MINVALUE 100000
 MAXVALUE 999999999
 CACHE  50 
GO
USE [XYZ_Financials_Securities]
GO
/****** Object:  Sequence [dbo].[seq_PaymentReference]    Script Date: 12/27/2025 11:23:14 AM ******/
CREATE SEQUENCE [dbo].[seq_PaymentReference] 
 AS [bigint]
 START WITH 1000000
 INCREMENT BY 1
 MINVALUE 1000000
 MAXVALUE 9999999999
 CACHE  100 
GO
/****** Object:  Synonym [dbo].[ActiveCustomers]    Script Date: 12/27/2025 11:23:14 AM ******/
CREATE SYNONYM [dbo].[ActiveCustomers] FOR [Customers]
GO
/****** Object:  Synonym [dbo].[CurrentLoans]    Script Date: 12/27/2025 11:23:14 AM ******/
CREATE SYNONYM [dbo].[CurrentLoans] FOR [Loans]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_CalculateCurrentBalance]    Script Date: 12/27/2025 11:23:14 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- 3. USER-DEFINED FUNCTIONS
-- =============================================

-- Calculate current loan balance
CREATE FUNCTION [dbo].[fn_CalculateCurrentBalance](
    @LoanID INT,
    @AsOfDate DATE = NULL
)
RETURNS DECIMAL(18,2)
AS
BEGIN
    DECLARE @CurrentBalance DECIMAL(18,2);
    DECLARE @CalculationDate DATE = ISNULL(@AsOfDate, GETDATE());
    
    SELECT @CurrentBalance = 
        L.LoanAmount - ISNULL(SUM(P.PrincipalAmount), 0)
    FROM Loans L
    LEFT JOIN Payments P ON L.LoanID = P.LoanID 
        AND P.PaymentDate <= @CalculationDate
        AND P.PaymentStatus = 'Posted'
    WHERE L.LoanID = @LoanID
    GROUP BY L.LoanAmount;
    
    RETURN ISNULL(@CurrentBalance, 0);
END;
GO
/****** Object:  UserDefinedFunction [dbo].[fn_CalculateInterestForPeriod]    Script Date: 12/27/2025 11:23:14 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- User-Defined Functions

-- Calculate Interest for a Period
CREATE FUNCTION [dbo].[fn_CalculateInterestForPeriod](
    @PrincipalAmount DECIMAL(15, 2),
    @AnnualInterestRate DECIMAL(5, 3),
    @DaysInPeriod INT
)
RETURNS DECIMAL(12, 2)
AS
BEGIN
    DECLARE @InterestAmount DECIMAL(12, 2);
    SET @InterestAmount = (@PrincipalAmount * (@AnnualInterestRate / 100) * @DaysInPeriod) / 365.0;
    RETURN ROUND(@InterestAmount, 2);
END;
GO
/****** Object:  UserDefinedFunction [dbo].[fn_CalculateLoanAge]    Script Date: 12/27/2025 11:23:14 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- Calculate Loan Age in Months
CREATE FUNCTION [dbo].[fn_CalculateLoanAge](
    @LoanID INT
)
RETURNS INT
AS
BEGIN
    DECLARE @OriginationDate DATE;
    DECLARE @Today DATE = GETDATE();
    DECLARE @LoanAgeMonths INT;
    
    SELECT @OriginationDate = OriginationDate
    FROM Loans
    WHERE LoanID = @LoanID;
    
    IF @OriginationDate IS NULL
        RETURN 0;
    
    SET @LoanAgeMonths = DATEDIFF(MONTH, @OriginationDate, @Today);
    
    RETURN @LoanAgeMonths;
END;
GO
/****** Object:  UserDefinedFunction [dbo].[fn_GetCustomerDTI]    Script Date: 12/27/2025 11:23:14 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- Get Customer Current DTI
CREATE FUNCTION [dbo].[fn_GetCustomerDTI](
    @CustomerID INT
)
RETURNS DECIMAL(5, 2)
AS
BEGIN
    DECLARE @MonthlyDebt DECIMAL(15, 2);
    DECLARE @MonthlyIncome DECIMAL(15, 2);
    DECLARE @DTI DECIMAL(5, 2);
    
    -- Calculate monthly debt (all active loan payments)
    SELECT @MonthlyDebt = ISNULL(SUM(MonthlyPayment), 0)
    FROM Loans
    WHERE CustomerID = @CustomerID AND Status = 'Active';
    
    -- Get monthly income
    SELECT @MonthlyIncome = AnnualIncome / 12
    FROM Customers
    WHERE CustomerID = @CustomerID;
    
    -- Calculate DTI
    IF @MonthlyIncome > 0
        SET @DTI = (@MonthlyDebt / @MonthlyIncome) * 100;
    ELSE
        SET @DTI = 100; -- Avoid division by zero
    
    RETURN ROUND(@DTI, 2);
END;
GO
/****** Object:  UserDefinedFunction [dbo].[fn_IsPropertyInFloodZone]    Script Date: 12/27/2025 11:23:14 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- Check if Property is in Flood Zone
CREATE FUNCTION [dbo].[fn_IsPropertyInFloodZone](
    @PropertyID INT
)
RETURNS BIT
AS
BEGIN
    DECLARE @FloodZone NVARCHAR(10);
    DECLARE @IsInFloodZone BIT = 0;
    
    SELECT @FloodZone = FloodZone
    FROM PropertyDetails
    WHERE PropertyID = @PropertyID;
    
    IF @FloodZone IN ('A', 'AE', 'AH', 'AO', 'V', 'VE')
        SET @IsInFloodZone = 1;
    
    RETURN @IsInFloodZone;
END;
GO
/****** Object:  Table [dbo].[DefaultsForeclosures]    Script Date: 12/27/2025 11:23:14 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DefaultsForeclosures](
	[DefaultID] [int] IDENTITY(1,1) NOT NULL,
	[LoanID] [int] NOT NULL,
	[DefaultDate] [date] NOT NULL,
	[Stage] [nvarchar](50) NOT NULL,
	[ReasonCode] [nvarchar](50) NULL,
	[ResolutionType] [nvarchar](50) NULL,
	[ResolutionDate] [date] NULL,
	[LossAmount] [decimal](15, 2) NULL,
	[CollectionAgency] [nvarchar](100) NULL,
	[LegalFilingDate] [date] NULL,
	[LegalCaseNumber] [nvarchar](50) NULL,
	[Notes] [nvarchar](max) NULL,
PRIMARY KEY CLUSTERED 
(
	[DefaultID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Securities]    Script Date: 12/27/2025 11:23:14 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Securities](
	[SecurityID] [int] IDENTITY(1,1) NOT NULL,
	[SecurityName] [nvarchar](100) NOT NULL,
	[SecurityType] [nvarchar](50) NOT NULL,
	[CUSIP] [nvarchar](9) NULL,
	[IssueDate] [date] NOT NULL,
	[MaturityDate] [date] NOT NULL,
	[CouponRate] [decimal](5, 3) NOT NULL,
	[FaceValue] [decimal](15, 2) NOT NULL,
	[CurrentBalance] [decimal](15, 2) NOT NULL,
	[Issuer] [nvarchar](100) NOT NULL,
	[Rating] [nvarchar](10) NULL,
	[Status] [nvarchar](20) NULL,
	[LastTradeDate] [date] NULL,
	[LastTradePrice] [decimal](10, 3) NULL,
PRIMARY KEY CLUSTERED 
(
	[SecurityID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ServicingRights]    Script Date: 12/27/2025 11:23:14 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ServicingRights](
	[ServicingID] [int] IDENTITY(1,1) NOT NULL,
	[LoanID] [int] NOT NULL,
	[ServicerName] [nvarchar](100) NOT NULL,
	[ServicerID] [int] NULL,
	[TransferDate] [date] NOT NULL,
	[MSRValue] [decimal](15, 2) NULL,
	[ServicingFee] [decimal](5, 3) NULL,
	[SubservicerName] [nvarchar](100) NULL,
	[TransferReason] [nvarchar](100) NULL,
PRIMARY KEY CLUSTERED 
(
	[ServicingID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Customers]    Script Date: 12/27/2025 11:23:14 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Customers](
	[CustomerID] [int] IDENTITY(1000,1) NOT NULL,
	[FirstName] [nvarchar](50) NOT NULL,
	[LastName] [nvarchar](50) NOT NULL,
	[SSN] [char](11) NOT NULL,
	[DateOfBirth] [date] NOT NULL,
	[Email] [nvarchar](100) NULL,
	[Phone] [nvarchar](20) NULL,
	[AnnualIncome] [decimal](15, 2) NULL,
	[EmploymentStatus] [nvarchar](50) NULL,
	[Employer] [nvarchar](100) NULL,
	[YearsEmployed] [int] NULL,
	[CreditScore] [int] NULL,
	[CreatedDate] [datetime] NULL,
	[LastUpdatedDate] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[CustomerID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UQ_Customers_SSN] UNIQUE NONCLUSTERED 
(
	[SSN] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[MortgageProducts]    Script Date: 12/27/2025 11:23:14 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MortgageProducts](
	[ProductID] [int] IDENTITY(1,1) NOT NULL,
	[ProductName] [nvarchar](100) NOT NULL,
	[ProductType] [nvarchar](50) NOT NULL,
	[Term] [int] NOT NULL,
	[BaseInterestRate] [decimal](5, 3) NOT NULL,
	[MinCreditScore] [int] NOT NULL,
	[MaxLTV] [decimal](5, 2) NOT NULL,
	[MinLoanAmount] [decimal](15, 2) NOT NULL,
	[MaxLoanAmount] [decimal](15, 2) NOT NULL,
	[OriginationFee] [decimal](5, 2) NULL,
	[IsActive] [bit] NULL,
PRIMARY KEY CLUSTERED 
(
	[ProductID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UQ_MortgageProducts_ProductName] UNIQUE NONCLUSTERED 
(
	[ProductName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PropertyDetails]    Script Date: 12/27/2025 11:23:14 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PropertyDetails](
	[PropertyID] [int] IDENTITY(1,1) NOT NULL,
	[AddressLine1] [nvarchar](100) NOT NULL,
	[AddressLine2] [nvarchar](100) NULL,
	[City] [nvarchar](50) NOT NULL,
	[State] [char](2) NOT NULL,
	[ZipCode] [nvarchar](10) NOT NULL,
	[Country] [nvarchar](50) NULL,
	[PropertyType] [nvarchar](50) NOT NULL,
	[YearBuilt] [int] NULL,
	[SquareFeet] [int] NULL,
	[Bedrooms] [int] NULL,
	[Bathrooms] [decimal](3, 1) NULL,
	[PurchasePrice] [decimal](15, 2) NULL,
	[CurrentValue] [decimal](15, 2) NULL,
	[LastAppraisalDate] [date] NULL,
	[LastAppraisalValue] [decimal](15, 2) NULL,
	[TaxAssessmentValue] [decimal](15, 2) NULL,
	[AnnualTaxAmount] [decimal](10, 2) NULL,
	[HOAFees] [decimal](10, 2) NULL,
	[FloodZone] [nvarchar](10) NULL,
	[PropertyTaxID] [nvarchar](50) NULL,
	[Latitude] [decimal](9, 6) NULL,
	[Longitude] [decimal](9, 6) NULL,
PRIMARY KEY CLUSTERED 
(
	[PropertyID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Loans]    Script Date: 12/27/2025 11:23:14 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Loans](
	[LoanID] [int] IDENTITY(100000,1) NOT NULL,
	[ApplicationID] [int] NOT NULL,
	[CustomerID] [int] NOT NULL,
	[PropertyID] [int] NOT NULL,
	[ProductID] [int] NOT NULL,
	[LoanAmount] [decimal](15, 2) NOT NULL,
	[InterestRate] [decimal](5, 3) NOT NULL,
	[Term] [int] NOT NULL,
	[OriginationDate] [date] NOT NULL,
	[MaturityDate] [date] NOT NULL,
	[MonthlyPayment] [decimal](12, 2) NOT NULL,
	[RemainingBalance] [decimal](15, 2) NOT NULL,
	[Status] [nvarchar](20) NOT NULL,
	[EscrowRequired] [bit] NULL,
	[PMIRequired] [bit] NULL,
	[PMIAmount] [decimal](10, 2) NULL,
	[FirstPaymentDate] [date] NOT NULL,
	[NextPaymentDate] [date] NULL,
	[PaymentFrequency] [nvarchar](20) NULL,
	[SecurityID] [int] NULL,
	[LastUpdatedDate] [date] NULL,
PRIMARY KEY CLUSTERED 
(
	[LoanID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[vw_LoanPortfolioOverview]    Script Date: 12/27/2025 11:23:14 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- Create Views

-- Loan Portfolio Overview
CREATE VIEW [dbo].[vw_LoanPortfolioOverview]
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
LEFT JOIN ServicingRights SR ON L.LoanID = SR.LoanID AND SR.TransferDate = (
    SELECT MAX(TransferDate) FROM ServicingRights WHERE LoanID = L.LoanID
);
GO
/****** Object:  View [dbo].[vw_DelinquentLoans]    Script Date: 12/27/2025 11:23:14 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- Delinquent Loans
CREATE VIEW [dbo].[vw_DelinquentLoans]
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
WHERE L.NextPaymentDate < GETDATE() AND L.Status = 'Active';
GO
/****** Object:  Table [dbo].[Applications]    Script Date: 12/27/2025 11:23:14 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Applications](
	[ApplicationID] [int] IDENTITY(10000,1) NOT NULL,
	[CustomerID] [int] NOT NULL,
	[ProductID] [int] NOT NULL,
	[OfficerID] [int] NOT NULL,
	[ApplicationDate] [datetime] NOT NULL,
	[LoanAmount] [decimal](15, 2) NOT NULL,
	[LoanPurpose] [nvarchar](50) NOT NULL,
	[Status] [nvarchar](50) NOT NULL,
	[ClosingDate] [date] NULL,
	[ApplicationFee] [decimal](10, 2) NULL,
	[DTI] [decimal](5, 2) NULL,
	[PropertyValue] [decimal](15, 2) NULL,
	[LTV] [decimal](5, 2) NULL,
	[RateOffered] [decimal](5, 3) NULL,
	[TermOffered] [int] NULL,
	[DenialReason] [nvarchar](255) NULL,
PRIMARY KEY CLUSTERED 
(
	[ApplicationID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[vw_CustomerPortfolio]    Script Date: 12/27/2025 11:23:14 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- Customer Portfolio View
CREATE VIEW [dbo].[vw_CustomerPortfolio]
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
    MAX(L.OriginationDate) AS MostRecentLoanDate,
    (SELECT TOP 1 A.Status FROM Applications A WHERE A.CustomerID = C.CustomerID ORDER BY A.ApplicationDate DESC) AS MostRecentApplicationStatus
FROM Customers C
LEFT JOIN Loans L ON C.CustomerID = L.CustomerID AND L.Status = 'Active'
GROUP BY C.CustomerID, C.FirstName, C.LastName, C.Email, C.Phone, C.CreditScore;
GO
/****** Object:  Table [dbo].[EscrowAccounts]    Script Date: 12/27/2025 11:23:14 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EscrowAccounts](
	[EscrowID] [int] IDENTITY(1,1) NOT NULL,
	[LoanID] [int] NOT NULL,
	[CurrentBalance] [decimal](12, 2) NOT NULL,
	[PropertyTaxAmount] [decimal](12, 2) NULL,
	[PropertyInsuranceAmount] [decimal](12, 2) NULL,
	[PMIAmount] [decimal](12, 2) NULL,
	[CushionAmount] [decimal](12, 2) NULL,
	[LastAnalysisDate] [date] NULL,
	[NextAnalysisDate] [date] NULL,
	[MonthlyContribution] [decimal](12, 2) NULL,
	[ShortageAmount] [decimal](12, 2) NULL,
PRIMARY KEY CLUSTERED 
(
	[EscrowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UQ_EscrowAccounts_LoanID] UNIQUE NONCLUSTERED 
(
	[LoanID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[EscrowTransactions]    Script Date: 12/27/2025 11:23:14 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EscrowTransactions](
	[TransactionID] [int] IDENTITY(1,1) NOT NULL,
	[EscrowID] [int] NOT NULL,
	[TransactionDate] [date] NOT NULL,
	[TransactionType] [nvarchar](50) NOT NULL,
	[Amount] [decimal](12, 2) NOT NULL,
	[Description] [nvarchar](255) NULL,
	[Reference] [nvarchar](100) NULL,
PRIMARY KEY CLUSTERED 
(
	[TransactionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[vw_EscrowAnalysis]    Script Date: 12/27/2025 11:23:14 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- Escrow Analysis View
CREATE VIEW [dbo].[vw_EscrowAnalysis]
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
    P.AnnualTaxAmount,
    (SELECT SUM(Amount) FROM EscrowTransactions ET 
     WHERE ET.EscrowID = E.EscrowID 
     AND ET.TransactionType = 'Property Tax Payment'
     AND ET.TransactionDate >= DATEADD(MONTH, -12, GETDATE())) AS TaxPaidLastYear,
    (SELECT SUM(Amount) FROM EscrowTransactions ET 
     WHERE ET.EscrowID = E.EscrowID 
     AND ET.TransactionType = 'Insurance Payment'
     AND ET.TransactionDate >= DATEADD(MONTH, -12, GETDATE())) AS InsurancePaidLastYear
FROM EscrowAccounts E
JOIN Loans L ON E.LoanID = L.LoanID
JOIN Customers C ON L.CustomerID = C.CustomerID
JOIN PropertyDetails P ON L.PropertyID = P.PropertyID;
GO
/****** Object:  Table [dbo].[LoanOfficers]    Script Date: 12/27/2025 11:23:14 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LoanOfficers](
	[OfficerID] [int] IDENTITY(1,1) NOT NULL,
	[FirstName] [nvarchar](50) NOT NULL,
	[LastName] [nvarchar](50) NOT NULL,
	[Email] [nvarchar](100) NOT NULL,
	[Phone] [nvarchar](20) NOT NULL,
	[BranchID] [int] NULL,
	[HireDate] [date] NOT NULL,
	[CommissionRate] [decimal](5, 2) NULL,
	[Status] [nvarchar](20) NULL,
PRIMARY KEY CLUSTERED 
(
	[OfficerID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UQ_LoanOfficers_Email] UNIQUE NONCLUSTERED 
(
	[Email] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[vw_LoanOfficerPerformance]    Script Date: 12/27/2025 11:23:14 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- Loan Officer Performance View
CREATE VIEW [dbo].[vw_LoanOfficerPerformance]
AS
SELECT 
    LO.OfficerID,
    LO.FirstName + ' ' + LO.LastName AS OfficerName,
    COUNT(A.ApplicationID) AS TotalApplications,
    SUM(CASE WHEN A.Status = 'Approved' THEN 1 ELSE 0 END) AS ApprovedApplications,
    SUM(CASE WHEN A.Status = 'Denied' THEN 1 ELSE 0 END) AS DeniedApplications,
    SUM(CASE WHEN A.Status = 'Approved' THEN 1.0 ELSE 0 END) / 
        CASE WHEN COUNT(A.ApplicationID) = 0 THEN 1 ELSE COUNT(A.ApplicationID) END * 100 AS ApprovalRate,
    SUM(L.LoanAmount) AS TotalLoanAmount,
    SUM(L.LoanAmount * (LO.CommissionRate / 100)) AS TotalCommission,
    AVG(DATEDIFF(DAY, A.ApplicationDate, A.ClosingDate)) AS AvgDaysToClose
FROM LoanOfficers LO
LEFT JOIN Applications A ON LO.OfficerID = A.OfficerID
LEFT JOIN Loans L ON A.ApplicationID = L.ApplicationID AND A.Status = 'Approved'
GROUP BY LO.OfficerID, LO.FirstName, LO.LastName;
GO
/****** Object:  Table [dbo].[AuditLog]    Script Date: 12/27/2025 11:23:14 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AuditLog](
	[LogID] [int] IDENTITY(1,1) NOT NULL,
	[EntityType] [nvarchar](50) NOT NULL,
	[EntityID] [int] NOT NULL,
	[ActionType] [nvarchar](20) NOT NULL,
	[ActionDateTime] [datetime] NULL,
	[UserID] [nvarchar](50) NOT NULL,
	[OldValues] [nvarchar](max) NULL,
	[NewValues] [nvarchar](max) NULL,
	[IPAddress] [nvarchar](50) NULL,
	[ApplicationName] [nvarchar](100) NULL,
PRIMARY KEY CLUSTERED 
(
	[LogID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CapitalMarketData]    Script Date: 12/27/2025 11:23:14 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CapitalMarketData](
	[MarketDataID] [int] IDENTITY(1,1) NOT NULL,
	[DataDate] [date] NOT NULL,
	[DataSource] [nvarchar](100) NOT NULL,
	[Treasury10Y] [decimal](5, 3) NULL,
	[FedFundsRate] [decimal](5, 3) NULL,
	[LIBOR3M] [decimal](5, 3) NULL,
	[SOFR] [decimal](5, 3) NULL,
	[MBS30YRate] [decimal](5, 3) NULL,
	[Fannie30YRate] [decimal](5, 3) NULL,
	[Freddie30YRate] [decimal](5, 3) NULL,
	[EffectiveDateStart] [date] NULL,
	[EffectiveDateEnd] [date] NULL,
PRIMARY KEY CLUSTERED 
(
	[MarketDataID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CustomerAddresses]    Script Date: 12/27/2025 11:23:14 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CustomerAddresses](
	[AddressID] [int] IDENTITY(1,1) NOT NULL,
	[CustomerID] [int] NOT NULL,
	[AddressType] [nvarchar](20) NOT NULL,
	[AddressLine1] [nvarchar](100) NOT NULL,
	[AddressLine2] [nvarchar](100) NULL,
	[City] [nvarchar](50) NOT NULL,
	[State] [char](2) NOT NULL,
	[ZipCode] [nvarchar](10) NOT NULL,
	[Country] [nvarchar](50) NULL,
	[StartDate] [date] NULL,
	[EndDate] [date] NULL,
PRIMARY KEY CLUSTERED 
(
	[AddressID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DocumentsRegistry]    Script Date: 12/27/2025 11:23:14 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DocumentsRegistry](
	[DocumentID] [int] IDENTITY(1,1) NOT NULL,
	[ApplicationID] [int] NOT NULL,
	[DocumentType] [nvarchar](100) NOT NULL,
	[FileName] [nvarchar](255) NULL,
	[FileLocation] [nvarchar](255) NULL,
	[UploadDate] [datetime] NULL,
	[RequiredFlag] [bit] NULL,
	[ReceivedFlag] [bit] NULL,
	[ApprovalStatus] [nvarchar](20) NULL,
	[ApprovalDate] [datetime] NULL,
	[ApprovedBy] [nvarchar](100) NULL,
	[Notes] [nvarchar](max) NULL,
PRIMARY KEY CLUSTERED 
(
	[DocumentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[FINRA_FI]    Script Date: 12/27/2025 11:23:14 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FINRA_FI](
	[PKID] [tinyint] NOT NULL,
	[Symbol] [nvarchar](50) NOT NULL,
	[IssuerName] [nvarchar](150) NOT NULL,
	[CouponType] [nvarchar](50) NULL,
	[CouponRate] [float] NULL,
	[MaturityDate] [date] NOT NULL,
	[DealID] [nvarchar](50) NULL,
	[TrancheID] [nvarchar](50) NULL,
	[IssueDescription] [nvarchar](250) NOT NULL,
	[InterestType] [nvarchar](50) NULL,
	[I44A] [bit] NOT NULL,
	[CUSIP] [nvarchar](50) NOT NULL,
	[SubProdType] [nvarchar](50) NULL,
	[ProdSubtype] [nvarchar](50) NOT NULL,
	[ProdType] [nvarchar](50) NULL,
	[IssuingAgency] [nvarchar](100) NULL,
	[Convertible] [nvarchar](1) NULL,
 CONSTRAINT [PK_FINRA_FI] PRIMARY KEY CLUSTERED 
(
	[Symbol] ASC,
	[CUSIP] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[InterestType]    Script Date: 12/27/2025 11:23:14 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[InterestType](
	[ITID] [int] NOT NULL,
	[InterestTypeID] [nchar](10) NULL,
	[InterestTypeDesc] [nchar](50) NULL,
 CONSTRAINT [PK_InterestType] PRIMARY KEY CLUSTERED 
(
	[ITID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[LoanTermModifications]    Script Date: 12/27/2025 11:23:14 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LoanTermModifications](
	[ModificationID] [int] IDENTITY(1,1) NOT NULL,
	[LoanID] [int] NOT NULL,
	[ModificationDate] [date] NOT NULL,
	[ModificationType] [nvarchar](50) NOT NULL,
	[PreviousInterestRate] [decimal](5, 3) NULL,
	[NewInterestRate] [decimal](5, 3) NULL,
	[PreviousTerm] [int] NULL,
	[NewTerm] [int] NULL,
	[PreviousPayment] [decimal](12, 2) NULL,
	[NewPayment] [decimal](12, 2) NULL,
	[ModificationFee] [decimal](10, 2) NULL,
	[RequiredDocuments] [nvarchar](max) NULL,
	[ApprovalStatus] [nvarchar](20) NULL,
	[ApprovedBy] [nvarchar](100) NULL,
	[Notes] [nvarchar](max) NULL,
PRIMARY KEY CLUSTERED 
(
	[ModificationID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Payments]    Script Date: 12/27/2025 11:23:14 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Payments](
	[PaymentID] [int] IDENTITY(1,1) NOT NULL,
	[LoanID] [int] NOT NULL,
	[PaymentDate] [date] NOT NULL,
	[PaymentAmount] [decimal](12, 2) NOT NULL,
	[PrincipalAmount] [decimal](12, 2) NOT NULL,
	[InterestAmount] [decimal](12, 2) NOT NULL,
	[EscrowAmount] [decimal](12, 2) NULL,
	[LateFeeAmount] [decimal](10, 2) NULL,
	[PaymentMethod] [nvarchar](50) NULL,
	[TransactionID] [nvarchar](100) NULL,
	[PaymentStatus] [nvarchar](20) NULL,
	[ProcessedDate] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[PaymentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ProductSubtype]    Script Date: 12/27/2025 11:23:14 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ProductSubtype](
	[PTID] [int] NOT NULL,
	[ProdType] [nchar](50) NOT NULL,
	[ProdSubType] [nchar](50) NOT NULL,
	[PSTDesc] [nchar](100) NULL,
 CONSTRAINT [PK_ProductSubtype] PRIMARY KEY CLUSTERED 
(
	[ProdType] ASC,
	[ProdSubType] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[RiskAssessments]    Script Date: 12/27/2025 11:23:14 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RiskAssessments](
	[AssessmentID] [int] IDENTITY(1,1) NOT NULL,
	[CustomerID] [int] NOT NULL,
	[ApplicationID] [int] NOT NULL,
	[AssessmentDate] [datetime] NULL,
	[CreditScore] [int] NOT NULL,
	[DTI] [decimal](5, 2) NOT NULL,
	[LTV] [decimal](5, 2) NOT NULL,
	[FICOScoreSource] [nvarchar](50) NULL,
	[RiskClassification] [nvarchar](20) NULL,
	[RecommendedAction] [nvarchar](50) NULL,
	[Notes] [nvarchar](max) NULL,
PRIMARY KEY CLUSTERED 
(
	[AssessmentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Index [IX_Applications_ApplicationDate]    Script Date: 12/27/2025 11:23:14 AM ******/
CREATE NONCLUSTERED INDEX [IX_Applications_ApplicationDate] ON [dbo].[Applications]
(
	[ApplicationDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Applications_CustomerID]    Script Date: 12/27/2025 11:23:14 AM ******/
CREATE NONCLUSTERED INDEX [IX_Applications_CustomerID] ON [dbo].[Applications]
(
	[CustomerID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Applications_OfficerID]    Script Date: 12/27/2025 11:23:14 AM ******/
CREATE NONCLUSTERED INDEX [IX_Applications_OfficerID] ON [dbo].[Applications]
(
	[OfficerID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_Applications_Status]    Script Date: 12/27/2025 11:23:14 AM ******/
CREATE NONCLUSTERED INDEX [IX_Applications_Status] ON [dbo].[Applications]
(
	[Status] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Customers_CreditScore]    Script Date: 12/27/2025 11:23:14 AM ******/
CREATE NONCLUSTERED INDEX [IX_Customers_CreditScore] ON [dbo].[Customers]
(
	[CreditScore] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_Customers_LastName]    Script Date: 12/27/2025 11:23:14 AM ******/
CREATE NONCLUSTERED INDEX [IX_Customers_LastName] ON [dbo].[Customers]
(
	[LastName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Loans_CustomerID]    Script Date: 12/27/2025 11:23:14 AM ******/
CREATE NONCLUSTERED INDEX [IX_Loans_CustomerID] ON [dbo].[Loans]
(
	[CustomerID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Loans_OriginationDate]    Script Date: 12/27/2025 11:23:14 AM ******/
CREATE NONCLUSTERED INDEX [IX_Loans_OriginationDate] ON [dbo].[Loans]
(
	[OriginationDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Loans_PropertyID]    Script Date: 12/27/2025 11:23:14 AM ******/
CREATE NONCLUSTERED INDEX [IX_Loans_PropertyID] ON [dbo].[Loans]
(
	[PropertyID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Loans_SecurityID]    Script Date: 12/27/2025 11:23:14 AM ******/
CREATE NONCLUSTERED INDEX [IX_Loans_SecurityID] ON [dbo].[Loans]
(
	[SecurityID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_Loans_Status]    Script Date: 12/27/2025 11:23:14 AM ******/
CREATE NONCLUSTERED INDEX [IX_Loans_Status] ON [dbo].[Loans]
(
	[Status] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Payments_LoanID]    Script Date: 12/27/2025 11:23:14 AM ******/
CREATE NONCLUSTERED INDEX [IX_Payments_LoanID] ON [dbo].[Payments]
(
	[LoanID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Payments_LoanID_Date]    Script Date: 12/27/2025 11:23:14 AM ******/
CREATE NONCLUSTERED INDEX [IX_Payments_LoanID_Date] ON [dbo].[Payments]
(
	[LoanID] ASC,
	[PaymentDate] DESC
)
INCLUDE([PaymentAmount],[PrincipalAmount],[InterestAmount]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Payments_PaymentDate]    Script Date: 12/27/2025 11:23:14 AM ******/
CREATE NONCLUSTERED INDEX [IX_Payments_PaymentDate] ON [dbo].[Payments]
(
	[PaymentDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_PropertyDetails_PropertyType]    Script Date: 12/27/2025 11:23:14 AM ******/
CREATE NONCLUSTERED INDEX [IX_PropertyDetails_PropertyType] ON [dbo].[PropertyDetails]
(
	[PropertyType] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_PropertyDetails_State]    Script Date: 12/27/2025 11:23:14 AM ******/
CREATE NONCLUSTERED INDEX [IX_PropertyDetails_State] ON [dbo].[PropertyDetails]
(
	[State] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_PropertyDetails_ZipCode]    Script Date: 12/27/2025 11:23:14 AM ******/
CREATE NONCLUSTERED INDEX [IX_PropertyDetails_ZipCode] ON [dbo].[PropertyDetails]
(
	[ZipCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Applications] ADD  DEFAULT (getdate()) FOR [ApplicationDate]
GO
ALTER TABLE [dbo].[Applications] ADD  DEFAULT ('Submitted') FOR [Status]
GO
ALTER TABLE [dbo].[AuditLog] ADD  DEFAULT (getdate()) FOR [ActionDateTime]
GO
ALTER TABLE [dbo].[CustomerAddresses] ADD  DEFAULT ('USA') FOR [Country]
GO
ALTER TABLE [dbo].[Customers] ADD  DEFAULT (getdate()) FOR [CreatedDate]
GO
ALTER TABLE [dbo].[Customers] ADD  DEFAULT (getdate()) FOR [LastUpdatedDate]
GO
ALTER TABLE [dbo].[DocumentsRegistry] ADD  DEFAULT (getdate()) FOR [UploadDate]
GO
ALTER TABLE [dbo].[DocumentsRegistry] ADD  DEFAULT ((1)) FOR [RequiredFlag]
GO
ALTER TABLE [dbo].[DocumentsRegistry] ADD  DEFAULT ((0)) FOR [ReceivedFlag]
GO
ALTER TABLE [dbo].[DocumentsRegistry] ADD  DEFAULT ('Pending') FOR [ApprovalStatus]
GO
ALTER TABLE [dbo].[EscrowAccounts] ADD  DEFAULT ((0.00)) FOR [CurrentBalance]
GO
ALTER TABLE [dbo].[EscrowAccounts] ADD  DEFAULT ((0.00)) FOR [PropertyTaxAmount]
GO
ALTER TABLE [dbo].[EscrowAccounts] ADD  DEFAULT ((0.00)) FOR [PropertyInsuranceAmount]
GO
ALTER TABLE [dbo].[EscrowAccounts] ADD  DEFAULT ((0.00)) FOR [PMIAmount]
GO
ALTER TABLE [dbo].[EscrowAccounts] ADD  DEFAULT ((0.00)) FOR [CushionAmount]
GO
ALTER TABLE [dbo].[EscrowAccounts] ADD  DEFAULT ((0.00)) FOR [MonthlyContribution]
GO
ALTER TABLE [dbo].[EscrowAccounts] ADD  DEFAULT ((0.00)) FOR [ShortageAmount]
GO
ALTER TABLE [dbo].[LoanOfficers] ADD  DEFAULT ((0.00)) FOR [CommissionRate]
GO
ALTER TABLE [dbo].[LoanOfficers] ADD  DEFAULT ('Active') FOR [Status]
GO
ALTER TABLE [dbo].[Loans] ADD  DEFAULT ('Active') FOR [Status]
GO
ALTER TABLE [dbo].[Loans] ADD  DEFAULT ((1)) FOR [EscrowRequired]
GO
ALTER TABLE [dbo].[Loans] ADD  DEFAULT ((0)) FOR [PMIRequired]
GO
ALTER TABLE [dbo].[Loans] ADD  DEFAULT ((0.00)) FOR [PMIAmount]
GO
ALTER TABLE [dbo].[Loans] ADD  DEFAULT ('Monthly') FOR [PaymentFrequency]
GO
ALTER TABLE [dbo].[LoanTermModifications] ADD  DEFAULT ('Pending') FOR [ApprovalStatus]
GO
ALTER TABLE [dbo].[MortgageProducts] ADD  DEFAULT ((0.00)) FOR [OriginationFee]
GO
ALTER TABLE [dbo].[MortgageProducts] ADD  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[Payments] ADD  DEFAULT ((0.00)) FOR [EscrowAmount]
GO
ALTER TABLE [dbo].[Payments] ADD  DEFAULT ((0.00)) FOR [LateFeeAmount]
GO
ALTER TABLE [dbo].[Payments] ADD  DEFAULT ('Processed') FOR [PaymentStatus]
GO
ALTER TABLE [dbo].[PropertyDetails] ADD  DEFAULT ('USA') FOR [Country]
GO
ALTER TABLE [dbo].[PropertyDetails] ADD  DEFAULT ((0.00)) FOR [HOAFees]
GO
ALTER TABLE [dbo].[RiskAssessments] ADD  DEFAULT (getdate()) FOR [AssessmentDate]
GO
ALTER TABLE [dbo].[Securities] ADD  DEFAULT ('Active') FOR [Status]
GO
ALTER TABLE [dbo].[Applications]  WITH CHECK ADD  CONSTRAINT [FK_Applications_Customers] FOREIGN KEY([CustomerID])
REFERENCES [dbo].[Customers] ([CustomerID])
GO
ALTER TABLE [dbo].[Applications] CHECK CONSTRAINT [FK_Applications_Customers]
GO
ALTER TABLE [dbo].[Applications]  WITH CHECK ADD  CONSTRAINT [FK_Applications_LoanOfficers] FOREIGN KEY([OfficerID])
REFERENCES [dbo].[LoanOfficers] ([OfficerID])
GO
ALTER TABLE [dbo].[Applications] CHECK CONSTRAINT [FK_Applications_LoanOfficers]
GO
ALTER TABLE [dbo].[Applications]  WITH CHECK ADD  CONSTRAINT [FK_Applications_MortgageProducts] FOREIGN KEY([ProductID])
REFERENCES [dbo].[MortgageProducts] ([ProductID])
GO
ALTER TABLE [dbo].[Applications] CHECK CONSTRAINT [FK_Applications_MortgageProducts]
GO
ALTER TABLE [dbo].[CustomerAddresses]  WITH CHECK ADD  CONSTRAINT [FK_CustomerAddresses_Customers] FOREIGN KEY([CustomerID])
REFERENCES [dbo].[Customers] ([CustomerID])
GO
ALTER TABLE [dbo].[CustomerAddresses] CHECK CONSTRAINT [FK_CustomerAddresses_Customers]
GO
ALTER TABLE [dbo].[DefaultsForeclosures]  WITH CHECK ADD  CONSTRAINT [FK_DefaultsForeclosures_Loans] FOREIGN KEY([LoanID])
REFERENCES [dbo].[Loans] ([LoanID])
GO
ALTER TABLE [dbo].[DefaultsForeclosures] CHECK CONSTRAINT [FK_DefaultsForeclosures_Loans]
GO
ALTER TABLE [dbo].[DocumentsRegistry]  WITH CHECK ADD  CONSTRAINT [FK_DocumentsRegistry_Applications] FOREIGN KEY([ApplicationID])
REFERENCES [dbo].[Applications] ([ApplicationID])
GO
ALTER TABLE [dbo].[DocumentsRegistry] CHECK CONSTRAINT [FK_DocumentsRegistry_Applications]
GO
ALTER TABLE [dbo].[EscrowAccounts]  WITH CHECK ADD  CONSTRAINT [FK_EscrowAccounts_Loans] FOREIGN KEY([LoanID])
REFERENCES [dbo].[Loans] ([LoanID])
GO
ALTER TABLE [dbo].[EscrowAccounts] CHECK CONSTRAINT [FK_EscrowAccounts_Loans]
GO
ALTER TABLE [dbo].[EscrowTransactions]  WITH CHECK ADD  CONSTRAINT [FK_EscrowTransactions_EscrowAccounts] FOREIGN KEY([EscrowID])
REFERENCES [dbo].[EscrowAccounts] ([EscrowID])
GO
ALTER TABLE [dbo].[EscrowTransactions] CHECK CONSTRAINT [FK_EscrowTransactions_EscrowAccounts]
GO
ALTER TABLE [dbo].[Loans]  WITH CHECK ADD  CONSTRAINT [FK_Loans_Applications] FOREIGN KEY([ApplicationID])
REFERENCES [dbo].[Applications] ([ApplicationID])
GO
ALTER TABLE [dbo].[Loans] CHECK CONSTRAINT [FK_Loans_Applications]
GO
ALTER TABLE [dbo].[Loans]  WITH CHECK ADD  CONSTRAINT [FK_Loans_Customers] FOREIGN KEY([CustomerID])
REFERENCES [dbo].[Customers] ([CustomerID])
GO
ALTER TABLE [dbo].[Loans] CHECK CONSTRAINT [FK_Loans_Customers]
GO
ALTER TABLE [dbo].[Loans]  WITH CHECK ADD  CONSTRAINT [FK_Loans_MortgageProducts] FOREIGN KEY([ProductID])
REFERENCES [dbo].[MortgageProducts] ([ProductID])
GO
ALTER TABLE [dbo].[Loans] CHECK CONSTRAINT [FK_Loans_MortgageProducts]
GO
ALTER TABLE [dbo].[Loans]  WITH CHECK ADD  CONSTRAINT [FK_Loans_PropertyDetails] FOREIGN KEY([PropertyID])
REFERENCES [dbo].[PropertyDetails] ([PropertyID])
GO
ALTER TABLE [dbo].[Loans] CHECK CONSTRAINT [FK_Loans_PropertyDetails]
GO
ALTER TABLE [dbo].[Loans]  WITH CHECK ADD  CONSTRAINT [FK_Loans_Securities] FOREIGN KEY([SecurityID])
REFERENCES [dbo].[Securities] ([SecurityID])
GO
ALTER TABLE [dbo].[Loans] CHECK CONSTRAINT [FK_Loans_Securities]
GO
ALTER TABLE [dbo].[LoanTermModifications]  WITH CHECK ADD  CONSTRAINT [FK_LoanTermModifications_Loans] FOREIGN KEY([LoanID])
REFERENCES [dbo].[Loans] ([LoanID])
GO
ALTER TABLE [dbo].[LoanTermModifications] CHECK CONSTRAINT [FK_LoanTermModifications_Loans]
GO
ALTER TABLE [dbo].[Payments]  WITH CHECK ADD  CONSTRAINT [FK_Payments_Loans] FOREIGN KEY([LoanID])
REFERENCES [dbo].[Loans] ([LoanID])
GO
ALTER TABLE [dbo].[Payments] CHECK CONSTRAINT [FK_Payments_Loans]
GO
ALTER TABLE [dbo].[RiskAssessments]  WITH CHECK ADD  CONSTRAINT [FK_RiskAssessments_Applications] FOREIGN KEY([ApplicationID])
REFERENCES [dbo].[Applications] ([ApplicationID])
GO
ALTER TABLE [dbo].[RiskAssessments] CHECK CONSTRAINT [FK_RiskAssessments_Applications]
GO
ALTER TABLE [dbo].[RiskAssessments]  WITH CHECK ADD  CONSTRAINT [FK_RiskAssessments_Customers] FOREIGN KEY([CustomerID])
REFERENCES [dbo].[Customers] ([CustomerID])
GO
ALTER TABLE [dbo].[RiskAssessments] CHECK CONSTRAINT [FK_RiskAssessments_Customers]
GO
ALTER TABLE [dbo].[ServicingRights]  WITH CHECK ADD  CONSTRAINT [FK_ServicingRights_Loans] FOREIGN KEY([LoanID])
REFERENCES [dbo].[Loans] ([LoanID])
GO
ALTER TABLE [dbo].[ServicingRights] CHECK CONSTRAINT [FK_ServicingRights_Loans]
GO
ALTER TABLE [dbo].[Loans]  WITH CHECK ADD  CONSTRAINT [CK_Loans_InterestRate_Range] CHECK  (([InterestRate]>=(0) AND [InterestRate]<=(50)))
GO
ALTER TABLE [dbo].[Loans] CHECK CONSTRAINT [CK_Loans_InterestRate_Range]
GO
ALTER TABLE [dbo].[Loans]  WITH CHECK ADD  CONSTRAINT [CK_Loans_LoanAmount_Positive] CHECK  (([LoanAmount]>(0)))
GO
ALTER TABLE [dbo].[Loans] CHECK CONSTRAINT [CK_Loans_LoanAmount_Positive]
GO
ALTER TABLE [dbo].[Payments]  WITH CHECK ADD  CONSTRAINT [CK_Payments_Amount_Valid] CHECK  (([PaymentAmount]>(0) AND [PrincipalAmount]>=(0) AND [InterestAmount]>=(0)))
GO
ALTER TABLE [dbo].[Payments] CHECK CONSTRAINT [CK_Payments_Amount_Valid]
GO
/****** Object:  StoredProcedure [dbo].[sp_CalculateLTV]    Script Date: 12/27/2025 11:23:14 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- Calculate Loan to Value Ratio
CREATE PROCEDURE [dbo].[sp_CalculateLTV]
    @LoanAmount DECIMAL(15, 2),
    @PropertyValue DECIMAL(15, 2),
    @LTV DECIMAL(5, 2) OUTPUT
AS
BEGIN
    IF @PropertyValue = 0
        SET @LTV = 100; -- Avoid division by zero
    ELSE
        SET @LTV = (@LoanAmount / @PropertyValue) * 100;
END;
GO
/****** Object:  StoredProcedure [dbo].[sp_CalculateMonthlyPayment]    Script Date: 12/27/2025 11:23:14 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- Calculate Monthly Payment
CREATE PROCEDURE [dbo].[sp_CalculateMonthlyPayment]
    @LoanAmount DECIMAL(15, 2),
    @InterestRate DECIMAL(5, 3),
    @Term INT,
    @MonthlyPayment DECIMAL(12, 2) OUTPUT
AS
BEGIN
    -- Convert annual interest rate to monthly and to decimal
    DECLARE @MonthlyRate DECIMAL(12, 8) = (@InterestRate / 100) / 12;
    
    -- Calculate monthly payment using the formula: P = L[c(1 + c)^n]/[(1 + c)^n - 1]
    -- Where P = payment, L = loan amount, c = monthly interest rate, n = number of payments
    SET @MonthlyPayment = @LoanAmount * (@MonthlyRate * POWER(1 + @MonthlyRate, @Term)) / (POWER(1 + @MonthlyRate, @Term) - 1);
END;
GO
/****** Object:  StoredProcedure [dbo].[sp_GenerateAmortizationSchedule]    Script Date: 12/27/2025 11:23:14 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- Calculate Amortization Schedule
CREATE PROCEDURE [dbo].[sp_GenerateAmortizationSchedule]
    @LoanID INT
AS
BEGIN
    DECLARE @LoanAmount DECIMAL(15, 2);
    DECLARE @InterestRate DECIMAL(5, 3);
    DECLARE @Term INT;
    DECLARE @MonthlyPayment DECIMAL(12, 2);
    DECLARE @RemainingBalance DECIMAL(15, 2);
    DECLARE @OriginationDate DATE;
    
    -- Get loan details
    SELECT 
        @LoanAmount = LoanAmount,
        @InterestRate = InterestRate,
        @Term = Term,
        @MonthlyPayment = MonthlyPayment,
        @OriginationDate = OriginationDate
    FROM Loans
    WHERE LoanID = @LoanID;
    
    IF @LoanAmount IS NULL
        RETURN;
    
    -- Create temporary table for amortization schedule
    CREATE TABLE #AmortizationSchedule (
        PaymentNumber INT,
        PaymentDate DATE,
        BeginningBalance DECIMAL(15, 2),
        Payment DECIMAL(12, 2),
        PrincipalAmount DECIMAL(12, 2),
        InterestAmount DECIMAL(12, 2),
        EndingBalance DECIMAL(15, 2)
    );
    
    -- Variables for calculation
    DECLARE @PaymentNumber INT = 1;
    DECLARE @BeginningBalance DECIMAL(15, 2) = @LoanAmount;
    DECLARE @EndingBalance DECIMAL(15, 2);
    DECLARE @PrincipalAmount DECIMAL(12, 2);
    DECLARE @InterestAmount DECIMAL(12, 2);
    DECLARE @PaymentDate DATE = DATEADD(MONTH, 1, @OriginationDate);
    DECLARE @MonthlyRate DECIMAL(12, 8) = (@InterestRate / 100) / 12;
    
    -- Generate amortization schedule
    WHILE @PaymentNumber <= @Term
    BEGIN
        -- Calculate interest for this payment
        SET @InterestAmount = ROUND(@BeginningBalance * @MonthlyRate, 2);
        
        -- Calculate principal for this payment
        SET @PrincipalAmount = @MonthlyPayment - @InterestAmount;
        
        -- Calculate ending balance
        SET @EndingBalance = @BeginningBalance - @PrincipalAmount;
        
        -- Handle last payment rounding issues
        IF @PaymentNumber = @Term AND @EndingBalance <> 0
        BEGIN
            SET @PrincipalAmount = @PrincipalAmount + @EndingBalance;
            SET @EndingBalance = 0;
        END
        
        -- Insert into temp table
        INSERT INTO #AmortizationSchedule
        VALUES (
            @PaymentNumber,
            @PaymentDate,
            @BeginningBalance,
            @MonthlyPayment,
            @PrincipalAmount,
            @InterestAmount,
            @EndingBalance
        );
        
        -- Prepare for next iteration
        SET @PaymentNumber = @PaymentNumber + 1;
        SET @BeginningBalance = @EndingBalance;
        SET @PaymentDate = DATEADD(MONTH, 1, @PaymentDate);
    END;
    
    -- Return the amortization schedule
    SELECT * FROM #AmortizationSchedule;
    
    -- Clean up
    DROP TABLE #AmortizationSchedule;
END;
GO
/****** Object:  StoredProcedure [dbo].[sp_ProcessLoanPayment]    Script Date: 12/27/2025 11:23:14 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- Process Loan Payment
CREATE PROCEDURE [dbo].[sp_ProcessLoanPayment]
    @LoanID INT,
    @PaymentAmount DECIMAL(12, 2),
    @PaymentDate DATE,
    @PaymentMethod NVARCHAR(50),
    @TransactionID NVARCHAR(100) = NULL
AS
BEGIN
    BEGIN TRANSACTION;
    
    BEGIN TRY
        DECLARE @RemainingBalance DECIMAL(15, 2);
        DECLARE @InterestRate DECIMAL(5, 3);
        DECLARE @MonthlyPayment DECIMAL(12, 2);
        DECLARE @EscrowRequired BIT;
        DECLARE @EscrowID INT;
        DECLARE @EscrowAmount DECIMAL(12, 2) = 0;
        DECLARE @PrincipalAmount DECIMAL(12, 2);
        DECLARE @InterestAmount DECIMAL(12, 2);
        DECLARE @MonthlyRate DECIMAL(12, 8);
        DECLARE @LateFeeAmount DECIMAL(10, 2) = 0;
        DECLARE @NextPaymentDate DATE;
        
        -- Get loan details
        SELECT 
            @RemainingBalance = RemainingBalance,
            @InterestRate = InterestRate,
            @MonthlyPayment = MonthlyPayment,
            @EscrowRequired = EscrowRequired,
            @NextPaymentDate = NextPaymentDate
        FROM Loans
        WHERE LoanID = @LoanID;
        
        -- Validate loan exists
        IF @RemainingBalance IS NULL
            THROW 50000, 'Loan not found', 1;
            
        -- Check for late payment
        IF @PaymentDate > @NextPaymentDate
            SET @LateFeeAmount = 50.00; -- Example late fee
            
        -- Calculate monthly interest rate
        SET @MonthlyRate = (@InterestRate / 100) / 12;
        
        -- Calculate interest amount
        SET @InterestAmount = ROUND(@RemainingBalance * @MonthlyRate, 2);
        
        -- Get escrow amount if required
        IF @EscrowRequired = 1
        BEGIN
            SELECT 
                @EscrowID = EscrowID,
                @EscrowAmount = MonthlyContribution
            FROM EscrowAccounts
            WHERE LoanID = @LoanID;
        END
        
        -- Calculate principal amount (payment minus interest and escrow)
        SET @PrincipalAmount = @PaymentAmount - @InterestAmount - @EscrowAmount - @LateFeeAmount;
        
        -- Make sure principal is not negative
        IF @PrincipalAmount < 0
            THROW 50001, 'Payment amount is insufficient to cover interest and escrow', 1;
            
        -- Update loan balance
        UPDATE Loans
        SET 
            RemainingBalance = RemainingBalance - @PrincipalAmount,
            NextPaymentDate = DATEADD(MONTH, 1, @NextPaymentDate),
            LastUpdatedDate = GETDATE()
        WHERE LoanID = @LoanID;
        
        -- Insert payment record
        INSERT INTO Payments (
            LoanID,
            PaymentDate,
            PaymentAmount,
            PrincipalAmount,
            InterestAmount,
            EscrowAmount,
            LateFeeAmount,
            PaymentMethod,
            TransactionID,
            PaymentStatus,
            ProcessedDate
        )
        VALUES (
            @LoanID,
            @PaymentDate,
            @PaymentAmount,
            @PrincipalAmount,
            @InterestAmount,
            @EscrowAmount,
            @LateFeeAmount,
            @PaymentMethod,
            @TransactionID,
            'Processed',
            GETDATE()
        );
        
        -- Update escrow balance if required
        IF @EscrowRequired = 1 AND @EscrowID IS NOT NULL
        BEGIN
            UPDATE EscrowAccounts
            SET CurrentBalance = CurrentBalance + @EscrowAmount
            WHERE EscrowID = @EscrowID;
            
            -- Insert escrow transaction
            INSERT INTO EscrowTransactions (
                EscrowID,
                TransactionDate,
                TransactionType,
                Amount,
                Description
            )
            VALUES (
                @EscrowID,
                @PaymentDate,
                'Deposit',
                @EscrowAmount,
                'Monthly escrow contribution'
            );
        END
        
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO
USE [master]
GO
ALTER DATABASE [XYZ_Financials_Securities] SET  READ_WRITE 
GO

USE [master]
GO
/****** Object:  Database [CreditDB]    Script Date: 1/21/2025 8:21:28 PM ******/
CREATE DATABASE [CreditDB]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'CreditData', FILENAME = N'D:\AppsInstalledOnCSharedBinaries\MSSQLServer2022\MSSQL16.MSSQLSERVER2022\MSSQL\DATA\CreditDBData.mdf' , SIZE = 1024000KB , MAXSIZE = UNLIMITED, FILEGROWTH = 10%)
 LOG ON 
( NAME = N'CreditLog', FILENAME = N'D:\AppsInstalledOnCSharedBinaries\MSSQLServer2022\MSSQL16.MSSQLSERVER2022\MSSQL\DATA\CreditDBLog.ldf' , SIZE = 409600KB , MAXSIZE = UNLIMITED, FILEGROWTH = 10%)
 WITH CATALOG_COLLATION = DATABASE_DEFAULT, LEDGER = OFF
GO
ALTER DATABASE [CreditDB] SET COMPATIBILITY_LEVEL = 100
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [CreditDB].[dbo].[sp_fulltext_database] @action = 'disable'
end
GO
ALTER DATABASE [CreditDB] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [CreditDB] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [CreditDB] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [CreditDB] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [CreditDB] SET ARITHABORT OFF 
GO
ALTER DATABASE [CreditDB] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [CreditDB] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [CreditDB] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [CreditDB] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [CreditDB] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [CreditDB] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [CreditDB] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [CreditDB] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [CreditDB] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [CreditDB] SET  DISABLE_BROKER 
GO
ALTER DATABASE [CreditDB] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [CreditDB] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [CreditDB] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [CreditDB] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [CreditDB] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [CreditDB] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [CreditDB] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [CreditDB] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [CreditDB] SET  MULTI_USER 
GO
ALTER DATABASE [CreditDB] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [CreditDB] SET DB_CHAINING OFF 
GO
ALTER DATABASE [CreditDB] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [CreditDB] SET TARGET_RECOVERY_TIME = 0 SECONDS 
GO
ALTER DATABASE [CreditDB] SET DELAYED_DURABILITY = DISABLED 
GO
ALTER DATABASE [CreditDB] SET ACCELERATED_DATABASE_RECOVERY = OFF  
GO
EXEC sys.sp_db_vardecimal_storage_format N'CreditDB', N'ON'
GO
ALTER DATABASE [CreditDB] SET QUERY_STORE = ON
GO
ALTER DATABASE [CreditDB] SET QUERY_STORE (OPERATION_MODE = READ_WRITE, CLEANUP_POLICY = (STALE_QUERY_THRESHOLD_DAYS = 2), DATA_FLUSH_INTERVAL_SECONDS = 900, INTERVAL_LENGTH_MINUTES = 60, MAX_STORAGE_SIZE_MB = 1024, QUERY_CAPTURE_MODE = AUTO, SIZE_BASED_CLEANUP_MODE = AUTO, MAX_PLANS_PER_QUERY = 200, WAIT_STATS_CAPTURE_MODE = ON)
GO
USE [CreditDB]
GO
/****** Object:  Schema [msqta]    Script Date: 1/21/2025 8:21:29 PM ******/
CREATE SCHEMA [msqta]
GO
/****** Object:  UserDefinedDataType [dbo].[countrycode]    Script Date: 1/21/2025 8:21:29 PM ******/
CREATE TYPE [dbo].[countrycode] FROM [char](2) NOT NULL
GO
/****** Object:  UserDefinedDataType [dbo].[letter]    Script Date: 1/21/2025 8:21:29 PM ******/
CREATE TYPE [dbo].[letter] FROM [char](1) NOT NULL
GO
/****** Object:  UserDefinedDataType [dbo].[longstring]    Script Date: 1/21/2025 8:21:29 PM ******/
CREATE TYPE [dbo].[longstring] FROM [varchar](63) NOT NULL
GO
/****** Object:  UserDefinedDataType [dbo].[mailcode]    Script Date: 1/21/2025 8:21:29 PM ******/
CREATE TYPE [dbo].[mailcode] FROM [char](10) NOT NULL
GO
/****** Object:  UserDefinedDataType [dbo].[normstring]    Script Date: 1/21/2025 8:21:29 PM ******/
CREATE TYPE [dbo].[normstring] FROM [varchar](31) NOT NULL
GO
/****** Object:  UserDefinedDataType [dbo].[numeric_id]    Script Date: 1/21/2025 8:21:29 PM ******/
CREATE TYPE [dbo].[numeric_id] FROM [int] NOT NULL
GO
/****** Object:  UserDefinedDataType [dbo].[phonenumber]    Script Date: 1/21/2025 8:21:29 PM ******/
CREATE TYPE [dbo].[phonenumber] FROM [char](13) NOT NULL
GO
/****** Object:  UserDefinedDataType [dbo].[remarks]    Script Date: 1/21/2025 8:21:29 PM ******/
CREATE TYPE [dbo].[remarks] FROM [varchar](255) NOT NULL
GO
/****** Object:  UserDefinedDataType [dbo].[shortstring]    Script Date: 1/21/2025 8:21:29 PM ******/
CREATE TYPE [dbo].[shortstring] FROM [varchar](15) NOT NULL
GO
/****** Object:  UserDefinedDataType [dbo].[statecode]    Script Date: 1/21/2025 8:21:29 PM ******/
CREATE TYPE [dbo].[statecode] FROM [char](2) NOT NULL
GO
/****** Object:  UserDefinedDataType [dbo].[status_code]    Script Date: 1/21/2025 8:21:29 PM ******/
CREATE TYPE [dbo].[status_code] FROM [char](2) NOT NULL
GO
/****** Object:  UserDefinedDataType [dbo].[yes_no]    Script Date: 1/21/2025 8:21:29 PM ******/
CREATE TYPE [dbo].[yes_no] FROM [char](1) NOT NULL
GO
/****** Object:  UserDefinedTableType [msqta].[ExecutionStatType]    Script Date: 1/21/2025 8:21:29 PM ******/
CREATE TYPE [msqta].[ExecutionStatType] AS TABLE(
	[GroupID] [bigint] NOT NULL,
	[QueryID] [bigint] NOT NULL,
	[DatabaseName] [sysname] NOT NULL,
	[StatType] [tinyint] NOT NULL,
	[IsProfiled] [bit] NOT NULL,
	[ExecutionCount] [bigint] NOT NULL,
	[Showplan] [nvarchar](max) NULL,
	[Stats] [nvarchar](max) NOT NULL
)
GO
/****** Object:  UserDefinedTableType [msqta].[QueryOptionGroupType]    Script Date: 1/21/2025 8:21:29 PM ******/
CREATE TYPE [msqta].[QueryOptionGroupType] AS TABLE(
	[GroupID] [bigint] NOT NULL,
	[QueryID] [bigint] NOT NULL,
	[DatabaseName] [sysname] NOT NULL,
	[QueryOptions] [nvarchar](max) NOT NULL,
	[IsVerified] [bit] NOT NULL,
	[IsDeployed] [bit] NOT NULL,
	[ValidationCompleteDate] [datetime2](7) NULL
)
GO
/****** Object:  UserDefinedTableType [msqta].[TuningQueryType]    Script Date: 1/21/2025 8:21:29 PM ******/
CREATE TYPE [msqta].[TuningQueryType] AS TABLE(
	[QueryID] [bigint] NOT NULL,
	[DatabaseName] [sysname] NOT NULL,
	[ParentObjectId] [bigint] NULL,
	[QueryHash] [binary](8) NOT NULL,
	[QueryText] [nvarchar](max) NOT NULL,
	[QueryType] [tinyint] NOT NULL,
	[IsParametrized] [bit] NOT NULL,
	[PlanGuide] [nvarchar](max) NULL,
	[Status] [tinyint] NOT NULL,
	[CreateDate] [datetime2](7) NOT NULL,
	[LastModifyDate] [datetime2](7) NOT NULL,
	[ProfileCompleteDate] [datetime2](7) NULL,
	[AnalysisCompleteDate] [datetime2](7) NULL,
	[ExperimentPendingDate] [datetime2](7) NULL,
	[ExperimentCompleteDate] [datetime2](7) NULL,
	[DeployedDate] [datetime2](7) NULL,
	[AbandonedDate] [datetime2](7) NULL,
	[Parameters] [nvarchar](max) NULL
)
GO
/****** Object:  UserDefinedTableType [msqta].[TuningSessionType]    Script Date: 1/21/2025 8:21:29 PM ******/
CREATE TYPE [msqta].[TuningSessionType] AS TABLE(
	[TuningSessionID] [int] NULL,
	[DatabaseName] [sysname] NOT NULL,
	[Name] [nvarchar](300) NULL,
	[Description] [nvarchar](400) NULL,
	[Status] [tinyint] NOT NULL,
	[CreateDate] [datetime2](7) NOT NULL,
	[LastModifyDate] [datetime2](7) NOT NULL,
	[BaselineEndDate] [datetime2](7) NOT NULL,
	[UpgradeDate] [datetime2](7) NOT NULL,
	[TargetCompatLevel] [int] NOT NULL,
	[WorkloadDurationDays] [int] NOT NULL
)
GO
/****** Object:  Table [dbo].[corporation]    Script Date: 1/21/2025 8:21:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[corporation](
	[corp_no] [dbo].[numeric_id] IDENTITY(1,1) NOT NULL,
	[corp_name] [dbo].[normstring] NOT NULL,
	[street] [dbo].[shortstring] NOT NULL,
	[city] [dbo].[shortstring] NOT NULL,
	[state_prov] [dbo].[statecode] NOT NULL,
	[country] [dbo].[countrycode] NOT NULL,
	[mail_code] [dbo].[mailcode] NOT NULL,
	[phone_no] [dbo].[phonenumber] NOT NULL,
	[expr_dt] [datetime] NOT NULL,
	[region_no] [dbo].[numeric_id] NOT NULL,
	[corp_code] [dbo].[status_code] NOT NULL,
 CONSTRAINT [corporation_ident] PRIMARY KEY CLUSTERED 
(
	[corp_no] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[member]    Script Date: 1/21/2025 8:21:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[member](
	[member_no] [dbo].[numeric_id] IDENTITY(1,1) NOT NULL,
	[lastname] [dbo].[shortstring] NOT NULL,
	[firstname] [dbo].[shortstring] NOT NULL,
	[middleinitial] [dbo].[letter] NULL,
	[street] [dbo].[shortstring] NOT NULL,
	[city] [dbo].[shortstring] NOT NULL,
	[state_prov] [dbo].[statecode] NOT NULL,
	[country] [dbo].[countrycode] NOT NULL,
	[mail_code] [dbo].[mailcode] NOT NULL,
	[phone_no] [dbo].[phonenumber] NULL,
	[photograph] [image] NULL,
	[issue_dt] [datetime] NOT NULL,
	[expr_dt] [datetime] NOT NULL,
	[region_no] [dbo].[numeric_id] NOT NULL,
	[corp_no] [dbo].[numeric_id] NULL,
	[prev_balance] [money] NULL,
	[curr_balance] [money] NULL,
	[member_code] [dbo].[status_code] NOT NULL,
 CONSTRAINT [member_ident] PRIMARY KEY CLUSTERED 
(
	[member_no] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  View [dbo].[corp_member]    Script Date: 1/21/2025 8:21:29 PM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  View dbo.corp_member    Script Date: 10/13/99 6:38:01 PM ******/



/*
**  Create views for the credit database;
**    basic_member  -  Members, who do NOT have corporate cards.
**    corp_member  -  Members, who have their cards through a corporation.
**    statement_wide  -  Statements, widened to include member info.
**    payment_wide  -  Payments, widened to include member info.
**    charge_wide  -  charges, widened to include member and provider info.
**    overdue  -  Statement_wide, overdue.
**
**  One of these views is deliberately inefficient.  Rewording it
**  is one of the lab exercises.  Do not attempt to fix it here.
*/



CREATE VIEW [dbo].[corp_member]
AS
    SELECT 
         member.member_no
      ,  member.lastname
      ,  member.firstname
      ,  member.middleinitial
      ,  corporation.corp_no          
      ,  corporation.corp_name             
      ,  corporation.street           
      ,  corporation.city             
      ,  corporation.state_prov            
      ,  corporation.mail_code              
      ,  corporation.phone_no         
      ,  corporation.expr_dt        
      ,  corporation.region_no        
      ,  corporation.corp_code
    FROM member, corporation
    WHERE corporation.corp_no = member.corp_no
GO
/****** Object:  View [dbo].[basic_member]    Script Date: 1/21/2025 8:21:29 PM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/****** Object:  View dbo.basic_member    Script Date: 10/13/99 6:38:01 PM ******/



CREATE VIEW [dbo].[basic_member]
AS
    SELECT 
         member.member_no
      ,  member.lastname
      ,  member.firstname
      ,  member.middleinitial
      ,  member.street
      ,  member.city
      ,  member.state_prov
      ,  member.mail_code
      ,  member.phone_no
      ,  member.region_no
      ,  member.expr_dt
      ,  member.member_code
    FROM member
    WHERE member_no NOT IN (SELECT member_no FROM corp_member)
GO
/****** Object:  Table [dbo].[category]    Script Date: 1/21/2025 8:21:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[category](
	[category_no] [dbo].[numeric_id] IDENTITY(1,1) NOT NULL,
	[category_desc] [dbo].[normstring] NOT NULL,
	[category_code] [dbo].[status_code] NOT NULL,
 CONSTRAINT [category_ident] PRIMARY KEY CLUSTERED 
(
	[category_no] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[region]    Script Date: 1/21/2025 8:21:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[region](
	[region_no] [dbo].[numeric_id] IDENTITY(1,1) NOT NULL,
	[region_name] [dbo].[shortstring] NOT NULL,
	[street] [dbo].[shortstring] NOT NULL,
	[city] [dbo].[shortstring] NOT NULL,
	[state_prov] [dbo].[statecode] NOT NULL,
	[country] [dbo].[countrycode] NOT NULL,
	[mail_code] [dbo].[mailcode] NOT NULL,
	[phone_no] [dbo].[phonenumber] NOT NULL,
	[region_code] [dbo].[status_code] NOT NULL,
 CONSTRAINT [region_ident] PRIMARY KEY CLUSTERED 
(
	[region_no] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[provider]    Script Date: 1/21/2025 8:21:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[provider](
	[provider_no] [dbo].[numeric_id] IDENTITY(1,1) NOT NULL,
	[provider_name] [dbo].[shortstring] NOT NULL,
	[street] [dbo].[shortstring] NOT NULL,
	[city] [dbo].[shortstring] NOT NULL,
	[state_prov] [dbo].[statecode] NOT NULL,
	[mail_code] [dbo].[mailcode] NOT NULL,
	[country] [dbo].[countrycode] NOT NULL,
	[phone_no] [dbo].[phonenumber] NOT NULL,
	[issue_dt] [datetime] NOT NULL,
	[expr_dt] [datetime] NOT NULL,
	[region_no] [dbo].[numeric_id] NOT NULL,
	[provider_code] [dbo].[status_code] NOT NULL,
 CONSTRAINT [provider_ident] PRIMARY KEY CLUSTERED 
(
	[provider_no] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[charge]    Script Date: 1/21/2025 8:21:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[charge](
	[charge_no] [dbo].[numeric_id] IDENTITY(1,1) NOT NULL,
	[member_no] [dbo].[numeric_id] NOT NULL,
	[provider_no] [dbo].[numeric_id] NOT NULL,
	[category_no] [dbo].[numeric_id] NOT NULL,
	[charge_dt] [datetime] NOT NULL,
	[charge_amt] [money] NOT NULL,
	[statement_no] [dbo].[numeric_id] NOT NULL,
	[charge_code] [dbo].[status_code] NOT NULL,
 CONSTRAINT [ChargePK] PRIMARY KEY CLUSTERED 
(
	[charge_no] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[charge_wide]    Script Date: 1/21/2025 8:21:29 PM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/****** Object:  View dbo.charge_wide    Script Date: 10/13/99 6:38:01 PM ******/



CREATE VIEW [dbo].[charge_wide]
AS
    SELECT 
         member.member_no
      ,  member.lastname
      ,  member.firstname
      ,  region.region_no
      ,  region.region_name
      ,  provider.provider_name
      ,  category.category_desc
      ,  charge.charge_no        
      ,  charge.provider_no      
      ,  charge.category_no      
      ,  charge.charge_dt        
      ,  charge.charge_amt       
      ,  charge.charge_code
    FROM provider, member, region, category, charge
    WHERE member.member_no = charge.member_no 
      AND region.region_no = member.region_no
      AND provider.provider_no = charge.provider_no
      AND category.category_no = charge.category_no
GO
/****** Object:  Table [dbo].[payment]    Script Date: 1/21/2025 8:21:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[payment](
	[payment_no] [dbo].[numeric_id] IDENTITY(1,1) NOT NULL,
	[member_no] [dbo].[numeric_id] NOT NULL,
	[payment_dt] [datetime] NOT NULL,
	[payment_amt] [money] NOT NULL,
	[statement_no] [dbo].[numeric_id] NULL,
	[payment_code] [dbo].[status_code] NOT NULL,
 CONSTRAINT [payment_ident] PRIMARY KEY NONCLUSTERED 
(
	[payment_no] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[payment_wide]    Script Date: 1/21/2025 8:21:29 PM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/****** Object:  View dbo.payment_wide    Script Date: 10/13/99 6:38:01 PM ******/



CREATE VIEW [dbo].[payment_wide]
AS
    SELECT 
         member.member_no
      ,  member.lastname
      ,  member.firstname
      ,  member.middleinitial
      ,  member.street
      ,  member.city
      ,  member.state_prov
      ,  member.mail_code
      ,  member.phone_no
      ,  member.expr_dt
      ,  member.member_code
      ,  region.region_no
      ,  region.region_name
      ,  payment.payment_no       
      ,  payment.payment_dt       
      ,  payment.payment_amt      

      ,  payment.payment_code
    FROM member, region, payment
    WHERE member.member_no = payment.member_no 
      AND region.region_no = member.region_no
GO
/****** Object:  Table [dbo].[statement]    Script Date: 1/21/2025 8:21:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[statement](
	[statement_no] [dbo].[numeric_id] IDENTITY(1,1) NOT NULL,
	[member_no] [dbo].[numeric_id] NOT NULL,
	[statement_dt] [datetime] NOT NULL,
	[due_dt] [datetime] NOT NULL,
	[statement_amt] [money] NOT NULL,
	[statement_code] [dbo].[status_code] NOT NULL,
 CONSTRAINT [statement_ident] PRIMARY KEY CLUSTERED 
(
	[statement_no] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[statement_wide]    Script Date: 1/21/2025 8:21:29 PM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/****** Object:  View dbo.statement_wide    Script Date: 10/13/99 6:38:01 PM ******/



CREATE VIEW [dbo].[statement_wide]
AS
    SELECT 
         member.member_no
      ,  member.lastname
      ,  member.firstname
      ,  member.middleinitial
      ,  member.street
      ,  member.city
      ,  member.state_prov
      ,  member.mail_code
      ,  member.phone_no
      ,  member.expr_dt
      ,  member.member_code
      ,  region.region_no
      ,  region.region_name
      ,  statement.statement_no     
      ,  statement.statement_dt     
      ,  statement.due_dt           
      ,  statement.statement_amt    
      ,  statement.statement_code      
    FROM member, region, statement
    WHERE member.member_no = statement.member_no 
      AND region.region_no = member.region_no
GO
/****** Object:  View [dbo].[overdue]    Script Date: 1/21/2025 8:21:29 PM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/****** Object:  View dbo.overdue    Script Date: 10/13/99 6:38:01 PM ******/



CREATE VIEW [dbo].[overdue]
AS
    SELECT *
    FROM statement_wide
    WHERE due_dt < GETDATE()
GO
/****** Object:  View [dbo].[test]    Script Date: 1/21/2025 8:21:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[test]
with schemabinding
as select member_no, lastname, firstname
from dbo.member
GO
/****** Object:  View [dbo].[test2]    Script Date: 1/21/2025 8:21:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[test2]
with schemabinding
as
select member_no, lastname
from dbo.test
GO
/****** Object:  Table [dbo].[member2]    Script Date: 1/21/2025 8:21:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[member2](
	[member_no] [dbo].[numeric_id] NOT NULL,
	[lastname] [dbo].[shortstring] NOT NULL,
	[firstname] [dbo].[shortstring] NOT NULL,
	[middleinitial] [dbo].[letter] NULL,
	[street] [dbo].[shortstring] NOT NULL,
	[city] [dbo].[shortstring] NOT NULL,
	[state_prov] [dbo].[statecode] NOT NULL,
	[country] [dbo].[countrycode] NOT NULL,
	[mail_code] [dbo].[mailcode] NOT NULL,
	[phone_no] [dbo].[phonenumber] NULL,
	[photograph] [image] NULL,
	[issue_dt] [datetime] NOT NULL,
	[expr_dt] [datetime] NOT NULL,
	[region_no] [dbo].[numeric_id] NOT NULL,
	[corp_no] [dbo].[numeric_id] NULL,
	[prev_balance] [money] NULL,
	[curr_balance] [money] NULL,
	[member_code] [dbo].[status_code] NOT NULL,
 CONSTRAINT [member2PK] PRIMARY KEY NONCLUSTERED 
(
	[member_no] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Index [member2Cl]    Script Date: 1/21/2025 8:21:29 PM ******/
CREATE CLUSTERED INDEX [member2Cl] ON [dbo].[member2]
(
	[lastname] ASC,
	[firstname] ASC,
	[middleinitial] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[status]    Script Date: 1/21/2025 8:21:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[status](
	[status_code] [dbo].[status_code] NOT NULL,
	[status_desc] [dbo].[normstring] NOT NULL,
 CONSTRAINT [status_ident] PRIMARY KEY CLUSTERED 
(
	[status_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [msqta].[ExecutionStat]    Script Date: 1/21/2025 8:21:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [msqta].[ExecutionStat](
	[StatID] [bigint] IDENTITY(1,1) NOT NULL,
	[GroupID] [bigint] NOT NULL,
	[StatType] [tinyint] NOT NULL,
	[IsProfiled] [bit] NOT NULL,
	[ExecutionCount] [bigint] NOT NULL,
	[Showplan] [nvarchar](max) NULL,
	[Stats] [nvarchar](max) NOT NULL,
 CONSTRAINT [PkExecutionStat_StatID] PRIMARY KEY CLUSTERED 
(
	[StatID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [msqta].[MetaData]    Script Date: 1/21/2025 8:21:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [msqta].[MetaData](
	[Property] [nvarchar](50) NOT NULL,
	[Value] [nvarchar](max) NOT NULL,
UNIQUE NONCLUSTERED 
(
	[Property] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [msqta].[QueryOptionGroup]    Script Date: 1/21/2025 8:21:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [msqta].[QueryOptionGroup](
	[GroupID] [bigint] IDENTITY(1,1) NOT NULL,
	[TuningQueryID] [bigint] NOT NULL,
	[QueryOptions] [nvarchar](max) NOT NULL,
	[IsVerified] [bit] NOT NULL,
	[IsDeployed] [bit] NOT NULL,
	[ValidationCompleteDate] [datetime2](7) NULL,
 CONSTRAINT [PkQueryOptionGroup_GroupID] PRIMARY KEY CLUSTERED 
(
	[GroupID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [msqta].[TuningQuery]    Script Date: 1/21/2025 8:21:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [msqta].[TuningQuery](
	[TuningQueryID] [bigint] IDENTITY(1,1) NOT NULL,
	[QueryID] [bigint] NOT NULL,
	[DatabaseID] [int] NOT NULL,
	[ParentObjectId] [bigint] NULL,
	[QueryHash] [binary](8) NOT NULL,
	[QueryText] [nvarchar](max) NOT NULL,
	[QueryType] [tinyint] NOT NULL,
	[IsParametrized] [bit] NOT NULL,
	[PlanGuide] [nvarchar](max) NULL,
	[Status] [tinyint] NOT NULL,
	[CreateDate] [datetime2](7) NOT NULL,
	[LastModifyDate] [datetime2](7) NOT NULL,
	[ProfileCompleteDate] [datetime2](7) NULL,
	[AnalysisCompleteDate] [datetime2](7) NULL,
	[ExperimentPendingDate] [datetime2](7) NULL,
	[ExperimentCompleteDate] [datetime2](7) NULL,
	[DeployedDate] [datetime2](7) NULL,
	[AbandonedDate] [datetime2](7) NULL,
	[Parameters] [nvarchar](max) NULL,
 CONSTRAINT [PkTuningQuery_TuningQueryID] PRIMARY KEY CLUSTERED 
(
	[TuningQueryID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [msqta].[TuningSession]    Script Date: 1/21/2025 8:21:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [msqta].[TuningSession](
	[TuningSessionID] [int] IDENTITY(1,1) NOT NULL,
	[DatabaseID] [int] NOT NULL,
	[Name] [nvarchar](300) NULL,
	[Description] [nvarchar](400) NULL,
	[Status] [tinyint] NOT NULL,
	[CreateDate] [datetime2](7) NOT NULL,
	[LastModifyDate] [datetime2](7) NOT NULL,
	[BaselineEndDate] [datetime2](7) NOT NULL,
	[UpgradeDate] [datetime2](7) NOT NULL,
	[TargetCompatLevel] [int] NOT NULL,
	[WorkloadDurationDays] [int] NOT NULL,
 CONSTRAINT [PkTuningSession_TuningSessionID] PRIMARY KEY CLUSTERED 
(
	[TuningSessionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [msqta].[TuningSession_TuningQuery]    Script Date: 1/21/2025 8:21:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [msqta].[TuningSession_TuningQuery](
	[TuningSessionID] [int] NOT NULL,
	[TuningQueryID] [bigint] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Index [charge_category_link]    Script Date: 1/21/2025 8:21:29 PM ******/
CREATE NONCLUSTERED INDEX [charge_category_link] ON [dbo].[charge]
(
	[category_no] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [charge_provider_link]    Script Date: 1/21/2025 8:21:29 PM ******/
CREATE NONCLUSTERED INDEX [charge_provider_link] ON [dbo].[charge]
(
	[provider_no] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [charge_statement_link]    Script Date: 1/21/2025 8:21:29 PM ******/
CREATE NONCLUSTERED INDEX [charge_statement_link] ON [dbo].[charge]
(
	[statement_no] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [corporation_region_link]    Script Date: 1/21/2025 8:21:29 PM ******/
CREATE NONCLUSTERED INDEX [corporation_region_link] ON [dbo].[corporation]
(
	[region_no] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [member_corporation_link]    Script Date: 1/21/2025 8:21:29 PM ******/
CREATE NONCLUSTERED INDEX [member_corporation_link] ON [dbo].[member]
(
	[corp_no] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [member_region_link]    Script Date: 1/21/2025 8:21:29 PM ******/
CREATE NONCLUSTERED INDEX [member_region_link] ON [dbo].[member]
(
	[region_no] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [member2CorpFK]    Script Date: 1/21/2025 8:21:29 PM ******/
CREATE NONCLUSTERED INDEX [member2CorpFK] ON [dbo].[member2]
(
	[corp_no] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [member2RegionFK]    Script Date: 1/21/2025 8:21:29 PM ******/
CREATE NONCLUSTERED INDEX [member2RegionFK] ON [dbo].[member2]
(
	[region_no] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [payment_member_link]    Script Date: 1/21/2025 8:21:29 PM ******/
CREATE NONCLUSTERED INDEX [payment_member_link] ON [dbo].[payment]
(
	[member_no] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [provider_region_link]    Script Date: 1/21/2025 8:21:29 PM ******/
CREATE NONCLUSTERED INDEX [provider_region_link] ON [dbo].[provider]
(
	[region_no] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [statement_member_link]    Script Date: 1/21/2025 8:21:29 PM ******/
CREATE NONCLUSTERED INDEX [statement_member_link] ON [dbo].[statement]
(
	[member_no] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IDX_Un_TuningSession_DatabaseID_Name]    Script Date: 1/21/2025 8:21:29 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IDX_Un_TuningSession_DatabaseID_Name] ON [msqta].[TuningSession]
(
	[DatabaseID] ASC,
	[Name] ASC
)
WHERE ([Name] IS NOT NULL)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [dbo].[category] ADD  CONSTRAINT [category_status_default]  DEFAULT ('  ') FOR [category_code]
GO
ALTER TABLE [dbo].[charge] ADD  CONSTRAINT [charge_statement_no_default]  DEFAULT (0) FOR [statement_no]
GO
ALTER TABLE [dbo].[charge] ADD  CONSTRAINT [charge_status_default]  DEFAULT ('  ') FOR [charge_code]
GO
ALTER TABLE [dbo].[corporation] ADD  CONSTRAINT [corporation_status_default]  DEFAULT ('  ') FOR [corp_code]
GO
ALTER TABLE [dbo].[member] ADD  CONSTRAINT [member_issue_dt_default]  DEFAULT (getdate()) FOR [issue_dt]
GO
ALTER TABLE [dbo].[member] ADD  CONSTRAINT [member_expr_dt_default]  DEFAULT (dateadd(year,1,getdate())) FOR [expr_dt]
GO
ALTER TABLE [dbo].[member] ADD  CONSTRAINT [member_prev_balance_default]  DEFAULT (0) FOR [prev_balance]
GO
ALTER TABLE [dbo].[member] ADD  CONSTRAINT [member_curr_balance_default]  DEFAULT (0) FOR [curr_balance]
GO
ALTER TABLE [dbo].[member] ADD  CONSTRAINT [member_status_default]  DEFAULT ('  ') FOR [member_code]
GO
ALTER TABLE [dbo].[payment] ADD  CONSTRAINT [payment_statement_no_default]  DEFAULT (0) FOR [statement_no]
GO
ALTER TABLE [dbo].[payment] ADD  CONSTRAINT [payment_status_default]  DEFAULT ('  ') FOR [payment_code]
GO
ALTER TABLE [dbo].[provider] ADD  CONSTRAINT [provider_issue_dt_default]  DEFAULT (getdate()) FOR [issue_dt]
GO
ALTER TABLE [dbo].[provider] ADD  CONSTRAINT [provider_expr_dt_default]  DEFAULT (dateadd(year,1,getdate())) FOR [expr_dt]
GO
ALTER TABLE [dbo].[provider] ADD  CONSTRAINT [provider_status_default]  DEFAULT ('  ') FOR [provider_code]
GO
ALTER TABLE [dbo].[region] ADD  CONSTRAINT [region_status_default]  DEFAULT ('  ') FOR [region_code]
GO
ALTER TABLE [dbo].[statement] ADD  CONSTRAINT [statement_status_default]  DEFAULT ('  ') FOR [statement_code]
GO
ALTER TABLE [dbo].[charge]  WITH CHECK ADD  CONSTRAINT [charge_category_link] FOREIGN KEY([category_no])
REFERENCES [dbo].[category] ([category_no])
GO
ALTER TABLE [dbo].[charge] CHECK CONSTRAINT [charge_category_link]
GO
ALTER TABLE [dbo].[charge]  WITH CHECK ADD  CONSTRAINT [charge_member_link] FOREIGN KEY([member_no])
REFERENCES [dbo].[member] ([member_no])
GO
ALTER TABLE [dbo].[charge] CHECK CONSTRAINT [charge_member_link]
GO
ALTER TABLE [dbo].[charge]  WITH CHECK ADD  CONSTRAINT [charge_provider_link] FOREIGN KEY([provider_no])
REFERENCES [dbo].[provider] ([provider_no])
GO
ALTER TABLE [dbo].[charge] CHECK CONSTRAINT [charge_provider_link]
GO
ALTER TABLE [dbo].[corporation]  WITH CHECK ADD  CONSTRAINT [corporation_region_link] FOREIGN KEY([region_no])
REFERENCES [dbo].[region] ([region_no])
GO
ALTER TABLE [dbo].[corporation] CHECK CONSTRAINT [corporation_region_link]
GO
ALTER TABLE [dbo].[member]  WITH CHECK ADD  CONSTRAINT [member_corporation_link] FOREIGN KEY([corp_no])
REFERENCES [dbo].[corporation] ([corp_no])
GO
ALTER TABLE [dbo].[member] CHECK CONSTRAINT [member_corporation_link]
GO
ALTER TABLE [dbo].[member]  WITH CHECK ADD  CONSTRAINT [member_region_link] FOREIGN KEY([region_no])
REFERENCES [dbo].[region] ([region_no])
GO
ALTER TABLE [dbo].[member] CHECK CONSTRAINT [member_region_link]
GO
ALTER TABLE [dbo].[payment]  WITH CHECK ADD  CONSTRAINT [payment_member_link] FOREIGN KEY([member_no])
REFERENCES [dbo].[member] ([member_no])
GO
ALTER TABLE [dbo].[payment] CHECK CONSTRAINT [payment_member_link]
GO
ALTER TABLE [dbo].[provider]  WITH CHECK ADD  CONSTRAINT [provider_region_link] FOREIGN KEY([region_no])
REFERENCES [dbo].[region] ([region_no])
GO
ALTER TABLE [dbo].[provider] CHECK CONSTRAINT [provider_region_link]
GO
ALTER TABLE [dbo].[statement]  WITH CHECK ADD  CONSTRAINT [statement_member_link] FOREIGN KEY([member_no])
REFERENCES [dbo].[member] ([member_no])
GO
ALTER TABLE [dbo].[statement] CHECK CONSTRAINT [statement_member_link]
GO
ALTER TABLE [msqta].[ExecutionStat]  WITH CHECK ADD  CONSTRAINT [FkExecutionStat_GroupID] FOREIGN KEY([GroupID])
REFERENCES [msqta].[QueryOptionGroup] ([GroupID])
ON DELETE CASCADE
GO
ALTER TABLE [msqta].[ExecutionStat] CHECK CONSTRAINT [FkExecutionStat_GroupID]
GO
ALTER TABLE [msqta].[QueryOptionGroup]  WITH CHECK ADD  CONSTRAINT [FkQueryOptionGroup_TuningQueryID] FOREIGN KEY([TuningQueryID])
REFERENCES [msqta].[TuningQuery] ([TuningQueryID])
ON DELETE CASCADE
GO
ALTER TABLE [msqta].[QueryOptionGroup] CHECK CONSTRAINT [FkQueryOptionGroup_TuningQueryID]
GO
ALTER TABLE [msqta].[TuningSession_TuningQuery]  WITH CHECK ADD  CONSTRAINT [FkTuningSession_TuningQuery_TuningQueryID] FOREIGN KEY([TuningQueryID])
REFERENCES [msqta].[TuningQuery] ([TuningQueryID])
ON DELETE CASCADE
GO
ALTER TABLE [msqta].[TuningSession_TuningQuery] CHECK CONSTRAINT [FkTuningSession_TuningQuery_TuningQueryID]
GO
ALTER TABLE [msqta].[TuningSession_TuningQuery]  WITH CHECK ADD  CONSTRAINT [FkTuningSession_TuningQuery_TuningSessionID] FOREIGN KEY([TuningSessionID])
REFERENCES [msqta].[TuningSession] ([TuningSessionID])
ON DELETE CASCADE
GO
ALTER TABLE [msqta].[TuningSession_TuningQuery] CHECK CONSTRAINT [FkTuningSession_TuningQuery_TuningSessionID]
GO
ALTER TABLE [dbo].[payment]  WITH NOCHECK ADD  CONSTRAINT [payment_amount_rule] CHECK  (([payment_amt] <> 0))
GO
ALTER TABLE [dbo].[payment] CHECK CONSTRAINT [payment_amount_rule]
GO
ALTER TABLE [dbo].[statement]  WITH NOCHECK ADD  CONSTRAINT [statement_dt_rule] CHECK  (([due_dt] >= [statement_dt]))
GO
ALTER TABLE [dbo].[statement] CHECK CONSTRAINT [statement_dt_rule]
GO
/****** Object:  StoredProcedure [dbo].[addcategory]    Script Date: 1/21/2025 8:21:29 PM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/****** Object:  Stored Procedure dbo.addcategory    Script Date: 10/13/99 6:38:02 PM ******/


CREATE PROCEDURE [dbo].[addcategory]
    @category_desc    shortstring
AS 
    INSERT category
        (  category_desc)
      VALUES    
        ( @category_desc)

    IF @@error != 0
       RETURN (-99)
    ELSE
       RETURN 0
GO
/****** Object:  StoredProcedure [dbo].[addcorporation]    Script Date: 1/21/2025 8:21:29 PM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/****** Object:  Stored Procedure dbo.addcorporation    Script Date: 10/13/99 6:38:02 PM ******/


CREATE PROCEDURE [dbo].[addcorporation]
    @region_no        numeric_id
  , @corp_name        normstring
  , @street           shortstring
  , @city             shortstring
  , @state_prov       statecode
  , @country          countrycode
  , @mail_code        mailcode
  , @phone_no         phonenumber 
  , @expr_dt          datetime
AS 
    INSERT corporation
        (  region_no,  corp_name,  street,  city,  state_prov,  country,  mail_code,  phone_no,  expr_dt)
      VALUES    
        ( @region_no, @corp_name, @street, @city, @state_prov, @country, @mail_code, @phone_no, @expr_dt)

    IF @@error != 0
       RETURN (-99)
    ELSE
       RETURN 0
GO
/****** Object:  StoredProcedure [dbo].[addmember]    Script Date: 1/21/2025 8:21:29 PM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/****** Object:  Stored Procedure dbo.addmember    Script Date: 10/13/99 6:38:02 PM ******/



CREATE PROCEDURE [dbo].[addmember]
    @region_no        numeric_id
  , @corp_no          numeric_id
  , @lastname         shortstring
  , @firstname        shortstring
  , @middleinitial    shortstring
  , @street           shortstring
  , @city             shortstring
  , @state_prov       statecode
  , @country          countrycode
  , @mail_code        mailcode
  , @phone_no         phonenumber 
AS 
    INSERT member
        (  region_no,  corp_no,  lastname,  firstname,  middleinitial,  street,  city,  state_prov,  country,  mail_code,  phone_no)
      VALUES    
        ( @region_no, @corp_no, @lastname, @firstname, @middleinitial, @street, @city, @state_prov, @country, @mail_code, @phone_no)

    IF @@error != 0
       RETURN (-99)
    ELSE
       RETURN 0
GO
/****** Object:  StoredProcedure [dbo].[addprovider]    Script Date: 1/21/2025 8:21:29 PM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/****** Object:  Stored Procedure dbo.addprovider    Script Date: 10/13/99 6:38:02 PM ******/


CREATE PROCEDURE [dbo].[addprovider]
    @region_no        numeric_id
  , @provider_name    shortstring
  , @street           shortstring
  , @city             shortstring
  , @state_prov       statecode
  , @country          countrycode
  , @mail_code        mailcode
  , @phone_no         phonenumber 
AS 
    INSERT provider
        (  region_no,  provider_name,  street,  city,  state_prov,  country,  mail_code,  phone_no)
      VALUES    
        ( @region_no, @provider_name, @street, @city, @state_prov, @country, @mail_code, @phone_no)

    IF @@error != 0
       RETURN (-99)
    ELSE
       RETURN 0
GO
/****** Object:  StoredProcedure [dbo].[addregion]    Script Date: 1/21/2025 8:21:29 PM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/****** Object:  Stored Procedure dbo.addregion    Script Date: 10/13/99 6:38:02 PM ******/


CREATE PROCEDURE [dbo].[addregion]
    @region_name      shortstring
  , @street           shortstring
  , @city             shortstring
  , @state_prov       statecode
  , @country          countrycode
  , @mail_code        mailcode
  , @phone_no         phonenumber 
AS 
    INSERT region
        (  region_name,  street,  city,  state_prov,  country,  mail_code,  phone_no)
      VALUES    
        ( @region_name, @street, @city, @state_prov, @country, @mail_code, @phone_no)

    IF @@error != 0
       RETURN (-99)
    ELSE
       RETURN 0
GO
/****** Object:  StoredProcedure [dbo].[generate_firstname]    Script Date: 1/21/2025 8:21:29 PM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.generate_firstname    Script Date: 10/13/99 6:38:01 PM ******/



CREATE PROCEDURE [dbo].[generate_firstname] 
   @firstname shortstring OUTPUT 
AS
BEGIN
   DECLARE @limit int
   DECLARE @curr_iteration int
   SELECT @limit = round((rand() * 20) + 3, 0)
   SELECT @curr_iteration = 0
   SELECT @firstname = ''
   WHILE @curr_iteration < @limit
   BEGIN
      SELECT @firstname = @firstname + char(round((rand() * 25) + 1, 0) + 64)
      SELECT @curr_iteration = @curr_iteration + 1
   END
   IF SUBSTRING(@firstname,1,1) = ' '
   BEGIN
      SELECT @firstname = SUBSTRING(@firstname,2,16)
   END
END
GO
/****** Object:  StoredProcedure [dbo].[generatestatement]    Script Date: 1/21/2025 8:21:29 PM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/****** Object:  Stored Procedure dbo.generatestatement    Script Date: 10/13/99 6:38:03 PM ******/


CREATE PROCEDURE [dbo].[generatestatement] 
    @member_no numeric_id
  , @statement_dt datetime  
AS
BEGIN
   DECLARE @due_dt datetime        SELECT @due_dt = DATEADD(day,20,@statement_dt)
   DECLARE @statement_amt money

   BEGIN TRANSACTION

   SELECT @statement_amt = ISNULL(SUM(charge_amt),0)
   FROM charge (TABLOCKX HOLDLOCK)
   WHERE member_no = @member_no 
     AND statement_no = 0
     AND charge_dt <= @statement_dt

   INSERT statement (member_no        
                  ,  statement_dt     
                  ,  due_dt           
                  ,  statement_amt    
                  ,  statement_code
                  )
   VALUES (@member_no
        ,  @statement_dt
        ,  @due_dt
        ,  @statement_amt
        ,  ' '
        )

   UPDATE charge
   SET statement_no = @@IDENTITY
   WHERE member_no = @member_no 
     AND statement_no = 0
     AND charge_dt <= @statement_dt

   COMMIT TRANSACTION
END
GO
/****** Object:  StoredProcedure [dbo].[inputcharge]    Script Date: 1/21/2025 8:21:29 PM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO

/****** Object:  Stored Procedure dbo.inputcharge    Script Date: 10/13/99 6:38:03 PM ******/


CREATE PROCEDURE [dbo].[inputcharge]
    @member_no        numeric_id   
  , @provider_no      numeric_id   
  , @category_no      numeric_id   
  , @charge_dt        datetime     
  , @charge_amt       money        
AS 
BEGIN
  BEGIN TRANSACTION
  IF @@error = 0
    INSERT charge 
        (  member_no,  provider_no,  category_no,  charge_dt,  charge_amt )
      VALUES    
        ( @member_no, @provider_no, @category_no, @charge_dt, @charge_amt )
  IF @@error = 0
    COMMIT TRANSACTION
  IF @@error = 0
    RETURN 0

  ROLLBACK TRANSACTION
  RAISERROR ('Stored procedure "inputcharge" failed', 16, -1)
  RETURN (-99)
END
GO
/****** Object:  StoredProcedure [dbo].[inputpayment]    Script Date: 1/21/2025 8:21:29 PM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO

/****** Object:  Stored Procedure dbo.inputpayment    Script Date: 10/13/99 6:38:03 PM ******/


CREATE PROCEDURE [dbo].[inputpayment]
    @member_no        numeric_id   
  , @payment_dt       datetime     
  , @payment_amt      money        
AS 
BEGIN
  BEGIN TRANSACTION
  IF @@error = 0
    INSERT payment
        (  member_no,  payment_dt,  payment_amt )
      VALUES    
        ( @member_no, @payment_dt, @payment_amt )
  IF @@error = 0
    COMMIT TRANSACTION
  IF @@error = 0
    RETURN 0

  ROLLBACK TRANSACTION
  RAISERROR ('Stored procedure "inputpayment" failed', 16, -1)
  RETURN (-99)
END
GO
/****** Object:  StoredProcedure [dbo].[load_charges]    Script Date: 1/21/2025 8:21:29 PM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/****** Object:  Stored Procedure dbo.load_charges    Script Date: 10/13/99 6:38:03 PM ******/

CREATE PROCEDURE [dbo].[load_charges] 
    @target_charge_count int
AS
BEGIN
   DECLARE @charge_category_no int
   DECLARE @charge_provider_no int
   DECLARE @charge_member_no int
   DECLARE @charge_charge_dt datetime
   DECLARE @charge_charge_amt money

   DECLARE @no_of_members int       SELECT @no_of_members = COUNT(*) FROM member
   DECLARE @no_of_providers int     SELECT @no_of_providers = COUNT(*) FROM provider
   DECLARE @no_of_categories int    SELECT @no_of_categories = COUNT(*) FROM category

   DECLARE @tran_size int           SELECT @tran_size = 4000

   BEGIN TRANSACTION
   WHILE @target_charge_count > 0
   BEGIN
      SELECT @target_charge_count = @target_charge_count - 1
      IF (@target_charge_count % @tran_size = 0) 

      BEGIN
         COMMIT TRANSACTION
         DUMP TRANSACTION credit WITH TRUNCATE_ONLY
         BEGIN TRANSACTION
      END

      EXEC @charge_category_no = skewed_rand @no_of_categories, 1
      EXEC @charge_provider_no = skewed_rand @no_of_providers, 3
      EXEC @charge_member_no   = skewed_rand @no_of_members, 2
      SELECT @charge_charge_dt = dateadd(day, -(rand()*120), getdate())
      SELECT @charge_charge_amt = convert(money, round((rand() * 5000 + 1), 0))

      EXEC inputcharge
          @member_no        = @charge_member_no   
        , @provider_no      = @charge_provider_no
        , @category_no      = @charge_category_no
        , @charge_dt        = @charge_charge_dt
        , @charge_amt       = @charge_charge_amt
   END
   COMMIT TRANSACTION
END
GO
/****** Object:  StoredProcedure [dbo].[load_members]    Script Date: 1/21/2025 8:21:29 PM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/****** Object:  Stored Procedure dbo.load_members    Script Date: 10/13/99 6:38:03 PM ******/



CREATE PROCEDURE [dbo].[load_members] 
   @target_member_count int 
AS
BEGIN
   DECLARE @member_region_no numeric_id
   DECLARE @member_corp_no numeric_id
   DECLARE @member_lastname shortstring
   DECLARE @member_firstname shortstring

   DECLARE @no_of_regions int      SELECT @no_of_regions = COUNT(*) FROM region
   DECLARE @no_of_corps int        SELECT @no_of_corps = COUNT(*) FROM corporation
   DECLARE @no_of_corps_t5 int     SELECT @no_of_corps_t5 = @no_of_corps * 2

   DECLARE tnames_cursor CURSOR FOR SELECT lastname FROM lastname_table

   WHILE @target_member_count > 0
   BEGIN
      BEGIN TRANSACTION

      OPEN tnames_cursor
      WHILE (@@FETCH_STATUS = @@FETCH_STATUS)
      BEGIN
         FETCH NEXT FROM tnames_cursor INTO @member_lastname
         IF (@@FETCH_STATUS <> 0)
            BREAK
         EXEC @member_region_no = skewed_rand @no_of_regions, 1
         EXEC @member_corp_no = skewed_rand @no_of_corps_t5, 2
         IF (@member_corp_no > @no_of_corps) SELECT @member_corp_no = NULL
         EXEC generate_firstname @member_firstname OUTPUT
         EXEC addmember
             @region_no        = @member_region_no
           , @corp_no          = @member_corp_no
           , @lastname         = @member_lastname
           , @firstname        = @member_firstname
           , @middleinitial    = ' '
           , @street           = '  '
           , @city             = '  '
           , @state_prov       = '  '
           , @country          = '  '
           , @mail_code        = '  '
           , @phone_no         = '  '
         SELECT @target_member_count = @target_member_count - 1
      END
      CLOSE tnames_cursor

      COMMIT TRANSACTION
      DUMP TRANSACTION credit WITH TRUNCATE_ONLY
   END
   DEALLOCATE tnames_cursor
END
GO
/****** Object:  StoredProcedure [dbo].[load_payments]    Script Date: 1/21/2025 8:21:29 PM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/****** Object:  Stored Procedure dbo.load_payments    Script Date: 10/13/99 6:38:03 PM ******/

CREATE PROCEDURE [dbo].[load_payments] 
    @starting_dt datetime
  , @ending_dt datetime
AS
BEGIN
   DECLARE @batch_size int                   SELECT @batch_size = 1000

   DECLARE @member_no numeric_id
   DECLARE @due_dt datetime
   DECLARE @statement_amt money

   DECLARE @highest_member_no numeric_id     SELECT @highest_member_no = COUNT(*) FROM member

   DECLARE @starting_member_no numeric_id  SELECT @starting_member_no = 1
   DECLARE @ending_member_no numeric_id    SELECT @ending_member_no = @batch_size

   SELECT @starting_dt = CONVERT(CHAR(12),@starting_dt,9)
   SELECT @ending_dt = CONVERT(CHAR(12),@ending_dt,9)    

   DECLARE statements_cursor CURSOR FOR 
      SELECT member_no, due_dt, statement_amt
      FROM statement
      WHERE member_no BETWEEN @starting_member_no AND @ending_member_no
        AND statement_dt > @starting_dt AND statement_dt <= @ending_dt 
        AND statement_amt > 0

   WHILE @starting_member_no <= @highest_member_no
   BEGIN
      BEGIN TRANSACTION
      OPEN statements_cursor

      WHILE (@@FETCH_STATUS = @@FETCH_STATUS)
      BEGIN
         FETCH NEXT FROM statements_cursor INTO @member_no, @due_dt, @statement_amt
         IF (@@FETCH_STATUS <> 0)
            BREAK
         EXEC inputpayment @member_no, @due_dt, @statement_amt
      END

      CLOSE statements_cursor
      COMMIT TRANSACTION
      DUMP TRANSACTION credit WITH NO_LOG

      SELECT @starting_member_no = @ending_member_no + 1
      SELECT @ending_member_no = @ending_member_no + @batch_size
   END

   DEALLOCATE statements_cursor
END
GO
/****** Object:  StoredProcedure [dbo].[load_statements]    Script Date: 1/21/2025 8:21:29 PM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/****** Object:  Stored Procedure dbo.load_statements    Script Date: 10/13/99 6:38:03 PM ******/

CREATE PROCEDURE [dbo].[load_statements] 
   @statement_dt datetime
AS
BEGIN
   DECLARE @batch_size int                 SELECT @batch_size = 100
   DECLARE @starting_member_no numeric_id  SELECT @starting_member_no = 1
   DECLARE @ending_member_no numeric_id    SELECT @ending_member_no = COUNT(*) FROM member
   DECLARE @member_no numeric_id           SELECT @member_no = @starting_member_no - 1

   SELECT @statement_dt = CONVERT(CHAR(12),@statement_dt,9)               --  Trim off the time.

   BEGIN TRANSACTION
   WHILE @member_no < @ending_member_no
   BEGIN
      SELECT @member_no = @member_no + 1

      IF @member_no % @batch_size = 0 
      BEGIN
         COMMIT TRANSACTION
         DUMP TRANSACTION credit WITH TRUNCATE_ONLY
         BEGIN TRANSACTION
      END

      EXEC generatestatement @member_no, @statement_dt
   END
   COMMIT TRANSACTION
   DUMP TRANSACTION credit WITH TRUNCATE_ONLY
END
GO
/****** Object:  StoredProcedure [dbo].[pto_locktable]    Script Date: 1/21/2025 8:21:29 PM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/****** Object:  Stored Procedure dbo.pto_locktable    Script Date: 10/13/99 6:38:01 PM ******/


CREATE PROCEDURE [dbo].[pto_locktable] 
    @table_name sysname
AS
BEGIN
   EXECUTE ('DECLARE @scratch int IF EXISTS (SELECT * FROM ' + @table_name + ' (TABLOCKX HOLDLOCK)) BEGIN SELECT @scratch = @scratch END')
END
GO
/****** Object:  StoredProcedure [dbo].[removecategory]    Script Date: 1/21/2025 8:21:29 PM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/****** Object:  Stored Procedure dbo.removecategory    Script Date: 10/13/99 6:38:02 PM ******/


CREATE PROCEDURE [dbo].[removecategory]
    @category_no    numeric_id
AS 
    DELETE category
      WHERE category_no = @category_no

    IF @@error != 0
       RETURN (-99)
    ELSE
       RETURN 0
GO
/****** Object:  StoredProcedure [dbo].[removecorporation]    Script Date: 1/21/2025 8:21:29 PM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/****** Object:  Stored Procedure dbo.removecorporation    Script Date: 10/13/99 6:38:02 PM ******/


CREATE PROCEDURE [dbo].[removecorporation]
    @corp_no    numeric_id
AS 
    DELETE corporation
      WHERE corp_no = @corp_no

    IF @@error != 0
       RETURN (-99)
    ELSE
       RETURN 0
GO
/****** Object:  StoredProcedure [dbo].[removemember]    Script Date: 1/21/2025 8:21:29 PM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/****** Object:  Stored Procedure dbo.removemember    Script Date: 10/13/99 6:38:03 PM ******/


CREATE PROCEDURE [dbo].[removemember]
    @member_no    numeric_id
AS 
    DELETE member
      WHERE member_no = @member_no

    IF @@error != 0
       RETURN (-99)
    ELSE
       RETURN 0
GO
/****** Object:  StoredProcedure [dbo].[removeprovider]    Script Date: 1/21/2025 8:21:29 PM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/****** Object:  Stored Procedure dbo.removeprovider    Script Date: 10/13/99 6:38:02 PM ******/


CREATE PROCEDURE [dbo].[removeprovider]
    @provider_no    numeric_id
AS 
    DELETE provider
      WHERE provider_no = @provider_no

    IF @@error != 0
       RETURN (-99)
    ELSE
       RETURN 0
GO
/****** Object:  StoredProcedure [dbo].[removeregion]    Script Date: 1/21/2025 8:21:29 PM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/****** Object:  Stored Procedure dbo.removeregion    Script Date: 10/13/99 6:38:02 PM ******/


CREATE PROCEDURE [dbo].[removeregion]
    @region_no    numeric_id
AS 
    DELETE region
      WHERE region_no = @region_no

    IF @@error != 0
       RETURN (-99)
    ELSE
       RETURN 0
GO
/****** Object:  StoredProcedure [dbo].[show_dist]    Script Date: 1/21/2025 8:21:29 PM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/****** Object:  Stored Procedure dbo.show_dist    Script Date: 10/13/99 6:38:01 PM ******/

CREATE PROCEDURE [dbo].[show_dist] 
    @table  sysname
  , @column sysname
AS
BEGIN
   CREATE TABLE #temp_table ( NUMBER_THAT_HAVE int NULL
                            , THIS_MANY        int NULL
                            )
   EXEC ("INSERT INTO #temp_table SELECT " + @column + ", COUNT(*) FROM " + @table + " GROUP BY " + @column)
   EXEC ("SELECT 'NUMBER THAT HAVE' = COUNT(*), THIS_MANY FROM #temp_table GROUP BY THIS_MANY ORDER BY THIS_MANY DESC") 
   DROP TABLE #temp_table
END
GO
/****** Object:  StoredProcedure [dbo].[skewed_rand]    Script Date: 1/21/2025 8:21:29 PM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/****** Object:  Stored Procedure dbo.skewed_rand    Script Date: 10/13/99 6:38:02 PM ******/



CREATE PROCEDURE [dbo].[skewed_rand] 
    @max_value int
  , @skew_factor tinyint
AS
BEGIN
   DECLARE @rand_value int    SELECT @rand_value = @max_value
   WHILE (@skew_factor > 0)
   BEGIN
      SELECT @skew_factor = @skew_factor - 1
      EXEC @rand_value = straight_rand @rand_value
   END
   RETURN (@max_value - @rand_value) + 1
END
GO
/****** Object:  StoredProcedure [dbo].[straight_rand]    Script Date: 1/21/2025 8:21:29 PM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/****** Object:  Stored Procedure dbo.straight_rand    Script Date: 10/13/99 6:38:02 PM ******/



CREATE PROCEDURE [dbo].[straight_rand] 
    @max_value int
AS
BEGIN
   RETURN (rand() * (@max_value - 1)) + 1
END
GO
/****** Object:  StoredProcedure [msqta].[spPurgeData]    Script Date: 1/21/2025 8:21:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [msqta].[spPurgeData]
@sessionObject	msqta.TuningSessionType		READONLY,
@queryObject	msqta.TuningQueryType		READONLY,
@databaseName								varchar(256),
@mode										tinyint
AS

/*
------------------------------------------------------------
Copyright (c) Microsoft Corporation.  All rights reserved.
Licensed under the Source EULA. See License.txt in the project root for license information.
------------------------------------------------------------

Deletes persisted Session and Query data from database. It operates in multiple modes as defined below

case @mode = 0:
    Purge queries and its properties from database.
    This operation might leave an empty session in database. If queries getting purged
    are part of some session.
    Caller needs to pass in @queryObject

case @mode = 1: 
    Purge session and its properties from database.
    Query belonging to this session remains in the database.
    Caller needs to pass in @sessionObject

case @mode = 2:
    Purge session and its properties from database.
    This also purges query which are part of this session.
    Caller needs to pass in @sessionObject

case @mode = 3:
    Purge all sessions and its properties from database except current active session.
    Query belonging to this session remains in the database.
    Caller needs to pass @databaseName

case @mode = 4:
    Purge all sessions and its properties from database except current active session.
    This also purges query which are part of this session.
    Caller needs to pass @databaseName
*/

BEGIN TRANSACTION

BEGIN TRY

    IF @mode = 0 AND (SELECT COUNT(*) FROM @queryObject) > 0
    BEGIN
        DELETE query 
        FROM msqta.TuningQuery query 
        INNER JOIN @queryObject queryObject ON queryObject.QueryID = query.QueryID AND DB_ID(queryObject.DatabaseName) = query.DatabaseID
        -- delete cascade  will take care of foreign keys
    END
    IF @mode = 1 AND (SELECT COUNT(*) FROM @sessionObject) > 0
    BEGIN
        DELETE session
        FROM msqta.TuningSession session
        INNER JOIN @sessionObject sessionObject ON sessionObject.TuningSessionID = session.TuningSessionID
        WHERE session.Status != 0
        -- delete cascade  will take care of foreign keys
    END
    IF @mode = 2 AND (SELECT COUNT(*) FROM @sessionObject) > 0
    BEGIN
        DELETE query 
        FROM msqta.TuningQuery query 
        INNER JOIN msqta.TuningSession_TuningQuery session_query ON session_query.TuningQueryID = query.TuningQueryID
        INNER JOIN msqta.TuningSession session ON session.TuningSessionID = session_query.TuningSessionID
        INNER JOIN @sessionObject sessionObject ON sessionObject.TuningSessionID = session_query.TuningSessionID
        WHERE session.Status != 0

        DELETE session
        FROM msqta.TuningSession session
        INNER JOIN @sessionObject sessionObject ON sessionObject.TuningSessionID = session.TuningSessionID
        WHERE session.Status != 0
        -- delete cascade  will take care of foreign keys
    END
    IF @mode = 3
    BEGIN
        DELETE session
        FROM msqta.TuningSession session WHERE session.DatabaseID = DB_ID(@databaseName) AND session.Status != 0
        -- delete cascade  will take care of foreign keys
    END
    IF @mode = 4
    BEGIN
        DELETE query 
        FROM msqta.TuningQuery query 
        INNER JOIN msqta.TuningSession_TuningQuery session_query ON session_query.TuningQueryID = query.TuningQueryID
        INNER JOIN msqta.TuningSession session ON session.TuningSessionID = session_query.TuningSessionID
        WHERE session.DatabaseID = DB_ID(@databaseName) AND session.Status != 0

        DELETE session
        FROM msqta.TuningSession session WHERE session.DatabaseID = DB_ID(@databaseName) AND session.Status != 0
        -- delete cascade  will take care of foreign keys
    END
END TRY
BEGIN CATCH

    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    THROW

END CATCH

IF @@TRANCOUNT > 0
    COMMIT TRANSACTION;
GO
/****** Object:  StoredProcedure [msqta].[spQueryGet]    Script Date: 1/21/2025 8:21:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [msqta].[spQueryGet]
@databaseName	varchar(256)
AS

/*
------------------------------------------------------------
Copyright (c) Microsoft Corporation.  All rights reserved.
Licensed under the Source EULA. See License.txt in the project root for license information.
------------------------------------------------------------

Returns list of TuningQuery for the given database
@databaseName			- Name of the database for which TuningQuery is returned for

*/

SELECT 
query.TuningQueryID,
query.QueryID,
DB_NAME(query.DatabaseID) AS DatabaseName,
query.ParentObjectId,
query.QueryHash,
query.QueryText,
query.QueryType,
query.IsParametrized,
query.PlanGuide,
query.Status,
query.CreateDate,
query.LastModifyDate,
query.ProfileCompleteDate,
query.AnalysisCompleteDate,
query.ExperimentPendingDate,
query.ExperimentCompleteDate,
query.DeployedDate,
query.AbandonedDate,
query.Parameters 
FROM msqta.TuningQuery query
WHERE query.DatabaseID = DB_ID(@databaseName)

SELECT 
queryOptionGroup.GroupID,
queryOptionGroup.TuningQueryID,
query.QueryID,
DB_NAME(query.DatabaseID) AS DatabaseName,
queryOptionGroup.QueryOptions,
queryOptionGroup.IsVerified,
queryOptionGroup.IsDeployed,
queryOptionGroup.ValidationCompleteDate
FROM msqta.QueryOptionGroup queryOptionGroup
INNER JOIN msqta.TuningQuery query ON query.TuningQueryID = queryOptionGroup.TuningQueryID
WHERE query.DatabaseID = DB_ID(@databaseName)

SELECT
stat.StatID,
stat.GroupID,
query.QueryID,
DB_NAME(query.DatabaseID) AS DatabaseName,
stat.StatType,
stat.IsProfiled,
stat.ExecutionCount,
stat.Showplan,
stat.Stats
FROM msqta.ExecutionStat stat
INNER JOIN msqta.QueryOptionGroup queryOptionGroup ON queryOptionGroup.GroupID = stat.GroupID
INNER JOIN msqta.TuningQuery query ON query.TuningQueryID = queryOptionGroup.TuningQueryID
WHERE query.DatabaseID = DB_ID(@databaseName)
GO
/****** Object:  StoredProcedure [msqta].[spQuerySave]    Script Date: 1/21/2025 8:21:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [msqta].[spQuerySave]
@queryObject				msqta.TuningQueryType		READONLY,
@queryOptionGroupObject		msqta.QueryOptionGroupType	READONLY,
@queryExecutionStatObject	msqta.ExecutionStatType		READONLY,
@update						tinyint 
AS

/*
------------------------------------------------------------
Copyright (c) Microsoft Corporation.  All rights reserved.
Licensed under the Source EULA. See License.txt in the project root for license information.
------------------------------------------------------------

Persist queries into database. 
@queryObject				- UDT for TuningQuery
@queryOptionGroupObject		- UDT from QueryOptionObject
@queryExecutionStatObject	- UDT for ExecutionStat
@update						- Valid values are 
                                1 - Force update existing record and insert new records
                                2 - update existing record only if it's query_status is behind the incoming record and insert new records
                                x - insert new records

*/

BEGIN TRANSACTION

BEGIN TRY
    
     -- Verify Database name is valid for query records
    IF (SELECT COUNT(*) FROM @queryObject WHERE DB_ID(DatabaseName) IS NULL) > 0
    BEGIN
        THROW 51000, 'Cannot find database against which query is saved.', 1
    END
        
    IF @update = 1
    BEGIN
        
        /*
        If query already exists, we will overwrite existing record with the incoming record (DELETE + ADD)
        */

        DELETE query
        FROM msqta.TuningQuery query
        INNER JOIN @queryObject queryObject on queryObject.QueryID = query.QueryID AND DB_ID(queryObject.DatabaseName) = query.DatabaseID
        
    END

    IF @update = 2
    BEGIN
        
        /*
        If query already exists, we will update record only if saved query's query_status is behind the incoming record
        */

        DELETE query
        FROM msqta.TuningQuery query
        INNER JOIN @queryObject queryObject on queryObject.QueryID = query.QueryID AND DB_ID(queryObject.DatabaseName) = query.DatabaseID
        WHERE query.Status <= queryObject.Status

    END

    /*
    Add new records
    */

    -- Create temporary list of QueryIDs to which we have to insert. 
    DECLARE @msqta_TempQueryToInsert table(
    QueryID bigint,
    DatabaseID int)

    INSERT INTO @msqta_TempQueryToInsert (QueryID, DatabaseID)
    SELECT queryObject.QueryID, DB_ID(queryObject.DatabaseName)
    FROM @queryObject queryObject
    LEFT JOIN msqta.TuningQuery query on query.QueryID = queryObject.QueryID AND query.DatabaseID = DB_ID(queryObject.DatabaseName)
    WHERE query.QueryID IS NULL AND query.DatabaseID IS NULL

    -- Adding Query Record
    INSERT INTO msqta.TuningQuery(
    QueryID,
    DatabaseID,
    ParentObjectId,
    QueryHash,
    QueryText,
    QueryType,
    IsParametrized,
    PlanGuide,
    Status,
    CreateDate,
    LastModifyDate,
    ProfileCompleteDate,
    AnalysisCompleteDate,
    ExperimentPendingDate,
    ExperimentCompleteDate,
    DeployedDate,
    AbandonedDate,
    Parameters)

    SELECT 
    queryObject.QueryID, 
    DB_ID(queryObject.DatabaseName), 
    queryObject.ParentObjectId, 
    queryObject.QueryHash, 
    queryObject.QueryText, 
    queryObject.QueryType, 
    queryObject.IsParametrized, 
    queryObject.PlanGuide, 
    queryObject.Status,
    queryObject.CreateDate, 
    GETUTCDATE(), 
    queryObject.ProfileCompleteDate, 
    queryObject.AnalysisCompleteDate, 
    queryObject.ExperimentPendingDate, 
    queryObject.ExperimentCompleteDate, 
    queryObject.DeployedDate, 
    queryObject.AbandonedDate, 
    queryObject.Parameters 
    FROM @queryObject queryObject
    INNER JOIN @msqta_TempQueryToInsert queryToInsert ON queryToInsert.QueryID = queryObject.QueryID AND queryToInsert.DatabaseID = DB_ID(queryObject.DatabaseName)

    -- Create a temporary mapping of QueryOptionGroup(GroupID) from the client to actual GroupID generated from above statement.
    -- We will need this mapping to link ExecutionStats back to GroupID
    DECLARE @msqta_TempGroupIdMapping table(
    TuningQueryID bigint,
    TempGroupID bigint,
    NewGroupID bigint)

    /*
    Adding QueryOptionGroup Records with always insert merge condition.
    We have to use merge condition in this case because we have to use output clause to get back the identity column value for GroupID.
    Output clause will generate the temporary mapping of GroupID from client to actual GroupID.
    */
    MERGE INTO msqta.QueryOptionGroup
    USING @queryOptionGroupObject qogObject
    INNER JOIN @msqta_TempQueryToInsert queryToInsert ON queryToInsert.QueryID = qogObject.QueryID AND queryToInsert.DatabaseID = DB_ID(qogObject.DatabaseName)
    INNER JOIN msqta.TuningQuery query ON query.QueryID = qogObject.QueryID AND query.DatabaseID = DB_ID(qogObject.DatabaseName)
    ON 1=0
    WHEN NOT MATCHED THEN
        INSERT(
        TuningQueryID,
        QueryOptions,
        IsVerified,
        IsDeployed,
        ValidationCompleteDate)

        VALUES(
        query.TuningQueryID,
        qogObject.QueryOptions,
        qogObject.IsVerified,
        qogObject.IsDeployed,
        qogObject.ValidationCompleteDate)

        OUTPUT INSERTED.TuningQueryID, qogObject.GroupID, INSERTED.GroupID INTO @msqta_TempGroupIdMapping;

    -- Adding ExecutionStat Records
    INSERT INTO msqta.ExecutionStat(
    GroupID,
    StatType,
    IsProfiled,
    ExecutionCount,
    Showplan,
    Stats)

    SELECT
    tempGroupIdMapping.NewGroupID,
    statsObject.StatType,
    statsObject.IsProfiled,
    statsObject.ExecutionCount,
    statsObject.Showplan,
    statsObject.Stats
    FROM @queryExecutionStatObject statsObject
    INNER JOIN @msqta_TempQueryToInsert queryToInsert ON queryToInsert.QueryID = statsObject.QueryID AND queryToInsert.DatabaseID = DB_ID(statsObject.DatabaseName)
    INNER JOIN msqta.TuningQuery query ON query.QueryID = statsObject.QueryID AND query.DatabaseID = DB_ID(statsObject.DatabaseName)
    INNER JOIN @msqta_TempGroupIdMapping tempGroupIdMapping ON tempGroupIdMapping.TuningQueryID = query.TuningQueryID AND tempGroupIdMapping.TempGroupID = statsObject.GroupID

END TRY
BEGIN CATCH

    IF @@TRANCOUNT > 0  
        ROLLBACK TRANSACTION; 
    THROW

END CATCH

IF @@TRANCOUNT > 0  
    COMMIT TRANSACTION;
GO
/****** Object:  StoredProcedure [msqta].[spSessionById]    Script Date: 1/21/2025 8:21:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [msqta].[spSessionById]
@sessionId	bigint
AS

/*
------------------------------------------------------------
Copyright (c) Microsoft Corporation.  All rights reserved.
Licensed under the Source EULA. See License.txt in the project root for license information.
------------------------------------------------------------

Retrieve already saved Tuning Session. 
@sessionId			- sessionId to retrieve

*/

SELECT 
TuningSessionID,
DB_NAME(DatabaseID) AS DatabaseName,
Name,
Description,
Status,
CreateDate,
LastModifyDate,
BaselineEndDate,
UpgradeDate,
TargetCompatLevel,
WorkloadDurationDays
FROM msqta.TuningSession 
WHERE TuningSessionID = @sessionId

SELECT 
query.TuningQueryID,
query.QueryID,
DB_NAME(query.DatabaseID) AS DatabaseName,
query.ParentObjectId,
query.QueryHash,
query.QueryText,
query.QueryType,
query.IsParametrized,
query.PlanGuide,
query.Status,
query.CreateDate,
query.LastModifyDate,
query.ProfileCompleteDate,
query.AnalysisCompleteDate,
query.ExperimentPendingDate,
query.ExperimentCompleteDate,
query.DeployedDate,
query.AbandonedDate,
query.Parameters 
FROM msqta.TuningQuery query
INNER JOIN msqta.TuningSession_TuningQuery session_query ON session_query.TuningQueryID = query.TuningQueryID
WHERE session_query.TuningSessionID = @sessionId

SELECT 
queryOptionGroup.GroupID,
queryOptionGroup.TuningQueryID,
query.QueryID,
DB_NAME(query.DatabaseID) AS DatabaseName,
queryOptionGroup.QueryOptions,
queryOptionGroup.IsVerified,
queryOptionGroup.IsDeployed,
queryOptionGroup.ValidationCompleteDate
FROM msqta.QueryOptionGroup queryOptionGroup
INNER JOIN msqta.TuningQuery query ON query.TuningQueryID = queryOptionGroup.TuningQueryID
INNER JOIN msqta.TuningSession_TuningQuery session_query ON session_query.TuningQueryID = queryOptionGroup.TuningQueryID
WHERE session_query.TuningSessionID = @sessionId

SELECT
stat.GroupID,
query.QueryID,
DB_NAME(query.DatabaseID) AS DatabaseName,
stat.StatType,
stat.IsProfiled,
stat.ExecutionCount,
stat.Showplan,
stat.Stats
FROM msqta.ExecutionStat stat
INNER JOIN msqta.QueryOptionGroup queryOptionGroup ON queryOptionGroup.GroupID = stat.GroupID
INNER JOIN msqta.TuningQuery query ON query.TuningQueryID = queryOptionGroup.TuningQueryID
INNER JOIN msqta.TuningSession_TuningQuery session_query ON session_query.TuningQueryID = queryOptionGroup.TuningQueryID
WHERE session_query.TuningSessionID = @sessionId
GO
/****** Object:  StoredProcedure [msqta].[spSessionSave]    Script Date: 1/21/2025 8:21:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [msqta].[spSessionSave]
@sessionObject				msqta.TuningSessionType		READONLY,
@queryObject				msqta.TuningQueryType		READONLY,
@queryOptionGroupObject		msqta.QueryOptionGroupType	READONLY,
@queryExecutionStatObject	msqta.ExecutionStatType		READONLY
AS

/*
------------------------------------------------------------
Copyright (c) Microsoft Corporation.  All rights reserved.
Licensed under the Source EULA. See License.txt in the project root for license information.
------------------------------------------------------------

Persist tuning Session into database. 
@sessionObject				- UDT for TuningSession
@queryObject				- UDT for TuningQuery
@queryOptionGroupObject		- UDT from QueryOptionObject
@queryExecutionStatObject	- UDT for ExecutionStat

*/

BEGIN TRANSACTION

BEGIN TRY

    -- Verify Database name is valid for query records
    IF (SELECT COUNT(*) FROM @sessionObject WHERE DB_ID(DatabaseName) IS NULL) > 0
    BEGIN
        THROW 51000, 'Cannot find database against which session is saved.', 1
    END

    -- we only handle single session update for now
    IF (SELECT COUNT(*) FROM @sessionObject) > 1
    BEGIN
        THROW 51000, 'Cannot process multiple sessions.', 1
    END

    DECLARE @sessionId AS int
    SET @sessionId = (SELECT TOP(1) TuningSessionID FROM @sessionObject)

    DECLARE @databaseId AS int
    SET @databaseId = (SELECT TOP(1) DB_ID(DatabaseName) FROM @sessionObject)
        
    IF @sessionId > 0
    BEGIN
        /*
        If session already exists, (this is update session request)
            - Update session properties
            - Update Queries
            - Drop existing session-query mappings 
            - Add new session-query mappings
        */
            
        -- Update session properties
        UPDATE session
        SET DatabaseID = DB_ID(sessionObject.DatabaseName),
        Name = sessionObject.Name,
        Description = sessionObject.Description,
        Status = sessionObject.Status,
        CreateDate = sessionObject.CreateDate,
        LastModifyDate = GETUTCDATE(),
        BaselineEndDate = sessionObject.BaselineEndDate,
        UpgradeDate = sessionObject.UpgradeDate,
        TargetCompatLevel = sessionObject.TargetCompatLevel,
        WorkloadDurationDays = sessionObject.WorkloadDurationDays
        FROM msqta.TuningSession session		
        INNER JOIN @sessionObject sessionObject ON sessionObject.TuningSessionID = session.TuningSessionID

        IF (SELECT COUNT(*) FROM @queryObject) > 0
        BEGIN
            -- Update queries with update flag
            exec msqta.spQuerySave @queryObject, @queryOptionGroupObject, @queryExecutionStatObject, 2
        END

        -- Delete all existing session-query mapping
        DELETE session_query
        FROM msqta.TuningSession_TuningQuery session_query
        WHERE session_query.TuningSessionID = @sessionId
        
        -- Add session-query mapping
        INSERT INTO msqta.TuningSession_TuningQuery (TuningSessionID, TuningQueryID)
        SELECT @sessionId, query.TuningQueryID 
        FROM @queryObject queryObject
        INNER JOIN msqta.TuningQuery query ON query.QueryID = queryObject.QueryID AND query.DatabaseID = DB_ID(queryObject.DatabaseName)

    END
    ELSE 
    BEGIN
        /*
        If session doesn't exist, (this is create new session request)
            - Create new session only if we don't have an active session
            - If query already exist with a mapping to an existing session, update the query mappings
            - Persist new query
            - Add new mapping for session and query
        */

        -- Validate we don't have active session
        IF (SELECT COUNT(*) FROM msqta.TuningSession WHERE DatabaseID = @databaseId AND Status = 0) > 0
        BEGIN
            THROW 51000, 'Database already have an active session.', 1
        END

        -- Create a new session
        INSERT INTO msqta.TuningSession (DatabaseID, Name, Description, Status, CreateDate, LastModifyDate, BaselineEndDate, UpgradeDate, TargetCompatLevel, WorkloadDurationDays)
        SELECT DB_ID(DatabaseName), Name, Description, Status, CreateDate, GETUTCDATE(), BaselineEndDate, UpgradeDate, TargetCompatLevel, WorkloadDurationDays FROM @sessionObject
            
        -- asign new session id
        SET @sessionId = SCOPE_IDENTITY()

        IF (SELECT COUNT(*) FROM @queryObject) > 0
        BEGIN
            -- Update Queries
            exec msqta.spQuerySave @queryObject, @queryOptionGroupObject, @queryExecutionStatObject, 2

            -- Add session-query mappings
            INSERT INTO msqta.TuningSession_TuningQuery (TuningSessionID, TuningQueryID)
            SELECT @sessionId, query.TuningQueryID 
            FROM @queryObject queryObject
            INNER JOIN msqta.TuningQuery query ON query.QueryID = queryObject.QueryID AND query.DatabaseID = DB_ID(queryObject.DatabaseName)
        END
    END

    EXEC msqta.spSessionById @sessionId

END TRY
BEGIN CATCH

    IF @@TRANCOUNT > 0  
        ROLLBACK TRANSACTION; 
    
    THROW 

END CATCH

IF @@TRANCOUNT > 0  
    COMMIT TRANSACTION;
GO
USE [master]
GO
ALTER DATABASE [CreditDB] SET  READ_WRITE 
GO

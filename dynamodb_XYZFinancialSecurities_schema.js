
// =============================================
// AWS DynamoDB Schema Design for XYZ Financials Securities
// =============================================

// DynamoDB uses single-table design pattern for optimal performance
// Primary access patterns drive the design

// =============================================
// Main Table: FinancialsSecurities
// =============================================

const tableSchema = {
  TableName: "FinancialsSecurities",
  KeySchema: [
    { AttributeName: "PK", KeyType: "HASH" },   // Partition key
    { AttributeName: "SK", KeyType: "RANGE" }    // Sort key
  ],
  AttributeDefinitions: [
    { AttributeName: "PK", AttributeType: "S" },
    { AttributeName: "SK", AttributeType: "S" },
    { AttributeName: "GSI1PK", AttributeType: "S" },
    { AttributeName: "GSI1SK", AttributeType: "S" },
    { AttributeName: "GSI2PK", AttributeType: "S" },
    { AttributeName: "GSI2SK", AttributeType: "S" },
    { AttributeName: "GSI3PK", AttributeType: "S" },
    { AttributeName: "GSI3SK", AttributeType: "S" },
    { AttributeName: "LSI1SK", AttributeType: "S" }
  ],
  GlobalSecondaryIndexes: [
    {
      IndexName: "GSI1",
      KeySchema: [
        { AttributeName: "GSI1PK", KeyType: "HASH" },
        { AttributeName: "GSI1SK", KeyType: "RANGE" }
      ],
      Projection: { ProjectionType: "ALL" },
      ProvisionedThroughput: {
        ReadCapacityUnits: 5,
        WriteCapacityUnits: 5
      }
    },
    {
      IndexName: "GSI2",
      KeySchema: [
        { AttributeName: "GSI2PK", KeyType: "HASH" },
        { AttributeName: "GSI2SK", KeyType: "RANGE" }
      ],
      Projection: { ProjectionType: "ALL" },
      ProvisionedThroughput: {
        ReadCapacityUnits: 5,
        WriteCapacityUnits: 5
      }
    },
    {
      IndexName: "GSI3",
      KeySchema: [
        { AttributeName: "GSI3PK", KeyType: "HASH" },
        { AttributeName: "GSI3SK", KeyType: "RANGE" }
      ],
      Projection: { ProjectionType: "ALL" },
      ProvisionedThroughput: {
        ReadCapacityUnits: 5,
        WriteCapacityUnits: 5
      }
    }
  ],
  LocalSecondaryIndexes: [
    {
      IndexName: "LSI1",
      KeySchema: [
        { AttributeName: "PK", KeyType: "HASH" },
        { AttributeName: "LSI1SK", KeyType: "RANGE" }
      ],
      Projection: { ProjectionType: "ALL" }
    }
  ],
  BillingMode: "PAY_PER_REQUEST", // Or PROVISIONED
  StreamSpecification: {
    StreamEnabled: true,
    StreamViewType: "NEW_AND_OLD_IMAGES"
  }
};

// =============================================
// Access Patterns and Key Design
// =============================================

/*
ACCESS PATTERNS:

1. Get customer by ID
2. Get all loans for a customer
3. Get loan by ID
4. Get all payments for a loan
5. Get applications by customer
6. Get applications by loan officer
7. Get delinquent loans
8. Get loans by status
9. Get properties by location
10. Get securities by CUSIP
11. Get loan officer performance
12. Get customer portfolio summary
*/

// =============================================
// Item Patterns
// =============================================

// 1. CUSTOMER
const customer = {
  PK: "CUSTOMER#1234",
  SK: "METADATA",
  Type: "Customer",
  CustomerId: 1234,
  FirstName: "John",
  LastName: "Doe",
  SSN: "123-45-6789",
  DateOfBirth: "1980-01-15",
  Email: "john.doe@example.com",
  Phone: "555-1234",
  AnnualIncome: 85000.00,
  EmploymentStatus: "Employed",
  Employer: "Tech Corp",
  YearsEmployed: 5,
  CreditScore: 720,
  CreatedDate: "2024-01-01T00:00:00Z",
  LastUpdatedDate: "2024-12-27T00:00:00Z",
  
  // Computed metrics
  Metrics: {
    CurrentDTI: 28.5,
    ActiveLoanCount: 2,
    TotalLoanAmount: 450000.00,
    TotalRemainingBalance: 385000.00
  },
  
  // GSI1 for searching by email
  GSI1PK: "EMAIL#john.doe@example.com",
  GSI1SK: "CUSTOMER#1234",
  
  // GSI2 for searching by last name
  GSI2PK: "LASTNAME#Doe",
  GSI2SK: "CUSTOMER#1234",
  
  // GSI3 for credit score queries
  GSI3PK: "CREDITSCORE#720",
  GSI3SK: "CUSTOMER#1234"
};

// 2. CUSTOMER ADDRESS
const customerAddress = {
  PK: "CUSTOMER#1234",
  SK: "ADDRESS#HOME",
  Type: "CustomerAddress",
  AddressType: "Home",
  AddressLine1: "123 Main St",
  AddressLine2: "Apt 4B",
  City: "Springfield",
  State: "IL",
  ZipCode: "62701",
  Country: "USA",
  StartDate: "2020-01-01",
  EndDate: null
};

// 3. LOAN
const loan = {
  PK: "LOAN#100000",
  SK: "METADATA",
  Type: "Loan",
  LoanId: 100000,
  ApplicationId: 10000,
  CustomerId: 1234,
  PropertyId: 5001,
  ProductId: 1,
  LoanAmount: 300000.00,
  InterestRate: 4.250,
  Term: 360,
  OriginationDate: "2024-01-15",
  MaturityDate: "2054-01-15",
  MonthlyPayment: 1475.82,
  RemainingBalance: 295000.00,
  Status: "Active",
  EscrowRequired: true,
  PMIRequired: false,
  FirstPaymentDate: "2024-02-15",
  NextPaymentDate: "2025-01-15",
  PaymentFrequency: "Monthly",
  SecurityId: 2001,
  
  // Embedded escrow
  Escrow: {
    CurrentBalance: 4500.00,
    PropertyTaxAmount: 350.00,
    PropertyInsuranceAmount: 125.00,
    MonthlyContribution: 475.00,
    LastAnalysisDate: "2024-12-01",
    NextAnalysisDate: "2025-12-01"
  },
  
  // Current servicer
  CurrentServicer: {
    ServicerName: "ABC Servicing LLC",
    ServicerID: 501,
    TransferDate: "2024-01-15",
    ServicingFee: 0.25
  },
  
  LastUpdatedDate: "2024-12-27T00:00:00Z",
  
  // GSI1 for customer's loans
  GSI1PK: "CUSTOMER#1234",
  GSI1SK: "LOAN#100000",
  
  // GSI2 for status-based queries
  GSI2PK: "STATUS#Active",
  GSI2SK: "LOAN#100000",
  
  // GSI3 for next payment date (delinquency)
  GSI3PK: "NEXTPAYMENT#2025-01-15",
  GSI3SK: "LOAN#100000",
  
  // LSI1 for sorting loans by origination date
  LSI1SK: "DATE#2024-01-15"
};

// 4. PAYMENT
const payment = {
  PK: "LOAN#100000",
  SK: "PAYMENT#2024-12-15",
  Type: "Payment",
  PaymentId: 50001,
  LoanId: 100000,
  CustomerId: 1234,
  PaymentDate: "2024-12-15",
  PaymentAmount: 1475.82,
  PrincipalAmount: 950.00,
  InterestAmount: 1050.82,
  EscrowAmount: 475.00,
  LateFeeAmount: 0.00,
  PaymentMethod: "ACH",
  TransactionId: "TXN123456789",
  PaymentStatus: "Posted",
  ProcessedDate: "2024-12-15T10:30:00Z",
  
  // GSI1 for payment date range queries
  GSI1PK: "PAYMENTDATE#2024-12",
  GSI1SK: "PAYMENT#50001",
  
  // GSI2 for customer payment history
  GSI2PK: "CUSTOMER#1234",
  GSI2SK: "PAYMENT#2024-12-15"
};

// 5. APPLICATION
const application = {
  PK: "APPLICATION#10000",
  SK: "METADATA",
  Type: "Application",
  ApplicationId: 10000,
  CustomerId: 1234,
  ProductId: 1,
  OfficerId: 5,
  ApplicationDate: "2023-11-01",
  LoanAmount: 300000.00,
  LoanPurpose: "Purchase",
  Status: "Approved",
  ClosingDate: "2024-01-15",
  ApplicationFee: 500.00,
  DTI: 28.5,
  PropertyValue: 375000.00,
  LTV: 80.0,
  RateOffered: 4.250,
  TermOffered: 360,
  
  // Risk assessment
  RiskAssessment: {
    AssessmentDate: "2023-11-05",
    CreditScore: 720,
    DTI: 28.5,
    LTV: 80.0,
    FICOScoreSource: "Experian",
    RiskClassification: "Low",
    RecommendedAction: "Approve"
  },
  
  // GSI1 for customer's applications
  GSI1PK: "CUSTOMER#1234",
  GSI1SK: "APPLICATION#10000",
  
  // GSI2 for loan officer's applications
  GSI2PK: "OFFICER#5",
  GSI2SK: "APPLICATION#2023-11-01#10000",
  
  // GSI3 for status queries
  GSI3PK: "APPSTATUS#Approved",
  GSI3SK: "APPLICATION#10000"
};

// 6. APPLICATION DOCUMENT
const applicationDocument = {
  PK: "APPLICATION#10000",
  SK: "DOCUMENT#W2_2023",
  Type: "Document",
  DocumentType: "W2",
  FileName: "w2_2023.pdf",
  FileLocation: "s3://bucket/docs/w2_2023.pdf",
  UploadDate: "2023-11-02",
  RequiredFlag: true,
  ReceivedFlag: true,
  ApprovalStatus: "Approved",
  ApprovalDate: "2023-11-03",
  ApprovedBy: "underwriter@company.com"
};

// 7. PROPERTY
const property = {
  PK: "PROPERTY#5001",
  SK: "METADATA",
  Type: "Property",
  PropertyId: 5001,
  AddressLine1: "456 Oak Ave",
  City: "Springfield",
  State: "IL",
  ZipCode: "62701",
  Country: "USA",
  PropertyType: "Single Family",
  YearBuilt: 2005,
  SquareFeet: 2200,
  Bedrooms: 4,
  Bathrooms: 2.5,
  PurchasePrice: 350000.00,
  CurrentValue: 375000.00,
  LastAppraisalDate: "2023-12-01",
  LastAppraisalValue: 375000.00,
  TaxAssessmentValue: 360000.00,
  AnnualTaxAmount: 4200.00,
  HOAFees: 0.00,
  FloodZone: "X",
  PropertyTaxID: "IL-62701-12345",
  
  // Geolocation
  Location: {
    Latitude: 39.7817,
    Longitude: -89.6501
  },
  
  // GSI1 for location-based queries (geohash)
  GSI1PK: "GEO#9zn5",
  GSI1SK: "PROPERTY#5001",
  
  // GSI2 for state/city queries
  GSI2PK: "LOCATION#IL#Springfield",
  GSI2SK: "PROPERTY#5001",
  
  // GSI3 for property type
  GSI3PK: "PROPTYPE#Single Family",
  GSI3SK: "PROPERTY#5001"
};

// 8. SECURITY
const security = {
  PK: "SECURITY#2001",
  SK: "METADATA",
  Type: "Security",
  SecurityId: 2001,
  SecurityName: "XYZ MBS 2024-1",
  SecurityType: "MBS",
  CUSIP: "12345ABC9",
  IssueDate: "2024-01-01",
  MaturityDate: "2054-01-01",
  CouponRate: 4.500,
  FaceValue: 10000000.00,
  CurrentBalance: 9850000.00,
  Issuer: "XYZ Financials",
  Rating: "AAA",
  Status: "Active",
  LastTradeDate: "2024-12-20",
  LastTradePrice: 98.50,
  
  // GSI1 for CUSIP lookup
  GSI1PK: "CUSIP#12345ABC9",
  GSI1SK: "SECURITY#2001",
  
  // GSI2 for security type
  GSI2PK: "SECTYPE#MBS",
  GSI2SK: "SECURITY#2001"
};

// 9. SECURITY LOAN POOL MEMBER
const securityLoanMember = {
  PK: "SECURITY#2001",
  SK: "LOAN#100000",
  Type: "SecurityLoanMember",
  LoanId: 100000,
  LoanAmount: 300000.00,
  RemainingBalance: 295000.00,
  InterestRate: 4.250,
  OriginationDate: "2024-01-15"
};

// 10. LOAN OFFICER
const loanOfficer = {
  PK: "OFFICER#5",
  SK: "METADATA",
  Type: "LoanOfficer",
  OfficerId: 5,
  FirstName: "Jane",
  LastName: "Smith",
  Email: "jane.smith@company.com",
  Phone: "555-9876",
  BranchId: 10,
  HireDate: "2020-01-15",
  CommissionRate: 0.50,
  Status: "Active",
  
  // Performance metrics (cached/computed)
  Performance: {
    TotalApplications: 150,
    ApprovedApplications: 120,
    DeniedApplications: 20,
    ApprovalRate: 80.0,
    TotalLoanAmount: 45000000.00,
    TotalCommission: 225000.00,
    AvgDaysToClose: 45,
    LastCalculated: "2024-12-27"
  },
  
  // GSI1 for email lookup
  GSI1PK: "EMAIL#jane.smith@company.com",
  GSI1SK: "OFFICER#5"
};

// 11. MORTGAGE PRODUCT
const mortgageProduct = {
  PK: "PRODUCT#1",
  SK: "METADATA",
  Type: "MortgageProduct",
  ProductId: 1,
  ProductName: "30-Year Fixed Conventional",
  ProductType: "Conventional",
  Term: 360,
  BaseInterestRate: 4.250,
  MinCreditScore: 620,
  MaxLTV: 95.0,
  MinLoanAmount: 50000.00,
  MaxLoanAmount: 750000.00,
  OriginationFee: 1.0,
  IsActive: true,
  
  // GSI1 for product type
  GSI1PK: "PRODTYPE#Conventional",
  GSI1SK: "PRODUCT#1"
};

// 12. ESCROW TRANSACTION
const escrowTransaction = {
  PK: "LOAN#100000",
  SK: "ESCROW#2024-12-15#TAX",
  Type: "EscrowTransaction",
  TransactionId: 70001,
  LoanId: 100000,
  TransactionDate: "2024-12-15",
  TransactionType: "Property Tax Payment",
  Amount: 1050.00,
  Description: "Q4 2024 Property Tax",
  Reference: "TAX-IL-2024-Q4"
};

// 13. DEFAULT/FORECLOSURE
const defaultRecord = {
  PK: "LOAN#100000",
  SK: "DEFAULT#2024-06-01",
  Type: "Default",
  DefaultId: 80001,
  LoanId: 100000,
  DefaultDate: "2024-06-01",
  Stage: "30 Days Delinquent",
  ReasonCode: "Financial Hardship",
  ResolutionType: null,
  ResolutionDate: null,
  LossAmount: 0.00,
  CollectionAgency: null,
  LegalFilingDate: null,
  LegalCaseNumber: null,
  Notes: "Customer experiencing temporary hardship"
};

// 14. LOAN MODIFICATION
const loanModification = {
  PK: "LOAN#100000",
  SK: "MODIFICATION#2024-07-01",
  Type: "LoanModification",
  ModificationId: 90001,
  LoanId: 100000,
  ModificationDate: "2024-07-01",
  ModificationType: "Rate Reduction",
  PreviousInterestRate: 4.750,
  NewInterestRate: 4.250,
  PreviousPayment: 1565.00,
  NewPayment: 1475.82,
  ModificationFee: 500.00,
  ApprovalStatus: "Approved",
  ApprovedBy: "supervisor@company.com"
};

// 15. CAPITAL MARKET DATA (Time-series)
const marketData = {
  PK: "MARKETDATA#2024-12-27",
  SK: "METADATA",
  Type: "CapitalMarketData",
  DataDate: "2024-12-27",
  DataSource: "Bloomberg",
  Treasury10Y: 4.250,
  FedFundsRate: 4.500,
  LIBOR3M: 4.750,
  SOFR: 4.625,
  MBS30YRate: 5.125,
  Fannie30YRate: 5.000,
  Freddie30YRate: 5.050,
  
  // GSI1 for date range queries
  GSI1PK: "MARKETDATA",
  GSI1SK: "DATE#2024-12-27"
};

// 16. AUDIT LOG
const auditLog = {
  PK: "AUDIT#2024-12-27#12:30:00",
  SK: "LOG#123456",
  Type: "AuditLog",
  LogId: 123456,
  EntityType: "Loan",
  EntityId: 100000,
  ActionType: "UPDATE",
  ActionDateTime: "2024-12-27T12:30:00Z",
  UserId: "user@company.com",
  OldValues: {
    RemainingBalance: 296000.00
  },
  NewValues: {
    RemainingBalance: 295000.00
  },
  IPAddress: "192.168.1.100",
  ApplicationName: "LoanServicingApp",
  
  // GSI1 for user activity
  GSI1PK: "USER#user@company.com",
  GSI1SK: "AUDIT#2024-12-27#12:30:00",
  
  // GSI2 for entity audit trail
  GSI2PK: "ENTITY#Loan#100000",
  GSI2SK: "AUDIT#2024-12-27#12:30:00"
};

// =============================================
// Query Examples
// =============================================

// Get customer with all related data
const getCustomerData = async (customerId) => {
  const params = {
    TableName: "FinancialsSecurities",
    KeyConditionExpression: "PK = :pk",
    ExpressionAttributeValues: {
      ":pk": `CUSTOMER#${customerId}`
    }
  };
  // Returns customer metadata and all addresses
};

// Get all loans for a customer
const getCustomerLoans = async (customerId) => {
  const params = {
    TableName: "FinancialsSecurities",
    IndexName: "GSI1",
    KeyConditionExpression: "GSI1PK = :pk",
    ExpressionAttributeValues: {
      ":pk": `CUSTOMER#${customerId}`
    }
  };
};

// Get delinquent loans (next payment date in the past)
const getDelinquentLoans = async (date) => {
  const params = {
    TableName: "FinancialsSecurities",
    IndexName: "GSI3",
    KeyConditionExpression: "GSI3PK < :date",
    FilterExpression: "Status = :status",
    ExpressionAttributeValues: {
      ":date": `NEXTPAYMENT#${date}`,
      ":status": "Active"
    }
  };
};

// Get loan with all payments
const getLoanWithPayments = async (loanId) => {
  const params = {
    TableName: "FinancialsSecurities",
    KeyConditionExpression: "PK = :pk",
    ExpressionAttributeValues: {
      ":pk": `LOAN#${loanId}`
    }
  };
  // Returns loan metadata and all payments
};

// Get loan officer applications
const getOfficerApplications = async (officerId) => {
  const params = {
    TableName: "FinancialsSecurities",
    IndexName: "GSI2",
    KeyConditionExpression: "GSI2PK = :pk",
    ExpressionAttributeValues: {
      ":pk": `OFFICER#${officerId}`
    }
  };
};

// =============================================
// DynamoDB Streams for Aggregations
// =============================================

/*
Use DynamoDB Streams + Lambda to maintain:
1. Customer metrics (total loans, balances)
2. Loan officer performance metrics
3. Security pool balances
4. Portfolio summaries

This keeps read queries fast while maintaining eventual consistency
*/
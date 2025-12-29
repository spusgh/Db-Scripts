
// =============================================
// Azure Cosmos DB Schema Design for XYZ Financials Securities
// =============================================
// Using Cosmos DB SQL API (Core API) with JSON documents
// Partition strategy is critical for performance and cost
// =============================================

// =============================================
// DATABASE CONFIGURATION
// =============================================

const databaseConfig = {
  id: "XYZFinancialsSecurities",
  throughput: 20000, // RU/s at database level (optional, or per-container)
  maxThroughput: 100000 // For autoscale
};

// =============================================
// CONTAINER 1: Customers
// =============================================
// Partition Key: /customerId (or /customerIdHash for better distribution)

const customersContainer = {
  id: "customers",
  partitionKey: {
    paths: ["/customerId"],
    kind: "Hash"
  },
  indexingPolicy: {
    indexingMode: "consistent",
    automatic: true,
    includedPaths: [
      { path: "/*" }
    ],
    excludedPaths: [
      { path: "/\"_etag\"/?"}
    ],
    compositeIndexes: [
      [
        { path: "/lastName", order: "ascending" },
        { path: "/firstName", order: "ascending" }
      ],
      [
        { path: "/creditScore", order: "descending" },
        { path: "/customerId", order: "ascending" }
      ]
    ]
  },
  uniqueKeyPolicy: {
    uniqueKeys: [
      { paths: ["/ssn"] },
      { paths: ["/email"] }
    ]
  },
  throughput: 10000 // Dedicated RU/s
};

// Sample Customer Document
const customerDocument = {
  id: "CUSTOMER-1234", // Cosmos DB requires 'id' field
  customerId: 1234,
  type: "customer",
  firstName: "John",
  lastName: "Doe",
  ssn: "123-45-6789",
  dateOfBirth: "1980-01-15",
  email: "john.doe@example.com",
  phone: "555-1234",
  annualIncome: 85000.00,
  employmentStatus: "Employed",
  employer: "Tech Corp",
  yearsEmployed: 5,
  creditScore: 720,
  
  // Embedded addresses
  addresses: [
    {
      addressType: "Home",
      addressLine1: "123 Main St",
      addressLine2: "Apt 4B",
      city: "Springfield",
      state: "IL",
      zipCode: "62701",
      country: "USA",
      startDate: "2020-01-01",
      endDate: null,
      isCurrent: true
    }
  ],
  
  // Computed/cached metrics
  metrics: {
    currentDTI: 28.5,
    activeLoanCount: 2,
    totalLoanAmount: 450000.00,
    totalRemainingBalance: 385000.00,
    lastCalculated: "2024-12-27T00:00:00Z"
  },
  
  // Metadata
  createdDate: "2024-01-01T00:00:00Z",
  lastUpdatedDate: "2024-12-27T00:00:00Z",
  _ts: 1703721600, // Cosmos DB timestamp
  ttl: -1 // No expiration
};

// =============================================
// CONTAINER 2: Loans
// =============================================
// Partition Key: /customerId (enables efficient customer portfolio queries)
// Alternative: /loanId for loan-centric queries

const loansContainer = {
  id: "loans",
  partitionKey: {
    paths: ["/customerId"],
    kind: "Hash"
  },
  indexingPolicy: {
    indexingMode: "consistent",
    automatic: true,
    includedPaths: [
      { path: "/*" }
    ],
    excludedPaths: [
      { path: "/recentPayments/*" }, // Don't index embedded payment array
      { path: "/\"_etag\"/?"}
    ],
    compositeIndexes: [
      [
        { path: "/status", order: "ascending" },
        { path: "/nextPaymentDate", order: "ascending" }
      ],
      [
        { path: "/customerId", order: "ascending" },
        { path: "/originationDate", order: "descending" }
      ],
      [
        { path: "/securityId", order: "ascending" },
        { path: "/loanId", order: "ascending" }
      ]
    ]
  },
  throughput: 15000
};

// Sample Loan Document
const loanDocument = {
  id: "LOAN-100000",
  loanId: 100000,
  customerId: 1234, // Partition key
  type: "loan",
  
  // Basic loan information
  applicationId: 10000,
  propertyId: 5001,
  productId: 1,
  loanAmount: 300000.00,
  interestRate: 4.250,
  term: 360,
  originationDate: "2024-01-15",
  maturityDate: "2054-01-15",
  monthlyPayment: 1475.82,
  remainingBalance: 295000.00,
  status: "Active", // Active, Paid Off, Defaulted, In Foreclosure
  
  // Payment details
  escrowRequired: true,
  pmiRequired: false,
  pmiAmount: 0.00,
  firstPaymentDate: "2024-02-15",
  nextPaymentDate: "2025-01-15",
  paymentFrequency: "Monthly",
  
  // Security information
  securityId: 2001,
  
  // Embedded escrow account (1-to-1 relationship)
  escrow: {
    currentBalance: 4500.00,
    propertyTaxAmount: 350.00,
    propertyInsuranceAmount: 125.00,
    pmiAmount: 0.00,
    cushionAmount: 500.00,
    monthlyContribution: 475.00,
    shortageAmount: 0.00,
    lastAnalysisDate: "2024-12-01",
    nextAnalysisDate: "2025-12-01"
  },
  
  // Current servicer
  currentServicer: {
    servicerName: "ABC Servicing LLC",
    servicerId: 501,
    transferDate: "2024-01-15",
    msrValue: 3000.00,
    servicingFee: 0.25,
    subservicerName: null
  },
  
  // Default information (if applicable)
  defaultInfo: null,
  
  // Recent payments (last 12 months, for quick access)
  recentPayments: [
    {
      paymentDate: "2024-12-15",
      paymentAmount: 1475.82,
      principalAmount: 950.00,
      interestAmount: 1050.82,
      escrowAmount: 475.00,
      lateFeeAmount: 0.00,
      paymentStatus: "Posted"
    }
  ],
  
  // Modification history
  modifications: [
    {
      modificationDate: "2024-07-01",
      modificationType: "Rate Reduction",
      previousInterestRate: 4.750,
      newInterestRate: 4.250,
      previousPayment: 1565.00,
      newPayment: 1475.82,
      approvalStatus: "Approved",
      approvedBy: "supervisor@company.com"
    }
  ],
  
  // Denormalized property info (for queries)
  propertyAddress: "456 Oak Ave, Springfield, IL 62701",
  propertyType: "Single Family",
  propertyValue: 375000.00,
  
  // Denormalized customer info (for queries)
  customerName: "John Doe",
  customerEmail: "john.doe@example.com",
  customerPhone: "555-1234",
  
  // Metadata
  lastUpdatedDate: "2024-12-27T00:00:00Z",
  _ts: 1703721600
};

// =============================================
// CONTAINER 3: Payments
// =============================================
// Partition Key: /loanId (all payments for a loan in same partition)
// Alternative: Synthetic key /yearMonth for time-series queries

const paymentsContainer = {
  id: "payments",
  partitionKey: {
    paths: ["/loanId"],
    kind: "Hash"
  },
  indexingPolicy: {
    indexingMode: "consistent",
    automatic: true,
    includedPaths: [
      { path: "/*" }
    ],
    excludedPaths: [
      { path: "/\"_etag\"/?"}
    ],
    compositeIndexes: [
      [
        { path: "/loanId", order: "ascending" },
        { path: "/paymentDate", order: "descending" }
      ],
      [
        { path: "/customerId", order: "ascending" },
        { path: "/paymentDate", order: "descending" }
      ],
      [
        { path: "/paymentDate", order: "descending" },
        { path: "/paymentStatus", order: "ascending" }
      ]
    ]
  },
  defaultTtl: 2592000, // 30 days (if you want to auto-expire old data)
  throughput: 8000
};

// Sample Payment Document
const paymentDocument = {
  id: "PAYMENT-50001",
  paymentId: 50001,
  loanId: 100000, // Partition key
  customerId: 1234,
  type: "payment",
  
  paymentDate: "2024-12-15",
  paymentAmount: 1475.82,
  principalAmount: 950.00,
  interestAmount: 1050.82,
  escrowAmount: 475.00,
  lateFeeAmount: 0.00,
  paymentMethod: "ACH",
  transactionId: "TXN123456789",
  paymentStatus: "Posted", // Pending, Posted, Reversed, Failed
  processedDate: "2024-12-15T10:30:00Z",
  
  // Denormalized data for queries
  customerName: "John Doe",
  loanRemainingBalance: 295000.00,
  
  // For time-series queries
  yearMonth: "2024-12",
  
  _ts: 1702641000
};

// =============================================
// CONTAINER 4: Applications
// =============================================
// Partition Key: /customerId (customer-centric queries)

const applicationsContainer = {
  id: "applications",
  partitionKey: {
    paths: ["/customerId"],
    kind: "Hash"
  },
  indexingPolicy: {
    indexingMode: "consistent",
    automatic: true,
    compositeIndexes: [
      [
        { path: "/officerId", order: "ascending" },
        { path: "/applicationDate", order: "descending" }
      ],
      [
        { path: "/status", order: "ascending" },
        { path: "/applicationDate", order: "descending" }
      ]
    ]
  },
  throughput: 5000
};

// Sample Application Document
const applicationDocument = {
  id: "APPLICATION-10000",
  applicationId: 10000,
  customerId: 1234, // Partition key
  type: "application",
  
  productId: 1,
  officerId: 5,
  applicationDate: "2023-11-01T00:00:00Z",
  loanAmount: 300000.00,
  loanPurpose: "Purchase",
  status: "Approved", // Submitted, Under Review, Approved, Denied, Withdrawn
  closingDate: "2024-01-15",
  applicationFee: 500.00,
  dti: 28.5,
  propertyValue: 375000.00,
  ltv: 80.0,
  rateOffered: 4.250,
  termOffered: 360,
  denialReason: null,
  
  // Embedded documents
  documents: [
    {
      documentType: "W2",
      fileName: "w2_2023.pdf",
      fileLocation: "https://storage.blob.core.windows.net/docs/w2_2023.pdf",
      uploadDate: "2023-11-02",
      requiredFlag: true,
      receivedFlag: true,
      approvalStatus: "Approved",
      approvalDate: "2023-11-03",
      approvedBy: "underwriter@company.com"
    },
    {
      documentType: "Pay Stub",
      fileName: "paystub_oct2023.pdf",
      fileLocation: "https://storage.blob.core.windows.net/docs/paystub_oct2023.pdf",
      uploadDate: "2023-11-02",
      requiredFlag: true,
      receivedFlag: true,
      approvalStatus: "Approved",
      approvalDate: "2023-11-03",
      approvedBy: "underwriter@company.com"
    }
  ],
  
  // Risk assessment
  riskAssessment: {
    assessmentDate: "2023-11-05",
    creditScore: 720,
    dti: 28.5,
    ltv: 80.0,
    ficoScoreSource: "Experian",
    riskClassification: "Low",
    recommendedAction: "Approve",
    notes: "Excellent payment history, stable employment"
  },
  
  // Denormalized data
  customerName: "John Doe",
  customerEmail: "john.doe@example.com",
  officerName: "Jane Smith",
  productName: "30-Year Fixed Conventional",
  
  _ts: 1698796800
};

// =============================================
// CONTAINER 5: Properties
// =============================================
// Partition Key: /propertyId or /stateCity for location queries

const propertiesContainer = {
  id: "properties",
  partitionKey: {
    paths: ["/propertyId"],
    kind: "Hash"
  },
  indexingPolicy: {
    indexingMode: "consistent",
    automatic: true,
    spatialIndexes: [
      {
        path: "/location/*",
        types: ["Point"]
      }
    ],
    compositeIndexes: [
      [
        { path: "/state", order: "ascending" },
        { path: "/city", order: "ascending" },
        { path: "/zipCode", order: "ascending" }
      ],
      [
        { path: "/propertyType", order: "ascending" },
        { path: "/currentValue", order: "descending" }
      ]
    ]
  },
  throughput: 4000
};

// Sample Property Document
const propertyDocument = {
  id: "PROPERTY-5001",
  propertyId: 5001,
  type: "property",
  
  addressLine1: "456 Oak Ave",
  addressLine2: null,
  city: "Springfield",
  state: "IL",
  zipCode: "62701",
  stateCity: "IL-Springfield", // Composite for partition key alternative
  country: "USA",
  
  propertyType: "Single Family",
  yearBuilt: 2005,
  squareFeet: 2200,
  bedrooms: 4,
  bathrooms: 2.5,
  
  purchasePrice: 350000.00,
  currentValue: 375000.00,
  lastAppraisalDate: "2023-12-01",
  lastAppraisalValue: 375000.00,
  taxAssessmentValue: 360000.00,
  annualTaxAmount: 4200.00,
  hoaFees: 0.00,
  floodZone: "X",
  propertyTaxId: "IL-62701-12345",
  
  // Geospatial (GeoJSON format)
  location: {
    type: "Point",
    coordinates: [-89.6501, 39.7817] // [longitude, latitude]
  },
  
  // Associated loans
  activeLoanIds: [100000],
  
  _ts: 1701388800
};

// =============================================
// CONTAINER 6: Securities
// =============================================
// Partition Key: /securityId

const securitiesContainer = {
  id: "securities",
  partitionKey: {
    paths: ["/securityId"],
    kind: "Hash"
  },
  indexingPolicy: {
    indexingMode: "consistent",
    automatic: true,
    includedPaths: [
      { path: "/*" }
    ],
    excludedPaths: [
      { path: "/loanPool/*" } // Large array, don't index
    ],
    compositeIndexes: [
      [
        { path: "/securityType", order: "ascending" },
        { path: "/issueDate", order: "descending" }
      ],
      [
        { path: "/status", order: "ascending" },
        { path: "/rating", order: "descending" }
      ]
    ]
  },
  uniqueKeyPolicy: {
    uniqueKeys: [
      { paths: ["/cusip"] }
    ]
  },
  throughput: 3000
};

// Sample Security Document
const securityDocument = {
  id: "SECURITY-2001",
  securityId: 2001,
  type: "security",
  
  securityName: "XYZ MBS 2024-1",
  securityType: "MBS",
  cusip: "12345ABC9",
  issueDate: "2024-01-01",
  maturityDate: "2054-01-01",
  couponRate: 4.500,
  faceValue: 10000000.00,
  currentBalance: 9850000.00,
  issuer: "XYZ Financials",
  rating: "AAA",
  status: "Active",
  lastTradeDate: "2024-12-20",
  lastTradePrice: 98.50,
  
  // Loan pool (summary, not full details)
  loanPool: {
    loanCount: 35,
    totalBalance: 9850000.00,
    weightedAvgRate: 4.375,
    weightedAvgTerm: 355,
    loanIds: [100000, 100001, 100002] // Sample, truncated
  },
  
  // Performance metrics
  performance: {
    delinquencyRate: 0.5,
    defaultRate: 0.1,
    prepaymentRate: 5.2
  },
  
  _ts: 1703635200
};

// =============================================
// CONTAINER 7: Reference Data (small, shared)
// =============================================
// Partition Key: /type (all products, officers, etc. by type)

const referenceDataContainer = {
  id: "referenceData",
  partitionKey: {
    paths: ["/type"],
    kind: "Hash"
  },
  throughput: 400 // Shared throughput
};

// Mortgage Product
const mortgageProductDocument = {
  id: "PRODUCT-1",
  productId: 1,
  type: "mortgageProduct", // Partition key value
  
  productName: "30-Year Fixed Conventional",
  productType: "Conventional",
  term: 360,
  baseInterestRate: 4.250,
  minCreditScore: 620,
  maxLtv: 95.0,
  minLoanAmount: 50000.00,
  maxLoanAmount: 750000.00,
  originationFee: 1.0,
  isActive: true
};

// Loan Officer
const loanOfficerDocument = {
  id: "OFFICER-5",
  officerId: 5,
  type: "loanOfficer", // Partition key value
  
  firstName: "Jane",
  lastName: "Smith",
  email: "jane.smith@company.com",
  phone: "555-9876",
  branchId: 10,
  hireDate: "2020-01-15",
  commissionRate: 0.50,
  status: "Active",
  
  // Cached performance metrics
  performance: {
    totalApplications: 150,
    approvedApplications: 120,
    deniedApplications: 20,
    approvalRate: 80.0,
    totalLoanAmount: 45000000.00,
    totalCommission: 225000.00,
    avgDaysToClose: 45,
    lastCalculated: "2024-12-27"
  }
};

// =============================================
// CONTAINER 8: Time-Series Data
// =============================================
// For high-volume, time-based data (market data, audit logs)
// Partition Key: /yearMonth (synthetic key for time-based partitioning)

const timeSeriesContainer = {
  id: "timeSeries",
  partitionKey: {
    paths: ["/yearMonth"],
    kind: "Hash"
  },
  defaultTtl: 7776000, // 90 days (auto-delete old data)
  throughput: 5000
};

// Capital Market Data
const marketDataDocument = {
  id: "MARKET-2024-12-27",
  type: "marketData",
  yearMonth: "2024-12", // Partition key
  
  dataDate: "2024-12-27",
  dataSource: "Bloomberg",
  treasury10Y: 4.250,
  fedFundsRate: 4.500,
  libor3M: 4.750,
  sofr: 4.625,
  mbs30YRate: 5.125,
  fannie30YRate: 5.000,
  freddie30YRate: 5.050,
  effectiveDateStart: "2024-12-27",
  effectiveDateEnd: "2024-12-28",
  
  _ts: 1703721600
};

// Audit Log
const auditLogDocument = {
  id: "AUDIT-2024-12-27-12:30:00-123456",
  type: "auditLog",
  yearMonth: "2024-12", // Partition key
  
  logId: 123456,
  entityType: "Loan",
  entityId: 100000,
  actionType: "UPDATE",
  actionDateTime: "2024-12-27T12:30:00Z",
  userId: "user@company.com",
  oldValues: {
    remainingBalance: 296000.00
  },
  newValues: {
    remainingBalance: 295000.00
  },
  ipAddress: "192.168.1.100",
  applicationName: "LoanServicingApp",
  
  _ts: 1703678200,
  ttl: 7776000 // 90 days
};

// =============================================
// COSMOS DB QUERY EXAMPLES
// =============================================

// Get customer with their loans (cross-partition query)
const query1 = `
SELECT c.*, 
       ARRAY(SELECT VALUE l FROM loans l WHERE l.customerId = c.customerId) as loans
FROM customers c
WHERE c.customerId = 1234
`;

// Get delinquent loans (requires cross-partition query or change partition key)
const query2 = `
SELECT l.loanId, l.customerName, l.nextPaymentDate, l.remainingBalance
FROM loans l
WHERE l.status = 'Active' 
  AND l.nextPaymentDate < GetCurrentDateTime()
ORDER BY l.nextPaymentDate ASC
`;

// Get customer portfolio summary (within partition)
const query3 = `
SELECT c.customerId,
       c.firstName,
       c.lastName,
       c.metrics.activeLoanCount as loanCount,
       c.metrics.totalRemainingBalance as totalBalance
FROM customers c
WHERE c.customerId = 1234
`;

// Get loan officer performance
const query4 = `
SELECT o.officerId, o.firstName, o.lastName, o.performance
FROM referenceData o
WHERE o.type = 'loanOfficer' AND o.officerId = 5
`;

// Geospatial query for properties near a location
const query5 = `
SELECT p.propertyId, p.addressLine1, p.city, p.currentValue
FROM properties p
WHERE ST_DISTANCE(p.location, {
  'type': 'Point',
  'coordinates': [-89.6501, 39.7817]
}) < 10000
`;

// =============================================
// CHANGE FEED CONFIGURATION
// =============================================

const changeFeedConfig = {
  // Use change feed to:
  // 1. Update customer metrics when loans change
  // 2. Update loan officer performance when applications change
  // 3. Trigger events (emails, notifications)
  // 4. Sync to data warehouse for analytics
  // 5. Maintain search indexes (Azure Cognitive Search)
  
  processorName: "LoanChangeFeedProcessor",
  leaseContainer: "leases",
  startFromBeginning: false,
  maxItemCount: 100
};

// =============================================
// BEST PRACTICES
// =============================================

/*
1. PARTITION KEY STRATEGY:
   - Choose partition key with high cardinality
   - Avoid hot partitions
   - Customer-centric: customerId works well for loans, applications
   - Time-series: Use yearMonth for audit logs, market data
   - Reference data: Use 'type' field

2. DENORMALIZATION:
   - Embed related data for common queries
   - Store customer name in loan documents
   - Cache computed metrics

3. THROUGHPUT MANAGEMENT:
   - Use database-level throughput for containers with low traffic
   - Dedicated throughput for high-traffic containers
   - Monitor RU consumption

4. INDEXING:
   - Exclude large arrays from indexing
   - Use composite indexes for common query patterns
   - Be selective to reduce indexing costs

5. TTL:
   - Use TTL for time-series data
   - Auto-expire audit logs after 90 days
   - Reduce storage costs

6. CHANGE FEED:
   - Process changes asynchronously
   - Update aggregated metrics
   - Trigger downstream processes

7. CROSS-PARTITION QUERIES:
   - Expensive in terms of RUs
   - Cache results when possible
   - Consider partition key design to minimize

8. CONSISTENCY:
   - Default: Session consistency
   - Strong consistency only when needed
   - Eventual consistency for non-critical reads
*/
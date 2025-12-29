
// =============================================
// MongoDB Schema Design for XYZ Financials Securities
// =============================================

// Collection: customers
db.createCollection("customers", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["firstName", "lastName", "ssn", "dateOfBirth", "email"],
      properties: {
        _id: { bsonType: "objectId" },
        customerId: { bsonType: "int" },
        firstName: { bsonType: "string" },
        lastName: { bsonType: "string" },
        ssn: { bsonType: "string", pattern: "^[0-9]{3}-[0-9]{2}-[0-9]{4}$" },
        dateOfBirth: { bsonType: "date" },
        email: { bsonType: "string" },
        phone: { bsonType: "string" },
        annualIncome: { bsonType: "decimal" },
        employmentStatus: { bsonType: "string" },
        employer: { bsonType: "string" },
        yearsEmployed: { bsonType: "int" },
        creditScore: { bsonType: "int" },
        // Embedded addresses (denormalized)
        addresses: {
          bsonType: "array",
          items: {
            bsonType: "object",
            properties: {
              addressType: { bsonType: "string" },
              addressLine1: { bsonType: "string" },
              addressLine2: { bsonType: "string" },
              city: { bsonType: "string" },
              state: { bsonType: "string" },
              zipCode: { bsonType: "string" },
              country: { bsonType: "string" },
              startDate: { bsonType: "date" },
              endDate: { bsonType: "date" }
            }
          }
        },
        // Embedded metrics (computed fields)
        metrics: {
          bsonType: "object",
          properties: {
            currentDTI: { bsonType: "decimal" },
            activeLoanCount: { bsonType: "int" },
            totalLoanAmount: { bsonType: "decimal" },
            totalRemainingBalance: { bsonType: "decimal" }
          }
        },
        createdDate: { bsonType: "date" },
        lastUpdatedDate: { bsonType: "date" }
      }
    }
  }
});

// Indexes for customers
db.customers.createIndex({ "customerId": 1 }, { unique: true });
db.customers.createIndex({ "ssn": 1 }, { unique: true });
db.customers.createIndex({ "lastName": 1, "firstName": 1 });
db.customers.createIndex({ "email": 1 });
db.customers.createIndex({ "creditScore": 1 });

// Collection: properties
db.createCollection("properties", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["addressLine1", "city", "state", "zipCode", "propertyType"],
      properties: {
        _id: { bsonType: "objectId" },
        propertyId: { bsonType: "int" },
        addressLine1: { bsonType: "string" },
        addressLine2: { bsonType: "string" },
        city: { bsonType: "string" },
        state: { bsonType: "string" },
        zipCode: { bsonType: "string" },
        country: { bsonType: "string" },
        propertyType: { bsonType: "string" },
        yearBuilt: { bsonType: "int" },
        squareFeet: { bsonType: "int" },
        bedrooms: { bsonType: "int" },
        bathrooms: { bsonType: "decimal" },
        purchasePrice: { bsonType: "decimal" },
        currentValue: { bsonType: "decimal" },
        lastAppraisalDate: { bsonType: "date" },
        lastAppraisalValue: { bsonType: "decimal" },
        taxAssessmentValue: { bsonType: "decimal" },
        annualTaxAmount: { bsonType: "decimal" },
        hoaFees: { bsonType: "decimal" },
        floodZone: { bsonType: "string" },
        propertyTaxId: { bsonType: "string" },
        location: {
          bsonType: "object",
          properties: {
            type: { enum: ["Point"] },
            coordinates: { bsonType: "array" } // [longitude, latitude]
          }
        }
      }
    }
  }
});

// Indexes for properties
db.properties.createIndex({ "propertyId": 1 }, { unique: true });
db.properties.createIndex({ "location": "2dsphere" }); // Geospatial index
db.properties.createIndex({ "state": 1, "city": 1 });
db.properties.createIndex({ "zipCode": 1 });
db.properties.createIndex({ "propertyType": 1 });

// Collection: loans (main aggregate root)
db.createCollection("loans", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["customerId", "propertyId", "loanAmount", "interestRate", "status"],
      properties: {
        _id: { bsonType: "objectId" },
        loanId: { bsonType: "int" },
        applicationId: { bsonType: "int" },
        customerId: { bsonType: "int" },
        propertyId: { bsonType: "int" },
        productId: { bsonType: "int" },
        
        // Loan details
        loanAmount: { bsonType: "decimal" },
        interestRate: { bsonType: "decimal" },
        term: { bsonType: "int" },
        originationDate: { bsonType: "date" },
        maturityDate: { bsonType: "date" },
        monthlyPayment: { bsonType: "decimal" },
        remainingBalance: { bsonType: "decimal" },
        status: { enum: ["Active", "Paid Off", "Defaulted", "In Foreclosure"] },
        
        // Payment details
        escrowRequired: { bsonType: "bool" },
        pmiRequired: { bsonType: "bool" },
        pmiAmount: { bsonType: "decimal" },
        firstPaymentDate: { bsonType: "date" },
        nextPaymentDate: { bsonType: "date" },
        paymentFrequency: { bsonType: "string" },
        
        // Security info
        securityId: { bsonType: "int" },
        
        // Embedded escrow account (1-to-1 relationship)
        escrow: {
          bsonType: "object",
          properties: {
            currentBalance: { bsonType: "decimal" },
            propertyTaxAmount: { bsonType: "decimal" },
            propertyInsuranceAmount: { bsonType: "decimal" },
            pmiAmount: { bsonType: "decimal" },
            cushionAmount: { bsonType: "decimal" },
            monthlyContribution: { bsonType: "decimal" },
            shortageAmount: { bsonType: "decimal" },
            lastAnalysisDate: { bsonType: "date" },
            nextAnalysisDate: { bsonType: "date" }
          }
        },
        
        // Embedded servicing rights (current servicer)
        currentServicer: {
          bsonType: "object",
          properties: {
            servicerName: { bsonType: "string" },
            servicerId: { bsonType: "int" },
            transferDate: { bsonType: "date" },
            msrValue: { bsonType: "decimal" },
            servicingFee: { bsonType: "decimal" },
            subservicerName: { bsonType: "string" }
          }
        },
        
        // Default/foreclosure info (if applicable)
        defaultInfo: {
          bsonType: "object",
          properties: {
            defaultDate: { bsonType: "date" },
            stage: { bsonType: "string" },
            reasonCode: { bsonType: "string" },
            resolutionType: { bsonType: "string" },
            resolutionDate: { bsonType: "date" },
            lossAmount: { bsonType: "decimal" },
            collectionAgency: { bsonType: "string" },
            legalFilingDate: { bsonType: "date" },
            legalCaseNumber: { bsonType: "string" },
            notes: { bsonType: "string" }
          }
        },
        
        // Embedded recent payments (last 12 months, for quick access)
        recentPayments: {
          bsonType: "array",
          items: {
            bsonType: "object",
            properties: {
              paymentDate: { bsonType: "date" },
              paymentAmount: { bsonType: "decimal" },
              principalAmount: { bsonType: "decimal" },
              interestAmount: { bsonType: "decimal" },
              escrowAmount: { bsonType: "decimal" },
              lateFeeAmount: { bsonType: "decimal" },
              paymentMethod: { bsonType: "string" },
              transactionId: { bsonType: "string" },
              paymentStatus: { bsonType: "string" }
            }
          }
        },
        
        // Modification history
        modifications: {
          bsonType: "array",
          items: {
            bsonType: "object",
            properties: {
              modificationDate: { bsonType: "date" },
              modificationType: { bsonType: "string" },
              previousInterestRate: { bsonType: "decimal" },
              newInterestRate: { bsonType: "decimal" },
              previousTerm: { bsonType: "int" },
              newTerm: { bsonType: "int" },
              previousPayment: { bsonType: "decimal" },
              newPayment: { bsonType: "decimal" },
              modificationFee: { bsonType: "decimal" },
              approvalStatus: { bsonType: "string" },
              approvedBy: { bsonType: "string" }
            }
          }
        },
        
        lastUpdatedDate: { bsonType: "date" }
      }
    }
  }
});

// Indexes for loans
db.loans.createIndex({ "loanId": 1 }, { unique: true });
db.loans.createIndex({ "customerId": 1 });
db.loans.createIndex({ "propertyId": 1 });
db.loans.createIndex({ "status": 1 });
db.loans.createIndex({ "securityId": 1 });
db.loans.createIndex({ "originationDate": 1 });
db.loans.createIndex({ "nextPaymentDate": 1 });
db.loans.createIndex({ "customerId": 1, "status": 1 }); // Compound index
db.loans.createIndex({ "status": 1, "nextPaymentDate": 1 }); // For delinquency queries

// Collection: payments (full payment history, separate from loans)
db.createCollection("payments", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["loanId", "paymentDate", "paymentAmount"],
      properties: {
        _id: { bsonType: "objectId" },
        paymentId: { bsonType: "int" },
        loanId: { bsonType: "int" },
        customerId: { bsonType: "int" }, // Denormalized for queries
        paymentDate: { bsonType: "date" },
        paymentAmount: { bsonType: "decimal" },
        principalAmount: { bsonType: "decimal" },
        interestAmount: { bsonType: "decimal" },
        escrowAmount: { bsonType: "decimal" },
        lateFeeAmount: { bsonType: "decimal" },
        paymentMethod: { bsonType: "string" },
        transactionId: { bsonType: "string" },
        paymentStatus: { bsonType: "string" },
        processedDate: { bsonType: "date" }
      }
    }
  }
});

// Indexes for payments
db.payments.createIndex({ "paymentId": 1 }, { unique: true });
db.payments.createIndex({ "loanId": 1, "paymentDate": -1 });
db.payments.createIndex({ "customerId": 1, "paymentDate": -1 });
db.payments.createIndex({ "paymentDate": 1 });
db.payments.createIndex({ "transactionId": 1 });

// Collection: applications
db.createCollection("applications", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["customerId", "productId", "officerId", "loanAmount", "status"],
      properties: {
        _id: { bsonType: "objectId" },
        applicationId: { bsonType: "int" },
        customerId: { bsonType: "int" },
        productId: { bsonType: "int" },
        officerId: { bsonType: "int" },
        applicationDate: { bsonType: "date" },
        loanAmount: { bsonType: "decimal" },
        loanPurpose: { bsonType: "string" },
        status: { bsonType: "string" },
        closingDate: { bsonType: "date" },
        applicationFee: { bsonType: "decimal" },
        dti: { bsonType: "decimal" },
        propertyValue: { bsonType: "decimal" },
        ltv: { bsonType: "decimal" },
        rateOffered: { bsonType: "decimal" },
        termOffered: { bsonType: "int" },
        denialReason: { bsonType: "string" },
        
        // Embedded documents
        documents: {
          bsonType: "array",
          items: {
            bsonType: "object",
            properties: {
              documentType: { bsonType: "string" },
              fileName: { bsonType: "string" },
              fileLocation: { bsonType: "string" },
              uploadDate: { bsonType: "date" },
              requiredFlag: { bsonType: "bool" },
              receivedFlag: { bsonType: "bool" },
              approvalStatus: { bsonType: "string" },
              approvedBy: { bsonType: "string" }
            }
          }
        },
        
        // Risk assessment
        riskAssessment: {
          bsonType: "object",
          properties: {
            assessmentDate: { bsonType: "date" },
            creditScore: { bsonType: "int" },
            dti: { bsonType: "decimal" },
            ltv: { bsonType: "decimal" },
            ficoScoreSource: { bsonType: "string" },
            riskClassification: { bsonType: "string" },
            recommendedAction: { bsonType: "string" },
            notes: { bsonType: "string" }
          }
        }
      }
    }
  }
});

// Indexes for applications
db.applications.createIndex({ "applicationId": 1 }, { unique: true });
db.applications.createIndex({ "customerId": 1, "applicationDate": -1 });
db.applications.createIndex({ "officerId": 1 });
db.applications.createIndex({ "status": 1 });
db.applications.createIndex({ "applicationDate": 1 });

// Collection: securities
db.createCollection("securities", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["securityName", "securityType", "issueDate", "maturityDate"],
      properties: {
        _id: { bsonType: "objectId" },
        securityId: { bsonType: "int" },
        securityName: { bsonType: "string" },
        securityType: { bsonType: "string" },
        cusip: { bsonType: "string" },
        issueDate: { bsonType: "date" },
        maturityDate: { bsonType: "date" },
        couponRate: { bsonType: "decimal" },
        faceValue: { bsonType: "decimal" },
        currentBalance: { bsonType: "decimal" },
        issuer: { bsonType: "string" },
        rating: { bsonType: "string" },
        status: { bsonType: "string" },
        lastTradeDate: { bsonType: "date" },
        lastTradePrice: { bsonType: "decimal" },
        
        // Embedded loan pool references
        loanPool: {
          bsonType: "array",
          items: {
            bsonType: "object",
            properties: {
              loanId: { bsonType: "int" },
              loanAmount: { bsonType: "decimal" },
              remainingBalance: { bsonType: "decimal" },
              interestRate: { bsonType: "decimal" },
              originationDate: { bsonType: "date" }
            }
          }
        }
      }
    }
  }
});

// Indexes for securities
db.securities.createIndex({ "securityId": 1 }, { unique: true });
db.securities.createIndex({ "cusip": 1 }, { unique: true });
db.securities.createIndex({ "securityType": 1 });
db.securities.createIndex({ "status": 1 });

// Collection: mortgageProducts
db.createCollection("mortgageProducts", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["productName", "productType", "term"],
      properties: {
        _id: { bsonType: "objectId" },
        productId: { bsonType: "int" },
        productName: { bsonType: "string" },
        productType: { bsonType: "string" },
        term: { bsonType: "int" },
        baseInterestRate: { bsonType: "decimal" },
        minCreditScore: { bsonType: "int" },
        maxLtv: { bsonType: "decimal" },
        minLoanAmount: { bsonType: "decimal" },
        maxLoanAmount: { bsonType: "decimal" },
        originationFee: { bsonType: "decimal" },
        isActive: { bsonType: "bool" }
      }
    }
  }
});

// Indexes for mortgageProducts
db.mortgageProducts.createIndex({ "productId": 1 }, { unique: true });
db.mortgageProducts.createIndex({ "productName": 1 }, { unique: true });
db.mortgageProducts.createIndex({ "isActive": 1 });

// Collection: loanOfficers
db.createCollection("loanOfficers", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["firstName", "lastName", "email"],
      properties: {
        _id: { bsonType: "objectId" },
        officerId: { bsonType: "int" },
        firstName: { bsonType: "string" },
        lastName: { bsonType: "string" },
        email: { bsonType: "string" },
        phone: { bsonType: "string" },
        branchId: { bsonType: "int" },
        hireDate: { bsonType: "date" },
        commissionRate: { bsonType: "decimal" },
        status: { bsonType: "string" },
        
        // Performance metrics (computed/cached)
        performance: {
          bsonType: "object",
          properties: {
            totalApplications: { bsonType: "int" },
            approvedApplications: { bsonType: "int" },
            deniedApplications: { bsonType: "int" },
            approvalRate: { bsonType: "decimal" },
            totalLoanAmount: { bsonType: "decimal" },
            totalCommission: { bsonType: "decimal" },
            avgDaysToClose: { bsonType: "decimal" },
            lastCalculated: { bsonType: "date" }
          }
        }
      }
    }
  }
});

// Indexes for loanOfficers
db.loanOfficers.createIndex({ "officerId": 1 }, { unique: true });
db.loanOfficers.createIndex({ "email": 1 }, { unique: true });
db.loanOfficers.createIndex({ "status": 1 });

// Collection: escrowTransactions (time-series data)
db.createCollection("escrowTransactions", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["loanId", "transactionDate", "transactionType", "amount"],
      properties: {
        _id: { bsonType: "objectId" },
        transactionId: { bsonType: "int" },
        loanId: { bsonType: "int" },
        customerId: { bsonType: "int" }, // Denormalized
        transactionDate: { bsonType: "date" },
        transactionType: { bsonType: "string" },
        amount: { bsonType: "decimal" },
        description: { bsonType: "string" },
        reference: { bsonType: "string" }
      }
    }
  }
});

// Indexes for escrowTransactions
db.escrowTransactions.createIndex({ "loanId": 1, "transactionDate": -1 });
db.escrowTransactions.createIndex({ "transactionDate": 1 });

// Collection: capitalMarketData (time-series)
db.createCollection("capitalMarketData", {
  timeseries: {
    timeField: "dataDate",
    metaField: "dataSource",
    granularity: "hours"
  }
});

db.capitalMarketData.createIndex({ "dataDate": 1 });

// Collection: auditLog (append-only)
db.createCollection("auditLog", {
  capped: true,
  size: 104857600, // 100MB
  max: 1000000
});

db.auditLog.createIndex({ "entityType": 1, "entityId": 1, "actionDateTime": -1 });
db.auditLog.createIndex({ "userId": 1, "actionDateTime": -1 });

// =============================================
// Sample Queries
// =============================================

// Find delinquent loans
db.loans.find({
  status: "Active",
  nextPaymentDate: { $lt: new Date() }
}).sort({ nextPaymentDate: 1 });

// Get customer portfolio
db.loans.aggregate([
  {
    $match: { customerId: 1234, status: "Active" }
  },
  {
    $group: {
      _id: "$customerId",
      activeLoanCount: { $sum: 1 },
      totalLoanAmount: { $sum: "$loanAmount" },
      totalRemainingBalance: { $sum: "$remainingBalance" }
    }
  }
]);

// Loan officer performance
db.applications.aggregate([
  {
    $match: { officerId: 5 }
  },
  {
    $group: {
      _id: "$officerId",
      totalApplications: { $sum: 1 },
      approvedApplications: {
        $sum: { $cond: [{ $eq: ["$status", "Approved"] }, 1, 0] }
      },
      avgDaysToClose: {
        $avg: {
          $dateDiff: {
            startDate: "$applicationDate",
            endDate: "$closingDate",
            unit: "day"
          }
        }
      }
    }
  }
]);
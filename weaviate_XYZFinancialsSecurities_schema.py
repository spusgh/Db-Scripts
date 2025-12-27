"""
Weaviate Vector Database Schema for XYZ Financials Securities
"""

import weaviate
from weaviate.classes.config import Configure, Property, DataType

# ============================================================
# CLASS: Customer
# ============================================================
customer_class = {
    "class": "Customer",
    "description": "Customer profiles with financial information",
    "vectorizer": "text2vec-transformers",  # or "text2vec-openai", "text2vec-cohere"
    "moduleConfig": {
        "text2vec-transformers": {
            "vectorizeClassName": False,
            "poolingStrategy": "masked_mean"
        }
    },
    "properties": [
        {
            "name": "customerId",
            "dataType": ["int"],
            "description": "Unique customer identifier"
        },
        {
            "name": "fullName",
            "dataType": ["text"],
            "description": "Customer full name",
            "indexFilterable": True,
            "indexSearchable": True
        },
        {
            "name": "firstName",
            "dataType": ["text"],
            "description": "Customer first name"
        },
        {
            "name": "lastName",
            "dataType": ["text"],
            "description": "Customer last name",
            "indexFilterable": True
        },
        {
            "name": "ssnEncrypted",
            "dataType": ["text"],
            "description": "Encrypted SSN",
            "indexFilterable": False,
            "indexSearchable": False
        },
        {
            "name": "dateOfBirth",
            "dataType": ["date"],
            "description": "Customer date of birth"
        },
        {
            "name": "email",
            "dataType": ["text"],
            "description": "Customer email address",
            "indexFilterable": True
        },
        {
            "name": "phone",
            "dataType": ["text"],
            "description": "Customer phone number",
            "indexFilterable": True
        },
        {
            "name": "annualIncome",
            "dataType": ["number"],
            "description": "Annual income in dollars"
        },
        {
            "name": "employmentStatus",
            "dataType": ["text"],
            "description": "Employment status",
            "indexFilterable": True
        },
        {
            "name": "employer",
            "dataType": ["text"],
            "description": "Employer name",
            "indexSearchable": True
        },
        {
            "name": "yearsEmployed",
            "dataType": ["int"],
            "description": "Years with current employer"
        },
        {
            "name": "creditScore",
            "dataType": ["int"],
            "description": "Credit score",
            "indexRangeFilters": True
        },
        {
            "name": "createdDate",
            "dataType": ["date"],
            "description": "Record creation date"
        },
        {
            "name": "lastUpdatedDate",
            "dataType": ["date"],
            "description": "Last update date"
        },
        {
            "name": "customerProfileText",
            "dataType": ["text"],
            "description": "Customer profile summary for vectorization",
            "moduleConfig": {
                "text2vec-transformers": {
                    "skip": False,
                    "vectorizePropertyName": False
                }
            }
        }
    ]
}


# ============================================================
# CLASS: Loan
# ============================================================
loan_class = {
    "class": "Loan",
    "description": "Mortgage loan records",
    "vectorizer": "text2vec-transformers",
    "moduleConfig": {
        "text2vec-transformers": {
            "vectorizeClassName": False,
            "poolingStrategy": "masked_mean"
        }
    },
    "properties": [
        {
            "name": "loanId",
            "dataType": ["int"],
            "description": "Unique loan identifier"
        },
        {
            "name": "applicationId",
            "dataType": ["int"],
            "description": "Associated application ID"
        },
        {
            "name": "customerId",
            "dataType": ["int"],
            "description": "Customer ID",
            "indexFilterable": True
        },
        {
            "name": "propertyId",
            "dataType": ["int"],
            "description": "Property ID"
        },
        {
            "name": "productId",
            "dataType": ["int"],
            "description": "Mortgage product ID"
        },
        {
            "name": "loanAmount",
            "dataType": ["number"],
            "description": "Loan amount in dollars",
            "indexRangeFilters": True
        },
        {
            "name": "interestRate",
            "dataType": ["number"],
            "description": "Interest rate percentage",
            "indexRangeFilters": True
        },
        {
            "name": "term",
            "dataType": ["int"],
            "description": "Loan term in months"
        },
        {
            "name": "originationDate",
            "dataType": ["date"],
            "description": "Loan origination date"
        },
        {
            "name": "maturityDate",
            "dataType": ["date"],
            "description": "Loan maturity date"
        },
        {
            "name": "monthlyPayment",
            "dataType": ["number"],
            "description": "Monthly payment amount"
        },
        {
            "name": "remainingBalance",
            "dataType": ["number"],
            "description": "Remaining loan balance",
            "indexRangeFilters": True
        },
        {
            "name": "status",
            "dataType": ["text"],
            "description": "Loan status",
            "indexFilterable": True
        },
        {
            "name": "escrowRequired",
            "dataType": ["boolean"],
            "description": "Escrow account required flag"
        },
        {
            "name": "pmiRequired",
            "dataType": ["boolean"],
            "description": "PMI required flag"
        },
        {
            "name": "pmiAmount",
            "dataType": ["number"],
            "description": "Monthly PMI amount"
        },
        {
            "name": "nextPaymentDate",
            "dataType": ["date"],
            "description": "Next payment due date"
        },
        {
            "name": "paymentFrequency",
            "dataType": ["text"],
            "description": "Payment frequency"
        },
        {
            "name": "securityId",
            "dataType": ["int"],
            "description": "Associated security ID"
        },
        {
            "name": "loanSummaryText",
            "dataType": ["text"],
            "description": "Loan summary for vectorization",
            "moduleConfig": {
                "text2vec-transformers": {
                    "skip": False,
                    "vectorizePropertyName": False
                }
            }
        },
        {
            "name": "hasCustomer",
            "dataType": ["Customer"],
            "description": "Reference to customer"
        },
        {
            "name": "hasProperty",
            "dataType": ["Property"],
            "description": "Reference to property"
        }
    ]
}


# ============================================================
# CLASS: Property
# ============================================================
property_class = {
    "class": "Property",
    "description": "Property details",
    "vectorizer": "text2vec-transformers",
    "moduleConfig": {
        "text2vec-transformers": {
            "vectorizeClassName": False,
            "poolingStrategy": "masked_mean"
        }
    },
    "properties": [
        {
            "name": "propertyId",
            "dataType": ["int"],
            "description": "Unique property identifier"
        },
        {
            "name": "addressFull",
            "dataType": ["text"],
            "description": "Complete address",
            "indexSearchable": True
        },
        {
            "name": "addressLine1",
            "dataType": ["text"],
            "description": "Address line 1"
        },
        {
            "name": "city",
            "dataType": ["text"],
            "description": "City",
            "indexFilterable": True
        },
        {
            "name": "state",
            "dataType": ["text"],
            "description": "State code",
            "indexFilterable": True
        },
        {
            "name": "zipCode",
            "dataType": ["text"],
            "description": "ZIP code",
            "indexFilterable": True
        },
        {
            "name": "country",
            "dataType": ["text"],
            "description": "Country"
        },
        {
            "name": "propertyType",
            "dataType": ["text"],
            "description": "Property type",
            "indexFilterable": True
        },
        {
            "name": "yearBuilt",
            "dataType": ["int"],
            "description": "Year built"
        },
        {
            "name": "squareFeet",
            "dataType": ["int"],
            "description": "Square footage"
        },
        {
            "name": "bedrooms",
            "dataType": ["int"],
            "description": "Number of bedrooms"
        },
        {
            "name": "bathrooms",
            "dataType": ["number"],
            "description": "Number of bathrooms"
        },
        {
            "name": "purchasePrice",
            "dataType": ["number"],
            "description": "Purchase price"
        },
        {
            "name": "currentValue",
            "dataType": ["number"],
            "description": "Current market value",
            "indexRangeFilters": True
        },
        {
            "name": "lastAppraisalDate",
            "dataType": ["date"],
            "description": "Last appraisal date"
        },
        {
            "name": "lastAppraisalValue",
            "dataType": ["number"],
            "description": "Last appraisal value"
        },
        {
            "name": "taxAssessmentValue",
            "dataType": ["number"],
            "description": "Tax assessment value"
        },
        {
            "name": "annualTaxAmount",
            "dataType": ["number"],
            "description": "Annual property tax"
        },
        {
            "name": "hoaFees",
            "dataType": ["number"],
            "description": "Monthly HOA fees"
        },
        {
            "name": "floodZone",
            "dataType": ["text"],
            "description": "Flood zone designation",
            "indexFilterable": True
        },
        {
            "name": "propertyTaxId",
            "dataType": ["text"],
            "description": "Property tax ID"
        },
        {
            "name": "geoCoordinates",
            "dataType": ["geoCoordinates"],
            "description": "Property location coordinates"
        },
        {
            "name": "propertyDescriptionText",
            "dataType": ["text"],
            "description": "Property description for vectorization",
            "moduleConfig": {
                "text2vec-transformers": {
                    "skip": False,
                    "vectorizePropertyName": False
                }
            }
        }
    ]
}


# ============================================================
# CLASS: Security
# ============================================================
security_class = {
    "class": "Security",
    "description": "Mortgage-backed securities",
    "vectorizer": "text2vec-transformers",
    "moduleConfig": {
        "text2vec-transformers": {
            "vectorizeClassName": False,
            "poolingStrategy": "masked_mean"
        }
    },
    "properties": [
        {
            "name": "securityId",
            "dataType": ["int"],
            "description": "Unique security identifier"
        },
        {
            "name": "securityName",
            "dataType": ["text"],
            "description": "Security name",
            "indexSearchable": True
        },
        {
            "name": "securityType",
            "dataType": ["text"],
            "description": "Security type",
            "indexFilterable": True
        },
        {
            "name": "cusip",
            "dataType": ["text"],
            "description": "CUSIP identifier",
            "indexFilterable": True
        },
        {
            "name": "issueDate",
            "dataType": ["date"],
            "description": "Issue date"
        },
        {
            "name": "maturityDate",
            "dataType": ["date"],
            "description": "Maturity date"
        },
        {
            "name": "couponRate",
            "dataType": ["number"],
            "description": "Coupon rate"
        },
        {
            "name": "faceValue",
            "dataType": ["number"],
            "description": "Face value"
        },
        {
            "name": "currentBalance",
            "dataType": ["number"],
            "description": "Current balance"
        },
        {
            "name": "issuer",
            "dataType": ["text"],
            "description": "Issuer name",
            "indexFilterable": True
        },
        {
            "name": "rating",
            "dataType": ["text"],
            "description": "Credit rating",
            "indexFilterable": True
        },
        {
            "name": "status",
            "dataType": ["text"],
            "description": "Security status",
            "indexFilterable": True
        },
        {
            "name": "lastTradeDate",
            "dataType": ["date"],
            "description": "Last trade date"
        },
        {
            "name": "lastTradePrice",
            "dataType": ["number"],
            "description": "Last trade price"
        },
        {
            "name": "securityDescriptionText",
            "dataType": ["text"],
            "description": "Security description for vectorization",
            "moduleConfig": {
                "text2vec-transformers": {
                    "skip": False,
                    "vectorizePropertyName": False
                }
            }
        }
    ]
}


# ============================================================
# CLASS: Application
# ============================================================
application_class = {
    "class": "Application",
    "description": "Loan applications",
    "vectorizer": "text2vec-transformers",
    "moduleConfig": {
        "text2vec-transformers": {
            "vectorizeClassName": False,
            "poolingStrategy": "masked_mean"
        }
    },
    "properties": [
        {
            "name": "applicationId",
            "dataType": ["int"],
            "description": "Unique application identifier"
        },
        {
            "name": "customerId",
            "dataType": ["int"],
            "description": "Customer ID",
            "indexFilterable": True
        },
        {
            "name": "productId",
            "dataType": ["int"],
            "description": "Product ID"
        },
        {
            "name": "officerId",
            "dataType": ["int"],
            "description": "Loan officer ID",
            "indexFilterable": True
        },
        {
            "name": "applicationDate",
            "dataType": ["date"],
            "description": "Application date"
        },
        {
            "name": "loanAmount",
            "dataType": ["number"],
            "description": "Requested loan amount"
        },
        {
            "name": "loanPurpose",
            "dataType": ["text"],
            "description": "Loan purpose",
            "indexFilterable": True
        },
        {
            "name": "status",
            "dataType": ["text"],
            "description": "Application status",
            "indexFilterable": True
        },
        {
            "name": "closingDate",
            "dataType": ["date"],
            "description": "Closing date"
        },
        {
            "name": "applicationFee",
            "dataType": ["number"],
            "description": "Application fee"
        },
        {
            "name": "dti",
            "dataType": ["number"],
            "description": "Debt-to-income ratio"
        },
        {
            "name": "propertyValue",
            "dataType": ["number"],
            "description": "Property value"
        },
        {
            "name": "ltv",
            "dataType": ["number"],
            "description": "Loan-to-value ratio"
        },
        {
            "name": "rateOffered",
            "dataType": ["number"],
            "description": "Interest rate offered"
        },
        {
            "name": "termOffered",
            "dataType": ["int"],
            "description": "Term offered in months"
        },
        {
            "name": "denialReason",
            "dataType": ["text"],
            "description": "Denial reason if applicable"
        },
        {
            "name": "applicationSummaryText",
            "dataType": ["text"],
            "description": "Application summary for vectorization",
            "moduleConfig": {
                "text2vec-transformers": {
                    "skip": False,
                    "vectorizePropertyName": False
                }
            }
        },
        {
            "name": "forCustomer",
            "dataType": ["Customer"],
            "description": "Reference to customer"
        }
    ]
}


# ============================================================
# CLASS: Document
# ============================================================
document_class = {
    "class": "Document",
    "description": "Application documents",
    "vectorizer": "text2vec-transformers",
    "moduleConfig": {
        "text2vec-transformers": {
            "vectorizeClassName": False,
            "poolingStrategy": "masked_mean"
        }
    },
    "properties": [
        {
            "name": "documentId",
            "dataType": ["int"],
            "description": "Unique document identifier"
        },
        {
            "name": "applicationId",
            "dataType": ["int"],
            "description": "Application ID",
            "indexFilterable": True
        },
        {
            "name": "documentType",
            "dataType": ["text"],
            "description": "Document type",
            "indexFilterable": True
        },
        {
            "name": "fileName",
            "dataType": ["text"],
            "description": "File name"
        },
        {
            "name": "uploadDate",
            "dataType": ["date"],
            "description": "Upload date"
        },
        {
            "name": "requiredFlag",
            "dataType": ["boolean"],
            "description": "Required document flag"
        },
        {
            "name": "receivedFlag",
            "dataType": ["boolean"],
            "description": "Received flag"
        },
        {
            "name": "approvalStatus",
            "dataType": ["text"],
            "description": "Approval status",
            "indexFilterable": True
        },
        {
            "name": "approvalDate",
            "dataType": ["date"],
            "description": "Approval date"
        },
        {
            "name": "approvedBy",
            "dataType": ["text"],
            "description": "Approver name"
        },
        {
            "name": "notes",
            "dataType": ["text"],
            "description": "Document notes"
        },
        {
            "name": "documentTextContent",
            "dataType": ["text"],
            "description": "Extracted document text content for vectorization",
            "moduleConfig": {
                "text2vec-transformers": {
                    "skip": False,
                    "vectorizePropertyName": False
                }
            }
        },
        {
            "name": "forApplication",
            "dataType": ["Application"],
            "description": "Reference to application"
        }
    ]
}


# ============================================================
# Example Usage Code
# ============================================================
"""
import weaviate

# Initialize Weaviate client
client = weaviate.Client("http://localhost:8080")

# Create all classes
client.schema.create_class(customer_class)
client.schema.create_class(property_class)
client.schema.create_class(security_class)
client.schema.create_class(application_class)
client.schema.create_class(loan_class)
client.schema.create_class(document_class)

# Add data example
data_object = {
    "customerId": 1000,
    "fullName": "John Doe",
    "firstName": "John",
    "lastName": "Doe",
    "email": "john.doe@example.com",
    "phone": "555-1234",
    "annualIncome": 85000.0,
    "employmentStatus": "Employed",
    "employer": "Tech Corp",
    "yearsEmployed": 5,
    "creditScore": 750,
    "createdDate": "2023-01-15T10:00:00Z",
    "lastUpdatedDate": "2025-12-27T10:00:00Z",
    "customerProfileText": "John Doe, employed software engineer with 5 years at Tech Corp, excellent credit score of 750"
}

client.data_object.create(
    data_object=data_object,
    class_name="Customer"
)

# Query example
result = (
    client.query
    .get("Customer", ["fullName", "creditScore", "employmentStatus"])
    .with_near_text({"concepts": ["high credit score employed engineer"]})
    .with_where({
        "path": ["creditScore"],
        "operator": "GreaterThanEqual",
        "valueInt": 700
    })
    .with_limit(10)
    .do()
)

# GraphQL query with cross-references
result = (
    client.query
    .get("Loan", ["loanId", "loanAmount", "status"])
    .with_near_text({"concepts": ["active mortgage good standing"]})
    .with_additional(["id", "distance"])
    .do()
)
"""
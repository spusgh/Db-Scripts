# XYZ Financials MongoDB Database

This repository contains the MongoDB data model for **XYZ Financials & Securities**, migrated from the original SQL Server schema.  
The database supports loan origination, servicing, payments, risk assessments, securities, and capital market data.

---

## 📂 Collections Overview

| Collection            | Purpose                                                                 |
|-----------------------|-------------------------------------------------------------------------|
| <a href="https://github.com/spusgh/Db-Scripts/blob/main/XYZFinancialssecuritiesMongoDB/database/Customer.json">`customers`</a>          | Master customer records with demographics, income, credit score, etc.   |
| `customer_addresses`  | Historical addresses linked to customers.                               |
| <a href="https://github.com/spusgh/Db-Scripts/blob/main/XYZFinancialssecuritiesMongoDB/database/Applications.json">`applications`</a>        | Loan applications with terms, fees, and approval status.                |
| <a href="https://github.com/spusgh/Db-Scripts/blob/main/XYZFinancialssecuritiesMongoDB/database/Loan.json">`loans`</a>               | Active loan contracts, balances, and payment schedules.                 |
| <a href="https://github.com/spusgh/Db-Scripts/blob/main/XYZFinancialssecuritiesMongoDB/database/Payments.json">`payments`</a>            | High‑volume loan payment transactions.                                  |
| `loan_modifications`  | Loan term changes (rate, term, payment).                                |
| `properties`          | Real estate property details linked to loans.                           |
| `products`            | Mortgage product definitions (term, rate, credit score requirements).   |
| `loan_officers`       | Loan officer directory with branch and commission info.                 |
| `escrows`             | Escrow account balances for taxes, insurance, PMI.                      |
| `escrow_transactions` | Escrow account transaction history.                                     |
| `risk_assessments`    | Credit risk evaluations for applications/customers.                     |
| `defaults_foreclosures` | Default and foreclosure events with legal details.                   |
| `documents`           | Registry of loan application documents (metadata only).                 |
| `market_data`         | Capital market rates (Treasury, Fed Funds, LIBOR, SOFR, MBS).           |
| `securities`          | Mortgage‑backed securities and related instruments.                     |
| `servicing_rights`    | Mortgage servicing rights (MSR) transfers and fees.                     |
| `audit_log`           | Audit trail of entity changes and user actions.                         |
| `reference_data`      | Supporting lookup tables (FINRA FI, interest types, product subtypes).  |

---


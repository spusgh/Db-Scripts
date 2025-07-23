# 🏁 Project Title: Power Platform Loan Ecosystem
A FINRA-compliant loan origination, risk scoring, servicing, and capital markets platform built using Microsoft Power Platform components: Power Apps, Power Automate, Power BI, Synapse, and secure SQL Server schema.

## 🧭 System Architecture Overview
#### Mermaid Diagram
![image](https://github.com/spusgh/Db-Scripts/blob/main/DbModels/Mermaid_Live_Editor-MSPowerPlatformLoanEcosystem-SystemArchitecture.png)


## 🔄 Loan Origination & Servicing Workflow
#### Mermaid Diagram
![image](https://github.com/spusgh/Db-Scripts/blob/main/DbModels/Mermaid_Live_Editor-MSPowerPlatformLoanEcosystem-LoanOriginationServicingWorkflow.png)


## 🧬 Data Lineage Highlights (Key Attributes)
| Field	| Origin Table	| Transformations & Usage| 
| :---   | :--- | :--- |
| LoanAmount	| Applications, Loans	| Used for risk scoring, escrow, payment scheduling |
| CreditScore	| Customers → RiskAssessments	| Scored by AI Builder, tagged for Purview |
| DTI / LTV	| Applications, RiskAssessments	| Used in AI risk model, tied to approval logic |
| DenialReason	| Applications	| Workflow flag with audit trail |
| CUSIP	| FINRA_FI, Securities	| Capital markets linkage, sensitive identifier |
| SSN	| Customers	| Tagged as PII, secured via DLP policy |
| AuditLog.*	| AuditLog Table	| Tracks all entity changes + connects to Sentinel |

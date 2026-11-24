
# Staging Data Validation Report

## Project
Customer Churn Prediction and Retention Intelligence System

## Data Source
Maven Analytics - Telecom Customer Churn

## Objective
Validate the integrity and consistency of data imported
from the original CSV files into SQL Server.

## Technology Stack
- Microsoft SQL Server 2019
- Python 3.14
- Pandas
- pyodbc
- SQL Server Management Studio

## Source Tables

| Table | Records | Columns |
|---|---:|---:|
| stg.CustomerChurn | 7043 | 38 |
| stg.ZipCodePopulation | 1671 | 2 |
| stg.DataDictionary | 40 | 3 |

## Validation Results

### Customer Integrity
- Total customers: 7043
- Unique Customer IDs: 7043
- Missing Customer IDs: 0
- Duplicate Customer IDs: 0

### Customer Status
- Stayed: 4720
- Churned: 1869
- Joined: 454

### Offer Validation
- Customers with Offer = None: 3877
- Missing Offer values: 0
- The category "None" was preserved as text.

### ZIP Code Integrity
- Reference ZIP codes: 1671
- ZIP codes used by customers: 1626
- Unused reference ZIP codes: 45
- Customers without a matching ZIP code: 0

### Structural Missingness
- 1526 customers have no internet service.
- Ten internet-related columns are structurally missing.
- 682 customers have no phone service.
- Two phone-related columns are structurally missing.
- No unexpected missing values were found in these
  validated service-related columns.

### Full Data Comparison
The original CSV files were compared with the corresponding
SQL Server staging tables using Python.

Comparison method:
- Column names and order were verified.
- Complete rows were compared as multisets.
- Empty CSV cells were normalized to SQL NULL.
- Row ordering was not assumed.

Results:
- CustomerChurn: PASSED
- ZipCodePopulation: PASSED
- DataDictionary: PASSED

Missing rows in SQL: 0
Extra rows in SQL: 0

## Conclusion
All three staging datasets passed the defined integrity
and content validation checks.

The staging layer is ready for the next phase:
Data Preparation and Feature Engineering.

## Important Limitations
- Staging columns are stored as NVARCHAR.
- Numerical conversion and business transformations
  have not yet been applied.
- Predictive feature eligibility remains under review,
  especially regarding temporal data leakage.

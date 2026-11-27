
# Core Data Layer - Validation Report

## 1. Overview

This report documents the creation, loading, and validation
of the typed core data layer for the Customer Churn Prediction
and Retention Intelligence System.

The objective is to transform validated staging records into
properly typed SQL Server tables while preserving data integrity.

## 2. Data Sources

| Source Table | Target Table | Records |
|---|---|---:|
| stg.CustomerChurn | core.CustomerChurn | 7,043 |
| stg.ZipCodePopulation | core.ZipCodePopulation | 1,671 |


The original staging tables remain unchanged.

## 3. Data Type Validation

Numeric fields were profiled before conversion.

Results:

- 14 customer numeric fields examined.
- 0 invalid numeric conversions.
- 5 integer fields validated, including ZIP population.
- 0 invalid integer conversions.
- 0 fractional values in integer fields.
- 10 decimal fields validated.
- 0 decimal precision violations.
- 0 decimal conversion problems.

Selected target data types:

- INT for discrete numeric fields.
- DECIMAL (18,2) for financial and usage metrics.
- DECIMAL (18,6) for geographic coordinates.
- NVARCHAR for categorical fields and identifiers.

## 4. Negative Monthly Charges

A total of 120 customers (approximately 1.70%)
have negative monthly charges.

Observed values range from -10.00 to -1.00.

The records are distributed across customer statuses
and service combinations.

Decision:

Retain the original negative values because the available
evidence does not establish that they are erroneous.

Their business interpretation remains unconfirmed.

## 5. Core Data Loading

The loading process uses a SQL Server transaction.

Controls include:

- Source record count verification.
- Prevention of duplicate or partial reloads.
- Explicit numeric conversions.
- Target record count verification.
- Transaction rollback on failure.

The core loading script completed and produced the
expected record counts.

## 6. Core Data Validation Results

| Validation | Result |
|---|---|
| Customer records | 7,043 |
| ZIP population records | 1,671 |
| Duplicate customer keys | 0 |
| Duplicate ZIP keys | 0 |
| Missing keys | 0 |
| Customer record differences | 0 |
| ZIP record differences | 0 |

Bidirectional EXCEPT comparisons detected no differences
under the defined SQL Server comparison rules.

## 7. Preserved Data Characteristics

| Indicator | Core Result |
|---|---:|
| Negative monthly charges | 120 |
| Missing monthly GB download | 1,526 |
| Missing long-distance charges | 682 |
| Offer = None | 3,877 |
| Churned customers | 1,869 |
| Joined customers | 454 |
| Stayed customers | 4,720 |

Missing values associated with unavailable services
were preserved.

## 8. Validation Scope and Limitations

The validation confirms consistency between the staging
and typed core layers using the implemented checks.

It does not establish that every source value is
commercially accurate.

The dataset is a historical snapshot. Feature availability
and potential target leakage require further review before
building predictive models.

## 9. SQL Scripts

- `sql/05_profile_numeric_fields.sql`
- `sql/06_create_core_tables.sql`
- `sql/07_load_core_data.sql`
- `sql/08_validate_core_data.sql`

## 10. Conclusion

The typed core data layer was successfully created,
loaded, and validated.

No differences were detected between staging and core
in the implemented bidirectional comparisons.

The data is ready for the next stage:
Machine Learning dataset design and feature engineering.

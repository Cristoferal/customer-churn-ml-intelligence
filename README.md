# Customer Churn Prediction and Retention Intelligence System

An end-to-end Data Science and Machine Learning project
integrating SQL Server, Python, and Power BI to analyze
telecommunications customer churn and support data-driven
customer retention strategies.

## 1. Project Overview

Customer churn represents a major challenge for
telecommunications companies, directly affecting revenue,
customer lifetime value, and retention costs.

This project aims to develop an analytical solution that
combines data engineering, exploratory data analysis,
predictive modeling, and business intelligence.

The goal is to identify customers at risk of
churning and translate analytical findings into
actionable retention insights.

## 2. Project Objectives

- Build a reproducible data engineering pipeline.
- Validate source data integrity and consistency.
- Analyze customer behavior and churn patterns.
- Develop and evaluate machine learning models.
- Identify factors associated with customer churn.
- Design a Power BI retention intelligence dashboard.
- Document methodology, limitations, and findings.

## 3. Technology Stack

| Technology | Purpose |
|---|---|
| SQL Server 2019 | Data storage, transformation, and validation |
| Python 3.14 | Data ingestion, analysis, and machine learning |
| Pandas/NumPy | Data analysis |
| Scikit-learn | Predictive modeling (planned) |
| Matplotlib/Seaborn | Data visualization |
| Power BI | Business intelligence dashboard (planned) |
| Git/GitHub | Version control and documentation |

## 4. Dataset

**Source:** Maven Analytics - Telecom Customer Churn

The dataset contains:

- 7,043 customer records
- 38 customer-related columns
- 1,671 ZIP code reference records
- 40 data dictionary entries

Customer Status distribution:

| Status | Customers |
|---|---:|
| Stayed | 4,720 |
| Churned | 1,869 |
| Joined | 454 |

The original CSV files are not included in this repository.
They must be downloaded separately from Maven Analytics.

## 5. Project Architecture

```text
Maven Analytics CSV files
          |
          v
Python ingestion and source validation
          |
          v
SQL Server - stg (raw staging)
          |
          v
SQL Server - core (typed, validated data)
          |
          v
ML dataset design and feature engineering [in progress]
          |
          v
Model training, evaluation, and interpretation [planned]
          |
          v
Reporting layer and Power BI retention dashboard [planned]
```

The `stg` and `core` layers have been implemented and validated.
The machine learning and reporting components are under development.

## 6. Project Structure

- `data/` - Local source and processed datasets (excluded from Git)
- `docs/` - Technical documentation and validation reports
- `notebooks/` - Exploratory analysis and experiments
- `powerbi/` - Power BI dashboards (planned)
- `reports/` - Analytical reports and findings (planned)
- `sql/` - Database setup, profiling, transformation, and validation scripts
- `src/` - Python ingestion, validation, and future ML code
- `requirements.txt` - Python environment dependencies

## 7. Completed Work

### Staging Data Engineering

- Created `CustomerChurnDB` in SQL Server.
- Established `stg`, `core`, `ml`, and `reporting` schemas.
- Implemented Python-based CSV ingestion.
- Imported three Maven Analytics datasets into staging.
- Validated customer identifiers and ZIP code relationships.
- Verified customer status and offer categories.
- Investigated structural missing values.
- Compared complete source records against SQL Server staging records.

**Result:** All three staging datasets passed the defined
integrity and content comparison checks.

### Exploratory Data Analysis

- Inspected dataset structure and data types.
- Analyzed missing value patterns.
- Investigated customer status distribution.
- Identified target leakage risks.
- Created a preliminary feature audit.
- Integrated the official data dictionary.

### Core Data Preparation and Validation

- Profiled 14 numeric customer fields and found no invalid numeric conversions.
- Validated five integer fields (including ZIP population) with no invalid or fractional values.
- Validated ten decimal fields with no detected scale or conversion problems.
- Examined 120 customers with negative monthly charges; retained these values because their business meaning remains unconfirmed.
- Created typed `core.CustomerChurn` (38 columns) and `core.ZipCodePopulation` (2 columns).
- Loaded 7,043 customer records and 1,671 ZIP population records through a controlled SQL transaction.
- Verified key uniqueness and non-missing identifiers.
- Detected zero differences in bidirectional `EXCEPT` comparisons between staging and core under the implemented SQL Server comparison rules.
- Preserved 1,526 missing monthly GB download values, 682 missing long-distance charge values, and the original customer status distribution.

**Result:** The typed core layer has been created, loaded, and
validated against staging. Feature selection and ML-specific
transformations have not yet been completed.

## 8. Machine Learning Methodology

The intended modeling approach includes:

1. Define the target population and prediction scenario.
2. Review feature availability and potential target leakage.
3. Prepare features and handle missing values.
4. Establish baseline classification models.
5. Train and compare machine learning algorithms.
6. Evaluate precision, recall, F1-score, and ROC-AUC.
7. Interpret model results and translate findings into retention insights.

**Important limitation:**
The dataset represents a historical customer snapshot.
Some variables are measured at the end of the same
period used to determine customer status.

Consequently, the initial model will be evaluated as
a retrospective classification experiment. Its results
must not be presented as proven prospective churn
predictions without appropriate temporal validation.

## 9. Reproducibility

The project was developed on Windows using Python 3.14,
SQL Server 2019, and ODBC Driver 17 for SQL Server.

To reproduce the currently implemented data pipeline:

1. Clone the repository.
2. Create and activate a Python virtual environment.
3. Install packages from `requirements.txt`.
4. Download the three CSV files from Maven Analytics.
5. Place them in `data/raw/`.
6. Configure a local SQL Server instance and Windows Authentication.
7. Run `sql/01_create_database.sql`, `sql/02_create_schemas.sql`, and `sql/03_create_staging_tables.sql` in order.
8. Run `python src/load_staging_data.py`.
9. Run `sql/04_validate_staging_data.sql` and `python src/validate_staging_data.py`.
10. Run `sql/05_profile_numeric_fields.sql` to review numeric types and observed exceptions.
11. Run `sql/06_create_core_tables.sql` to create empty typed tables.
12. Run `sql/07_load_core_data.sql` **once**, after confirming both core tables are empty.
13. Run `sql/08_validate_core_data.sql` to verify consistency between the staging and core layers.

The Python ingestion scripts currently use a local SQL Server
connection with Windows Authentication. Adjust the connection
configuration for your environment before running them.

The core loading script intentionally rejects repeat loads into
non-empty target tables. Do not delete existing core data merely
to rerun the validation scripts.

## 10. Technical Documentation

- [Staging Data Validation Report](docs/01_staging_validation.md)
- [Core Data Layer Validation Report](docs/02_core_data_validation.md)

## 11. Project Status

**Current stage:** Data Preparation and Feature Engineering.

**Completed:** Raw staging ingestion, data quality profiling,
typed core tables, transactional loading, and cross-layer validation.

**Next:** Define the modeling population, assess target leakage,
and build the ML feature dataset.

Machine learning model results and the Power BI dashboard
will be added as development progresses.

## 12. Author

**Cristoferal**

Business Intelligence professional with a background in Computer Engineering and a growing focus on Data Science, Machine Learning, and Predictive Analytics.

This project reflects an interest in developing end-to-end analytical solutions that combine data engineering, machine learning, and business intelligence to address real-world business challenges.


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
| SQL Server 2019 | Data storage and transformation |
| Python 3.14 | Data processing and machine learning |
| Pandas/NumPy | Data analysis |
| Scikit-learn | Predictive modeling |
| Matplotlib/Seaborn | Data visualization |
| Power BI | Business intelligence dashboard |
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

Data Source (CSV)
    |
    v
Python ETL
    |
    v
SQL Server - Staging Layer
    |
    v
Data Preparation and Feature Engineering
    |
    v
Machine Learning Models
    |
    v
Predictions & Model Evaluation
    |
    v
Power BI Retention Dashboard

The staging layer has been implemented and validated.
The downstream components are under development.

## 6. Project Structure

- `data/` — Source and processed datasets (excluded from Git)
- `docs/` — Technical documentation
- `notebooks/` — Exploratory analysis and experiments
- `powerbi/` — Power BI dashboards
- `reports/` — Analytical reports and findings
- `sql/` — Database creation and validation scripts
- `src/` — Python ETL and ML source code
- `requirements.txt` — Python environment dependencies

## 7. Completed Work

### Data Engineering

- Created CustomerChurnDB in SQL Server.
- Created staging, machine learning, and reporting schemas.
- Implemented Python-based CSV ingestion.
- Imported three Maven Analytics datasets.
- Validated customer identifiers and ZIP code relationships.
- Verified customer status and offer categories.
- Investigated structural missing values.
- Compared complete source records against SQL Server.

**Result:** All three staging datasets passed the
defined integrity and content comparison checks.

### Exploratory Data Analysis

- Inspected dataset structure and data types.
- Analyzed missing value patterns.
- Investigated customer status distribution.
- Identified target leakage risks.
- Created a preliminary feature audit.
- Integrated the official data dictionary.

## 8. Machine Learning Methodology

The intended modeling approach includes:

1. Define the target and prediction scenario.
2. Prepare features and handle missing values.
3. Establish baseline classification models.
4. Train and compare machine learning algorithms.
5. Evaluate precision, recall, F1-score, and ROC-AUC.
6. Interpret model predictions.
7. Translate results into retention insights.

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

To reproduce the staging pipeline:

1. Clone the repository.
2. Create a Python virtual environment.
3. Install packages from `requirements.txt`.
4. Download the three CSV files from Maven Analytics.
5. Place them in `data/raw/`.
6. Configure a local SQL Server instance.
7. Execute the SQL scripts 01 through 03 in order.
8. Run `src/load_staging_data.py`.
9. Execute `sql/04_validate_staging_data.sql`.
10. Run `src/validate_staging_data.py`.

The provided Python scripts currently use a local SQL
Server connection with Windows Authentication.

## 10. Technical Documentation

- [Staging Data Validation Report](docs/01_staging_validation.md)

## 11. Project Status

**Current stage:** Data Engineering completed;
Data Preparation and Feature Engineering are next.

Machine learning model results and the Power BI
dashboard will be added as development progresses.

## 12. Author

**Cristoferal**

Business Intelligence professional with a background in Computer Engineering and a growing focus on Data Science, Machine Learning, and Predictive Analytics.

This project reflects an interest in developing end-to-end analytical solutions that combine data engineering, machine learning, and business intelligence to address real-world business challenges.
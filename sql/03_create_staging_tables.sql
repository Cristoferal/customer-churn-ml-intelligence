USE CustomerChurnDB;
GO

/* ============================================================================
   PROJECT : Customer Churn Prediction & Retention Intelligence System
   FILE    : 03_create_staging_tables.sql
   PURPOSE : Create raw staging tables for the three source CSV files.

   SOURCES : telecom_customer_churn.csv
             telecom_zipcode_population.csv
             telecom_data_dictionary.csv

   CONTENTS:
      01. Create Customer Churn Staging Table
      02. Create ZIP Code Population Staging Table
      03. Create Data Dictionary Staging Table
      04. Verify Staging Table Structures

   NOTE    : Source columns are stored as NVARCHAR to preserve raw values.
             Existing tables are not recreated or modified.
             Requires the stg schema from 02_create_schemas.sql.
   ============================================================================ */


-- ============================================================================
-- 01. CREATE CUSTOMER CHURN STAGING TABLE
-- ============================================================================
-- Source  : telecom_customer_churn.csv
-- Output  : stg.CustomerChurn with 38 source columns.
-- ============================================================================

IF OBJECT_ID(N'stg.CustomerChurn', N'U') IS NULL
BEGIN
    CREATE TABLE stg.CustomerChurn
    (
        [Customer ID] NVARCHAR(20) NULL,
        [Gender] NVARCHAR(100) NULL,
        [Age] NVARCHAR(100) NULL,
        [Married] NVARCHAR(100) NULL,
        [Number of Dependents] NVARCHAR(100) NULL,
        [City] NVARCHAR(100) NULL,
        [Zip Code] NVARCHAR(100) NULL,
        [Latitude] NVARCHAR(100) NULL,
        [Longitude] NVARCHAR(100) NULL,
        [Number of Referrals] NVARCHAR(100) NULL,
        [Tenure in Months] NVARCHAR(100) NULL,
        [Offer] NVARCHAR(100) NULL,
        [Phone Service] NVARCHAR(100) NULL,
        [Avg Monthly Long Distance Charges] NVARCHAR(100) NULL,
        [Multiple Lines] NVARCHAR(100) NULL,
        [Internet Service] NVARCHAR(100) NULL,
        [Internet Type] NVARCHAR(100) NULL,
        [Avg Monthly GB Download] NVARCHAR(100) NULL,
        [Online Security] NVARCHAR(100) NULL,
        [Online Backup] NVARCHAR(100) NULL,
        [Device Protection Plan] NVARCHAR(100) NULL,
        [Premium Tech Support] NVARCHAR(100) NULL,
        [Streaming TV] NVARCHAR(100) NULL,
        [Streaming Movies] NVARCHAR(100) NULL,
        [Streaming Music] NVARCHAR(100) NULL,
        [Unlimited Data] NVARCHAR(100) NULL,
        [Contract] NVARCHAR(100) NULL,
        [Paperless Billing] NVARCHAR(100) NULL,
        [Payment Method] NVARCHAR(100) NULL,
        [Monthly Charge] NVARCHAR(100) NULL,
        [Total Charges] NVARCHAR(100) NULL,
        [Total Refunds] NVARCHAR(100) NULL,
        [Total Extra Data Charges] NVARCHAR(100) NULL,
        [Total Long Distance Charges] NVARCHAR(100) NULL,
        [Total Revenue] NVARCHAR(100) NULL,
        [Customer Status] NVARCHAR(100) NULL,
        [Churn Category] NVARCHAR(100) NULL,
        [Churn Reason] NVARCHAR(100) NULL
    );
END;
GO


-- ============================================================================
-- 02. CREATE ZIP CODE POPULATION STAGING TABLE
-- ============================================================================
-- Source  : telecom_zipcode_population.csv
-- Output  : stg.ZipCodePopulation with 2 source columns.
-- ============================================================================

IF OBJECT_ID(N'stg.ZipCodePopulation', N'U') IS NULL
BEGIN
    CREATE TABLE stg.ZipCodePopulation
    (
        [Zip Code] NVARCHAR(20) NULL,
        [Population] NVARCHAR(50) NULL
    );
END;
GO


-- ============================================================================
-- 03. CREATE DATA DICTIONARY STAGING TABLE
-- ============================================================================
-- Source  : telecom_data_dictionary.csv
-- Output  : stg.DataDictionary with 3 source columns.
-- ============================================================================

IF OBJECT_ID(N'stg.DataDictionary', N'U') IS NULL
BEGIN
    CREATE TABLE stg.DataDictionary
    (
        [Table] NVARCHAR(100) NULL,
        [Field] NVARCHAR(100) NULL,
        [Description] NVARCHAR(1000) NULL
    );
END;
GO


-- ============================================================================
-- 04. VERIFY STAGING TABLE STRUCTURES
-- ============================================================================
-- Purpose : Check the column count of the staging tables.
-- Expected: CustomerChurn = 38; ZipCodePopulation = 2; DataDictionary = 3.
-- ============================================================================

SELECT
    s.name AS SchemaName,
    t.name AS TableName,
    COUNT(c.column_id) AS TotalColumns
FROM sys.tables AS t
INNER JOIN sys.schemas AS s
    ON t.schema_id = s.schema_id
INNER JOIN sys.columns AS c
    ON t.object_id = c.object_id
WHERE s.name = N'stg'
GROUP BY
    s.name,
    t.name
ORDER BY
    t.name;
GO

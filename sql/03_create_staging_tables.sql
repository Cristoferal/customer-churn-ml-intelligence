
USE CustomerChurnDB;
GO

/* ==========================================
   1. CUSTOMER CHURN — RAW STAGING
   Source: telecom_customer_churn.csv
   ========================================== */

IF OBJECT_ID('stg.CustomerChurn', 'U') IS NULL
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

/* ==========================================
   2. ZIP CODE POPULATION
   Source: telecom_zipcode_population.csv
   ========================================== */

IF OBJECT_ID('stg.ZipCodePopulation', 'U') IS NULL
BEGIN
    CREATE TABLE stg.ZipCodePopulation
    (
        [Zip Code] NVARCHAR(20) NULL,
        [Population] NVARCHAR(50) NULL
    );
END;
GO

/* ==========================================
   3. DATA DICTIONARY
   Source: telecom_data_dictionary.csv
   ========================================== */

IF OBJECT_ID('stg.DataDictionary', 'U') IS NULL
BEGIN
    CREATE TABLE stg.DataDictionary
    (
        [Table] NVARCHAR(100) NULL,
        [Field] NVARCHAR(100) NULL,
        [Description] NVARCHAR(1000) NULL
    );
END;
GO

/* ==========================================
   4. VALIDATE TABLE STRUCTURES
   ========================================== */

SELECT
    s.name AS SchemaName,
    t.name AS TableName,
    COUNT(c.column_id) AS TotalColumns
FROM sys.tables t
INNER JOIN sys.schemas s
    ON t.schema_id = s.schema_id
INNER JOIN sys.columns c
    ON t.object_id = c.object_id
WHERE s.name = 'stg'
GROUP BY
    s.name,
    t.name
ORDER BY
    t.name;
GO

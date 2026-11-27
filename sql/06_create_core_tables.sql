
USE CustomerChurnDB;
GO

/* ============================================================
   PROJECT: Customer Churn Prediction & Retention Intelligence
   FILE: 06_create_core_tables.sql

   PURPOSE:
   Create typed tables for the curated data layer.

   SOURCE:
   stg.CustomerChurn
   stg.ZipCodePopulation

   NOTE:
   This script creates empty tables.
   No staging data is modified.
   ============================================================ */


-- ============================================================
-- 1. CREATE CORE SCHEMA
-- ============================================================

IF SCHEMA_ID(N'core') IS NULL
BEGIN
    EXEC(N'CREATE SCHEMA core');
END;
GO


-- ============================================================
-- 2. CREATE CORE CUSTOMER CHURN TABLE
-- ============================================================

IF OBJECT_ID(N'core.CustomerChurn', N'U') IS NULL
BEGIN

    CREATE TABLE core.CustomerChurn
    (
        customer_id NVARCHAR(20) NOT NULL,

        gender NVARCHAR(100) NULL,
        age INT NULL,
        married NVARCHAR(100) NULL,
        number_of_dependents INT NULL,

        city NVARCHAR(100) NULL,
        zip_code NVARCHAR(100) NULL,
        latitude DECIMAL(18,6) NULL,
        longitude DECIMAL(18,6) NULL,

        number_of_referrals INT NULL,
        tenure_months INT NULL,

        offer NVARCHAR(100) NULL,

        phone_service NVARCHAR(100) NULL,

        avg_monthly_long_distance_charges
            DECIMAL(18,2) NULL,

        multiple_lines NVARCHAR(100) NULL,

        internet_service NVARCHAR(100) NULL,
        internet_type NVARCHAR(100) NULL,

        avg_monthly_gb_download
            DECIMAL(18,2) NULL,

        online_security NVARCHAR(100) NULL,
        online_backup NVARCHAR(100) NULL,

        device_protection_plan NVARCHAR(100) NULL,
        premium_tech_support NVARCHAR(100) NULL,

        streaming_tv NVARCHAR(100) NULL,
        streaming_movies NVARCHAR(100) NULL,
        streaming_music NVARCHAR(100) NULL,

        unlimited_data NVARCHAR(100) NULL,

        contract NVARCHAR(100) NULL,
        paperless_billing NVARCHAR(100) NULL,
        payment_method NVARCHAR(100) NULL,

        monthly_charge DECIMAL(18,2) NULL,
        total_charges DECIMAL(18,2) NULL,
        total_refunds DECIMAL(18,2) NULL,

        total_extra_data_charges
            DECIMAL(18,2) NULL,

        total_long_distance_charges
            DECIMAL(18,2) NULL,

        total_revenue DECIMAL(18,2) NULL,

        customer_status NVARCHAR(100) NULL,
        churn_category NVARCHAR(100) NULL,
        churn_reason NVARCHAR(100) NULL,

        CONSTRAINT PK_core_CustomerChurn
            PRIMARY KEY CLUSTERED (customer_id)
    );

END;
GO


-- ============================================================
-- 3. CREATE CORE ZIP CODE POPULATION TABLE
-- ============================================================

IF OBJECT_ID(N'core.ZipCodePopulation', N'U') IS NULL
BEGIN

    CREATE TABLE core.ZipCodePopulation
    (
        zip_code NVARCHAR(20) NOT NULL,
        population INT NOT NULL,

        CONSTRAINT PK_core_ZipCodePopulation
            PRIMARY KEY CLUSTERED (zip_code)
    );

END;
GO


-- ============================================================
-- 4. VALIDATE CREATED TABLE STRUCTURES
-- ============================================================

SELECT
    s.name AS SchemaName,
    t.name AS TableName,
    COUNT(c.column_id) AS TotalColumns

FROM sys.tables t

INNER JOIN sys.schemas s
    ON t.schema_id = s.schema_id

INNER JOIN sys.columns c
    ON t.object_id = c.object_id

WHERE s.name = N'core'

GROUP BY
    s.name,
    t.name

ORDER BY
    t.name;
GO


-- ============================================================
-- 5. VERIFY TABLES ARE EMPTY
-- ============================================================

SELECT
    'CustomerChurn' AS TableName,
    COUNT_BIG(*) AS TotalRecords
FROM core.CustomerChurn

UNION ALL

SELECT
    'ZipCodePopulation',
    COUNT_BIG(*)
FROM core.ZipCodePopulation;
GO

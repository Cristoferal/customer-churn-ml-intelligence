
USE CustomerChurnDB;
GO

/* ============================================================================
   PROJECT : Customer Churn Prediction & Retention Intelligence
   FILE    : 08_validate_core_data.sql
   PURPOSE : Verify data integrity after loading the typed core layer.

   SOURCE TABLES:
       stg.CustomerChurn
       stg.ZipCodePopulation

   TARGET TABLES:
       core.CustomerChurn
       core.ZipCodePopulation

   VALIDATIONS:
       01. Record count comparison
       02. Customer and ZIP code key integrity
       03. Complete customer record comparison
       04. Complete ZIP code record comparison
       05. Business and missing-value consistency

   NOTE:
       Read-only validation. No data is modified.
   ============================================================================ */

SET NOCOUNT ON;
GO


-- ============================================================================
-- 01. RECORD COUNT COMPARISON
-- ============================================================================
-- Purpose : Confirm equal record counts between staging and core.
-- ============================================================================

SELECT
    'CustomerChurn' AS TableName,
    (SELECT COUNT_BIG(*) FROM stg.CustomerChurn) AS StagingRecords,
    (SELECT COUNT_BIG(*) FROM core.CustomerChurn) AS CoreRecords

UNION ALL

SELECT
    'ZipCodePopulation',
    (SELECT COUNT_BIG(*) FROM stg.ZipCodePopulation),
    (SELECT COUNT_BIG(*) FROM core.ZipCodePopulation);
GO


-- ============================================================================
-- 02. CUSTOMER AND ZIP CODE KEY INTEGRITY
-- ============================================================================
-- Purpose : Detect duplicate or missing identifiers.
-- ============================================================================

SELECT
    'CustomerChurn' AS TableName,
    COUNT_BIG(*) AS TotalRecords,
    COUNT(DISTINCT customer_id) AS UniqueKeys,

    SUM(
        CASE
            WHEN NULLIF(LTRIM(RTRIM(customer_id)), '') IS NULL
            THEN 1 ELSE 0
        END
    ) AS MissingKeys

FROM core.CustomerChurn

UNION ALL

SELECT
    'ZipCodePopulation',
    COUNT_BIG(*),
    COUNT(DISTINCT zip_code),

    SUM(
        CASE
            WHEN NULLIF(LTRIM(RTRIM(zip_code)), '') IS NULL
            THEN 1 ELSE 0
        END
    )

FROM core.ZipCodePopulation;
GO


-- ============================================================================
-- 03. COMPLETE CUSTOMER RECORD COMPARISON
-- ============================================================================
-- Purpose : Compare all 38 fields using equivalent data types.
--
-- EXCEPT identifies records present in one layer but not the other.
-- Both comparison directions must return zero differences.
-- ============================================================================

WITH StagingCustomer AS
(
    SELECT
        c.[Customer ID] AS customer_id,
        c.[Gender] AS gender,
        CONVERT(INT, c.[Age]) AS age,
        c.[Married] AS married,
        CONVERT(INT, c.[Number of Dependents]) AS number_of_dependents,
        c.[City] AS city,
        c.[Zip Code] AS zip_code,
        CONVERT(DECIMAL(18,6), c.[Latitude]) AS latitude,
        CONVERT(DECIMAL(18,6), c.[Longitude]) AS longitude,
        CONVERT(INT, c.[Number of Referrals]) AS number_of_referrals,
        CONVERT(INT, c.[Tenure in Months]) AS tenure_months,
        c.[Offer] AS offer,
        c.[Phone Service] AS phone_service,
        CONVERT(
            DECIMAL(18,2), c.[Avg Monthly Long Distance Charges]
        ) AS avg_monthly_long_distance_charges,
        c.[Multiple Lines] AS multiple_lines,
        c.[Internet Service] AS internet_service,
        c.[Internet Type] AS internet_type,
        CONVERT(
            DECIMAL(18,2), c.[Avg Monthly GB Download]
        ) AS avg_monthly_gb_download,
        c.[Online Security] AS online_security,
        c.[Online Backup] AS online_backup,
        c.[Device Protection Plan] AS device_protection_plan,
        c.[Premium Tech Support] AS premium_tech_support,
        c.[Streaming TV] AS streaming_tv,
        c.[Streaming Movies] AS streaming_movies,
        c.[Streaming Music] AS streaming_music,
        c.[Unlimited Data] AS unlimited_data,
        c.[Contract] AS contract,
        c.[Paperless Billing] AS paperless_billing,
        c.[Payment Method] AS payment_method,
        CONVERT(DECIMAL(18,2), c.[Monthly Charge]) AS monthly_charge,
        CONVERT(DECIMAL(18,2), c.[Total Charges]) AS total_charges,
        CONVERT(DECIMAL(18,2), c.[Total Refunds]) AS total_refunds,
        CONVERT(
            DECIMAL(18,2), c.[Total Extra Data Charges]
        ) AS total_extra_data_charges,
        CONVERT(
            DECIMAL(18,2), c.[Total Long Distance Charges]
        ) AS total_long_distance_charges,
        CONVERT(DECIMAL(18,2), c.[Total Revenue]) AS total_revenue,
        c.[Customer Status] AS customer_status,
        c.[Churn Category] AS churn_category,
        c.[Churn Reason] AS churn_reason

    FROM stg.CustomerChurn AS c
),

CoreCustomer AS
(
    SELECT
        customer_id,
        gender,
        age,
        married,
        number_of_dependents,
        city,
        zip_code,
        latitude,
        longitude,
        number_of_referrals,
        tenure_months,
        offer,
        phone_service,
        avg_monthly_long_distance_charges,
        multiple_lines,
        internet_service,
        internet_type,
        avg_monthly_gb_download,
        online_security,
        online_backup,
        device_protection_plan,
        premium_tech_support,
        streaming_tv,
        streaming_movies,
        streaming_music,
        unlimited_data,
        contract,
        paperless_billing,
        payment_method,
        monthly_charge,
        total_charges,
        total_refunds,
        total_extra_data_charges,
        total_long_distance_charges,
        total_revenue,
        customer_status,
        churn_category,
        churn_reason

    FROM core.CustomerChurn
),

StagingOnly AS
(
    SELECT * FROM StagingCustomer
    EXCEPT
    SELECT * FROM CoreCustomer
),

CoreOnly AS
(
    SELECT * FROM CoreCustomer
    EXCEPT
    SELECT * FROM StagingCustomer
)

SELECT
    'StagingNotInCore' AS Validation,
    COUNT_BIG(*) AS DifferentRecords
FROM StagingOnly

UNION ALL

SELECT
    'CoreNotInStaging',
    COUNT_BIG(*)
FROM CoreOnly;
GO


-- ============================================================================
-- 04. COMPLETE ZIP CODE RECORD COMPARISON
-- ============================================================================
-- Purpose : Compare ZIP codes and their population values.
-- ============================================================================

WITH StagingZip AS
(
    SELECT
        [Zip Code] AS zip_code,
        CONVERT(INT, [Population]) AS population
    FROM stg.ZipCodePopulation
),

CoreZip AS
(
    SELECT
        zip_code,
        population
    FROM core.ZipCodePopulation
),

StagingOnly AS
(
    SELECT * FROM StagingZip
    EXCEPT
    SELECT * FROM CoreZip
),

CoreOnly AS
(
    SELECT * FROM CoreZip
    EXCEPT
    SELECT * FROM StagingZip
)

SELECT
    'StagingZipNotInCore' AS Validation,
    COUNT_BIG(*) AS DifferentRecords
FROM StagingOnly

UNION ALL

SELECT
    'CoreZipNotInStaging',
    COUNT_BIG(*)
FROM CoreOnly;
GO


-- ============================================================================
-- 05. BUSINESS AND MISSING-VALUE CONSISTENCY
-- ============================================================================
-- Purpose : Verify previously documented data characteristics.
-- ============================================================================

-- 05.1. Preserve negative charges and structural missing values.

SELECT
    COUNT_BIG(*) AS TotalCustomers,

    SUM(
        CASE
            WHEN monthly_charge < 0 THEN 1 ELSE 0
        END
    ) AS NegativeMonthlyCharges,

    SUM(
        CASE
            WHEN avg_monthly_gb_download IS NULL
            THEN 1 ELSE 0
        END
    ) AS MissingGBDownload,

    SUM(
        CASE
            WHEN avg_monthly_long_distance_charges IS NULL
            THEN 1 ELSE 0
        END
    ) AS MissingLongDistanceCharges,

    SUM(
        CASE
            WHEN offer = N'None' THEN 1 ELSE 0
        END
    ) AS NoAcceptedOffer

FROM core.CustomerChurn;
GO


-- ----------------------------------------------------------------------------
-- 05.2. Verify customer status distribution.
-- ----------------------------------------------------------------------------

SELECT
    customer_status AS CustomerStatus,
    COUNT_BIG(*) AS TotalCustomers

FROM core.CustomerChurn

GROUP BY customer_status

ORDER BY customer_status;
GO

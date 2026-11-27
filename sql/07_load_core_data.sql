
USE CustomerChurnDB;
GO

/* ============================================================================
   PROJECT : Customer Churn Prediction & Retention Intelligence
   FILE    : 07_load_core_data.sql
   PURPOSE : Load validated staging data into typed core tables.

   SOURCE TABLES:
       stg.CustomerChurn
       stg.ZipCodePopulation

   TARGET TABLES:
       core.CustomerChurn
       core.ZipCodePopulation

   EXECUTION RULES:
       - Preserve original customer and categorical values.
       - Convert numeric fields to validated SQL data types.
       - Reject loading when target tables contain data.
       - Roll back all changes if any operation fails.
       - Do not modify staging tables.
   ============================================================================ */

SET NOCOUNT ON;
SET XACT_ABORT ON;
GO


-- ============================================================================
-- 01. BEGIN TRANSACTION AND VALIDATE PRECONDITIONS
-- ============================================================================

BEGIN TRY

    BEGIN TRANSACTION;

    -- Verify expected source row counts.

    IF (SELECT COUNT_BIG(*) FROM stg.CustomerChurn) <> 7043
    BEGIN
        THROW 51001,
            'Unexpected row count in stg.CustomerChurn.',
            1;
    END;

    IF (SELECT COUNT_BIG(*) FROM stg.ZipCodePopulation) <> 1671
    BEGIN
        THROW 51002,
            'Unexpected row count in stg.ZipCodePopulation.',
            1;
    END;

    -- Prevent accidental duplicate or partial reloads.

    IF EXISTS (SELECT 1 FROM core.CustomerChurn)
       OR EXISTS (SELECT 1 FROM core.ZipCodePopulation)
    BEGIN
        THROW 51003,
            'Core tables must be empty before loading.',
            1;
    END;


    -- ========================================================================
    -- 02. LOAD CORE CUSTOMER CHURN
    -- ========================================================================

    INSERT INTO core.CustomerChurn
    (
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
    )

    SELECT
        c.[Customer ID],
        c.[Gender],
        CONVERT(INT, c.[Age]),
        c.[Married],
        CONVERT(INT, c.[Number of Dependents]),
        c.[City],
        c.[Zip Code],
        CONVERT(DECIMAL(18,6), c.[Latitude]),
        CONVERT(DECIMAL(18,6), c.[Longitude]),
        CONVERT(INT, c.[Number of Referrals]),
        CONVERT(INT, c.[Tenure in Months]),
        c.[Offer],
        c.[Phone Service],
        CONVERT(
            DECIMAL(18,2),
            c.[Avg Monthly Long Distance Charges]
        ),
        c.[Multiple Lines],
        c.[Internet Service],
        c.[Internet Type],
        CONVERT(
            DECIMAL(18,2),
            c.[Avg Monthly GB Download]
        ),
        c.[Online Security],
        c.[Online Backup],
        c.[Device Protection Plan],
        c.[Premium Tech Support],
        c.[Streaming TV],
        c.[Streaming Movies],
        c.[Streaming Music],
        c.[Unlimited Data],
        c.[Contract],
        c.[Paperless Billing],
        c.[Payment Method],
        CONVERT(DECIMAL(18,2), c.[Monthly Charge]),
        CONVERT(DECIMAL(18,2), c.[Total Charges]),
        CONVERT(DECIMAL(18,2), c.[Total Refunds]),
        CONVERT(
            DECIMAL(18,2),
            c.[Total Extra Data Charges]
        ),
        CONVERT(
            DECIMAL(18,2),
            c.[Total Long Distance Charges]
        ),
        CONVERT(DECIMAL(18,2), c.[Total Revenue]),
        c.[Customer Status],
        c.[Churn Category],
        c.[Churn Reason]

    FROM stg.CustomerChurn AS c;


    -- ========================================================================
    -- 03. LOAD CORE ZIP CODE POPULATION
    -- ========================================================================

    INSERT INTO core.ZipCodePopulation
    (
        zip_code,
        population
    )

    SELECT
        z.[Zip Code],
        CONVERT(INT, z.[Population])

    FROM stg.ZipCodePopulation AS z;


    -- ========================================================================
    -- 04. VALIDATE LOADED ROW COUNTS
    -- ========================================================================

    IF (SELECT COUNT_BIG(*) FROM core.CustomerChurn) <> 7043
    BEGIN
        THROW 51004,
            'CustomerChurn row count validation failed.',
            1;
    END;

    IF (SELECT COUNT_BIG(*) FROM core.ZipCodePopulation) <> 1671
    BEGIN
        THROW 51005,
            'ZipCodePopulation row count validation failed.',
            1;
    END;


    -- ========================================================================
    -- 05. COMMIT TRANSACTION
    -- ========================================================================

    COMMIT TRANSACTION;

    PRINT 'Core data loaded successfully.';


END TRY

BEGIN CATCH

    -- Roll back the complete load if any statement fails.

    IF XACT_STATE() <> 0
    BEGIN
        ROLLBACK TRANSACTION;
    END;

    PRINT 'Core data load failed. Transaction rolled back.';

    THROW;

END CATCH;
GO


-- ============================================================================
-- 06. VERIFY FINAL RECORD COUNTS
-- ============================================================================

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

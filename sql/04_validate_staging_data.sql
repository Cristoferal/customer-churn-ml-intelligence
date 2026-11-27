USE CustomerChurnDB;
GO

/* ============================================================================
   PROJECT : Customer Churn Prediction & Retention Intelligence System
   FILE    : 04_validate_staging_data.sql
   PURPOSE : Validate staging counts, identifiers, categories and relationships.

   SOURCES : stg.CustomerChurn
             stg.ZipCodePopulation
             stg.DataDictionary

   CONTENTS:
      01. Staging Record Count Validation
      02. Customer Identifier Integrity
          02.1. Customer ID Counts and Missing Values
          02.2. Duplicate Customer IDs
      03. Customer Status, Offer and Churn Reason Validation
      04. ZIP Code Referential Integrity
          04.1. ZIP Code Reference Integrity
          04.2. Duplicate ZIP Codes
          04.3. Customers Without a ZIP Code Match
      05. Structural Missingness Validation
      06. ZIP Code Usage Analysis
          06.1. Customer ZIP Code Coverage
          06.2. Most Common Customer ZIP Codes
          06.3. Unused Reference ZIP Codes

   NOTE    : Read-only validation. No staging data is modified.
             Record-count checks do not replace row-level CSV comparison.
   ============================================================================ */


-- ============================================================================
-- 01. STAGING RECORD COUNT VALIDATION
-- ============================================================================
-- Purpose : Compare SQL table counts with expected source record counts.
-- Expected: CustomerChurn = 7043; ZipCodePopulation = 1671;
--           DataDictionary = 40.
-- ============================================================================

SELECT
    N'CustomerChurn' AS TableName,
    COUNT_BIG(*) AS TotalRecords,
    7043 AS ExpectedRecords
FROM stg.CustomerChurn

UNION ALL

SELECT
    N'ZipCodePopulation',
    COUNT_BIG(*),
    1671
FROM stg.ZipCodePopulation

UNION ALL

SELECT
    N'DataDictionary',
    COUNT_BIG(*),
    40
FROM stg.DataDictionary;
GO


-- ============================================================================
-- 02. CUSTOMER IDENTIFIER INTEGRITY
-- ============================================================================
-- Purpose : Detect missing and duplicate customer IDs.
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 02.1. CUSTOMER ID COUNTS AND MISSING VALUES
-- ----------------------------------------------------------------------------
-- Output  : One summary row for customer count, unique IDs and missing IDs.
-- ----------------------------------------------------------------------------

SELECT
    COUNT_BIG(*) AS TotalCustomers,
    COUNT(DISTINCT [Customer ID]) AS UniqueCustomers,
    SUM(
        CASE
            WHEN [Customer ID] IS NULL
              OR LTRIM(RTRIM([Customer ID])) = ''
            THEN 1 ELSE 0
        END
    ) AS MissingCustomerIDs
FROM stg.CustomerChurn;
GO


-- ----------------------------------------------------------------------------
-- 02.2. DUPLICATE CUSTOMER IDS
-- ----------------------------------------------------------------------------
-- Output  : No rows when customer IDs are unique.
-- ----------------------------------------------------------------------------

SELECT
    [Customer ID],
    COUNT_BIG(*) AS DuplicateCount
FROM stg.CustomerChurn
GROUP BY
    [Customer ID]
HAVING COUNT_BIG(*) > 1
ORDER BY
    DuplicateCount DESC;
GO


-- ============================================================================
-- 03. CUSTOMER STATUS, OFFER AND CHURN REASON VALIDATION
-- ============================================================================
-- Purpose : Validate category counts and churn-reason availability.
-- Note    : 'None' is a valid Offer value; it is not SQL NULL.
-- Expected: Churn Reason populated only for customers marked Churned.
-- ============================================================================

SELECT
    [Customer Status],
    COUNT_BIG(*) AS TotalCustomers,
    SUM(
        CASE
            WHEN [Offer] = N'None' THEN 1 ELSE 0
        END
    ) AS NoAcceptedOffer,
    SUM(
        CASE
            WHEN [Offer] IS NULL THEN 1 ELSE 0
        END
    ) AS MissingOffer,
    SUM(
        CASE
            WHEN [Churn Reason] IS NOT NULL THEN 1 ELSE 0
        END
    ) AS CustomersWithChurnReason
FROM stg.CustomerChurn
GROUP BY
    [Customer Status]
ORDER BY
    [Customer Status];
GO


-- ============================================================================
-- 04. ZIP CODE REFERENTIAL INTEGRITY
-- ============================================================================
-- Purpose : Check ZIP codes and their relationship to customer records.
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 04.1. ZIP CODE REFERENCE INTEGRITY
-- ----------------------------------------------------------------------------
-- Output  : Reference row count, distinct ZIP codes and missing ZIP codes.
-- ----------------------------------------------------------------------------

SELECT
    COUNT_BIG(*) AS TotalZipRecords,
    COUNT(
        DISTINCT NULLIF(LTRIM(RTRIM([Zip Code])), '')
    ) AS UniqueZipCodes,
    SUM(
        CASE
            WHEN [Zip Code] IS NULL
              OR LTRIM(RTRIM([Zip Code])) = ''
            THEN 1 ELSE 0
        END
    ) AS MissingZipCodes
FROM stg.ZipCodePopulation;
GO


-- ----------------------------------------------------------------------------
-- 04.2. DUPLICATE ZIP CODES
-- ----------------------------------------------------------------------------
-- Output  : No rows when the existing ZIP code duplicate check passes.
-- Note    : Groups by both trimmed and original ZIP code, matching the
--           previously validated query behavior.
-- ----------------------------------------------------------------------------

SELECT
    [Zip Code],
    COUNT_BIG(*) AS DuplicateCount
FROM stg.ZipCodePopulation
GROUP BY
    LTRIM(RTRIM([Zip Code])),
    [Zip Code]
HAVING COUNT_BIG(*) > 1
ORDER BY
    DuplicateCount DESC;
GO


-- ----------------------------------------------------------------------------
-- 04.3. CUSTOMERS WITHOUT A ZIP CODE MATCH
-- ----------------------------------------------------------------------------
-- Expected: 0 customers without a matching ZIP code reference.
-- ----------------------------------------------------------------------------

SELECT
    COUNT_BIG(*) AS CustomersWithoutZipMatch
FROM stg.CustomerChurn AS c
WHERE NOT EXISTS
(
    SELECT 1
    FROM stg.ZipCodePopulation AS z
    WHERE LTRIM(RTRIM(z.[Zip Code]))
        = LTRIM(RTRIM(c.[Zip Code]))
);
GO


-- ============================================================================
-- 05. STRUCTURAL MISSINGNESS VALIDATION
-- ============================================================================
-- Purpose : Measure missing service-dependent values for customers with
--           and without internet or phone service.
-- ============================================================================

SELECT
    v.ServiceGroup,
    v.FieldName,
    SUM(
        CASE
            WHEN v.HasService = 'No'
             AND NULLIF(LTRIM(RTRIM(v.FieldValue)), '') IS NULL
            THEN 1 ELSE 0
        END
    ) AS Missing_NoService,
    SUM(
        CASE
            WHEN v.HasService = 'No'
             AND NULLIF(LTRIM(RTRIM(v.FieldValue)), '') IS NOT NULL
            THEN 1 ELSE 0
        END
    ) AS Present_NoService,
    SUM(
        CASE
            WHEN v.HasService = 'Yes'
             AND NULLIF(LTRIM(RTRIM(v.FieldValue)), '') IS NULL
            THEN 1 ELSE 0
        END
    ) AS Missing_WithService
FROM stg.CustomerChurn AS c
CROSS APPLY
(
    VALUES
        ('Internet', 'Internet Type',
            c.[Internet Service], c.[Internet Type]),
        ('Internet', 'Avg Monthly GB Download',
            c.[Internet Service], c.[Avg Monthly GB Download]),
        ('Internet', 'Online Security',
            c.[Internet Service], c.[Online Security]),
        ('Internet', 'Online Backup',
            c.[Internet Service], c.[Online Backup]),
        ('Internet', 'Device Protection Plan',
            c.[Internet Service], c.[Device Protection Plan]),
        ('Internet', 'Premium Tech Support',
            c.[Internet Service], c.[Premium Tech Support]),
        ('Internet', 'Streaming TV',
            c.[Internet Service], c.[Streaming TV]),
        ('Internet', 'Streaming Movies',
            c.[Internet Service], c.[Streaming Movies]),
        ('Internet', 'Streaming Music',
            c.[Internet Service], c.[Streaming Music]),
        ('Internet', 'Unlimited Data',
            c.[Internet Service], c.[Unlimited Data]),
        ('Phone', 'Multiple Lines',
            c.[Phone Service], c.[Multiple Lines]),
        ('Phone', 'Avg Monthly Long Distance Charges',
            c.[Phone Service], c.[Avg Monthly Long Distance Charges])
) AS v(ServiceGroup, FieldName, HasService, FieldValue)
GROUP BY
    v.ServiceGroup,
    v.FieldName
ORDER BY
    v.ServiceGroup,
    v.FieldName;
GO


-- ============================================================================
-- 06. ZIP CODE USAGE ANALYSIS
-- ============================================================================
-- Purpose : Analyze ZIP code usage across customer and reference tables.
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 06.1. CUSTOMER ZIP CODE COVERAGE
-- ----------------------------------------------------------------------------
-- Output  : Customer count and number of distinct customer ZIP codes.
-- ----------------------------------------------------------------------------

SELECT
    COUNT_BIG(*) AS TotalCustomers,
    COUNT(DISTINCT [Zip Code]) AS UniqueCustomerZipCodes
FROM stg.CustomerChurn;
GO


-- ----------------------------------------------------------------------------
-- 06.2. MOST COMMON CUSTOMER ZIP CODES
-- ----------------------------------------------------------------------------
-- Output  : Ten ZIP codes with the highest number of customers.
-- ----------------------------------------------------------------------------

SELECT TOP (10)
    [Zip Code],
    COUNT_BIG(*) AS TotalCustomers
FROM stg.CustomerChurn
GROUP BY
    [Zip Code]
ORDER BY
    TotalCustomers DESC,
    [Zip Code];
GO


-- ----------------------------------------------------------------------------
-- 06.3. UNUSED REFERENCE ZIP CODES
-- ----------------------------------------------------------------------------
-- Purpose : Count reference ZIP codes absent from customer records.
-- ----------------------------------------------------------------------------

SELECT
    COUNT_BIG(*) AS ZipCodesWithoutCustomers
FROM stg.ZipCodePopulation AS z
WHERE NOT EXISTS
(
    SELECT 1
    FROM stg.CustomerChurn AS c
    WHERE c.[Zip Code] = z.[Zip Code]
);
GO

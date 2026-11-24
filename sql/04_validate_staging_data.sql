
USE CustomerChurnDB;
GO

/* ============================================================
   PROJECT: Customer Churn Prediction & Retention Intelligence
   FILE: 04_validate_staging_data.sql

   PURPOSE:
   Validate data imported from Maven Analytics into SQL Server.

   VALIDATIONS:
   1. Staging table record counts
   2. Customer ID integrity and duplicates
   3. Customer Status, Offer, and Churn Reason

   SOURCE: Maven Analytics - Telecom Customer Churn
   ============================================================ */


/* ============================================================
   1. STAGING DATA VALIDATION
   Compare imported records with source files
   ============================================================ */

SELECT
    'CustomerChurn' AS TableName,
    COUNT_BIG(*) AS TotalRecords,
    7043 AS ExpectedRecords
FROM stg.CustomerChurn

UNION ALL

SELECT
    'ZipCodePopulation',
    COUNT_BIG(*),
    1671
FROM stg.ZipCodePopulation

UNION ALL

SELECT
    'DataDictionary',
    COUNT_BIG(*),
    40
FROM stg.DataDictionary;
GO


/* ============================================================
   2. CUSTOMER ID INTEGRITY VALIDATION
   Check unique, missing, and duplicate customer IDs
   ============================================================ */

-- 2.1 Total customers, unique IDs, and missing IDs

SELECT
    COUNT_BIG(*) AS TotalCustomers,

    COUNT(DISTINCT [Customer ID]) AS UniqueCustomers,

    SUM(
        CASE
            WHEN [Customer ID] IS NULL
              OR LTRIM(RTRIM([Customer ID])) = ''
            THEN 1
            ELSE 0
        END
    ) AS MissingCustomerIDs

FROM stg.CustomerChurn;
GO


-- 2.2 Identify duplicated customer IDs

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


/* ============================================================
   3. CUSTOMER STATUS AND OFFER VALIDATION

   Verify that categorical values were preserved during ETL.

   IMPORTANT:
   'None' is a valid Offer category, not a SQL NULL.

   Churn Reason must only be populated for churned customers.
   ============================================================ */

SELECT
    [Customer Status],

    -- Total customers per status
    COUNT_BIG(*) AS TotalCustomers,

    -- Customers without an accepted marketing offer
    SUM(
        CASE
            WHEN [Offer] = N'None'
            THEN 1
            ELSE 0
        END
    ) AS NoAcceptedOffer,

    -- Customers with a missing Offer value
    SUM(
        CASE
            WHEN [Offer] IS NULL
            THEN 1
            ELSE 0
        END
    ) AS MissingOffer,

    -- Customers with a recorded churn reason
    SUM(
        CASE
            WHEN [Churn Reason] IS NOT NULL
            THEN 1
            ELSE 0
        END
    ) AS CustomersWithChurnReason

FROM stg.CustomerChurn

GROUP BY
    [Customer Status]

ORDER BY
    [Customer Status];
GO




/* ============================================================
   4. ZIP CODE REFERENTIAL INTEGRITY VALIDATION

   PURPOSE:
   Verify that customer ZIP codes exist in the
   ZipCodePopulation reference table.
   ============================================================ */

-- 4.1 Validate ZIP code reference records

SELECT
    COUNT_BIG(*) AS TotalZipRecords,

    COUNT(
        DISTINCT NULLIF(
            LTRIM(RTRIM([Zip Code])), ''
        )
    ) AS UniqueZipCodes,

    SUM(
        CASE
            WHEN [Zip Code] IS NULL
              OR LTRIM(RTRIM([Zip Code])) = ''
            THEN 1
            ELSE 0
        END
    ) AS MissingZipCodes

FROM stg.ZipCodePopulation;
GO


-- 4.2 Identify duplicated ZIP codes

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


-- 4.3 Find customers without a matching ZIP code

SELECT
    COUNT_BIG(*) AS CustomersWithoutZipMatch

FROM stg.CustomerChurn c

WHERE NOT EXISTS
(
    SELECT 1
    FROM stg.ZipCodePopulation z
    WHERE LTRIM(RTRIM(z.[Zip Code]))
        = LTRIM(RTRIM(c.[Zip Code]))
);
GO



/* ============================================================
   5. STRUCTURAL MISSINGNESS VALIDATION

   PURPOSE:
   Verify missing internet and phone service data
   after importing CSV files into SQL Server.
   ============================================================ */

SELECT
    v.ServiceGroup,
    v.FieldName,

    SUM(
        CASE
            WHEN v.HasService = 'No'
             AND NULLIF(
                 LTRIM(RTRIM(v.FieldValue)), ''
             ) IS NULL
            THEN 1 ELSE 0
        END
    ) AS Missing_NoService,

    SUM(
        CASE
            WHEN v.HasService = 'No'
             AND NULLIF(
                 LTRIM(RTRIM(v.FieldValue)), ''
             ) IS NOT NULL
            THEN 1 ELSE 0
        END
    ) AS Present_NoService,

    SUM(
        CASE
            WHEN v.HasService = 'Yes'
             AND NULLIF(
                 LTRIM(RTRIM(v.FieldValue)), ''
             ) IS NULL
            THEN 1 ELSE 0
        END
    ) AS Missing_WithService

FROM stg.CustomerChurn AS c

CROSS APPLY (
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


/* ============================================================
   6. ZIP CODE USAGE ANALYSIS

   PURPOSE:
   Analyze the one-to-many relationship between
   customers and ZIP codes.
   ============================================================ */

-- 6.1 Count unique ZIP codes used by customers

SELECT
    COUNT_BIG(*) AS TotalCustomers,
    COUNT(DISTINCT [Zip Code]) AS UniqueCustomerZipCodes
FROM stg.CustomerChurn;
GO


-- 6.2 Find the ZIP codes with the most customers

SELECT TOP (10)
    [Zip Code],
    COUNT_BIG(*) AS TotalCustomers
FROM stg.CustomerChurn
GROUP BY [Zip Code]
ORDER BY TotalCustomers DESC, [Zip Code];
GO


-- 6.3 Find reference ZIP codes not used by any customer

SELECT
    COUNT_BIG(*) AS ZipCodesWithoutCustomers
FROM stg.ZipCodePopulation z
WHERE NOT EXISTS (
    SELECT 1
    FROM stg.CustomerChurn c
    WHERE c.[Zip Code] = z.[Zip Code]
);
GO

USE CustomerChurnDB;
GO

/* ============================================================================
   PROJECT : Customer Churn Prediction & Retention Intelligence System
   FILE    : 05_profile_numeric_fields.sql
   PURPOSE : Profile numeric fields before building the typed data layer.

   SOURCES : stg.CustomerChurn
             stg.ZipCodePopulation

   CONTENTS:
      01. Customer Numeric Field Profiling
      02. ZIP Code Population Profiling
      03. Negative Monthly Charge Analysis
          03.1. Distribution of Negative Monthly Charges
          03.2. Negative Charges by Customer Status and Services
          03.3. Sample Records with Negative Monthly Charges
      04. Integer Data Type Validation
      05. Decimal Precision Validation

   NOTE    : Read-only analysis. No staging data is modified.
   ============================================================================ */


-- ============================================================================
-- 01. CUSTOMER NUMERIC FIELD PROFILING
-- ============================================================================
-- Purpose : Check missing, invalid, and negative values in numeric fields.
-- Output  : One summary row for each of the 14 customer numeric fields.
-- ============================================================================

WITH NumericProfile AS
(
    SELECT
        v.FieldName,
        NULLIF(LTRIM(RTRIM(v.RawValue)), N'') AS RawValue
    FROM stg.CustomerChurn AS c
    CROSS APPLY
    (
        VALUES
            (N'Age',                               c.[Age]),
            (N'Number of Dependents',              c.[Number of Dependents]),
            (N'Latitude',                          c.[Latitude]),
            (N'Longitude',                         c.[Longitude]),
            (N'Number of Referrals',               c.[Number of Referrals]),
            (N'Tenure in Months',                  c.[Tenure in Months]),
            (N'Avg Monthly Long Distance Charges', c.[Avg Monthly Long Distance Charges]),
            (N'Avg Monthly GB Download',           c.[Avg Monthly GB Download]),
            (N'Monthly Charge',                    c.[Monthly Charge]),
            (N'Total Charges',                     c.[Total Charges]),
            (N'Total Refunds',                     c.[Total Refunds]),
            (N'Total Extra Data Charges',          c.[Total Extra Data Charges]),
            (N'Total Long Distance Charges',       c.[Total Long Distance Charges]),
            (N'Total Revenue',                     c.[Total Revenue])
    ) AS v(FieldName, RawValue)
)
SELECT
    FieldName,
    COUNT_BIG(*) AS TotalRecords,
    SUM(
        CASE WHEN RawValue IS NULL THEN 1 ELSE 0 END
    ) AS MissingValues,
    SUM(
        CASE
            WHEN RawValue IS NOT NULL
             AND TRY_CONVERT(DECIMAL(28,10), RawValue) IS NULL
            THEN 1 ELSE 0
        END
    ) AS InvalidNumericValues,
    SUM(
        CASE
            WHEN TRY_CONVERT(DECIMAL(28,10), RawValue) < 0
            THEN 1 ELSE 0
        END
    ) AS NegativeValues,
    MIN(TRY_CONVERT(DECIMAL(28,10), RawValue)) AS MinValue,
    MAX(TRY_CONVERT(DECIMAL(28,10), RawValue)) AS MaxValue
FROM NumericProfile
GROUP BY FieldName
ORDER BY FieldName;
GO


-- ============================================================================
-- 02. ZIP CODE POPULATION PROFILING
-- ============================================================================
-- Purpose : Validate completeness, numeric conversion, and population range.
-- Output  : A single summary row for the ZIP code reference table.
-- ============================================================================

SELECT
    COUNT_BIG(*) AS TotalRecords,
    SUM(
        CASE
            WHEN [Population] IS NULL
              OR LTRIM(RTRIM([Population])) = ''
            THEN 1 ELSE 0
        END
    ) AS MissingPopulation,
    SUM(
        CASE
            WHEN NULLIF(LTRIM(RTRIM([Population])), '') IS NOT NULL
             AND TRY_CONVERT(BIGINT, [Population]) IS NULL
            THEN 1 ELSE 0
        END
    ) AS InvalidPopulation,
    MIN(TRY_CONVERT(BIGINT, [Population])) AS MinPopulation,
    MAX(TRY_CONVERT(BIGINT, [Population])) AS MaxPopulation
FROM stg.ZipCodePopulation;
GO


-- ============================================================================
-- 03. NEGATIVE MONTHLY CHARGE ANALYSIS
-- ============================================================================
-- Purpose : Examine negative charges before defining transformation rules.
-- Note    : Negative values are investigated, not modified or discarded.
-- ============================================================================


-- ----------------------------------------------------------------------------
-- 03.1. DISTRIBUTION OF NEGATIVE MONTHLY CHARGES
-- ----------------------------------------------------------------------------
-- Purpose : Count customers for each distinct negative monthly charge.
-- ----------------------------------------------------------------------------

SELECT
    TRY_CONVERT(DECIMAL(18,2), [Monthly Charge]) AS MonthlyCharge,
    COUNT_BIG(*) AS TotalCustomers
FROM stg.CustomerChurn
WHERE TRY_CONVERT(DECIMAL(18,2), [Monthly Charge]) < 0
GROUP BY
    TRY_CONVERT(DECIMAL(18,2), [Monthly Charge])
ORDER BY
    TotalCustomers DESC,
    MonthlyCharge;
GO


-- ----------------------------------------------------------------------------
-- 03.2. NEGATIVE CHARGES BY CUSTOMER STATUS AND SERVICES
-- ----------------------------------------------------------------------------
-- Purpose : Identify status and service combinations with negative charges.
-- ----------------------------------------------------------------------------

SELECT
    [Customer Status],
    [Phone Service],
    [Internet Service],
    COUNT_BIG(*) AS TotalCustomers
FROM stg.CustomerChurn
WHERE TRY_CONVERT(DECIMAL(18,2), [Monthly Charge]) < 0
GROUP BY
    [Customer Status],
    [Phone Service],
    [Internet Service]
ORDER BY
    TotalCustomers DESC;
GO


-- ----------------------------------------------------------------------------
-- 03.3. SAMPLE RECORDS WITH NEGATIVE MONTHLY CHARGES
-- ----------------------------------------------------------------------------
-- Purpose : Review contracts, offers, tenure, charges, refunds, and revenue.
-- Note    : Customer identifiers are intentionally excluded from the output.
-- ----------------------------------------------------------------------------

SELECT TOP (15)
    [Customer Status],
    [Phone Service],
    [Internet Service],
    [Contract],
    [Offer],
    [Tenure in Months],
    [Monthly Charge],
    [Total Charges],
    [Total Refunds],
    [Total Revenue]
FROM stg.CustomerChurn
WHERE TRY_CONVERT(DECIMAL(18,2), [Monthly Charge]) < 0
ORDER BY
    TRY_CONVERT(DECIMAL(18,2), [Monthly Charge]);
GO


-- ============================================================================
-- 04. INTEGER DATA TYPE VALIDATION
-- ============================================================================
-- Purpose : Check INT compatibility, fractional values, and numeric ranges.
-- Sources : Customer numeric fields and ZIP code population.
-- Output  : Five rows, one per candidate integer field.
-- ============================================================================

WITH IntegerFields AS
(
    SELECT
        v.FieldName,
        NULLIF(LTRIM(RTRIM(v.RawValue)), N'') AS RawValue
    FROM stg.CustomerChurn AS c
    CROSS APPLY
    (
        VALUES
            (N'Age',                  c.[Age]),
            (N'Number of Dependents', c.[Number of Dependents]),
            (N'Number of Referrals',  c.[Number of Referrals]),
            (N'Tenure in Months',     c.[Tenure in Months])
    ) AS v(FieldName, RawValue)

    UNION ALL

    SELECT
        N'Population' AS FieldName,
        NULLIF(LTRIM(RTRIM([Population])), N'') AS RawValue
    FROM stg.ZipCodePopulation
)
SELECT
    FieldName,
    COUNT_BIG(*) AS TotalRecords,
    SUM(
        CASE WHEN RawValue IS NULL THEN 1 ELSE 0 END
    ) AS MissingValues,
    SUM(
        CASE
            WHEN RawValue IS NOT NULL
             AND TRY_CONVERT(INT, RawValue) IS NULL
            THEN 1 ELSE 0
        END
    ) AS InvalidIntegerValues,
    SUM(
        CASE
            WHEN TRY_CONVERT(DECIMAL(28,10), RawValue)
                 <> FLOOR(TRY_CONVERT(DECIMAL(28,10), RawValue))
            THEN 1 ELSE 0
        END
    ) AS FractionalValues,
    MIN(TRY_CONVERT(INT, RawValue)) AS MinValue,
    MAX(TRY_CONVERT(INT, RawValue)) AS MaxValue
FROM IntegerFields
GROUP BY FieldName
ORDER BY FieldName;
GO


-- ============================================================================
-- 05. DECIMAL PRECISION VALIDATION
-- ============================================================================
-- Purpose : Verify the proposed decimal scale for each numeric field.
-- Scale   : 6 decimal places for coordinates; 2 for charges and usage.
-- Output  : Ten rows, one per candidate decimal field.
-- ============================================================================

WITH DecimalFields AS
(
    SELECT
        v.FieldName,
        v.ExpectedScale,
        TRY_CONVERT(
            DECIMAL(28,10),
            NULLIF(LTRIM(RTRIM(v.RawValue)), '')
        ) AS NumericValue,
        NULLIF(LTRIM(RTRIM(v.RawValue)), '') AS RawValue
    FROM stg.CustomerChurn AS c
    CROSS APPLY
    (
        VALUES
            (N'Latitude',                          6, c.[Latitude]),
            (N'Longitude',                         6, c.[Longitude]),
            (N'Avg Monthly Long Distance Charges', 2, c.[Avg Monthly Long Distance Charges]),
            (N'Avg Monthly GB Download',           2, c.[Avg Monthly GB Download]),
            (N'Monthly Charge',                    2, c.[Monthly Charge]),
            (N'Total Charges',                     2, c.[Total Charges]),
            (N'Total Refunds',                     2, c.[Total Refunds]),
            (N'Total Extra Data Charges',          2, c.[Total Extra Data Charges]),
            (N'Total Long Distance Charges',       2, c.[Total Long Distance Charges]),
            (N'Total Revenue',                     2, c.[Total Revenue])
    ) AS v(FieldName, ExpectedScale, RawValue)
)
SELECT
    FieldName,
    ExpectedScale,
    COUNT_BIG(*) AS TotalRecords,
    SUM(
        CASE WHEN RawValue IS NULL THEN 1 ELSE 0 END
    ) AS MissingValues,
    SUM(
        CASE
            WHEN NumericValue IS NOT NULL
             AND NumericValue <> ROUND(NumericValue, ExpectedScale)
            THEN 1 ELSE 0
        END
    ) AS ExcessDecimalPlaces,
    SUM(
        CASE
            WHEN RawValue IS NOT NULL
             AND
             (
                 NumericValue IS NULL
                 OR
                 (
                     ExpectedScale = 2
                     AND TRY_CONVERT(DECIMAL(18,2), RawValue) IS NULL
                 )
                 OR
                 (
                     ExpectedScale = 6
                     AND TRY_CONVERT(DECIMAL(18,6), RawValue) IS NULL
                 )
             )
            THEN 1 ELSE 0
        END
    ) AS ConversionProblems
FROM DecimalFields
GROUP BY
    FieldName,
    ExpectedScale
ORDER BY FieldName;
GO

USE CustomerChurnDB;
GO

/* ============================================================================
   PROJECT : Customer Churn Prediction & Retention Intelligence System
   FILE    : 02_create_schemas.sql
   PURPOSE : Create schemas for the project's data processing layers.

   CONTENTS:
      01. Create Staging Schema
      02. Create Core Schema
      03. Create Machine Learning Schema
      04. Create Reporting Schema
      05. Verify Project Schemas

   NOTE    : Safe to rerun. Existing schemas are not recreated.
             The core schema is also guarded in 06_create_core_tables.sql.
   ============================================================================ */


-- ============================================================================
-- 01. CREATE STAGING SCHEMA
-- ============================================================================
-- Purpose : Store source data imported without business transformations.
-- ============================================================================

IF SCHEMA_ID(N'stg') IS NULL
BEGIN
    EXEC(N'CREATE SCHEMA stg');
END;
GO


-- ============================================================================
-- 02. CREATE CORE SCHEMA
-- ============================================================================
-- Purpose : Store typed and validated data derived from staging.
-- ============================================================================

IF SCHEMA_ID(N'core') IS NULL
BEGIN
    EXEC(N'CREATE SCHEMA core');
END;
GO


-- ============================================================================
-- 03. CREATE MACHINE LEARNING SCHEMA
-- ============================================================================
-- Purpose : Store ML-specific features and model outputs.
-- ============================================================================

IF SCHEMA_ID(N'ml') IS NULL
BEGIN
    EXEC(N'CREATE SCHEMA ml');
END;
GO


-- ============================================================================
-- 04. CREATE REPORTING SCHEMA
-- ============================================================================
-- Purpose : Store reporting objects for analytical consumption.
-- ============================================================================

IF SCHEMA_ID(N'reporting') IS NULL
BEGIN
    EXEC(N'CREATE SCHEMA reporting');
END;
GO


-- ============================================================================
-- 05. VERIFY PROJECT SCHEMAS
-- ============================================================================
-- Purpose : List the four expected project schemas.
-- Output  : stg, core, ml, reporting (sorted alphabetically).
-- ============================================================================

SELECT
    name AS SchemaName
FROM sys.schemas
WHERE name IN (N'stg', N'core', N'ml', N'reporting')
ORDER BY name;
GO

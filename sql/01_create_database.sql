USE master;
GO

/* ============================================================================
   PROJECT : Customer Churn Prediction & Retention Intelligence System
   FILE    : 01_create_database.sql
   PURPOSE : Create the project database if it does not already exist.

   CONTENTS:
      01. Create Project Database
      02. Verify Database Context and Table Count

   NOTE    : Safe to rerun. An existing database is not recreated.
   ============================================================================ */


-- ============================================================================
-- 01. CREATE PROJECT DATABASE
-- ============================================================================
-- Purpose : Initialize CustomerChurnDB without replacing an existing database.
-- ============================================================================

IF DB_ID(N'CustomerChurnDB') IS NULL
BEGIN
    CREATE DATABASE CustomerChurnDB;
END;
GO


-- ============================================================================
-- 02. VERIFY DATABASE CONTEXT AND TABLE COUNT
-- ============================================================================
-- Purpose : Confirm the active database and report its current table count.
-- Output  : One row with CurrentDatabase and TotalTables.
-- ============================================================================

USE CustomerChurnDB;
GO

SELECT
    DB_NAME() AS CurrentDatabase,
    COUNT(*) AS TotalTables
FROM sys.tables;
GO

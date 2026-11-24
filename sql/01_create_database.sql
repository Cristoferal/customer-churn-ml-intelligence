
USE master;
GO

-- Create the database only if it does not exist
IF DB_ID(N'CustomerChurnDB') IS NULL
BEGIN
    CREATE DATABASE CustomerChurnDB;
END;
GO

-- Switch to the project database
USE CustomerChurnDB;
GO

-- Verify the database
SELECT
    DB_NAME() AS CurrentDatabase,
    COUNT(*) AS TotalTables
FROM sys.tables;
GO

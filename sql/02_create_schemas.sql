
USE CustomerChurnDB;
GO

-- Staging schema: raw imported data
IF SCHEMA_ID('stg') IS NULL
    EXEC('CREATE SCHEMA stg');
GO

-- Machine Learning schema
IF SCHEMA_ID('ml') IS NULL
    EXEC('CREATE SCHEMA ml');
GO

-- Reporting schema
IF SCHEMA_ID('reporting') IS NULL
    EXEC('CREATE SCHEMA reporting');
GO

-- Verify schemas
SELECT
    name AS SchemaName
FROM sys.schemas
WHERE name IN ('stg', 'ml', 'reporting')
ORDER BY name;
GO

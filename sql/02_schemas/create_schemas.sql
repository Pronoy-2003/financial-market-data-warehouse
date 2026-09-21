/*
    File: create_schemas.sql

    Purpose:
    Creates the Bronze, Silver, and Gold schemas used to organize
    the different layers of the data warehouse.
*/


-- Create Bronze schema
USE FinancialMarketWarehouse;
GO

CREATE SCHEMA bronze;
GO

-- Verify Bronze schema
SELECT name
FROM sys.schemas
WHERE name = 'bronze';

-- Create Silver schema
CREATE SCHEMA silver;
GO

-- Verify Silver schema
SELECT name
FROM sys.schemas
WHERE name = 'silver';

-- Create Gold schema
CREATE SCHEMA gold;
GO

-- Verify Gold schema
SELECT name
FROM sys.schemas
WHERE name = 'gold';

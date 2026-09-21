/*
    File: create_database.sql

    Purpose:
    Creates the FinancialMarketWarehouse database used by the
    financial market data warehouse project.
*/

-- Create the database
CREATE DATABASE FinancialMarketWarehouse;
GO

-- Select the database
USE FinancialMarketWarehouse;
GO

-- Verify the database
SELECT DB_NAME() AS CurrentDatabase;

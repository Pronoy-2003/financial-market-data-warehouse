/*
    File: load_all.sql

    Purpose:
    Creates the master Gold-layer loading procedure that executes
    all Gold dimension and fact loading procedures in sequence.
*/


-- Master Gold Loader
CREATE OR ALTER PROCEDURE gold.usp_load_all
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

        PRINT 'Starting Gold layer load...';

        PRINT 'Loading Company Dimension...';

        EXEC gold.usp_load_dim_company;


        PRINT 'Loading Market Dimension...';

        EXEC gold.usp_load_dim_market;


        PRINT 'Loading Date Dimension...';

        EXEC gold.usp_load_dim_date;


        PRINT 'Loading Stock Price Fact...';

        EXEC gold.usp_load_fact_stock_price;


        PRINT 'Gold layer load completed successfully.';

    END TRY

    BEGIN CATCH

        PRINT 'Gold layer load failed.';

        THROW;

    END CATCH;

END;
GO


-- Executing Master Gold Loader
EXEC gold.usp_load_all;

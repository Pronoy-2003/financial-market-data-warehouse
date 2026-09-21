/*
    File: data_quality_checks.sql

    Purpose:
    Creates the warehouse data-quality validation procedure that
    checks record counts, duplicates, key integrity, financial-data
    validity, and NULL measures.
*/


-- Create Final Data Quality Procedure
CREATE OR ALTER PROCEDURE gold.usp_run_data_quality_checks
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Results TABLE
    (
        check_id INT,
        check_name VARCHAR(100),
        actual_value BIGINT,
        expected_value BIGINT NULL,
        failed_rows BIGINT,
        status VARCHAR(10)
    );

    ------------------------------------------------------------
    -- 1. BRONZE RECORD COUNT
    ------------------------------------------------------------
    DECLARE @BronzeCount BIGINT;

    SELECT @BronzeCount = COUNT(*)
    FROM bronze.stock_price_raw;

    INSERT INTO @Results
    SELECT
        1,
        'Bronze Record Count',
        @BronzeCount,
        NULL,
        0,
        'PASS';


    ------------------------------------------------------------
    -- 2. SILVER RECORD COUNT
    ------------------------------------------------------------
    DECLARE @SilverCount BIGINT;

    SELECT @SilverCount = COUNT(*)
    FROM silver.stock_price;

    INSERT INTO @Results
    SELECT
        2,
        'Silver Record Count',
        @SilverCount,
        NULL,
        0,
        'PASS';


    ------------------------------------------------------------
    -- 3. GOLD FACT RECORD COUNT
    ------------------------------------------------------------
    DECLARE @GoldFactCount BIGINT;

    SELECT @GoldFactCount = COUNT(*)
    FROM gold.fact_stock_price;

    INSERT INTO @Results
    SELECT
        3,
        'Gold Fact Record Count',
        @GoldFactCount,
        NULL,
        0,
        'PASS';


    ------------------------------------------------------------
    -- 4. COMPANY DIMENSION COUNT
    ------------------------------------------------------------
    DECLARE @CompanyCount BIGINT;

    SELECT @CompanyCount = COUNT(*)
    FROM gold.dim_company;

    INSERT INTO @Results
    SELECT
        4,
        'Company Dimension Count',
        @CompanyCount,
        NULL,
        0,
        'PASS';


    ------------------------------------------------------------
    -- 5. MARKET DIMENSION COUNT
    ------------------------------------------------------------
    DECLARE @MarketCount BIGINT;

    SELECT @MarketCount = COUNT(*)
    FROM gold.dim_market;

    INSERT INTO @Results
    SELECT
        5,
        'Market Dimension Count',
        @MarketCount,
        NULL,
        0,
        'PASS';


    ------------------------------------------------------------
    -- 6. DATE DIMENSION COUNT
    ------------------------------------------------------------
    DECLARE @DateCount BIGINT;

    SELECT @DateCount = COUNT(*)
    FROM gold.dim_date;

    INSERT INTO @Results
    SELECT
        6,
        'Date Dimension Count',
        @DateCount,
        NULL,
        0,
        'PASS';


    ------------------------------------------------------------
    -- 7. DUPLICATE GOLD FACT RECORDS
    ------------------------------------------------------------
    DECLARE @DuplicateFacts BIGINT;

    SELECT @DuplicateFacts =
        ISNULL(SUM(duplicate_count), 0)
    FROM
    (
        SELECT COUNT(*) - 1 AS duplicate_count
        FROM gold.fact_stock_price
        GROUP BY
            company_key,
            market_key,
            date_key
        HAVING COUNT(*) > 1
    ) d;

    INSERT INTO @Results
    SELECT
        7,
        'Duplicate Gold Fact Records',
        @DuplicateFacts,
        0,
        @DuplicateFacts,
        CASE
            WHEN @DuplicateFacts = 0 THEN 'PASS'
            ELSE 'FAIL'
        END;


    ------------------------------------------------------------
    -- 8. NULL COMPANY KEYS
    ------------------------------------------------------------
    DECLARE @NullCompanyKeys BIGINT;

    SELECT @NullCompanyKeys = COUNT(*)
    FROM gold.fact_stock_price
    WHERE company_key IS NULL;

    INSERT INTO @Results
    SELECT
        8,
        'NULL Company Keys',
        @NullCompanyKeys,
        0,
        @NullCompanyKeys,
        CASE
            WHEN @NullCompanyKeys = 0 THEN 'PASS'
            ELSE 'FAIL'
        END;


    ------------------------------------------------------------
    -- 9. NULL MARKET KEYS
    ------------------------------------------------------------
    DECLARE @NullMarketKeys BIGINT;

    SELECT @NullMarketKeys = COUNT(*)
    FROM gold.fact_stock_price
    WHERE market_key IS NULL;

    INSERT INTO @Results
    SELECT
        9,
        'NULL Market Keys',
        @NullMarketKeys,
        0,
        @NullMarketKeys,
        CASE
            WHEN @NullMarketKeys = 0 THEN 'PASS'
            ELSE 'FAIL'
        END;


    ------------------------------------------------------------
    -- 10. NULL DATE KEYS
    ------------------------------------------------------------
    DECLARE @NullDateKeys BIGINT;

    SELECT @NullDateKeys = COUNT(*)
    FROM gold.fact_stock_price
    WHERE date_key IS NULL;

    INSERT INTO @Results
    SELECT
        10,
        'NULL Date Keys',
        @NullDateKeys,
        0,
        @NullDateKeys,
        CASE
            WHEN @NullDateKeys = 0 THEN 'PASS'
            ELSE 'FAIL'
        END;


    ------------------------------------------------------------
    -- 11. ORPHAN COMPANY KEYS
    ------------------------------------------------------------
    DECLARE @OrphanCompanyKeys BIGINT;

    SELECT @OrphanCompanyKeys = COUNT(*)
    FROM gold.fact_stock_price f
    LEFT JOIN gold.dim_company c
        ON f.company_key = c.company_key
    WHERE c.company_key IS NULL;

    INSERT INTO @Results
    SELECT
        11,
        'Orphan Company Keys',
        @OrphanCompanyKeys,
        0,
        @OrphanCompanyKeys,
        CASE
            WHEN @OrphanCompanyKeys = 0 THEN 'PASS'
            ELSE 'FAIL'
        END;


    ------------------------------------------------------------
    -- 12. ORPHAN MARKET KEYS
    ------------------------------------------------------------
    DECLARE @OrphanMarketKeys BIGINT;

    SELECT @OrphanMarketKeys = COUNT(*)
    FROM gold.fact_stock_price f
    LEFT JOIN gold.dim_market m
        ON f.market_key = m.market_key
    WHERE m.market_key IS NULL;

    INSERT INTO @Results
    SELECT
        12,
        'Orphan Market Keys',
        @OrphanMarketKeys,
        0,
        @OrphanMarketKeys,
        CASE
            WHEN @OrphanMarketKeys = 0 THEN 'PASS'
            ELSE 'FAIL'
        END;


    ------------------------------------------------------------
    -- 13. ORPHAN DATE KEYS
    ------------------------------------------------------------
    DECLARE @OrphanDateKeys BIGINT;

    SELECT @OrphanDateKeys = COUNT(*)
    FROM gold.fact_stock_price f
    LEFT JOIN gold.dim_date d
        ON f.date_key = d.date_key
    WHERE d.date_key IS NULL;

    INSERT INTO @Results
    SELECT
        13,
        'Orphan Date Keys',
        @OrphanDateKeys,
        0,
        @OrphanDateKeys,
        CASE
            WHEN @OrphanDateKeys = 0 THEN 'PASS'
            ELSE 'FAIL'
        END;


    ------------------------------------------------------------
    -- 14. INVALID OHLC RECORDS
    ------------------------------------------------------------
    DECLARE @InvalidOHLC BIGINT;

    SELECT @InvalidOHLC = COUNT(*)
    FROM gold.fact_stock_price
    WHERE
        open_price <= 0
        OR high_price <= 0
        OR low_price <= 0
        OR close_price <= 0
        OR high_price < low_price
        OR high_price < open_price
        OR high_price < close_price
        OR low_price > open_price
        OR low_price > close_price;

    INSERT INTO @Results
    SELECT
        14,
        'Invalid OHLC Records',
        @InvalidOHLC,
        0,
        @InvalidOHLC,
        CASE
            WHEN @InvalidOHLC = 0 THEN 'PASS'
            ELSE 'FAIL'
        END;


    ------------------------------------------------------------
    -- 15. INVALID VOLUME
    ------------------------------------------------------------
    DECLARE @InvalidVolume BIGINT;

    SELECT @InvalidVolume = COUNT(*)
    FROM gold.fact_stock_price
    WHERE volume < 0;

    INSERT INTO @Results
    SELECT
        15,
        'Invalid Volume Records',
        @InvalidVolume,
        0,
        @InvalidVolume,
        CASE
            WHEN @InvalidVolume = 0 THEN 'PASS'
            ELSE 'FAIL'
        END;


    ------------------------------------------------------------
    -- 16. NULL PRICE/VOLUME VALUES
    ------------------------------------------------------------
    DECLARE @NullMeasures BIGINT;

    SELECT @NullMeasures = COUNT(*)
    FROM gold.fact_stock_price
    WHERE
        open_price IS NULL
        OR high_price IS NULL
        OR low_price IS NULL
        OR close_price IS NULL
        OR volume IS NULL;

    INSERT INTO @Results
    SELECT
        16,
        'NULL Financial Measures',
        @NullMeasures,
        0,
        @NullMeasures,
        CASE
            WHEN @NullMeasures = 0 THEN 'PASS'
            ELSE 'FAIL'
        END;


    ------------------------------------------------------------
    -- RETURN RESULTS
    ------------------------------------------------------------
    SELECT
        check_id,
        check_name,
        actual_value,
        expected_value,
        failed_rows,
        status
    FROM @Results
    ORDER BY check_id;

END;
GO


-- Execute Final Data Quality Procedure
EXEC gold.usp_run_data_quality_checks;

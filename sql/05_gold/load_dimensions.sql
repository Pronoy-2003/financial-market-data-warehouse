/*
    File: load_dimensions.sql

    Purpose:
    Creates the Gold-layer procedures that populate the company,
    market, and date dimensions from Silver-layer data.
*/


-- Company Dimension loader
CREATE OR ALTER PROCEDURE gold.usp_load_dim_company
AS
BEGIN
    SET NOCOUNT ON;

    -- Insert new companies from Silver
    INSERT INTO gold.dim_company
    (
        symbol,
        company_name,
        sector,
        industry,
        exchange
    )
    SELECT DISTINCT
        s.symbol,
        s.symbol AS company_name,
        NULL AS sector,
        NULL AS industry,
        'NASDAQ' AS exchange
    FROM silver.stock_price s
    WHERE NOT EXISTS
    (
        SELECT 1
        FROM gold.dim_company c
        WHERE c.symbol = s.symbol
    );
END;
GO


-- Market Dimension Loader
CREATE OR ALTER PROCEDURE gold.usp_load_dim_market
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO gold.dim_market
    (
        exchange,
        market_name,
        country,
        currency,
        timezone
    )
    SELECT
        'NASDAQ',
        'NASDAQ Stock Market',
        'United States',
        'USD',
        'America/New_York'
    WHERE NOT EXISTS
    (
        SELECT 1
        FROM gold.dim_market
        WHERE exchange = 'NASDAQ'
    );

END;
GO


-- Date Dimension Loader
CREATE OR ALTER PROCEDURE gold.usp_load_dim_date
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MinDate DATE;
    DECLARE @MaxDate DATE;

    SELECT
        @MinDate = MIN(observation_date),
        @MaxDate = MAX(observation_date)
    FROM silver.stock_price;

    ;WITH DateRange AS
    (
        SELECT @MinDate AS full_date

        UNION ALL

        SELECT DATEADD(DAY, 1, full_date)
        FROM DateRange
        WHERE full_date < @MaxDate
    )

    INSERT INTO gold.dim_date
    (
        date_key,
        full_date,
        year,
        quarter,
        month,
        month_name,
        day,
        day_of_week,
        day_name,
        is_weekend
    )
    SELECT
        CONVERT(INT, CONVERT(VARCHAR(8), full_date, 112)) AS date_key,

        full_date,

        YEAR(full_date) AS year,

        DATEPART(QUARTER, full_date) AS quarter,

        MONTH(full_date) AS month,

        DATENAME(MONTH, full_date) AS month_name,

        DAY(full_date) AS day,

        DATEPART(WEEKDAY, full_date) AS day_of_week,

        DATENAME(WEEKDAY, full_date) AS day_name,

        CASE
            WHEN DATEPART(WEEKDAY, full_date) IN (1, 7)
            THEN 1
            ELSE 0
        END AS is_weekend

    FROM DateRange d

    WHERE NOT EXISTS
    (
        SELECT 1
        FROM gold.dim_date x
        WHERE x.full_date = d.full_date
    )

    OPTION (MAXRECURSION 1000);

END;
GO

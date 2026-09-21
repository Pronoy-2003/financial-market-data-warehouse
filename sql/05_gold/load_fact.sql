/*
    File: load_fact.sql

    Purpose:
    Creates the Gold-layer fact loading procedure that loads
    stock-price measures and connects them to the dimension keys.
*/


-- Fact Table Loader
CREATE OR ALTER PROCEDURE gold.usp_load_fact_stock_price
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO gold.fact_stock_price
    (
        company_key,
        market_key,
        date_key,
        open_price,
        high_price,
        low_price,
        close_price,
        volume,
        daily_return
    )
    SELECT
        c.company_key,

        m.market_key,

        d.date_key,

        s.open_price,

        s.high_price,

        s.low_price,

        s.close_price,

        s.volume,

        s.daily_return

    FROM silver.stock_price s

    INNER JOIN gold.dim_company c
        ON s.symbol = c.symbol

    INNER JOIN gold.dim_market m
        ON m.exchange = 'NASDAQ'

    INNER JOIN gold.dim_date d
        ON s.observation_date = d.full_date

    WHERE NOT EXISTS
    (
        SELECT 1
        FROM gold.fact_stock_price f
        WHERE
            f.company_key = c.company_key
            AND f.market_key = m.market_key
            AND f.date_key = d.date_key
    );

END;
GO

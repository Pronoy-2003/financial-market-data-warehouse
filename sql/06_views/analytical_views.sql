/*
    File: analytical_views.sql

    Purpose:
    Creates business-ready analytical views for daily stock,
    company, and market performance analysis from the Gold layer.
*/


-- Create vw_stock_daily_performance view
CREATE OR ALTER VIEW gold.vw_stock_daily_performance
AS
SELECT
    c.symbol,
    c.company_name,
    m.market_name,
    d.full_date,
    f.open_price,
    f.high_price,
    f.low_price,
    f.close_price,
    f.volume,
    f.daily_return
FROM gold.fact_stock_price AS f
INNER JOIN gold.dim_company AS c
    ON f.company_key = c.company_key
INNER JOIN gold.dim_market AS m
    ON f.market_key = m.market_key
INNER JOIN gold.dim_date AS d
    ON f.date_key = d.date_key;
GO


-- Create vw_company_performance view
CREATE OR ALTER VIEW gold.vw_company_performance
AS
SELECT
    c.symbol,
    c.company_name,
    COUNT(*) AS trading_days,
    MIN(d.full_date) AS first_trading_date,
    MAX(d.full_date) AS latest_trading_date,
    AVG(f.close_price) AS avg_close_price,
    MIN(f.close_price) AS min_close_price,
    MAX(f.close_price) AS max_close_price,
    SUM(f.volume) AS total_volume,
    AVG(f.daily_return) AS avg_daily_return
FROM gold.fact_stock_price AS f
INNER JOIN gold.dim_company AS c
    ON f.company_key = c.company_key
INNER JOIN gold.dim_date AS d
    ON f.date_key = d.date_key
GROUP BY
    c.symbol,
    c.company_name;
GO


-- Create vw_market_performance view
CREATE OR ALTER VIEW gold.vw_market_performance
AS
SELECT
    d.full_date,
    m.market_name,
    COUNT(DISTINCT f.company_key) AS stocks_traded,
    AVG(f.close_price) AS avg_close_price,
    AVG(f.daily_return) AS avg_daily_return,
    SUM(f.volume) AS total_volume
FROM gold.fact_stock_price AS f
INNER JOIN gold.dim_market AS m
    ON f.market_key = m.market_key
INNER JOIN gold.dim_date AS d
    ON f.date_key = d.date_key
GROUP BY
    d.full_date,
    m.market_name;
GO



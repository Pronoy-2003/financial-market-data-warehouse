/*
    File: create_fact.sql

    Purpose:
    Creates the Gold-layer stock-price fact table containing
    daily market measures linked to company, market, and date dimensions.
*/


-- Create gold.fact_stock_price table
CREATE TABLE gold.fact_stock_price
(
    stock_price_key BIGINT IDENTITY(1,1) NOT NULL,

    company_key INT NOT NULL,

    market_key INT NOT NULL,

    date_key INT NOT NULL,

    open_price DECIMAL(18,4) NOT NULL,

    high_price DECIMAL(18,4) NOT NULL,

    low_price DECIMAL(18,4) NOT NULL,

    close_price DECIMAL(18,4) NOT NULL,

    volume BIGINT NOT NULL,

    daily_return DECIMAL(18,6) NULL,

    CONSTRAINT PK_gold_fact_stock_price
        PRIMARY KEY (stock_price_key),

    CONSTRAINT UQ_gold_fact_stock_price
        UNIQUE (company_key, market_key, date_key),

    CONSTRAINT FK_fact_stock_price_company
        FOREIGN KEY (company_key)
        REFERENCES gold.dim_company(company_key),

    CONSTRAINT FK_fact_stock_price_market
        FOREIGN KEY (market_key)
        REFERENCES gold.dim_market(market_key),

    CONSTRAINT FK_fact_stock_price_date
        FOREIGN KEY (date_key)
        REFERENCES gold.dim_date(date_key)
);
GO

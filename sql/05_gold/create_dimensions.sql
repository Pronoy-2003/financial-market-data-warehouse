/*
    File: create_dimensions.sql

    Purpose:
    Creates the Gold-layer dimension tables for company, market,
    and date attributes used by the stock-price fact table.
*/


-- Create gold.dim_company table
CREATE TABLE gold.dim_company
(
    company_key INT IDENTITY(1,1) NOT NULL,

    symbol VARCHAR(20) NOT NULL,

    company_name VARCHAR(100) NOT NULL,

    sector VARCHAR(100) NULL,

    industry VARCHAR(150) NULL,

    exchange VARCHAR(50) NULL,

    CONSTRAINT PK_gold_dim_company
        PRIMARY KEY (company_key),

    CONSTRAINT UQ_gold_dim_company_symbol
        UNIQUE (symbol)
);
GO


-- Create gold.dim_date table
CREATE TABLE gold.dim_date
(
    date_key INT NOT NULL,

    full_date DATE NOT NULL,

    year INT NOT NULL,

    quarter INT NOT NULL,

    month INT NOT NULL,

    month_name VARCHAR(20) NOT NULL,

    day INT NOT NULL,

    day_of_week INT NOT NULL,

    day_name VARCHAR(20) NOT NULL,

    is_weekend BIT NOT NULL,

    CONSTRAINT PK_gold_dim_date
        PRIMARY KEY (date_key),

    CONSTRAINT UQ_gold_dim_date_full_date
        UNIQUE (full_date)
);
GO


-- Create gold.dim_market table
CREATE TABLE gold.dim_market
(
    market_key INT IDENTITY(1,1) NOT NULL,

    exchange VARCHAR(50) NOT NULL,

    market_name VARCHAR(100) NOT NULL,

    country VARCHAR(100) NOT NULL,

    currency VARCHAR(10) NOT NULL,

    timezone VARCHAR(50) NULL,

    CONSTRAINT PK_gold_dim_market
        PRIMARY KEY (market_key),

    CONSTRAINT UQ_gold_dim_market_exchange
        UNIQUE (exchange)
);
GO

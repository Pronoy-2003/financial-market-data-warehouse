/*
    File: create_tables.sql

    Purpose:
    Creates the Silver-layer stock-price table used to store
    cleaned and standardized market data for the Gold layer.
*/

-- Create silver.stock_price table
IF OBJECT_ID('silver.stock_price', 'U') IS NULL
BEGIN

    CREATE TABLE silver.stock_price
    (
        silver_id BIGINT IDENTITY(1,1) NOT NULL,

        symbol VARCHAR(20) NOT NULL,

        observation_date DATE NOT NULL,

        open_price DECIMAL(18,4) NOT NULL,

        high_price DECIMAL(18,4) NOT NULL,

        low_price DECIMAL(18,4) NOT NULL,

        close_price DECIMAL(18,4) NOT NULL,

        volume BIGINT NOT NULL,

        daily_return DECIMAL(18,6) NULL,

        source VARCHAR(100) NOT NULL,

        transformed_at DATETIME2 NOT NULL
            DEFAULT SYSDATETIME(),

        CONSTRAINT PK_silver_stock_price
            PRIMARY KEY (silver_id),

        CONSTRAINT UQ_silver_stock_price
            UNIQUE (symbol, observation_date)
    );

END;
GO

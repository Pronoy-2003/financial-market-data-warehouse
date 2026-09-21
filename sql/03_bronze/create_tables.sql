/*
    File: create_tables.sql

    Purpose:
    Creates the Bronze-layer table used to store raw market data
    received from the Alpha Vantage API before transformation.
*/


-- Create bronze.stock_price_raw table
IF OBJECT_ID('bronze.stock_price_raw', 'U') IS NULL
BEGIN
    CREATE TABLE bronze.stock_price_raw
    (
        bronze_id BIGINT IDENTITY(1,1) NOT NULL,
    
        ingestion_id UNIQUEIDENTIFIER NOT NULL,
    
        symbol VARCHAR(10) NOT NULL,
    
        observation_date DATE NOT NULL,
    
        open_price DECIMAL(18,4) NULL,
        high_price DECIMAL(18,4) NULL,
        low_price DECIMAL(18,4) NULL,
        close_price DECIMAL(18,4) NULL,
    
        volume BIGINT NULL,
    
        source VARCHAR(50) NOT NULL,
    
        loaded_at DATETIME2 NOT NULL
            DEFAULT SYSDATETIME(),
    
        CONSTRAINT PK_bronze_stock_price_raw
            PRIMARY KEY (bronze_id)
    );
END;
GO

-- Add a unique constraint
ALTER TABLE bronze.stock_price_raw
ADD CONSTRAINT UQ_bronze_stock_price
UNIQUE (symbol, observation_date);
GO

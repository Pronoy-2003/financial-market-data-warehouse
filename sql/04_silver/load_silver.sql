/*
    File: load_silver.sql

    Purpose:
    Creates the Silver-layer transformation procedure that cleans,
    standardizes, and loads stock-price data from Bronze into Silver.
*/


-- Create the Silver procedure
CREATE OR ALTER PROCEDURE silver.usp_load_stock_price
AS
BEGIN

    SET NOCOUNT ON;

    BEGIN TRY

        ;WITH ValidData AS
        (
            SELECT
                symbol,
                observation_date,
                open_price,
                high_price,
                low_price,
                close_price,
                volume,
                source
            FROM bronze.stock_price_raw
            WHERE
                symbol IS NOT NULL
                AND observation_date IS NOT NULL
                AND open_price > 0
                AND high_price > 0
                AND low_price > 0
                AND close_price > 0
                AND volume >= 0
                AND high_price >= low_price
                AND high_price >= open_price
                AND high_price >= close_price
                AND low_price <= open_price
                AND low_price <= close_price
        ),

        TransformedData AS
        (
            SELECT
                symbol,
                observation_date,
                open_price,
                high_price,
                low_price,
                close_price,
                volume,

                CAST(
                    (
                        (close_price -
                            LAG(close_price) OVER
                            (
                                PARTITION BY symbol
                                ORDER BY observation_date
                            )
                        )
                        /
                        NULLIF(
                            LAG(close_price) OVER
                            (
                                PARTITION BY symbol
                                ORDER BY observation_date
                            ),
                            0
                        )
                    ) * 100
                    AS DECIMAL(18,6)
                ) AS daily_return,

                source

            FROM ValidData
        )

        INSERT INTO silver.stock_price
        (
            symbol,
            observation_date,
            open_price,
            high_price,
            low_price,
            close_price,
            volume,
            daily_return,
            source,
            transformed_at
        )

        SELECT
            t.symbol,
            t.observation_date,
            t.open_price,
            t.high_price,
            t.low_price,
            t.close_price,
            t.volume,
            t.daily_return,
            t.source,
            SYSDATETIME()

        FROM TransformedData t

        WHERE NOT EXISTS
        (
            SELECT 1
            FROM silver.stock_price s
            WHERE
                s.symbol = t.symbol
                AND s.observation_date = t.observation_date
        );

    END TRY

    BEGIN CATCH

        THROW;

    END CATCH;

END;
GO


-- Execute the Silver transformation procedure
EXEC silver.usp_load_stock_price;

"""
File: bronze_loader.py

Purpose:
Manages Bronze-layer loading and pipeline ingestion logging.
Tracks pipeline status and loads only new stock-price records while
reporting inserted and skipped record counts.
"""


import uuid
from datetime import datetime

from database import get_sql_connection


def start_ingestion_log(ingestion_id):
    """
    Create a STARTED record in the ingestion log.
    """

    connection = get_sql_connection()
    cursor = connection.cursor()

    query = """
        INSERT INTO bronze.ingestion_log
        (
            ingestion_id,
            pipeline_name,
            start_time,
            status,
            records_received
        )
        VALUES (?, ?, ?, ?, ?)
    """

    cursor.execute(
        query,
        (
            ingestion_id,
            "financial_market_ingestion",
            datetime.now(),
            "STARTED",
            0
        )
    )

    connection.commit()

    cursor.close()
    connection.close()


def update_ingestion_log(
    ingestion_id,
    status,
    records_received,
    error_message=None
):
    """
    Update the ingestion log after pipeline completion.
    """

    connection = get_sql_connection()
    cursor = connection.cursor()

    query = """
        UPDATE bronze.ingestion_log
        SET
            end_time = ?,
            status = ?,
            records_received = ?,
            error_message = ?
        WHERE ingestion_id = ?
    """

    cursor.execute(
        query,
        (
            datetime.now(),
            status,
            records_received,
            error_message,
            ingestion_id
        )
    )

    connection.commit()

    cursor.close()
    connection.close()


def load_to_bronze(df, ingestion_id):
    """
    Load only new stock-price records into Bronze.

    Returns:
        inserted_count
        skipped_count
    """

    connection = get_sql_connection()
    cursor = connection.cursor()

    inserted_count = 0
    skipped_count = 0

    insert_query = """
        INSERT INTO bronze.stock_price_raw
        (
            ingestion_id,
            symbol,
            observation_date,
            open_price,
            high_price,
            low_price,
            close_price,
            volume,
            source
        )
        SELECT ?, ?, ?, ?, ?, ?, ?, ?, ?
        WHERE NOT EXISTS
        (
            SELECT 1
            FROM bronze.stock_price_raw
            WHERE symbol = ?
              AND observation_date = ?
        );
    """

    for _, row in df.iterrows():

        symbol = row["symbol"]
        observation_date = row["observation_date"].date()

        cursor.execute(
            insert_query,
            (
                ingestion_id,
                symbol,
                observation_date,
                float(row["open_price"]),
                float(row["high_price"]),
                float(row["low_price"]),
                float(row["close_price"]),
                int(row["volume"]),
                "Alpha Vantage",
                symbol,
                observation_date
            )
        )

        if cursor.rowcount == 1:
            inserted_count += 1
        else:
            skipped_count += 1

    connection.commit()

    cursor.close()
    connection.close()

    return inserted_count, skipped_count
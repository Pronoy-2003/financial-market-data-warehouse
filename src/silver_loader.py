"""
File: silver_loader.py

Purpose:
Executes the Silver-layer transformation stored procedure.
Handles transaction commit and rollback to ensure reliable
Silver-layer processing.
"""


from database import get_sql_connection


def load_to_silver():

    connection = get_sql_connection()

    try:

        cursor = connection.cursor()

        print("\nStarting Silver transformation...")

        cursor.execute(
            "EXEC silver.usp_load_stock_price;"
        )

        connection.commit()

        print("Silver transformation completed successfully.")

    except Exception as error:

        connection.rollback()

        print(f"Silver transformation failed: {error}")

        raise

    finally:

        connection.close()
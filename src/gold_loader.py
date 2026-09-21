"""
File: gold_loader.py

Purpose:
Executes the master Gold-layer loading procedure to populate the
company, market, date dimensions and stock-price fact table.
"""


from database import get_sql_connection


def load_to_gold():
    """
    Execute the master Gold layer loading procedure.

    The SQL procedure internally loads:
        1. Company Dimension
        2. Market Dimension
        3. Date Dimension
        4. Stock Price Fact
    """

    connection = get_sql_connection()

    try:
        cursor = connection.cursor()

        print("\nStarting Gold layer load...")

        # Execute master Gold procedure
        cursor.execute(
            "EXEC gold.usp_load_all;"
        )

        connection.commit()

        print("Gold layer load completed successfully.")

    except Exception as error:

        connection.rollback()

        print(f"Gold layer load failed: {error}")

        raise

    finally:
        connection.close()



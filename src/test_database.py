"""
File: test_database.py

Purpose:
Tests the SQL Server connection and verifies that the expected
FinancialMarketWarehouse database is accessible.
"""


from database import get_sql_connection


def main():

    connection = get_sql_connection()

    cursor = connection.cursor()

    cursor.execute(
        "SELECT DB_NAME() AS database_name"
    )

    result = cursor.fetchone()

    print("Successfully connected to SQL Server")
    print("Database:", result.database_name)

    cursor.close()
    connection.close()


if __name__ == "__main__":
    main()
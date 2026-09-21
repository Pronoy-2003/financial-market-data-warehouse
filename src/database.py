"""
File: database.py

Purpose:
Provides the SQL Server database connection used by the pipeline.
Loads connection settings from environment variables and creates
a pyodbc connection to the warehouse.
"""


import os

import pyodbc
from dotenv import load_dotenv


def get_sql_connection():
    """
    Create and return a connection to SQL Server.
    """

    load_dotenv()

    server = os.getenv("SQL_SERVER")
    database = os.getenv("SQL_DATABASE")
    driver = os.getenv("SQL_DRIVER")

    connection_string = (
        f"DRIVER={{{driver}}};"
        f"SERVER={server};"
        f"DATABASE={database};"
        "Trusted_Connection=yes;"
        "TrustServerCertificate=yes;"
    )

    return pyodbc.connect(connection_string)
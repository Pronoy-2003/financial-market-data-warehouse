"""
File: ingestion.py

Purpose:
Orchestrates market-data extraction for all configured stocks.
Retrieves data from Alpha Vantage, parses the responses, handles
individual request failures, and combines the results into one DataFrame.
"""


import json
import time
from pathlib import Path

import pandas as pd

from api_client import AlphaVantageClient
from data_parser import parse_daily_stock_data


def load_stock_config():
    """
    Load stock information from config/stocks.json.
    """

    config_path = Path("config/stocks.json")

    with open(config_path, "r", encoding="utf-8") as file:
        config = json.load(file)

    return config["stocks"]


def ingest_stock_data():
    """
    Retrieve daily stock data for all configured stocks
    and combine the results into a single DataFrame.
    """

    stocks = load_stock_config()

    client = AlphaVantageClient()

    all_data = []

    for stock in stocks:

        symbol = stock["symbol"]

        print(f"Fetching data for {symbol}...")

        try:
            # Get data from Alpha Vantage
            data = client.get_daily_stock_data(symbol)

            # Convert API response into DataFrame
            df = parse_daily_stock_data(data, symbol)

            all_data.append(df)

            print(
                f"Successfully retrieved {len(df)} records for {symbol}"
            )

        except Exception as error:

            print(f"Failed to retrieve data for {symbol}: {error}")

        # Small delay between API requests
        time.sleep(1)

    # Stop if no data was retrieved
    if not all_data:
        raise RuntimeError("No stock data was successfully retrieved.")

    # Combine all stock DataFrames
    combined_df = pd.concat(
        all_data,
        ignore_index=True
    )

    return combined_df
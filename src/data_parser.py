"""
File: data_parser.py

Purpose:
Transforms Alpha Vantage daily stock JSON responses into a structured
Pandas DataFrame with standardized data types and sorted observations.
"""


import pandas as pd


def parse_daily_stock_data(data, symbol):
    """
    Convert Alpha Vantage daily stock JSON
    into a clean Pandas DataFrame.
    """

    time_series = data["Time Series (Daily)"]

    records = []

    for date, values in time_series.items():

        record = {
            "symbol": symbol,
            "observation_date": date,
            "open_price": values["1. open"],
            "high_price": values["2. high"],
            "low_price": values["3. low"],
            "close_price": values["4. close"],
            "volume": values["5. volume"]
        }

        records.append(record)

    df = pd.DataFrame(records)

    # Convert data types
    df["observation_date"] = pd.to_datetime(
        df["observation_date"]
    )

    numeric_columns = [
        "open_price",
        "high_price",
        "low_price",
        "close_price",
        "volume"
    ]

    df[numeric_columns] = df[numeric_columns].apply(
        pd.to_numeric
    )

    # Sort by date
    df = df.sort_values(
        "observation_date",
        ascending=False
    ).reset_index(drop=True)

    return df
"""
File: api_client.py

Purpose:
Provides a reusable Alpha Vantage API client for retrieving daily
stock-market data and handling API, rate-limit, and response errors.
"""


import os
import requests
from dotenv import load_dotenv


class AlphaVantageClient:

    def __init__(self):
        load_dotenv()

        self.api_key = os.getenv("ALPHA_VANTAGE_API_KEY")
        self.base_url = "https://www.alphavantage.co/query"

        if not self.api_key:
            raise ValueError("ALPHA_VANTAGE_API_KEY is not configured.")

    def get_daily_stock_data(self, symbol):
        params = {
            "function": "TIME_SERIES_DAILY",
            "symbol": symbol,
            "outputsize": "compact",
            "apikey": self.api_key
        }

        response = requests.get(
            self.base_url,
            params=params,
            timeout=30
        )

        response.raise_for_status()

        data = response.json()

        if "Error Message" in data:
            raise ValueError(
                f"API error for {symbol}: {data['Error Message']}"
            )

        if "Note" in data:
            raise RuntimeError(
                f"API rate limit message for {symbol}: {data['Note']}"
            )

        if "Time Series (Daily)" not in data:
            raise ValueError(
                f"Unexpected API response for {symbol}"
            )

        return data